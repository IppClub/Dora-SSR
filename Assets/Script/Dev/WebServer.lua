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
	local res = AgentSession.listRunningSessions() -- 164
	if res.success and #res.sessions == 0 then -- 165
		res.sessions = nil -- 166
	end -- 165
	return res -- 167
end) -- 163
HttpServer:post("/agent/task/stop", function(req) -- 169
	do -- 170
		local _type_0 = type(req) -- 170
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 170
		if _tab_0 then -- 170
			local sessionId -- 170
			do -- 170
				local _obj_0 = req.body -- 170
				local _type_1 = type(_obj_0) -- 170
				if "table" == _type_1 or "userdata" == _type_1 then -- 170
					sessionId = _obj_0.sessionId -- 170
				end -- 170
			end -- 170
			if sessionId ~= nil then -- 170
				return AgentSession.stopSessionTask(sessionId) -- 171
			end -- 170
		end -- 170
	end -- 170
	return invalidArguments -- 169
end) -- 169
HttpServer:post("/agent/checkpoint/list", function(req) -- 173
	do -- 174
		local _type_0 = type(req) -- 174
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 174
		if _tab_0 then -- 174
			local taskId -- 174
			do -- 174
				local _obj_0 = req.body -- 174
				local _type_1 = type(_obj_0) -- 174
				if "table" == _type_1 or "userdata" == _type_1 then -- 174
					taskId = _obj_0.taskId -- 174
				end -- 174
			end -- 174
			local sessionId -- 174
			do -- 174
				local _obj_0 = req.body -- 174
				local _type_1 = type(_obj_0) -- 174
				if "table" == _type_1 or "userdata" == _type_1 then -- 174
					sessionId = _obj_0.sessionId -- 174
				end -- 174
			end -- 174
			if sessionId ~= nil then -- 174
				if not taskId and sessionId then -- 175
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 176
				end -- 175
				if not taskId then -- 177
					return { -- 177
						success = false, -- 177
						message = "task not found" -- 177
					} -- 177
				end -- 177
				return { -- 179
					success = true, -- 179
					taskId = taskId, -- 180
					checkpoints = AgentTools.listCheckpoints(taskId) -- 181
				} -- 178
			end -- 174
		end -- 174
	end -- 174
	return invalidArguments -- 173
end) -- 173
HttpServer:post("/agent/checkpoint/diff", function(req) -- 183
	do -- 184
		local _type_0 = type(req) -- 184
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 184
		if _tab_0 then -- 184
			local checkpointId -- 184
			do -- 184
				local _obj_0 = req.body -- 184
				local _type_1 = type(_obj_0) -- 184
				if "table" == _type_1 or "userdata" == _type_1 then -- 184
					checkpointId = _obj_0.checkpointId -- 184
				end -- 184
			end -- 184
			if checkpointId ~= nil then -- 184
				if not (checkpointId > 0) then -- 185
					return { -- 185
						success = false, -- 185
						message = "invalid checkpointId" -- 185
					} -- 185
				end -- 185
				return AgentTools.getCheckpointDiff(checkpointId) -- 186
			end -- 184
		end -- 184
	end -- 184
	return invalidArguments -- 183
end) -- 183
HttpServer:post("/agent/task/diff", function(req) -- 188
	do -- 189
		local _type_0 = type(req) -- 189
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 189
		if _tab_0 then -- 189
			local taskId -- 189
			do -- 189
				local _obj_0 = req.body -- 189
				local _type_1 = type(_obj_0) -- 189
				if "table" == _type_1 or "userdata" == _type_1 then -- 189
					taskId = _obj_0.taskId -- 189
				end -- 189
			end -- 189
			if taskId ~= nil then -- 189
				if not (taskId > 0) then -- 190
					return { -- 190
						success = false, -- 190
						message = "invalid taskId" -- 190
					} -- 190
				end -- 190
				return AgentTools.getTaskChangeSetDiff(taskId) -- 191
			end -- 189
		end -- 189
	end -- 189
	return invalidArguments -- 188
end) -- 188
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 193
	do -- 194
		local _type_0 = type(req) -- 194
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 194
		if _tab_0 then -- 194
			local sessionId -- 194
			do -- 194
				local _obj_0 = req.body -- 194
				local _type_1 = type(_obj_0) -- 194
				if "table" == _type_1 or "userdata" == _type_1 then -- 194
					sessionId = _obj_0.sessionId -- 194
				end -- 194
			end -- 194
			local checkpointId -- 194
			do -- 194
				local _obj_0 = req.body -- 194
				local _type_1 = type(_obj_0) -- 194
				if "table" == _type_1 or "userdata" == _type_1 then -- 194
					checkpointId = _obj_0.checkpointId -- 194
				end -- 194
			end -- 194
			if sessionId ~= nil and checkpointId ~= nil then -- 194
				if not (checkpointId > 0) then -- 195
					return { -- 195
						success = false, -- 195
						message = "invalid checkpointId" -- 195
					} -- 195
				end -- 195
				local res = AgentSession.getSession(sessionId) -- 196
				if not res.success then -- 197
					return res -- 197
				end -- 197
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, res.session.projectRoot) -- 198
				if not rollbackRes.success then -- 199
					return rollbackRes -- 199
				end -- 199
				return { -- 201
					success = true, -- 201
					checkpointId = rollbackRes.checkpointId -- 202
				} -- 200
			end -- 194
		end -- 194
	end -- 194
	return invalidArguments -- 193
end) -- 193
HttpServer:post("/agent/task/rollback", function(req) -- 204
	do -- 205
		local _type_0 = type(req) -- 205
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 205
		if _tab_0 then -- 205
			local sessionId -- 205
			do -- 205
				local _obj_0 = req.body -- 205
				local _type_1 = type(_obj_0) -- 205
				if "table" == _type_1 or "userdata" == _type_1 then -- 205
					sessionId = _obj_0.sessionId -- 205
				end -- 205
			end -- 205
			local taskId -- 205
			do -- 205
				local _obj_0 = req.body -- 205
				local _type_1 = type(_obj_0) -- 205
				if "table" == _type_1 or "userdata" == _type_1 then -- 205
					taskId = _obj_0.taskId -- 205
				end -- 205
			end -- 205
			if sessionId ~= nil and taskId ~= nil then -- 205
				if not (taskId > 0) then -- 206
					return { -- 206
						success = false, -- 206
						message = "invalid taskId" -- 206
					} -- 206
				end -- 206
				local res = AgentSession.getSession(sessionId) -- 207
				if not res.success then -- 208
					return res -- 208
				end -- 208
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, res.session.projectRoot) -- 209
				if not rollbackRes.success then -- 210
					return rollbackRes -- 210
				end -- 210
				return { -- 212
					success = true, -- 212
					taskId = rollbackRes.taskId, -- 213
					checkpointId = rollbackRes.checkpointId, -- 214
					checkpointCount = rollbackRes.checkpointCount -- 215
				} -- 211
			end -- 205
		end -- 205
	end -- 205
	return invalidArguments -- 204
end) -- 204
local getSearchPath -- 217
getSearchPath = function(file) -- 217
	do -- 218
		local dir = getProjectDirFromFile(file) -- 218
		if dir then -- 218
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 219
		end -- 218
	end -- 218
	return "" -- 217
end -- 217
local getSearchFolders -- 221
getSearchFolders = function(file) -- 221
	do -- 222
		local dir = getProjectDirFromFile(file) -- 222
		if dir then -- 222
			return { -- 224
				Path(dir, "Script"), -- 224
				dir -- 225
			} -- 223
		end -- 222
	end -- 222
	return { } -- 221
end -- 221
local disabledCheckForLua = { -- 228
	"incompatible number of returns", -- 228
	"unknown", -- 229
	"cannot index", -- 230
	"module not found", -- 231
	"don't know how to resolve", -- 232
	"ContainerItem", -- 233
	"cannot resolve a type", -- 234
	"invalid key", -- 235
	"inconsistent index type", -- 236
	"cannot use operator", -- 237
	"attempting ipairs loop", -- 238
	"expects record or nominal", -- 239
	"variable is not being assigned", -- 240
	"<invalid type>", -- 241
	"<any type>", -- 242
	"using the '#' operator", -- 243
	"can't match a record", -- 244
	"redeclaration of variable", -- 245
	"cannot apply pairs", -- 246
	"not a function", -- 247
	"to%-be%-closed" -- 248
} -- 227
local yueCheck -- 250
yueCheck = function(file, content, lax) -- 250
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 251
	if isTIC80 then -- 252
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 253
	end -- 252
	local searchPath = getSearchPath(file) -- 254
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 255
	local info = { } -- 256
	local globals = { } -- 257
	for _index_0 = 1, #checkResult do -- 258
		local _des_0 = checkResult[_index_0] -- 258
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 258
		if "error" == t then -- 259
			info[#info + 1] = { -- 260
				"syntax", -- 260
				file, -- 260
				line, -- 260
				col, -- 260
				msg -- 260
			} -- 260
		elseif "global" == t then -- 261
			globals[#globals + 1] = { -- 262
				msg, -- 262
				line, -- 262
				col -- 262
			} -- 262
		end -- 259
	end -- 258
	if luaCodes then -- 263
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 264
		if success then -- 265
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 266
			if not (lintResult == "") then -- 267
				lintResult = lintResult .. "\n" -- 267
			end -- 267
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 268
		else -- 269
			for _index_0 = 1, #lintResult do -- 269
				local _des_0 = lintResult[_index_0] -- 269
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 269
				if isTIC80 and tic80APIs[name] then -- 270
					goto _continue_0 -- 270
				end -- 270
				info[#info + 1] = { -- 271
					"syntax", -- 271
					file, -- 271
					line, -- 271
					col, -- 271
					"invalid global variable" -- 271
				} -- 271
				::_continue_0:: -- 270
			end -- 269
		end -- 265
	end -- 263
	return luaCodes, info -- 272
end -- 250
local luaCheck -- 274
luaCheck = function(file, content) -- 274
	local res, err = load(content, "check") -- 275
	if not res then -- 276
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 277
		return { -- 278
			success = false, -- 278
			info = { -- 278
				{ -- 278
					"syntax", -- 278
					file, -- 278
					tonumber(line), -- 278
					0, -- 278
					msg -- 278
				} -- 278
			} -- 278
		} -- 278
	end -- 276
	local success, info = teal.checkAsync(content, file, true, "") -- 279
	if info then -- 280
		do -- 281
			local _accum_0 = { } -- 281
			local _len_0 = 1 -- 281
			for _index_0 = 1, #info do -- 281
				local item = info[_index_0] -- 281
				local useCheck = true -- 282
				if not item[5]:match("unused") then -- 283
					for _index_1 = 1, #disabledCheckForLua do -- 284
						local check = disabledCheckForLua[_index_1] -- 284
						if item[5]:match(check) then -- 285
							useCheck = false -- 286
						end -- 285
					end -- 284
				end -- 283
				if not useCheck then -- 287
					goto _continue_0 -- 287
				end -- 287
				do -- 288
					local _exp_0 = item[1] -- 288
					if "type" == _exp_0 then -- 289
						item[1] = "warning" -- 290
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 291
						goto _continue_0 -- 292
					end -- 288
				end -- 288
				_accum_0[_len_0] = item -- 293
				_len_0 = _len_0 + 1 -- 282
				::_continue_0:: -- 282
			end -- 281
			info = _accum_0 -- 281
		end -- 281
		if #info == 0 then -- 294
			info = nil -- 295
			success = true -- 296
		end -- 294
	end -- 280
	return { -- 297
		success = success, -- 297
		info = info -- 297
	} -- 297
end -- 274
local luaCheckWithLineInfo -- 299
luaCheckWithLineInfo = function(file, luaCodes) -- 299
	local res = luaCheck(file, luaCodes) -- 300
	local info = { } -- 301
	if not res.success then -- 302
		local current = 1 -- 303
		local lastLine = 1 -- 304
		local lineMap = { } -- 305
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 306
			local num = lineCode:match("--%s*(%d+)%s*$") -- 307
			if num then -- 308
				lastLine = tonumber(num) -- 309
			end -- 308
			lineMap[current] = lastLine -- 310
			current = current + 1 -- 311
		end -- 306
		local _list_0 = res.info -- 312
		for _index_0 = 1, #_list_0 do -- 312
			local item = _list_0[_index_0] -- 312
			item[3] = lineMap[item[3]] or 0 -- 313
			item[4] = 0 -- 314
			info[#info + 1] = item -- 315
		end -- 312
		return false, info -- 316
	end -- 302
	return true, info -- 317
end -- 299
local getCompiledYueLine -- 319
getCompiledYueLine = function(content, line, row, file, lax) -- 319
	local luaCodes = yueCheck(file, content, lax) -- 320
	if not luaCodes then -- 321
		return nil -- 321
	end -- 321
	local current = 1 -- 322
	local lastLine = 1 -- 323
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 324
	local targetRow = nil -- 325
	local lineMap = { } -- 326
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 327
		local num = lineCode:match("--%s*(%d+)%s*$") -- 328
		if num then -- 329
			lastLine = tonumber(num) -- 329
		end -- 329
		lineMap[current] = lastLine -- 330
		if row <= lastLine and not targetRow then -- 331
			targetRow = current -- 332
			break -- 333
		end -- 331
		current = current + 1 -- 334
	end -- 327
	targetRow = current -- 335
	if targetLine and targetRow then -- 336
		return luaCodes, targetLine, targetRow, lineMap -- 337
	else -- 339
		return nil -- 339
	end -- 336
end -- 319
HttpServer:postSchedule("/check", function(req) -- 341
	do -- 342
		local _type_0 = type(req) -- 342
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 342
		if _tab_0 then -- 342
			local file -- 342
			do -- 342
				local _obj_0 = req.body -- 342
				local _type_1 = type(_obj_0) -- 342
				if "table" == _type_1 or "userdata" == _type_1 then -- 342
					file = _obj_0.file -- 342
				end -- 342
			end -- 342
			local content -- 342
			do -- 342
				local _obj_0 = req.body -- 342
				local _type_1 = type(_obj_0) -- 342
				if "table" == _type_1 or "userdata" == _type_1 then -- 342
					content = _obj_0.content -- 342
				end -- 342
			end -- 342
			if file ~= nil and content ~= nil then -- 342
				local ext = Path:getExt(file) -- 343
				if "tl" == ext then -- 344
					local searchPath = getSearchPath(file) -- 345
					do -- 346
						local isTIC80 = CheckTIC80Code(content) -- 346
						if isTIC80 then -- 346
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 347
						end -- 346
					end -- 346
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 348
					return { -- 349
						success = success, -- 349
						info = info -- 349
					} -- 349
				elseif "lua" == ext then -- 350
					do -- 351
						local isTIC80 = CheckTIC80Code(content) -- 351
						if isTIC80 then -- 351
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 352
						end -- 351
					end -- 351
					return luaCheck(file, content) -- 353
				elseif "yue" == ext then -- 354
					local luaCodes, info = yueCheck(file, content, false) -- 355
					local success = false -- 356
					if luaCodes then -- 357
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 358
						do -- 359
							local _tab_1 = { } -- 359
							local _idx_0 = #_tab_1 + 1 -- 359
							for _index_0 = 1, #info do -- 359
								local _value_0 = info[_index_0] -- 359
								_tab_1[_idx_0] = _value_0 -- 359
								_idx_0 = _idx_0 + 1 -- 359
							end -- 359
							local _idx_1 = #_tab_1 + 1 -- 359
							for _index_0 = 1, #luaInfo do -- 359
								local _value_0 = luaInfo[_index_0] -- 359
								_tab_1[_idx_1] = _value_0 -- 359
								_idx_1 = _idx_1 + 1 -- 359
							end -- 359
							info = _tab_1 -- 359
						end -- 359
						success = success and luaSuccess -- 360
					end -- 357
					if #info > 0 then -- 361
						return { -- 362
							success = success, -- 362
							info = info -- 362
						} -- 362
					else -- 364
						return { -- 364
							success = success -- 364
						} -- 364
					end -- 361
				elseif "xml" == ext then -- 365
					local success, result = xml.check(content) -- 366
					if success then -- 367
						local info -- 368
						success, info = luaCheckWithLineInfo(file, result) -- 368
						if #info > 0 then -- 369
							return { -- 370
								success = success, -- 370
								info = info -- 370
							} -- 370
						else -- 372
							return { -- 372
								success = success -- 372
							} -- 372
						end -- 369
					else -- 374
						local info -- 374
						do -- 374
							local _accum_0 = { } -- 374
							local _len_0 = 1 -- 374
							for _index_0 = 1, #result do -- 374
								local _des_0 = result[_index_0] -- 374
								local row, err = _des_0[1], _des_0[2] -- 374
								_accum_0[_len_0] = { -- 375
									"syntax", -- 375
									file, -- 375
									row, -- 375
									0, -- 375
									err -- 375
								} -- 375
								_len_0 = _len_0 + 1 -- 375
							end -- 374
							info = _accum_0 -- 374
						end -- 374
						return { -- 376
							success = false, -- 376
							info = info -- 376
						} -- 376
					end -- 367
				end -- 344
			end -- 342
		end -- 342
	end -- 342
	return { -- 341
		success = true -- 341
	} -- 341
end) -- 341
HttpServer:post("/body/parse", function(req) -- 378
	do -- 379
		local _type_0 = type(req) -- 379
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 379
		if _tab_0 then -- 379
			local file -- 379
			do -- 379
				local _obj_0 = req.body -- 379
				local _type_1 = type(_obj_0) -- 379
				if "table" == _type_1 or "userdata" == _type_1 then -- 379
					file = _obj_0.file -- 379
				end -- 379
			end -- 379
			local content -- 379
			do -- 379
				local _obj_0 = req.body -- 379
				local _type_1 = type(_obj_0) -- 379
				if "table" == _type_1 or "userdata" == _type_1 then -- 379
					content = _obj_0.content -- 379
				end -- 379
			end -- 379
			if file ~= nil and content ~= nil then -- 379
				if not (file:sub(-6) == ".b.lua") then -- 380
					return { -- 381
						success = false, -- 381
						phase = "request", -- 381
						message = "only .b.lua files can be converted" -- 381
					} -- 381
				end -- 380
				local loader, err = load("_ENV = {}\n" .. content) -- 382
				if not loader then -- 383
					return { -- 384
						success = false, -- 384
						phase = "parse", -- 384
						message = tostring(err) -- 384
					} -- 384
				end -- 383
				local ok, data = pcall(loader) -- 385
				if not ok then -- 386
					return { -- 387
						success = false, -- 387
						phase = "execute", -- 387
						message = tostring(data) -- 387
					} -- 387
				end -- 386
				if not ("table" == type(data) and data[1] == "Array") then -- 388
					return { -- 389
						success = false, -- 389
						phase = "validate", -- 389
						message = "body lua root must be {\"Array\", ...}" -- 389
					} -- 389
				end -- 388
				local text, jsonErr = json.encode(data, false, true) -- 390
				if not text then -- 391
					return { -- 392
						success = false, -- 392
						phase = "encode", -- 392
						message = tostring(jsonErr) -- 392
					} -- 392
				end -- 391
				return { -- 393
					success = true, -- 393
					json = text -- 393
				} -- 393
			end -- 379
		end -- 379
	end -- 379
	return { -- 378
		success = false, -- 378
		phase = "request", -- 378
		message = "invalid request" -- 378
	} -- 378
end) -- 378
local updateInferedDesc -- 395
updateInferedDesc = function(infered) -- 395
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 396
		return -- 396
	end -- 396
	local key, row = infered.key, infered.row -- 397
	local codes = Content:loadAsync(key) -- 398
	if codes then -- 398
		local comments = { } -- 399
		local line = 0 -- 400
		local skipping = false -- 401
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 402
			line = line + 1 -- 403
			if line >= row then -- 404
				break -- 404
			end -- 404
			if lineCode:match("^%s*%-%- @") then -- 405
				skipping = true -- 406
				goto _continue_0 -- 407
			end -- 405
			local result = lineCode:match("^%s*%-%- (.+)") -- 408
			if result then -- 408
				if not skipping then -- 409
					comments[#comments + 1] = result -- 409
				end -- 409
			elseif #comments > 0 then -- 410
				comments = { } -- 411
				skipping = false -- 412
			end -- 408
			::_continue_0:: -- 403
		end -- 402
		infered.doc = table.concat(comments, "\n") -- 413
	end -- 398
end -- 395
HttpServer:postSchedule("/infer", function(req) -- 415
	do -- 416
		local _type_0 = type(req) -- 416
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 416
		if _tab_0 then -- 416
			local lang -- 416
			do -- 416
				local _obj_0 = req.body -- 416
				local _type_1 = type(_obj_0) -- 416
				if "table" == _type_1 or "userdata" == _type_1 then -- 416
					lang = _obj_0.lang -- 416
				end -- 416
			end -- 416
			local file -- 416
			do -- 416
				local _obj_0 = req.body -- 416
				local _type_1 = type(_obj_0) -- 416
				if "table" == _type_1 or "userdata" == _type_1 then -- 416
					file = _obj_0.file -- 416
				end -- 416
			end -- 416
			local content -- 416
			do -- 416
				local _obj_0 = req.body -- 416
				local _type_1 = type(_obj_0) -- 416
				if "table" == _type_1 or "userdata" == _type_1 then -- 416
					content = _obj_0.content -- 416
				end -- 416
			end -- 416
			local line -- 416
			do -- 416
				local _obj_0 = req.body -- 416
				local _type_1 = type(_obj_0) -- 416
				if "table" == _type_1 or "userdata" == _type_1 then -- 416
					line = _obj_0.line -- 416
				end -- 416
			end -- 416
			local row -- 416
			do -- 416
				local _obj_0 = req.body -- 416
				local _type_1 = type(_obj_0) -- 416
				if "table" == _type_1 or "userdata" == _type_1 then -- 416
					row = _obj_0.row -- 416
				end -- 416
			end -- 416
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 416
				local searchPath = getSearchPath(file) -- 417
				if "tl" == lang or "lua" == lang then -- 418
					if CheckTIC80Code(content) then -- 419
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 420
					end -- 419
					local infered = teal.inferAsync(content, line, row, searchPath) -- 421
					if (infered ~= nil) then -- 422
						updateInferedDesc(infered) -- 423
						return { -- 424
							success = true, -- 424
							infered = infered -- 424
						} -- 424
					end -- 422
				elseif "yue" == lang then -- 425
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 426
					if not luaCodes then -- 427
						return { -- 427
							success = false -- 427
						} -- 427
					end -- 427
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 428
					if (infered ~= nil) then -- 429
						local col -- 430
						file, row, col = infered.file, infered.row, infered.col -- 430
						if file == "" and row > 0 and col > 0 then -- 431
							infered.row = lineMap[row] or 0 -- 432
							infered.col = 0 -- 433
						end -- 431
						updateInferedDesc(infered) -- 434
						return { -- 435
							success = true, -- 435
							infered = infered -- 435
						} -- 435
					end -- 429
				end -- 418
			end -- 416
		end -- 416
	end -- 416
	return { -- 415
		success = false -- 415
	} -- 415
end) -- 415
local _anon_func_2 = function(doc) -- 486
	local _accum_0 = { } -- 486
	local _len_0 = 1 -- 486
	local _list_0 = doc.params -- 486
	for _index_0 = 1, #_list_0 do -- 486
		local param = _list_0[_index_0] -- 486
		_accum_0[_len_0] = param.name -- 486
		_len_0 = _len_0 + 1 -- 486
	end -- 486
	return _accum_0 -- 486
end -- 486
local getParamDocs -- 437
getParamDocs = function(signatures) -- 437
	do -- 438
		local codes = Content:loadAsync(signatures[1].file) -- 438
		if codes then -- 438
			local comments = { } -- 439
			local params = { } -- 440
			local line = 0 -- 441
			local docs = { } -- 442
			local returnType = nil -- 443
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 444
				line = line + 1 -- 445
				local needBreak = true -- 446
				for i, _des_0 in ipairs(signatures) do -- 447
					local row = _des_0.row -- 447
					if line >= row and not (docs[i] ~= nil) then -- 448
						if #comments > 0 or #params > 0 or returnType then -- 449
							docs[i] = { -- 451
								doc = table.concat(comments, "  \n"), -- 451
								returnType = returnType -- 452
							} -- 450
							if #params > 0 then -- 454
								docs[i].params = params -- 454
							end -- 454
						else -- 456
							docs[i] = false -- 456
						end -- 449
					end -- 448
					if not docs[i] then -- 457
						needBreak = false -- 457
					end -- 457
				end -- 447
				if needBreak then -- 458
					break -- 458
				end -- 458
				local result = lineCode:match("%s*%-%- (.+)") -- 459
				if result then -- 459
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 460
					if not name then -- 461
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 462
					end -- 461
					if name then -- 463
						local pname = name -- 464
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 465
							pname = pname .. "?" -- 465
						end -- 465
						params[#params + 1] = { -- 467
							name = tostring(pname) .. ": " .. tostring(typ), -- 467
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 468
						} -- 466
					else -- 471
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 471
						if typ then -- 471
							if returnType then -- 472
								returnType = returnType .. ", " .. typ -- 473
							else -- 475
								returnType = typ -- 475
							end -- 472
							result = result:gsub("@return", "**return:**") -- 476
						end -- 471
						comments[#comments + 1] = result -- 477
					end -- 463
				elseif #comments > 0 then -- 478
					comments = { } -- 479
					params = { } -- 480
					returnType = nil -- 481
				end -- 459
			end -- 444
			local results = { } -- 482
			for _index_0 = 1, #docs do -- 483
				local doc = docs[_index_0] -- 483
				if not doc then -- 484
					goto _continue_0 -- 484
				end -- 484
				if doc.params then -- 485
					doc.desc = "function(" .. tostring(table.concat(_anon_func_2(doc), ', ')) .. ")" -- 486
				else -- 488
					doc.desc = "function()" -- 488
				end -- 485
				if doc.returnType then -- 489
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 490
					doc.returnType = nil -- 491
				end -- 489
				results[#results + 1] = doc -- 492
				::_continue_0:: -- 484
			end -- 483
			if #results > 0 then -- 493
				return results -- 493
			else -- 493
				return nil -- 493
			end -- 493
		end -- 438
	end -- 438
	return nil -- 437
end -- 437
HttpServer:postSchedule("/signature", function(req) -- 495
	do -- 496
		local _type_0 = type(req) -- 496
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 496
		if _tab_0 then -- 496
			local lang -- 496
			do -- 496
				local _obj_0 = req.body -- 496
				local _type_1 = type(_obj_0) -- 496
				if "table" == _type_1 or "userdata" == _type_1 then -- 496
					lang = _obj_0.lang -- 496
				end -- 496
			end -- 496
			local file -- 496
			do -- 496
				local _obj_0 = req.body -- 496
				local _type_1 = type(_obj_0) -- 496
				if "table" == _type_1 or "userdata" == _type_1 then -- 496
					file = _obj_0.file -- 496
				end -- 496
			end -- 496
			local content -- 496
			do -- 496
				local _obj_0 = req.body -- 496
				local _type_1 = type(_obj_0) -- 496
				if "table" == _type_1 or "userdata" == _type_1 then -- 496
					content = _obj_0.content -- 496
				end -- 496
			end -- 496
			local line -- 496
			do -- 496
				local _obj_0 = req.body -- 496
				local _type_1 = type(_obj_0) -- 496
				if "table" == _type_1 or "userdata" == _type_1 then -- 496
					line = _obj_0.line -- 496
				end -- 496
			end -- 496
			local row -- 496
			do -- 496
				local _obj_0 = req.body -- 496
				local _type_1 = type(_obj_0) -- 496
				if "table" == _type_1 or "userdata" == _type_1 then -- 496
					row = _obj_0.row -- 496
				end -- 496
			end -- 496
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 496
				local searchPath = getSearchPath(file) -- 497
				if "tl" == lang or "lua" == lang then -- 498
					if CheckTIC80Code(content) then -- 499
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 500
					end -- 499
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 501
					if signatures then -- 501
						signatures = getParamDocs(signatures) -- 502
						if signatures then -- 502
							return { -- 503
								success = true, -- 503
								signatures = signatures -- 503
							} -- 503
						end -- 502
					end -- 501
				elseif "yue" == lang then -- 504
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 505
					if not luaCodes then -- 506
						return { -- 506
							success = false -- 506
						} -- 506
					end -- 506
					do -- 507
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 507
						if chainOp then -- 507
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 508
							if withVar then -- 508
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 509
							end -- 508
						end -- 507
					end -- 507
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 510
					if signatures then -- 510
						signatures = getParamDocs(signatures) -- 511
						if signatures then -- 511
							return { -- 512
								success = true, -- 512
								signatures = signatures -- 512
							} -- 512
						end -- 511
					else -- 513
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 513
						if signatures then -- 513
							signatures = getParamDocs(signatures) -- 514
							if signatures then -- 514
								return { -- 515
									success = true, -- 515
									signatures = signatures -- 515
								} -- 515
							end -- 514
						end -- 513
					end -- 510
				end -- 498
			end -- 496
		end -- 496
	end -- 496
	return { -- 495
		success = false -- 495
	} -- 495
end) -- 495
local luaKeywords = { -- 518
	'and', -- 518
	'break', -- 519
	'do', -- 520
	'else', -- 521
	'elseif', -- 522
	'end', -- 523
	'false', -- 524
	'for', -- 525
	'function', -- 526
	'goto', -- 527
	'if', -- 528
	'in', -- 529
	'local', -- 530
	'nil', -- 531
	'not', -- 532
	'or', -- 533
	'repeat', -- 534
	'return', -- 535
	'then', -- 536
	'true', -- 537
	'until', -- 538
	'while' -- 539
} -- 517
local tealKeywords = { -- 543
	'record', -- 543
	'as', -- 544
	'is', -- 545
	'type', -- 546
	'embed', -- 547
	'enum', -- 548
	'global', -- 549
	'any', -- 550
	'boolean', -- 551
	'integer', -- 552
	'number', -- 553
	'string', -- 554
	'thread' -- 555
} -- 542
local yueKeywords = { -- 559
	"and", -- 559
	"break", -- 560
	"do", -- 561
	"else", -- 562
	"elseif", -- 563
	"false", -- 564
	"for", -- 565
	"goto", -- 566
	"if", -- 567
	"in", -- 568
	"local", -- 569
	"nil", -- 570
	"not", -- 571
	"or", -- 572
	"repeat", -- 573
	"return", -- 574
	"then", -- 575
	"true", -- 576
	"until", -- 577
	"while", -- 578
	"as", -- 579
	"class", -- 580
	"continue", -- 581
	"export", -- 582
	"extends", -- 583
	"from", -- 584
	"global", -- 585
	"import", -- 586
	"macro", -- 587
	"switch", -- 588
	"try", -- 589
	"unless", -- 590
	"using", -- 591
	"when", -- 592
	"with" -- 593
} -- 558
local _anon_func_3 = function(f) -- 629
	local _val_0 = Path:getExt(f) -- 629
	return "ttf" == _val_0 or "otf" == _val_0 -- 629
end -- 629
local _anon_func_4 = function(suggestions) -- 655
	local _tbl_0 = { } -- 655
	for _index_0 = 1, #suggestions do -- 655
		local item = suggestions[_index_0] -- 655
		_tbl_0[item[1] .. item[2]] = item -- 655
	end -- 655
	return _tbl_0 -- 655
end -- 655
HttpServer:postSchedule("/complete", function(req) -- 596
	do -- 597
		local _type_0 = type(req) -- 597
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 597
		if _tab_0 then -- 597
			local lang -- 597
			do -- 597
				local _obj_0 = req.body -- 597
				local _type_1 = type(_obj_0) -- 597
				if "table" == _type_1 or "userdata" == _type_1 then -- 597
					lang = _obj_0.lang -- 597
				end -- 597
			end -- 597
			local file -- 597
			do -- 597
				local _obj_0 = req.body -- 597
				local _type_1 = type(_obj_0) -- 597
				if "table" == _type_1 or "userdata" == _type_1 then -- 597
					file = _obj_0.file -- 597
				end -- 597
			end -- 597
			local content -- 597
			do -- 597
				local _obj_0 = req.body -- 597
				local _type_1 = type(_obj_0) -- 597
				if "table" == _type_1 or "userdata" == _type_1 then -- 597
					content = _obj_0.content -- 597
				end -- 597
			end -- 597
			local line -- 597
			do -- 597
				local _obj_0 = req.body -- 597
				local _type_1 = type(_obj_0) -- 597
				if "table" == _type_1 or "userdata" == _type_1 then -- 597
					line = _obj_0.line -- 597
				end -- 597
			end -- 597
			local row -- 597
			do -- 597
				local _obj_0 = req.body -- 597
				local _type_1 = type(_obj_0) -- 597
				if "table" == _type_1 or "userdata" == _type_1 then -- 597
					row = _obj_0.row -- 597
				end -- 597
			end -- 597
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 597
				local searchPath = getSearchPath(file) -- 598
				repeat -- 599
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 600
					if lang == "yue" then -- 601
						if not item then -- 602
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 602
						end -- 602
						if not item then -- 603
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 603
						end -- 603
					end -- 601
					local searchType = nil -- 604
					if not item then -- 605
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 606
						if lang == "yue" then -- 607
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 608
						end -- 607
						if (item ~= nil) then -- 609
							searchType = "Image" -- 609
						end -- 609
					end -- 605
					if not item then -- 610
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 611
						if lang == "yue" then -- 612
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 613
						end -- 612
						if (item ~= nil) then -- 614
							searchType = "Font" -- 614
						end -- 614
					end -- 610
					if not item then -- 615
						break -- 615
					end -- 615
					local searchPaths = Content.searchPaths -- 616
					local _list_0 = getSearchFolders(file) -- 617
					for _index_0 = 1, #_list_0 do -- 617
						local folder = _list_0[_index_0] -- 617
						searchPaths[#searchPaths + 1] = folder -- 618
					end -- 617
					if searchType then -- 619
						searchPaths[#searchPaths + 1] = Content.assetPath -- 619
					end -- 619
					local tokens -- 620
					do -- 620
						local _accum_0 = { } -- 620
						local _len_0 = 1 -- 620
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 620
							_accum_0[_len_0] = mod -- 620
							_len_0 = _len_0 + 1 -- 620
						end -- 620
						tokens = _accum_0 -- 620
					end -- 620
					local suggestions = { } -- 621
					for _index_0 = 1, #searchPaths do -- 622
						local path = searchPaths[_index_0] -- 622
						local sPath = Path(path, table.unpack(tokens)) -- 623
						if not Content:exist(sPath) then -- 624
							goto _continue_0 -- 624
						end -- 624
						if searchType == "Font" then -- 625
							local fontPath = Path(sPath, "Font") -- 626
							if Content:exist(fontPath) then -- 627
								local _list_1 = Content:getFiles(fontPath) -- 628
								for _index_1 = 1, #_list_1 do -- 628
									local f = _list_1[_index_1] -- 628
									if _anon_func_3(f) then -- 629
										if "." == f:sub(1, 1) then -- 630
											goto _continue_1 -- 630
										end -- 630
										suggestions[#suggestions + 1] = { -- 631
											Path:getName(f), -- 631
											"font", -- 631
											"field" -- 631
										} -- 631
									end -- 629
									::_continue_1:: -- 629
								end -- 628
							end -- 627
						end -- 625
						local _list_1 = Content:getFiles(sPath) -- 632
						for _index_1 = 1, #_list_1 do -- 632
							local f = _list_1[_index_1] -- 632
							if "Image" == searchType then -- 633
								do -- 634
									local _exp_0 = Path:getExt(f) -- 634
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 634
										if "." == f:sub(1, 1) then -- 635
											goto _continue_2 -- 635
										end -- 635
										suggestions[#suggestions + 1] = { -- 636
											f, -- 636
											"image", -- 636
											"field" -- 636
										} -- 636
									end -- 634
								end -- 634
								goto _continue_2 -- 637
							elseif "Font" == searchType then -- 638
								do -- 639
									local _exp_0 = Path:getExt(f) -- 639
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 639
										if "." == f:sub(1, 1) then -- 640
											goto _continue_2 -- 640
										end -- 640
										suggestions[#suggestions + 1] = { -- 641
											f, -- 641
											"font", -- 641
											"field" -- 641
										} -- 641
									end -- 639
								end -- 639
								goto _continue_2 -- 642
							end -- 633
							local _exp_0 = Path:getExt(f) -- 643
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 643
								local name = Path:getName(f) -- 644
								if "d" == Path:getExt(name) then -- 645
									goto _continue_2 -- 645
								end -- 645
								if "." == name:sub(1, 1) then -- 646
									goto _continue_2 -- 646
								end -- 646
								suggestions[#suggestions + 1] = { -- 647
									name, -- 647
									"module", -- 647
									"field" -- 647
								} -- 647
							end -- 643
							::_continue_2:: -- 633
						end -- 632
						local _list_2 = Content:getDirs(sPath) -- 648
						for _index_1 = 1, #_list_2 do -- 648
							local dir = _list_2[_index_1] -- 648
							if "." == dir:sub(1, 1) then -- 649
								goto _continue_3 -- 649
							end -- 649
							suggestions[#suggestions + 1] = { -- 650
								dir, -- 650
								"folder", -- 650
								"variable" -- 650
							} -- 650
							::_continue_3:: -- 649
						end -- 648
						::_continue_0:: -- 623
					end -- 622
					if item == "" and not searchType then -- 651
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 652
						for _index_0 = 1, #_list_1 do -- 652
							local _des_0 = _list_1[_index_0] -- 652
							local name = _des_0[1] -- 652
							suggestions[#suggestions + 1] = { -- 653
								name, -- 653
								"dora module", -- 653
								"function" -- 653
							} -- 653
						end -- 652
					end -- 651
					if #suggestions > 0 then -- 654
						do -- 655
							local _accum_0 = { } -- 655
							local _len_0 = 1 -- 655
							for _, v in pairs(_anon_func_4(suggestions)) do -- 655
								_accum_0[_len_0] = v -- 655
								_len_0 = _len_0 + 1 -- 655
							end -- 655
							suggestions = _accum_0 -- 655
						end -- 655
						return { -- 656
							success = true, -- 656
							suggestions = suggestions -- 656
						} -- 656
					else -- 658
						return { -- 658
							success = false -- 658
						} -- 658
					end -- 654
				until true -- 599
				if "tl" == lang or "lua" == lang then -- 660
					do -- 661
						local isTIC80 = CheckTIC80Code(content) -- 661
						if isTIC80 then -- 661
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 662
						end -- 661
					end -- 661
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 663
					if not line:match("[%.:]$") then -- 664
						local checkSet -- 665
						do -- 665
							local _tbl_0 = { } -- 665
							for _index_0 = 1, #suggestions do -- 665
								local _des_0 = suggestions[_index_0] -- 665
								local name = _des_0[1] -- 665
								_tbl_0[name] = true -- 665
							end -- 665
							checkSet = _tbl_0 -- 665
						end -- 665
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 666
						for _index_0 = 1, #_list_0 do -- 666
							local item = _list_0[_index_0] -- 666
							if not checkSet[item[1]] then -- 667
								suggestions[#suggestions + 1] = item -- 667
							end -- 667
						end -- 666
						for _index_0 = 1, #luaKeywords do -- 668
							local word = luaKeywords[_index_0] -- 668
							suggestions[#suggestions + 1] = { -- 669
								word, -- 669
								"keyword", -- 669
								"keyword" -- 669
							} -- 669
						end -- 668
						if lang == "tl" then -- 670
							for _index_0 = 1, #tealKeywords do -- 671
								local word = tealKeywords[_index_0] -- 671
								suggestions[#suggestions + 1] = { -- 672
									word, -- 672
									"keyword", -- 672
									"keyword" -- 672
								} -- 672
							end -- 671
						end -- 670
					end -- 664
					if #suggestions > 0 then -- 673
						return { -- 674
							success = true, -- 674
							suggestions = suggestions -- 674
						} -- 674
					end -- 673
				elseif "yue" == lang then -- 675
					local suggestions = { } -- 676
					local gotGlobals = false -- 677
					do -- 678
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 678
						if luaCodes then -- 678
							gotGlobals = true -- 679
							do -- 680
								local chainOp = line:match("[^%w_]([%.\\])$") -- 680
								if chainOp then -- 680
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 681
									if not withVar then -- 682
										return { -- 682
											success = false -- 682
										} -- 682
									end -- 682
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 683
								elseif line:match("^([%.\\])$") then -- 684
									return { -- 685
										success = false -- 685
									} -- 685
								end -- 680
							end -- 680
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 686
							for _index_0 = 1, #_list_0 do -- 686
								local item = _list_0[_index_0] -- 686
								suggestions[#suggestions + 1] = item -- 686
							end -- 686
							if #suggestions == 0 then -- 687
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 688
								for _index_0 = 1, #_list_1 do -- 688
									local item = _list_1[_index_0] -- 688
									suggestions[#suggestions + 1] = item -- 688
								end -- 688
							end -- 687
						end -- 678
					end -- 678
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 689
						local checkSet -- 690
						do -- 690
							local _tbl_0 = { } -- 690
							for _index_0 = 1, #suggestions do -- 690
								local _des_0 = suggestions[_index_0] -- 690
								local name = _des_0[1] -- 690
								_tbl_0[name] = true -- 690
							end -- 690
							checkSet = _tbl_0 -- 690
						end -- 690
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 691
						for _index_0 = 1, #_list_0 do -- 691
							local item = _list_0[_index_0] -- 691
							if not checkSet[item[1]] then -- 692
								suggestions[#suggestions + 1] = item -- 692
							end -- 692
						end -- 691
						if not gotGlobals then -- 693
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 694
							for _index_0 = 1, #_list_1 do -- 694
								local item = _list_1[_index_0] -- 694
								if not checkSet[item[1]] then -- 695
									suggestions[#suggestions + 1] = item -- 695
								end -- 695
							end -- 694
						end -- 693
						for _index_0 = 1, #yueKeywords do -- 696
							local word = yueKeywords[_index_0] -- 696
							if not checkSet[word] then -- 697
								suggestions[#suggestions + 1] = { -- 698
									word, -- 698
									"keyword", -- 698
									"keyword" -- 698
								} -- 698
							end -- 697
						end -- 696
					end -- 689
					if #suggestions > 0 then -- 699
						return { -- 700
							success = true, -- 700
							suggestions = suggestions -- 700
						} -- 700
					end -- 699
				elseif "xml" == lang then -- 701
					local items = xml.complete(content) -- 702
					if #items > 0 then -- 703
						local suggestions -- 704
						do -- 704
							local _accum_0 = { } -- 704
							local _len_0 = 1 -- 704
							for _index_0 = 1, #items do -- 704
								local _des_0 = items[_index_0] -- 704
								local label, insertText = _des_0[1], _des_0[2] -- 704
								_accum_0[_len_0] = { -- 705
									label, -- 705
									insertText, -- 705
									"field" -- 705
								} -- 705
								_len_0 = _len_0 + 1 -- 705
							end -- 704
							suggestions = _accum_0 -- 704
						end -- 704
						return { -- 706
							success = true, -- 706
							suggestions = suggestions -- 706
						} -- 706
					end -- 703
				end -- 660
			end -- 597
		end -- 597
	end -- 597
	return { -- 596
		success = false -- 596
	} -- 596
end) -- 596
HttpServer:upload("/upload", function(req, filename) -- 710
	do -- 711
		local _type_0 = type(req) -- 711
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 711
		if _tab_0 then -- 711
			local path -- 711
			do -- 711
				local _obj_0 = req.params -- 711
				local _type_1 = type(_obj_0) -- 711
				if "table" == _type_1 or "userdata" == _type_1 then -- 711
					path = _obj_0.path -- 711
				end -- 711
			end -- 711
			if path ~= nil then -- 711
				local uploadPath = Path(Content.writablePath, ".upload") -- 712
				if not Content:exist(uploadPath) then -- 713
					Content:mkdir(uploadPath) -- 714
				end -- 713
				local targetPath = Path(uploadPath, filename) -- 715
				Content:mkdir(Path:getPath(targetPath)) -- 716
				return targetPath -- 717
			end -- 711
		end -- 711
	end -- 711
	return nil -- 710
end, function(req, file) -- 718
	do -- 719
		local _type_0 = type(req) -- 719
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 719
		if _tab_0 then -- 719
			local path -- 719
			do -- 719
				local _obj_0 = req.params -- 719
				local _type_1 = type(_obj_0) -- 719
				if "table" == _type_1 or "userdata" == _type_1 then -- 719
					path = _obj_0.path -- 719
				end -- 719
			end -- 719
			if path ~= nil then -- 719
				path = Path(Content.writablePath, path) -- 720
				if Content:exist(path) then -- 721
					local uploadPath = Path(Content.writablePath, ".upload") -- 722
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 723
					Content:mkdir(Path:getPath(targetPath)) -- 724
					if Content:move(file, targetPath) then -- 725
						return true -- 726
					end -- 725
				end -- 721
			end -- 719
		end -- 719
	end -- 719
	return false -- 718
end) -- 708
HttpServer:post("/list", function(req) -- 729
	do -- 730
		local _type_0 = type(req) -- 730
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 730
		if _tab_0 then -- 730
			local path -- 730
			do -- 730
				local _obj_0 = req.body -- 730
				local _type_1 = type(_obj_0) -- 730
				if "table" == _type_1 or "userdata" == _type_1 then -- 730
					path = _obj_0.path -- 730
				end -- 730
			end -- 730
			if path ~= nil then -- 730
				if Content:exist(path) then -- 731
					local files = { } -- 732
					local visitAssets -- 733
					visitAssets = function(path, folder) -- 733
						local dirs = Content:getDirs(path) -- 734
						for _index_0 = 1, #dirs do -- 735
							local dir = dirs[_index_0] -- 735
							if dir:match("^%.") then -- 736
								goto _continue_0 -- 736
							end -- 736
							local current -- 737
							if folder == "" then -- 737
								current = dir -- 738
							else -- 740
								current = Path(folder, dir) -- 740
							end -- 737
							files[#files + 1] = current -- 741
							visitAssets(Path(path, dir), current) -- 742
							::_continue_0:: -- 736
						end -- 735
						local fs = Content:getFiles(path) -- 743
						for _index_0 = 1, #fs do -- 744
							local f = fs[_index_0] -- 744
							if f:match("^%.") then -- 745
								goto _continue_1 -- 745
							end -- 745
							if folder == "" then -- 746
								files[#files + 1] = f -- 747
							else -- 749
								files[#files + 1] = Path(folder, f) -- 749
							end -- 746
							::_continue_1:: -- 745
						end -- 744
					end -- 733
					visitAssets(path, "") -- 750
					if #files == 0 then -- 751
						files = nil -- 751
					end -- 751
					return { -- 752
						success = true, -- 752
						files = files -- 752
					} -- 752
				end -- 731
			end -- 730
		end -- 730
	end -- 730
	return { -- 729
		success = false -- 729
	} -- 729
end) -- 729
HttpServer:post("/info", function() -- 754
	local Entry = require("Script.Dev.Entry") -- 755
	local webProfiler, drawerWidth -- 756
	do -- 756
		local _obj_0 = Entry.getConfig() -- 756
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 756
	end -- 756
	local engineDev = Entry.getEngineDev() -- 757
	Entry.connectWebIDE() -- 758
	return { -- 760
		platform = App.platform, -- 760
		locale = App.locale, -- 761
		version = App.version, -- 762
		engineDev = engineDev, -- 763
		webProfiler = webProfiler, -- 764
		drawerWidth = drawerWidth -- 765
	} -- 759
end) -- 754
local ensureLLMConfigTable -- 767
ensureLLMConfigTable = function() -- 767
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 768
	if columns and #columns > 0 then -- 769
		local expected = { -- 771
			id = true, -- 771
			name = true, -- 772
			url = true, -- 773
			model = true, -- 774
			api_key = true, -- 775
			context_window = true, -- 776
			temperature = true, -- 777
			max_tokens = true, -- 778
			reasoning_effort = true, -- 779
			custom_options = true, -- 780
			supports_function_calling = true, -- 781
			active = true, -- 782
			created_at = true, -- 783
			updated_at = true -- 784
		} -- 770
		local existing = { } -- 786
		local valid = true -- 787
		for _index_0 = 1, #columns do -- 788
			local row = columns[_index_0] -- 788
			local columnName = tostring(row[2]) -- 789
			existing[columnName] = true -- 790
			if not expected[columnName] then -- 791
				valid = false -- 792
				break -- 793
			end -- 791
		end -- 788
		if valid then -- 794
			if not existing.context_window then -- 795
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 796
			end -- 795
			if not existing.temperature then -- 797
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 798
			end -- 797
			if not existing.max_tokens then -- 799
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 800
			end -- 799
			if not existing.reasoning_effort then -- 801
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 802
			end -- 801
			if not existing.custom_options then -- 803
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 804
			end -- 803
			if not existing.supports_function_calling then -- 805
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 806
			end -- 805
		else -- 808
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 808
		end -- 794
	end -- 769
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
	]]) -- 809
end -- 767
local normalizeContextWindow -- 828
normalizeContextWindow = function(value) -- 828
	local contextWindow = tonumber(value) -- 829
	if contextWindow == nil or contextWindow < 64000 then -- 830
		return 64000 -- 831
	end -- 830
	return math.max(64000, math.floor(contextWindow)) -- 832
end -- 828
local normalizeTemperature -- 834
normalizeTemperature = function(value) -- 834
	local temperature = tonumber(value) -- 835
	if temperature == nil then -- 836
		return 0.1 -- 837
	end -- 836
	return math.max(0, math.min(2, temperature)) -- 838
end -- 834
local normalizeMaxTokens -- 840
normalizeMaxTokens = function(value) -- 840
	local maxTokens = tonumber(value) -- 841
	if maxTokens == nil or maxTokens < 1 then -- 842
		return 8192 -- 843
	end -- 842
	return math.max(1, math.floor(maxTokens)) -- 844
end -- 840
local normalizeReasoningEffort -- 846
normalizeReasoningEffort = function(value) -- 846
	if value == nil then -- 847
		return "" -- 848
	end -- 847
	local effort = tostring(value) -- 849
	return effort:match("^%s*(.-)%s*$") or "" -- 850
end -- 846
local normalizeCustomOptions -- 852
normalizeCustomOptions = function(value) -- 852
	if value == nil then -- 853
		return "" -- 854
	end -- 853
	local options = tostring(value) -- 855
	options = options:match("^%s*(.-)%s*$") or "" -- 856
	return options -- 857
end -- 852
local validateCustomOptions -- 859
validateCustomOptions = function(value) -- 859
	local options = normalizeCustomOptions(value) -- 860
	if options == "" then -- 861
		return true -- 861
	end -- 861
	if not options:match("^%s*{") then -- 862
		return false -- 862
	end -- 862
	local decoded = json.decode(options) -- 863
	return type(decoded) == "table" -- 864
end -- 859
HttpServer:post("/llm/list", function() -- 866
	ensureLLMConfigTable() -- 867
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 868
	local items -- 872
	if rows and #rows > 0 then -- 872
		local _accum_0 = { } -- 873
		local _len_0 = 1 -- 873
		for _index_0 = 1, #rows do -- 873
			local _des_0 = rows[_index_0] -- 873
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11], _des_0[12] -- 873
			_accum_0[_len_0] = { -- 874
				id = id, -- 874
				name = name, -- 874
				url = url, -- 874
				model = model, -- 874
				key = key, -- 874
				contextWindow = normalizeContextWindow(contextWindow), -- 874
				temperature = normalizeTemperature(temperature), -- 874
				maxTokens = normalizeMaxTokens(maxTokens), -- 874
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 874
				customOptions = normalizeCustomOptions(customOptions), -- 874
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 874
				active = active ~= 0 -- 874
			} -- 874
			_len_0 = _len_0 + 1 -- 874
		end -- 873
		items = _accum_0 -- 872
	end -- 872
	return { -- 875
		success = true, -- 875
		items = items -- 875
	} -- 875
end) -- 866
HttpServer:post("/llm/create", function(req) -- 877
	ensureLLMConfigTable() -- 878
	do -- 879
		local _type_0 = type(req) -- 879
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 879
		if _tab_0 then -- 879
			local body = req.body -- 879
			if body ~= nil then -- 879
				local name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 880
				local now = os.time() -- 881
				if name == nil or url == nil or model == nil or key == nil then -- 882
					return { -- 883
						success = false, -- 883
						message = "invalid" -- 883
					} -- 883
				end -- 882
				contextWindow = normalizeContextWindow(contextWindow) -- 884
				temperature = normalizeTemperature(temperature) -- 885
				maxTokens = normalizeMaxTokens(maxTokens) -- 886
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 887
				customOptions = normalizeCustomOptions(customOptions) -- 888
				if not validateCustomOptions(customOptions) then -- 889
					return { -- 889
						success = false, -- 889
						message = "customOptions must be a JSON object" -- 889
					} -- 889
				end -- 889
				if supportsFunctionCalling == false then -- 890
					supportsFunctionCalling = 0 -- 890
				else -- 890
					supportsFunctionCalling = 1 -- 890
				end -- 890
				if active then -- 891
					active = 1 -- 891
				else -- 891
					active = 0 -- 891
				end -- 891
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 898
					tostring(name), -- 898
					tostring(url), -- 899
					tostring(model), -- 900
					tostring(key), -- 901
					contextWindow, -- 902
					temperature, -- 903
					maxTokens, -- 904
					reasoningEffort, -- 905
					customOptions, -- 906
					supportsFunctionCalling, -- 907
					active, -- 908
					now, -- 909
					now -- 910
				}) -- 892
				return { -- 912
					success = affected >= 0 -- 912
				} -- 912
			end -- 879
		end -- 879
	end -- 879
	return { -- 877
		success = false, -- 877
		message = "invalid" -- 877
	} -- 877
end) -- 877
HttpServer:post("/llm/update", function(req) -- 914
	ensureLLMConfigTable() -- 915
	do -- 916
		local _type_0 = type(req) -- 916
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 916
		if _tab_0 then -- 916
			local body = req.body -- 916
			if body ~= nil then -- 916
				local id, name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 917
				local now = os.time() -- 918
				id = tonumber(id) -- 919
				if id == nil then -- 920
					return { -- 921
						success = false, -- 921
						message = "invalid" -- 921
					} -- 921
				end -- 920
				contextWindow = normalizeContextWindow(contextWindow) -- 922
				temperature = normalizeTemperature(temperature) -- 923
				maxTokens = normalizeMaxTokens(maxTokens) -- 924
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 925
				customOptions = normalizeCustomOptions(customOptions) -- 926
				if not validateCustomOptions(customOptions) then -- 927
					return { -- 927
						success = false, -- 927
						message = "customOptions must be a JSON object" -- 927
					} -- 927
				end -- 927
				if supportsFunctionCalling == false then -- 928
					supportsFunctionCalling = 0 -- 928
				else -- 928
					supportsFunctionCalling = 1 -- 928
				end -- 928
				if active then -- 929
					active = 1 -- 929
				else -- 929
					active = 0 -- 929
				end -- 929
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 934
					tostring(name), -- 934
					tostring(url), -- 935
					tostring(model), -- 936
					tostring(key), -- 937
					contextWindow, -- 938
					temperature, -- 939
					maxTokens, -- 940
					reasoningEffort, -- 941
					customOptions, -- 942
					supportsFunctionCalling, -- 943
					active, -- 944
					now, -- 945
					id -- 946
				}) -- 930
				return { -- 948
					success = affected >= 0 -- 948
				} -- 948
			end -- 916
		end -- 916
	end -- 916
	return { -- 914
		success = false, -- 914
		message = "invalid" -- 914
	} -- 914
end) -- 914
HttpServer:post("/llm/delete", function(req) -- 950
	ensureLLMConfigTable() -- 951
	do -- 952
		local _type_0 = type(req) -- 952
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 952
		if _tab_0 then -- 952
			local id -- 952
			do -- 952
				local _obj_0 = req.body -- 952
				local _type_1 = type(_obj_0) -- 952
				if "table" == _type_1 or "userdata" == _type_1 then -- 952
					id = _obj_0.id -- 952
				end -- 952
			end -- 952
			if id ~= nil then -- 952
				id = tonumber(id) -- 953
				if id == nil then -- 954
					return { -- 955
						success = false, -- 955
						message = "invalid" -- 955
					} -- 955
				end -- 954
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 956
					id -- 956
				}) -- 956
				return { -- 957
					success = affected >= 0 -- 957
				} -- 957
			end -- 952
		end -- 952
	end -- 952
	return { -- 950
		success = false, -- 950
		message = "invalid" -- 950
	} -- 950
end) -- 950
HttpServer:post("/new", function(req) -- 959
	do -- 960
		local _type_0 = type(req) -- 960
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 960
		if _tab_0 then -- 960
			local path -- 960
			do -- 960
				local _obj_0 = req.body -- 960
				local _type_1 = type(_obj_0) -- 960
				if "table" == _type_1 or "userdata" == _type_1 then -- 960
					path = _obj_0.path -- 960
				end -- 960
			end -- 960
			local content -- 960
			do -- 960
				local _obj_0 = req.body -- 960
				local _type_1 = type(_obj_0) -- 960
				if "table" == _type_1 or "userdata" == _type_1 then -- 960
					content = _obj_0.content -- 960
				end -- 960
			end -- 960
			local folder -- 960
			do -- 960
				local _obj_0 = req.body -- 960
				local _type_1 = type(_obj_0) -- 960
				if "table" == _type_1 or "userdata" == _type_1 then -- 960
					folder = _obj_0.folder -- 960
				end -- 960
			end -- 960
			if path ~= nil and content ~= nil and folder ~= nil then -- 960
				if Content:exist(path) then -- 961
					return { -- 962
						success = false, -- 962
						message = "TargetExisted" -- 962
					} -- 962
				end -- 961
				local parent = Path:getPath(path) -- 963
				local files = Content:getFiles(parent) -- 964
				if folder then -- 965
					local name = Path:getFilename(path):lower() -- 966
					for _index_0 = 1, #files do -- 967
						local file = files[_index_0] -- 967
						if name == Path:getFilename(file):lower() then -- 968
							return { -- 969
								success = false, -- 969
								message = "TargetExisted" -- 969
							} -- 969
						end -- 968
					end -- 967
					if Content:mkdir(path) then -- 970
						return { -- 971
							success = true -- 971
						} -- 971
					end -- 970
				else -- 973
					local name = Path:getName(path):lower() -- 973
					for _index_0 = 1, #files do -- 974
						local file = files[_index_0] -- 974
						if name == Path:getName(file):lower() then -- 975
							local ext = Path:getExt(file) -- 976
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 977
								goto _continue_0 -- 978
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 979
								goto _continue_0 -- 980
							end -- 977
							return { -- 981
								success = false, -- 981
								message = "SourceExisted" -- 981
							} -- 981
						end -- 975
						::_continue_0:: -- 975
					end -- 974
					if Content:save(path, content) then -- 982
						return { -- 983
							success = true -- 983
						} -- 983
					end -- 982
				end -- 965
			end -- 960
		end -- 960
	end -- 960
	return { -- 959
		success = false, -- 959
		message = "Failed" -- 959
	} -- 959
end) -- 959
HttpServer:post("/delete", function(req) -- 985
	do -- 986
		local _type_0 = type(req) -- 986
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 986
		if _tab_0 then -- 986
			local path -- 986
			do -- 986
				local _obj_0 = req.body -- 986
				local _type_1 = type(_obj_0) -- 986
				if "table" == _type_1 or "userdata" == _type_1 then -- 986
					path = _obj_0.path -- 986
				end -- 986
			end -- 986
			if path ~= nil then -- 986
				if Content:exist(path) then -- 987
					local projectRoot -- 988
					if Content:isdir(path) and isProjectRootDir(path) then -- 988
						projectRoot = path -- 988
					else -- 988
						projectRoot = nil -- 988
					end -- 988
					local parent = Path:getPath(path) -- 989
					local files = Content:getFiles(parent) -- 990
					local name = Path:getName(path):lower() -- 991
					local ext = Path:getExt(path) -- 992
					for _index_0 = 1, #files do -- 993
						local file = files[_index_0] -- 993
						if name == Path:getName(file):lower() then -- 994
							local _exp_0 = Path:getExt(file) -- 995
							if "tl" == _exp_0 then -- 995
								if ("vs" == ext) then -- 995
									Content:remove(Path(parent, file)) -- 996
								end -- 995
							elseif "lua" == _exp_0 then -- 997
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 997
									Content:remove(Path(parent, file)) -- 998
								end -- 997
							end -- 995
						end -- 994
					end -- 993
					if Content:remove(path) then -- 999
						if projectRoot then -- 1000
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1001
						end -- 1000
						return { -- 1002
							success = true -- 1002
						} -- 1002
					end -- 999
				end -- 987
			end -- 986
		end -- 986
	end -- 986
	return { -- 985
		success = false -- 985
	} -- 985
end) -- 985
HttpServer:post("/rename", function(req) -- 1004
	do -- 1005
		local _type_0 = type(req) -- 1005
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1005
		if _tab_0 then -- 1005
			local old -- 1005
			do -- 1005
				local _obj_0 = req.body -- 1005
				local _type_1 = type(_obj_0) -- 1005
				if "table" == _type_1 or "userdata" == _type_1 then -- 1005
					old = _obj_0.old -- 1005
				end -- 1005
			end -- 1005
			local new -- 1005
			do -- 1005
				local _obj_0 = req.body -- 1005
				local _type_1 = type(_obj_0) -- 1005
				if "table" == _type_1 or "userdata" == _type_1 then -- 1005
					new = _obj_0.new -- 1005
				end -- 1005
			end -- 1005
			if old ~= nil and new ~= nil then -- 1005
				if Content:exist(old) and not Content:exist(new) then -- 1006
					local renamedDir = Content:isdir(old) -- 1007
					local parent = Path:getPath(new) -- 1008
					local files = Content:getFiles(parent) -- 1009
					if renamedDir then -- 1010
						local name = Path:getFilename(new):lower() -- 1011
						for _index_0 = 1, #files do -- 1012
							local file = files[_index_0] -- 1012
							if name == Path:getFilename(file):lower() then -- 1013
								return { -- 1014
									success = false -- 1014
								} -- 1014
							end -- 1013
						end -- 1012
					else -- 1016
						local name = Path:getName(new):lower() -- 1016
						local ext = Path:getExt(new) -- 1017
						for _index_0 = 1, #files do -- 1018
							local file = files[_index_0] -- 1018
							if name == Path:getName(file):lower() then -- 1019
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1020
									goto _continue_0 -- 1021
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1022
									goto _continue_0 -- 1023
								end -- 1020
								return { -- 1024
									success = false -- 1024
								} -- 1024
							end -- 1019
							::_continue_0:: -- 1019
						end -- 1018
					end -- 1010
					if Content:move(old, new) then -- 1025
						if renamedDir then -- 1026
							AgentSession.renameSessionsByProjectRoot(old, new) -- 1027
						end -- 1026
						local newParent = Path:getPath(new) -- 1028
						parent = Path:getPath(old) -- 1029
						files = Content:getFiles(parent) -- 1030
						local newName = Path:getName(new) -- 1031
						local oldName = Path:getName(old) -- 1032
						local name = oldName:lower() -- 1033
						local ext = Path:getExt(old) -- 1034
						for _index_0 = 1, #files do -- 1035
							local file = files[_index_0] -- 1035
							if name == Path:getName(file):lower() then -- 1036
								local _exp_0 = Path:getExt(file) -- 1037
								if "tl" == _exp_0 then -- 1037
									if ("vs" == ext) then -- 1037
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1038
									end -- 1037
								elseif "lua" == _exp_0 then -- 1039
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1039
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1040
									end -- 1039
								end -- 1037
							end -- 1036
						end -- 1035
						return { -- 1041
							success = true -- 1041
						} -- 1041
					end -- 1025
				end -- 1006
			end -- 1005
		end -- 1005
	end -- 1005
	return { -- 1004
		success = false -- 1004
	} -- 1004
end) -- 1004
HttpServer:post("/exist", function(req) -- 1043
	do -- 1044
		local _type_0 = type(req) -- 1044
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1044
		if _tab_0 then -- 1044
			local file -- 1044
			do -- 1044
				local _obj_0 = req.body -- 1044
				local _type_1 = type(_obj_0) -- 1044
				if "table" == _type_1 or "userdata" == _type_1 then -- 1044
					file = _obj_0.file -- 1044
				end -- 1044
			end -- 1044
			if file ~= nil then -- 1044
				do -- 1045
					local projFile = req.body.projFile -- 1045
					if projFile then -- 1045
						local projDir = getProjectDirFromFile(projFile) -- 1046
						if projDir then -- 1046
							local scriptDir = Path(projDir, "Script") -- 1047
							local searchPaths = Content.searchPaths -- 1048
							if Content:exist(scriptDir) then -- 1049
								Content:addSearchPath(scriptDir) -- 1049
							end -- 1049
							if Content:exist(projDir) then -- 1050
								Content:addSearchPath(projDir) -- 1050
							end -- 1050
							local _ <close> = setmetatable({ }, { -- 1051
								__close = function() -- 1051
									Content.searchPaths = searchPaths -- 1051
								end -- 1051
							}) -- 1051
							return { -- 1052
								success = Content:exist(file) -- 1052
							} -- 1052
						end -- 1046
					end -- 1045
				end -- 1045
				return { -- 1053
					success = Content:exist(file) -- 1053
				} -- 1053
			end -- 1044
		end -- 1044
	end -- 1044
	return { -- 1043
		success = false -- 1043
	} -- 1043
end) -- 1043
HttpServer:postSchedule("/read", function(req) -- 1055
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
				local readFile -- 1057
				readFile = function() -- 1057
					if Content:exist(path) then -- 1058
						local content = Content:loadAsync(path) -- 1059
						if content then -- 1059
							return { -- 1060
								content = content, -- 1060
								success = true, -- 1060
								fullPath = Content:getFullPath(path) -- 1060
							} -- 1060
						end -- 1059
					end -- 1058
					return nil -- 1057
				end -- 1057
				do -- 1061
					local projFile = req.body.projFile -- 1061
					if projFile then -- 1061
						local projDir = getProjectDirFromFile(projFile) -- 1062
						if projDir then -- 1062
							local scriptDir = Path(projDir, "Script") -- 1063
							local searchPaths = Content.searchPaths -- 1064
							if Content:exist(scriptDir) then -- 1065
								Content:addSearchPath(scriptDir) -- 1065
							end -- 1065
							if Content:exist(projDir) then -- 1066
								Content:addSearchPath(projDir) -- 1066
							end -- 1066
							local _ <close> = setmetatable({ }, { -- 1067
								__close = function() -- 1067
									Content.searchPaths = searchPaths -- 1067
								end -- 1067
							}) -- 1067
							local result = readFile() -- 1068
							if result then -- 1068
								return result -- 1068
							end -- 1068
						end -- 1062
					end -- 1061
				end -- 1061
				local result = readFile() -- 1069
				if result then -- 1069
					return result -- 1069
				end -- 1069
			end -- 1056
		end -- 1056
	end -- 1056
	return { -- 1055
		success = false -- 1055
	} -- 1055
end) -- 1055
HttpServer:get("/read-sync", function(req) -- 1071
	do -- 1072
		local _type_0 = type(req) -- 1072
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1072
		if _tab_0 then -- 1072
			local params = req.params -- 1072
			if params ~= nil then -- 1072
				local path = params.path -- 1073
				local exts -- 1074
				if params.exts then -- 1074
					local _accum_0 = { } -- 1075
					local _len_0 = 1 -- 1075
					for ext in params.exts:gmatch("[^|]*") do -- 1075
						_accum_0[_len_0] = ext -- 1076
						_len_0 = _len_0 + 1 -- 1076
					end -- 1075
					exts = _accum_0 -- 1074
				else -- 1077
					exts = { -- 1077
						"" -- 1077
					} -- 1077
				end -- 1074
				local readFile -- 1078
				readFile = function() -- 1078
					for _index_0 = 1, #exts do -- 1079
						local ext = exts[_index_0] -- 1079
						local targetPath = path .. ext -- 1080
						if Content:exist(targetPath) then -- 1081
							local content = Content:load(targetPath) -- 1082
							if content then -- 1082
								return { -- 1083
									content = content, -- 1083
									success = true, -- 1083
									fullPath = Content:getFullPath(targetPath) -- 1083
								} -- 1083
							end -- 1082
						end -- 1081
					end -- 1079
					return nil -- 1078
				end -- 1078
				local searchPaths = Content.searchPaths -- 1084
				local _ <close> = setmetatable({ }, { -- 1085
					__close = function() -- 1085
						Content.searchPaths = searchPaths -- 1085
					end -- 1085
				}) -- 1085
				do -- 1086
					local projFile = req.params.projFile -- 1086
					if projFile then -- 1086
						local projDir = getProjectDirFromFile(projFile) -- 1087
						if projDir then -- 1087
							local scriptDir = Path(projDir, "Script") -- 1088
							if Content:exist(scriptDir) then -- 1089
								Content:addSearchPath(scriptDir) -- 1089
							end -- 1089
							if Content:exist(projDir) then -- 1090
								Content:addSearchPath(projDir) -- 1090
							end -- 1090
						else -- 1092
							projDir = Path:getPath(projFile) -- 1092
							if Content:exist(projDir) then -- 1093
								Content:addSearchPath(projDir) -- 1093
							end -- 1093
						end -- 1087
					end -- 1086
				end -- 1086
				local result = readFile() -- 1094
				if result then -- 1094
					return result -- 1094
				end -- 1094
			end -- 1072
		end -- 1072
	end -- 1072
	return { -- 1071
		success = false -- 1071
	} -- 1071
end) -- 1071
local compileFileAsync -- 1096
compileFileAsync = function(inputFile, sourceCodes) -- 1096
	local file = inputFile -- 1097
	local searchPath -- 1098
	do -- 1098
		local dir = getProjectDirFromFile(inputFile) -- 1098
		if dir then -- 1098
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 1099
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1100
		else -- 1102
			file = Path:getRelative(inputFile, Content.writablePath) -- 1102
			if file:sub(1, 2) == ".." then -- 1103
				file = Path:getRelative(inputFile, Content.assetPath) -- 1104
			end -- 1103
			searchPath = "" -- 1105
		end -- 1098
	end -- 1098
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1106
	local yueext = yue.options.extension -- 1107
	local resultCodes = nil -- 1108
	local resultError = nil -- 1109
	do -- 1110
		local _exp_0 = Path:getExt(inputFile) -- 1110
		if yueext == _exp_0 then -- 1110
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1111
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1112
				if not codes then -- 1113
					resultError = err -- 1114
					return -- 1115
				end -- 1113
				local extraGlobal -- 1116
				if isTIC80 then -- 1116
					extraGlobal = tic80APIs -- 1116
				else -- 1116
					extraGlobal = nil -- 1116
				end -- 1116
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1117
				if not success then -- 1118
					resultError = message -- 1119
					return -- 1120
				end -- 1118
				if codes == "" then -- 1121
					resultCodes = "" -- 1122
					return nil -- 1123
				end -- 1121
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1124
				return resultCodes -- 1125
			end, function(success) -- 1112
				if not success then -- 1126
					Content:remove(outputFile) -- 1127
					if resultCodes == nil then -- 1128
						resultCodes = false -- 1129
					end -- 1128
				end -- 1126
			end) -- 1112
		elseif "tl" == _exp_0 then -- 1130
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1131
			if isTIC80 then -- 1132
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1133
			end -- 1132
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1134
			if codes then -- 1134
				if isTIC80 then -- 1135
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1136
				end -- 1135
				resultCodes = codes -- 1137
				Content:saveAsync(outputFile, codes) -- 1138
			else -- 1140
				Content:remove(outputFile) -- 1140
				resultCodes = false -- 1141
				resultError = err -- 1142
			end -- 1134
		elseif "xml" == _exp_0 then -- 1143
			local codes, err = xml.tolua(sourceCodes) -- 1144
			if codes then -- 1144
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1145
				Content:saveAsync(outputFile, resultCodes) -- 1146
			else -- 1148
				Content:remove(outputFile) -- 1148
				resultCodes = false -- 1149
				resultError = err -- 1150
			end -- 1144
		end -- 1110
	end -- 1110
	wait(function() -- 1151
		return resultCodes ~= nil -- 1151
	end) -- 1151
	if resultCodes then -- 1152
		return resultCodes -- 1153
	else -- 1155
		return nil, resultError -- 1155
	end -- 1152
	return nil -- 1096
end -- 1096
HttpServer:postSchedule("/write", function(req) -- 1157
	do -- 1158
		local _type_0 = type(req) -- 1158
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1158
		if _tab_0 then -- 1158
			local path -- 1158
			do -- 1158
				local _obj_0 = req.body -- 1158
				local _type_1 = type(_obj_0) -- 1158
				if "table" == _type_1 or "userdata" == _type_1 then -- 1158
					path = _obj_0.path -- 1158
				end -- 1158
			end -- 1158
			local content -- 1158
			do -- 1158
				local _obj_0 = req.body -- 1158
				local _type_1 = type(_obj_0) -- 1158
				if "table" == _type_1 or "userdata" == _type_1 then -- 1158
					content = _obj_0.content -- 1158
				end -- 1158
			end -- 1158
			if path ~= nil and content ~= nil then -- 1158
				if Content:saveAsync(path, content) then -- 1159
					do -- 1160
						local _exp_0 = Path:getExt(path) -- 1160
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1160
							if '' == Path:getExt(Path:getName(path)) then -- 1161
								local resultCodes = compileFileAsync(path, content) -- 1162
								return { -- 1163
									success = true, -- 1163
									resultCodes = resultCodes -- 1163
								} -- 1163
							end -- 1161
						end -- 1160
					end -- 1160
					return { -- 1164
						success = true -- 1164
					} -- 1164
				end -- 1159
			end -- 1158
		end -- 1158
	end -- 1158
	return { -- 1157
		success = false -- 1157
	} -- 1157
end) -- 1157
HttpServer:postSchedule("/build", function(req) -- 1166
	do -- 1167
		local _type_0 = type(req) -- 1167
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1167
		if _tab_0 then -- 1167
			local path -- 1167
			do -- 1167
				local _obj_0 = req.body -- 1167
				local _type_1 = type(_obj_0) -- 1167
				if "table" == _type_1 or "userdata" == _type_1 then -- 1167
					path = _obj_0.path -- 1167
				end -- 1167
			end -- 1167
			if path ~= nil then -- 1167
				local _exp_0 = Path:getExt(path) -- 1168
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1168
					if '' == Path:getExt(Path:getName(path)) then -- 1169
						local content = Content:loadAsync(path) -- 1170
						if content then -- 1170
							local resultCodes = compileFileAsync(path, content) -- 1171
							if resultCodes then -- 1171
								return { -- 1172
									success = true, -- 1172
									resultCodes = resultCodes -- 1172
								} -- 1172
							end -- 1171
						end -- 1170
					end -- 1169
				end -- 1168
			end -- 1167
		end -- 1167
	end -- 1167
	return { -- 1166
		success = false -- 1166
	} -- 1166
end) -- 1166
local extentionLevels = { -- 1175
	vs = 2, -- 1175
	bl = 2, -- 1176
	ts = 1, -- 1177
	tsx = 1, -- 1178
	tl = 1, -- 1179
	yue = 1, -- 1180
	xml = 1, -- 1181
	lua = 0 -- 1182
} -- 1174
HttpServer:post("/assets", function() -- 1184
	local Entry = require("Script.Dev.Entry") -- 1187
	local engineDev = Entry.getEngineDev() -- 1188
	local visitAssets -- 1189
	visitAssets = function(path, tag) -- 1189
		local isWorkspace = tag == "Workspace" -- 1190
		local builtin -- 1191
		if tag == "Builtin" then -- 1191
			builtin = true -- 1191
		else -- 1191
			builtin = nil -- 1191
		end -- 1191
		local children = nil -- 1192
		local dirs = Content:getDirs(path) -- 1193
		for _index_0 = 1, #dirs do -- 1194
			local dir = dirs[_index_0] -- 1194
			if isWorkspace then -- 1195
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1196
					goto _continue_0 -- 1197
				end -- 1196
			elseif dir == ".git" then -- 1198
				goto _continue_0 -- 1199
			end -- 1195
			if not children then -- 1200
				children = { } -- 1200
			end -- 1200
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1201
			::_continue_0:: -- 1195
		end -- 1194
		local files = Content:getFiles(path) -- 1202
		local names = { } -- 1203
		for _index_0 = 1, #files do -- 1204
			local file = files[_index_0] -- 1204
			if file:match("^%.") then -- 1205
				goto _continue_1 -- 1205
			end -- 1205
			local name = Path:getName(file) -- 1206
			local ext = names[name] -- 1207
			if ext then -- 1207
				local lv1 -- 1208
				do -- 1208
					local _exp_0 = extentionLevels[ext] -- 1208
					if _exp_0 ~= nil then -- 1208
						lv1 = _exp_0 -- 1208
					else -- 1208
						lv1 = -1 -- 1208
					end -- 1208
				end -- 1208
				ext = Path:getExt(file) -- 1209
				local lv2 -- 1210
				do -- 1210
					local _exp_0 = extentionLevels[ext] -- 1210
					if _exp_0 ~= nil then -- 1210
						lv2 = _exp_0 -- 1210
					else -- 1210
						lv2 = -1 -- 1210
					end -- 1210
				end -- 1210
				if lv2 > lv1 then -- 1211
					names[name] = ext -- 1212
				elseif lv2 == lv1 then -- 1213
					names[name .. '.' .. ext] = "" -- 1214
				end -- 1211
			else -- 1216
				ext = Path:getExt(file) -- 1216
				if not extentionLevels[ext] then -- 1217
					names[file] = "" -- 1218
				else -- 1220
					names[name] = ext -- 1220
				end -- 1217
			end -- 1207
			::_continue_1:: -- 1205
		end -- 1204
		do -- 1221
			local _accum_0 = { } -- 1221
			local _len_0 = 1 -- 1221
			for name, ext in pairs(names) do -- 1221
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1221
				_len_0 = _len_0 + 1 -- 1221
			end -- 1221
			files = _accum_0 -- 1221
		end -- 1221
		for _index_0 = 1, #files do -- 1222
			local file = files[_index_0] -- 1222
			if not children then -- 1223
				children = { } -- 1223
			end -- 1223
			children[#children + 1] = { -- 1225
				key = Path(path, file), -- 1225
				dir = false, -- 1226
				title = file, -- 1227
				builtin = builtin -- 1228
			} -- 1224
		end -- 1222
		if children then -- 1230
			table.sort(children, function(a, b) -- 1231
				if a.dir == b.dir then -- 1232
					return a.title < b.title -- 1233
				else -- 1235
					return a.dir -- 1235
				end -- 1232
			end) -- 1231
		end -- 1230
		if isWorkspace and children then -- 1236
			return children -- 1237
		else -- 1239
			return { -- 1240
				key = path, -- 1240
				dir = true, -- 1241
				title = Path:getFilename(path), -- 1242
				builtin = builtin, -- 1243
				children = children -- 1244
			} -- 1239
		end -- 1236
	end -- 1189
	local zh = (App.locale:match("^zh") ~= nil) -- 1246
	return { -- 1248
		key = Content.writablePath, -- 1248
		dir = true, -- 1249
		root = true, -- 1250
		title = "Assets", -- 1251
		children = (function() -- 1253
			local _tab_0 = { -- 1253
				{ -- 1254
					key = Path(Content.assetPath), -- 1254
					dir = true, -- 1255
					builtin = true, -- 1256
					title = zh and "内置资源" or "Built-in", -- 1257
					children = { -- 1259
						(function() -- 1259
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1259
							_with_0.title = zh and "说明文档" or "Readme" -- 1260
							return _with_0 -- 1259
						end)(), -- 1259
						(function() -- 1261
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1261
							_with_0.title = zh and "接口文档" or "API Doc" -- 1262
							return _with_0 -- 1261
						end)(), -- 1261
						(function() -- 1263
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1263
							_with_0.title = zh and "开发工具" or "Tools" -- 1264
							return _with_0 -- 1263
						end)(), -- 1263
						(function() -- 1265
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1265
							_with_0.title = zh and "字体" or "Font" -- 1266
							return _with_0 -- 1265
						end)(), -- 1265
						(function() -- 1267
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1267
							_with_0.title = zh and "程序库" or "Lib" -- 1268
							if engineDev then -- 1269
								local _list_0 = _with_0.children -- 1270
								for _index_0 = 1, #_list_0 do -- 1270
									local child = _list_0[_index_0] -- 1270
									if not (child.title == "Dora") then -- 1271
										goto _continue_0 -- 1271
									end -- 1271
									local title = zh and "zh-Hans" or "en" -- 1272
									do -- 1273
										local _accum_0 = { } -- 1273
										local _len_0 = 1 -- 1273
										local _list_1 = child.children -- 1273
										for _index_1 = 1, #_list_1 do -- 1273
											local c = _list_1[_index_1] -- 1273
											if c.title ~= title then -- 1273
												_accum_0[_len_0] = c -- 1273
												_len_0 = _len_0 + 1 -- 1273
											end -- 1273
										end -- 1273
										child.children = _accum_0 -- 1273
									end -- 1273
									break -- 1274
									::_continue_0:: -- 1271
								end -- 1270
							else -- 1276
								local _accum_0 = { } -- 1276
								local _len_0 = 1 -- 1276
								local _list_0 = _with_0.children -- 1276
								for _index_0 = 1, #_list_0 do -- 1276
									local child = _list_0[_index_0] -- 1276
									if child.title ~= "Dora" then -- 1276
										_accum_0[_len_0] = child -- 1276
										_len_0 = _len_0 + 1 -- 1276
									end -- 1276
								end -- 1276
								_with_0.children = _accum_0 -- 1276
							end -- 1269
							return _with_0 -- 1267
						end)(), -- 1267
						(function() -- 1277
							if engineDev then -- 1277
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1278
								local _obj_0 = _with_0.children -- 1279
								_obj_0[#_obj_0 + 1] = { -- 1280
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1280
									dir = false, -- 1281
									builtin = true, -- 1282
									title = "init.yue" -- 1283
								} -- 1279
								return _with_0 -- 1278
							end -- 1277
						end)() -- 1277
					} -- 1258
				} -- 1253
			} -- 1287
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1287
			local _idx_0 = #_tab_0 + 1 -- 1287
			for _index_0 = 1, #_obj_0 do -- 1287
				local _value_0 = _obj_0[_index_0] -- 1287
				_tab_0[_idx_0] = _value_0 -- 1287
				_idx_0 = _idx_0 + 1 -- 1287
			end -- 1287
			return _tab_0 -- 1253
		end)() -- 1252
	} -- 1247
end) -- 1184
HttpServer:post("/entry/list", function() -- 1291
	local Entry = require("Script.Dev.Entry") -- 1292
	local res = Entry.getLaunchEntries() -- 1293
	res.success = true -- 1294
	return res -- 1295
end) -- 1291
HttpServer:post("/run/status", function() -- 1297
	local Entry = require("Script.Dev.Entry") -- 1298
	return Entry.getCurrentEntryStatus() -- 1299
end) -- 1297
HttpServer:postSchedule("/run", function(req) -- 1301
	do -- 1302
		local _type_0 = type(req) -- 1302
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1302
		if _tab_0 then -- 1302
			local file -- 1302
			do -- 1302
				local _obj_0 = req.body -- 1302
				local _type_1 = type(_obj_0) -- 1302
				if "table" == _type_1 or "userdata" == _type_1 then -- 1302
					file = _obj_0.file -- 1302
				end -- 1302
			end -- 1302
			local asProj -- 1302
			do -- 1302
				local _obj_0 = req.body -- 1302
				local _type_1 = type(_obj_0) -- 1302
				if "table" == _type_1 or "userdata" == _type_1 then -- 1302
					asProj = _obj_0.asProj -- 1302
				end -- 1302
			end -- 1302
			if file ~= nil and asProj ~= nil then -- 1302
				if not Content:isAbsolutePath(file) then -- 1303
					local devFile = Path(Content.writablePath, file) -- 1304
					if Content:exist(devFile) then -- 1305
						file = devFile -- 1305
					end -- 1305
				end -- 1303
				local Entry = require("Script.Dev.Entry") -- 1306
				local workDir -- 1307
				if asProj then -- 1308
					workDir = getProjectDirFromFile(file) -- 1309
					if workDir then -- 1309
						Entry.allClear() -- 1310
						local target = Path(workDir, "init") -- 1311
						local success, err = Entry.enterEntryAsync({ -- 1312
							entryName = "Project", -- 1312
							fileName = target, -- 1312
							workDir = workDir, -- 1312
							projectRoot = workDir, -- 1312
							runKind = "project" -- 1312
						}) -- 1312
						target = Path:getName(Path:getPath(target)) -- 1313
						return { -- 1314
							success = success, -- 1314
							target = target, -- 1314
							err = err -- 1314
						} -- 1314
					end -- 1309
				else -- 1316
					workDir = getProjectDirFromFile(file) -- 1316
				end -- 1308
				Entry.allClear() -- 1317
				file = Path:replaceExt(file, "") -- 1318
				local entry = { -- 1320
					entryName = Path:getName(file), -- 1320
					fileName = file, -- 1321
					runKind = "file" -- 1322
				} -- 1319
				if workDir then -- 1323
					entry.workDir = workDir -- 1324
					entry.projectRoot = workDir -- 1325
				end -- 1323
				local success, err = Entry.enterEntryAsync(entry) -- 1326
				return { -- 1327
					success = success, -- 1327
					err = err -- 1327
				} -- 1327
			end -- 1302
		end -- 1302
	end -- 1302
	return { -- 1301
		success = false -- 1301
	} -- 1301
end) -- 1301
HttpServer:postSchedule("/stop", function() -- 1329
	local Entry = require("Script.Dev.Entry") -- 1330
	return { -- 1331
		success = Entry.stop() -- 1331
	} -- 1331
end) -- 1329
local minifyAsync -- 1333
minifyAsync = function(sourcePath, minifyPath) -- 1333
	if not Content:exist(sourcePath) then -- 1334
		return -- 1334
	end -- 1334
	local Entry = require("Script.Dev.Entry") -- 1335
	local errors = { } -- 1336
	local files = Entry.getAllFiles(sourcePath, { -- 1337
		"lua" -- 1337
	}, true) -- 1337
	do -- 1338
		local _accum_0 = { } -- 1338
		local _len_0 = 1 -- 1338
		for _index_0 = 1, #files do -- 1338
			local file = files[_index_0] -- 1338
			if file:sub(1, 1) ~= '.' then -- 1338
				_accum_0[_len_0] = file -- 1338
				_len_0 = _len_0 + 1 -- 1338
			end -- 1338
		end -- 1338
		files = _accum_0 -- 1338
	end -- 1338
	local paths -- 1339
	do -- 1339
		local _tbl_0 = { } -- 1339
		for _index_0 = 1, #files do -- 1339
			local file = files[_index_0] -- 1339
			_tbl_0[Path:getPath(file)] = true -- 1339
		end -- 1339
		paths = _tbl_0 -- 1339
	end -- 1339
	for path in pairs(paths) do -- 1340
		Content:mkdir(Path(minifyPath, path)) -- 1340
	end -- 1340
	local _ <close> = setmetatable({ }, { -- 1341
		__close = function() -- 1341
			package.loaded["luaminify.FormatMini"] = nil -- 1342
			package.loaded["luaminify.ParseLua"] = nil -- 1343
			package.loaded["luaminify.Scope"] = nil -- 1344
			package.loaded["luaminify.Util"] = nil -- 1345
		end -- 1341
	}) -- 1341
	local FormatMini -- 1346
	do -- 1346
		local _obj_0 = require("luaminify") -- 1346
		FormatMini = _obj_0.FormatMini -- 1346
	end -- 1346
	local fileCount = #files -- 1347
	local count = 0 -- 1348
	for _index_0 = 1, #files do -- 1349
		local file = files[_index_0] -- 1349
		thread(function() -- 1350
			local _ <close> = setmetatable({ }, { -- 1351
				__close = function() -- 1351
					count = count + 1 -- 1351
				end -- 1351
			}) -- 1351
			local input = Path(sourcePath, file) -- 1352
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1353
			if Content:exist(input) then -- 1354
				local sourceCodes = Content:loadAsync(input) -- 1355
				local res, err = FormatMini(sourceCodes) -- 1356
				if res then -- 1357
					Content:saveAsync(output, res) -- 1358
					return print("Minify " .. tostring(file)) -- 1359
				else -- 1361
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1361
				end -- 1357
			else -- 1363
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1363
			end -- 1354
		end) -- 1350
		sleep() -- 1364
	end -- 1349
	wait(function() -- 1365
		return count == fileCount -- 1365
	end) -- 1365
	if #errors > 0 then -- 1366
		print(table.concat(errors, '\n')) -- 1367
	end -- 1366
	print("Obfuscation done.") -- 1368
	return files -- 1369
end -- 1333
local zipping = false -- 1371
HttpServer:postSchedule("/zip", function(req) -- 1373
	do -- 1374
		local _type_0 = type(req) -- 1374
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1374
		if _tab_0 then -- 1374
			local path -- 1374
			do -- 1374
				local _obj_0 = req.body -- 1374
				local _type_1 = type(_obj_0) -- 1374
				if "table" == _type_1 or "userdata" == _type_1 then -- 1374
					path = _obj_0.path -- 1374
				end -- 1374
			end -- 1374
			local zipFile -- 1374
			do -- 1374
				local _obj_0 = req.body -- 1374
				local _type_1 = type(_obj_0) -- 1374
				if "table" == _type_1 or "userdata" == _type_1 then -- 1374
					zipFile = _obj_0.zipFile -- 1374
				end -- 1374
			end -- 1374
			local obfuscated -- 1374
			do -- 1374
				local _obj_0 = req.body -- 1374
				local _type_1 = type(_obj_0) -- 1374
				if "table" == _type_1 or "userdata" == _type_1 then -- 1374
					obfuscated = _obj_0.obfuscated -- 1374
				end -- 1374
			end -- 1374
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1374
				if zipping then -- 1375
					goto failed -- 1375
				end -- 1375
				zipping = true -- 1376
				local _ <close> = setmetatable({ }, { -- 1377
					__close = function() -- 1377
						zipping = false -- 1377
					end -- 1377
				}) -- 1377
				if not Content:exist(path) then -- 1378
					goto failed -- 1378
				end -- 1378
				Content:mkdir(Path:getPath(zipFile)) -- 1379
				if obfuscated then -- 1380
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1381
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1382
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1383
					Content:remove(scriptPath) -- 1384
					Content:remove(obfuscatedPath) -- 1385
					Content:remove(tempPath) -- 1386
					Content:mkdir(scriptPath) -- 1387
					Content:mkdir(obfuscatedPath) -- 1388
					Content:mkdir(tempPath) -- 1389
					if not Content:copyAsync(path, tempPath) then -- 1390
						goto failed -- 1390
					end -- 1390
					local Entry = require("Script.Dev.Entry") -- 1391
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1392
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1393
						"tl", -- 1393
						"yue", -- 1393
						"lua", -- 1393
						"ts", -- 1393
						"tsx", -- 1393
						"vs", -- 1393
						"bl", -- 1393
						"xml", -- 1393
						"wa", -- 1393
						"mod" -- 1393
					}, true) -- 1393
					for _index_0 = 1, #scriptFiles do -- 1394
						local file = scriptFiles[_index_0] -- 1394
						Content:remove(Path(tempPath, file)) -- 1395
					end -- 1394
					for _index_0 = 1, #luaFiles do -- 1396
						local file = luaFiles[_index_0] -- 1396
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1397
					end -- 1396
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1398
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1399
					end) then -- 1398
						goto failed -- 1398
					end -- 1398
					return { -- 1400
						success = true -- 1400
					} -- 1400
				else -- 1402
					return { -- 1402
						success = Content:zipAsync(path, zipFile, function(file) -- 1402
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1403
						end) -- 1402
					} -- 1402
				end -- 1380
			end -- 1374
		end -- 1374
	end -- 1374
	::failed:: -- 1404
	return { -- 1373
		success = false -- 1373
	} -- 1373
end) -- 1373
HttpServer:postSchedule("/unzip", function(req) -- 1406
	do -- 1407
		local _type_0 = type(req) -- 1407
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1407
		if _tab_0 then -- 1407
			local zipFile -- 1407
			do -- 1407
				local _obj_0 = req.body -- 1407
				local _type_1 = type(_obj_0) -- 1407
				if "table" == _type_1 or "userdata" == _type_1 then -- 1407
					zipFile = _obj_0.zipFile -- 1407
				end -- 1407
			end -- 1407
			local path -- 1407
			do -- 1407
				local _obj_0 = req.body -- 1407
				local _type_1 = type(_obj_0) -- 1407
				if "table" == _type_1 or "userdata" == _type_1 then -- 1407
					path = _obj_0.path -- 1407
				end -- 1407
			end -- 1407
			if zipFile ~= nil and path ~= nil then -- 1407
				return { -- 1408
					success = Content:unzipAsync(zipFile, path, function(file) -- 1408
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1409
					end) -- 1408
				} -- 1408
			end -- 1407
		end -- 1407
	end -- 1407
	return { -- 1406
		success = false -- 1406
	} -- 1406
end) -- 1406
HttpServer:post("/editing-info", function(req) -- 1411
	local Entry = require("Script.Dev.Entry") -- 1412
	local config = Entry.getConfig() -- 1413
	local _type_0 = type(req) -- 1414
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1414
	local _match_0 = false -- 1414
	if _tab_0 then -- 1414
		local editingInfo -- 1414
		do -- 1414
			local _obj_0 = req.body -- 1414
			local _type_1 = type(_obj_0) -- 1414
			if "table" == _type_1 or "userdata" == _type_1 then -- 1414
				editingInfo = _obj_0.editingInfo -- 1414
			end -- 1414
		end -- 1414
		if editingInfo ~= nil then -- 1414
			_match_0 = true -- 1414
			config.editingInfo = editingInfo -- 1415
			return { -- 1416
				success = true -- 1416
			} -- 1416
		end -- 1414
	end -- 1414
	if not _match_0 then -- 1414
		if not (config.editingInfo ~= nil) then -- 1418
			local folder -- 1419
			if App.locale:match('^zh') then -- 1419
				folder = 'zh-Hans' -- 1419
			else -- 1419
				folder = 'en' -- 1419
			end -- 1419
			config.editingInfo = json.encode({ -- 1421
				index = 0, -- 1421
				files = { -- 1423
					{ -- 1424
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1424
						title = "welcome.md" -- 1425
					} -- 1423
				} -- 1422
			}) -- 1420
		end -- 1418
		return { -- 1429
			success = true, -- 1429
			editingInfo = config.editingInfo -- 1429
		} -- 1429
	end -- 1414
end) -- 1411
HttpServer:post("/command", function(req) -- 1431
	do -- 1432
		local _type_0 = type(req) -- 1432
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1432
		if _tab_0 then -- 1432
			local code -- 1432
			do -- 1432
				local _obj_0 = req.body -- 1432
				local _type_1 = type(_obj_0) -- 1432
				if "table" == _type_1 or "userdata" == _type_1 then -- 1432
					code = _obj_0.code -- 1432
				end -- 1432
			end -- 1432
			local log -- 1432
			do -- 1432
				local _obj_0 = req.body -- 1432
				local _type_1 = type(_obj_0) -- 1432
				if "table" == _type_1 or "userdata" == _type_1 then -- 1432
					log = _obj_0.log -- 1432
				end -- 1432
			end -- 1432
			if code ~= nil and log ~= nil then -- 1432
				emit("AppCommand", code, log) -- 1433
				return { -- 1434
					success = true -- 1434
				} -- 1434
			end -- 1432
		end -- 1432
	end -- 1432
	return { -- 1431
		success = false -- 1431
	} -- 1431
end) -- 1431
HttpServer:post("/log/save", function() -- 1436
	local folder = ".download" -- 1437
	local fullLogFile = "dora_full_logs.txt" -- 1438
	local fullFolder = Path(Content.writablePath, folder) -- 1439
	Content:mkdir(fullFolder) -- 1440
	local logPath = Path(fullFolder, fullLogFile) -- 1441
	if App:saveLog(logPath) then -- 1442
		return { -- 1443
			success = true, -- 1443
			path = Path(folder, fullLogFile) -- 1443
		} -- 1443
	end -- 1442
	return { -- 1436
		success = false -- 1436
	} -- 1436
end) -- 1436
HttpServer:post("/yarn/check", function(req) -- 1445
	local yarncompile = require("yarncompile") -- 1446
	do -- 1447
		local _type_0 = type(req) -- 1447
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1447
		if _tab_0 then -- 1447
			local code -- 1447
			do -- 1447
				local _obj_0 = req.body -- 1447
				local _type_1 = type(_obj_0) -- 1447
				if "table" == _type_1 or "userdata" == _type_1 then -- 1447
					code = _obj_0.code -- 1447
				end -- 1447
			end -- 1447
			if code ~= nil then -- 1447
				local jsonObject = json.decode(code) -- 1448
				if jsonObject then -- 1448
					local errors = { } -- 1449
					local _list_0 = jsonObject.nodes -- 1450
					for _index_0 = 1, #_list_0 do -- 1450
						local node = _list_0[_index_0] -- 1450
						local title, body = node.title, node.body -- 1451
						local luaCode, err = yarncompile(body) -- 1452
						if not luaCode then -- 1452
							errors[#errors + 1] = title .. ":" .. err -- 1453
						end -- 1452
					end -- 1450
					return { -- 1454
						success = true, -- 1454
						syntaxError = table.concat(errors, "\n\n") -- 1454
					} -- 1454
				end -- 1448
			end -- 1447
		end -- 1447
	end -- 1447
	return { -- 1445
		success = false -- 1445
	} -- 1445
end) -- 1445
HttpServer:post("/yarn/check-file", function(req) -- 1456
	local yarncompile = require("yarncompile") -- 1457
	do -- 1458
		local _type_0 = type(req) -- 1458
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1458
		if _tab_0 then -- 1458
			local code -- 1458
			do -- 1458
				local _obj_0 = req.body -- 1458
				local _type_1 = type(_obj_0) -- 1458
				if "table" == _type_1 or "userdata" == _type_1 then -- 1458
					code = _obj_0.code -- 1458
				end -- 1458
			end -- 1458
			if code ~= nil then -- 1458
				local res, _, err = yarncompile(code, true) -- 1459
				if not res then -- 1459
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1460
					return { -- 1461
						success = false, -- 1461
						message = message, -- 1461
						line = line, -- 1461
						column = column, -- 1461
						node = node -- 1461
					} -- 1461
				end -- 1459
			end -- 1458
		end -- 1458
	end -- 1458
	return { -- 1456
		success = true -- 1456
	} -- 1456
end) -- 1456
local getWaProjectDirFromFile -- 1463
getWaProjectDirFromFile = function(file) -- 1463
	local writablePath = Content.writablePath -- 1464
	local parent, current -- 1465
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1465
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1466
	else -- 1468
		parent, current = nil, nil -- 1468
	end -- 1465
	if not current then -- 1469
		return nil -- 1469
	end -- 1469
	repeat -- 1470
		current = Path:getPath(current) -- 1471
		if current == "" then -- 1472
			break -- 1472
		end -- 1472
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1473
		for _index_0 = 1, #_list_0 do -- 1473
			local f = _list_0[_index_0] -- 1473
			if Path:getFilename(f):lower() == "wa.mod" then -- 1474
				return Path(parent, current, Path:getPath(f)) -- 1475
			end -- 1474
		end -- 1473
	until false -- 1470
	return nil -- 1477
end -- 1463
HttpServer:postSchedule("/wa/update_dora", function(req) -- 1479
	do -- 1480
		local _type_0 = type(req) -- 1480
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1480
		if _tab_0 then -- 1480
			local path -- 1480
			do -- 1480
				local _obj_0 = req.body -- 1480
				local _type_1 = type(_obj_0) -- 1480
				if "table" == _type_1 or "userdata" == _type_1 then -- 1480
					path = _obj_0.path -- 1480
				end -- 1480
			end -- 1480
			if path ~= nil then -- 1480
				local projDir = getWaProjectDirFromFile(path) -- 1481
				if projDir then -- 1481
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 1482
					if not Content:exist(sourceDoraPath) then -- 1483
						return { -- 1484
							success = false, -- 1484
							message = "missing dora template" -- 1484
						} -- 1484
					end -- 1483
					local targetVendorPath = Path(projDir, "vendor") -- 1485
					local targetDoraPath = Path(targetVendorPath, "dora") -- 1486
					if not Content:exist(targetVendorPath) then -- 1487
						if not Content:mkdir(targetVendorPath) then -- 1488
							return { -- 1489
								success = false, -- 1489
								message = "failed to create vendor folder" -- 1489
							} -- 1489
						end -- 1488
					elseif not Content:isdir(targetVendorPath) then -- 1490
						return { -- 1491
							success = false, -- 1491
							message = "vendor path is not a folder" -- 1491
						} -- 1491
					end -- 1487
					if Content:exist(targetDoraPath) then -- 1492
						if not Content:remove(targetDoraPath) then -- 1493
							return { -- 1494
								success = false, -- 1494
								message = "failed to remove old dora" -- 1494
							} -- 1494
						end -- 1493
					end -- 1492
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 1495
						return { -- 1496
							success = false, -- 1496
							message = "failed to copy dora" -- 1496
						} -- 1496
					end -- 1495
					return { -- 1497
						success = true -- 1497
					} -- 1497
				else -- 1499
					return { -- 1499
						success = false, -- 1499
						message = 'Wa file needs a project' -- 1499
					} -- 1499
				end -- 1481
			end -- 1480
		end -- 1480
	end -- 1480
	return { -- 1479
		success = false, -- 1479
		message = "invalid call" -- 1479
	} -- 1479
end) -- 1479
HttpServer:postSchedule("/wa/build", function(req) -- 1501
	do -- 1502
		local _type_0 = type(req) -- 1502
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1502
		if _tab_0 then -- 1502
			local path -- 1502
			do -- 1502
				local _obj_0 = req.body -- 1502
				local _type_1 = type(_obj_0) -- 1502
				if "table" == _type_1 or "userdata" == _type_1 then -- 1502
					path = _obj_0.path -- 1502
				end -- 1502
			end -- 1502
			if path ~= nil then -- 1502
				local projDir = getWaProjectDirFromFile(path) -- 1503
				if projDir then -- 1503
					local message = Wasm:buildWaAsync(projDir) -- 1504
					if message == "" then -- 1505
						return { -- 1506
							success = true -- 1506
						} -- 1506
					else -- 1508
						return { -- 1508
							success = false, -- 1508
							message = message -- 1508
						} -- 1508
					end -- 1505
				else -- 1510
					return { -- 1510
						success = false, -- 1510
						message = 'Wa file needs a project' -- 1510
					} -- 1510
				end -- 1503
			end -- 1502
		end -- 1502
	end -- 1502
	return { -- 1511
		success = false, -- 1511
		message = 'failed to build' -- 1511
	} -- 1511
end) -- 1501
HttpServer:postSchedule("/wa/format", function(req) -- 1513
	do -- 1514
		local _type_0 = type(req) -- 1514
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1514
		if _tab_0 then -- 1514
			local file -- 1514
			do -- 1514
				local _obj_0 = req.body -- 1514
				local _type_1 = type(_obj_0) -- 1514
				if "table" == _type_1 or "userdata" == _type_1 then -- 1514
					file = _obj_0.file -- 1514
				end -- 1514
			end -- 1514
			if file ~= nil then -- 1514
				local code = Wasm:formatWaAsync(file) -- 1515
				if code == "" then -- 1516
					return { -- 1517
						success = false -- 1517
					} -- 1517
				else -- 1519
					return { -- 1519
						success = true, -- 1519
						code = code -- 1519
					} -- 1519
				end -- 1516
			end -- 1514
		end -- 1514
	end -- 1514
	return { -- 1520
		success = false -- 1520
	} -- 1520
end) -- 1513
HttpServer:postSchedule("/wa/create", function(req) -- 1522
	do -- 1523
		local _type_0 = type(req) -- 1523
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1523
		if _tab_0 then -- 1523
			local path -- 1523
			do -- 1523
				local _obj_0 = req.body -- 1523
				local _type_1 = type(_obj_0) -- 1523
				if "table" == _type_1 or "userdata" == _type_1 then -- 1523
					path = _obj_0.path -- 1523
				end -- 1523
			end -- 1523
			if path ~= nil then -- 1523
				if not Content:exist(Path:getPath(path)) then -- 1524
					return { -- 1525
						success = false, -- 1525
						message = "target path not existed" -- 1525
					} -- 1525
				end -- 1524
				if Content:exist(path) then -- 1526
					return { -- 1527
						success = false, -- 1527
						message = "target project folder existed" -- 1527
					} -- 1527
				end -- 1526
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1528
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1529
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1530
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1531
					return { -- 1534
						success = false, -- 1534
						message = "missing template project" -- 1534
					} -- 1534
				end -- 1531
				if not Content:mkdir(path) then -- 1535
					return { -- 1536
						success = false, -- 1536
						message = "failed to create project folder" -- 1536
					} -- 1536
				end -- 1535
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1537
					Content:remove(path) -- 1538
					return { -- 1539
						success = false, -- 1539
						message = "failed to copy template" -- 1539
					} -- 1539
				end -- 1537
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1540
					Content:remove(path) -- 1541
					return { -- 1542
						success = false, -- 1542
						message = "failed to copy template" -- 1542
					} -- 1542
				end -- 1540
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1543
					Content:remove(path) -- 1544
					return { -- 1545
						success = false, -- 1545
						message = "failed to copy template" -- 1545
					} -- 1545
				end -- 1543
				return { -- 1546
					success = true -- 1546
				} -- 1546
			end -- 1523
		end -- 1523
	end -- 1523
	return { -- 1522
		success = false, -- 1522
		message = "invalid call" -- 1522
	} -- 1522
end) -- 1522
local tsBuildGlobs = { -- 1549
	"**/*.ts", -- 1549
	"**/*.tsx", -- 1550
	"!**/.*/**", -- 1551
	"!**/node_modules/**" -- 1552
} -- 1548
local _anon_func_5 = function(path) -- 1561
	local _val_0 = Path:getExt(path) -- 1561
	return "ts" == _val_0 or "tsx" == _val_0 -- 1561
end -- 1561
HttpServer:postSchedule("/ts/build", function(req) -- 1554
	do -- 1555
		local _type_0 = type(req) -- 1555
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1555
		if _tab_0 then -- 1555
			local path -- 1555
			do -- 1555
				local _obj_0 = req.body -- 1555
				local _type_1 = type(_obj_0) -- 1555
				if "table" == _type_1 or "userdata" == _type_1 then -- 1555
					path = _obj_0.path -- 1555
				end -- 1555
			end -- 1555
			if path ~= nil then -- 1555
				if HttpServer.wsConnectionCount == 0 then -- 1556
					return { -- 1557
						success = false, -- 1557
						message = "Web IDE not connected" -- 1557
					} -- 1557
				end -- 1556
				if not Content:exist(path) then -- 1558
					return { -- 1559
						success = false, -- 1559
						message = "path not existed" -- 1559
					} -- 1559
				end -- 1558
				if not Content:isdir(path) then -- 1560
					if not (_anon_func_5(path)) then -- 1561
						return { -- 1562
							success = false, -- 1562
							message = "expecting a TypeScript file" -- 1562
						} -- 1562
					end -- 1561
					local messages = { } -- 1563
					local content = Content:load(path) -- 1564
					if not content then -- 1565
						return { -- 1566
							success = false, -- 1566
							message = "failed to read file" -- 1566
						} -- 1566
					end -- 1565
					emit("AppWS", "Send", json.encode({ -- 1567
						name = "UpdateFile", -- 1567
						file = path, -- 1567
						exists = true, -- 1567
						content = content -- 1567
					})) -- 1567
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1568
						local done = false -- 1569
						do -- 1570
							local _with_0 = Node() -- 1570
							_with_0:gslot("AppWS", function(event) -- 1571
								if event.type == "Receive" then -- 1572
									local res = json.decode(event.msg) -- 1573
									if res then -- 1573
										if res.name == "TranspileTS" and res.file == path then -- 1574
											_with_0:removeFromParent() -- 1575
											if res.success then -- 1576
												local luaFile = Path:replaceExt(path, "lua") -- 1577
												Content:save(luaFile, res.luaCode) -- 1578
												messages[#messages + 1] = { -- 1579
													success = true, -- 1579
													file = path -- 1579
												} -- 1579
											else -- 1581
												messages[#messages + 1] = { -- 1581
													success = false, -- 1581
													file = path, -- 1581
													message = res.message -- 1581
												} -- 1581
											end -- 1576
											done = true -- 1582
										end -- 1574
									end -- 1573
								end -- 1572
							end) -- 1571
						end -- 1570
						emit("AppWS", "Send", json.encode({ -- 1583
							name = "TranspileTS", -- 1583
							file = path, -- 1583
							content = content -- 1583
						})) -- 1583
						wait(function() -- 1584
							return done -- 1584
						end) -- 1584
					end -- 1568
					return { -- 1585
						success = true, -- 1585
						messages = messages -- 1585
					} -- 1585
				else -- 1587
					local fileData = { } -- 1587
					local messages = { } -- 1588
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 1589
					for _index_0 = 1, #_list_0 do -- 1589
						local subFile = _list_0[_index_0] -- 1589
						local file = Path(path, subFile) -- 1590
						local content = Content:load(file) -- 1591
						if content then -- 1591
							fileData[file] = content -- 1592
							emit("AppWS", "Send", json.encode({ -- 1593
								name = "UpdateFile", -- 1593
								file = file, -- 1593
								exists = true, -- 1593
								content = content -- 1593
							})) -- 1593
						else -- 1595
							messages[#messages + 1] = { -- 1595
								success = false, -- 1595
								file = file, -- 1595
								message = "failed to read file" -- 1595
							} -- 1595
						end -- 1591
					end -- 1589
					for file, content in pairs(fileData) do -- 1596
						if "d" == Path:getExt(Path:getName(file)) then -- 1597
							goto _continue_0 -- 1597
						end -- 1597
						local done = false -- 1598
						do -- 1599
							local _with_0 = Node() -- 1599
							_with_0:gslot("AppWS", function(event) -- 1600
								if event.type == "Receive" then -- 1601
									local res = json.decode(event.msg) -- 1602
									if res then -- 1602
										if res.name == "TranspileTS" and res.file == file then -- 1603
											_with_0:removeFromParent() -- 1604
											if res.success then -- 1605
												local luaFile = Path:replaceExt(file, "lua") -- 1606
												Content:save(luaFile, res.luaCode) -- 1607
												messages[#messages + 1] = { -- 1608
													success = true, -- 1608
													file = file -- 1608
												} -- 1608
											else -- 1610
												messages[#messages + 1] = { -- 1610
													success = false, -- 1610
													file = file, -- 1610
													message = res.message -- 1610
												} -- 1610
											end -- 1605
											done = true -- 1611
										end -- 1603
									end -- 1602
								end -- 1601
							end) -- 1600
						end -- 1599
						emit("AppWS", "Send", json.encode({ -- 1612
							name = "TranspileTS", -- 1612
							file = file, -- 1612
							content = content -- 1612
						})) -- 1612
						wait(function() -- 1613
							return done -- 1613
						end) -- 1613
						::_continue_0:: -- 1597
					end -- 1596
					return { -- 1614
						success = true, -- 1614
						messages = messages -- 1614
					} -- 1614
				end -- 1560
			end -- 1555
		end -- 1555
	end -- 1555
	return { -- 1554
		success = false -- 1554
	} -- 1554
end) -- 1554
HttpServer:post("/download", function(req) -- 1616
	do -- 1617
		local _type_0 = type(req) -- 1617
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1617
		if _tab_0 then -- 1617
			local url -- 1617
			do -- 1617
				local _obj_0 = req.body -- 1617
				local _type_1 = type(_obj_0) -- 1617
				if "table" == _type_1 or "userdata" == _type_1 then -- 1617
					url = _obj_0.url -- 1617
				end -- 1617
			end -- 1617
			local target -- 1617
			do -- 1617
				local _obj_0 = req.body -- 1617
				local _type_1 = type(_obj_0) -- 1617
				if "table" == _type_1 or "userdata" == _type_1 then -- 1617
					target = _obj_0.target -- 1617
				end -- 1617
			end -- 1617
			if url ~= nil and target ~= nil then -- 1617
				local Entry = require("Script.Dev.Entry") -- 1618
				Entry.downloadFile(url, target) -- 1619
				return { -- 1620
					success = true -- 1620
				} -- 1620
			end -- 1617
		end -- 1617
	end -- 1617
	return { -- 1616
		success = false -- 1616
	} -- 1616
end) -- 1616
local status = { } -- 1622
_module_0 = status -- 1623
status.buildAsync = function(path) -- 1625
	if not Content:exist(path) then -- 1626
		return { -- 1627
			success = false, -- 1627
			file = path, -- 1627
			message = "file not existed" -- 1627
		} -- 1627
	end -- 1626
	do -- 1628
		local _exp_0 = Path:getExt(path) -- 1628
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1628
			if '' == Path:getExt(Path:getName(path)) then -- 1629
				local content = Content:loadAsync(path) -- 1630
				if content then -- 1630
					local resultCodes, err = compileFileAsync(path, content) -- 1631
					if resultCodes then -- 1631
						return { -- 1632
							success = true, -- 1632
							file = path -- 1632
						} -- 1632
					else -- 1634
						return { -- 1634
							success = false, -- 1634
							file = path, -- 1634
							message = err -- 1634
						} -- 1634
					end -- 1631
				end -- 1630
			end -- 1629
		elseif "lua" == _exp_0 then -- 1635
			local content = Content:loadAsync(path) -- 1636
			if content then -- 1636
				do -- 1637
					local isTIC80 = CheckTIC80Code(content) -- 1637
					if isTIC80 then -- 1637
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1638
					end -- 1637
				end -- 1637
				local success, info -- 1639
				do -- 1639
					local _obj_0 = luaCheck(path, content) -- 1639
					success, info = _obj_0.success, _obj_0.info -- 1639
				end -- 1639
				if success then -- 1640
					return { -- 1641
						success = true, -- 1641
						file = path -- 1641
					} -- 1641
				elseif info and #info > 0 then -- 1642
					local messages = { } -- 1643
					for _index_0 = 1, #info do -- 1644
						local _des_0 = info[_index_0] -- 1644
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 1644
						local lineText = "" -- 1645
						if line then -- 1646
							local currentLine = 1 -- 1647
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1648
								if currentLine == line then -- 1649
									lineText = text -- 1650
									break -- 1651
								end -- 1649
								currentLine = currentLine + 1 -- 1652
							end -- 1648
						end -- 1646
						if line then -- 1653
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1654
						else -- 1656
							messages[#messages + 1] = message -- 1656
						end -- 1653
					end -- 1644
					return { -- 1657
						success = false, -- 1657
						file = path, -- 1657
						message = table.concat(messages, "\n") -- 1657
					} -- 1657
				else -- 1659
					return { -- 1659
						success = false, -- 1659
						file = path, -- 1659
						message = "lua check failed" -- 1659
					} -- 1659
				end -- 1640
			end -- 1636
		elseif "yarn" == _exp_0 then -- 1660
			local content = Content:loadAsync(path) -- 1661
			if content then -- 1661
				local res, _, err = yarncompile(content, true) -- 1662
				if res then -- 1662
					return { -- 1663
						success = true, -- 1663
						file = path -- 1663
					} -- 1663
				else -- 1665
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1665
					local lineText = "" -- 1666
					if line then -- 1667
						local currentLine = 1 -- 1668
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1669
							if currentLine == line then -- 1670
								lineText = text -- 1671
								break -- 1672
							end -- 1670
							currentLine = currentLine + 1 -- 1673
						end -- 1669
					end -- 1667
					if node ~= "" then -- 1674
						node = "node: " .. tostring(node) .. ", " -- 1675
					else -- 1676
						node = "" -- 1676
					end -- 1674
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1677
					return { -- 1678
						success = false, -- 1678
						file = path, -- 1678
						message = message -- 1678
					} -- 1678
				end -- 1662
			end -- 1661
		end -- 1628
	end -- 1628
	return { -- 1679
		success = false, -- 1679
		file = path, -- 1679
		message = "invalid file to build" -- 1679
	} -- 1679
end -- 1625
thread(function() -- 1681
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1682
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1683
	if Content:exist(doraWeb) then -- 1684
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 1685
		local needReload -- 1686
		if Content:exist(doraReady) then -- 1686
			needReload = readyContent ~= Content:load(doraReady) -- 1687
		else -- 1688
			needReload = true -- 1688
		end -- 1686
		if needReload then -- 1689
			Content:remove(Path(Content.appPath, ".www")) -- 1690
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1691
			Content:save(doraReady, readyContent) -- 1695
			print("Dora Dora is ready!") -- 1696
		end -- 1689
	end -- 1684
	if HttpServer:start(8866) then -- 1697
		local localIP = HttpServer.localIP -- 1698
		if localIP == "" then -- 1699
			localIP = "localhost" -- 1699
		end -- 1699
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1700
		return HttpServer:startWS(8868) -- 1701
	else -- 1703
		status.url = nil -- 1703
		return print("8866 Port not available!") -- 1704
	end -- 1697
end) -- 1681
return _module_0 -- 1
