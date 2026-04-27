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
HttpServer:post("/agent/task/diff", function(req) -- 184
	do -- 185
		local _type_0 = type(req) -- 185
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 185
		if _tab_0 then -- 185
			local taskId -- 185
			do -- 185
				local _obj_0 = req.body -- 185
				local _type_1 = type(_obj_0) -- 185
				if "table" == _type_1 or "userdata" == _type_1 then -- 185
					taskId = _obj_0.taskId -- 185
				end -- 185
			end -- 185
			if taskId ~= nil then -- 185
				if not (taskId > 0) then -- 186
					return { -- 186
						success = false, -- 186
						message = "invalid taskId" -- 186
					} -- 186
				end -- 186
				return AgentTools.getTaskChangeSetDiff(taskId) -- 187
			end -- 185
		end -- 185
	end -- 185
	return invalidArguments -- 184
end) -- 184
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 189
	do -- 190
		local _type_0 = type(req) -- 190
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 190
		if _tab_0 then -- 190
			local sessionId -- 190
			do -- 190
				local _obj_0 = req.body -- 190
				local _type_1 = type(_obj_0) -- 190
				if "table" == _type_1 or "userdata" == _type_1 then -- 190
					sessionId = _obj_0.sessionId -- 190
				end -- 190
			end -- 190
			local checkpointId -- 190
			do -- 190
				local _obj_0 = req.body -- 190
				local _type_1 = type(_obj_0) -- 190
				if "table" == _type_1 or "userdata" == _type_1 then -- 190
					checkpointId = _obj_0.checkpointId -- 190
				end -- 190
			end -- 190
			if sessionId ~= nil and checkpointId ~= nil then -- 190
				if not (checkpointId > 0) then -- 191
					return { -- 191
						success = false, -- 191
						message = "invalid checkpointId" -- 191
					} -- 191
				end -- 191
				local res = AgentSession.getSession(sessionId) -- 192
				if not res.success then -- 193
					return res -- 193
				end -- 193
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, res.session.projectRoot) -- 194
				if not rollbackRes.success then -- 195
					return rollbackRes -- 195
				end -- 195
				return { -- 197
					success = true, -- 197
					checkpointId = rollbackRes.checkpointId -- 198
				} -- 196
			end -- 190
		end -- 190
	end -- 190
	return invalidArguments -- 189
end) -- 189
HttpServer:post("/agent/task/rollback", function(req) -- 200
	do -- 201
		local _type_0 = type(req) -- 201
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 201
		if _tab_0 then -- 201
			local sessionId -- 201
			do -- 201
				local _obj_0 = req.body -- 201
				local _type_1 = type(_obj_0) -- 201
				if "table" == _type_1 or "userdata" == _type_1 then -- 201
					sessionId = _obj_0.sessionId -- 201
				end -- 201
			end -- 201
			local taskId -- 201
			do -- 201
				local _obj_0 = req.body -- 201
				local _type_1 = type(_obj_0) -- 201
				if "table" == _type_1 or "userdata" == _type_1 then -- 201
					taskId = _obj_0.taskId -- 201
				end -- 201
			end -- 201
			if sessionId ~= nil and taskId ~= nil then -- 201
				if not (taskId > 0) then -- 202
					return { -- 202
						success = false, -- 202
						message = "invalid taskId" -- 202
					} -- 202
				end -- 202
				local res = AgentSession.getSession(sessionId) -- 203
				if not res.success then -- 204
					return res -- 204
				end -- 204
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, res.session.projectRoot) -- 205
				if not rollbackRes.success then -- 206
					return rollbackRes -- 206
				end -- 206
				return { -- 208
					success = true, -- 208
					taskId = rollbackRes.taskId, -- 209
					checkpointId = rollbackRes.checkpointId, -- 210
					checkpointCount = rollbackRes.checkpointCount -- 211
				} -- 207
			end -- 201
		end -- 201
	end -- 201
	return invalidArguments -- 200
end) -- 200
local getSearchPath -- 213
getSearchPath = function(file) -- 213
	do -- 214
		local dir = getProjectDirFromFile(file) -- 214
		if dir then -- 214
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 215
		end -- 214
	end -- 214
	return "" -- 213
end -- 213
local getSearchFolders -- 217
getSearchFolders = function(file) -- 217
	do -- 218
		local dir = getProjectDirFromFile(file) -- 218
		if dir then -- 218
			return { -- 220
				Path(dir, "Script"), -- 220
				dir -- 221
			} -- 219
		end -- 218
	end -- 218
	return { } -- 217
end -- 217
local disabledCheckForLua = { -- 224
	"incompatible number of returns", -- 224
	"unknown", -- 225
	"cannot index", -- 226
	"module not found", -- 227
	"don't know how to resolve", -- 228
	"ContainerItem", -- 229
	"cannot resolve a type", -- 230
	"invalid key", -- 231
	"inconsistent index type", -- 232
	"cannot use operator", -- 233
	"attempting ipairs loop", -- 234
	"expects record or nominal", -- 235
	"variable is not being assigned", -- 236
	"<invalid type>", -- 237
	"<any type>", -- 238
	"using the '#' operator", -- 239
	"can't match a record", -- 240
	"redeclaration of variable", -- 241
	"cannot apply pairs", -- 242
	"not a function", -- 243
	"to%-be%-closed" -- 244
} -- 223
local yueCheck -- 246
yueCheck = function(file, content, lax) -- 246
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 247
	if isTIC80 then -- 248
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 249
	end -- 248
	local searchPath = getSearchPath(file) -- 250
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 251
	local info = { } -- 252
	local globals = { } -- 253
	for _index_0 = 1, #checkResult do -- 254
		local _des_0 = checkResult[_index_0] -- 254
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 254
		if "error" == t then -- 255
			info[#info + 1] = { -- 256
				"syntax", -- 256
				file, -- 256
				line, -- 256
				col, -- 256
				msg -- 256
			} -- 256
		elseif "global" == t then -- 257
			globals[#globals + 1] = { -- 258
				msg, -- 258
				line, -- 258
				col -- 258
			} -- 258
		end -- 255
	end -- 254
	if luaCodes then -- 259
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 260
		if success then -- 261
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 262
			if not (lintResult == "") then -- 263
				lintResult = lintResult .. "\n" -- 263
			end -- 263
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 264
		else -- 265
			for _index_0 = 1, #lintResult do -- 265
				local _des_0 = lintResult[_index_0] -- 265
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 265
				if isTIC80 and tic80APIs[name] then -- 266
					goto _continue_0 -- 266
				end -- 266
				info[#info + 1] = { -- 267
					"syntax", -- 267
					file, -- 267
					line, -- 267
					col, -- 267
					"invalid global variable" -- 267
				} -- 267
				::_continue_0:: -- 266
			end -- 265
		end -- 261
	end -- 259
	return luaCodes, info -- 268
end -- 246
local luaCheck -- 270
luaCheck = function(file, content) -- 270
	local res, err = load(content, "check") -- 271
	if not res then -- 272
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 273
		return { -- 274
			success = false, -- 274
			info = { -- 274
				{ -- 274
					"syntax", -- 274
					file, -- 274
					tonumber(line), -- 274
					0, -- 274
					msg -- 274
				} -- 274
			} -- 274
		} -- 274
	end -- 272
	local success, info = teal.checkAsync(content, file, true, "") -- 275
	if info then -- 276
		do -- 277
			local _accum_0 = { } -- 277
			local _len_0 = 1 -- 277
			for _index_0 = 1, #info do -- 277
				local item = info[_index_0] -- 277
				local useCheck = true -- 278
				if not item[5]:match("unused") then -- 279
					for _index_1 = 1, #disabledCheckForLua do -- 280
						local check = disabledCheckForLua[_index_1] -- 280
						if item[5]:match(check) then -- 281
							useCheck = false -- 282
						end -- 281
					end -- 280
				end -- 279
				if not useCheck then -- 283
					goto _continue_0 -- 283
				end -- 283
				do -- 284
					local _exp_0 = item[1] -- 284
					if "type" == _exp_0 then -- 285
						item[1] = "warning" -- 286
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 287
						goto _continue_0 -- 288
					end -- 284
				end -- 284
				_accum_0[_len_0] = item -- 289
				_len_0 = _len_0 + 1 -- 278
				::_continue_0:: -- 278
			end -- 277
			info = _accum_0 -- 277
		end -- 277
		if #info == 0 then -- 290
			info = nil -- 291
			success = true -- 292
		end -- 290
	end -- 276
	return { -- 293
		success = success, -- 293
		info = info -- 293
	} -- 293
end -- 270
local luaCheckWithLineInfo -- 295
luaCheckWithLineInfo = function(file, luaCodes) -- 295
	local res = luaCheck(file, luaCodes) -- 296
	local info = { } -- 297
	if not res.success then -- 298
		local current = 1 -- 299
		local lastLine = 1 -- 300
		local lineMap = { } -- 301
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 302
			local num = lineCode:match("--%s*(%d+)%s*$") -- 303
			if num then -- 304
				lastLine = tonumber(num) -- 305
			end -- 304
			lineMap[current] = lastLine -- 306
			current = current + 1 -- 307
		end -- 302
		local _list_0 = res.info -- 308
		for _index_0 = 1, #_list_0 do -- 308
			local item = _list_0[_index_0] -- 308
			item[3] = lineMap[item[3]] or 0 -- 309
			item[4] = 0 -- 310
			info[#info + 1] = item -- 311
		end -- 308
		return false, info -- 312
	end -- 298
	return true, info -- 313
end -- 295
local getCompiledYueLine -- 315
getCompiledYueLine = function(content, line, row, file, lax) -- 315
	local luaCodes = yueCheck(file, content, lax) -- 316
	if not luaCodes then -- 317
		return nil -- 317
	end -- 317
	local current = 1 -- 318
	local lastLine = 1 -- 319
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 320
	local targetRow = nil -- 321
	local lineMap = { } -- 322
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 323
		local num = lineCode:match("--%s*(%d+)%s*$") -- 324
		if num then -- 325
			lastLine = tonumber(num) -- 325
		end -- 325
		lineMap[current] = lastLine -- 326
		if row <= lastLine and not targetRow then -- 327
			targetRow = current -- 328
			break -- 329
		end -- 327
		current = current + 1 -- 330
	end -- 323
	targetRow = current -- 331
	if targetLine and targetRow then -- 332
		return luaCodes, targetLine, targetRow, lineMap -- 333
	else -- 335
		return nil -- 335
	end -- 332
end -- 315
HttpServer:postSchedule("/check", function(req) -- 337
	do -- 338
		local _type_0 = type(req) -- 338
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 338
		if _tab_0 then -- 338
			local file -- 338
			do -- 338
				local _obj_0 = req.body -- 338
				local _type_1 = type(_obj_0) -- 338
				if "table" == _type_1 or "userdata" == _type_1 then -- 338
					file = _obj_0.file -- 338
				end -- 338
			end -- 338
			local content -- 338
			do -- 338
				local _obj_0 = req.body -- 338
				local _type_1 = type(_obj_0) -- 338
				if "table" == _type_1 or "userdata" == _type_1 then -- 338
					content = _obj_0.content -- 338
				end -- 338
			end -- 338
			if file ~= nil and content ~= nil then -- 338
				local ext = Path:getExt(file) -- 339
				if "tl" == ext then -- 340
					local searchPath = getSearchPath(file) -- 341
					do -- 342
						local isTIC80 = CheckTIC80Code(content) -- 342
						if isTIC80 then -- 342
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 343
						end -- 342
					end -- 342
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 344
					return { -- 345
						success = success, -- 345
						info = info -- 345
					} -- 345
				elseif "lua" == ext then -- 346
					do -- 347
						local isTIC80 = CheckTIC80Code(content) -- 347
						if isTIC80 then -- 347
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 348
						end -- 347
					end -- 347
					return luaCheck(file, content) -- 349
				elseif "yue" == ext then -- 350
					local luaCodes, info = yueCheck(file, content, false) -- 351
					local success = false -- 352
					if luaCodes then -- 353
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 354
						do -- 355
							local _tab_1 = { } -- 355
							local _idx_0 = #_tab_1 + 1 -- 355
							for _index_0 = 1, #info do -- 355
								local _value_0 = info[_index_0] -- 355
								_tab_1[_idx_0] = _value_0 -- 355
								_idx_0 = _idx_0 + 1 -- 355
							end -- 355
							local _idx_1 = #_tab_1 + 1 -- 355
							for _index_0 = 1, #luaInfo do -- 355
								local _value_0 = luaInfo[_index_0] -- 355
								_tab_1[_idx_1] = _value_0 -- 355
								_idx_1 = _idx_1 + 1 -- 355
							end -- 355
							info = _tab_1 -- 355
						end -- 355
						success = success and luaSuccess -- 356
					end -- 353
					if #info > 0 then -- 357
						return { -- 358
							success = success, -- 358
							info = info -- 358
						} -- 358
					else -- 360
						return { -- 360
							success = success -- 360
						} -- 360
					end -- 357
				elseif "xml" == ext then -- 361
					local success, result = xml.check(content) -- 362
					if success then -- 363
						local info -- 364
						success, info = luaCheckWithLineInfo(file, result) -- 364
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
					else -- 370
						local info -- 370
						do -- 370
							local _accum_0 = { } -- 370
							local _len_0 = 1 -- 370
							for _index_0 = 1, #result do -- 370
								local _des_0 = result[_index_0] -- 370
								local row, err = _des_0[1], _des_0[2] -- 370
								_accum_0[_len_0] = { -- 371
									"syntax", -- 371
									file, -- 371
									row, -- 371
									0, -- 371
									err -- 371
								} -- 371
								_len_0 = _len_0 + 1 -- 371
							end -- 370
							info = _accum_0 -- 370
						end -- 370
						return { -- 372
							success = false, -- 372
							info = info -- 372
						} -- 372
					end -- 363
				end -- 340
			end -- 338
		end -- 338
	end -- 338
	return { -- 337
		success = true -- 337
	} -- 337
end) -- 337
local updateInferedDesc -- 374
updateInferedDesc = function(infered) -- 374
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 375
		return -- 375
	end -- 375
	local key, row = infered.key, infered.row -- 376
	local codes = Content:loadAsync(key) -- 377
	if codes then -- 377
		local comments = { } -- 378
		local line = 0 -- 379
		local skipping = false -- 380
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 381
			line = line + 1 -- 382
			if line >= row then -- 383
				break -- 383
			end -- 383
			if lineCode:match("^%s*%-%- @") then -- 384
				skipping = true -- 385
				goto _continue_0 -- 386
			end -- 384
			local result = lineCode:match("^%s*%-%- (.+)") -- 387
			if result then -- 387
				if not skipping then -- 388
					comments[#comments + 1] = result -- 388
				end -- 388
			elseif #comments > 0 then -- 389
				comments = { } -- 390
				skipping = false -- 391
			end -- 387
			::_continue_0:: -- 382
		end -- 381
		infered.doc = table.concat(comments, "\n") -- 392
	end -- 377
end -- 374
HttpServer:postSchedule("/infer", function(req) -- 394
	do -- 395
		local _type_0 = type(req) -- 395
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 395
		if _tab_0 then -- 395
			local lang -- 395
			do -- 395
				local _obj_0 = req.body -- 395
				local _type_1 = type(_obj_0) -- 395
				if "table" == _type_1 or "userdata" == _type_1 then -- 395
					lang = _obj_0.lang -- 395
				end -- 395
			end -- 395
			local file -- 395
			do -- 395
				local _obj_0 = req.body -- 395
				local _type_1 = type(_obj_0) -- 395
				if "table" == _type_1 or "userdata" == _type_1 then -- 395
					file = _obj_0.file -- 395
				end -- 395
			end -- 395
			local content -- 395
			do -- 395
				local _obj_0 = req.body -- 395
				local _type_1 = type(_obj_0) -- 395
				if "table" == _type_1 or "userdata" == _type_1 then -- 395
					content = _obj_0.content -- 395
				end -- 395
			end -- 395
			local line -- 395
			do -- 395
				local _obj_0 = req.body -- 395
				local _type_1 = type(_obj_0) -- 395
				if "table" == _type_1 or "userdata" == _type_1 then -- 395
					line = _obj_0.line -- 395
				end -- 395
			end -- 395
			local row -- 395
			do -- 395
				local _obj_0 = req.body -- 395
				local _type_1 = type(_obj_0) -- 395
				if "table" == _type_1 or "userdata" == _type_1 then -- 395
					row = _obj_0.row -- 395
				end -- 395
			end -- 395
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 395
				local searchPath = getSearchPath(file) -- 396
				if "tl" == lang or "lua" == lang then -- 397
					if CheckTIC80Code(content) then -- 398
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 399
					end -- 398
					local infered = teal.inferAsync(content, line, row, searchPath) -- 400
					if (infered ~= nil) then -- 401
						updateInferedDesc(infered) -- 402
						return { -- 403
							success = true, -- 403
							infered = infered -- 403
						} -- 403
					end -- 401
				elseif "yue" == lang then -- 404
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 405
					if not luaCodes then -- 406
						return { -- 406
							success = false -- 406
						} -- 406
					end -- 406
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 407
					if (infered ~= nil) then -- 408
						local col -- 409
						file, row, col = infered.file, infered.row, infered.col -- 409
						if file == "" and row > 0 and col > 0 then -- 410
							infered.row = lineMap[row] or 0 -- 411
							infered.col = 0 -- 412
						end -- 410
						updateInferedDesc(infered) -- 413
						return { -- 414
							success = true, -- 414
							infered = infered -- 414
						} -- 414
					end -- 408
				end -- 397
			end -- 395
		end -- 395
	end -- 395
	return { -- 394
		success = false -- 394
	} -- 394
end) -- 394
local _anon_func_2 = function(doc) -- 465
	local _accum_0 = { } -- 465
	local _len_0 = 1 -- 465
	local _list_0 = doc.params -- 465
	for _index_0 = 1, #_list_0 do -- 465
		local param = _list_0[_index_0] -- 465
		_accum_0[_len_0] = param.name -- 465
		_len_0 = _len_0 + 1 -- 465
	end -- 465
	return _accum_0 -- 465
end -- 465
local getParamDocs -- 416
getParamDocs = function(signatures) -- 416
	do -- 417
		local codes = Content:loadAsync(signatures[1].file) -- 417
		if codes then -- 417
			local comments = { } -- 418
			local params = { } -- 419
			local line = 0 -- 420
			local docs = { } -- 421
			local returnType = nil -- 422
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 423
				line = line + 1 -- 424
				local needBreak = true -- 425
				for i, _des_0 in ipairs(signatures) do -- 426
					local row = _des_0.row -- 426
					if line >= row and not (docs[i] ~= nil) then -- 427
						if #comments > 0 or #params > 0 or returnType then -- 428
							docs[i] = { -- 430
								doc = table.concat(comments, "  \n"), -- 430
								returnType = returnType -- 431
							} -- 429
							if #params > 0 then -- 433
								docs[i].params = params -- 433
							end -- 433
						else -- 435
							docs[i] = false -- 435
						end -- 428
					end -- 427
					if not docs[i] then -- 436
						needBreak = false -- 436
					end -- 436
				end -- 426
				if needBreak then -- 437
					break -- 437
				end -- 437
				local result = lineCode:match("%s*%-%- (.+)") -- 438
				if result then -- 438
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 439
					if not name then -- 440
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 441
					end -- 440
					if name then -- 442
						local pname = name -- 443
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 444
							pname = pname .. "?" -- 444
						end -- 444
						params[#params + 1] = { -- 446
							name = tostring(pname) .. ": " .. tostring(typ), -- 446
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 447
						} -- 445
					else -- 450
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 450
						if typ then -- 450
							if returnType then -- 451
								returnType = returnType .. ", " .. typ -- 452
							else -- 454
								returnType = typ -- 454
							end -- 451
							result = result:gsub("@return", "**return:**") -- 455
						end -- 450
						comments[#comments + 1] = result -- 456
					end -- 442
				elseif #comments > 0 then -- 457
					comments = { } -- 458
					params = { } -- 459
					returnType = nil -- 460
				end -- 438
			end -- 423
			local results = { } -- 461
			for _index_0 = 1, #docs do -- 462
				local doc = docs[_index_0] -- 462
				if not doc then -- 463
					goto _continue_0 -- 463
				end -- 463
				if doc.params then -- 464
					doc.desc = "function(" .. tostring(table.concat(_anon_func_2(doc), ', ')) .. ")" -- 465
				else -- 467
					doc.desc = "function()" -- 467
				end -- 464
				if doc.returnType then -- 468
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 469
					doc.returnType = nil -- 470
				end -- 468
				results[#results + 1] = doc -- 471
				::_continue_0:: -- 463
			end -- 462
			if #results > 0 then -- 472
				return results -- 472
			else -- 472
				return nil -- 472
			end -- 472
		end -- 417
	end -- 417
	return nil -- 416
end -- 416
HttpServer:postSchedule("/signature", function(req) -- 474
	do -- 475
		local _type_0 = type(req) -- 475
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 475
		if _tab_0 then -- 475
			local lang -- 475
			do -- 475
				local _obj_0 = req.body -- 475
				local _type_1 = type(_obj_0) -- 475
				if "table" == _type_1 or "userdata" == _type_1 then -- 475
					lang = _obj_0.lang -- 475
				end -- 475
			end -- 475
			local file -- 475
			do -- 475
				local _obj_0 = req.body -- 475
				local _type_1 = type(_obj_0) -- 475
				if "table" == _type_1 or "userdata" == _type_1 then -- 475
					file = _obj_0.file -- 475
				end -- 475
			end -- 475
			local content -- 475
			do -- 475
				local _obj_0 = req.body -- 475
				local _type_1 = type(_obj_0) -- 475
				if "table" == _type_1 or "userdata" == _type_1 then -- 475
					content = _obj_0.content -- 475
				end -- 475
			end -- 475
			local line -- 475
			do -- 475
				local _obj_0 = req.body -- 475
				local _type_1 = type(_obj_0) -- 475
				if "table" == _type_1 or "userdata" == _type_1 then -- 475
					line = _obj_0.line -- 475
				end -- 475
			end -- 475
			local row -- 475
			do -- 475
				local _obj_0 = req.body -- 475
				local _type_1 = type(_obj_0) -- 475
				if "table" == _type_1 or "userdata" == _type_1 then -- 475
					row = _obj_0.row -- 475
				end -- 475
			end -- 475
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 475
				local searchPath = getSearchPath(file) -- 476
				if "tl" == lang or "lua" == lang then -- 477
					if CheckTIC80Code(content) then -- 478
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 479
					end -- 478
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 480
					if signatures then -- 480
						signatures = getParamDocs(signatures) -- 481
						if signatures then -- 481
							return { -- 482
								success = true, -- 482
								signatures = signatures -- 482
							} -- 482
						end -- 481
					end -- 480
				elseif "yue" == lang then -- 483
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 484
					if not luaCodes then -- 485
						return { -- 485
							success = false -- 485
						} -- 485
					end -- 485
					do -- 486
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 486
						if chainOp then -- 486
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 487
							if withVar then -- 487
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 488
							end -- 487
						end -- 486
					end -- 486
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 489
					if signatures then -- 489
						signatures = getParamDocs(signatures) -- 490
						if signatures then -- 490
							return { -- 491
								success = true, -- 491
								signatures = signatures -- 491
							} -- 491
						end -- 490
					else -- 492
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 492
						if signatures then -- 492
							signatures = getParamDocs(signatures) -- 493
							if signatures then -- 493
								return { -- 494
									success = true, -- 494
									signatures = signatures -- 494
								} -- 494
							end -- 493
						end -- 492
					end -- 489
				end -- 477
			end -- 475
		end -- 475
	end -- 475
	return { -- 474
		success = false -- 474
	} -- 474
end) -- 474
local luaKeywords = { -- 497
	'and', -- 497
	'break', -- 498
	'do', -- 499
	'else', -- 500
	'elseif', -- 501
	'end', -- 502
	'false', -- 503
	'for', -- 504
	'function', -- 505
	'goto', -- 506
	'if', -- 507
	'in', -- 508
	'local', -- 509
	'nil', -- 510
	'not', -- 511
	'or', -- 512
	'repeat', -- 513
	'return', -- 514
	'then', -- 515
	'true', -- 516
	'until', -- 517
	'while' -- 518
} -- 496
local tealKeywords = { -- 522
	'record', -- 522
	'as', -- 523
	'is', -- 524
	'type', -- 525
	'embed', -- 526
	'enum', -- 527
	'global', -- 528
	'any', -- 529
	'boolean', -- 530
	'integer', -- 531
	'number', -- 532
	'string', -- 533
	'thread' -- 534
} -- 521
local yueKeywords = { -- 538
	"and", -- 538
	"break", -- 539
	"do", -- 540
	"else", -- 541
	"elseif", -- 542
	"false", -- 543
	"for", -- 544
	"goto", -- 545
	"if", -- 546
	"in", -- 547
	"local", -- 548
	"nil", -- 549
	"not", -- 550
	"or", -- 551
	"repeat", -- 552
	"return", -- 553
	"then", -- 554
	"true", -- 555
	"until", -- 556
	"while", -- 557
	"as", -- 558
	"class", -- 559
	"continue", -- 560
	"export", -- 561
	"extends", -- 562
	"from", -- 563
	"global", -- 564
	"import", -- 565
	"macro", -- 566
	"switch", -- 567
	"try", -- 568
	"unless", -- 569
	"using", -- 570
	"when", -- 571
	"with" -- 572
} -- 537
local _anon_func_3 = function(f) -- 608
	local _val_0 = Path:getExt(f) -- 608
	return "ttf" == _val_0 or "otf" == _val_0 -- 608
end -- 608
local _anon_func_4 = function(suggestions) -- 634
	local _tbl_0 = { } -- 634
	for _index_0 = 1, #suggestions do -- 634
		local item = suggestions[_index_0] -- 634
		_tbl_0[item[1] .. item[2]] = item -- 634
	end -- 634
	return _tbl_0 -- 634
end -- 634
HttpServer:postSchedule("/complete", function(req) -- 575
	do -- 576
		local _type_0 = type(req) -- 576
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 576
		if _tab_0 then -- 576
			local lang -- 576
			do -- 576
				local _obj_0 = req.body -- 576
				local _type_1 = type(_obj_0) -- 576
				if "table" == _type_1 or "userdata" == _type_1 then -- 576
					lang = _obj_0.lang -- 576
				end -- 576
			end -- 576
			local file -- 576
			do -- 576
				local _obj_0 = req.body -- 576
				local _type_1 = type(_obj_0) -- 576
				if "table" == _type_1 or "userdata" == _type_1 then -- 576
					file = _obj_0.file -- 576
				end -- 576
			end -- 576
			local content -- 576
			do -- 576
				local _obj_0 = req.body -- 576
				local _type_1 = type(_obj_0) -- 576
				if "table" == _type_1 or "userdata" == _type_1 then -- 576
					content = _obj_0.content -- 576
				end -- 576
			end -- 576
			local line -- 576
			do -- 576
				local _obj_0 = req.body -- 576
				local _type_1 = type(_obj_0) -- 576
				if "table" == _type_1 or "userdata" == _type_1 then -- 576
					line = _obj_0.line -- 576
				end -- 576
			end -- 576
			local row -- 576
			do -- 576
				local _obj_0 = req.body -- 576
				local _type_1 = type(_obj_0) -- 576
				if "table" == _type_1 or "userdata" == _type_1 then -- 576
					row = _obj_0.row -- 576
				end -- 576
			end -- 576
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 576
				local searchPath = getSearchPath(file) -- 577
				repeat -- 578
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 579
					if lang == "yue" then -- 580
						if not item then -- 581
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 581
						end -- 581
						if not item then -- 582
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 582
						end -- 582
					end -- 580
					local searchType = nil -- 583
					if not item then -- 584
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 585
						if lang == "yue" then -- 586
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 587
						end -- 586
						if (item ~= nil) then -- 588
							searchType = "Image" -- 588
						end -- 588
					end -- 584
					if not item then -- 589
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 590
						if lang == "yue" then -- 591
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 592
						end -- 591
						if (item ~= nil) then -- 593
							searchType = "Font" -- 593
						end -- 593
					end -- 589
					if not item then -- 594
						break -- 594
					end -- 594
					local searchPaths = Content.searchPaths -- 595
					local _list_0 = getSearchFolders(file) -- 596
					for _index_0 = 1, #_list_0 do -- 596
						local folder = _list_0[_index_0] -- 596
						searchPaths[#searchPaths + 1] = folder -- 597
					end -- 596
					if searchType then -- 598
						searchPaths[#searchPaths + 1] = Content.assetPath -- 598
					end -- 598
					local tokens -- 599
					do -- 599
						local _accum_0 = { } -- 599
						local _len_0 = 1 -- 599
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 599
							_accum_0[_len_0] = mod -- 599
							_len_0 = _len_0 + 1 -- 599
						end -- 599
						tokens = _accum_0 -- 599
					end -- 599
					local suggestions = { } -- 600
					for _index_0 = 1, #searchPaths do -- 601
						local path = searchPaths[_index_0] -- 601
						local sPath = Path(path, table.unpack(tokens)) -- 602
						if not Content:exist(sPath) then -- 603
							goto _continue_0 -- 603
						end -- 603
						if searchType == "Font" then -- 604
							local fontPath = Path(sPath, "Font") -- 605
							if Content:exist(fontPath) then -- 606
								local _list_1 = Content:getFiles(fontPath) -- 607
								for _index_1 = 1, #_list_1 do -- 607
									local f = _list_1[_index_1] -- 607
									if _anon_func_3(f) then -- 608
										if "." == f:sub(1, 1) then -- 609
											goto _continue_1 -- 609
										end -- 609
										suggestions[#suggestions + 1] = { -- 610
											Path:getName(f), -- 610
											"font", -- 610
											"field" -- 610
										} -- 610
									end -- 608
									::_continue_1:: -- 608
								end -- 607
							end -- 606
						end -- 604
						local _list_1 = Content:getFiles(sPath) -- 611
						for _index_1 = 1, #_list_1 do -- 611
							local f = _list_1[_index_1] -- 611
							if "Image" == searchType then -- 612
								do -- 613
									local _exp_0 = Path:getExt(f) -- 613
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 613
										if "." == f:sub(1, 1) then -- 614
											goto _continue_2 -- 614
										end -- 614
										suggestions[#suggestions + 1] = { -- 615
											f, -- 615
											"image", -- 615
											"field" -- 615
										} -- 615
									end -- 613
								end -- 613
								goto _continue_2 -- 616
							elseif "Font" == searchType then -- 617
								do -- 618
									local _exp_0 = Path:getExt(f) -- 618
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 618
										if "." == f:sub(1, 1) then -- 619
											goto _continue_2 -- 619
										end -- 619
										suggestions[#suggestions + 1] = { -- 620
											f, -- 620
											"font", -- 620
											"field" -- 620
										} -- 620
									end -- 618
								end -- 618
								goto _continue_2 -- 621
							end -- 612
							local _exp_0 = Path:getExt(f) -- 622
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 622
								local name = Path:getName(f) -- 623
								if "d" == Path:getExt(name) then -- 624
									goto _continue_2 -- 624
								end -- 624
								if "." == name:sub(1, 1) then -- 625
									goto _continue_2 -- 625
								end -- 625
								suggestions[#suggestions + 1] = { -- 626
									name, -- 626
									"module", -- 626
									"field" -- 626
								} -- 626
							end -- 622
							::_continue_2:: -- 612
						end -- 611
						local _list_2 = Content:getDirs(sPath) -- 627
						for _index_1 = 1, #_list_2 do -- 627
							local dir = _list_2[_index_1] -- 627
							if "." == dir:sub(1, 1) then -- 628
								goto _continue_3 -- 628
							end -- 628
							suggestions[#suggestions + 1] = { -- 629
								dir, -- 629
								"folder", -- 629
								"variable" -- 629
							} -- 629
							::_continue_3:: -- 628
						end -- 627
						::_continue_0:: -- 602
					end -- 601
					if item == "" and not searchType then -- 630
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 631
						for _index_0 = 1, #_list_1 do -- 631
							local _des_0 = _list_1[_index_0] -- 631
							local name = _des_0[1] -- 631
							suggestions[#suggestions + 1] = { -- 632
								name, -- 632
								"dora module", -- 632
								"function" -- 632
							} -- 632
						end -- 631
					end -- 630
					if #suggestions > 0 then -- 633
						do -- 634
							local _accum_0 = { } -- 634
							local _len_0 = 1 -- 634
							for _, v in pairs(_anon_func_4(suggestions)) do -- 634
								_accum_0[_len_0] = v -- 634
								_len_0 = _len_0 + 1 -- 634
							end -- 634
							suggestions = _accum_0 -- 634
						end -- 634
						return { -- 635
							success = true, -- 635
							suggestions = suggestions -- 635
						} -- 635
					else -- 637
						return { -- 637
							success = false -- 637
						} -- 637
					end -- 633
				until true -- 578
				if "tl" == lang or "lua" == lang then -- 639
					do -- 640
						local isTIC80 = CheckTIC80Code(content) -- 640
						if isTIC80 then -- 640
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 641
						end -- 640
					end -- 640
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 642
					if not line:match("[%.:]$") then -- 643
						local checkSet -- 644
						do -- 644
							local _tbl_0 = { } -- 644
							for _index_0 = 1, #suggestions do -- 644
								local _des_0 = suggestions[_index_0] -- 644
								local name = _des_0[1] -- 644
								_tbl_0[name] = true -- 644
							end -- 644
							checkSet = _tbl_0 -- 644
						end -- 644
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 645
						for _index_0 = 1, #_list_0 do -- 645
							local item = _list_0[_index_0] -- 645
							if not checkSet[item[1]] then -- 646
								suggestions[#suggestions + 1] = item -- 646
							end -- 646
						end -- 645
						for _index_0 = 1, #luaKeywords do -- 647
							local word = luaKeywords[_index_0] -- 647
							suggestions[#suggestions + 1] = { -- 648
								word, -- 648
								"keyword", -- 648
								"keyword" -- 648
							} -- 648
						end -- 647
						if lang == "tl" then -- 649
							for _index_0 = 1, #tealKeywords do -- 650
								local word = tealKeywords[_index_0] -- 650
								suggestions[#suggestions + 1] = { -- 651
									word, -- 651
									"keyword", -- 651
									"keyword" -- 651
								} -- 651
							end -- 650
						end -- 649
					end -- 643
					if #suggestions > 0 then -- 652
						return { -- 653
							success = true, -- 653
							suggestions = suggestions -- 653
						} -- 653
					end -- 652
				elseif "yue" == lang then -- 654
					local suggestions = { } -- 655
					local gotGlobals = false -- 656
					do -- 657
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 657
						if luaCodes then -- 657
							gotGlobals = true -- 658
							do -- 659
								local chainOp = line:match("[^%w_]([%.\\])$") -- 659
								if chainOp then -- 659
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 660
									if not withVar then -- 661
										return { -- 661
											success = false -- 661
										} -- 661
									end -- 661
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 662
								elseif line:match("^([%.\\])$") then -- 663
									return { -- 664
										success = false -- 664
									} -- 664
								end -- 659
							end -- 659
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 665
							for _index_0 = 1, #_list_0 do -- 665
								local item = _list_0[_index_0] -- 665
								suggestions[#suggestions + 1] = item -- 665
							end -- 665
							if #suggestions == 0 then -- 666
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 667
								for _index_0 = 1, #_list_1 do -- 667
									local item = _list_1[_index_0] -- 667
									suggestions[#suggestions + 1] = item -- 667
								end -- 667
							end -- 666
						end -- 657
					end -- 657
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 668
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
						if not gotGlobals then -- 672
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 673
							for _index_0 = 1, #_list_1 do -- 673
								local item = _list_1[_index_0] -- 673
								if not checkSet[item[1]] then -- 674
									suggestions[#suggestions + 1] = item -- 674
								end -- 674
							end -- 673
						end -- 672
						for _index_0 = 1, #yueKeywords do -- 675
							local word = yueKeywords[_index_0] -- 675
							if not checkSet[word] then -- 676
								suggestions[#suggestions + 1] = { -- 677
									word, -- 677
									"keyword", -- 677
									"keyword" -- 677
								} -- 677
							end -- 676
						end -- 675
					end -- 668
					if #suggestions > 0 then -- 678
						return { -- 679
							success = true, -- 679
							suggestions = suggestions -- 679
						} -- 679
					end -- 678
				elseif "xml" == lang then -- 680
					local items = xml.complete(content) -- 681
					if #items > 0 then -- 682
						local suggestions -- 683
						do -- 683
							local _accum_0 = { } -- 683
							local _len_0 = 1 -- 683
							for _index_0 = 1, #items do -- 683
								local _des_0 = items[_index_0] -- 683
								local label, insertText = _des_0[1], _des_0[2] -- 683
								_accum_0[_len_0] = { -- 684
									label, -- 684
									insertText, -- 684
									"field" -- 684
								} -- 684
								_len_0 = _len_0 + 1 -- 684
							end -- 683
							suggestions = _accum_0 -- 683
						end -- 683
						return { -- 685
							success = true, -- 685
							suggestions = suggestions -- 685
						} -- 685
					end -- 682
				end -- 639
			end -- 576
		end -- 576
	end -- 576
	return { -- 575
		success = false -- 575
	} -- 575
end) -- 575
HttpServer:upload("/upload", function(req, filename) -- 689
	do -- 690
		local _type_0 = type(req) -- 690
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 690
		if _tab_0 then -- 690
			local path -- 690
			do -- 690
				local _obj_0 = req.params -- 690
				local _type_1 = type(_obj_0) -- 690
				if "table" == _type_1 or "userdata" == _type_1 then -- 690
					path = _obj_0.path -- 690
				end -- 690
			end -- 690
			if path ~= nil then -- 690
				local uploadPath = Path(Content.writablePath, ".upload") -- 691
				if not Content:exist(uploadPath) then -- 692
					Content:mkdir(uploadPath) -- 693
				end -- 692
				local targetPath = Path(uploadPath, filename) -- 694
				Content:mkdir(Path:getPath(targetPath)) -- 695
				return targetPath -- 696
			end -- 690
		end -- 690
	end -- 690
	return nil -- 689
end, function(req, file) -- 697
	do -- 698
		local _type_0 = type(req) -- 698
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 698
		if _tab_0 then -- 698
			local path -- 698
			do -- 698
				local _obj_0 = req.params -- 698
				local _type_1 = type(_obj_0) -- 698
				if "table" == _type_1 or "userdata" == _type_1 then -- 698
					path = _obj_0.path -- 698
				end -- 698
			end -- 698
			if path ~= nil then -- 698
				path = Path(Content.writablePath, path) -- 699
				if Content:exist(path) then -- 700
					local uploadPath = Path(Content.writablePath, ".upload") -- 701
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 702
					Content:mkdir(Path:getPath(targetPath)) -- 703
					if Content:move(file, targetPath) then -- 704
						return true -- 705
					end -- 704
				end -- 700
			end -- 698
		end -- 698
	end -- 698
	return false -- 697
end) -- 687
HttpServer:post("/list", function(req) -- 708
	do -- 709
		local _type_0 = type(req) -- 709
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 709
		if _tab_0 then -- 709
			local path -- 709
			do -- 709
				local _obj_0 = req.body -- 709
				local _type_1 = type(_obj_0) -- 709
				if "table" == _type_1 or "userdata" == _type_1 then -- 709
					path = _obj_0.path -- 709
				end -- 709
			end -- 709
			if path ~= nil then -- 709
				if Content:exist(path) then -- 710
					local files = { } -- 711
					local visitAssets -- 712
					visitAssets = function(path, folder) -- 712
						local dirs = Content:getDirs(path) -- 713
						for _index_0 = 1, #dirs do -- 714
							local dir = dirs[_index_0] -- 714
							if dir:match("^%.") then -- 715
								goto _continue_0 -- 715
							end -- 715
							local current -- 716
							if folder == "" then -- 716
								current = dir -- 717
							else -- 719
								current = Path(folder, dir) -- 719
							end -- 716
							files[#files + 1] = current -- 720
							visitAssets(Path(path, dir), current) -- 721
							::_continue_0:: -- 715
						end -- 714
						local fs = Content:getFiles(path) -- 722
						for _index_0 = 1, #fs do -- 723
							local f = fs[_index_0] -- 723
							if f:match("^%.") then -- 724
								goto _continue_1 -- 724
							end -- 724
							if folder == "" then -- 725
								files[#files + 1] = f -- 726
							else -- 728
								files[#files + 1] = Path(folder, f) -- 728
							end -- 725
							::_continue_1:: -- 724
						end -- 723
					end -- 712
					visitAssets(path, "") -- 729
					if #files == 0 then -- 730
						files = nil -- 730
					end -- 730
					return { -- 731
						success = true, -- 731
						files = files -- 731
					} -- 731
				end -- 710
			end -- 709
		end -- 709
	end -- 709
	return { -- 708
		success = false -- 708
	} -- 708
end) -- 708
HttpServer:post("/info", function() -- 733
	local Entry = require("Script.Dev.Entry") -- 734
	local webProfiler, drawerWidth -- 735
	do -- 735
		local _obj_0 = Entry.getConfig() -- 735
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 735
	end -- 735
	local engineDev = Entry.getEngineDev() -- 736
	Entry.connectWebIDE() -- 737
	return { -- 739
		platform = App.platform, -- 739
		locale = App.locale, -- 740
		version = App.version, -- 741
		engineDev = engineDev, -- 742
		webProfiler = webProfiler, -- 743
		drawerWidth = drawerWidth -- 744
	} -- 738
end) -- 733
local ensureLLMConfigTable -- 746
ensureLLMConfigTable = function() -- 746
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 747
	if columns and #columns > 0 then -- 748
		local expected = { -- 750
			id = true, -- 750
			name = true, -- 751
			url = true, -- 752
			model = true, -- 753
			api_key = true, -- 754
			context_window = true, -- 755
			temperature = true, -- 756
			max_tokens = true, -- 757
			reasoning_effort = true, -- 758
			supports_function_calling = true, -- 759
			active = true, -- 760
			created_at = true, -- 761
			updated_at = true -- 762
		} -- 749
		local existing = { } -- 764
		local valid = true -- 765
		for _index_0 = 1, #columns do -- 766
			local row = columns[_index_0] -- 766
			local columnName = tostring(row[2]) -- 767
			existing[columnName] = true -- 768
			if not expected[columnName] then -- 769
				valid = false -- 770
				break -- 771
			end -- 769
		end -- 766
		if valid then -- 772
			if not existing.context_window then -- 773
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 774
			end -- 773
			if not existing.temperature then -- 775
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 776
			end -- 775
			if not existing.max_tokens then -- 777
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 778
			end -- 777
			if not existing.reasoning_effort then -- 779
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 780
			end -- 779
			if not existing.supports_function_calling then -- 781
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 782
			end -- 781
		else -- 784
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 784
		end -- 772
	end -- 748
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
			supports_function_calling INTEGER NOT NULL DEFAULT 1,
			active INTEGER NOT NULL DEFAULT 1,
			created_at INTEGER,
			updated_at INTEGER
		);
	]]) -- 785
end -- 746
local normalizeContextWindow -- 803
normalizeContextWindow = function(value) -- 803
	local contextWindow = tonumber(value) -- 804
	if contextWindow == nil or contextWindow < 64000 then -- 805
		return 64000 -- 806
	end -- 805
	return math.max(64000, math.floor(contextWindow)) -- 807
end -- 803
local normalizeTemperature -- 809
normalizeTemperature = function(value) -- 809
	local temperature = tonumber(value) -- 810
	if temperature == nil then -- 811
		return 0.1 -- 812
	end -- 811
	return math.max(0, math.min(2, temperature)) -- 813
end -- 809
local normalizeMaxTokens -- 815
normalizeMaxTokens = function(value) -- 815
	local maxTokens = tonumber(value) -- 816
	if maxTokens == nil or maxTokens < 1 then -- 817
		return 8192 -- 818
	end -- 817
	return math.max(1, math.floor(maxTokens)) -- 819
end -- 815
local normalizeReasoningEffort -- 821
normalizeReasoningEffort = function(value) -- 821
	if value == nil then -- 822
		return "" -- 823
	end -- 822
	local effort = tostring(value) -- 824
	return effort:match("^%s*(.-)%s*$") or "" -- 825
end -- 821
HttpServer:post("/llm/list", function() -- 827
	ensureLLMConfigTable() -- 828
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 829
	local items -- 833
	if rows and #rows > 0 then -- 833
		local _accum_0 = { } -- 834
		local _len_0 = 1 -- 834
		for _index_0 = 1, #rows do -- 834
			local _des_0 = rows[_index_0] -- 834
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 834
			_accum_0[_len_0] = { -- 835
				id = id, -- 835
				name = name, -- 835
				url = url, -- 835
				model = model, -- 835
				key = key, -- 835
				contextWindow = normalizeContextWindow(contextWindow), -- 835
				temperature = normalizeTemperature(temperature), -- 835
				maxTokens = normalizeMaxTokens(maxTokens), -- 835
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 835
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 835
				active = active ~= 0 -- 835
			} -- 835
			_len_0 = _len_0 + 1 -- 835
		end -- 834
		items = _accum_0 -- 833
	end -- 833
	return { -- 836
		success = true, -- 836
		items = items -- 836
	} -- 836
end) -- 827
HttpServer:post("/llm/create", function(req) -- 838
	ensureLLMConfigTable() -- 839
	do -- 840
		local _type_0 = type(req) -- 840
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 840
		if _tab_0 then -- 840
			local body = req.body -- 840
			if body ~= nil then -- 840
				local name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.supportsFunctionCalling -- 841
				local now = os.time() -- 842
				if name == nil or url == nil or model == nil or key == nil then -- 843
					return { -- 844
						success = false, -- 844
						message = "invalid" -- 844
					} -- 844
				end -- 843
				contextWindow = normalizeContextWindow(contextWindow) -- 845
				temperature = normalizeTemperature(temperature) -- 846
				maxTokens = normalizeMaxTokens(maxTokens) -- 847
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 848
				if supportsFunctionCalling == false then -- 849
					supportsFunctionCalling = 0 -- 849
				else -- 849
					supportsFunctionCalling = 1 -- 849
				end -- 849
				if active then -- 850
					active = 1 -- 850
				else -- 850
					active = 0 -- 850
				end -- 850
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 857
					tostring(name), -- 857
					tostring(url), -- 858
					tostring(model), -- 859
					tostring(key), -- 860
					contextWindow, -- 861
					temperature, -- 862
					maxTokens, -- 863
					reasoningEffort, -- 864
					supportsFunctionCalling, -- 865
					active, -- 866
					now, -- 867
					now -- 868
				}) -- 851
				return { -- 870
					success = affected >= 0 -- 870
				} -- 870
			end -- 840
		end -- 840
	end -- 840
	return { -- 838
		success = false, -- 838
		message = "invalid" -- 838
	} -- 838
end) -- 838
HttpServer:post("/llm/update", function(req) -- 872
	ensureLLMConfigTable() -- 873
	do -- 874
		local _type_0 = type(req) -- 874
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 874
		if _tab_0 then -- 874
			local body = req.body -- 874
			if body ~= nil then -- 874
				local id, name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.supportsFunctionCalling -- 875
				local now = os.time() -- 876
				id = tonumber(id) -- 877
				if id == nil then -- 878
					return { -- 879
						success = false, -- 879
						message = "invalid" -- 879
					} -- 879
				end -- 878
				contextWindow = normalizeContextWindow(contextWindow) -- 880
				temperature = normalizeTemperature(temperature) -- 881
				maxTokens = normalizeMaxTokens(maxTokens) -- 882
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 883
				if supportsFunctionCalling == false then -- 884
					supportsFunctionCalling = 0 -- 884
				else -- 884
					supportsFunctionCalling = 1 -- 884
				end -- 884
				if active then -- 885
					active = 1 -- 885
				else -- 885
					active = 0 -- 885
				end -- 885
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 890
					tostring(name), -- 890
					tostring(url), -- 891
					tostring(model), -- 892
					tostring(key), -- 893
					contextWindow, -- 894
					temperature, -- 895
					maxTokens, -- 896
					reasoningEffort, -- 897
					supportsFunctionCalling, -- 898
					active, -- 899
					now, -- 900
					id -- 901
				}) -- 886
				return { -- 903
					success = affected >= 0 -- 903
				} -- 903
			end -- 874
		end -- 874
	end -- 874
	return { -- 872
		success = false, -- 872
		message = "invalid" -- 872
	} -- 872
end) -- 872
HttpServer:post("/llm/delete", function(req) -- 905
	ensureLLMConfigTable() -- 906
	do -- 907
		local _type_0 = type(req) -- 907
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 907
		if _tab_0 then -- 907
			local id -- 907
			do -- 907
				local _obj_0 = req.body -- 907
				local _type_1 = type(_obj_0) -- 907
				if "table" == _type_1 or "userdata" == _type_1 then -- 907
					id = _obj_0.id -- 907
				end -- 907
			end -- 907
			if id ~= nil then -- 907
				id = tonumber(id) -- 908
				if id == nil then -- 909
					return { -- 910
						success = false, -- 910
						message = "invalid" -- 910
					} -- 910
				end -- 909
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 911
					id -- 911
				}) -- 911
				return { -- 912
					success = affected >= 0 -- 912
				} -- 912
			end -- 907
		end -- 907
	end -- 907
	return { -- 905
		success = false, -- 905
		message = "invalid" -- 905
	} -- 905
end) -- 905
HttpServer:post("/new", function(req) -- 914
	do -- 915
		local _type_0 = type(req) -- 915
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 915
		if _tab_0 then -- 915
			local path -- 915
			do -- 915
				local _obj_0 = req.body -- 915
				local _type_1 = type(_obj_0) -- 915
				if "table" == _type_1 or "userdata" == _type_1 then -- 915
					path = _obj_0.path -- 915
				end -- 915
			end -- 915
			local content -- 915
			do -- 915
				local _obj_0 = req.body -- 915
				local _type_1 = type(_obj_0) -- 915
				if "table" == _type_1 or "userdata" == _type_1 then -- 915
					content = _obj_0.content -- 915
				end -- 915
			end -- 915
			local folder -- 915
			do -- 915
				local _obj_0 = req.body -- 915
				local _type_1 = type(_obj_0) -- 915
				if "table" == _type_1 or "userdata" == _type_1 then -- 915
					folder = _obj_0.folder -- 915
				end -- 915
			end -- 915
			if path ~= nil and content ~= nil and folder ~= nil then -- 915
				if Content:exist(path) then -- 916
					return { -- 917
						success = false, -- 917
						message = "TargetExisted" -- 917
					} -- 917
				end -- 916
				local parent = Path:getPath(path) -- 918
				local files = Content:getFiles(parent) -- 919
				if folder then -- 920
					local name = Path:getFilename(path):lower() -- 921
					for _index_0 = 1, #files do -- 922
						local file = files[_index_0] -- 922
						if name == Path:getFilename(file):lower() then -- 923
							return { -- 924
								success = false, -- 924
								message = "TargetExisted" -- 924
							} -- 924
						end -- 923
					end -- 922
					if Content:mkdir(path) then -- 925
						return { -- 926
							success = true -- 926
						} -- 926
					end -- 925
				else -- 928
					local name = Path:getName(path):lower() -- 928
					for _index_0 = 1, #files do -- 929
						local file = files[_index_0] -- 929
						if name == Path:getName(file):lower() then -- 930
							local ext = Path:getExt(file) -- 931
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 932
								goto _continue_0 -- 933
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 934
								goto _continue_0 -- 935
							end -- 932
							return { -- 936
								success = false, -- 936
								message = "SourceExisted" -- 936
							} -- 936
						end -- 930
						::_continue_0:: -- 930
					end -- 929
					if Content:save(path, content) then -- 937
						return { -- 938
							success = true -- 938
						} -- 938
					end -- 937
				end -- 920
			end -- 915
		end -- 915
	end -- 915
	return { -- 914
		success = false, -- 914
		message = "Failed" -- 914
	} -- 914
end) -- 914
HttpServer:post("/delete", function(req) -- 940
	do -- 941
		local _type_0 = type(req) -- 941
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 941
		if _tab_0 then -- 941
			local path -- 941
			do -- 941
				local _obj_0 = req.body -- 941
				local _type_1 = type(_obj_0) -- 941
				if "table" == _type_1 or "userdata" == _type_1 then -- 941
					path = _obj_0.path -- 941
				end -- 941
			end -- 941
			if path ~= nil then -- 941
				if Content:exist(path) then -- 942
					local projectRoot -- 943
					if Content:isdir(path) and isProjectRootDir(path) then -- 943
						projectRoot = path -- 943
					else -- 943
						projectRoot = nil -- 943
					end -- 943
					local parent = Path:getPath(path) -- 944
					local files = Content:getFiles(parent) -- 945
					local name = Path:getName(path):lower() -- 946
					local ext = Path:getExt(path) -- 947
					for _index_0 = 1, #files do -- 948
						local file = files[_index_0] -- 948
						if name == Path:getName(file):lower() then -- 949
							local _exp_0 = Path:getExt(file) -- 950
							if "tl" == _exp_0 then -- 950
								if ("vs" == ext) then -- 950
									Content:remove(Path(parent, file)) -- 951
								end -- 950
							elseif "lua" == _exp_0 then -- 952
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 952
									Content:remove(Path(parent, file)) -- 953
								end -- 952
							end -- 950
						end -- 949
					end -- 948
					if Content:remove(path) then -- 954
						if projectRoot then -- 955
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 956
						end -- 955
						return { -- 957
							success = true -- 957
						} -- 957
					end -- 954
				end -- 942
			end -- 941
		end -- 941
	end -- 941
	return { -- 940
		success = false -- 940
	} -- 940
end) -- 940
HttpServer:post("/rename", function(req) -- 959
	do -- 960
		local _type_0 = type(req) -- 960
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 960
		if _tab_0 then -- 960
			local old -- 960
			do -- 960
				local _obj_0 = req.body -- 960
				local _type_1 = type(_obj_0) -- 960
				if "table" == _type_1 or "userdata" == _type_1 then -- 960
					old = _obj_0.old -- 960
				end -- 960
			end -- 960
			local new -- 960
			do -- 960
				local _obj_0 = req.body -- 960
				local _type_1 = type(_obj_0) -- 960
				if "table" == _type_1 or "userdata" == _type_1 then -- 960
					new = _obj_0.new -- 960
				end -- 960
			end -- 960
			if old ~= nil and new ~= nil then -- 960
				if Content:exist(old) and not Content:exist(new) then -- 961
					local renamedDir = Content:isdir(old) -- 962
					local parent = Path:getPath(new) -- 963
					local files = Content:getFiles(parent) -- 964
					if renamedDir then -- 965
						local name = Path:getFilename(new):lower() -- 966
						for _index_0 = 1, #files do -- 967
							local file = files[_index_0] -- 967
							if name == Path:getFilename(file):lower() then -- 968
								return { -- 969
									success = false -- 969
								} -- 969
							end -- 968
						end -- 967
					else -- 971
						local name = Path:getName(new):lower() -- 971
						local ext = Path:getExt(new) -- 972
						for _index_0 = 1, #files do -- 973
							local file = files[_index_0] -- 973
							if name == Path:getName(file):lower() then -- 974
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 975
									goto _continue_0 -- 976
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 977
									goto _continue_0 -- 978
								end -- 975
								return { -- 979
									success = false -- 979
								} -- 979
							end -- 974
							::_continue_0:: -- 974
						end -- 973
					end -- 965
					if Content:move(old, new) then -- 980
						if renamedDir then -- 981
							AgentSession.renameSessionsByProjectRoot(old, new) -- 982
						end -- 981
						local newParent = Path:getPath(new) -- 983
						parent = Path:getPath(old) -- 984
						files = Content:getFiles(parent) -- 985
						local newName = Path:getName(new) -- 986
						local oldName = Path:getName(old) -- 987
						local name = oldName:lower() -- 988
						local ext = Path:getExt(old) -- 989
						for _index_0 = 1, #files do -- 990
							local file = files[_index_0] -- 990
							if name == Path:getName(file):lower() then -- 991
								local _exp_0 = Path:getExt(file) -- 992
								if "tl" == _exp_0 then -- 992
									if ("vs" == ext) then -- 992
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 993
									end -- 992
								elseif "lua" == _exp_0 then -- 994
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 994
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 995
									end -- 994
								end -- 992
							end -- 991
						end -- 990
						return { -- 996
							success = true -- 996
						} -- 996
					end -- 980
				end -- 961
			end -- 960
		end -- 960
	end -- 960
	return { -- 959
		success = false -- 959
	} -- 959
end) -- 959
HttpServer:post("/exist", function(req) -- 998
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
			if file ~= nil then -- 999
				do -- 1000
					local projFile = req.body.projFile -- 1000
					if projFile then -- 1000
						local projDir = getProjectDirFromFile(projFile) -- 1001
						if projDir then -- 1001
							local scriptDir = Path(projDir, "Script") -- 1002
							local searchPaths = Content.searchPaths -- 1003
							if Content:exist(scriptDir) then -- 1004
								Content:addSearchPath(scriptDir) -- 1004
							end -- 1004
							if Content:exist(projDir) then -- 1005
								Content:addSearchPath(projDir) -- 1005
							end -- 1005
							local _ <close> = setmetatable({ }, { -- 1006
								__close = function() -- 1006
									Content.searchPaths = searchPaths -- 1006
								end -- 1006
							}) -- 1006
							return { -- 1007
								success = Content:exist(file) -- 1007
							} -- 1007
						end -- 1001
					end -- 1000
				end -- 1000
				return { -- 1008
					success = Content:exist(file) -- 1008
				} -- 1008
			end -- 999
		end -- 999
	end -- 999
	return { -- 998
		success = false -- 998
	} -- 998
end) -- 998
HttpServer:postSchedule("/read", function(req) -- 1010
	do -- 1011
		local _type_0 = type(req) -- 1011
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1011
		if _tab_0 then -- 1011
			local path -- 1011
			do -- 1011
				local _obj_0 = req.body -- 1011
				local _type_1 = type(_obj_0) -- 1011
				if "table" == _type_1 or "userdata" == _type_1 then -- 1011
					path = _obj_0.path -- 1011
				end -- 1011
			end -- 1011
			if path ~= nil then -- 1011
				local readFile -- 1012
				readFile = function() -- 1012
					if Content:exist(path) then -- 1013
						local content = Content:loadAsync(path) -- 1014
						if content then -- 1014
							return { -- 1015
								content = content, -- 1015
								success = true -- 1015
							} -- 1015
						end -- 1014
					end -- 1013
					return nil -- 1012
				end -- 1012
				do -- 1016
					local projFile = req.body.projFile -- 1016
					if projFile then -- 1016
						local projDir = getProjectDirFromFile(projFile) -- 1017
						if projDir then -- 1017
							local scriptDir = Path(projDir, "Script") -- 1018
							local searchPaths = Content.searchPaths -- 1019
							if Content:exist(scriptDir) then -- 1020
								Content:addSearchPath(scriptDir) -- 1020
							end -- 1020
							if Content:exist(projDir) then -- 1021
								Content:addSearchPath(projDir) -- 1021
							end -- 1021
							local _ <close> = setmetatable({ }, { -- 1022
								__close = function() -- 1022
									Content.searchPaths = searchPaths -- 1022
								end -- 1022
							}) -- 1022
							local result = readFile() -- 1023
							if result then -- 1023
								return result -- 1023
							end -- 1023
						end -- 1017
					end -- 1016
				end -- 1016
				local result = readFile() -- 1024
				if result then -- 1024
					return result -- 1024
				end -- 1024
			end -- 1011
		end -- 1011
	end -- 1011
	return { -- 1010
		success = false -- 1010
	} -- 1010
end) -- 1010
HttpServer:get("/read-sync", function(req) -- 1026
	do -- 1027
		local _type_0 = type(req) -- 1027
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1027
		if _tab_0 then -- 1027
			local params = req.params -- 1027
			if params ~= nil then -- 1027
				local path = params.path -- 1028
				local exts -- 1029
				if params.exts then -- 1029
					local _accum_0 = { } -- 1030
					local _len_0 = 1 -- 1030
					for ext in params.exts:gmatch("[^|]*") do -- 1030
						_accum_0[_len_0] = ext -- 1031
						_len_0 = _len_0 + 1 -- 1031
					end -- 1030
					exts = _accum_0 -- 1029
				else -- 1032
					exts = { -- 1032
						"" -- 1032
					} -- 1032
				end -- 1029
				local readFile -- 1033
				readFile = function() -- 1033
					for _index_0 = 1, #exts do -- 1034
						local ext = exts[_index_0] -- 1034
						local targetPath = path .. ext -- 1035
						if Content:exist(targetPath) then -- 1036
							local content = Content:load(targetPath) -- 1037
							if content then -- 1037
								return { -- 1038
									content = content, -- 1038
									success = true, -- 1038
									fullPath = Content:getFullPath(targetPath) -- 1038
								} -- 1038
							end -- 1037
						end -- 1036
					end -- 1034
					return nil -- 1033
				end -- 1033
				local searchPaths = Content.searchPaths -- 1039
				local _ <close> = setmetatable({ }, { -- 1040
					__close = function() -- 1040
						Content.searchPaths = searchPaths -- 1040
					end -- 1040
				}) -- 1040
				do -- 1041
					local projFile = req.params.projFile -- 1041
					if projFile then -- 1041
						local projDir = getProjectDirFromFile(projFile) -- 1042
						if projDir then -- 1042
							local scriptDir = Path(projDir, "Script") -- 1043
							if Content:exist(scriptDir) then -- 1044
								Content:addSearchPath(scriptDir) -- 1044
							end -- 1044
							if Content:exist(projDir) then -- 1045
								Content:addSearchPath(projDir) -- 1045
							end -- 1045
						else -- 1047
							projDir = Path:getPath(projFile) -- 1047
							if Content:exist(projDir) then -- 1048
								Content:addSearchPath(projDir) -- 1048
							end -- 1048
						end -- 1042
					end -- 1041
				end -- 1041
				local result = readFile() -- 1049
				if result then -- 1049
					return result -- 1049
				end -- 1049
			end -- 1027
		end -- 1027
	end -- 1027
	return { -- 1026
		success = false -- 1026
	} -- 1026
end) -- 1026
local compileFileAsync -- 1051
compileFileAsync = function(inputFile, sourceCodes) -- 1051
	local file = inputFile -- 1052
	local searchPath -- 1053
	do -- 1053
		local dir = getProjectDirFromFile(inputFile) -- 1053
		if dir then -- 1053
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 1054
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1055
		else -- 1057
			file = Path:getRelative(inputFile, Content.writablePath) -- 1057
			if file:sub(1, 2) == ".." then -- 1058
				file = Path:getRelative(inputFile, Content.assetPath) -- 1059
			end -- 1058
			searchPath = "" -- 1060
		end -- 1053
	end -- 1053
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1061
	local yueext = yue.options.extension -- 1062
	local resultCodes = nil -- 1063
	local resultError = nil -- 1064
	do -- 1065
		local _exp_0 = Path:getExt(inputFile) -- 1065
		if yueext == _exp_0 then -- 1065
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1066
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1067
				if not codes then -- 1068
					resultError = err -- 1069
					return -- 1070
				end -- 1068
				local extraGlobal -- 1071
				if isTIC80 then -- 1071
					extraGlobal = tic80APIs -- 1071
				else -- 1071
					extraGlobal = nil -- 1071
				end -- 1071
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1072
				if not success then -- 1073
					resultError = message -- 1074
					return -- 1075
				end -- 1073
				if codes == "" then -- 1076
					resultCodes = "" -- 1077
					return nil -- 1078
				end -- 1076
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1079
				return resultCodes -- 1080
			end, function(success) -- 1067
				if not success then -- 1081
					Content:remove(outputFile) -- 1082
					if resultCodes == nil then -- 1083
						resultCodes = false -- 1084
					end -- 1083
				end -- 1081
			end) -- 1067
		elseif "tl" == _exp_0 then -- 1085
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1086
			if isTIC80 then -- 1087
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1088
			end -- 1087
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1089
			if codes then -- 1089
				if isTIC80 then -- 1090
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1091
				end -- 1090
				resultCodes = codes -- 1092
				Content:saveAsync(outputFile, codes) -- 1093
			else -- 1095
				Content:remove(outputFile) -- 1095
				resultCodes = false -- 1096
				resultError = err -- 1097
			end -- 1089
		elseif "xml" == _exp_0 then -- 1098
			local codes, err = xml.tolua(sourceCodes) -- 1099
			if codes then -- 1099
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1100
				Content:saveAsync(outputFile, resultCodes) -- 1101
			else -- 1103
				Content:remove(outputFile) -- 1103
				resultCodes = false -- 1104
				resultError = err -- 1105
			end -- 1099
		end -- 1065
	end -- 1065
	wait(function() -- 1106
		return resultCodes ~= nil -- 1106
	end) -- 1106
	if resultCodes then -- 1107
		return resultCodes -- 1108
	else -- 1110
		return nil, resultError -- 1110
	end -- 1107
	return nil -- 1051
end -- 1051
HttpServer:postSchedule("/write", function(req) -- 1112
	do -- 1113
		local _type_0 = type(req) -- 1113
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1113
		if _tab_0 then -- 1113
			local path -- 1113
			do -- 1113
				local _obj_0 = req.body -- 1113
				local _type_1 = type(_obj_0) -- 1113
				if "table" == _type_1 or "userdata" == _type_1 then -- 1113
					path = _obj_0.path -- 1113
				end -- 1113
			end -- 1113
			local content -- 1113
			do -- 1113
				local _obj_0 = req.body -- 1113
				local _type_1 = type(_obj_0) -- 1113
				if "table" == _type_1 or "userdata" == _type_1 then -- 1113
					content = _obj_0.content -- 1113
				end -- 1113
			end -- 1113
			if path ~= nil and content ~= nil then -- 1113
				if Content:saveAsync(path, content) then -- 1114
					do -- 1115
						local _exp_0 = Path:getExt(path) -- 1115
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1115
							if '' == Path:getExt(Path:getName(path)) then -- 1116
								local resultCodes = compileFileAsync(path, content) -- 1117
								return { -- 1118
									success = true, -- 1118
									resultCodes = resultCodes -- 1118
								} -- 1118
							end -- 1116
						end -- 1115
					end -- 1115
					return { -- 1119
						success = true -- 1119
					} -- 1119
				end -- 1114
			end -- 1113
		end -- 1113
	end -- 1113
	return { -- 1112
		success = false -- 1112
	} -- 1112
end) -- 1112
HttpServer:postSchedule("/build", function(req) -- 1121
	do -- 1122
		local _type_0 = type(req) -- 1122
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1122
		if _tab_0 then -- 1122
			local path -- 1122
			do -- 1122
				local _obj_0 = req.body -- 1122
				local _type_1 = type(_obj_0) -- 1122
				if "table" == _type_1 or "userdata" == _type_1 then -- 1122
					path = _obj_0.path -- 1122
				end -- 1122
			end -- 1122
			if path ~= nil then -- 1122
				local _exp_0 = Path:getExt(path) -- 1123
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1123
					if '' == Path:getExt(Path:getName(path)) then -- 1124
						local content = Content:loadAsync(path) -- 1125
						if content then -- 1125
							local resultCodes = compileFileAsync(path, content) -- 1126
							if resultCodes then -- 1126
								return { -- 1127
									success = true, -- 1127
									resultCodes = resultCodes -- 1127
								} -- 1127
							end -- 1126
						end -- 1125
					end -- 1124
				end -- 1123
			end -- 1122
		end -- 1122
	end -- 1122
	return { -- 1121
		success = false -- 1121
	} -- 1121
end) -- 1121
local extentionLevels = { -- 1130
	vs = 2, -- 1130
	bl = 2, -- 1131
	ts = 1, -- 1132
	tsx = 1, -- 1133
	tl = 1, -- 1134
	yue = 1, -- 1135
	xml = 1, -- 1136
	lua = 0 -- 1137
} -- 1129
HttpServer:post("/assets", function() -- 1139
	local Entry = require("Script.Dev.Entry") -- 1142
	local engineDev = Entry.getEngineDev() -- 1143
	local visitAssets -- 1144
	visitAssets = function(path, tag) -- 1144
		local isWorkspace = tag == "Workspace" -- 1145
		local builtin -- 1146
		if tag == "Builtin" then -- 1146
			builtin = true -- 1146
		else -- 1146
			builtin = nil -- 1146
		end -- 1146
		local children = nil -- 1147
		local dirs = Content:getDirs(path) -- 1148
		for _index_0 = 1, #dirs do -- 1149
			local dir = dirs[_index_0] -- 1149
			if isWorkspace then -- 1150
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1151
					goto _continue_0 -- 1152
				end -- 1151
			elseif dir == ".git" then -- 1153
				goto _continue_0 -- 1154
			end -- 1150
			if not children then -- 1155
				children = { } -- 1155
			end -- 1155
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1156
			::_continue_0:: -- 1150
		end -- 1149
		local files = Content:getFiles(path) -- 1157
		local names = { } -- 1158
		for _index_0 = 1, #files do -- 1159
			local file = files[_index_0] -- 1159
			if file:match("^%.") then -- 1160
				goto _continue_1 -- 1160
			end -- 1160
			local name = Path:getName(file) -- 1161
			local ext = names[name] -- 1162
			if ext then -- 1162
				local lv1 -- 1163
				do -- 1163
					local _exp_0 = extentionLevels[ext] -- 1163
					if _exp_0 ~= nil then -- 1163
						lv1 = _exp_0 -- 1163
					else -- 1163
						lv1 = -1 -- 1163
					end -- 1163
				end -- 1163
				ext = Path:getExt(file) -- 1164
				local lv2 -- 1165
				do -- 1165
					local _exp_0 = extentionLevels[ext] -- 1165
					if _exp_0 ~= nil then -- 1165
						lv2 = _exp_0 -- 1165
					else -- 1165
						lv2 = -1 -- 1165
					end -- 1165
				end -- 1165
				if lv2 > lv1 then -- 1166
					names[name] = ext -- 1167
				elseif lv2 == lv1 then -- 1168
					names[name .. '.' .. ext] = "" -- 1169
				end -- 1166
			else -- 1171
				ext = Path:getExt(file) -- 1171
				if not extentionLevels[ext] then -- 1172
					names[file] = "" -- 1173
				else -- 1175
					names[name] = ext -- 1175
				end -- 1172
			end -- 1162
			::_continue_1:: -- 1160
		end -- 1159
		do -- 1176
			local _accum_0 = { } -- 1176
			local _len_0 = 1 -- 1176
			for name, ext in pairs(names) do -- 1176
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1176
				_len_0 = _len_0 + 1 -- 1176
			end -- 1176
			files = _accum_0 -- 1176
		end -- 1176
		for _index_0 = 1, #files do -- 1177
			local file = files[_index_0] -- 1177
			if not children then -- 1178
				children = { } -- 1178
			end -- 1178
			children[#children + 1] = { -- 1180
				key = Path(path, file), -- 1180
				dir = false, -- 1181
				title = file, -- 1182
				builtin = builtin -- 1183
			} -- 1179
		end -- 1177
		if children then -- 1185
			table.sort(children, function(a, b) -- 1186
				if a.dir == b.dir then -- 1187
					return a.title < b.title -- 1188
				else -- 1190
					return a.dir -- 1190
				end -- 1187
			end) -- 1186
		end -- 1185
		if isWorkspace and children then -- 1191
			return children -- 1192
		else -- 1194
			return { -- 1195
				key = path, -- 1195
				dir = true, -- 1196
				title = Path:getFilename(path), -- 1197
				builtin = builtin, -- 1198
				children = children -- 1199
			} -- 1194
		end -- 1191
	end -- 1144
	local zh = (App.locale:match("^zh") ~= nil) -- 1201
	return { -- 1203
		key = Content.writablePath, -- 1203
		dir = true, -- 1204
		root = true, -- 1205
		title = "Assets", -- 1206
		children = (function() -- 1208
			local _tab_0 = { -- 1208
				{ -- 1209
					key = Path(Content.assetPath), -- 1209
					dir = true, -- 1210
					builtin = true, -- 1211
					title = zh and "内置资源" or "Built-in", -- 1212
					children = { -- 1214
						(function() -- 1214
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1214
							_with_0.title = zh and "说明文档" or "Readme" -- 1215
							return _with_0 -- 1214
						end)(), -- 1214
						(function() -- 1216
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1216
							_with_0.title = zh and "接口文档" or "API Doc" -- 1217
							return _with_0 -- 1216
						end)(), -- 1216
						(function() -- 1218
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1218
							_with_0.title = zh and "开发工具" or "Tools" -- 1219
							return _with_0 -- 1218
						end)(), -- 1218
						(function() -- 1220
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1220
							_with_0.title = zh and "字体" or "Font" -- 1221
							return _with_0 -- 1220
						end)(), -- 1220
						(function() -- 1222
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1222
							_with_0.title = zh and "程序库" or "Lib" -- 1223
							if engineDev then -- 1224
								local _list_0 = _with_0.children -- 1225
								for _index_0 = 1, #_list_0 do -- 1225
									local child = _list_0[_index_0] -- 1225
									if not (child.title == "Dora") then -- 1226
										goto _continue_0 -- 1226
									end -- 1226
									local title = zh and "zh-Hans" or "en" -- 1227
									do -- 1228
										local _accum_0 = { } -- 1228
										local _len_0 = 1 -- 1228
										local _list_1 = child.children -- 1228
										for _index_1 = 1, #_list_1 do -- 1228
											local c = _list_1[_index_1] -- 1228
											if c.title ~= title then -- 1228
												_accum_0[_len_0] = c -- 1228
												_len_0 = _len_0 + 1 -- 1228
											end -- 1228
										end -- 1228
										child.children = _accum_0 -- 1228
									end -- 1228
									break -- 1229
									::_continue_0:: -- 1226
								end -- 1225
							else -- 1231
								local _accum_0 = { } -- 1231
								local _len_0 = 1 -- 1231
								local _list_0 = _with_0.children -- 1231
								for _index_0 = 1, #_list_0 do -- 1231
									local child = _list_0[_index_0] -- 1231
									if child.title ~= "Dora" then -- 1231
										_accum_0[_len_0] = child -- 1231
										_len_0 = _len_0 + 1 -- 1231
									end -- 1231
								end -- 1231
								_with_0.children = _accum_0 -- 1231
							end -- 1224
							return _with_0 -- 1222
						end)(), -- 1222
						(function() -- 1232
							if engineDev then -- 1232
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1233
								local _obj_0 = _with_0.children -- 1234
								_obj_0[#_obj_0 + 1] = { -- 1235
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1235
									dir = false, -- 1236
									builtin = true, -- 1237
									title = "init.yue" -- 1238
								} -- 1234
								return _with_0 -- 1233
							end -- 1232
						end)() -- 1232
					} -- 1213
				} -- 1208
			} -- 1242
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1242
			local _idx_0 = #_tab_0 + 1 -- 1242
			for _index_0 = 1, #_obj_0 do -- 1242
				local _value_0 = _obj_0[_index_0] -- 1242
				_tab_0[_idx_0] = _value_0 -- 1242
				_idx_0 = _idx_0 + 1 -- 1242
			end -- 1242
			return _tab_0 -- 1208
		end)() -- 1207
	} -- 1202
end) -- 1139
HttpServer:postSchedule("/run", function(req) -- 1246
	do -- 1247
		local _type_0 = type(req) -- 1247
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1247
		if _tab_0 then -- 1247
			local file -- 1247
			do -- 1247
				local _obj_0 = req.body -- 1247
				local _type_1 = type(_obj_0) -- 1247
				if "table" == _type_1 or "userdata" == _type_1 then -- 1247
					file = _obj_0.file -- 1247
				end -- 1247
			end -- 1247
			local asProj -- 1247
			do -- 1247
				local _obj_0 = req.body -- 1247
				local _type_1 = type(_obj_0) -- 1247
				if "table" == _type_1 or "userdata" == _type_1 then -- 1247
					asProj = _obj_0.asProj -- 1247
				end -- 1247
			end -- 1247
			if file ~= nil and asProj ~= nil then -- 1247
				if not Content:isAbsolutePath(file) then -- 1248
					local devFile = Path(Content.writablePath, file) -- 1249
					if Content:exist(devFile) then -- 1250
						file = devFile -- 1250
					end -- 1250
				end -- 1248
				local Entry = require("Script.Dev.Entry") -- 1251
				local workDir -- 1252
				if asProj then -- 1253
					workDir = getProjectDirFromFile(file) -- 1254
					if workDir then -- 1254
						Entry.allClear() -- 1255
						local target = Path(workDir, "init") -- 1256
						local success, err = Entry.enterEntryAsync({ -- 1257
							entryName = "Project", -- 1257
							fileName = target -- 1257
						}) -- 1257
						target = Path:getName(Path:getPath(target)) -- 1258
						return { -- 1259
							success = success, -- 1259
							target = target, -- 1259
							err = err -- 1259
						} -- 1259
					end -- 1254
				else -- 1261
					workDir = getProjectDirFromFile(file) -- 1261
				end -- 1253
				Entry.allClear() -- 1262
				file = Path:replaceExt(file, "") -- 1263
				local success, err = Entry.enterEntryAsync({ -- 1265
					entryName = Path:getName(file), -- 1265
					fileName = file, -- 1266
					workDir = workDir -- 1267
				}) -- 1264
				return { -- 1268
					success = success, -- 1268
					err = err -- 1268
				} -- 1268
			end -- 1247
		end -- 1247
	end -- 1247
	return { -- 1246
		success = false -- 1246
	} -- 1246
end) -- 1246
HttpServer:postSchedule("/stop", function() -- 1270
	local Entry = require("Script.Dev.Entry") -- 1271
	return { -- 1272
		success = Entry.stop() -- 1272
	} -- 1272
end) -- 1270
local minifyAsync -- 1274
minifyAsync = function(sourcePath, minifyPath) -- 1274
	if not Content:exist(sourcePath) then -- 1275
		return -- 1275
	end -- 1275
	local Entry = require("Script.Dev.Entry") -- 1276
	local errors = { } -- 1277
	local files = Entry.getAllFiles(sourcePath, { -- 1278
		"lua" -- 1278
	}, true) -- 1278
	do -- 1279
		local _accum_0 = { } -- 1279
		local _len_0 = 1 -- 1279
		for _index_0 = 1, #files do -- 1279
			local file = files[_index_0] -- 1279
			if file:sub(1, 1) ~= '.' then -- 1279
				_accum_0[_len_0] = file -- 1279
				_len_0 = _len_0 + 1 -- 1279
			end -- 1279
		end -- 1279
		files = _accum_0 -- 1279
	end -- 1279
	local paths -- 1280
	do -- 1280
		local _tbl_0 = { } -- 1280
		for _index_0 = 1, #files do -- 1280
			local file = files[_index_0] -- 1280
			_tbl_0[Path:getPath(file)] = true -- 1280
		end -- 1280
		paths = _tbl_0 -- 1280
	end -- 1280
	for path in pairs(paths) do -- 1281
		Content:mkdir(Path(minifyPath, path)) -- 1281
	end -- 1281
	local _ <close> = setmetatable({ }, { -- 1282
		__close = function() -- 1282
			package.loaded["luaminify.FormatMini"] = nil -- 1283
			package.loaded["luaminify.ParseLua"] = nil -- 1284
			package.loaded["luaminify.Scope"] = nil -- 1285
			package.loaded["luaminify.Util"] = nil -- 1286
		end -- 1282
	}) -- 1282
	local FormatMini -- 1287
	do -- 1287
		local _obj_0 = require("luaminify") -- 1287
		FormatMini = _obj_0.FormatMini -- 1287
	end -- 1287
	local fileCount = #files -- 1288
	local count = 0 -- 1289
	for _index_0 = 1, #files do -- 1290
		local file = files[_index_0] -- 1290
		thread(function() -- 1291
			local _ <close> = setmetatable({ }, { -- 1292
				__close = function() -- 1292
					count = count + 1 -- 1292
				end -- 1292
			}) -- 1292
			local input = Path(sourcePath, file) -- 1293
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1294
			if Content:exist(input) then -- 1295
				local sourceCodes = Content:loadAsync(input) -- 1296
				local res, err = FormatMini(sourceCodes) -- 1297
				if res then -- 1298
					Content:saveAsync(output, res) -- 1299
					return print("Minify " .. tostring(file)) -- 1300
				else -- 1302
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1302
				end -- 1298
			else -- 1304
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1304
			end -- 1295
		end) -- 1291
		sleep() -- 1305
	end -- 1290
	wait(function() -- 1306
		return count == fileCount -- 1306
	end) -- 1306
	if #errors > 0 then -- 1307
		print(table.concat(errors, '\n')) -- 1308
	end -- 1307
	print("Obfuscation done.") -- 1309
	return files -- 1310
end -- 1274
local zipping = false -- 1312
HttpServer:postSchedule("/zip", function(req) -- 1314
	do -- 1315
		local _type_0 = type(req) -- 1315
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1315
		if _tab_0 then -- 1315
			local path -- 1315
			do -- 1315
				local _obj_0 = req.body -- 1315
				local _type_1 = type(_obj_0) -- 1315
				if "table" == _type_1 or "userdata" == _type_1 then -- 1315
					path = _obj_0.path -- 1315
				end -- 1315
			end -- 1315
			local zipFile -- 1315
			do -- 1315
				local _obj_0 = req.body -- 1315
				local _type_1 = type(_obj_0) -- 1315
				if "table" == _type_1 or "userdata" == _type_1 then -- 1315
					zipFile = _obj_0.zipFile -- 1315
				end -- 1315
			end -- 1315
			local obfuscated -- 1315
			do -- 1315
				local _obj_0 = req.body -- 1315
				local _type_1 = type(_obj_0) -- 1315
				if "table" == _type_1 or "userdata" == _type_1 then -- 1315
					obfuscated = _obj_0.obfuscated -- 1315
				end -- 1315
			end -- 1315
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1315
				if zipping then -- 1316
					goto failed -- 1316
				end -- 1316
				zipping = true -- 1317
				local _ <close> = setmetatable({ }, { -- 1318
					__close = function() -- 1318
						zipping = false -- 1318
					end -- 1318
				}) -- 1318
				if not Content:exist(path) then -- 1319
					goto failed -- 1319
				end -- 1319
				Content:mkdir(Path:getPath(zipFile)) -- 1320
				if obfuscated then -- 1321
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1322
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1323
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1324
					Content:remove(scriptPath) -- 1325
					Content:remove(obfuscatedPath) -- 1326
					Content:remove(tempPath) -- 1327
					Content:mkdir(scriptPath) -- 1328
					Content:mkdir(obfuscatedPath) -- 1329
					Content:mkdir(tempPath) -- 1330
					if not Content:copyAsync(path, tempPath) then -- 1331
						goto failed -- 1331
					end -- 1331
					local Entry = require("Script.Dev.Entry") -- 1332
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1333
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1334
						"tl", -- 1334
						"yue", -- 1334
						"lua", -- 1334
						"ts", -- 1334
						"tsx", -- 1334
						"vs", -- 1334
						"bl", -- 1334
						"xml", -- 1334
						"wa", -- 1334
						"mod" -- 1334
					}, true) -- 1334
					for _index_0 = 1, #scriptFiles do -- 1335
						local file = scriptFiles[_index_0] -- 1335
						Content:remove(Path(tempPath, file)) -- 1336
					end -- 1335
					for _index_0 = 1, #luaFiles do -- 1337
						local file = luaFiles[_index_0] -- 1337
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1338
					end -- 1337
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1339
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1340
					end) then -- 1339
						goto failed -- 1339
					end -- 1339
					return { -- 1341
						success = true -- 1341
					} -- 1341
				else -- 1343
					return { -- 1343
						success = Content:zipAsync(path, zipFile, function(file) -- 1343
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1344
						end) -- 1343
					} -- 1343
				end -- 1321
			end -- 1315
		end -- 1315
	end -- 1315
	::failed:: -- 1345
	return { -- 1314
		success = false -- 1314
	} -- 1314
end) -- 1314
HttpServer:postSchedule("/unzip", function(req) -- 1347
	do -- 1348
		local _type_0 = type(req) -- 1348
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1348
		if _tab_0 then -- 1348
			local zipFile -- 1348
			do -- 1348
				local _obj_0 = req.body -- 1348
				local _type_1 = type(_obj_0) -- 1348
				if "table" == _type_1 or "userdata" == _type_1 then -- 1348
					zipFile = _obj_0.zipFile -- 1348
				end -- 1348
			end -- 1348
			local path -- 1348
			do -- 1348
				local _obj_0 = req.body -- 1348
				local _type_1 = type(_obj_0) -- 1348
				if "table" == _type_1 or "userdata" == _type_1 then -- 1348
					path = _obj_0.path -- 1348
				end -- 1348
			end -- 1348
			if zipFile ~= nil and path ~= nil then -- 1348
				return { -- 1349
					success = Content:unzipAsync(zipFile, path, function(file) -- 1349
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1350
					end) -- 1349
				} -- 1349
			end -- 1348
		end -- 1348
	end -- 1348
	return { -- 1347
		success = false -- 1347
	} -- 1347
end) -- 1347
HttpServer:post("/editing-info", function(req) -- 1352
	local Entry = require("Script.Dev.Entry") -- 1353
	local config = Entry.getConfig() -- 1354
	local _type_0 = type(req) -- 1355
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1355
	local _match_0 = false -- 1355
	if _tab_0 then -- 1355
		local editingInfo -- 1355
		do -- 1355
			local _obj_0 = req.body -- 1355
			local _type_1 = type(_obj_0) -- 1355
			if "table" == _type_1 or "userdata" == _type_1 then -- 1355
				editingInfo = _obj_0.editingInfo -- 1355
			end -- 1355
		end -- 1355
		if editingInfo ~= nil then -- 1355
			_match_0 = true -- 1355
			config.editingInfo = editingInfo -- 1356
			return { -- 1357
				success = true -- 1357
			} -- 1357
		end -- 1355
	end -- 1355
	if not _match_0 then -- 1355
		if not (config.editingInfo ~= nil) then -- 1359
			local folder -- 1360
			if App.locale:match('^zh') then -- 1360
				folder = 'zh-Hans' -- 1360
			else -- 1360
				folder = 'en' -- 1360
			end -- 1360
			config.editingInfo = json.encode({ -- 1362
				index = 0, -- 1362
				files = { -- 1364
					{ -- 1365
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1365
						title = "welcome.md" -- 1366
					} -- 1364
				} -- 1363
			}) -- 1361
		end -- 1359
		return { -- 1370
			success = true, -- 1370
			editingInfo = config.editingInfo -- 1370
		} -- 1370
	end -- 1355
end) -- 1352
HttpServer:post("/command", function(req) -- 1372
	do -- 1373
		local _type_0 = type(req) -- 1373
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1373
		if _tab_0 then -- 1373
			local code -- 1373
			do -- 1373
				local _obj_0 = req.body -- 1373
				local _type_1 = type(_obj_0) -- 1373
				if "table" == _type_1 or "userdata" == _type_1 then -- 1373
					code = _obj_0.code -- 1373
				end -- 1373
			end -- 1373
			local log -- 1373
			do -- 1373
				local _obj_0 = req.body -- 1373
				local _type_1 = type(_obj_0) -- 1373
				if "table" == _type_1 or "userdata" == _type_1 then -- 1373
					log = _obj_0.log -- 1373
				end -- 1373
			end -- 1373
			if code ~= nil and log ~= nil then -- 1373
				emit("AppCommand", code, log) -- 1374
				return { -- 1375
					success = true -- 1375
				} -- 1375
			end -- 1373
		end -- 1373
	end -- 1373
	return { -- 1372
		success = false -- 1372
	} -- 1372
end) -- 1372
HttpServer:post("/log/save", function() -- 1377
	local folder = ".download" -- 1378
	local fullLogFile = "dora_full_logs.txt" -- 1379
	local fullFolder = Path(Content.writablePath, folder) -- 1380
	Content:mkdir(fullFolder) -- 1381
	local logPath = Path(fullFolder, fullLogFile) -- 1382
	if App:saveLog(logPath) then -- 1383
		return { -- 1384
			success = true, -- 1384
			path = Path(folder, fullLogFile) -- 1384
		} -- 1384
	end -- 1383
	return { -- 1377
		success = false -- 1377
	} -- 1377
end) -- 1377
HttpServer:post("/yarn/check", function(req) -- 1386
	local yarncompile = require("yarncompile") -- 1387
	do -- 1388
		local _type_0 = type(req) -- 1388
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1388
		if _tab_0 then -- 1388
			local code -- 1388
			do -- 1388
				local _obj_0 = req.body -- 1388
				local _type_1 = type(_obj_0) -- 1388
				if "table" == _type_1 or "userdata" == _type_1 then -- 1388
					code = _obj_0.code -- 1388
				end -- 1388
			end -- 1388
			if code ~= nil then -- 1388
				local jsonObject = json.decode(code) -- 1389
				if jsonObject then -- 1389
					local errors = { } -- 1390
					local _list_0 = jsonObject.nodes -- 1391
					for _index_0 = 1, #_list_0 do -- 1391
						local node = _list_0[_index_0] -- 1391
						local title, body = node.title, node.body -- 1392
						local luaCode, err = yarncompile(body) -- 1393
						if not luaCode then -- 1393
							errors[#errors + 1] = title .. ":" .. err -- 1394
						end -- 1393
					end -- 1391
					return { -- 1395
						success = true, -- 1395
						syntaxError = table.concat(errors, "\n\n") -- 1395
					} -- 1395
				end -- 1389
			end -- 1388
		end -- 1388
	end -- 1388
	return { -- 1386
		success = false -- 1386
	} -- 1386
end) -- 1386
HttpServer:post("/yarn/check-file", function(req) -- 1397
	local yarncompile = require("yarncompile") -- 1398
	do -- 1399
		local _type_0 = type(req) -- 1399
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1399
		if _tab_0 then -- 1399
			local code -- 1399
			do -- 1399
				local _obj_0 = req.body -- 1399
				local _type_1 = type(_obj_0) -- 1399
				if "table" == _type_1 or "userdata" == _type_1 then -- 1399
					code = _obj_0.code -- 1399
				end -- 1399
			end -- 1399
			if code ~= nil then -- 1399
				local res, _, err = yarncompile(code, true) -- 1400
				if not res then -- 1400
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1401
					return { -- 1402
						success = false, -- 1402
						message = message, -- 1402
						line = line, -- 1402
						column = column, -- 1402
						node = node -- 1402
					} -- 1402
				end -- 1400
			end -- 1399
		end -- 1399
	end -- 1399
	return { -- 1397
		success = true -- 1397
	} -- 1397
end) -- 1397
local getWaProjectDirFromFile -- 1404
getWaProjectDirFromFile = function(file) -- 1404
	local writablePath = Content.writablePath -- 1405
	local parent, current -- 1406
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1406
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1407
	else -- 1409
		parent, current = nil, nil -- 1409
	end -- 1406
	if not current then -- 1410
		return nil -- 1410
	end -- 1410
	repeat -- 1411
		current = Path:getPath(current) -- 1412
		if current == "" then -- 1413
			break -- 1413
		end -- 1413
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1414
		for _index_0 = 1, #_list_0 do -- 1414
			local f = _list_0[_index_0] -- 1414
			if Path:getFilename(f):lower() == "wa.mod" then -- 1415
				return Path(parent, current, Path:getPath(f)) -- 1416
			end -- 1415
		end -- 1414
	until false -- 1411
	return nil -- 1418
end -- 1404
HttpServer:postSchedule("/wa/update_dora", function(req) -- 1420
	do -- 1421
		local _type_0 = type(req) -- 1421
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1421
		if _tab_0 then -- 1421
			local path -- 1421
			do -- 1421
				local _obj_0 = req.body -- 1421
				local _type_1 = type(_obj_0) -- 1421
				if "table" == _type_1 or "userdata" == _type_1 then -- 1421
					path = _obj_0.path -- 1421
				end -- 1421
			end -- 1421
			if path ~= nil then -- 1421
				local projDir = getWaProjectDirFromFile(path) -- 1422
				if projDir then -- 1422
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 1423
					if not Content:exist(sourceDoraPath) then -- 1424
						return { -- 1425
							success = false, -- 1425
							message = "missing dora template" -- 1425
						} -- 1425
					end -- 1424
					local targetVendorPath = Path(projDir, "vendor") -- 1426
					local targetDoraPath = Path(targetVendorPath, "dora") -- 1427
					if not Content:exist(targetVendorPath) then -- 1428
						if not Content:mkdir(targetVendorPath) then -- 1429
							return { -- 1430
								success = false, -- 1430
								message = "failed to create vendor folder" -- 1430
							} -- 1430
						end -- 1429
					elseif not Content:isdir(targetVendorPath) then -- 1431
						return { -- 1432
							success = false, -- 1432
							message = "vendor path is not a folder" -- 1432
						} -- 1432
					end -- 1428
					if Content:exist(targetDoraPath) then -- 1433
						if not Content:remove(targetDoraPath) then -- 1434
							return { -- 1435
								success = false, -- 1435
								message = "failed to remove old dora" -- 1435
							} -- 1435
						end -- 1434
					end -- 1433
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 1436
						return { -- 1437
							success = false, -- 1437
							message = "failed to copy dora" -- 1437
						} -- 1437
					end -- 1436
					return { -- 1438
						success = true -- 1438
					} -- 1438
				else -- 1440
					return { -- 1440
						success = false, -- 1440
						message = 'Wa file needs a project' -- 1440
					} -- 1440
				end -- 1422
			end -- 1421
		end -- 1421
	end -- 1421
	return { -- 1420
		success = false, -- 1420
		message = "invalid call" -- 1420
	} -- 1420
end) -- 1420
HttpServer:postSchedule("/wa/build", function(req) -- 1442
	do -- 1443
		local _type_0 = type(req) -- 1443
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1443
		if _tab_0 then -- 1443
			local path -- 1443
			do -- 1443
				local _obj_0 = req.body -- 1443
				local _type_1 = type(_obj_0) -- 1443
				if "table" == _type_1 or "userdata" == _type_1 then -- 1443
					path = _obj_0.path -- 1443
				end -- 1443
			end -- 1443
			if path ~= nil then -- 1443
				local projDir = getWaProjectDirFromFile(path) -- 1444
				if projDir then -- 1444
					local message = Wasm:buildWaAsync(projDir) -- 1445
					if message == "" then -- 1446
						return { -- 1447
							success = true -- 1447
						} -- 1447
					else -- 1449
						return { -- 1449
							success = false, -- 1449
							message = message -- 1449
						} -- 1449
					end -- 1446
				else -- 1451
					return { -- 1451
						success = false, -- 1451
						message = 'Wa file needs a project' -- 1451
					} -- 1451
				end -- 1444
			end -- 1443
		end -- 1443
	end -- 1443
	return { -- 1452
		success = false, -- 1452
		message = 'failed to build' -- 1452
	} -- 1452
end) -- 1442
HttpServer:postSchedule("/wa/format", function(req) -- 1454
	do -- 1455
		local _type_0 = type(req) -- 1455
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1455
		if _tab_0 then -- 1455
			local file -- 1455
			do -- 1455
				local _obj_0 = req.body -- 1455
				local _type_1 = type(_obj_0) -- 1455
				if "table" == _type_1 or "userdata" == _type_1 then -- 1455
					file = _obj_0.file -- 1455
				end -- 1455
			end -- 1455
			if file ~= nil then -- 1455
				local code = Wasm:formatWaAsync(file) -- 1456
				if code == "" then -- 1457
					return { -- 1458
						success = false -- 1458
					} -- 1458
				else -- 1460
					return { -- 1460
						success = true, -- 1460
						code = code -- 1460
					} -- 1460
				end -- 1457
			end -- 1455
		end -- 1455
	end -- 1455
	return { -- 1461
		success = false -- 1461
	} -- 1461
end) -- 1454
HttpServer:postSchedule("/wa/create", function(req) -- 1463
	do -- 1464
		local _type_0 = type(req) -- 1464
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1464
		if _tab_0 then -- 1464
			local path -- 1464
			do -- 1464
				local _obj_0 = req.body -- 1464
				local _type_1 = type(_obj_0) -- 1464
				if "table" == _type_1 or "userdata" == _type_1 then -- 1464
					path = _obj_0.path -- 1464
				end -- 1464
			end -- 1464
			if path ~= nil then -- 1464
				if not Content:exist(Path:getPath(path)) then -- 1465
					return { -- 1466
						success = false, -- 1466
						message = "target path not existed" -- 1466
					} -- 1466
				end -- 1465
				if Content:exist(path) then -- 1467
					return { -- 1468
						success = false, -- 1468
						message = "target project folder existed" -- 1468
					} -- 1468
				end -- 1467
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1469
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1470
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1471
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1472
					return { -- 1475
						success = false, -- 1475
						message = "missing template project" -- 1475
					} -- 1475
				end -- 1472
				if not Content:mkdir(path) then -- 1476
					return { -- 1477
						success = false, -- 1477
						message = "failed to create project folder" -- 1477
					} -- 1477
				end -- 1476
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1478
					Content:remove(path) -- 1479
					return { -- 1480
						success = false, -- 1480
						message = "failed to copy template" -- 1480
					} -- 1480
				end -- 1478
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1481
					Content:remove(path) -- 1482
					return { -- 1483
						success = false, -- 1483
						message = "failed to copy template" -- 1483
					} -- 1483
				end -- 1481
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1484
					Content:remove(path) -- 1485
					return { -- 1486
						success = false, -- 1486
						message = "failed to copy template" -- 1486
					} -- 1486
				end -- 1484
				return { -- 1487
					success = true -- 1487
				} -- 1487
			end -- 1464
		end -- 1464
	end -- 1464
	return { -- 1463
		success = false, -- 1463
		message = "invalid call" -- 1463
	} -- 1463
end) -- 1463
local _anon_func_5 = function(path) -- 1496
	local _val_0 = Path:getExt(path) -- 1496
	return "ts" == _val_0 or "tsx" == _val_0 -- 1496
end -- 1496
local _anon_func_6 = function(f) -- 1526
	local _val_0 = Path:getExt(f) -- 1526
	return "ts" == _val_0 or "tsx" == _val_0 -- 1526
end -- 1526
HttpServer:postSchedule("/ts/build", function(req) -- 1489
	do -- 1490
		local _type_0 = type(req) -- 1490
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1490
		if _tab_0 then -- 1490
			local path -- 1490
			do -- 1490
				local _obj_0 = req.body -- 1490
				local _type_1 = type(_obj_0) -- 1490
				if "table" == _type_1 or "userdata" == _type_1 then -- 1490
					path = _obj_0.path -- 1490
				end -- 1490
			end -- 1490
			if path ~= nil then -- 1490
				if HttpServer.wsConnectionCount == 0 then -- 1491
					return { -- 1492
						success = false, -- 1492
						message = "Web IDE not connected" -- 1492
					} -- 1492
				end -- 1491
				if not Content:exist(path) then -- 1493
					return { -- 1494
						success = false, -- 1494
						message = "path not existed" -- 1494
					} -- 1494
				end -- 1493
				if not Content:isdir(path) then -- 1495
					if not (_anon_func_5(path)) then -- 1496
						return { -- 1497
							success = false, -- 1497
							message = "expecting a TypeScript file" -- 1497
						} -- 1497
					end -- 1496
					local messages = { } -- 1498
					local content = Content:load(path) -- 1499
					if not content then -- 1500
						return { -- 1501
							success = false, -- 1501
							message = "failed to read file" -- 1501
						} -- 1501
					end -- 1500
					emit("AppWS", "Send", json.encode({ -- 1502
						name = "UpdateFile", -- 1502
						file = path, -- 1502
						exists = true, -- 1502
						content = content -- 1502
					})) -- 1502
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1503
						local done = false -- 1504
						do -- 1505
							local _with_0 = Node() -- 1505
							_with_0:gslot("AppWS", function(event) -- 1506
								if event.type == "Receive" then -- 1507
									local res = json.decode(event.msg) -- 1508
									if res then -- 1508
										if res.name == "TranspileTS" and res.file == path then -- 1509
											_with_0:removeFromParent() -- 1510
											if res.success then -- 1511
												local luaFile = Path:replaceExt(path, "lua") -- 1512
												Content:save(luaFile, res.luaCode) -- 1513
												messages[#messages + 1] = { -- 1514
													success = true, -- 1514
													file = path -- 1514
												} -- 1514
											else -- 1516
												messages[#messages + 1] = { -- 1516
													success = false, -- 1516
													file = path, -- 1516
													message = res.message -- 1516
												} -- 1516
											end -- 1511
											done = true -- 1517
										end -- 1509
									end -- 1508
								end -- 1507
							end) -- 1506
						end -- 1505
						emit("AppWS", "Send", json.encode({ -- 1518
							name = "TranspileTS", -- 1518
							file = path, -- 1518
							content = content -- 1518
						})) -- 1518
						wait(function() -- 1519
							return done -- 1519
						end) -- 1519
					end -- 1503
					return { -- 1520
						success = true, -- 1520
						messages = messages -- 1520
					} -- 1520
				else -- 1522
					local files = Content:getAllFiles(path) -- 1522
					local fileData = { } -- 1523
					local messages = { } -- 1524
					for _index_0 = 1, #files do -- 1525
						local f = files[_index_0] -- 1525
						if not (_anon_func_6(f)) then -- 1526
							goto _continue_0 -- 1526
						end -- 1526
						local file = Path(path, f) -- 1527
						local content = Content:load(file) -- 1528
						if content then -- 1528
							fileData[file] = content -- 1529
							emit("AppWS", "Send", json.encode({ -- 1530
								name = "UpdateFile", -- 1530
								file = file, -- 1530
								exists = true, -- 1530
								content = content -- 1530
							})) -- 1530
						else -- 1532
							messages[#messages + 1] = { -- 1532
								success = false, -- 1532
								file = file, -- 1532
								message = "failed to read file" -- 1532
							} -- 1532
						end -- 1528
						::_continue_0:: -- 1526
					end -- 1525
					for file, content in pairs(fileData) do -- 1533
						if "d" == Path:getExt(Path:getName(file)) then -- 1534
							goto _continue_1 -- 1534
						end -- 1534
						local done = false -- 1535
						do -- 1536
							local _with_0 = Node() -- 1536
							_with_0:gslot("AppWS", function(event) -- 1537
								if event.type == "Receive" then -- 1538
									local res = json.decode(event.msg) -- 1539
									if res then -- 1539
										if res.name == "TranspileTS" and res.file == file then -- 1540
											_with_0:removeFromParent() -- 1541
											if res.success then -- 1542
												local luaFile = Path:replaceExt(file, "lua") -- 1543
												Content:save(luaFile, res.luaCode) -- 1544
												messages[#messages + 1] = { -- 1545
													success = true, -- 1545
													file = file -- 1545
												} -- 1545
											else -- 1547
												messages[#messages + 1] = { -- 1547
													success = false, -- 1547
													file = file, -- 1547
													message = res.message -- 1547
												} -- 1547
											end -- 1542
											done = true -- 1548
										end -- 1540
									end -- 1539
								end -- 1538
							end) -- 1537
						end -- 1536
						emit("AppWS", "Send", json.encode({ -- 1549
							name = "TranspileTS", -- 1549
							file = file, -- 1549
							content = content -- 1549
						})) -- 1549
						wait(function() -- 1550
							return done -- 1550
						end) -- 1550
						::_continue_1:: -- 1534
					end -- 1533
					return { -- 1551
						success = true, -- 1551
						messages = messages -- 1551
					} -- 1551
				end -- 1495
			end -- 1490
		end -- 1490
	end -- 1490
	return { -- 1489
		success = false -- 1489
	} -- 1489
end) -- 1489
HttpServer:post("/download", function(req) -- 1553
	do -- 1554
		local _type_0 = type(req) -- 1554
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1554
		if _tab_0 then -- 1554
			local url -- 1554
			do -- 1554
				local _obj_0 = req.body -- 1554
				local _type_1 = type(_obj_0) -- 1554
				if "table" == _type_1 or "userdata" == _type_1 then -- 1554
					url = _obj_0.url -- 1554
				end -- 1554
			end -- 1554
			local target -- 1554
			do -- 1554
				local _obj_0 = req.body -- 1554
				local _type_1 = type(_obj_0) -- 1554
				if "table" == _type_1 or "userdata" == _type_1 then -- 1554
					target = _obj_0.target -- 1554
				end -- 1554
			end -- 1554
			if url ~= nil and target ~= nil then -- 1554
				local Entry = require("Script.Dev.Entry") -- 1555
				Entry.downloadFile(url, target) -- 1556
				return { -- 1557
					success = true -- 1557
				} -- 1557
			end -- 1554
		end -- 1554
	end -- 1554
	return { -- 1553
		success = false -- 1553
	} -- 1553
end) -- 1553
local status = { } -- 1559
_module_0 = status -- 1560
status.buildAsync = function(path) -- 1562
	if not Content:exist(path) then -- 1563
		return { -- 1564
			success = false, -- 1564
			file = path, -- 1564
			message = "file not existed" -- 1564
		} -- 1564
	end -- 1563
	do -- 1565
		local _exp_0 = Path:getExt(path) -- 1565
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1565
			if '' == Path:getExt(Path:getName(path)) then -- 1566
				local content = Content:loadAsync(path) -- 1567
				if content then -- 1567
					local resultCodes, err = compileFileAsync(path, content) -- 1568
					if resultCodes then -- 1568
						return { -- 1569
							success = true, -- 1569
							file = path -- 1569
						} -- 1569
					else -- 1571
						return { -- 1571
							success = false, -- 1571
							file = path, -- 1571
							message = err -- 1571
						} -- 1571
					end -- 1568
				end -- 1567
			end -- 1566
		elseif "lua" == _exp_0 then -- 1572
			local content = Content:loadAsync(path) -- 1573
			if content then -- 1573
				do -- 1574
					local isTIC80 = CheckTIC80Code(content) -- 1574
					if isTIC80 then -- 1574
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1575
					end -- 1574
				end -- 1574
				local success, info -- 1576
				do -- 1576
					local _obj_0 = luaCheck(path, content) -- 1576
					success, info = _obj_0.success, _obj_0.info -- 1576
				end -- 1576
				if success then -- 1577
					return { -- 1578
						success = true, -- 1578
						file = path -- 1578
					} -- 1578
				elseif info and #info > 0 then -- 1579
					local messages = { } -- 1580
					for _index_0 = 1, #info do -- 1581
						local _des_0 = info[_index_0] -- 1581
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 1581
						local lineText = "" -- 1582
						if line then -- 1583
							local currentLine = 1 -- 1584
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1585
								if currentLine == line then -- 1586
									lineText = text -- 1587
									break -- 1588
								end -- 1586
								currentLine = currentLine + 1 -- 1589
							end -- 1585
						end -- 1583
						if line then -- 1590
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1591
						else -- 1593
							messages[#messages + 1] = message -- 1593
						end -- 1590
					end -- 1581
					return { -- 1594
						success = false, -- 1594
						file = path, -- 1594
						message = table.concat(messages, "\n") -- 1594
					} -- 1594
				else -- 1596
					return { -- 1596
						success = false, -- 1596
						file = path, -- 1596
						message = "lua check failed" -- 1596
					} -- 1596
				end -- 1577
			end -- 1573
		elseif "yarn" == _exp_0 then -- 1597
			local content = Content:loadAsync(path) -- 1598
			if content then -- 1598
				local res, _, err = yarncompile(content, true) -- 1599
				if res then -- 1599
					return { -- 1600
						success = true, -- 1600
						file = path -- 1600
					} -- 1600
				else -- 1602
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1602
					local lineText = "" -- 1603
					if line then -- 1604
						local currentLine = 1 -- 1605
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1606
							if currentLine == line then -- 1607
								lineText = text -- 1608
								break -- 1609
							end -- 1607
							currentLine = currentLine + 1 -- 1610
						end -- 1606
					end -- 1604
					if node ~= "" then -- 1611
						node = "node: " .. tostring(node) .. ", " -- 1612
					else -- 1613
						node = "" -- 1613
					end -- 1611
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1614
					return { -- 1615
						success = false, -- 1615
						file = path, -- 1615
						message = message -- 1615
					} -- 1615
				end -- 1599
			end -- 1598
		end -- 1565
	end -- 1565
	return { -- 1616
		success = false, -- 1616
		file = path, -- 1616
		message = "invalid file to build" -- 1616
	} -- 1616
end -- 1562
thread(function() -- 1618
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1619
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1620
	if Content:exist(doraWeb) then -- 1621
		local needReload -- 1622
		if Content:exist(doraReady) then -- 1622
			needReload = App.version ~= Content:load(doraReady) -- 1623
		else -- 1624
			needReload = true -- 1624
		end -- 1622
		if needReload then -- 1625
			Content:remove(Path(Content.appPath, ".www")) -- 1626
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1627
			Content:save(doraReady, App.version) -- 1631
			print("Dora Dora is ready!") -- 1632
		end -- 1625
	end -- 1621
	if HttpServer:start(8866) then -- 1633
		local localIP = HttpServer.localIP -- 1634
		if localIP == "" then -- 1635
			localIP = "localhost" -- 1635
		end -- 1635
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1636
		return HttpServer:startWS(8868) -- 1637
	else -- 1639
		status.url = nil -- 1639
		return print("8866 Port not available!") -- 1640
	end -- 1633
end) -- 1618
return _module_0 -- 1
