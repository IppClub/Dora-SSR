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
local pcall <const> = pcall -- 10
local json <const> = json -- 10
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
HttpServer:post("/agent/session/resend", function(req) -- 148
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
			local messageId -- 149
			do -- 149
				local _obj_0 = req.body -- 149
				local _type_1 = type(_obj_0) -- 149
				if "table" == _type_1 or "userdata" == _type_1 then -- 149
					messageId = _obj_0.messageId -- 149
				end -- 149
			end -- 149
			local prompt -- 149
			do -- 149
				local _obj_0 = req.body -- 149
				local _type_1 = type(_obj_0) -- 149
				if "table" == _type_1 or "userdata" == _type_1 then -- 149
					prompt = _obj_0.prompt -- 149
				end -- 149
			end -- 149
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 149
				return AgentSession.resendPrompt(sessionId, messageId, prompt) -- 150
			end -- 149
		end -- 149
	end -- 149
	return invalidArguments -- 148
end) -- 148
HttpServer:post("/agent/task/status", function(req) -- 152
	do -- 153
		local _type_0 = type(req) -- 153
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 153
		if _tab_0 then -- 153
			local sessionId -- 153
			do -- 153
				local _obj_0 = req.body -- 153
				local _type_1 = type(_obj_0) -- 153
				if "table" == _type_1 or "userdata" == _type_1 then -- 153
					sessionId = _obj_0.sessionId -- 153
				end -- 153
			end -- 153
			if sessionId ~= nil then -- 153
				local res = AgentSession.getSession(sessionId) -- 154
				if not res.success then -- 155
					return res -- 155
				end -- 155
				local taskId = res.session.currentTaskId -- 156
				local checkpoints -- 157
				if taskId then -- 157
					checkpoints = AgentTools.listCheckpoints(taskId) -- 157
				else -- 157
					checkpoints = { } -- 157
				end -- 157
				return { -- 159
					success = true, -- 159
					session = res.session, -- 160
					relatedSessions = res.relatedSessions, -- 161
					spawnInfo = res.spawnInfo, -- 162
					messages = res.messages, -- 163
					steps = res.steps, -- 164
					checkpoints = checkpoints -- 165
				} -- 158
			end -- 153
		end -- 153
	end -- 153
	return invalidArguments -- 152
end) -- 152
HttpServer:post("/agent/task/running", function() -- 167
	local res = AgentSession.listRunningSessions() -- 168
	if res.success and #res.sessions == 0 then -- 169
		res.sessions = nil -- 170
	end -- 169
	return res -- 171
end) -- 167
HttpServer:post("/agent/task/stop", function(req) -- 173
	do -- 174
		local _type_0 = type(req) -- 174
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 174
		if _tab_0 then -- 174
			local sessionId -- 174
			do -- 174
				local _obj_0 = req.body -- 174
				local _type_1 = type(_obj_0) -- 174
				if "table" == _type_1 or "userdata" == _type_1 then -- 174
					sessionId = _obj_0.sessionId -- 174
				end -- 174
			end -- 174
			if sessionId ~= nil then -- 174
				return AgentSession.stopSessionTask(sessionId) -- 175
			end -- 174
		end -- 174
	end -- 174
	return invalidArguments -- 173
end) -- 173
HttpServer:post("/agent/checkpoint/list", function(req) -- 177
	do -- 178
		local _type_0 = type(req) -- 178
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 178
		if _tab_0 then -- 178
			local taskId -- 178
			do -- 178
				local _obj_0 = req.body -- 178
				local _type_1 = type(_obj_0) -- 178
				if "table" == _type_1 or "userdata" == _type_1 then -- 178
					taskId = _obj_0.taskId -- 178
				end -- 178
			end -- 178
			local sessionId -- 178
			do -- 178
				local _obj_0 = req.body -- 178
				local _type_1 = type(_obj_0) -- 178
				if "table" == _type_1 or "userdata" == _type_1 then -- 178
					sessionId = _obj_0.sessionId -- 178
				end -- 178
			end -- 178
			if sessionId ~= nil then -- 178
				if not taskId and sessionId then -- 179
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 180
				end -- 179
				if not taskId then -- 181
					return { -- 181
						success = false, -- 181
						message = "task not found" -- 181
					} -- 181
				end -- 181
				return { -- 183
					success = true, -- 183
					taskId = taskId, -- 184
					checkpoints = AgentTools.listCheckpoints(taskId) -- 185
				} -- 182
			end -- 178
		end -- 178
	end -- 178
	return invalidArguments -- 177
end) -- 177
HttpServer:post("/agent/checkpoint/diff", function(req) -- 187
	do -- 188
		local _type_0 = type(req) -- 188
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 188
		if _tab_0 then -- 188
			local checkpointId -- 188
			do -- 188
				local _obj_0 = req.body -- 188
				local _type_1 = type(_obj_0) -- 188
				if "table" == _type_1 or "userdata" == _type_1 then -- 188
					checkpointId = _obj_0.checkpointId -- 188
				end -- 188
			end -- 188
			if checkpointId ~= nil then -- 188
				if not (checkpointId > 0) then -- 189
					return { -- 189
						success = false, -- 189
						message = "invalid checkpointId" -- 189
					} -- 189
				end -- 189
				return AgentTools.getCheckpointDiff(checkpointId) -- 190
			end -- 188
		end -- 188
	end -- 188
	return invalidArguments -- 187
end) -- 187
HttpServer:post("/agent/task/diff", function(req) -- 192
	do -- 193
		local _type_0 = type(req) -- 193
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 193
		if _tab_0 then -- 193
			local taskId -- 193
			do -- 193
				local _obj_0 = req.body -- 193
				local _type_1 = type(_obj_0) -- 193
				if "table" == _type_1 or "userdata" == _type_1 then -- 193
					taskId = _obj_0.taskId -- 193
				end -- 193
			end -- 193
			if taskId ~= nil then -- 193
				if not (taskId > 0) then -- 194
					return { -- 194
						success = false, -- 194
						message = "invalid taskId" -- 194
					} -- 194
				end -- 194
				return AgentTools.getTaskChangeSetDiff(taskId) -- 195
			end -- 193
		end -- 193
	end -- 193
	return invalidArguments -- 192
end) -- 192
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 197
	do -- 198
		local _type_0 = type(req) -- 198
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 198
		if _tab_0 then -- 198
			local sessionId -- 198
			do -- 198
				local _obj_0 = req.body -- 198
				local _type_1 = type(_obj_0) -- 198
				if "table" == _type_1 or "userdata" == _type_1 then -- 198
					sessionId = _obj_0.sessionId -- 198
				end -- 198
			end -- 198
			local checkpointId -- 198
			do -- 198
				local _obj_0 = req.body -- 198
				local _type_1 = type(_obj_0) -- 198
				if "table" == _type_1 or "userdata" == _type_1 then -- 198
					checkpointId = _obj_0.checkpointId -- 198
				end -- 198
			end -- 198
			if sessionId ~= nil and checkpointId ~= nil then -- 198
				if not (checkpointId > 0) then -- 199
					return { -- 199
						success = false, -- 199
						message = "invalid checkpointId" -- 199
					} -- 199
				end -- 199
				local res = AgentSession.getSession(sessionId) -- 200
				if not res.success then -- 201
					return res -- 201
				end -- 201
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, res.session.projectRoot) -- 202
				if not rollbackRes.success then -- 203
					return rollbackRes -- 203
				end -- 203
				return { -- 205
					success = true, -- 205
					checkpointId = rollbackRes.checkpointId -- 206
				} -- 204
			end -- 198
		end -- 198
	end -- 198
	return invalidArguments -- 197
end) -- 197
HttpServer:post("/agent/task/rollback", function(req) -- 208
	do -- 209
		local _type_0 = type(req) -- 209
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 209
		if _tab_0 then -- 209
			local sessionId -- 209
			do -- 209
				local _obj_0 = req.body -- 209
				local _type_1 = type(_obj_0) -- 209
				if "table" == _type_1 or "userdata" == _type_1 then -- 209
					sessionId = _obj_0.sessionId -- 209
				end -- 209
			end -- 209
			local taskId -- 209
			do -- 209
				local _obj_0 = req.body -- 209
				local _type_1 = type(_obj_0) -- 209
				if "table" == _type_1 or "userdata" == _type_1 then -- 209
					taskId = _obj_0.taskId -- 209
				end -- 209
			end -- 209
			if sessionId ~= nil and taskId ~= nil then -- 209
				if not (taskId > 0) then -- 210
					return { -- 210
						success = false, -- 210
						message = "invalid taskId" -- 210
					} -- 210
				end -- 210
				local res = AgentSession.getSession(sessionId) -- 211
				if not res.success then -- 212
					return res -- 212
				end -- 212
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, res.session.projectRoot) -- 213
				if not rollbackRes.success then -- 214
					return rollbackRes -- 214
				end -- 214
				return { -- 216
					success = true, -- 216
					taskId = rollbackRes.taskId, -- 217
					checkpointId = rollbackRes.checkpointId, -- 218
					checkpointCount = rollbackRes.checkpointCount -- 219
				} -- 215
			end -- 209
		end -- 209
	end -- 209
	return invalidArguments -- 208
end) -- 208
local getSearchPath -- 221
getSearchPath = function(file) -- 221
	do -- 222
		local dir = getProjectDirFromFile(file) -- 222
		if dir then -- 222
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 223
		end -- 222
	end -- 222
	return "" -- 221
end -- 221
local getSearchFolders -- 225
getSearchFolders = function(file) -- 225
	do -- 226
		local dir = getProjectDirFromFile(file) -- 226
		if dir then -- 226
			return { -- 228
				Path(dir, "Script"), -- 228
				dir -- 229
			} -- 227
		end -- 226
	end -- 226
	return { } -- 225
end -- 225
local disabledCheckForLua = { -- 232
	"incompatible number of returns", -- 232
	"unknown", -- 233
	"cannot index", -- 234
	"module not found", -- 235
	"don't know how to resolve", -- 236
	"ContainerItem", -- 237
	"cannot resolve a type", -- 238
	"invalid key", -- 239
	"inconsistent index type", -- 240
	"cannot use operator", -- 241
	"attempting ipairs loop", -- 242
	"expects record or nominal", -- 243
	"variable is not being assigned", -- 244
	"<invalid type>", -- 245
	"<any type>", -- 246
	"using the '#' operator", -- 247
	"can't match a record", -- 248
	"redeclaration of variable", -- 249
	"cannot apply pairs", -- 250
	"not a function", -- 251
	"to%-be%-closed" -- 252
} -- 231
local yueCheck -- 254
yueCheck = function(file, content, lax) -- 254
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 255
	if isTIC80 then -- 256
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 257
	end -- 256
	local searchPath = getSearchPath(file) -- 258
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 259
	local info = { } -- 260
	local globals = { } -- 261
	for _index_0 = 1, #checkResult do -- 262
		local _des_0 = checkResult[_index_0] -- 262
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 262
		if "error" == t then -- 263
			info[#info + 1] = { -- 264
				"syntax", -- 264
				file, -- 264
				line, -- 264
				col, -- 264
				msg -- 264
			} -- 264
		elseif "global" == t then -- 265
			globals[#globals + 1] = { -- 266
				msg, -- 266
				line, -- 266
				col -- 266
			} -- 266
		end -- 263
	end -- 262
	if luaCodes then -- 267
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 268
		if success then -- 269
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 270
			if not (lintResult == "") then -- 271
				lintResult = lintResult .. "\n" -- 271
			end -- 271
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 272
		else -- 273
			for _index_0 = 1, #lintResult do -- 273
				local _des_0 = lintResult[_index_0] -- 273
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 273
				if isTIC80 and tic80APIs[name] then -- 274
					goto _continue_0 -- 274
				end -- 274
				info[#info + 1] = { -- 275
					"syntax", -- 275
					file, -- 275
					line, -- 275
					col, -- 275
					"invalid global variable" -- 275
				} -- 275
				::_continue_0:: -- 274
			end -- 273
		end -- 269
	end -- 267
	return luaCodes, info -- 276
end -- 254
local luaCheck -- 278
luaCheck = function(file, content) -- 278
	local res, err = load(content, "check") -- 279
	if not res then -- 280
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 281
		return { -- 282
			success = false, -- 282
			info = { -- 282
				{ -- 282
					"syntax", -- 282
					file, -- 282
					tonumber(line), -- 282
					0, -- 282
					msg -- 282
				} -- 282
			} -- 282
		} -- 282
	end -- 280
	local success, info = teal.checkAsync(content, file, true, "") -- 283
	if info then -- 284
		do -- 285
			local _accum_0 = { } -- 285
			local _len_0 = 1 -- 285
			for _index_0 = 1, #info do -- 285
				local item = info[_index_0] -- 285
				local useCheck = true -- 286
				if not item[5]:match("unused") then -- 287
					for _index_1 = 1, #disabledCheckForLua do -- 288
						local check = disabledCheckForLua[_index_1] -- 288
						if item[5]:match(check) then -- 289
							useCheck = false -- 290
						end -- 289
					end -- 288
				end -- 287
				if not useCheck then -- 291
					goto _continue_0 -- 291
				end -- 291
				do -- 292
					local _exp_0 = item[1] -- 292
					if "type" == _exp_0 then -- 293
						item[1] = "warning" -- 294
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 295
						goto _continue_0 -- 296
					end -- 292
				end -- 292
				_accum_0[_len_0] = item -- 297
				_len_0 = _len_0 + 1 -- 286
				::_continue_0:: -- 286
			end -- 285
			info = _accum_0 -- 285
		end -- 285
		if #info == 0 then -- 298
			info = nil -- 299
			success = true -- 300
		end -- 298
	end -- 284
	return { -- 301
		success = success, -- 301
		info = info -- 301
	} -- 301
end -- 278
local luaCheckWithLineInfo -- 303
luaCheckWithLineInfo = function(file, luaCodes) -- 303
	local res = luaCheck(file, luaCodes) -- 304
	local info = { } -- 305
	if not res.success then -- 306
		local current = 1 -- 307
		local lastLine = 1 -- 308
		local lineMap = { } -- 309
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 310
			local num = lineCode:match("--%s*(%d+)%s*$") -- 311
			if num then -- 312
				lastLine = tonumber(num) -- 313
			end -- 312
			lineMap[current] = lastLine -- 314
			current = current + 1 -- 315
		end -- 310
		local _list_0 = res.info -- 316
		for _index_0 = 1, #_list_0 do -- 316
			local item = _list_0[_index_0] -- 316
			item[3] = lineMap[item[3]] or 0 -- 317
			item[4] = 0 -- 318
			info[#info + 1] = item -- 319
		end -- 316
		return false, info -- 320
	end -- 306
	return true, info -- 321
end -- 303
local getCompiledYueLine -- 323
getCompiledYueLine = function(content, line, row, file, lax) -- 323
	local luaCodes = yueCheck(file, content, lax) -- 324
	if not luaCodes then -- 325
		return nil -- 325
	end -- 325
	local current = 1 -- 326
	local lastLine = 1 -- 327
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 328
	local targetRow = nil -- 329
	local lineMap = { } -- 330
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 331
		local num = lineCode:match("--%s*(%d+)%s*$") -- 332
		if num then -- 333
			lastLine = tonumber(num) -- 333
		end -- 333
		lineMap[current] = lastLine -- 334
		if row <= lastLine and not targetRow then -- 335
			targetRow = current -- 336
			break -- 337
		end -- 335
		current = current + 1 -- 338
	end -- 331
	targetRow = current -- 339
	if targetLine and targetRow then -- 340
		return luaCodes, targetLine, targetRow, lineMap -- 341
	else -- 343
		return nil -- 343
	end -- 340
end -- 323
HttpServer:postSchedule("/check", function(req) -- 345
	do -- 346
		local _type_0 = type(req) -- 346
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 346
		if _tab_0 then -- 346
			local file -- 346
			do -- 346
				local _obj_0 = req.body -- 346
				local _type_1 = type(_obj_0) -- 346
				if "table" == _type_1 or "userdata" == _type_1 then -- 346
					file = _obj_0.file -- 346
				end -- 346
			end -- 346
			local content -- 346
			do -- 346
				local _obj_0 = req.body -- 346
				local _type_1 = type(_obj_0) -- 346
				if "table" == _type_1 or "userdata" == _type_1 then -- 346
					content = _obj_0.content -- 346
				end -- 346
			end -- 346
			if file ~= nil and content ~= nil then -- 346
				local ext = Path:getExt(file) -- 347
				if "tl" == ext then -- 348
					local searchPath = getSearchPath(file) -- 349
					do -- 350
						local isTIC80 = CheckTIC80Code(content) -- 350
						if isTIC80 then -- 350
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 351
						end -- 350
					end -- 350
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 352
					return { -- 353
						success = success, -- 353
						info = info -- 353
					} -- 353
				elseif "lua" == ext then -- 354
					do -- 355
						local isTIC80 = CheckTIC80Code(content) -- 355
						if isTIC80 then -- 355
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 356
						end -- 355
					end -- 355
					return luaCheck(file, content) -- 357
				elseif "yue" == ext then -- 358
					local luaCodes, info = yueCheck(file, content, false) -- 359
					local success = false -- 360
					if luaCodes then -- 361
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 362
						do -- 363
							local _tab_1 = { } -- 363
							local _idx_0 = #_tab_1 + 1 -- 363
							for _index_0 = 1, #info do -- 363
								local _value_0 = info[_index_0] -- 363
								_tab_1[_idx_0] = _value_0 -- 363
								_idx_0 = _idx_0 + 1 -- 363
							end -- 363
							local _idx_1 = #_tab_1 + 1 -- 363
							for _index_0 = 1, #luaInfo do -- 363
								local _value_0 = luaInfo[_index_0] -- 363
								_tab_1[_idx_1] = _value_0 -- 363
								_idx_1 = _idx_1 + 1 -- 363
							end -- 363
							info = _tab_1 -- 363
						end -- 363
						success = success and luaSuccess -- 364
					end -- 361
					if #info > 0 then -- 365
						return { -- 366
							success = success, -- 366
							info = info -- 366
						} -- 366
					else -- 368
						return { -- 368
							success = success -- 368
						} -- 368
					end -- 365
				elseif "xml" == ext then -- 369
					local success, result = xml.check(content) -- 370
					if success then -- 371
						local info -- 372
						success, info = luaCheckWithLineInfo(file, result) -- 372
						if #info > 0 then -- 373
							return { -- 374
								success = success, -- 374
								info = info -- 374
							} -- 374
						else -- 376
							return { -- 376
								success = success -- 376
							} -- 376
						end -- 373
					else -- 378
						local info -- 378
						do -- 378
							local _accum_0 = { } -- 378
							local _len_0 = 1 -- 378
							for _index_0 = 1, #result do -- 378
								local _des_0 = result[_index_0] -- 378
								local row, err = _des_0[1], _des_0[2] -- 378
								_accum_0[_len_0] = { -- 379
									"syntax", -- 379
									file, -- 379
									row, -- 379
									0, -- 379
									err -- 379
								} -- 379
								_len_0 = _len_0 + 1 -- 379
							end -- 378
							info = _accum_0 -- 378
						end -- 378
						return { -- 380
							success = false, -- 380
							info = info -- 380
						} -- 380
					end -- 371
				end -- 348
			end -- 346
		end -- 346
	end -- 346
	return { -- 345
		success = true -- 345
	} -- 345
end) -- 345
HttpServer:post("/body/parse", function(req) -- 382
	do -- 383
		local _type_0 = type(req) -- 383
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 383
		if _tab_0 then -- 383
			local file -- 383
			do -- 383
				local _obj_0 = req.body -- 383
				local _type_1 = type(_obj_0) -- 383
				if "table" == _type_1 or "userdata" == _type_1 then -- 383
					file = _obj_0.file -- 383
				end -- 383
			end -- 383
			local content -- 383
			do -- 383
				local _obj_0 = req.body -- 383
				local _type_1 = type(_obj_0) -- 383
				if "table" == _type_1 or "userdata" == _type_1 then -- 383
					content = _obj_0.content -- 383
				end -- 383
			end -- 383
			if file ~= nil and content ~= nil then -- 383
				if not (file:sub(-6) == ".b.lua") then -- 384
					return { -- 385
						success = false, -- 385
						phase = "request", -- 385
						message = "only .b.lua files can be converted" -- 385
					} -- 385
				end -- 384
				local loader, err = load("_ENV = {}\n" .. content) -- 386
				if not loader then -- 387
					return { -- 388
						success = false, -- 388
						phase = "parse", -- 388
						message = tostring(err) -- 388
					} -- 388
				end -- 387
				local ok, data = pcall(loader) -- 389
				if not ok then -- 390
					return { -- 391
						success = false, -- 391
						phase = "execute", -- 391
						message = tostring(data) -- 391
					} -- 391
				end -- 390
				if not ("table" == type(data) and data[1] == "Array") then -- 392
					return { -- 393
						success = false, -- 393
						phase = "validate", -- 393
						message = "body lua root must be {\"Array\", ...}" -- 393
					} -- 393
				end -- 392
				local text, jsonErr = json.encode(data, false, true) -- 394
				if not text then -- 395
					return { -- 396
						success = false, -- 396
						phase = "encode", -- 396
						message = tostring(jsonErr) -- 396
					} -- 396
				end -- 395
				return { -- 397
					success = true, -- 397
					json = text -- 397
				} -- 397
			end -- 383
		end -- 383
	end -- 383
	return { -- 382
		success = false, -- 382
		phase = "request", -- 382
		message = "invalid request" -- 382
	} -- 382
end) -- 382
local updateInferedDesc -- 399
updateInferedDesc = function(infered) -- 399
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 400
		return -- 400
	end -- 400
	local key, row = infered.key, infered.row -- 401
	local codes = Content:loadAsync(key) -- 402
	if codes then -- 402
		local comments = { } -- 403
		local line = 0 -- 404
		local skipping = false -- 405
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 406
			line = line + 1 -- 407
			if line >= row then -- 408
				break -- 408
			end -- 408
			if lineCode:match("^%s*%-%- @") then -- 409
				skipping = true -- 410
				goto _continue_0 -- 411
			end -- 409
			local result = lineCode:match("^%s*%-%- (.+)") -- 412
			if result then -- 412
				if not skipping then -- 413
					comments[#comments + 1] = result -- 413
				end -- 413
			elseif #comments > 0 then -- 414
				comments = { } -- 415
				skipping = false -- 416
			end -- 412
			::_continue_0:: -- 407
		end -- 406
		infered.doc = table.concat(comments, "\n") -- 417
	end -- 402
end -- 399
HttpServer:postSchedule("/infer", function(req) -- 419
	do -- 420
		local _type_0 = type(req) -- 420
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 420
		if _tab_0 then -- 420
			local lang -- 420
			do -- 420
				local _obj_0 = req.body -- 420
				local _type_1 = type(_obj_0) -- 420
				if "table" == _type_1 or "userdata" == _type_1 then -- 420
					lang = _obj_0.lang -- 420
				end -- 420
			end -- 420
			local file -- 420
			do -- 420
				local _obj_0 = req.body -- 420
				local _type_1 = type(_obj_0) -- 420
				if "table" == _type_1 or "userdata" == _type_1 then -- 420
					file = _obj_0.file -- 420
				end -- 420
			end -- 420
			local content -- 420
			do -- 420
				local _obj_0 = req.body -- 420
				local _type_1 = type(_obj_0) -- 420
				if "table" == _type_1 or "userdata" == _type_1 then -- 420
					content = _obj_0.content -- 420
				end -- 420
			end -- 420
			local line -- 420
			do -- 420
				local _obj_0 = req.body -- 420
				local _type_1 = type(_obj_0) -- 420
				if "table" == _type_1 or "userdata" == _type_1 then -- 420
					line = _obj_0.line -- 420
				end -- 420
			end -- 420
			local row -- 420
			do -- 420
				local _obj_0 = req.body -- 420
				local _type_1 = type(_obj_0) -- 420
				if "table" == _type_1 or "userdata" == _type_1 then -- 420
					row = _obj_0.row -- 420
				end -- 420
			end -- 420
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 420
				local searchPath = getSearchPath(file) -- 421
				if "tl" == lang or "lua" == lang then -- 422
					if CheckTIC80Code(content) then -- 423
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 424
					end -- 423
					local infered = teal.inferAsync(content, line, row, searchPath) -- 425
					if (infered ~= nil) then -- 426
						updateInferedDesc(infered) -- 427
						return { -- 428
							success = true, -- 428
							infered = infered -- 428
						} -- 428
					end -- 426
				elseif "yue" == lang then -- 429
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 430
					if not luaCodes then -- 431
						return { -- 431
							success = false -- 431
						} -- 431
					end -- 431
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 432
					if (infered ~= nil) then -- 433
						local col -- 434
						file, row, col = infered.file, infered.row, infered.col -- 434
						if file == "" and row > 0 and col > 0 then -- 435
							infered.row = lineMap[row] or 0 -- 436
							infered.col = 0 -- 437
						end -- 435
						updateInferedDesc(infered) -- 438
						return { -- 439
							success = true, -- 439
							infered = infered -- 439
						} -- 439
					end -- 433
				end -- 422
			end -- 420
		end -- 420
	end -- 420
	return { -- 419
		success = false -- 419
	} -- 419
end) -- 419
local _anon_func_2 = function(doc) -- 490
	local _accum_0 = { } -- 490
	local _len_0 = 1 -- 490
	local _list_0 = doc.params -- 490
	for _index_0 = 1, #_list_0 do -- 490
		local param = _list_0[_index_0] -- 490
		_accum_0[_len_0] = param.name -- 490
		_len_0 = _len_0 + 1 -- 490
	end -- 490
	return _accum_0 -- 490
end -- 490
local getParamDocs -- 441
getParamDocs = function(signatures) -- 441
	do -- 442
		local codes = Content:loadAsync(signatures[1].file) -- 442
		if codes then -- 442
			local comments = { } -- 443
			local params = { } -- 444
			local line = 0 -- 445
			local docs = { } -- 446
			local returnType = nil -- 447
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 448
				line = line + 1 -- 449
				local needBreak = true -- 450
				for i, _des_0 in ipairs(signatures) do -- 451
					local row = _des_0.row -- 451
					if line >= row and not (docs[i] ~= nil) then -- 452
						if #comments > 0 or #params > 0 or returnType then -- 453
							docs[i] = { -- 455
								doc = table.concat(comments, "  \n"), -- 455
								returnType = returnType -- 456
							} -- 454
							if #params > 0 then -- 458
								docs[i].params = params -- 458
							end -- 458
						else -- 460
							docs[i] = false -- 460
						end -- 453
					end -- 452
					if not docs[i] then -- 461
						needBreak = false -- 461
					end -- 461
				end -- 451
				if needBreak then -- 462
					break -- 462
				end -- 462
				local result = lineCode:match("%s*%-%- (.+)") -- 463
				if result then -- 463
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 464
					if not name then -- 465
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 466
					end -- 465
					if name then -- 467
						local pname = name -- 468
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 469
							pname = pname .. "?" -- 469
						end -- 469
						params[#params + 1] = { -- 471
							name = tostring(pname) .. ": " .. tostring(typ), -- 471
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 472
						} -- 470
					else -- 475
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 475
						if typ then -- 475
							if returnType then -- 476
								returnType = returnType .. ", " .. typ -- 477
							else -- 479
								returnType = typ -- 479
							end -- 476
							result = result:gsub("@return", "**return:**") -- 480
						end -- 475
						comments[#comments + 1] = result -- 481
					end -- 467
				elseif #comments > 0 then -- 482
					comments = { } -- 483
					params = { } -- 484
					returnType = nil -- 485
				end -- 463
			end -- 448
			local results = { } -- 486
			for _index_0 = 1, #docs do -- 487
				local doc = docs[_index_0] -- 487
				if not doc then -- 488
					goto _continue_0 -- 488
				end -- 488
				if doc.params then -- 489
					doc.desc = "function(" .. tostring(table.concat(_anon_func_2(doc), ', ')) .. ")" -- 490
				else -- 492
					doc.desc = "function()" -- 492
				end -- 489
				if doc.returnType then -- 493
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 494
					doc.returnType = nil -- 495
				end -- 493
				results[#results + 1] = doc -- 496
				::_continue_0:: -- 488
			end -- 487
			if #results > 0 then -- 497
				return results -- 497
			else -- 497
				return nil -- 497
			end -- 497
		end -- 442
	end -- 442
	return nil -- 441
end -- 441
HttpServer:postSchedule("/signature", function(req) -- 499
	do -- 500
		local _type_0 = type(req) -- 500
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 500
		if _tab_0 then -- 500
			local lang -- 500
			do -- 500
				local _obj_0 = req.body -- 500
				local _type_1 = type(_obj_0) -- 500
				if "table" == _type_1 or "userdata" == _type_1 then -- 500
					lang = _obj_0.lang -- 500
				end -- 500
			end -- 500
			local file -- 500
			do -- 500
				local _obj_0 = req.body -- 500
				local _type_1 = type(_obj_0) -- 500
				if "table" == _type_1 or "userdata" == _type_1 then -- 500
					file = _obj_0.file -- 500
				end -- 500
			end -- 500
			local content -- 500
			do -- 500
				local _obj_0 = req.body -- 500
				local _type_1 = type(_obj_0) -- 500
				if "table" == _type_1 or "userdata" == _type_1 then -- 500
					content = _obj_0.content -- 500
				end -- 500
			end -- 500
			local line -- 500
			do -- 500
				local _obj_0 = req.body -- 500
				local _type_1 = type(_obj_0) -- 500
				if "table" == _type_1 or "userdata" == _type_1 then -- 500
					line = _obj_0.line -- 500
				end -- 500
			end -- 500
			local row -- 500
			do -- 500
				local _obj_0 = req.body -- 500
				local _type_1 = type(_obj_0) -- 500
				if "table" == _type_1 or "userdata" == _type_1 then -- 500
					row = _obj_0.row -- 500
				end -- 500
			end -- 500
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 500
				local searchPath = getSearchPath(file) -- 501
				if "tl" == lang or "lua" == lang then -- 502
					if CheckTIC80Code(content) then -- 503
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 504
					end -- 503
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 505
					if signatures then -- 505
						signatures = getParamDocs(signatures) -- 506
						if signatures then -- 506
							return { -- 507
								success = true, -- 507
								signatures = signatures -- 507
							} -- 507
						end -- 506
					end -- 505
				elseif "yue" == lang then -- 508
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 509
					if not luaCodes then -- 510
						return { -- 510
							success = false -- 510
						} -- 510
					end -- 510
					do -- 511
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 511
						if chainOp then -- 511
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 512
							if withVar then -- 512
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 513
							end -- 512
						end -- 511
					end -- 511
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 514
					if signatures then -- 514
						signatures = getParamDocs(signatures) -- 515
						if signatures then -- 515
							return { -- 516
								success = true, -- 516
								signatures = signatures -- 516
							} -- 516
						end -- 515
					else -- 517
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 517
						if signatures then -- 517
							signatures = getParamDocs(signatures) -- 518
							if signatures then -- 518
								return { -- 519
									success = true, -- 519
									signatures = signatures -- 519
								} -- 519
							end -- 518
						end -- 517
					end -- 514
				end -- 502
			end -- 500
		end -- 500
	end -- 500
	return { -- 499
		success = false -- 499
	} -- 499
end) -- 499
local luaKeywords = { -- 522
	'and', -- 522
	'break', -- 523
	'do', -- 524
	'else', -- 525
	'elseif', -- 526
	'end', -- 527
	'false', -- 528
	'for', -- 529
	'function', -- 530
	'goto', -- 531
	'if', -- 532
	'in', -- 533
	'local', -- 534
	'nil', -- 535
	'not', -- 536
	'or', -- 537
	'repeat', -- 538
	'return', -- 539
	'then', -- 540
	'true', -- 541
	'until', -- 542
	'while' -- 543
} -- 521
local tealKeywords = { -- 547
	'record', -- 547
	'as', -- 548
	'is', -- 549
	'type', -- 550
	'embed', -- 551
	'enum', -- 552
	'global', -- 553
	'any', -- 554
	'boolean', -- 555
	'integer', -- 556
	'number', -- 557
	'string', -- 558
	'thread' -- 559
} -- 546
local yueKeywords = { -- 563
	"and", -- 563
	"break", -- 564
	"do", -- 565
	"else", -- 566
	"elseif", -- 567
	"false", -- 568
	"for", -- 569
	"goto", -- 570
	"if", -- 571
	"in", -- 572
	"local", -- 573
	"nil", -- 574
	"not", -- 575
	"or", -- 576
	"repeat", -- 577
	"return", -- 578
	"then", -- 579
	"true", -- 580
	"until", -- 581
	"while", -- 582
	"as", -- 583
	"class", -- 584
	"continue", -- 585
	"export", -- 586
	"extends", -- 587
	"from", -- 588
	"global", -- 589
	"import", -- 590
	"macro", -- 591
	"switch", -- 592
	"try", -- 593
	"unless", -- 594
	"using", -- 595
	"when", -- 596
	"with" -- 597
} -- 562
local _anon_func_3 = function(f) -- 633
	local _val_0 = Path:getExt(f) -- 633
	return "ttf" == _val_0 or "otf" == _val_0 -- 633
end -- 633
local _anon_func_4 = function(suggestions) -- 659
	local _tbl_0 = { } -- 659
	for _index_0 = 1, #suggestions do -- 659
		local item = suggestions[_index_0] -- 659
		_tbl_0[item[1] .. item[2]] = item -- 659
	end -- 659
	return _tbl_0 -- 659
end -- 659
HttpServer:postSchedule("/complete", function(req) -- 600
	do -- 601
		local _type_0 = type(req) -- 601
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 601
		if _tab_0 then -- 601
			local lang -- 601
			do -- 601
				local _obj_0 = req.body -- 601
				local _type_1 = type(_obj_0) -- 601
				if "table" == _type_1 or "userdata" == _type_1 then -- 601
					lang = _obj_0.lang -- 601
				end -- 601
			end -- 601
			local file -- 601
			do -- 601
				local _obj_0 = req.body -- 601
				local _type_1 = type(_obj_0) -- 601
				if "table" == _type_1 or "userdata" == _type_1 then -- 601
					file = _obj_0.file -- 601
				end -- 601
			end -- 601
			local content -- 601
			do -- 601
				local _obj_0 = req.body -- 601
				local _type_1 = type(_obj_0) -- 601
				if "table" == _type_1 or "userdata" == _type_1 then -- 601
					content = _obj_0.content -- 601
				end -- 601
			end -- 601
			local line -- 601
			do -- 601
				local _obj_0 = req.body -- 601
				local _type_1 = type(_obj_0) -- 601
				if "table" == _type_1 or "userdata" == _type_1 then -- 601
					line = _obj_0.line -- 601
				end -- 601
			end -- 601
			local row -- 601
			do -- 601
				local _obj_0 = req.body -- 601
				local _type_1 = type(_obj_0) -- 601
				if "table" == _type_1 or "userdata" == _type_1 then -- 601
					row = _obj_0.row -- 601
				end -- 601
			end -- 601
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 601
				local searchPath = getSearchPath(file) -- 602
				repeat -- 603
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 604
					if lang == "yue" then -- 605
						if not item then -- 606
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 606
						end -- 606
						if not item then -- 607
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 607
						end -- 607
					end -- 605
					local searchType = nil -- 608
					if not item then -- 609
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 610
						if lang == "yue" then -- 611
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 612
						end -- 611
						if (item ~= nil) then -- 613
							searchType = "Image" -- 613
						end -- 613
					end -- 609
					if not item then -- 614
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 615
						if lang == "yue" then -- 616
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 617
						end -- 616
						if (item ~= nil) then -- 618
							searchType = "Font" -- 618
						end -- 618
					end -- 614
					if not item then -- 619
						break -- 619
					end -- 619
					local searchPaths = Content.searchPaths -- 620
					local _list_0 = getSearchFolders(file) -- 621
					for _index_0 = 1, #_list_0 do -- 621
						local folder = _list_0[_index_0] -- 621
						searchPaths[#searchPaths + 1] = folder -- 622
					end -- 621
					if searchType then -- 623
						searchPaths[#searchPaths + 1] = Content.assetPath -- 623
					end -- 623
					local tokens -- 624
					do -- 624
						local _accum_0 = { } -- 624
						local _len_0 = 1 -- 624
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 624
							_accum_0[_len_0] = mod -- 624
							_len_0 = _len_0 + 1 -- 624
						end -- 624
						tokens = _accum_0 -- 624
					end -- 624
					local suggestions = { } -- 625
					for _index_0 = 1, #searchPaths do -- 626
						local path = searchPaths[_index_0] -- 626
						local sPath = Path(path, table.unpack(tokens)) -- 627
						if not Content:exist(sPath) then -- 628
							goto _continue_0 -- 628
						end -- 628
						if searchType == "Font" then -- 629
							local fontPath = Path(sPath, "Font") -- 630
							if Content:exist(fontPath) then -- 631
								local _list_1 = Content:getFiles(fontPath) -- 632
								for _index_1 = 1, #_list_1 do -- 632
									local f = _list_1[_index_1] -- 632
									if _anon_func_3(f) then -- 633
										if "." == f:sub(1, 1) then -- 634
											goto _continue_1 -- 634
										end -- 634
										suggestions[#suggestions + 1] = { -- 635
											Path:getName(f), -- 635
											"font", -- 635
											"field" -- 635
										} -- 635
									end -- 633
									::_continue_1:: -- 633
								end -- 632
							end -- 631
						end -- 629
						local _list_1 = Content:getFiles(sPath) -- 636
						for _index_1 = 1, #_list_1 do -- 636
							local f = _list_1[_index_1] -- 636
							if "Image" == searchType then -- 637
								do -- 638
									local _exp_0 = Path:getExt(f) -- 638
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 638
										if "." == f:sub(1, 1) then -- 639
											goto _continue_2 -- 639
										end -- 639
										suggestions[#suggestions + 1] = { -- 640
											f, -- 640
											"image", -- 640
											"field" -- 640
										} -- 640
									end -- 638
								end -- 638
								goto _continue_2 -- 641
							elseif "Font" == searchType then -- 642
								do -- 643
									local _exp_0 = Path:getExt(f) -- 643
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 643
										if "." == f:sub(1, 1) then -- 644
											goto _continue_2 -- 644
										end -- 644
										suggestions[#suggestions + 1] = { -- 645
											f, -- 645
											"font", -- 645
											"field" -- 645
										} -- 645
									end -- 643
								end -- 643
								goto _continue_2 -- 646
							end -- 637
							local _exp_0 = Path:getExt(f) -- 647
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 647
								local name = Path:getName(f) -- 648
								if "d" == Path:getExt(name) then -- 649
									goto _continue_2 -- 649
								end -- 649
								if "." == name:sub(1, 1) then -- 650
									goto _continue_2 -- 650
								end -- 650
								suggestions[#suggestions + 1] = { -- 651
									name, -- 651
									"module", -- 651
									"field" -- 651
								} -- 651
							end -- 647
							::_continue_2:: -- 637
						end -- 636
						local _list_2 = Content:getDirs(sPath) -- 652
						for _index_1 = 1, #_list_2 do -- 652
							local dir = _list_2[_index_1] -- 652
							if "." == dir:sub(1, 1) then -- 653
								goto _continue_3 -- 653
							end -- 653
							suggestions[#suggestions + 1] = { -- 654
								dir, -- 654
								"folder", -- 654
								"variable" -- 654
							} -- 654
							::_continue_3:: -- 653
						end -- 652
						::_continue_0:: -- 627
					end -- 626
					if item == "" and not searchType then -- 655
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 656
						for _index_0 = 1, #_list_1 do -- 656
							local _des_0 = _list_1[_index_0] -- 656
							local name = _des_0[1] -- 656
							suggestions[#suggestions + 1] = { -- 657
								name, -- 657
								"dora module", -- 657
								"function" -- 657
							} -- 657
						end -- 656
					end -- 655
					if #suggestions > 0 then -- 658
						do -- 659
							local _accum_0 = { } -- 659
							local _len_0 = 1 -- 659
							for _, v in pairs(_anon_func_4(suggestions)) do -- 659
								_accum_0[_len_0] = v -- 659
								_len_0 = _len_0 + 1 -- 659
							end -- 659
							suggestions = _accum_0 -- 659
						end -- 659
						return { -- 660
							success = true, -- 660
							suggestions = suggestions -- 660
						} -- 660
					else -- 662
						return { -- 662
							success = false -- 662
						} -- 662
					end -- 658
				until true -- 603
				if "tl" == lang or "lua" == lang then -- 664
					do -- 665
						local isTIC80 = CheckTIC80Code(content) -- 665
						if isTIC80 then -- 665
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 666
						end -- 665
					end -- 665
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 667
					if not line:match("[%.:]$") then -- 668
						local checkSet -- 669
						do -- 669
							local _tbl_0 = { } -- 669
							for _index_0 = 1, #suggestions do -- 669
								local _des_0 = suggestions[_index_0] -- 669
								local name = _des_0[1] -- 669
								_tbl_0[name] = true -- 669
							end -- 669
							checkSet = _tbl_0 -- 669
						end -- 669
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 670
						for _index_0 = 1, #_list_0 do -- 670
							local item = _list_0[_index_0] -- 670
							if not checkSet[item[1]] then -- 671
								suggestions[#suggestions + 1] = item -- 671
							end -- 671
						end -- 670
						for _index_0 = 1, #luaKeywords do -- 672
							local word = luaKeywords[_index_0] -- 672
							suggestions[#suggestions + 1] = { -- 673
								word, -- 673
								"keyword", -- 673
								"keyword" -- 673
							} -- 673
						end -- 672
						if lang == "tl" then -- 674
							for _index_0 = 1, #tealKeywords do -- 675
								local word = tealKeywords[_index_0] -- 675
								suggestions[#suggestions + 1] = { -- 676
									word, -- 676
									"keyword", -- 676
									"keyword" -- 676
								} -- 676
							end -- 675
						end -- 674
					end -- 668
					if #suggestions > 0 then -- 677
						return { -- 678
							success = true, -- 678
							suggestions = suggestions -- 678
						} -- 678
					end -- 677
				elseif "yue" == lang then -- 679
					local suggestions = { } -- 680
					local gotGlobals = false -- 681
					do -- 682
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 682
						if luaCodes then -- 682
							gotGlobals = true -- 683
							do -- 684
								local chainOp = line:match("[^%w_]([%.\\])$") -- 684
								if chainOp then -- 684
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 685
									if not withVar then -- 686
										return { -- 686
											success = false -- 686
										} -- 686
									end -- 686
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 687
								elseif line:match("^([%.\\])$") then -- 688
									return { -- 689
										success = false -- 689
									} -- 689
								end -- 684
							end -- 684
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 690
							for _index_0 = 1, #_list_0 do -- 690
								local item = _list_0[_index_0] -- 690
								suggestions[#suggestions + 1] = item -- 690
							end -- 690
							if #suggestions == 0 then -- 691
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 692
								for _index_0 = 1, #_list_1 do -- 692
									local item = _list_1[_index_0] -- 692
									suggestions[#suggestions + 1] = item -- 692
								end -- 692
							end -- 691
						end -- 682
					end -- 682
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 693
						local checkSet -- 694
						do -- 694
							local _tbl_0 = { } -- 694
							for _index_0 = 1, #suggestions do -- 694
								local _des_0 = suggestions[_index_0] -- 694
								local name = _des_0[1] -- 694
								_tbl_0[name] = true -- 694
							end -- 694
							checkSet = _tbl_0 -- 694
						end -- 694
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 695
						for _index_0 = 1, #_list_0 do -- 695
							local item = _list_0[_index_0] -- 695
							if not checkSet[item[1]] then -- 696
								suggestions[#suggestions + 1] = item -- 696
							end -- 696
						end -- 695
						if not gotGlobals then -- 697
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 698
							for _index_0 = 1, #_list_1 do -- 698
								local item = _list_1[_index_0] -- 698
								if not checkSet[item[1]] then -- 699
									suggestions[#suggestions + 1] = item -- 699
								end -- 699
							end -- 698
						end -- 697
						for _index_0 = 1, #yueKeywords do -- 700
							local word = yueKeywords[_index_0] -- 700
							if not checkSet[word] then -- 701
								suggestions[#suggestions + 1] = { -- 702
									word, -- 702
									"keyword", -- 702
									"keyword" -- 702
								} -- 702
							end -- 701
						end -- 700
					end -- 693
					if #suggestions > 0 then -- 703
						return { -- 704
							success = true, -- 704
							suggestions = suggestions -- 704
						} -- 704
					end -- 703
				elseif "xml" == lang then -- 705
					local items = xml.complete(content) -- 706
					if #items > 0 then -- 707
						local suggestions -- 708
						do -- 708
							local _accum_0 = { } -- 708
							local _len_0 = 1 -- 708
							for _index_0 = 1, #items do -- 708
								local _des_0 = items[_index_0] -- 708
								local label, insertText = _des_0[1], _des_0[2] -- 708
								_accum_0[_len_0] = { -- 709
									label, -- 709
									insertText, -- 709
									"field" -- 709
								} -- 709
								_len_0 = _len_0 + 1 -- 709
							end -- 708
							suggestions = _accum_0 -- 708
						end -- 708
						return { -- 710
							success = true, -- 710
							suggestions = suggestions -- 710
						} -- 710
					end -- 707
				end -- 664
			end -- 601
		end -- 601
	end -- 601
	return { -- 600
		success = false -- 600
	} -- 600
end) -- 600
HttpServer:upload("/upload", function(req, filename) -- 714
	do -- 715
		local _type_0 = type(req) -- 715
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 715
		if _tab_0 then -- 715
			local path -- 715
			do -- 715
				local _obj_0 = req.params -- 715
				local _type_1 = type(_obj_0) -- 715
				if "table" == _type_1 or "userdata" == _type_1 then -- 715
					path = _obj_0.path -- 715
				end -- 715
			end -- 715
			if path ~= nil then -- 715
				local uploadPath = Path(Content.writablePath, ".upload") -- 716
				if not Content:exist(uploadPath) then -- 717
					Content:mkdir(uploadPath) -- 718
				end -- 717
				local targetPath = Path(uploadPath, filename) -- 719
				Content:mkdir(Path:getPath(targetPath)) -- 720
				return targetPath -- 721
			end -- 715
		end -- 715
	end -- 715
	return nil -- 714
end, function(req, file) -- 722
	do -- 723
		local _type_0 = type(req) -- 723
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 723
		if _tab_0 then -- 723
			local path -- 723
			do -- 723
				local _obj_0 = req.params -- 723
				local _type_1 = type(_obj_0) -- 723
				if "table" == _type_1 or "userdata" == _type_1 then -- 723
					path = _obj_0.path -- 723
				end -- 723
			end -- 723
			if path ~= nil then -- 723
				path = Path(Content.writablePath, path) -- 724
				if Content:exist(path) then -- 725
					local uploadPath = Path(Content.writablePath, ".upload") -- 726
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 727
					Content:mkdir(Path:getPath(targetPath)) -- 728
					if Content:move(file, targetPath) then -- 729
						return true -- 730
					end -- 729
				end -- 725
			end -- 723
		end -- 723
	end -- 723
	return false -- 722
end) -- 712
HttpServer:post("/list", function(req) -- 733
	do -- 734
		local _type_0 = type(req) -- 734
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 734
		if _tab_0 then -- 734
			local path -- 734
			do -- 734
				local _obj_0 = req.body -- 734
				local _type_1 = type(_obj_0) -- 734
				if "table" == _type_1 or "userdata" == _type_1 then -- 734
					path = _obj_0.path -- 734
				end -- 734
			end -- 734
			if path ~= nil then -- 734
				if Content:exist(path) then -- 735
					local files = { } -- 736
					local visitAssets -- 737
					visitAssets = function(path, folder) -- 737
						local dirs = Content:getDirs(path) -- 738
						for _index_0 = 1, #dirs do -- 739
							local dir = dirs[_index_0] -- 739
							if dir:match("^%.") then -- 740
								goto _continue_0 -- 740
							end -- 740
							local current -- 741
							if folder == "" then -- 741
								current = dir -- 742
							else -- 744
								current = Path(folder, dir) -- 744
							end -- 741
							files[#files + 1] = current -- 745
							visitAssets(Path(path, dir), current) -- 746
							::_continue_0:: -- 740
						end -- 739
						local fs = Content:getFiles(path) -- 747
						for _index_0 = 1, #fs do -- 748
							local f = fs[_index_0] -- 748
							if f:match("^%.") then -- 749
								goto _continue_1 -- 749
							end -- 749
							if folder == "" then -- 750
								files[#files + 1] = f -- 751
							else -- 753
								files[#files + 1] = Path(folder, f) -- 753
							end -- 750
							::_continue_1:: -- 749
						end -- 748
					end -- 737
					visitAssets(path, "") -- 754
					if #files == 0 then -- 755
						files = nil -- 755
					end -- 755
					return { -- 756
						success = true, -- 756
						files = files -- 756
					} -- 756
				end -- 735
			end -- 734
		end -- 734
	end -- 734
	return { -- 733
		success = false -- 733
	} -- 733
end) -- 733
HttpServer:post("/info", function() -- 758
	local Entry = require("Script.Dev.Entry") -- 759
	local webProfiler, drawerWidth -- 760
	do -- 760
		local _obj_0 = Entry.getConfig() -- 760
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 760
	end -- 760
	local engineDev = Entry.getEngineDev() -- 761
	Entry.connectWebIDE() -- 762
	return { -- 764
		platform = App.platform, -- 764
		locale = App.locale, -- 765
		version = App.version, -- 766
		engineDev = engineDev, -- 767
		webProfiler = webProfiler, -- 768
		drawerWidth = drawerWidth -- 769
	} -- 763
end) -- 758
local ensureLLMConfigTable -- 771
ensureLLMConfigTable = function() -- 771
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 772
	if columns and #columns > 0 then -- 773
		local expected = { -- 775
			id = true, -- 775
			name = true, -- 776
			url = true, -- 777
			model = true, -- 778
			api_key = true, -- 779
			context_window = true, -- 780
			temperature = true, -- 781
			max_tokens = true, -- 782
			reasoning_effort = true, -- 783
			custom_options = true, -- 784
			supports_function_calling = true, -- 785
			active = true, -- 786
			created_at = true, -- 787
			updated_at = true -- 788
		} -- 774
		local existing = { } -- 790
		local valid = true -- 791
		for _index_0 = 1, #columns do -- 792
			local row = columns[_index_0] -- 792
			local columnName = tostring(row[2]) -- 793
			existing[columnName] = true -- 794
			if not expected[columnName] then -- 795
				valid = false -- 796
				break -- 797
			end -- 795
		end -- 792
		if valid then -- 798
			if not existing.context_window then -- 799
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 800
			end -- 799
			if not existing.temperature then -- 801
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 802
			end -- 801
			if not existing.max_tokens then -- 803
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 804
			end -- 803
			if not existing.reasoning_effort then -- 805
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 806
			end -- 805
			if not existing.custom_options then -- 807
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 808
			end -- 807
			if not existing.supports_function_calling then -- 809
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 810
			end -- 809
		else -- 812
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 812
		end -- 798
	end -- 773
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
	]]) -- 813
end -- 771
local normalizeContextWindow -- 832
normalizeContextWindow = function(value) -- 832
	local contextWindow = tonumber(value) -- 833
	if contextWindow == nil or contextWindow < 64000 then -- 834
		return 64000 -- 835
	end -- 834
	return math.max(64000, math.floor(contextWindow)) -- 836
end -- 832
local normalizeTemperature -- 838
normalizeTemperature = function(value) -- 838
	local temperature = tonumber(value) -- 839
	if temperature == nil then -- 840
		return 0.1 -- 841
	end -- 840
	return math.max(0, math.min(2, temperature)) -- 842
end -- 838
local normalizeMaxTokens -- 844
normalizeMaxTokens = function(value) -- 844
	local maxTokens = tonumber(value) -- 845
	if maxTokens == nil or maxTokens < 1 then -- 846
		return 8192 -- 847
	end -- 846
	return math.max(1, math.floor(maxTokens)) -- 848
end -- 844
local normalizeReasoningEffort -- 850
normalizeReasoningEffort = function(value) -- 850
	if value == nil then -- 851
		return "" -- 852
	end -- 851
	local effort = tostring(value) -- 853
	return effort:match("^%s*(.-)%s*$") or "" -- 854
end -- 850
local normalizeCustomOptions -- 856
normalizeCustomOptions = function(value) -- 856
	if value == nil then -- 857
		return "" -- 858
	end -- 857
	local options = tostring(value) -- 859
	options = options:match("^%s*(.-)%s*$") or "" -- 860
	return options -- 861
end -- 856
local validateCustomOptions -- 863
validateCustomOptions = function(value) -- 863
	local options = normalizeCustomOptions(value) -- 864
	if options == "" then -- 865
		return true -- 865
	end -- 865
	if not options:match("^%s*{") then -- 866
		return false -- 866
	end -- 866
	local decoded = json.decode(options) -- 867
	return type(decoded) == "table" -- 868
end -- 863
HttpServer:post("/llm/list", function() -- 870
	ensureLLMConfigTable() -- 871
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 872
	local items -- 876
	if rows and #rows > 0 then -- 876
		local _accum_0 = { } -- 877
		local _len_0 = 1 -- 877
		for _index_0 = 1, #rows do -- 877
			local _des_0 = rows[_index_0] -- 877
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11], _des_0[12] -- 877
			_accum_0[_len_0] = { -- 878
				id = id, -- 878
				name = name, -- 878
				url = url, -- 878
				model = model, -- 878
				key = key, -- 878
				contextWindow = normalizeContextWindow(contextWindow), -- 878
				temperature = normalizeTemperature(temperature), -- 878
				maxTokens = normalizeMaxTokens(maxTokens), -- 878
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 878
				customOptions = normalizeCustomOptions(customOptions), -- 878
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 878
				active = active ~= 0 -- 878
			} -- 878
			_len_0 = _len_0 + 1 -- 878
		end -- 877
		items = _accum_0 -- 876
	end -- 876
	return { -- 879
		success = true, -- 879
		items = items -- 879
	} -- 879
end) -- 870
HttpServer:post("/llm/create", function(req) -- 881
	ensureLLMConfigTable() -- 882
	do -- 883
		local _type_0 = type(req) -- 883
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 883
		if _tab_0 then -- 883
			local body = req.body -- 883
			if body ~= nil then -- 883
				local name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 884
				local now = os.time() -- 885
				if name == nil or url == nil or model == nil or key == nil then -- 886
					return { -- 887
						success = false, -- 887
						message = "invalid" -- 887
					} -- 887
				end -- 886
				contextWindow = normalizeContextWindow(contextWindow) -- 888
				temperature = normalizeTemperature(temperature) -- 889
				maxTokens = normalizeMaxTokens(maxTokens) -- 890
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 891
				customOptions = normalizeCustomOptions(customOptions) -- 892
				if not validateCustomOptions(customOptions) then -- 893
					return { -- 893
						success = false, -- 893
						message = "customOptions must be a JSON object" -- 893
					} -- 893
				end -- 893
				if supportsFunctionCalling == false then -- 894
					supportsFunctionCalling = 0 -- 894
				else -- 894
					supportsFunctionCalling = 1 -- 894
				end -- 894
				if active then -- 895
					active = 1 -- 895
				else -- 895
					active = 0 -- 895
				end -- 895
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 902
					tostring(name), -- 902
					tostring(url), -- 903
					tostring(model), -- 904
					tostring(key), -- 905
					contextWindow, -- 906
					temperature, -- 907
					maxTokens, -- 908
					reasoningEffort, -- 909
					customOptions, -- 910
					supportsFunctionCalling, -- 911
					active, -- 912
					now, -- 913
					now -- 914
				}) -- 896
				return { -- 916
					success = affected >= 0 -- 916
				} -- 916
			end -- 883
		end -- 883
	end -- 883
	return { -- 881
		success = false, -- 881
		message = "invalid" -- 881
	} -- 881
end) -- 881
HttpServer:post("/llm/update", function(req) -- 918
	ensureLLMConfigTable() -- 919
	do -- 920
		local _type_0 = type(req) -- 920
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 920
		if _tab_0 then -- 920
			local body = req.body -- 920
			if body ~= nil then -- 920
				local id, name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 921
				local now = os.time() -- 922
				id = tonumber(id) -- 923
				if id == nil then -- 924
					return { -- 925
						success = false, -- 925
						message = "invalid" -- 925
					} -- 925
				end -- 924
				contextWindow = normalizeContextWindow(contextWindow) -- 926
				temperature = normalizeTemperature(temperature) -- 927
				maxTokens = normalizeMaxTokens(maxTokens) -- 928
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 929
				customOptions = normalizeCustomOptions(customOptions) -- 930
				if not validateCustomOptions(customOptions) then -- 931
					return { -- 931
						success = false, -- 931
						message = "customOptions must be a JSON object" -- 931
					} -- 931
				end -- 931
				if supportsFunctionCalling == false then -- 932
					supportsFunctionCalling = 0 -- 932
				else -- 932
					supportsFunctionCalling = 1 -- 932
				end -- 932
				if active then -- 933
					active = 1 -- 933
				else -- 933
					active = 0 -- 933
				end -- 933
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 938
					tostring(name), -- 938
					tostring(url), -- 939
					tostring(model), -- 940
					tostring(key), -- 941
					contextWindow, -- 942
					temperature, -- 943
					maxTokens, -- 944
					reasoningEffort, -- 945
					customOptions, -- 946
					supportsFunctionCalling, -- 947
					active, -- 948
					now, -- 949
					id -- 950
				}) -- 934
				return { -- 952
					success = affected >= 0 -- 952
				} -- 952
			end -- 920
		end -- 920
	end -- 920
	return { -- 918
		success = false, -- 918
		message = "invalid" -- 918
	} -- 918
end) -- 918
HttpServer:post("/llm/delete", function(req) -- 954
	ensureLLMConfigTable() -- 955
	do -- 956
		local _type_0 = type(req) -- 956
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 956
		if _tab_0 then -- 956
			local id -- 956
			do -- 956
				local _obj_0 = req.body -- 956
				local _type_1 = type(_obj_0) -- 956
				if "table" == _type_1 or "userdata" == _type_1 then -- 956
					id = _obj_0.id -- 956
				end -- 956
			end -- 956
			if id ~= nil then -- 956
				id = tonumber(id) -- 957
				if id == nil then -- 958
					return { -- 959
						success = false, -- 959
						message = "invalid" -- 959
					} -- 959
				end -- 958
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 960
					id -- 960
				}) -- 960
				return { -- 961
					success = affected >= 0 -- 961
				} -- 961
			end -- 956
		end -- 956
	end -- 956
	return { -- 954
		success = false, -- 954
		message = "invalid" -- 954
	} -- 954
end) -- 954
HttpServer:post("/new", function(req) -- 963
	do -- 964
		local _type_0 = type(req) -- 964
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 964
		if _tab_0 then -- 964
			local path -- 964
			do -- 964
				local _obj_0 = req.body -- 964
				local _type_1 = type(_obj_0) -- 964
				if "table" == _type_1 or "userdata" == _type_1 then -- 964
					path = _obj_0.path -- 964
				end -- 964
			end -- 964
			local content -- 964
			do -- 964
				local _obj_0 = req.body -- 964
				local _type_1 = type(_obj_0) -- 964
				if "table" == _type_1 or "userdata" == _type_1 then -- 964
					content = _obj_0.content -- 964
				end -- 964
			end -- 964
			local folder -- 964
			do -- 964
				local _obj_0 = req.body -- 964
				local _type_1 = type(_obj_0) -- 964
				if "table" == _type_1 or "userdata" == _type_1 then -- 964
					folder = _obj_0.folder -- 964
				end -- 964
			end -- 964
			if path ~= nil and content ~= nil and folder ~= nil then -- 964
				if Content:exist(path) then -- 965
					return { -- 966
						success = false, -- 966
						message = "TargetExisted" -- 966
					} -- 966
				end -- 965
				local parent = Path:getPath(path) -- 967
				local files = Content:getFiles(parent) -- 968
				if folder then -- 969
					local name = Path:getFilename(path):lower() -- 970
					for _index_0 = 1, #files do -- 971
						local file = files[_index_0] -- 971
						if name == Path:getFilename(file):lower() then -- 972
							return { -- 973
								success = false, -- 973
								message = "TargetExisted" -- 973
							} -- 973
						end -- 972
					end -- 971
					if Content:mkdir(path) then -- 974
						return { -- 975
							success = true -- 975
						} -- 975
					end -- 974
				else -- 977
					local name = Path:getName(path):lower() -- 977
					for _index_0 = 1, #files do -- 978
						local file = files[_index_0] -- 978
						if name == Path:getName(file):lower() then -- 979
							local ext = Path:getExt(file) -- 980
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 981
								goto _continue_0 -- 982
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 983
								goto _continue_0 -- 984
							end -- 981
							return { -- 985
								success = false, -- 985
								message = "SourceExisted" -- 985
							} -- 985
						end -- 979
						::_continue_0:: -- 979
					end -- 978
					if Content:save(path, content) then -- 986
						return { -- 987
							success = true -- 987
						} -- 987
					end -- 986
				end -- 969
			end -- 964
		end -- 964
	end -- 964
	return { -- 963
		success = false, -- 963
		message = "Failed" -- 963
	} -- 963
end) -- 963
HttpServer:post("/delete", function(req) -- 989
	do -- 990
		local _type_0 = type(req) -- 990
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 990
		if _tab_0 then -- 990
			local path -- 990
			do -- 990
				local _obj_0 = req.body -- 990
				local _type_1 = type(_obj_0) -- 990
				if "table" == _type_1 or "userdata" == _type_1 then -- 990
					path = _obj_0.path -- 990
				end -- 990
			end -- 990
			if path ~= nil then -- 990
				if Content:exist(path) then -- 991
					local projectRoot -- 992
					if Content:isdir(path) and isProjectRootDir(path) then -- 992
						projectRoot = path -- 992
					else -- 992
						projectRoot = nil -- 992
					end -- 992
					local parent = Path:getPath(path) -- 993
					local files = Content:getFiles(parent) -- 994
					local name = Path:getName(path):lower() -- 995
					local ext = Path:getExt(path) -- 996
					for _index_0 = 1, #files do -- 997
						local file = files[_index_0] -- 997
						if name == Path:getName(file):lower() then -- 998
							local _exp_0 = Path:getExt(file) -- 999
							if "tl" == _exp_0 then -- 999
								if ("vs" == ext) then -- 999
									Content:remove(Path(parent, file)) -- 1000
								end -- 999
							elseif "lua" == _exp_0 then -- 1001
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1001
									Content:remove(Path(parent, file)) -- 1002
								end -- 1001
							end -- 999
						end -- 998
					end -- 997
					if Content:remove(path) then -- 1003
						if projectRoot then -- 1004
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1005
						end -- 1004
						return { -- 1006
							success = true -- 1006
						} -- 1006
					end -- 1003
				end -- 991
			end -- 990
		end -- 990
	end -- 990
	return { -- 989
		success = false -- 989
	} -- 989
end) -- 989
HttpServer:post("/rename", function(req) -- 1008
	do -- 1009
		local _type_0 = type(req) -- 1009
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1009
		if _tab_0 then -- 1009
			local old -- 1009
			do -- 1009
				local _obj_0 = req.body -- 1009
				local _type_1 = type(_obj_0) -- 1009
				if "table" == _type_1 or "userdata" == _type_1 then -- 1009
					old = _obj_0.old -- 1009
				end -- 1009
			end -- 1009
			local new -- 1009
			do -- 1009
				local _obj_0 = req.body -- 1009
				local _type_1 = type(_obj_0) -- 1009
				if "table" == _type_1 or "userdata" == _type_1 then -- 1009
					new = _obj_0.new -- 1009
				end -- 1009
			end -- 1009
			if old ~= nil and new ~= nil then -- 1009
				if Content:exist(old) and not Content:exist(new) then -- 1010
					local renamedDir = Content:isdir(old) -- 1011
					local parent = Path:getPath(new) -- 1012
					local files = Content:getFiles(parent) -- 1013
					if renamedDir then -- 1014
						local name = Path:getFilename(new):lower() -- 1015
						for _index_0 = 1, #files do -- 1016
							local file = files[_index_0] -- 1016
							if name == Path:getFilename(file):lower() then -- 1017
								return { -- 1018
									success = false -- 1018
								} -- 1018
							end -- 1017
						end -- 1016
					else -- 1020
						local name = Path:getName(new):lower() -- 1020
						local ext = Path:getExt(new) -- 1021
						for _index_0 = 1, #files do -- 1022
							local file = files[_index_0] -- 1022
							if name == Path:getName(file):lower() then -- 1023
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1024
									goto _continue_0 -- 1025
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1026
									goto _continue_0 -- 1027
								end -- 1024
								return { -- 1028
									success = false -- 1028
								} -- 1028
							end -- 1023
							::_continue_0:: -- 1023
						end -- 1022
					end -- 1014
					if Content:move(old, new) then -- 1029
						if renamedDir then -- 1030
							AgentSession.renameSessionsByProjectRoot(old, new) -- 1031
						end -- 1030
						local newParent = Path:getPath(new) -- 1032
						parent = Path:getPath(old) -- 1033
						files = Content:getFiles(parent) -- 1034
						local newName = Path:getName(new) -- 1035
						local oldName = Path:getName(old) -- 1036
						local name = oldName:lower() -- 1037
						local ext = Path:getExt(old) -- 1038
						for _index_0 = 1, #files do -- 1039
							local file = files[_index_0] -- 1039
							if name == Path:getName(file):lower() then -- 1040
								local _exp_0 = Path:getExt(file) -- 1041
								if "tl" == _exp_0 then -- 1041
									if ("vs" == ext) then -- 1041
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1042
									end -- 1041
								elseif "lua" == _exp_0 then -- 1043
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1043
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1044
									end -- 1043
								end -- 1041
							end -- 1040
						end -- 1039
						return { -- 1045
							success = true -- 1045
						} -- 1045
					end -- 1029
				end -- 1010
			end -- 1009
		end -- 1009
	end -- 1009
	return { -- 1008
		success = false -- 1008
	} -- 1008
end) -- 1008
HttpServer:post("/exist", function(req) -- 1047
	do -- 1048
		local _type_0 = type(req) -- 1048
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1048
		if _tab_0 then -- 1048
			local file -- 1048
			do -- 1048
				local _obj_0 = req.body -- 1048
				local _type_1 = type(_obj_0) -- 1048
				if "table" == _type_1 or "userdata" == _type_1 then -- 1048
					file = _obj_0.file -- 1048
				end -- 1048
			end -- 1048
			if file ~= nil then -- 1048
				do -- 1049
					local projFile = req.body.projFile -- 1049
					if projFile then -- 1049
						local projDir = getProjectDirFromFile(projFile) -- 1050
						if projDir then -- 1050
							local scriptDir = Path(projDir, "Script") -- 1051
							local searchPaths = Content.searchPaths -- 1052
							if Content:exist(scriptDir) then -- 1053
								Content:addSearchPath(scriptDir) -- 1053
							end -- 1053
							if Content:exist(projDir) then -- 1054
								Content:addSearchPath(projDir) -- 1054
							end -- 1054
							local _ <close> = setmetatable({ }, { -- 1055
								__close = function() -- 1055
									Content.searchPaths = searchPaths -- 1055
								end -- 1055
							}) -- 1055
							return { -- 1056
								success = Content:exist(file) -- 1056
							} -- 1056
						end -- 1050
					end -- 1049
				end -- 1049
				return { -- 1057
					success = Content:exist(file) -- 1057
				} -- 1057
			end -- 1048
		end -- 1048
	end -- 1048
	return { -- 1047
		success = false -- 1047
	} -- 1047
end) -- 1047
HttpServer:postSchedule("/read", function(req) -- 1059
	do -- 1060
		local _type_0 = type(req) -- 1060
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1060
		if _tab_0 then -- 1060
			local path -- 1060
			do -- 1060
				local _obj_0 = req.body -- 1060
				local _type_1 = type(_obj_0) -- 1060
				if "table" == _type_1 or "userdata" == _type_1 then -- 1060
					path = _obj_0.path -- 1060
				end -- 1060
			end -- 1060
			if path ~= nil then -- 1060
				local readFile -- 1061
				readFile = function() -- 1061
					if Content:exist(path) then -- 1062
						local content = Content:loadAsync(path) -- 1063
						if content then -- 1063
							return { -- 1064
								content = content, -- 1064
								success = true, -- 1064
								fullPath = Content:getFullPath(path) -- 1064
							} -- 1064
						end -- 1063
					end -- 1062
					return nil -- 1061
				end -- 1061
				do -- 1065
					local projFile = req.body.projFile -- 1065
					if projFile then -- 1065
						local projDir = getProjectDirFromFile(projFile) -- 1066
						if projDir then -- 1066
							local scriptDir = Path(projDir, "Script") -- 1067
							local searchPaths = Content.searchPaths -- 1068
							if Content:exist(scriptDir) then -- 1069
								Content:addSearchPath(scriptDir) -- 1069
							end -- 1069
							if Content:exist(projDir) then -- 1070
								Content:addSearchPath(projDir) -- 1070
							end -- 1070
							local _ <close> = setmetatable({ }, { -- 1071
								__close = function() -- 1071
									Content.searchPaths = searchPaths -- 1071
								end -- 1071
							}) -- 1071
							local result = readFile() -- 1072
							if result then -- 1072
								return result -- 1072
							end -- 1072
						end -- 1066
					end -- 1065
				end -- 1065
				local result = readFile() -- 1073
				if result then -- 1073
					return result -- 1073
				end -- 1073
			end -- 1060
		end -- 1060
	end -- 1060
	return { -- 1059
		success = false -- 1059
	} -- 1059
end) -- 1059
HttpServer:get("/read-sync", function(req) -- 1075
	do -- 1076
		local _type_0 = type(req) -- 1076
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1076
		if _tab_0 then -- 1076
			local params = req.params -- 1076
			if params ~= nil then -- 1076
				local path = params.path -- 1077
				local exts -- 1078
				if params.exts then -- 1078
					local _accum_0 = { } -- 1079
					local _len_0 = 1 -- 1079
					for ext in params.exts:gmatch("[^|]*") do -- 1079
						_accum_0[_len_0] = ext -- 1080
						_len_0 = _len_0 + 1 -- 1080
					end -- 1079
					exts = _accum_0 -- 1078
				else -- 1081
					exts = { -- 1081
						"" -- 1081
					} -- 1081
				end -- 1078
				local readFile -- 1082
				readFile = function() -- 1082
					for _index_0 = 1, #exts do -- 1083
						local ext = exts[_index_0] -- 1083
						local targetPath = path .. ext -- 1084
						if Content:exist(targetPath) then -- 1085
							local content = Content:load(targetPath) -- 1086
							if content then -- 1086
								return { -- 1087
									content = content, -- 1087
									success = true, -- 1087
									fullPath = Content:getFullPath(targetPath) -- 1087
								} -- 1087
							end -- 1086
						end -- 1085
					end -- 1083
					return nil -- 1082
				end -- 1082
				local searchPaths = Content.searchPaths -- 1088
				local _ <close> = setmetatable({ }, { -- 1089
					__close = function() -- 1089
						Content.searchPaths = searchPaths -- 1089
					end -- 1089
				}) -- 1089
				do -- 1090
					local projFile = req.params.projFile -- 1090
					if projFile then -- 1090
						local projDir = getProjectDirFromFile(projFile) -- 1091
						if projDir then -- 1091
							local scriptDir = Path(projDir, "Script") -- 1092
							if Content:exist(scriptDir) then -- 1093
								Content:addSearchPath(scriptDir) -- 1093
							end -- 1093
							if Content:exist(projDir) then -- 1094
								Content:addSearchPath(projDir) -- 1094
							end -- 1094
						else -- 1096
							projDir = Path:getPath(projFile) -- 1096
							if Content:exist(projDir) then -- 1097
								Content:addSearchPath(projDir) -- 1097
							end -- 1097
						end -- 1091
					end -- 1090
				end -- 1090
				local result = readFile() -- 1098
				if result then -- 1098
					return result -- 1098
				end -- 1098
			end -- 1076
		end -- 1076
	end -- 1076
	return { -- 1075
		success = false -- 1075
	} -- 1075
end) -- 1075
local compileFileAsync -- 1100
compileFileAsync = function(inputFile, sourceCodes) -- 1100
	local file = inputFile -- 1101
	local searchPath -- 1102
	do -- 1102
		local dir = getProjectDirFromFile(inputFile) -- 1102
		if dir then -- 1102
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 1103
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1104
		else -- 1106
			file = Path:getRelative(inputFile, Content.writablePath) -- 1106
			if file:sub(1, 2) == ".." then -- 1107
				file = Path:getRelative(inputFile, Content.assetPath) -- 1108
			end -- 1107
			searchPath = "" -- 1109
		end -- 1102
	end -- 1102
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1110
	local yueext = yue.options.extension -- 1111
	local resultCodes = nil -- 1112
	local resultError = nil -- 1113
	do -- 1114
		local _exp_0 = Path:getExt(inputFile) -- 1114
		if yueext == _exp_0 then -- 1114
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1115
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1116
				if not codes then -- 1117
					resultError = err -- 1118
					return -- 1119
				end -- 1117
				local extraGlobal -- 1120
				if isTIC80 then -- 1120
					extraGlobal = tic80APIs -- 1120
				else -- 1120
					extraGlobal = nil -- 1120
				end -- 1120
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1121
				if not success then -- 1122
					resultError = message -- 1123
					return -- 1124
				end -- 1122
				if codes == "" then -- 1125
					resultCodes = "" -- 1126
					return nil -- 1127
				end -- 1125
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1128
				return resultCodes -- 1129
			end, function(success) -- 1116
				if not success then -- 1130
					Content:remove(outputFile) -- 1131
					if resultCodes == nil then -- 1132
						resultCodes = false -- 1133
					end -- 1132
				end -- 1130
			end) -- 1116
		elseif "tl" == _exp_0 then -- 1134
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1135
			if isTIC80 then -- 1136
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1137
			end -- 1136
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1138
			if codes then -- 1138
				if isTIC80 then -- 1139
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1140
				end -- 1139
				resultCodes = codes -- 1141
				Content:saveAsync(outputFile, codes) -- 1142
			else -- 1144
				Content:remove(outputFile) -- 1144
				resultCodes = false -- 1145
				resultError = err -- 1146
			end -- 1138
		elseif "xml" == _exp_0 then -- 1147
			local codes, err = xml.tolua(sourceCodes) -- 1148
			if codes then -- 1148
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1149
				Content:saveAsync(outputFile, resultCodes) -- 1150
			else -- 1152
				Content:remove(outputFile) -- 1152
				resultCodes = false -- 1153
				resultError = err -- 1154
			end -- 1148
		end -- 1114
	end -- 1114
	wait(function() -- 1155
		return resultCodes ~= nil -- 1155
	end) -- 1155
	if resultCodes then -- 1156
		return resultCodes -- 1157
	else -- 1159
		return nil, resultError -- 1159
	end -- 1156
	return nil -- 1100
end -- 1100
HttpServer:postSchedule("/write", function(req) -- 1161
	do -- 1162
		local _type_0 = type(req) -- 1162
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1162
		if _tab_0 then -- 1162
			local path -- 1162
			do -- 1162
				local _obj_0 = req.body -- 1162
				local _type_1 = type(_obj_0) -- 1162
				if "table" == _type_1 or "userdata" == _type_1 then -- 1162
					path = _obj_0.path -- 1162
				end -- 1162
			end -- 1162
			local content -- 1162
			do -- 1162
				local _obj_0 = req.body -- 1162
				local _type_1 = type(_obj_0) -- 1162
				if "table" == _type_1 or "userdata" == _type_1 then -- 1162
					content = _obj_0.content -- 1162
				end -- 1162
			end -- 1162
			if path ~= nil and content ~= nil then -- 1162
				if Content:saveAsync(path, content) then -- 1163
					do -- 1164
						local _exp_0 = Path:getExt(path) -- 1164
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1164
							if '' == Path:getExt(Path:getName(path)) then -- 1165
								local resultCodes = compileFileAsync(path, content) -- 1166
								return { -- 1167
									success = true, -- 1167
									resultCodes = resultCodes -- 1167
								} -- 1167
							end -- 1165
						end -- 1164
					end -- 1164
					return { -- 1168
						success = true -- 1168
					} -- 1168
				end -- 1163
			end -- 1162
		end -- 1162
	end -- 1162
	return { -- 1161
		success = false -- 1161
	} -- 1161
end) -- 1161
HttpServer:postSchedule("/build", function(req) -- 1170
	do -- 1171
		local _type_0 = type(req) -- 1171
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1171
		if _tab_0 then -- 1171
			local path -- 1171
			do -- 1171
				local _obj_0 = req.body -- 1171
				local _type_1 = type(_obj_0) -- 1171
				if "table" == _type_1 or "userdata" == _type_1 then -- 1171
					path = _obj_0.path -- 1171
				end -- 1171
			end -- 1171
			if path ~= nil then -- 1171
				local _exp_0 = Path:getExt(path) -- 1172
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1172
					if '' == Path:getExt(Path:getName(path)) then -- 1173
						local content = Content:loadAsync(path) -- 1174
						if content then -- 1174
							local resultCodes = compileFileAsync(path, content) -- 1175
							if resultCodes then -- 1175
								return { -- 1176
									success = true, -- 1176
									resultCodes = resultCodes -- 1176
								} -- 1176
							end -- 1175
						end -- 1174
					end -- 1173
				end -- 1172
			end -- 1171
		end -- 1171
	end -- 1171
	return { -- 1170
		success = false -- 1170
	} -- 1170
end) -- 1170
local extentionLevels = { -- 1179
	vs = 2, -- 1179
	bl = 2, -- 1180
	ts = 1, -- 1181
	tsx = 1, -- 1182
	tl = 1, -- 1183
	yue = 1, -- 1184
	xml = 1, -- 1185
	lua = 0 -- 1186
} -- 1178
HttpServer:post("/assets", function() -- 1188
	local Entry = require("Script.Dev.Entry") -- 1191
	local engineDev = Entry.getEngineDev() -- 1192
	local visitAssets -- 1193
	visitAssets = function(path, tag) -- 1193
		local isWorkspace = tag == "Workspace" -- 1194
		local builtin -- 1195
		if tag == "Builtin" then -- 1195
			builtin = true -- 1195
		else -- 1195
			builtin = nil -- 1195
		end -- 1195
		local children = nil -- 1196
		local dirs = Content:getDirs(path) -- 1197
		for _index_0 = 1, #dirs do -- 1198
			local dir = dirs[_index_0] -- 1198
			if isWorkspace then -- 1199
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1200
					goto _continue_0 -- 1201
				end -- 1200
			elseif dir == ".git" then -- 1202
				goto _continue_0 -- 1203
			end -- 1199
			if not children then -- 1204
				children = { } -- 1204
			end -- 1204
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1205
			::_continue_0:: -- 1199
		end -- 1198
		local files = Content:getFiles(path) -- 1206
		local names = { } -- 1207
		for _index_0 = 1, #files do -- 1208
			local file = files[_index_0] -- 1208
			if file:match("^%.") then -- 1209
				goto _continue_1 -- 1209
			end -- 1209
			local name = Path:getName(file) -- 1210
			local ext = names[name] -- 1211
			if ext then -- 1211
				local lv1 -- 1212
				do -- 1212
					local _exp_0 = extentionLevels[ext] -- 1212
					if _exp_0 ~= nil then -- 1212
						lv1 = _exp_0 -- 1212
					else -- 1212
						lv1 = -1 -- 1212
					end -- 1212
				end -- 1212
				ext = Path:getExt(file) -- 1213
				local lv2 -- 1214
				do -- 1214
					local _exp_0 = extentionLevels[ext] -- 1214
					if _exp_0 ~= nil then -- 1214
						lv2 = _exp_0 -- 1214
					else -- 1214
						lv2 = -1 -- 1214
					end -- 1214
				end -- 1214
				if lv2 > lv1 then -- 1215
					names[name] = ext -- 1216
				elseif lv2 == lv1 then -- 1217
					names[name .. '.' .. ext] = "" -- 1218
				end -- 1215
			else -- 1220
				ext = Path:getExt(file) -- 1220
				if not extentionLevels[ext] then -- 1221
					names[file] = "" -- 1222
				else -- 1224
					names[name] = ext -- 1224
				end -- 1221
			end -- 1211
			::_continue_1:: -- 1209
		end -- 1208
		do -- 1225
			local _accum_0 = { } -- 1225
			local _len_0 = 1 -- 1225
			for name, ext in pairs(names) do -- 1225
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1225
				_len_0 = _len_0 + 1 -- 1225
			end -- 1225
			files = _accum_0 -- 1225
		end -- 1225
		for _index_0 = 1, #files do -- 1226
			local file = files[_index_0] -- 1226
			if not children then -- 1227
				children = { } -- 1227
			end -- 1227
			children[#children + 1] = { -- 1229
				key = Path(path, file), -- 1229
				dir = false, -- 1230
				title = file, -- 1231
				builtin = builtin -- 1232
			} -- 1228
		end -- 1226
		if children then -- 1234
			table.sort(children, function(a, b) -- 1235
				if a.dir == b.dir then -- 1236
					return a.title < b.title -- 1237
				else -- 1239
					return a.dir -- 1239
				end -- 1236
			end) -- 1235
		end -- 1234
		if isWorkspace and children then -- 1240
			return children -- 1241
		else -- 1243
			return { -- 1244
				key = path, -- 1244
				dir = true, -- 1245
				title = Path:getFilename(path), -- 1246
				builtin = builtin, -- 1247
				children = children -- 1248
			} -- 1243
		end -- 1240
	end -- 1193
	local zh = (App.locale:match("^zh") ~= nil) -- 1250
	return { -- 1252
		key = Content.writablePath, -- 1252
		dir = true, -- 1253
		root = true, -- 1254
		title = "Assets", -- 1255
		children = (function() -- 1257
			local _tab_0 = { -- 1257
				{ -- 1258
					key = Path(Content.assetPath), -- 1258
					dir = true, -- 1259
					builtin = true, -- 1260
					title = zh and "内置资源" or "Built-in", -- 1261
					children = { -- 1263
						(function() -- 1263
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1263
							_with_0.title = zh and "说明文档" or "Readme" -- 1264
							return _with_0 -- 1263
						end)(), -- 1263
						(function() -- 1265
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1265
							_with_0.title = zh and "接口文档" or "API Doc" -- 1266
							return _with_0 -- 1265
						end)(), -- 1265
						(function() -- 1267
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1267
							_with_0.title = zh and "开发工具" or "Tools" -- 1268
							return _with_0 -- 1267
						end)(), -- 1267
						(function() -- 1269
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1269
							_with_0.title = zh and "字体" or "Font" -- 1270
							return _with_0 -- 1269
						end)(), -- 1269
						(function() -- 1271
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1271
							_with_0.title = zh and "程序库" or "Lib" -- 1272
							if engineDev then -- 1273
								local _list_0 = _with_0.children -- 1274
								for _index_0 = 1, #_list_0 do -- 1274
									local child = _list_0[_index_0] -- 1274
									if not (child.title == "Dora") then -- 1275
										goto _continue_0 -- 1275
									end -- 1275
									local title = zh and "zh-Hans" or "en" -- 1276
									do -- 1277
										local _accum_0 = { } -- 1277
										local _len_0 = 1 -- 1277
										local _list_1 = child.children -- 1277
										for _index_1 = 1, #_list_1 do -- 1277
											local c = _list_1[_index_1] -- 1277
											if c.title ~= title then -- 1277
												_accum_0[_len_0] = c -- 1277
												_len_0 = _len_0 + 1 -- 1277
											end -- 1277
										end -- 1277
										child.children = _accum_0 -- 1277
									end -- 1277
									break -- 1278
									::_continue_0:: -- 1275
								end -- 1274
							else -- 1280
								local _accum_0 = { } -- 1280
								local _len_0 = 1 -- 1280
								local _list_0 = _with_0.children -- 1280
								for _index_0 = 1, #_list_0 do -- 1280
									local child = _list_0[_index_0] -- 1280
									if child.title ~= "Dora" then -- 1280
										_accum_0[_len_0] = child -- 1280
										_len_0 = _len_0 + 1 -- 1280
									end -- 1280
								end -- 1280
								_with_0.children = _accum_0 -- 1280
							end -- 1273
							return _with_0 -- 1271
						end)(), -- 1271
						(function() -- 1281
							if engineDev then -- 1281
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1282
								local _obj_0 = _with_0.children -- 1283
								_obj_0[#_obj_0 + 1] = { -- 1284
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1284
									dir = false, -- 1285
									builtin = true, -- 1286
									title = "init.yue" -- 1287
								} -- 1283
								return _with_0 -- 1282
							end -- 1281
						end)() -- 1281
					} -- 1262
				} -- 1257
			} -- 1291
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1291
			local _idx_0 = #_tab_0 + 1 -- 1291
			for _index_0 = 1, #_obj_0 do -- 1291
				local _value_0 = _obj_0[_index_0] -- 1291
				_tab_0[_idx_0] = _value_0 -- 1291
				_idx_0 = _idx_0 + 1 -- 1291
			end -- 1291
			return _tab_0 -- 1257
		end)() -- 1256
	} -- 1251
end) -- 1188
HttpServer:post("/entry/list", function() -- 1295
	local Entry = require("Script.Dev.Entry") -- 1296
	local res = Entry.getLaunchEntries() -- 1297
	res.success = true -- 1298
	return res -- 1299
end) -- 1295
HttpServer:post("/run/status", function() -- 1301
	local Entry = require("Script.Dev.Entry") -- 1302
	return Entry.getCurrentEntryStatus() -- 1303
end) -- 1301
HttpServer:postSchedule("/run", function(req) -- 1305
	do -- 1306
		local _type_0 = type(req) -- 1306
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1306
		if _tab_0 then -- 1306
			local file -- 1306
			do -- 1306
				local _obj_0 = req.body -- 1306
				local _type_1 = type(_obj_0) -- 1306
				if "table" == _type_1 or "userdata" == _type_1 then -- 1306
					file = _obj_0.file -- 1306
				end -- 1306
			end -- 1306
			local asProj -- 1306
			do -- 1306
				local _obj_0 = req.body -- 1306
				local _type_1 = type(_obj_0) -- 1306
				if "table" == _type_1 or "userdata" == _type_1 then -- 1306
					asProj = _obj_0.asProj -- 1306
				end -- 1306
			end -- 1306
			if file ~= nil and asProj ~= nil then -- 1306
				if not Content:isAbsolutePath(file) then -- 1307
					local devFile = Path(Content.writablePath, file) -- 1308
					if Content:exist(devFile) then -- 1309
						file = devFile -- 1309
					end -- 1309
				end -- 1307
				local Entry = require("Script.Dev.Entry") -- 1310
				local workDir -- 1311
				if asProj then -- 1312
					workDir = getProjectDirFromFile(file) -- 1313
					if workDir then -- 1313
						Entry.allClear() -- 1314
						local target = Path(workDir, "init") -- 1315
						local success, err = Entry.enterEntryAsync({ -- 1316
							entryName = "Project", -- 1316
							fileName = target, -- 1316
							workDir = workDir, -- 1316
							projectRoot = workDir, -- 1316
							runKind = "project" -- 1316
						}) -- 1316
						target = Path:getName(Path:getPath(target)) -- 1317
						return { -- 1318
							success = success, -- 1318
							target = target, -- 1318
							err = err -- 1318
						} -- 1318
					end -- 1313
				else -- 1320
					workDir = getProjectDirFromFile(file) -- 1320
				end -- 1312
				Entry.allClear() -- 1321
				file = Path:replaceExt(file, "") -- 1322
				local entry = { -- 1324
					entryName = Path:getName(file), -- 1324
					fileName = file, -- 1325
					runKind = "file" -- 1326
				} -- 1323
				if workDir then -- 1327
					entry.workDir = workDir -- 1328
					entry.projectRoot = workDir -- 1329
				end -- 1327
				local success, err = Entry.enterEntryAsync(entry) -- 1330
				return { -- 1331
					success = success, -- 1331
					err = err -- 1331
				} -- 1331
			end -- 1306
		end -- 1306
	end -- 1306
	return { -- 1305
		success = false -- 1305
	} -- 1305
end) -- 1305
HttpServer:postSchedule("/stop", function() -- 1333
	local Entry = require("Script.Dev.Entry") -- 1334
	return { -- 1335
		success = Entry.stop() -- 1335
	} -- 1335
end) -- 1333
local minifyAsync -- 1337
minifyAsync = function(sourcePath, minifyPath) -- 1337
	if not Content:exist(sourcePath) then -- 1338
		return -- 1338
	end -- 1338
	local Entry = require("Script.Dev.Entry") -- 1339
	local errors = { } -- 1340
	local files = Entry.getAllFiles(sourcePath, { -- 1341
		"lua" -- 1341
	}, true) -- 1341
	do -- 1342
		local _accum_0 = { } -- 1342
		local _len_0 = 1 -- 1342
		for _index_0 = 1, #files do -- 1342
			local file = files[_index_0] -- 1342
			if file:sub(1, 1) ~= '.' then -- 1342
				_accum_0[_len_0] = file -- 1342
				_len_0 = _len_0 + 1 -- 1342
			end -- 1342
		end -- 1342
		files = _accum_0 -- 1342
	end -- 1342
	local paths -- 1343
	do -- 1343
		local _tbl_0 = { } -- 1343
		for _index_0 = 1, #files do -- 1343
			local file = files[_index_0] -- 1343
			_tbl_0[Path:getPath(file)] = true -- 1343
		end -- 1343
		paths = _tbl_0 -- 1343
	end -- 1343
	for path in pairs(paths) do -- 1344
		Content:mkdir(Path(minifyPath, path)) -- 1344
	end -- 1344
	local _ <close> = setmetatable({ }, { -- 1345
		__close = function() -- 1345
			package.loaded["luaminify.FormatMini"] = nil -- 1346
			package.loaded["luaminify.ParseLua"] = nil -- 1347
			package.loaded["luaminify.Scope"] = nil -- 1348
			package.loaded["luaminify.Util"] = nil -- 1349
		end -- 1345
	}) -- 1345
	local FormatMini -- 1350
	do -- 1350
		local _obj_0 = require("luaminify") -- 1350
		FormatMini = _obj_0.FormatMini -- 1350
	end -- 1350
	local fileCount = #files -- 1351
	local count = 0 -- 1352
	for _index_0 = 1, #files do -- 1353
		local file = files[_index_0] -- 1353
		thread(function() -- 1354
			local _ <close> = setmetatable({ }, { -- 1355
				__close = function() -- 1355
					count = count + 1 -- 1355
				end -- 1355
			}) -- 1355
			local input = Path(sourcePath, file) -- 1356
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1357
			if Content:exist(input) then -- 1358
				local sourceCodes = Content:loadAsync(input) -- 1359
				local res, err = FormatMini(sourceCodes) -- 1360
				if res then -- 1361
					Content:saveAsync(output, res) -- 1362
					return print("Minify " .. tostring(file)) -- 1363
				else -- 1365
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1365
				end -- 1361
			else -- 1367
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1367
			end -- 1358
		end) -- 1354
		sleep() -- 1368
	end -- 1353
	wait(function() -- 1369
		return count == fileCount -- 1369
	end) -- 1369
	if #errors > 0 then -- 1370
		print(table.concat(errors, '\n')) -- 1371
	end -- 1370
	print("Obfuscation done.") -- 1372
	return files -- 1373
end -- 1337
local zipping = false -- 1375
HttpServer:postSchedule("/zip", function(req) -- 1377
	do -- 1378
		local _type_0 = type(req) -- 1378
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1378
		if _tab_0 then -- 1378
			local path -- 1378
			do -- 1378
				local _obj_0 = req.body -- 1378
				local _type_1 = type(_obj_0) -- 1378
				if "table" == _type_1 or "userdata" == _type_1 then -- 1378
					path = _obj_0.path -- 1378
				end -- 1378
			end -- 1378
			local zipFile -- 1378
			do -- 1378
				local _obj_0 = req.body -- 1378
				local _type_1 = type(_obj_0) -- 1378
				if "table" == _type_1 or "userdata" == _type_1 then -- 1378
					zipFile = _obj_0.zipFile -- 1378
				end -- 1378
			end -- 1378
			local obfuscated -- 1378
			do -- 1378
				local _obj_0 = req.body -- 1378
				local _type_1 = type(_obj_0) -- 1378
				if "table" == _type_1 or "userdata" == _type_1 then -- 1378
					obfuscated = _obj_0.obfuscated -- 1378
				end -- 1378
			end -- 1378
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1378
				if zipping then -- 1379
					goto failed -- 1379
				end -- 1379
				zipping = true -- 1380
				local _ <close> = setmetatable({ }, { -- 1381
					__close = function() -- 1381
						zipping = false -- 1381
					end -- 1381
				}) -- 1381
				if not Content:exist(path) then -- 1382
					goto failed -- 1382
				end -- 1382
				Content:mkdir(Path:getPath(zipFile)) -- 1383
				if obfuscated then -- 1384
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1385
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1386
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1387
					Content:remove(scriptPath) -- 1388
					Content:remove(obfuscatedPath) -- 1389
					Content:remove(tempPath) -- 1390
					Content:mkdir(scriptPath) -- 1391
					Content:mkdir(obfuscatedPath) -- 1392
					Content:mkdir(tempPath) -- 1393
					if not Content:copyAsync(path, tempPath) then -- 1394
						goto failed -- 1394
					end -- 1394
					local Entry = require("Script.Dev.Entry") -- 1395
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1396
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1397
						"tl", -- 1397
						"yue", -- 1397
						"lua", -- 1397
						"ts", -- 1397
						"tsx", -- 1397
						"vs", -- 1397
						"bl", -- 1397
						"xml", -- 1397
						"wa", -- 1397
						"mod" -- 1397
					}, true) -- 1397
					for _index_0 = 1, #scriptFiles do -- 1398
						local file = scriptFiles[_index_0] -- 1398
						Content:remove(Path(tempPath, file)) -- 1399
					end -- 1398
					for _index_0 = 1, #luaFiles do -- 1400
						local file = luaFiles[_index_0] -- 1400
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1401
					end -- 1400
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1402
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1403
					end) then -- 1402
						goto failed -- 1402
					end -- 1402
					return { -- 1404
						success = true -- 1404
					} -- 1404
				else -- 1406
					return { -- 1406
						success = Content:zipAsync(path, zipFile, function(file) -- 1406
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1407
						end) -- 1406
					} -- 1406
				end -- 1384
			end -- 1378
		end -- 1378
	end -- 1378
	::failed:: -- 1408
	return { -- 1377
		success = false -- 1377
	} -- 1377
end) -- 1377
HttpServer:postSchedule("/unzip", function(req) -- 1410
	do -- 1411
		local _type_0 = type(req) -- 1411
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1411
		if _tab_0 then -- 1411
			local zipFile -- 1411
			do -- 1411
				local _obj_0 = req.body -- 1411
				local _type_1 = type(_obj_0) -- 1411
				if "table" == _type_1 or "userdata" == _type_1 then -- 1411
					zipFile = _obj_0.zipFile -- 1411
				end -- 1411
			end -- 1411
			local path -- 1411
			do -- 1411
				local _obj_0 = req.body -- 1411
				local _type_1 = type(_obj_0) -- 1411
				if "table" == _type_1 or "userdata" == _type_1 then -- 1411
					path = _obj_0.path -- 1411
				end -- 1411
			end -- 1411
			if zipFile ~= nil and path ~= nil then -- 1411
				return { -- 1412
					success = Content:unzipAsync(zipFile, path, function(file) -- 1412
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1413
					end) -- 1412
				} -- 1412
			end -- 1411
		end -- 1411
	end -- 1411
	return { -- 1410
		success = false -- 1410
	} -- 1410
end) -- 1410
HttpServer:post("/editing-info", function(req) -- 1415
	local Entry = require("Script.Dev.Entry") -- 1416
	local config = Entry.getConfig() -- 1417
	local _type_0 = type(req) -- 1418
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1418
	local _match_0 = false -- 1418
	if _tab_0 then -- 1418
		local editingInfo -- 1418
		do -- 1418
			local _obj_0 = req.body -- 1418
			local _type_1 = type(_obj_0) -- 1418
			if "table" == _type_1 or "userdata" == _type_1 then -- 1418
				editingInfo = _obj_0.editingInfo -- 1418
			end -- 1418
		end -- 1418
		if editingInfo ~= nil then -- 1418
			_match_0 = true -- 1418
			config.editingInfo = editingInfo -- 1419
			return { -- 1420
				success = true -- 1420
			} -- 1420
		end -- 1418
	end -- 1418
	if not _match_0 then -- 1418
		if not (config.editingInfo ~= nil) then -- 1422
			local folder -- 1423
			if App.locale:match('^zh') then -- 1423
				folder = 'zh-Hans' -- 1423
			else -- 1423
				folder = 'en' -- 1423
			end -- 1423
			config.editingInfo = json.encode({ -- 1425
				index = 0, -- 1425
				files = { -- 1427
					{ -- 1428
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1428
						title = "welcome.md" -- 1429
					} -- 1427
				} -- 1426
			}) -- 1424
		end -- 1422
		return { -- 1433
			success = true, -- 1433
			editingInfo = config.editingInfo -- 1433
		} -- 1433
	end -- 1418
end) -- 1415
HttpServer:post("/command", function(req) -- 1435
	do -- 1436
		local _type_0 = type(req) -- 1436
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1436
		if _tab_0 then -- 1436
			local code -- 1436
			do -- 1436
				local _obj_0 = req.body -- 1436
				local _type_1 = type(_obj_0) -- 1436
				if "table" == _type_1 or "userdata" == _type_1 then -- 1436
					code = _obj_0.code -- 1436
				end -- 1436
			end -- 1436
			local log -- 1436
			do -- 1436
				local _obj_0 = req.body -- 1436
				local _type_1 = type(_obj_0) -- 1436
				if "table" == _type_1 or "userdata" == _type_1 then -- 1436
					log = _obj_0.log -- 1436
				end -- 1436
			end -- 1436
			if code ~= nil and log ~= nil then -- 1436
				emit("AppCommand", code, log) -- 1437
				return { -- 1438
					success = true -- 1438
				} -- 1438
			end -- 1436
		end -- 1436
	end -- 1436
	return { -- 1435
		success = false -- 1435
	} -- 1435
end) -- 1435
HttpServer:post("/log/save", function() -- 1440
	local folder = ".download" -- 1441
	local fullLogFile = "dora_full_logs.txt" -- 1442
	local fullFolder = Path(Content.writablePath, folder) -- 1443
	Content:mkdir(fullFolder) -- 1444
	local logPath = Path(fullFolder, fullLogFile) -- 1445
	if App:saveLog(logPath) then -- 1446
		return { -- 1447
			success = true, -- 1447
			path = Path(folder, fullLogFile) -- 1447
		} -- 1447
	end -- 1446
	return { -- 1440
		success = false -- 1440
	} -- 1440
end) -- 1440
HttpServer:post("/yarn/check", function(req) -- 1449
	local yarncompile = require("yarncompile") -- 1450
	do -- 1451
		local _type_0 = type(req) -- 1451
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1451
		if _tab_0 then -- 1451
			local code -- 1451
			do -- 1451
				local _obj_0 = req.body -- 1451
				local _type_1 = type(_obj_0) -- 1451
				if "table" == _type_1 or "userdata" == _type_1 then -- 1451
					code = _obj_0.code -- 1451
				end -- 1451
			end -- 1451
			if code ~= nil then -- 1451
				local jsonObject = json.decode(code) -- 1452
				if jsonObject then -- 1452
					local errors = { } -- 1453
					local _list_0 = jsonObject.nodes -- 1454
					for _index_0 = 1, #_list_0 do -- 1454
						local node = _list_0[_index_0] -- 1454
						local title, body = node.title, node.body -- 1455
						local luaCode, err = yarncompile(body) -- 1456
						if not luaCode then -- 1456
							errors[#errors + 1] = title .. ":" .. err -- 1457
						end -- 1456
					end -- 1454
					return { -- 1458
						success = true, -- 1458
						syntaxError = table.concat(errors, "\n\n") -- 1458
					} -- 1458
				end -- 1452
			end -- 1451
		end -- 1451
	end -- 1451
	return { -- 1449
		success = false -- 1449
	} -- 1449
end) -- 1449
HttpServer:post("/yarn/check-file", function(req) -- 1460
	local yarncompile = require("yarncompile") -- 1461
	do -- 1462
		local _type_0 = type(req) -- 1462
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1462
		if _tab_0 then -- 1462
			local code -- 1462
			do -- 1462
				local _obj_0 = req.body -- 1462
				local _type_1 = type(_obj_0) -- 1462
				if "table" == _type_1 or "userdata" == _type_1 then -- 1462
					code = _obj_0.code -- 1462
				end -- 1462
			end -- 1462
			if code ~= nil then -- 1462
				local res, _, err = yarncompile(code, true) -- 1463
				if not res then -- 1463
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1464
					return { -- 1465
						success = false, -- 1465
						message = message, -- 1465
						line = line, -- 1465
						column = column, -- 1465
						node = node -- 1465
					} -- 1465
				end -- 1463
			end -- 1462
		end -- 1462
	end -- 1462
	return { -- 1460
		success = true -- 1460
	} -- 1460
end) -- 1460
local getWaProjectDirFromFile -- 1467
getWaProjectDirFromFile = function(file) -- 1467
	local writablePath = Content.writablePath -- 1468
	local parent, current -- 1469
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1469
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1470
	else -- 1472
		parent, current = nil, nil -- 1472
	end -- 1469
	if not current then -- 1473
		return nil -- 1473
	end -- 1473
	repeat -- 1474
		current = Path:getPath(current) -- 1475
		if current == "" then -- 1476
			break -- 1476
		end -- 1476
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1477
		for _index_0 = 1, #_list_0 do -- 1477
			local f = _list_0[_index_0] -- 1477
			if Path:getFilename(f):lower() == "wa.mod" then -- 1478
				return Path(parent, current, Path:getPath(f)) -- 1479
			end -- 1478
		end -- 1477
	until false -- 1474
	return nil -- 1481
end -- 1467
HttpServer:postSchedule("/wa/update_dora", function(req) -- 1483
	do -- 1484
		local _type_0 = type(req) -- 1484
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1484
		if _tab_0 then -- 1484
			local path -- 1484
			do -- 1484
				local _obj_0 = req.body -- 1484
				local _type_1 = type(_obj_0) -- 1484
				if "table" == _type_1 or "userdata" == _type_1 then -- 1484
					path = _obj_0.path -- 1484
				end -- 1484
			end -- 1484
			if path ~= nil then -- 1484
				local projDir = getWaProjectDirFromFile(path) -- 1485
				if projDir then -- 1485
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 1486
					if not Content:exist(sourceDoraPath) then -- 1487
						return { -- 1488
							success = false, -- 1488
							message = "missing dora template" -- 1488
						} -- 1488
					end -- 1487
					local targetVendorPath = Path(projDir, "vendor") -- 1489
					local targetDoraPath = Path(targetVendorPath, "dora") -- 1490
					if not Content:exist(targetVendorPath) then -- 1491
						if not Content:mkdir(targetVendorPath) then -- 1492
							return { -- 1493
								success = false, -- 1493
								message = "failed to create vendor folder" -- 1493
							} -- 1493
						end -- 1492
					elseif not Content:isdir(targetVendorPath) then -- 1494
						return { -- 1495
							success = false, -- 1495
							message = "vendor path is not a folder" -- 1495
						} -- 1495
					end -- 1491
					if Content:exist(targetDoraPath) then -- 1496
						if not Content:remove(targetDoraPath) then -- 1497
							return { -- 1498
								success = false, -- 1498
								message = "failed to remove old dora" -- 1498
							} -- 1498
						end -- 1497
					end -- 1496
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 1499
						return { -- 1500
							success = false, -- 1500
							message = "failed to copy dora" -- 1500
						} -- 1500
					end -- 1499
					return { -- 1501
						success = true -- 1501
					} -- 1501
				else -- 1503
					return { -- 1503
						success = false, -- 1503
						message = 'Wa file needs a project' -- 1503
					} -- 1503
				end -- 1485
			end -- 1484
		end -- 1484
	end -- 1484
	return { -- 1483
		success = false, -- 1483
		message = "invalid call" -- 1483
	} -- 1483
end) -- 1483
HttpServer:postSchedule("/wa/build", function(req) -- 1505
	do -- 1506
		local _type_0 = type(req) -- 1506
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1506
		if _tab_0 then -- 1506
			local path -- 1506
			do -- 1506
				local _obj_0 = req.body -- 1506
				local _type_1 = type(_obj_0) -- 1506
				if "table" == _type_1 or "userdata" == _type_1 then -- 1506
					path = _obj_0.path -- 1506
				end -- 1506
			end -- 1506
			if path ~= nil then -- 1506
				local projDir = getWaProjectDirFromFile(path) -- 1507
				if projDir then -- 1507
					local message = Wasm:buildWaAsync(projDir) -- 1508
					if message == "" then -- 1509
						return { -- 1510
							success = true -- 1510
						} -- 1510
					else -- 1512
						return { -- 1512
							success = false, -- 1512
							message = message -- 1512
						} -- 1512
					end -- 1509
				else -- 1514
					return { -- 1514
						success = false, -- 1514
						message = 'Wa file needs a project' -- 1514
					} -- 1514
				end -- 1507
			end -- 1506
		end -- 1506
	end -- 1506
	return { -- 1515
		success = false, -- 1515
		message = 'failed to build' -- 1515
	} -- 1515
end) -- 1505
HttpServer:postSchedule("/wa/format", function(req) -- 1517
	do -- 1518
		local _type_0 = type(req) -- 1518
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1518
		if _tab_0 then -- 1518
			local file -- 1518
			do -- 1518
				local _obj_0 = req.body -- 1518
				local _type_1 = type(_obj_0) -- 1518
				if "table" == _type_1 or "userdata" == _type_1 then -- 1518
					file = _obj_0.file -- 1518
				end -- 1518
			end -- 1518
			if file ~= nil then -- 1518
				local code = Wasm:formatWaAsync(file) -- 1519
				if code == "" then -- 1520
					return { -- 1521
						success = false -- 1521
					} -- 1521
				else -- 1523
					return { -- 1523
						success = true, -- 1523
						code = code -- 1523
					} -- 1523
				end -- 1520
			end -- 1518
		end -- 1518
	end -- 1518
	return { -- 1524
		success = false -- 1524
	} -- 1524
end) -- 1517
HttpServer:postSchedule("/wa/create", function(req) -- 1526
	do -- 1527
		local _type_0 = type(req) -- 1527
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1527
		if _tab_0 then -- 1527
			local path -- 1527
			do -- 1527
				local _obj_0 = req.body -- 1527
				local _type_1 = type(_obj_0) -- 1527
				if "table" == _type_1 or "userdata" == _type_1 then -- 1527
					path = _obj_0.path -- 1527
				end -- 1527
			end -- 1527
			if path ~= nil then -- 1527
				if not Content:exist(Path:getPath(path)) then -- 1528
					return { -- 1529
						success = false, -- 1529
						message = "target path not existed" -- 1529
					} -- 1529
				end -- 1528
				if Content:exist(path) then -- 1530
					return { -- 1531
						success = false, -- 1531
						message = "target project folder existed" -- 1531
					} -- 1531
				end -- 1530
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1532
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1533
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1534
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1535
					return { -- 1538
						success = false, -- 1538
						message = "missing template project" -- 1538
					} -- 1538
				end -- 1535
				if not Content:mkdir(path) then -- 1539
					return { -- 1540
						success = false, -- 1540
						message = "failed to create project folder" -- 1540
					} -- 1540
				end -- 1539
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1541
					Content:remove(path) -- 1542
					return { -- 1543
						success = false, -- 1543
						message = "failed to copy template" -- 1543
					} -- 1543
				end -- 1541
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1544
					Content:remove(path) -- 1545
					return { -- 1546
						success = false, -- 1546
						message = "failed to copy template" -- 1546
					} -- 1546
				end -- 1544
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1547
					Content:remove(path) -- 1548
					return { -- 1549
						success = false, -- 1549
						message = "failed to copy template" -- 1549
					} -- 1549
				end -- 1547
				return { -- 1550
					success = true -- 1550
				} -- 1550
			end -- 1527
		end -- 1527
	end -- 1527
	return { -- 1526
		success = false, -- 1526
		message = "invalid call" -- 1526
	} -- 1526
end) -- 1526
local tsBuildGlobs = { -- 1553
	"**/*.ts", -- 1553
	"**/*.tsx", -- 1554
	"!**/.*/**", -- 1555
	"!**/node_modules/**" -- 1556
} -- 1552
local _anon_func_5 = function(path) -- 1565
	local _val_0 = Path:getExt(path) -- 1565
	return "ts" == _val_0 or "tsx" == _val_0 -- 1565
end -- 1565
HttpServer:postSchedule("/ts/build", function(req) -- 1558
	do -- 1559
		local _type_0 = type(req) -- 1559
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1559
		if _tab_0 then -- 1559
			local path -- 1559
			do -- 1559
				local _obj_0 = req.body -- 1559
				local _type_1 = type(_obj_0) -- 1559
				if "table" == _type_1 or "userdata" == _type_1 then -- 1559
					path = _obj_0.path -- 1559
				end -- 1559
			end -- 1559
			if path ~= nil then -- 1559
				if HttpServer.wsConnectionCount == 0 then -- 1560
					return { -- 1561
						success = false, -- 1561
						message = "Web IDE not connected" -- 1561
					} -- 1561
				end -- 1560
				if not Content:exist(path) then -- 1562
					return { -- 1563
						success = false, -- 1563
						message = "path not existed" -- 1563
					} -- 1563
				end -- 1562
				if not Content:isdir(path) then -- 1564
					if not (_anon_func_5(path)) then -- 1565
						return { -- 1566
							success = false, -- 1566
							message = "expecting a TypeScript file" -- 1566
						} -- 1566
					end -- 1565
					local messages = { } -- 1567
					local content = Content:load(path) -- 1568
					if not content then -- 1569
						return { -- 1570
							success = false, -- 1570
							message = "failed to read file" -- 1570
						} -- 1570
					end -- 1569
					emit("AppWS", "Send", json.encode({ -- 1571
						name = "UpdateFile", -- 1571
						file = path, -- 1571
						exists = true, -- 1571
						content = content -- 1571
					})) -- 1571
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1572
						local done = false -- 1573
						do -- 1574
							local _with_0 = Node() -- 1574
							_with_0:gslot("AppWS", function(event) -- 1575
								if event.type == "Receive" then -- 1576
									local res = json.decode(event.msg) -- 1577
									if res then -- 1577
										if res.name == "TranspileTS" and res.file == path then -- 1578
											_with_0:removeFromParent() -- 1579
											if res.success then -- 1580
												local luaFile = Path:replaceExt(path, "lua") -- 1581
												Content:save(luaFile, res.luaCode) -- 1582
												messages[#messages + 1] = { -- 1583
													success = true, -- 1583
													file = path -- 1583
												} -- 1583
											else -- 1585
												messages[#messages + 1] = { -- 1585
													success = false, -- 1585
													file = path, -- 1585
													message = res.message -- 1585
												} -- 1585
											end -- 1580
											done = true -- 1586
										end -- 1578
									end -- 1577
								end -- 1576
							end) -- 1575
						end -- 1574
						emit("AppWS", "Send", json.encode({ -- 1587
							name = "TranspileTS", -- 1587
							file = path, -- 1587
							content = content -- 1587
						})) -- 1587
						wait(function() -- 1588
							return done -- 1588
						end) -- 1588
					end -- 1572
					return { -- 1589
						success = true, -- 1589
						messages = messages -- 1589
					} -- 1589
				else -- 1591
					local fileData = { } -- 1591
					local messages = { } -- 1592
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 1593
					for _index_0 = 1, #_list_0 do -- 1593
						local subFile = _list_0[_index_0] -- 1593
						local file = Path(path, subFile) -- 1594
						local content = Content:load(file) -- 1595
						if content then -- 1595
							fileData[file] = content -- 1596
							emit("AppWS", "Send", json.encode({ -- 1597
								name = "UpdateFile", -- 1597
								file = file, -- 1597
								exists = true, -- 1597
								content = content -- 1597
							})) -- 1597
						else -- 1599
							messages[#messages + 1] = { -- 1599
								success = false, -- 1599
								file = file, -- 1599
								message = "failed to read file" -- 1599
							} -- 1599
						end -- 1595
					end -- 1593
					for file, content in pairs(fileData) do -- 1600
						if "d" == Path:getExt(Path:getName(file)) then -- 1601
							goto _continue_0 -- 1601
						end -- 1601
						local done = false -- 1602
						do -- 1603
							local _with_0 = Node() -- 1603
							_with_0:gslot("AppWS", function(event) -- 1604
								if event.type == "Receive" then -- 1605
									local res = json.decode(event.msg) -- 1606
									if res then -- 1606
										if res.name == "TranspileTS" and res.file == file then -- 1607
											_with_0:removeFromParent() -- 1608
											if res.success then -- 1609
												local luaFile = Path:replaceExt(file, "lua") -- 1610
												Content:save(luaFile, res.luaCode) -- 1611
												messages[#messages + 1] = { -- 1612
													success = true, -- 1612
													file = file -- 1612
												} -- 1612
											else -- 1614
												messages[#messages + 1] = { -- 1614
													success = false, -- 1614
													file = file, -- 1614
													message = res.message -- 1614
												} -- 1614
											end -- 1609
											done = true -- 1615
										end -- 1607
									end -- 1606
								end -- 1605
							end) -- 1604
						end -- 1603
						emit("AppWS", "Send", json.encode({ -- 1616
							name = "TranspileTS", -- 1616
							file = file, -- 1616
							content = content -- 1616
						})) -- 1616
						wait(function() -- 1617
							return done -- 1617
						end) -- 1617
						::_continue_0:: -- 1601
					end -- 1600
					return { -- 1618
						success = true, -- 1618
						messages = messages -- 1618
					} -- 1618
				end -- 1564
			end -- 1559
		end -- 1559
	end -- 1559
	return { -- 1558
		success = false -- 1558
	} -- 1558
end) -- 1558
HttpServer:post("/download", function(req) -- 1620
	do -- 1621
		local _type_0 = type(req) -- 1621
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1621
		if _tab_0 then -- 1621
			local url -- 1621
			do -- 1621
				local _obj_0 = req.body -- 1621
				local _type_1 = type(_obj_0) -- 1621
				if "table" == _type_1 or "userdata" == _type_1 then -- 1621
					url = _obj_0.url -- 1621
				end -- 1621
			end -- 1621
			local target -- 1621
			do -- 1621
				local _obj_0 = req.body -- 1621
				local _type_1 = type(_obj_0) -- 1621
				if "table" == _type_1 or "userdata" == _type_1 then -- 1621
					target = _obj_0.target -- 1621
				end -- 1621
			end -- 1621
			if url ~= nil and target ~= nil then -- 1621
				local Entry = require("Script.Dev.Entry") -- 1622
				Entry.downloadFile(url, target) -- 1623
				return { -- 1624
					success = true -- 1624
				} -- 1624
			end -- 1621
		end -- 1621
	end -- 1621
	return { -- 1620
		success = false -- 1620
	} -- 1620
end) -- 1620
local status = { } -- 1626
_module_0 = status -- 1627
status.buildAsync = function(path) -- 1629
	if not Content:exist(path) then -- 1630
		return { -- 1631
			success = false, -- 1631
			file = path, -- 1631
			message = "file not existed" -- 1631
		} -- 1631
	end -- 1630
	do -- 1632
		local _exp_0 = Path:getExt(path) -- 1632
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1632
			if '' == Path:getExt(Path:getName(path)) then -- 1633
				local content = Content:loadAsync(path) -- 1634
				if content then -- 1634
					local resultCodes, err = compileFileAsync(path, content) -- 1635
					if resultCodes then -- 1635
						return { -- 1636
							success = true, -- 1636
							file = path -- 1636
						} -- 1636
					else -- 1638
						return { -- 1638
							success = false, -- 1638
							file = path, -- 1638
							message = err -- 1638
						} -- 1638
					end -- 1635
				end -- 1634
			end -- 1633
		elseif "lua" == _exp_0 then -- 1639
			local content = Content:loadAsync(path) -- 1640
			if content then -- 1640
				do -- 1641
					local isTIC80 = CheckTIC80Code(content) -- 1641
					if isTIC80 then -- 1641
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1642
					end -- 1641
				end -- 1641
				local success, info -- 1643
				do -- 1643
					local _obj_0 = luaCheck(path, content) -- 1643
					success, info = _obj_0.success, _obj_0.info -- 1643
				end -- 1643
				if success then -- 1644
					return { -- 1645
						success = true, -- 1645
						file = path -- 1645
					} -- 1645
				elseif info and #info > 0 then -- 1646
					local messages = { } -- 1647
					for _index_0 = 1, #info do -- 1648
						local _des_0 = info[_index_0] -- 1648
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 1648
						local lineText = "" -- 1649
						if line then -- 1650
							local currentLine = 1 -- 1651
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1652
								if currentLine == line then -- 1653
									lineText = text -- 1654
									break -- 1655
								end -- 1653
								currentLine = currentLine + 1 -- 1656
							end -- 1652
						end -- 1650
						if line then -- 1657
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1658
						else -- 1660
							messages[#messages + 1] = message -- 1660
						end -- 1657
					end -- 1648
					return { -- 1661
						success = false, -- 1661
						file = path, -- 1661
						message = table.concat(messages, "\n") -- 1661
					} -- 1661
				else -- 1663
					return { -- 1663
						success = false, -- 1663
						file = path, -- 1663
						message = "lua check failed" -- 1663
					} -- 1663
				end -- 1644
			end -- 1640
		elseif "yarn" == _exp_0 then -- 1664
			local content = Content:loadAsync(path) -- 1665
			if content then -- 1665
				local res, _, err = yarncompile(content, true) -- 1666
				if res then -- 1666
					return { -- 1667
						success = true, -- 1667
						file = path -- 1667
					} -- 1667
				else -- 1669
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1669
					local lineText = "" -- 1670
					if line then -- 1671
						local currentLine = 1 -- 1672
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1673
							if currentLine == line then -- 1674
								lineText = text -- 1675
								break -- 1676
							end -- 1674
							currentLine = currentLine + 1 -- 1677
						end -- 1673
					end -- 1671
					if node ~= "" then -- 1678
						node = "node: " .. tostring(node) .. ", " -- 1679
					else -- 1680
						node = "" -- 1680
					end -- 1678
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1681
					return { -- 1682
						success = false, -- 1682
						file = path, -- 1682
						message = message -- 1682
					} -- 1682
				end -- 1666
			end -- 1665
		end -- 1632
	end -- 1632
	return { -- 1683
		success = false, -- 1683
		file = path, -- 1683
		message = "invalid file to build" -- 1683
	} -- 1683
end -- 1629
thread(function() -- 1685
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1686
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1687
	if Content:exist(doraWeb) then -- 1688
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 1689
		local needReload -- 1690
		if Content:exist(doraReady) then -- 1690
			needReload = readyContent ~= Content:load(doraReady) -- 1691
		else -- 1692
			needReload = true -- 1692
		end -- 1690
		if needReload then -- 1693
			Content:remove(Path(Content.appPath, ".www")) -- 1694
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1695
			Content:save(doraReady, readyContent) -- 1699
			print("Dora Dora is ready!") -- 1700
		end -- 1693
	end -- 1688
	if HttpServer:start(8866) then -- 1701
		local localIP = HttpServer.localIP -- 1702
		if localIP == "" then -- 1703
			localIP = "localhost" -- 1703
		end -- 1703
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1704
		return HttpServer:startWS(8868) -- 1705
	else -- 1707
		status.url = nil -- 1707
		return print("8866 Port not available!") -- 1708
	end -- 1701
end) -- 1685
return _module_0 -- 1
