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
HttpServer:post("/body/parse", function(req) -- 374
	do -- 375
		local _type_0 = type(req) -- 375
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 375
		if _tab_0 then -- 375
			local file -- 375
			do -- 375
				local _obj_0 = req.body -- 375
				local _type_1 = type(_obj_0) -- 375
				if "table" == _type_1 or "userdata" == _type_1 then -- 375
					file = _obj_0.file -- 375
				end -- 375
			end -- 375
			local content -- 375
			do -- 375
				local _obj_0 = req.body -- 375
				local _type_1 = type(_obj_0) -- 375
				if "table" == _type_1 or "userdata" == _type_1 then -- 375
					content = _obj_0.content -- 375
				end -- 375
			end -- 375
			if file ~= nil and content ~= nil then -- 375
				if not (file:sub(-6) == ".b.lua") then -- 376
					return { -- 377
						success = false, -- 377
						phase = "request", -- 377
						message = "only .b.lua files can be converted" -- 377
					} -- 377
				end -- 376
				local loader, err = load("_ENV = {}\n" .. content) -- 378
				if not loader then -- 379
					return { -- 380
						success = false, -- 380
						phase = "parse", -- 380
						message = tostring(err) -- 380
					} -- 380
				end -- 379
				local ok, data = pcall(loader) -- 381
				if not ok then -- 382
					return { -- 383
						success = false, -- 383
						phase = "execute", -- 383
						message = tostring(data) -- 383
					} -- 383
				end -- 382
				if not ("table" == type(data) and data[1] == "Array") then -- 384
					return { -- 385
						success = false, -- 385
						phase = "validate", -- 385
						message = "body lua root must be {\"Array\", ...}" -- 385
					} -- 385
				end -- 384
				local text, jsonErr = json.encode(data, false, true) -- 386
				if not text then -- 387
					return { -- 388
						success = false, -- 388
						phase = "encode", -- 388
						message = tostring(jsonErr) -- 388
					} -- 388
				end -- 387
				return { -- 389
					success = true, -- 389
					json = text -- 389
				} -- 389
			end -- 375
		end -- 375
	end -- 375
	return { -- 374
		success = false, -- 374
		phase = "request", -- 374
		message = "invalid request" -- 374
	} -- 374
end) -- 374
local updateInferedDesc -- 391
updateInferedDesc = function(infered) -- 391
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 392
		return -- 392
	end -- 392
	local key, row = infered.key, infered.row -- 393
	local codes = Content:loadAsync(key) -- 394
	if codes then -- 394
		local comments = { } -- 395
		local line = 0 -- 396
		local skipping = false -- 397
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 398
			line = line + 1 -- 399
			if line >= row then -- 400
				break -- 400
			end -- 400
			if lineCode:match("^%s*%-%- @") then -- 401
				skipping = true -- 402
				goto _continue_0 -- 403
			end -- 401
			local result = lineCode:match("^%s*%-%- (.+)") -- 404
			if result then -- 404
				if not skipping then -- 405
					comments[#comments + 1] = result -- 405
				end -- 405
			elseif #comments > 0 then -- 406
				comments = { } -- 407
				skipping = false -- 408
			end -- 404
			::_continue_0:: -- 399
		end -- 398
		infered.doc = table.concat(comments, "\n") -- 409
	end -- 394
end -- 391
HttpServer:postSchedule("/infer", function(req) -- 411
	do -- 412
		local _type_0 = type(req) -- 412
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 412
		if _tab_0 then -- 412
			local lang -- 412
			do -- 412
				local _obj_0 = req.body -- 412
				local _type_1 = type(_obj_0) -- 412
				if "table" == _type_1 or "userdata" == _type_1 then -- 412
					lang = _obj_0.lang -- 412
				end -- 412
			end -- 412
			local file -- 412
			do -- 412
				local _obj_0 = req.body -- 412
				local _type_1 = type(_obj_0) -- 412
				if "table" == _type_1 or "userdata" == _type_1 then -- 412
					file = _obj_0.file -- 412
				end -- 412
			end -- 412
			local content -- 412
			do -- 412
				local _obj_0 = req.body -- 412
				local _type_1 = type(_obj_0) -- 412
				if "table" == _type_1 or "userdata" == _type_1 then -- 412
					content = _obj_0.content -- 412
				end -- 412
			end -- 412
			local line -- 412
			do -- 412
				local _obj_0 = req.body -- 412
				local _type_1 = type(_obj_0) -- 412
				if "table" == _type_1 or "userdata" == _type_1 then -- 412
					line = _obj_0.line -- 412
				end -- 412
			end -- 412
			local row -- 412
			do -- 412
				local _obj_0 = req.body -- 412
				local _type_1 = type(_obj_0) -- 412
				if "table" == _type_1 or "userdata" == _type_1 then -- 412
					row = _obj_0.row -- 412
				end -- 412
			end -- 412
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 412
				local searchPath = getSearchPath(file) -- 413
				if "tl" == lang or "lua" == lang then -- 414
					if CheckTIC80Code(content) then -- 415
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 416
					end -- 415
					local infered = teal.inferAsync(content, line, row, searchPath) -- 417
					if (infered ~= nil) then -- 418
						updateInferedDesc(infered) -- 419
						return { -- 420
							success = true, -- 420
							infered = infered -- 420
						} -- 420
					end -- 418
				elseif "yue" == lang then -- 421
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 422
					if not luaCodes then -- 423
						return { -- 423
							success = false -- 423
						} -- 423
					end -- 423
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 424
					if (infered ~= nil) then -- 425
						local col -- 426
						file, row, col = infered.file, infered.row, infered.col -- 426
						if file == "" and row > 0 and col > 0 then -- 427
							infered.row = lineMap[row] or 0 -- 428
							infered.col = 0 -- 429
						end -- 427
						updateInferedDesc(infered) -- 430
						return { -- 431
							success = true, -- 431
							infered = infered -- 431
						} -- 431
					end -- 425
				end -- 414
			end -- 412
		end -- 412
	end -- 412
	return { -- 411
		success = false -- 411
	} -- 411
end) -- 411
local _anon_func_2 = function(doc) -- 482
	local _accum_0 = { } -- 482
	local _len_0 = 1 -- 482
	local _list_0 = doc.params -- 482
	for _index_0 = 1, #_list_0 do -- 482
		local param = _list_0[_index_0] -- 482
		_accum_0[_len_0] = param.name -- 482
		_len_0 = _len_0 + 1 -- 482
	end -- 482
	return _accum_0 -- 482
end -- 482
local getParamDocs -- 433
getParamDocs = function(signatures) -- 433
	do -- 434
		local codes = Content:loadAsync(signatures[1].file) -- 434
		if codes then -- 434
			local comments = { } -- 435
			local params = { } -- 436
			local line = 0 -- 437
			local docs = { } -- 438
			local returnType = nil -- 439
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 440
				line = line + 1 -- 441
				local needBreak = true -- 442
				for i, _des_0 in ipairs(signatures) do -- 443
					local row = _des_0.row -- 443
					if line >= row and not (docs[i] ~= nil) then -- 444
						if #comments > 0 or #params > 0 or returnType then -- 445
							docs[i] = { -- 447
								doc = table.concat(comments, "  \n"), -- 447
								returnType = returnType -- 448
							} -- 446
							if #params > 0 then -- 450
								docs[i].params = params -- 450
							end -- 450
						else -- 452
							docs[i] = false -- 452
						end -- 445
					end -- 444
					if not docs[i] then -- 453
						needBreak = false -- 453
					end -- 453
				end -- 443
				if needBreak then -- 454
					break -- 454
				end -- 454
				local result = lineCode:match("%s*%-%- (.+)") -- 455
				if result then -- 455
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 456
					if not name then -- 457
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 458
					end -- 457
					if name then -- 459
						local pname = name -- 460
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 461
							pname = pname .. "?" -- 461
						end -- 461
						params[#params + 1] = { -- 463
							name = tostring(pname) .. ": " .. tostring(typ), -- 463
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 464
						} -- 462
					else -- 467
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 467
						if typ then -- 467
							if returnType then -- 468
								returnType = returnType .. ", " .. typ -- 469
							else -- 471
								returnType = typ -- 471
							end -- 468
							result = result:gsub("@return", "**return:**") -- 472
						end -- 467
						comments[#comments + 1] = result -- 473
					end -- 459
				elseif #comments > 0 then -- 474
					comments = { } -- 475
					params = { } -- 476
					returnType = nil -- 477
				end -- 455
			end -- 440
			local results = { } -- 478
			for _index_0 = 1, #docs do -- 479
				local doc = docs[_index_0] -- 479
				if not doc then -- 480
					goto _continue_0 -- 480
				end -- 480
				if doc.params then -- 481
					doc.desc = "function(" .. tostring(table.concat(_anon_func_2(doc), ', ')) .. ")" -- 482
				else -- 484
					doc.desc = "function()" -- 484
				end -- 481
				if doc.returnType then -- 485
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 486
					doc.returnType = nil -- 487
				end -- 485
				results[#results + 1] = doc -- 488
				::_continue_0:: -- 480
			end -- 479
			if #results > 0 then -- 489
				return results -- 489
			else -- 489
				return nil -- 489
			end -- 489
		end -- 434
	end -- 434
	return nil -- 433
end -- 433
HttpServer:postSchedule("/signature", function(req) -- 491
	do -- 492
		local _type_0 = type(req) -- 492
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 492
		if _tab_0 then -- 492
			local lang -- 492
			do -- 492
				local _obj_0 = req.body -- 492
				local _type_1 = type(_obj_0) -- 492
				if "table" == _type_1 or "userdata" == _type_1 then -- 492
					lang = _obj_0.lang -- 492
				end -- 492
			end -- 492
			local file -- 492
			do -- 492
				local _obj_0 = req.body -- 492
				local _type_1 = type(_obj_0) -- 492
				if "table" == _type_1 or "userdata" == _type_1 then -- 492
					file = _obj_0.file -- 492
				end -- 492
			end -- 492
			local content -- 492
			do -- 492
				local _obj_0 = req.body -- 492
				local _type_1 = type(_obj_0) -- 492
				if "table" == _type_1 or "userdata" == _type_1 then -- 492
					content = _obj_0.content -- 492
				end -- 492
			end -- 492
			local line -- 492
			do -- 492
				local _obj_0 = req.body -- 492
				local _type_1 = type(_obj_0) -- 492
				if "table" == _type_1 or "userdata" == _type_1 then -- 492
					line = _obj_0.line -- 492
				end -- 492
			end -- 492
			local row -- 492
			do -- 492
				local _obj_0 = req.body -- 492
				local _type_1 = type(_obj_0) -- 492
				if "table" == _type_1 or "userdata" == _type_1 then -- 492
					row = _obj_0.row -- 492
				end -- 492
			end -- 492
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 492
				local searchPath = getSearchPath(file) -- 493
				if "tl" == lang or "lua" == lang then -- 494
					if CheckTIC80Code(content) then -- 495
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 496
					end -- 495
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 497
					if signatures then -- 497
						signatures = getParamDocs(signatures) -- 498
						if signatures then -- 498
							return { -- 499
								success = true, -- 499
								signatures = signatures -- 499
							} -- 499
						end -- 498
					end -- 497
				elseif "yue" == lang then -- 500
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 501
					if not luaCodes then -- 502
						return { -- 502
							success = false -- 502
						} -- 502
					end -- 502
					do -- 503
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 503
						if chainOp then -- 503
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 504
							if withVar then -- 504
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 505
							end -- 504
						end -- 503
					end -- 503
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 506
					if signatures then -- 506
						signatures = getParamDocs(signatures) -- 507
						if signatures then -- 507
							return { -- 508
								success = true, -- 508
								signatures = signatures -- 508
							} -- 508
						end -- 507
					else -- 509
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 509
						if signatures then -- 509
							signatures = getParamDocs(signatures) -- 510
							if signatures then -- 510
								return { -- 511
									success = true, -- 511
									signatures = signatures -- 511
								} -- 511
							end -- 510
						end -- 509
					end -- 506
				end -- 494
			end -- 492
		end -- 492
	end -- 492
	return { -- 491
		success = false -- 491
	} -- 491
end) -- 491
local luaKeywords = { -- 514
	'and', -- 514
	'break', -- 515
	'do', -- 516
	'else', -- 517
	'elseif', -- 518
	'end', -- 519
	'false', -- 520
	'for', -- 521
	'function', -- 522
	'goto', -- 523
	'if', -- 524
	'in', -- 525
	'local', -- 526
	'nil', -- 527
	'not', -- 528
	'or', -- 529
	'repeat', -- 530
	'return', -- 531
	'then', -- 532
	'true', -- 533
	'until', -- 534
	'while' -- 535
} -- 513
local tealKeywords = { -- 539
	'record', -- 539
	'as', -- 540
	'is', -- 541
	'type', -- 542
	'embed', -- 543
	'enum', -- 544
	'global', -- 545
	'any', -- 546
	'boolean', -- 547
	'integer', -- 548
	'number', -- 549
	'string', -- 550
	'thread' -- 551
} -- 538
local yueKeywords = { -- 555
	"and", -- 555
	"break", -- 556
	"do", -- 557
	"else", -- 558
	"elseif", -- 559
	"false", -- 560
	"for", -- 561
	"goto", -- 562
	"if", -- 563
	"in", -- 564
	"local", -- 565
	"nil", -- 566
	"not", -- 567
	"or", -- 568
	"repeat", -- 569
	"return", -- 570
	"then", -- 571
	"true", -- 572
	"until", -- 573
	"while", -- 574
	"as", -- 575
	"class", -- 576
	"continue", -- 577
	"export", -- 578
	"extends", -- 579
	"from", -- 580
	"global", -- 581
	"import", -- 582
	"macro", -- 583
	"switch", -- 584
	"try", -- 585
	"unless", -- 586
	"using", -- 587
	"when", -- 588
	"with" -- 589
} -- 554
local _anon_func_3 = function(f) -- 625
	local _val_0 = Path:getExt(f) -- 625
	return "ttf" == _val_0 or "otf" == _val_0 -- 625
end -- 625
local _anon_func_4 = function(suggestions) -- 651
	local _tbl_0 = { } -- 651
	for _index_0 = 1, #suggestions do -- 651
		local item = suggestions[_index_0] -- 651
		_tbl_0[item[1] .. item[2]] = item -- 651
	end -- 651
	return _tbl_0 -- 651
end -- 651
HttpServer:postSchedule("/complete", function(req) -- 592
	do -- 593
		local _type_0 = type(req) -- 593
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 593
		if _tab_0 then -- 593
			local lang -- 593
			do -- 593
				local _obj_0 = req.body -- 593
				local _type_1 = type(_obj_0) -- 593
				if "table" == _type_1 or "userdata" == _type_1 then -- 593
					lang = _obj_0.lang -- 593
				end -- 593
			end -- 593
			local file -- 593
			do -- 593
				local _obj_0 = req.body -- 593
				local _type_1 = type(_obj_0) -- 593
				if "table" == _type_1 or "userdata" == _type_1 then -- 593
					file = _obj_0.file -- 593
				end -- 593
			end -- 593
			local content -- 593
			do -- 593
				local _obj_0 = req.body -- 593
				local _type_1 = type(_obj_0) -- 593
				if "table" == _type_1 or "userdata" == _type_1 then -- 593
					content = _obj_0.content -- 593
				end -- 593
			end -- 593
			local line -- 593
			do -- 593
				local _obj_0 = req.body -- 593
				local _type_1 = type(_obj_0) -- 593
				if "table" == _type_1 or "userdata" == _type_1 then -- 593
					line = _obj_0.line -- 593
				end -- 593
			end -- 593
			local row -- 593
			do -- 593
				local _obj_0 = req.body -- 593
				local _type_1 = type(_obj_0) -- 593
				if "table" == _type_1 or "userdata" == _type_1 then -- 593
					row = _obj_0.row -- 593
				end -- 593
			end -- 593
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 593
				local searchPath = getSearchPath(file) -- 594
				repeat -- 595
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 596
					if lang == "yue" then -- 597
						if not item then -- 598
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 598
						end -- 598
						if not item then -- 599
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 599
						end -- 599
					end -- 597
					local searchType = nil -- 600
					if not item then -- 601
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 602
						if lang == "yue" then -- 603
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 604
						end -- 603
						if (item ~= nil) then -- 605
							searchType = "Image" -- 605
						end -- 605
					end -- 601
					if not item then -- 606
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 607
						if lang == "yue" then -- 608
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 609
						end -- 608
						if (item ~= nil) then -- 610
							searchType = "Font" -- 610
						end -- 610
					end -- 606
					if not item then -- 611
						break -- 611
					end -- 611
					local searchPaths = Content.searchPaths -- 612
					local _list_0 = getSearchFolders(file) -- 613
					for _index_0 = 1, #_list_0 do -- 613
						local folder = _list_0[_index_0] -- 613
						searchPaths[#searchPaths + 1] = folder -- 614
					end -- 613
					if searchType then -- 615
						searchPaths[#searchPaths + 1] = Content.assetPath -- 615
					end -- 615
					local tokens -- 616
					do -- 616
						local _accum_0 = { } -- 616
						local _len_0 = 1 -- 616
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 616
							_accum_0[_len_0] = mod -- 616
							_len_0 = _len_0 + 1 -- 616
						end -- 616
						tokens = _accum_0 -- 616
					end -- 616
					local suggestions = { } -- 617
					for _index_0 = 1, #searchPaths do -- 618
						local path = searchPaths[_index_0] -- 618
						local sPath = Path(path, table.unpack(tokens)) -- 619
						if not Content:exist(sPath) then -- 620
							goto _continue_0 -- 620
						end -- 620
						if searchType == "Font" then -- 621
							local fontPath = Path(sPath, "Font") -- 622
							if Content:exist(fontPath) then -- 623
								local _list_1 = Content:getFiles(fontPath) -- 624
								for _index_1 = 1, #_list_1 do -- 624
									local f = _list_1[_index_1] -- 624
									if _anon_func_3(f) then -- 625
										if "." == f:sub(1, 1) then -- 626
											goto _continue_1 -- 626
										end -- 626
										suggestions[#suggestions + 1] = { -- 627
											Path:getName(f), -- 627
											"font", -- 627
											"field" -- 627
										} -- 627
									end -- 625
									::_continue_1:: -- 625
								end -- 624
							end -- 623
						end -- 621
						local _list_1 = Content:getFiles(sPath) -- 628
						for _index_1 = 1, #_list_1 do -- 628
							local f = _list_1[_index_1] -- 628
							if "Image" == searchType then -- 629
								do -- 630
									local _exp_0 = Path:getExt(f) -- 630
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 630
										if "." == f:sub(1, 1) then -- 631
											goto _continue_2 -- 631
										end -- 631
										suggestions[#suggestions + 1] = { -- 632
											f, -- 632
											"image", -- 632
											"field" -- 632
										} -- 632
									end -- 630
								end -- 630
								goto _continue_2 -- 633
							elseif "Font" == searchType then -- 634
								do -- 635
									local _exp_0 = Path:getExt(f) -- 635
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 635
										if "." == f:sub(1, 1) then -- 636
											goto _continue_2 -- 636
										end -- 636
										suggestions[#suggestions + 1] = { -- 637
											f, -- 637
											"font", -- 637
											"field" -- 637
										} -- 637
									end -- 635
								end -- 635
								goto _continue_2 -- 638
							end -- 629
							local _exp_0 = Path:getExt(f) -- 639
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 639
								local name = Path:getName(f) -- 640
								if "d" == Path:getExt(name) then -- 641
									goto _continue_2 -- 641
								end -- 641
								if "." == name:sub(1, 1) then -- 642
									goto _continue_2 -- 642
								end -- 642
								suggestions[#suggestions + 1] = { -- 643
									name, -- 643
									"module", -- 643
									"field" -- 643
								} -- 643
							end -- 639
							::_continue_2:: -- 629
						end -- 628
						local _list_2 = Content:getDirs(sPath) -- 644
						for _index_1 = 1, #_list_2 do -- 644
							local dir = _list_2[_index_1] -- 644
							if "." == dir:sub(1, 1) then -- 645
								goto _continue_3 -- 645
							end -- 645
							suggestions[#suggestions + 1] = { -- 646
								dir, -- 646
								"folder", -- 646
								"variable" -- 646
							} -- 646
							::_continue_3:: -- 645
						end -- 644
						::_continue_0:: -- 619
					end -- 618
					if item == "" and not searchType then -- 647
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 648
						for _index_0 = 1, #_list_1 do -- 648
							local _des_0 = _list_1[_index_0] -- 648
							local name = _des_0[1] -- 648
							suggestions[#suggestions + 1] = { -- 649
								name, -- 649
								"dora module", -- 649
								"function" -- 649
							} -- 649
						end -- 648
					end -- 647
					if #suggestions > 0 then -- 650
						do -- 651
							local _accum_0 = { } -- 651
							local _len_0 = 1 -- 651
							for _, v in pairs(_anon_func_4(suggestions)) do -- 651
								_accum_0[_len_0] = v -- 651
								_len_0 = _len_0 + 1 -- 651
							end -- 651
							suggestions = _accum_0 -- 651
						end -- 651
						return { -- 652
							success = true, -- 652
							suggestions = suggestions -- 652
						} -- 652
					else -- 654
						return { -- 654
							success = false -- 654
						} -- 654
					end -- 650
				until true -- 595
				if "tl" == lang or "lua" == lang then -- 656
					do -- 657
						local isTIC80 = CheckTIC80Code(content) -- 657
						if isTIC80 then -- 657
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 658
						end -- 657
					end -- 657
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 659
					if not line:match("[%.:]$") then -- 660
						local checkSet -- 661
						do -- 661
							local _tbl_0 = { } -- 661
							for _index_0 = 1, #suggestions do -- 661
								local _des_0 = suggestions[_index_0] -- 661
								local name = _des_0[1] -- 661
								_tbl_0[name] = true -- 661
							end -- 661
							checkSet = _tbl_0 -- 661
						end -- 661
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 662
						for _index_0 = 1, #_list_0 do -- 662
							local item = _list_0[_index_0] -- 662
							if not checkSet[item[1]] then -- 663
								suggestions[#suggestions + 1] = item -- 663
							end -- 663
						end -- 662
						for _index_0 = 1, #luaKeywords do -- 664
							local word = luaKeywords[_index_0] -- 664
							suggestions[#suggestions + 1] = { -- 665
								word, -- 665
								"keyword", -- 665
								"keyword" -- 665
							} -- 665
						end -- 664
						if lang == "tl" then -- 666
							for _index_0 = 1, #tealKeywords do -- 667
								local word = tealKeywords[_index_0] -- 667
								suggestions[#suggestions + 1] = { -- 668
									word, -- 668
									"keyword", -- 668
									"keyword" -- 668
								} -- 668
							end -- 667
						end -- 666
					end -- 660
					if #suggestions > 0 then -- 669
						return { -- 670
							success = true, -- 670
							suggestions = suggestions -- 670
						} -- 670
					end -- 669
				elseif "yue" == lang then -- 671
					local suggestions = { } -- 672
					local gotGlobals = false -- 673
					do -- 674
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 674
						if luaCodes then -- 674
							gotGlobals = true -- 675
							do -- 676
								local chainOp = line:match("[^%w_]([%.\\])$") -- 676
								if chainOp then -- 676
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 677
									if not withVar then -- 678
										return { -- 678
											success = false -- 678
										} -- 678
									end -- 678
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 679
								elseif line:match("^([%.\\])$") then -- 680
									return { -- 681
										success = false -- 681
									} -- 681
								end -- 676
							end -- 676
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 682
							for _index_0 = 1, #_list_0 do -- 682
								local item = _list_0[_index_0] -- 682
								suggestions[#suggestions + 1] = item -- 682
							end -- 682
							if #suggestions == 0 then -- 683
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 684
								for _index_0 = 1, #_list_1 do -- 684
									local item = _list_1[_index_0] -- 684
									suggestions[#suggestions + 1] = item -- 684
								end -- 684
							end -- 683
						end -- 674
					end -- 674
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 685
						local checkSet -- 686
						do -- 686
							local _tbl_0 = { } -- 686
							for _index_0 = 1, #suggestions do -- 686
								local _des_0 = suggestions[_index_0] -- 686
								local name = _des_0[1] -- 686
								_tbl_0[name] = true -- 686
							end -- 686
							checkSet = _tbl_0 -- 686
						end -- 686
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 687
						for _index_0 = 1, #_list_0 do -- 687
							local item = _list_0[_index_0] -- 687
							if not checkSet[item[1]] then -- 688
								suggestions[#suggestions + 1] = item -- 688
							end -- 688
						end -- 687
						if not gotGlobals then -- 689
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 690
							for _index_0 = 1, #_list_1 do -- 690
								local item = _list_1[_index_0] -- 690
								if not checkSet[item[1]] then -- 691
									suggestions[#suggestions + 1] = item -- 691
								end -- 691
							end -- 690
						end -- 689
						for _index_0 = 1, #yueKeywords do -- 692
							local word = yueKeywords[_index_0] -- 692
							if not checkSet[word] then -- 693
								suggestions[#suggestions + 1] = { -- 694
									word, -- 694
									"keyword", -- 694
									"keyword" -- 694
								} -- 694
							end -- 693
						end -- 692
					end -- 685
					if #suggestions > 0 then -- 695
						return { -- 696
							success = true, -- 696
							suggestions = suggestions -- 696
						} -- 696
					end -- 695
				elseif "xml" == lang then -- 697
					local items = xml.complete(content) -- 698
					if #items > 0 then -- 699
						local suggestions -- 700
						do -- 700
							local _accum_0 = { } -- 700
							local _len_0 = 1 -- 700
							for _index_0 = 1, #items do -- 700
								local _des_0 = items[_index_0] -- 700
								local label, insertText = _des_0[1], _des_0[2] -- 700
								_accum_0[_len_0] = { -- 701
									label, -- 701
									insertText, -- 701
									"field" -- 701
								} -- 701
								_len_0 = _len_0 + 1 -- 701
							end -- 700
							suggestions = _accum_0 -- 700
						end -- 700
						return { -- 702
							success = true, -- 702
							suggestions = suggestions -- 702
						} -- 702
					end -- 699
				end -- 656
			end -- 593
		end -- 593
	end -- 593
	return { -- 592
		success = false -- 592
	} -- 592
end) -- 592
HttpServer:upload("/upload", function(req, filename) -- 706
	do -- 707
		local _type_0 = type(req) -- 707
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 707
		if _tab_0 then -- 707
			local path -- 707
			do -- 707
				local _obj_0 = req.params -- 707
				local _type_1 = type(_obj_0) -- 707
				if "table" == _type_1 or "userdata" == _type_1 then -- 707
					path = _obj_0.path -- 707
				end -- 707
			end -- 707
			if path ~= nil then -- 707
				local uploadPath = Path(Content.writablePath, ".upload") -- 708
				if not Content:exist(uploadPath) then -- 709
					Content:mkdir(uploadPath) -- 710
				end -- 709
				local targetPath = Path(uploadPath, filename) -- 711
				Content:mkdir(Path:getPath(targetPath)) -- 712
				return targetPath -- 713
			end -- 707
		end -- 707
	end -- 707
	return nil -- 706
end, function(req, file) -- 714
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
				path = Path(Content.writablePath, path) -- 716
				if Content:exist(path) then -- 717
					local uploadPath = Path(Content.writablePath, ".upload") -- 718
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 719
					Content:mkdir(Path:getPath(targetPath)) -- 720
					if Content:move(file, targetPath) then -- 721
						return true -- 722
					end -- 721
				end -- 717
			end -- 715
		end -- 715
	end -- 715
	return false -- 714
end) -- 704
HttpServer:post("/list", function(req) -- 725
	do -- 726
		local _type_0 = type(req) -- 726
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 726
		if _tab_0 then -- 726
			local path -- 726
			do -- 726
				local _obj_0 = req.body -- 726
				local _type_1 = type(_obj_0) -- 726
				if "table" == _type_1 or "userdata" == _type_1 then -- 726
					path = _obj_0.path -- 726
				end -- 726
			end -- 726
			if path ~= nil then -- 726
				if Content:exist(path) then -- 727
					local files = { } -- 728
					local visitAssets -- 729
					visitAssets = function(path, folder) -- 729
						local dirs = Content:getDirs(path) -- 730
						for _index_0 = 1, #dirs do -- 731
							local dir = dirs[_index_0] -- 731
							if dir:match("^%.") then -- 732
								goto _continue_0 -- 732
							end -- 732
							local current -- 733
							if folder == "" then -- 733
								current = dir -- 734
							else -- 736
								current = Path(folder, dir) -- 736
							end -- 733
							files[#files + 1] = current -- 737
							visitAssets(Path(path, dir), current) -- 738
							::_continue_0:: -- 732
						end -- 731
						local fs = Content:getFiles(path) -- 739
						for _index_0 = 1, #fs do -- 740
							local f = fs[_index_0] -- 740
							if f:match("^%.") then -- 741
								goto _continue_1 -- 741
							end -- 741
							if folder == "" then -- 742
								files[#files + 1] = f -- 743
							else -- 745
								files[#files + 1] = Path(folder, f) -- 745
							end -- 742
							::_continue_1:: -- 741
						end -- 740
					end -- 729
					visitAssets(path, "") -- 746
					if #files == 0 then -- 747
						files = nil -- 747
					end -- 747
					return { -- 748
						success = true, -- 748
						files = files -- 748
					} -- 748
				end -- 727
			end -- 726
		end -- 726
	end -- 726
	return { -- 725
		success = false -- 725
	} -- 725
end) -- 725
HttpServer:post("/info", function() -- 750
	local Entry = require("Script.Dev.Entry") -- 751
	local webProfiler, drawerWidth -- 752
	do -- 752
		local _obj_0 = Entry.getConfig() -- 752
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 752
	end -- 752
	local engineDev = Entry.getEngineDev() -- 753
	Entry.connectWebIDE() -- 754
	return { -- 756
		platform = App.platform, -- 756
		locale = App.locale, -- 757
		version = App.version, -- 758
		engineDev = engineDev, -- 759
		webProfiler = webProfiler, -- 760
		drawerWidth = drawerWidth -- 761
	} -- 755
end) -- 750
local ensureLLMConfigTable -- 763
ensureLLMConfigTable = function() -- 763
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 764
	if columns and #columns > 0 then -- 765
		local expected = { -- 767
			id = true, -- 767
			name = true, -- 768
			url = true, -- 769
			model = true, -- 770
			api_key = true, -- 771
			context_window = true, -- 772
			temperature = true, -- 773
			max_tokens = true, -- 774
			reasoning_effort = true, -- 775
			custom_options = true, -- 776
			supports_function_calling = true, -- 777
			active = true, -- 778
			created_at = true, -- 779
			updated_at = true -- 780
		} -- 766
		local existing = { } -- 782
		local valid = true -- 783
		for _index_0 = 1, #columns do -- 784
			local row = columns[_index_0] -- 784
			local columnName = tostring(row[2]) -- 785
			existing[columnName] = true -- 786
			if not expected[columnName] then -- 787
				valid = false -- 788
				break -- 789
			end -- 787
		end -- 784
		if valid then -- 790
			if not existing.context_window then -- 791
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 792
			end -- 791
			if not existing.temperature then -- 793
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 794
			end -- 793
			if not existing.max_tokens then -- 795
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 796
			end -- 795
			if not existing.reasoning_effort then -- 797
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 798
			end -- 797
			if not existing.custom_options then -- 799
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 800
			end -- 799
			if not existing.supports_function_calling then -- 801
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 802
			end -- 801
		else -- 804
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 804
		end -- 790
	end -- 765
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
	]]) -- 805
end -- 763
local normalizeContextWindow -- 824
normalizeContextWindow = function(value) -- 824
	local contextWindow = tonumber(value) -- 825
	if contextWindow == nil or contextWindow < 64000 then -- 826
		return 64000 -- 827
	end -- 826
	return math.max(64000, math.floor(contextWindow)) -- 828
end -- 824
local normalizeTemperature -- 830
normalizeTemperature = function(value) -- 830
	local temperature = tonumber(value) -- 831
	if temperature == nil then -- 832
		return 0.1 -- 833
	end -- 832
	return math.max(0, math.min(2, temperature)) -- 834
end -- 830
local normalizeMaxTokens -- 836
normalizeMaxTokens = function(value) -- 836
	local maxTokens = tonumber(value) -- 837
	if maxTokens == nil or maxTokens < 1 then -- 838
		return 8192 -- 839
	end -- 838
	return math.max(1, math.floor(maxTokens)) -- 840
end -- 836
local normalizeReasoningEffort -- 842
normalizeReasoningEffort = function(value) -- 842
	if value == nil then -- 843
		return "" -- 844
	end -- 843
	local effort = tostring(value) -- 845
	return effort:match("^%s*(.-)%s*$") or "" -- 846
end -- 842
local normalizeCustomOptions -- 848
normalizeCustomOptions = function(value) -- 848
	if value == nil then -- 849
		return "" -- 850
	end -- 849
	local options = tostring(value) -- 851
	options = options:match("^%s*(.-)%s*$") or "" -- 852
	return options -- 853
end -- 848
local validateCustomOptions -- 855
validateCustomOptions = function(value) -- 855
	local options = normalizeCustomOptions(value) -- 856
	if options == "" then -- 857
		return true -- 857
	end -- 857
	if not options:match("^%s*{") then -- 858
		return false -- 858
	end -- 858
	local decoded = json.decode(options) -- 859
	return type(decoded) == "table" -- 860
end -- 855
HttpServer:post("/llm/list", function() -- 862
	ensureLLMConfigTable() -- 863
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 864
	local items -- 868
	if rows and #rows > 0 then -- 868
		local _accum_0 = { } -- 869
		local _len_0 = 1 -- 869
		for _index_0 = 1, #rows do -- 869
			local _des_0 = rows[_index_0] -- 869
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11], _des_0[12] -- 869
			_accum_0[_len_0] = { -- 870
				id = id, -- 870
				name = name, -- 870
				url = url, -- 870
				model = model, -- 870
				key = key, -- 870
				contextWindow = normalizeContextWindow(contextWindow), -- 870
				temperature = normalizeTemperature(temperature), -- 870
				maxTokens = normalizeMaxTokens(maxTokens), -- 870
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 870
				customOptions = normalizeCustomOptions(customOptions), -- 870
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 870
				active = active ~= 0 -- 870
			} -- 870
			_len_0 = _len_0 + 1 -- 870
		end -- 869
		items = _accum_0 -- 868
	end -- 868
	return { -- 871
		success = true, -- 871
		items = items -- 871
	} -- 871
end) -- 862
HttpServer:post("/llm/create", function(req) -- 873
	ensureLLMConfigTable() -- 874
	do -- 875
		local _type_0 = type(req) -- 875
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 875
		if _tab_0 then -- 875
			local body = req.body -- 875
			if body ~= nil then -- 875
				local name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 876
				local now = os.time() -- 877
				if name == nil or url == nil or model == nil or key == nil then -- 878
					return { -- 879
						success = false, -- 879
						message = "invalid" -- 879
					} -- 879
				end -- 878
				contextWindow = normalizeContextWindow(contextWindow) -- 880
				temperature = normalizeTemperature(temperature) -- 881
				maxTokens = normalizeMaxTokens(maxTokens) -- 882
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 883
				customOptions = normalizeCustomOptions(customOptions) -- 884
				if not validateCustomOptions(customOptions) then -- 885
					return { -- 885
						success = false, -- 885
						message = "customOptions must be a JSON object" -- 885
					} -- 885
				end -- 885
				if supportsFunctionCalling == false then -- 886
					supportsFunctionCalling = 0 -- 886
				else -- 886
					supportsFunctionCalling = 1 -- 886
				end -- 886
				if active then -- 887
					active = 1 -- 887
				else -- 887
					active = 0 -- 887
				end -- 887
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 894
					tostring(name), -- 894
					tostring(url), -- 895
					tostring(model), -- 896
					tostring(key), -- 897
					contextWindow, -- 898
					temperature, -- 899
					maxTokens, -- 900
					reasoningEffort, -- 901
					customOptions, -- 902
					supportsFunctionCalling, -- 903
					active, -- 904
					now, -- 905
					now -- 906
				}) -- 888
				return { -- 908
					success = affected >= 0 -- 908
				} -- 908
			end -- 875
		end -- 875
	end -- 875
	return { -- 873
		success = false, -- 873
		message = "invalid" -- 873
	} -- 873
end) -- 873
HttpServer:post("/llm/update", function(req) -- 910
	ensureLLMConfigTable() -- 911
	do -- 912
		local _type_0 = type(req) -- 912
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 912
		if _tab_0 then -- 912
			local body = req.body -- 912
			if body ~= nil then -- 912
				local id, name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 913
				local now = os.time() -- 914
				id = tonumber(id) -- 915
				if id == nil then -- 916
					return { -- 917
						success = false, -- 917
						message = "invalid" -- 917
					} -- 917
				end -- 916
				contextWindow = normalizeContextWindow(contextWindow) -- 918
				temperature = normalizeTemperature(temperature) -- 919
				maxTokens = normalizeMaxTokens(maxTokens) -- 920
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 921
				customOptions = normalizeCustomOptions(customOptions) -- 922
				if not validateCustomOptions(customOptions) then -- 923
					return { -- 923
						success = false, -- 923
						message = "customOptions must be a JSON object" -- 923
					} -- 923
				end -- 923
				if supportsFunctionCalling == false then -- 924
					supportsFunctionCalling = 0 -- 924
				else -- 924
					supportsFunctionCalling = 1 -- 924
				end -- 924
				if active then -- 925
					active = 1 -- 925
				else -- 925
					active = 0 -- 925
				end -- 925
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 930
					tostring(name), -- 930
					tostring(url), -- 931
					tostring(model), -- 932
					tostring(key), -- 933
					contextWindow, -- 934
					temperature, -- 935
					maxTokens, -- 936
					reasoningEffort, -- 937
					customOptions, -- 938
					supportsFunctionCalling, -- 939
					active, -- 940
					now, -- 941
					id -- 942
				}) -- 926
				return { -- 944
					success = affected >= 0 -- 944
				} -- 944
			end -- 912
		end -- 912
	end -- 912
	return { -- 910
		success = false, -- 910
		message = "invalid" -- 910
	} -- 910
end) -- 910
HttpServer:post("/llm/delete", function(req) -- 946
	ensureLLMConfigTable() -- 947
	do -- 948
		local _type_0 = type(req) -- 948
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 948
		if _tab_0 then -- 948
			local id -- 948
			do -- 948
				local _obj_0 = req.body -- 948
				local _type_1 = type(_obj_0) -- 948
				if "table" == _type_1 or "userdata" == _type_1 then -- 948
					id = _obj_0.id -- 948
				end -- 948
			end -- 948
			if id ~= nil then -- 948
				id = tonumber(id) -- 949
				if id == nil then -- 950
					return { -- 951
						success = false, -- 951
						message = "invalid" -- 951
					} -- 951
				end -- 950
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 952
					id -- 952
				}) -- 952
				return { -- 953
					success = affected >= 0 -- 953
				} -- 953
			end -- 948
		end -- 948
	end -- 948
	return { -- 946
		success = false, -- 946
		message = "invalid" -- 946
	} -- 946
end) -- 946
HttpServer:post("/new", function(req) -- 955
	do -- 956
		local _type_0 = type(req) -- 956
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 956
		if _tab_0 then -- 956
			local path -- 956
			do -- 956
				local _obj_0 = req.body -- 956
				local _type_1 = type(_obj_0) -- 956
				if "table" == _type_1 or "userdata" == _type_1 then -- 956
					path = _obj_0.path -- 956
				end -- 956
			end -- 956
			local content -- 956
			do -- 956
				local _obj_0 = req.body -- 956
				local _type_1 = type(_obj_0) -- 956
				if "table" == _type_1 or "userdata" == _type_1 then -- 956
					content = _obj_0.content -- 956
				end -- 956
			end -- 956
			local folder -- 956
			do -- 956
				local _obj_0 = req.body -- 956
				local _type_1 = type(_obj_0) -- 956
				if "table" == _type_1 or "userdata" == _type_1 then -- 956
					folder = _obj_0.folder -- 956
				end -- 956
			end -- 956
			if path ~= nil and content ~= nil and folder ~= nil then -- 956
				if Content:exist(path) then -- 957
					return { -- 958
						success = false, -- 958
						message = "TargetExisted" -- 958
					} -- 958
				end -- 957
				local parent = Path:getPath(path) -- 959
				local files = Content:getFiles(parent) -- 960
				if folder then -- 961
					local name = Path:getFilename(path):lower() -- 962
					for _index_0 = 1, #files do -- 963
						local file = files[_index_0] -- 963
						if name == Path:getFilename(file):lower() then -- 964
							return { -- 965
								success = false, -- 965
								message = "TargetExisted" -- 965
							} -- 965
						end -- 964
					end -- 963
					if Content:mkdir(path) then -- 966
						return { -- 967
							success = true -- 967
						} -- 967
					end -- 966
				else -- 969
					local name = Path:getName(path):lower() -- 969
					for _index_0 = 1, #files do -- 970
						local file = files[_index_0] -- 970
						if name == Path:getName(file):lower() then -- 971
							local ext = Path:getExt(file) -- 972
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 973
								goto _continue_0 -- 974
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 975
								goto _continue_0 -- 976
							end -- 973
							return { -- 977
								success = false, -- 977
								message = "SourceExisted" -- 977
							} -- 977
						end -- 971
						::_continue_0:: -- 971
					end -- 970
					if Content:save(path, content) then -- 978
						return { -- 979
							success = true -- 979
						} -- 979
					end -- 978
				end -- 961
			end -- 956
		end -- 956
	end -- 956
	return { -- 955
		success = false, -- 955
		message = "Failed" -- 955
	} -- 955
end) -- 955
HttpServer:post("/delete", function(req) -- 981
	do -- 982
		local _type_0 = type(req) -- 982
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 982
		if _tab_0 then -- 982
			local path -- 982
			do -- 982
				local _obj_0 = req.body -- 982
				local _type_1 = type(_obj_0) -- 982
				if "table" == _type_1 or "userdata" == _type_1 then -- 982
					path = _obj_0.path -- 982
				end -- 982
			end -- 982
			if path ~= nil then -- 982
				if Content:exist(path) then -- 983
					local projectRoot -- 984
					if Content:isdir(path) and isProjectRootDir(path) then -- 984
						projectRoot = path -- 984
					else -- 984
						projectRoot = nil -- 984
					end -- 984
					local parent = Path:getPath(path) -- 985
					local files = Content:getFiles(parent) -- 986
					local name = Path:getName(path):lower() -- 987
					local ext = Path:getExt(path) -- 988
					for _index_0 = 1, #files do -- 989
						local file = files[_index_0] -- 989
						if name == Path:getName(file):lower() then -- 990
							local _exp_0 = Path:getExt(file) -- 991
							if "tl" == _exp_0 then -- 991
								if ("vs" == ext) then -- 991
									Content:remove(Path(parent, file)) -- 992
								end -- 991
							elseif "lua" == _exp_0 then -- 993
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 993
									Content:remove(Path(parent, file)) -- 994
								end -- 993
							end -- 991
						end -- 990
					end -- 989
					if Content:remove(path) then -- 995
						if projectRoot then -- 996
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 997
						end -- 996
						return { -- 998
							success = true -- 998
						} -- 998
					end -- 995
				end -- 983
			end -- 982
		end -- 982
	end -- 982
	return { -- 981
		success = false -- 981
	} -- 981
end) -- 981
HttpServer:post("/rename", function(req) -- 1000
	do -- 1001
		local _type_0 = type(req) -- 1001
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1001
		if _tab_0 then -- 1001
			local old -- 1001
			do -- 1001
				local _obj_0 = req.body -- 1001
				local _type_1 = type(_obj_0) -- 1001
				if "table" == _type_1 or "userdata" == _type_1 then -- 1001
					old = _obj_0.old -- 1001
				end -- 1001
			end -- 1001
			local new -- 1001
			do -- 1001
				local _obj_0 = req.body -- 1001
				local _type_1 = type(_obj_0) -- 1001
				if "table" == _type_1 or "userdata" == _type_1 then -- 1001
					new = _obj_0.new -- 1001
				end -- 1001
			end -- 1001
			if old ~= nil and new ~= nil then -- 1001
				if Content:exist(old) and not Content:exist(new) then -- 1002
					local renamedDir = Content:isdir(old) -- 1003
					local parent = Path:getPath(new) -- 1004
					local files = Content:getFiles(parent) -- 1005
					if renamedDir then -- 1006
						local name = Path:getFilename(new):lower() -- 1007
						for _index_0 = 1, #files do -- 1008
							local file = files[_index_0] -- 1008
							if name == Path:getFilename(file):lower() then -- 1009
								return { -- 1010
									success = false -- 1010
								} -- 1010
							end -- 1009
						end -- 1008
					else -- 1012
						local name = Path:getName(new):lower() -- 1012
						local ext = Path:getExt(new) -- 1013
						for _index_0 = 1, #files do -- 1014
							local file = files[_index_0] -- 1014
							if name == Path:getName(file):lower() then -- 1015
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1016
									goto _continue_0 -- 1017
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1018
									goto _continue_0 -- 1019
								end -- 1016
								return { -- 1020
									success = false -- 1020
								} -- 1020
							end -- 1015
							::_continue_0:: -- 1015
						end -- 1014
					end -- 1006
					if Content:move(old, new) then -- 1021
						if renamedDir then -- 1022
							AgentSession.renameSessionsByProjectRoot(old, new) -- 1023
						end -- 1022
						local newParent = Path:getPath(new) -- 1024
						parent = Path:getPath(old) -- 1025
						files = Content:getFiles(parent) -- 1026
						local newName = Path:getName(new) -- 1027
						local oldName = Path:getName(old) -- 1028
						local name = oldName:lower() -- 1029
						local ext = Path:getExt(old) -- 1030
						for _index_0 = 1, #files do -- 1031
							local file = files[_index_0] -- 1031
							if name == Path:getName(file):lower() then -- 1032
								local _exp_0 = Path:getExt(file) -- 1033
								if "tl" == _exp_0 then -- 1033
									if ("vs" == ext) then -- 1033
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1034
									end -- 1033
								elseif "lua" == _exp_0 then -- 1035
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1035
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1036
									end -- 1035
								end -- 1033
							end -- 1032
						end -- 1031
						return { -- 1037
							success = true -- 1037
						} -- 1037
					end -- 1021
				end -- 1002
			end -- 1001
		end -- 1001
	end -- 1001
	return { -- 1000
		success = false -- 1000
	} -- 1000
end) -- 1000
HttpServer:post("/exist", function(req) -- 1039
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
			if file ~= nil then -- 1040
				do -- 1041
					local projFile = req.body.projFile -- 1041
					if projFile then -- 1041
						local projDir = getProjectDirFromFile(projFile) -- 1042
						if projDir then -- 1042
							local scriptDir = Path(projDir, "Script") -- 1043
							local searchPaths = Content.searchPaths -- 1044
							if Content:exist(scriptDir) then -- 1045
								Content:addSearchPath(scriptDir) -- 1045
							end -- 1045
							if Content:exist(projDir) then -- 1046
								Content:addSearchPath(projDir) -- 1046
							end -- 1046
							local _ <close> = setmetatable({ }, { -- 1047
								__close = function() -- 1047
									Content.searchPaths = searchPaths -- 1047
								end -- 1047
							}) -- 1047
							return { -- 1048
								success = Content:exist(file) -- 1048
							} -- 1048
						end -- 1042
					end -- 1041
				end -- 1041
				return { -- 1049
					success = Content:exist(file) -- 1049
				} -- 1049
			end -- 1040
		end -- 1040
	end -- 1040
	return { -- 1039
		success = false -- 1039
	} -- 1039
end) -- 1039
HttpServer:postSchedule("/read", function(req) -- 1051
	do -- 1052
		local _type_0 = type(req) -- 1052
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1052
		if _tab_0 then -- 1052
			local path -- 1052
			do -- 1052
				local _obj_0 = req.body -- 1052
				local _type_1 = type(_obj_0) -- 1052
				if "table" == _type_1 or "userdata" == _type_1 then -- 1052
					path = _obj_0.path -- 1052
				end -- 1052
			end -- 1052
			if path ~= nil then -- 1052
				local readFile -- 1053
				readFile = function() -- 1053
					if Content:exist(path) then -- 1054
						local content = Content:loadAsync(path) -- 1055
						if content then -- 1055
							return { -- 1056
								content = content, -- 1056
								success = true, -- 1056
								fullPath = Content:getFullPath(path) -- 1056
							} -- 1056
						end -- 1055
					end -- 1054
					return nil -- 1053
				end -- 1053
				do -- 1057
					local projFile = req.body.projFile -- 1057
					if projFile then -- 1057
						local projDir = getProjectDirFromFile(projFile) -- 1058
						if projDir then -- 1058
							local scriptDir = Path(projDir, "Script") -- 1059
							local searchPaths = Content.searchPaths -- 1060
							if Content:exist(scriptDir) then -- 1061
								Content:addSearchPath(scriptDir) -- 1061
							end -- 1061
							if Content:exist(projDir) then -- 1062
								Content:addSearchPath(projDir) -- 1062
							end -- 1062
							local _ <close> = setmetatable({ }, { -- 1063
								__close = function() -- 1063
									Content.searchPaths = searchPaths -- 1063
								end -- 1063
							}) -- 1063
							local result = readFile() -- 1064
							if result then -- 1064
								return result -- 1064
							end -- 1064
						end -- 1058
					end -- 1057
				end -- 1057
				local result = readFile() -- 1065
				if result then -- 1065
					return result -- 1065
				end -- 1065
			end -- 1052
		end -- 1052
	end -- 1052
	return { -- 1051
		success = false -- 1051
	} -- 1051
end) -- 1051
HttpServer:get("/read-sync", function(req) -- 1067
	do -- 1068
		local _type_0 = type(req) -- 1068
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1068
		if _tab_0 then -- 1068
			local params = req.params -- 1068
			if params ~= nil then -- 1068
				local path = params.path -- 1069
				local exts -- 1070
				if params.exts then -- 1070
					local _accum_0 = { } -- 1071
					local _len_0 = 1 -- 1071
					for ext in params.exts:gmatch("[^|]*") do -- 1071
						_accum_0[_len_0] = ext -- 1072
						_len_0 = _len_0 + 1 -- 1072
					end -- 1071
					exts = _accum_0 -- 1070
				else -- 1073
					exts = { -- 1073
						"" -- 1073
					} -- 1073
				end -- 1070
				local readFile -- 1074
				readFile = function() -- 1074
					for _index_0 = 1, #exts do -- 1075
						local ext = exts[_index_0] -- 1075
						local targetPath = path .. ext -- 1076
						if Content:exist(targetPath) then -- 1077
							local content = Content:load(targetPath) -- 1078
							if content then -- 1078
								return { -- 1079
									content = content, -- 1079
									success = true, -- 1079
									fullPath = Content:getFullPath(targetPath) -- 1079
								} -- 1079
							end -- 1078
						end -- 1077
					end -- 1075
					return nil -- 1074
				end -- 1074
				local searchPaths = Content.searchPaths -- 1080
				local _ <close> = setmetatable({ }, { -- 1081
					__close = function() -- 1081
						Content.searchPaths = searchPaths -- 1081
					end -- 1081
				}) -- 1081
				do -- 1082
					local projFile = req.params.projFile -- 1082
					if projFile then -- 1082
						local projDir = getProjectDirFromFile(projFile) -- 1083
						if projDir then -- 1083
							local scriptDir = Path(projDir, "Script") -- 1084
							if Content:exist(scriptDir) then -- 1085
								Content:addSearchPath(scriptDir) -- 1085
							end -- 1085
							if Content:exist(projDir) then -- 1086
								Content:addSearchPath(projDir) -- 1086
							end -- 1086
						else -- 1088
							projDir = Path:getPath(projFile) -- 1088
							if Content:exist(projDir) then -- 1089
								Content:addSearchPath(projDir) -- 1089
							end -- 1089
						end -- 1083
					end -- 1082
				end -- 1082
				local result = readFile() -- 1090
				if result then -- 1090
					return result -- 1090
				end -- 1090
			end -- 1068
		end -- 1068
	end -- 1068
	return { -- 1067
		success = false -- 1067
	} -- 1067
end) -- 1067
local compileFileAsync -- 1092
compileFileAsync = function(inputFile, sourceCodes) -- 1092
	local file = inputFile -- 1093
	local searchPath -- 1094
	do -- 1094
		local dir = getProjectDirFromFile(inputFile) -- 1094
		if dir then -- 1094
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 1095
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1096
		else -- 1098
			file = Path:getRelative(inputFile, Content.writablePath) -- 1098
			if file:sub(1, 2) == ".." then -- 1099
				file = Path:getRelative(inputFile, Content.assetPath) -- 1100
			end -- 1099
			searchPath = "" -- 1101
		end -- 1094
	end -- 1094
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1102
	local yueext = yue.options.extension -- 1103
	local resultCodes = nil -- 1104
	local resultError = nil -- 1105
	do -- 1106
		local _exp_0 = Path:getExt(inputFile) -- 1106
		if yueext == _exp_0 then -- 1106
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1107
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1108
				if not codes then -- 1109
					resultError = err -- 1110
					return -- 1111
				end -- 1109
				local extraGlobal -- 1112
				if isTIC80 then -- 1112
					extraGlobal = tic80APIs -- 1112
				else -- 1112
					extraGlobal = nil -- 1112
				end -- 1112
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1113
				if not success then -- 1114
					resultError = message -- 1115
					return -- 1116
				end -- 1114
				if codes == "" then -- 1117
					resultCodes = "" -- 1118
					return nil -- 1119
				end -- 1117
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1120
				return resultCodes -- 1121
			end, function(success) -- 1108
				if not success then -- 1122
					Content:remove(outputFile) -- 1123
					if resultCodes == nil then -- 1124
						resultCodes = false -- 1125
					end -- 1124
				end -- 1122
			end) -- 1108
		elseif "tl" == _exp_0 then -- 1126
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1127
			if isTIC80 then -- 1128
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1129
			end -- 1128
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1130
			if codes then -- 1130
				if isTIC80 then -- 1131
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1132
				end -- 1131
				resultCodes = codes -- 1133
				Content:saveAsync(outputFile, codes) -- 1134
			else -- 1136
				Content:remove(outputFile) -- 1136
				resultCodes = false -- 1137
				resultError = err -- 1138
			end -- 1130
		elseif "xml" == _exp_0 then -- 1139
			local codes, err = xml.tolua(sourceCodes) -- 1140
			if codes then -- 1140
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1141
				Content:saveAsync(outputFile, resultCodes) -- 1142
			else -- 1144
				Content:remove(outputFile) -- 1144
				resultCodes = false -- 1145
				resultError = err -- 1146
			end -- 1140
		end -- 1106
	end -- 1106
	wait(function() -- 1147
		return resultCodes ~= nil -- 1147
	end) -- 1147
	if resultCodes then -- 1148
		return resultCodes -- 1149
	else -- 1151
		return nil, resultError -- 1151
	end -- 1148
	return nil -- 1092
end -- 1092
HttpServer:postSchedule("/write", function(req) -- 1153
	do -- 1154
		local _type_0 = type(req) -- 1154
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1154
		if _tab_0 then -- 1154
			local path -- 1154
			do -- 1154
				local _obj_0 = req.body -- 1154
				local _type_1 = type(_obj_0) -- 1154
				if "table" == _type_1 or "userdata" == _type_1 then -- 1154
					path = _obj_0.path -- 1154
				end -- 1154
			end -- 1154
			local content -- 1154
			do -- 1154
				local _obj_0 = req.body -- 1154
				local _type_1 = type(_obj_0) -- 1154
				if "table" == _type_1 or "userdata" == _type_1 then -- 1154
					content = _obj_0.content -- 1154
				end -- 1154
			end -- 1154
			if path ~= nil and content ~= nil then -- 1154
				if Content:saveAsync(path, content) then -- 1155
					do -- 1156
						local _exp_0 = Path:getExt(path) -- 1156
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1156
							if '' == Path:getExt(Path:getName(path)) then -- 1157
								local resultCodes = compileFileAsync(path, content) -- 1158
								return { -- 1159
									success = true, -- 1159
									resultCodes = resultCodes -- 1159
								} -- 1159
							end -- 1157
						end -- 1156
					end -- 1156
					return { -- 1160
						success = true -- 1160
					} -- 1160
				end -- 1155
			end -- 1154
		end -- 1154
	end -- 1154
	return { -- 1153
		success = false -- 1153
	} -- 1153
end) -- 1153
HttpServer:postSchedule("/build", function(req) -- 1162
	do -- 1163
		local _type_0 = type(req) -- 1163
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1163
		if _tab_0 then -- 1163
			local path -- 1163
			do -- 1163
				local _obj_0 = req.body -- 1163
				local _type_1 = type(_obj_0) -- 1163
				if "table" == _type_1 or "userdata" == _type_1 then -- 1163
					path = _obj_0.path -- 1163
				end -- 1163
			end -- 1163
			if path ~= nil then -- 1163
				local _exp_0 = Path:getExt(path) -- 1164
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1164
					if '' == Path:getExt(Path:getName(path)) then -- 1165
						local content = Content:loadAsync(path) -- 1166
						if content then -- 1166
							local resultCodes = compileFileAsync(path, content) -- 1167
							if resultCodes then -- 1167
								return { -- 1168
									success = true, -- 1168
									resultCodes = resultCodes -- 1168
								} -- 1168
							end -- 1167
						end -- 1166
					end -- 1165
				end -- 1164
			end -- 1163
		end -- 1163
	end -- 1163
	return { -- 1162
		success = false -- 1162
	} -- 1162
end) -- 1162
local extentionLevels = { -- 1171
	vs = 2, -- 1171
	bl = 2, -- 1172
	ts = 1, -- 1173
	tsx = 1, -- 1174
	tl = 1, -- 1175
	yue = 1, -- 1176
	xml = 1, -- 1177
	lua = 0 -- 1178
} -- 1170
HttpServer:post("/assets", function() -- 1180
	local Entry = require("Script.Dev.Entry") -- 1183
	local engineDev = Entry.getEngineDev() -- 1184
	local visitAssets -- 1185
	visitAssets = function(path, tag) -- 1185
		local isWorkspace = tag == "Workspace" -- 1186
		local builtin -- 1187
		if tag == "Builtin" then -- 1187
			builtin = true -- 1187
		else -- 1187
			builtin = nil -- 1187
		end -- 1187
		local children = nil -- 1188
		local dirs = Content:getDirs(path) -- 1189
		for _index_0 = 1, #dirs do -- 1190
			local dir = dirs[_index_0] -- 1190
			if isWorkspace then -- 1191
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1192
					goto _continue_0 -- 1193
				end -- 1192
			elseif dir == ".git" then -- 1194
				goto _continue_0 -- 1195
			end -- 1191
			if not children then -- 1196
				children = { } -- 1196
			end -- 1196
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1197
			::_continue_0:: -- 1191
		end -- 1190
		local files = Content:getFiles(path) -- 1198
		local names = { } -- 1199
		for _index_0 = 1, #files do -- 1200
			local file = files[_index_0] -- 1200
			if file:match("^%.") then -- 1201
				goto _continue_1 -- 1201
			end -- 1201
			local name = Path:getName(file) -- 1202
			local ext = names[name] -- 1203
			if ext then -- 1203
				local lv1 -- 1204
				do -- 1204
					local _exp_0 = extentionLevels[ext] -- 1204
					if _exp_0 ~= nil then -- 1204
						lv1 = _exp_0 -- 1204
					else -- 1204
						lv1 = -1 -- 1204
					end -- 1204
				end -- 1204
				ext = Path:getExt(file) -- 1205
				local lv2 -- 1206
				do -- 1206
					local _exp_0 = extentionLevels[ext] -- 1206
					if _exp_0 ~= nil then -- 1206
						lv2 = _exp_0 -- 1206
					else -- 1206
						lv2 = -1 -- 1206
					end -- 1206
				end -- 1206
				if lv2 > lv1 then -- 1207
					names[name] = ext -- 1208
				elseif lv2 == lv1 then -- 1209
					names[name .. '.' .. ext] = "" -- 1210
				end -- 1207
			else -- 1212
				ext = Path:getExt(file) -- 1212
				if not extentionLevels[ext] then -- 1213
					names[file] = "" -- 1214
				else -- 1216
					names[name] = ext -- 1216
				end -- 1213
			end -- 1203
			::_continue_1:: -- 1201
		end -- 1200
		do -- 1217
			local _accum_0 = { } -- 1217
			local _len_0 = 1 -- 1217
			for name, ext in pairs(names) do -- 1217
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1217
				_len_0 = _len_0 + 1 -- 1217
			end -- 1217
			files = _accum_0 -- 1217
		end -- 1217
		for _index_0 = 1, #files do -- 1218
			local file = files[_index_0] -- 1218
			if not children then -- 1219
				children = { } -- 1219
			end -- 1219
			children[#children + 1] = { -- 1221
				key = Path(path, file), -- 1221
				dir = false, -- 1222
				title = file, -- 1223
				builtin = builtin -- 1224
			} -- 1220
		end -- 1218
		if children then -- 1226
			table.sort(children, function(a, b) -- 1227
				if a.dir == b.dir then -- 1228
					return a.title < b.title -- 1229
				else -- 1231
					return a.dir -- 1231
				end -- 1228
			end) -- 1227
		end -- 1226
		if isWorkspace and children then -- 1232
			return children -- 1233
		else -- 1235
			return { -- 1236
				key = path, -- 1236
				dir = true, -- 1237
				title = Path:getFilename(path), -- 1238
				builtin = builtin, -- 1239
				children = children -- 1240
			} -- 1235
		end -- 1232
	end -- 1185
	local zh = (App.locale:match("^zh") ~= nil) -- 1242
	return { -- 1244
		key = Content.writablePath, -- 1244
		dir = true, -- 1245
		root = true, -- 1246
		title = "Assets", -- 1247
		children = (function() -- 1249
			local _tab_0 = { -- 1249
				{ -- 1250
					key = Path(Content.assetPath), -- 1250
					dir = true, -- 1251
					builtin = true, -- 1252
					title = zh and "内置资源" or "Built-in", -- 1253
					children = { -- 1255
						(function() -- 1255
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1255
							_with_0.title = zh and "说明文档" or "Readme" -- 1256
							return _with_0 -- 1255
						end)(), -- 1255
						(function() -- 1257
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1257
							_with_0.title = zh and "接口文档" or "API Doc" -- 1258
							return _with_0 -- 1257
						end)(), -- 1257
						(function() -- 1259
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1259
							_with_0.title = zh and "开发工具" or "Tools" -- 1260
							return _with_0 -- 1259
						end)(), -- 1259
						(function() -- 1261
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1261
							_with_0.title = zh and "字体" or "Font" -- 1262
							return _with_0 -- 1261
						end)(), -- 1261
						(function() -- 1263
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1263
							_with_0.title = zh and "程序库" or "Lib" -- 1264
							if engineDev then -- 1265
								local _list_0 = _with_0.children -- 1266
								for _index_0 = 1, #_list_0 do -- 1266
									local child = _list_0[_index_0] -- 1266
									if not (child.title == "Dora") then -- 1267
										goto _continue_0 -- 1267
									end -- 1267
									local title = zh and "zh-Hans" or "en" -- 1268
									do -- 1269
										local _accum_0 = { } -- 1269
										local _len_0 = 1 -- 1269
										local _list_1 = child.children -- 1269
										for _index_1 = 1, #_list_1 do -- 1269
											local c = _list_1[_index_1] -- 1269
											if c.title ~= title then -- 1269
												_accum_0[_len_0] = c -- 1269
												_len_0 = _len_0 + 1 -- 1269
											end -- 1269
										end -- 1269
										child.children = _accum_0 -- 1269
									end -- 1269
									break -- 1270
									::_continue_0:: -- 1267
								end -- 1266
							else -- 1272
								local _accum_0 = { } -- 1272
								local _len_0 = 1 -- 1272
								local _list_0 = _with_0.children -- 1272
								for _index_0 = 1, #_list_0 do -- 1272
									local child = _list_0[_index_0] -- 1272
									if child.title ~= "Dora" then -- 1272
										_accum_0[_len_0] = child -- 1272
										_len_0 = _len_0 + 1 -- 1272
									end -- 1272
								end -- 1272
								_with_0.children = _accum_0 -- 1272
							end -- 1265
							return _with_0 -- 1263
						end)(), -- 1263
						(function() -- 1273
							if engineDev then -- 1273
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1274
								local _obj_0 = _with_0.children -- 1275
								_obj_0[#_obj_0 + 1] = { -- 1276
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1276
									dir = false, -- 1277
									builtin = true, -- 1278
									title = "init.yue" -- 1279
								} -- 1275
								return _with_0 -- 1274
							end -- 1273
						end)() -- 1273
					} -- 1254
				} -- 1249
			} -- 1283
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1283
			local _idx_0 = #_tab_0 + 1 -- 1283
			for _index_0 = 1, #_obj_0 do -- 1283
				local _value_0 = _obj_0[_index_0] -- 1283
				_tab_0[_idx_0] = _value_0 -- 1283
				_idx_0 = _idx_0 + 1 -- 1283
			end -- 1283
			return _tab_0 -- 1249
		end)() -- 1248
	} -- 1243
end) -- 1180
HttpServer:post("/entry/list", function() -- 1287
	local Entry = require("Script.Dev.Entry") -- 1288
	local res = Entry.getLaunchEntries() -- 1289
	res.success = true -- 1290
	return res -- 1291
end) -- 1287
HttpServer:postSchedule("/run", function(req) -- 1293
	do -- 1294
		local _type_0 = type(req) -- 1294
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1294
		if _tab_0 then -- 1294
			local file -- 1294
			do -- 1294
				local _obj_0 = req.body -- 1294
				local _type_1 = type(_obj_0) -- 1294
				if "table" == _type_1 or "userdata" == _type_1 then -- 1294
					file = _obj_0.file -- 1294
				end -- 1294
			end -- 1294
			local asProj -- 1294
			do -- 1294
				local _obj_0 = req.body -- 1294
				local _type_1 = type(_obj_0) -- 1294
				if "table" == _type_1 or "userdata" == _type_1 then -- 1294
					asProj = _obj_0.asProj -- 1294
				end -- 1294
			end -- 1294
			if file ~= nil and asProj ~= nil then -- 1294
				if not Content:isAbsolutePath(file) then -- 1295
					local devFile = Path(Content.writablePath, file) -- 1296
					if Content:exist(devFile) then -- 1297
						file = devFile -- 1297
					end -- 1297
				end -- 1295
				local Entry = require("Script.Dev.Entry") -- 1298
				local workDir -- 1299
				if asProj then -- 1300
					workDir = getProjectDirFromFile(file) -- 1301
					if workDir then -- 1301
						Entry.allClear() -- 1302
						local target = Path(workDir, "init") -- 1303
						local success, err = Entry.enterEntryAsync({ -- 1304
							entryName = "Project", -- 1304
							fileName = target -- 1304
						}) -- 1304
						target = Path:getName(Path:getPath(target)) -- 1305
						return { -- 1306
							success = success, -- 1306
							target = target, -- 1306
							err = err -- 1306
						} -- 1306
					end -- 1301
				else -- 1308
					workDir = getProjectDirFromFile(file) -- 1308
				end -- 1300
				Entry.allClear() -- 1309
				file = Path:replaceExt(file, "") -- 1310
				local success, err = Entry.enterEntryAsync({ -- 1312
					entryName = Path:getName(file), -- 1312
					fileName = file, -- 1313
					workDir = workDir -- 1314
				}) -- 1311
				return { -- 1315
					success = success, -- 1315
					err = err -- 1315
				} -- 1315
			end -- 1294
		end -- 1294
	end -- 1294
	return { -- 1293
		success = false -- 1293
	} -- 1293
end) -- 1293
HttpServer:postSchedule("/stop", function() -- 1317
	local Entry = require("Script.Dev.Entry") -- 1318
	return { -- 1319
		success = Entry.stop() -- 1319
	} -- 1319
end) -- 1317
local minifyAsync -- 1321
minifyAsync = function(sourcePath, minifyPath) -- 1321
	if not Content:exist(sourcePath) then -- 1322
		return -- 1322
	end -- 1322
	local Entry = require("Script.Dev.Entry") -- 1323
	local errors = { } -- 1324
	local files = Entry.getAllFiles(sourcePath, { -- 1325
		"lua" -- 1325
	}, true) -- 1325
	do -- 1326
		local _accum_0 = { } -- 1326
		local _len_0 = 1 -- 1326
		for _index_0 = 1, #files do -- 1326
			local file = files[_index_0] -- 1326
			if file:sub(1, 1) ~= '.' then -- 1326
				_accum_0[_len_0] = file -- 1326
				_len_0 = _len_0 + 1 -- 1326
			end -- 1326
		end -- 1326
		files = _accum_0 -- 1326
	end -- 1326
	local paths -- 1327
	do -- 1327
		local _tbl_0 = { } -- 1327
		for _index_0 = 1, #files do -- 1327
			local file = files[_index_0] -- 1327
			_tbl_0[Path:getPath(file)] = true -- 1327
		end -- 1327
		paths = _tbl_0 -- 1327
	end -- 1327
	for path in pairs(paths) do -- 1328
		Content:mkdir(Path(minifyPath, path)) -- 1328
	end -- 1328
	local _ <close> = setmetatable({ }, { -- 1329
		__close = function() -- 1329
			package.loaded["luaminify.FormatMini"] = nil -- 1330
			package.loaded["luaminify.ParseLua"] = nil -- 1331
			package.loaded["luaminify.Scope"] = nil -- 1332
			package.loaded["luaminify.Util"] = nil -- 1333
		end -- 1329
	}) -- 1329
	local FormatMini -- 1334
	do -- 1334
		local _obj_0 = require("luaminify") -- 1334
		FormatMini = _obj_0.FormatMini -- 1334
	end -- 1334
	local fileCount = #files -- 1335
	local count = 0 -- 1336
	for _index_0 = 1, #files do -- 1337
		local file = files[_index_0] -- 1337
		thread(function() -- 1338
			local _ <close> = setmetatable({ }, { -- 1339
				__close = function() -- 1339
					count = count + 1 -- 1339
				end -- 1339
			}) -- 1339
			local input = Path(sourcePath, file) -- 1340
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1341
			if Content:exist(input) then -- 1342
				local sourceCodes = Content:loadAsync(input) -- 1343
				local res, err = FormatMini(sourceCodes) -- 1344
				if res then -- 1345
					Content:saveAsync(output, res) -- 1346
					return print("Minify " .. tostring(file)) -- 1347
				else -- 1349
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1349
				end -- 1345
			else -- 1351
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1351
			end -- 1342
		end) -- 1338
		sleep() -- 1352
	end -- 1337
	wait(function() -- 1353
		return count == fileCount -- 1353
	end) -- 1353
	if #errors > 0 then -- 1354
		print(table.concat(errors, '\n')) -- 1355
	end -- 1354
	print("Obfuscation done.") -- 1356
	return files -- 1357
end -- 1321
local zipping = false -- 1359
HttpServer:postSchedule("/zip", function(req) -- 1361
	do -- 1362
		local _type_0 = type(req) -- 1362
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1362
		if _tab_0 then -- 1362
			local path -- 1362
			do -- 1362
				local _obj_0 = req.body -- 1362
				local _type_1 = type(_obj_0) -- 1362
				if "table" == _type_1 or "userdata" == _type_1 then -- 1362
					path = _obj_0.path -- 1362
				end -- 1362
			end -- 1362
			local zipFile -- 1362
			do -- 1362
				local _obj_0 = req.body -- 1362
				local _type_1 = type(_obj_0) -- 1362
				if "table" == _type_1 or "userdata" == _type_1 then -- 1362
					zipFile = _obj_0.zipFile -- 1362
				end -- 1362
			end -- 1362
			local obfuscated -- 1362
			do -- 1362
				local _obj_0 = req.body -- 1362
				local _type_1 = type(_obj_0) -- 1362
				if "table" == _type_1 or "userdata" == _type_1 then -- 1362
					obfuscated = _obj_0.obfuscated -- 1362
				end -- 1362
			end -- 1362
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1362
				if zipping then -- 1363
					goto failed -- 1363
				end -- 1363
				zipping = true -- 1364
				local _ <close> = setmetatable({ }, { -- 1365
					__close = function() -- 1365
						zipping = false -- 1365
					end -- 1365
				}) -- 1365
				if not Content:exist(path) then -- 1366
					goto failed -- 1366
				end -- 1366
				Content:mkdir(Path:getPath(zipFile)) -- 1367
				if obfuscated then -- 1368
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1369
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1370
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1371
					Content:remove(scriptPath) -- 1372
					Content:remove(obfuscatedPath) -- 1373
					Content:remove(tempPath) -- 1374
					Content:mkdir(scriptPath) -- 1375
					Content:mkdir(obfuscatedPath) -- 1376
					Content:mkdir(tempPath) -- 1377
					if not Content:copyAsync(path, tempPath) then -- 1378
						goto failed -- 1378
					end -- 1378
					local Entry = require("Script.Dev.Entry") -- 1379
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1380
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1381
						"tl", -- 1381
						"yue", -- 1381
						"lua", -- 1381
						"ts", -- 1381
						"tsx", -- 1381
						"vs", -- 1381
						"bl", -- 1381
						"xml", -- 1381
						"wa", -- 1381
						"mod" -- 1381
					}, true) -- 1381
					for _index_0 = 1, #scriptFiles do -- 1382
						local file = scriptFiles[_index_0] -- 1382
						Content:remove(Path(tempPath, file)) -- 1383
					end -- 1382
					for _index_0 = 1, #luaFiles do -- 1384
						local file = luaFiles[_index_0] -- 1384
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1385
					end -- 1384
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1386
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1387
					end) then -- 1386
						goto failed -- 1386
					end -- 1386
					return { -- 1388
						success = true -- 1388
					} -- 1388
				else -- 1390
					return { -- 1390
						success = Content:zipAsync(path, zipFile, function(file) -- 1390
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1391
						end) -- 1390
					} -- 1390
				end -- 1368
			end -- 1362
		end -- 1362
	end -- 1362
	::failed:: -- 1392
	return { -- 1361
		success = false -- 1361
	} -- 1361
end) -- 1361
HttpServer:postSchedule("/unzip", function(req) -- 1394
	do -- 1395
		local _type_0 = type(req) -- 1395
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1395
		if _tab_0 then -- 1395
			local zipFile -- 1395
			do -- 1395
				local _obj_0 = req.body -- 1395
				local _type_1 = type(_obj_0) -- 1395
				if "table" == _type_1 or "userdata" == _type_1 then -- 1395
					zipFile = _obj_0.zipFile -- 1395
				end -- 1395
			end -- 1395
			local path -- 1395
			do -- 1395
				local _obj_0 = req.body -- 1395
				local _type_1 = type(_obj_0) -- 1395
				if "table" == _type_1 or "userdata" == _type_1 then -- 1395
					path = _obj_0.path -- 1395
				end -- 1395
			end -- 1395
			if zipFile ~= nil and path ~= nil then -- 1395
				return { -- 1396
					success = Content:unzipAsync(zipFile, path, function(file) -- 1396
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1397
					end) -- 1396
				} -- 1396
			end -- 1395
		end -- 1395
	end -- 1395
	return { -- 1394
		success = false -- 1394
	} -- 1394
end) -- 1394
HttpServer:post("/editing-info", function(req) -- 1399
	local Entry = require("Script.Dev.Entry") -- 1400
	local config = Entry.getConfig() -- 1401
	local _type_0 = type(req) -- 1402
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1402
	local _match_0 = false -- 1402
	if _tab_0 then -- 1402
		local editingInfo -- 1402
		do -- 1402
			local _obj_0 = req.body -- 1402
			local _type_1 = type(_obj_0) -- 1402
			if "table" == _type_1 or "userdata" == _type_1 then -- 1402
				editingInfo = _obj_0.editingInfo -- 1402
			end -- 1402
		end -- 1402
		if editingInfo ~= nil then -- 1402
			_match_0 = true -- 1402
			config.editingInfo = editingInfo -- 1403
			return { -- 1404
				success = true -- 1404
			} -- 1404
		end -- 1402
	end -- 1402
	if not _match_0 then -- 1402
		if not (config.editingInfo ~= nil) then -- 1406
			local folder -- 1407
			if App.locale:match('^zh') then -- 1407
				folder = 'zh-Hans' -- 1407
			else -- 1407
				folder = 'en' -- 1407
			end -- 1407
			config.editingInfo = json.encode({ -- 1409
				index = 0, -- 1409
				files = { -- 1411
					{ -- 1412
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1412
						title = "welcome.md" -- 1413
					} -- 1411
				} -- 1410
			}) -- 1408
		end -- 1406
		return { -- 1417
			success = true, -- 1417
			editingInfo = config.editingInfo -- 1417
		} -- 1417
	end -- 1402
end) -- 1399
HttpServer:post("/command", function(req) -- 1419
	do -- 1420
		local _type_0 = type(req) -- 1420
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1420
		if _tab_0 then -- 1420
			local code -- 1420
			do -- 1420
				local _obj_0 = req.body -- 1420
				local _type_1 = type(_obj_0) -- 1420
				if "table" == _type_1 or "userdata" == _type_1 then -- 1420
					code = _obj_0.code -- 1420
				end -- 1420
			end -- 1420
			local log -- 1420
			do -- 1420
				local _obj_0 = req.body -- 1420
				local _type_1 = type(_obj_0) -- 1420
				if "table" == _type_1 or "userdata" == _type_1 then -- 1420
					log = _obj_0.log -- 1420
				end -- 1420
			end -- 1420
			if code ~= nil and log ~= nil then -- 1420
				emit("AppCommand", code, log) -- 1421
				return { -- 1422
					success = true -- 1422
				} -- 1422
			end -- 1420
		end -- 1420
	end -- 1420
	return { -- 1419
		success = false -- 1419
	} -- 1419
end) -- 1419
HttpServer:post("/log/save", function() -- 1424
	local folder = ".download" -- 1425
	local fullLogFile = "dora_full_logs.txt" -- 1426
	local fullFolder = Path(Content.writablePath, folder) -- 1427
	Content:mkdir(fullFolder) -- 1428
	local logPath = Path(fullFolder, fullLogFile) -- 1429
	if App:saveLog(logPath) then -- 1430
		return { -- 1431
			success = true, -- 1431
			path = Path(folder, fullLogFile) -- 1431
		} -- 1431
	end -- 1430
	return { -- 1424
		success = false -- 1424
	} -- 1424
end) -- 1424
HttpServer:post("/yarn/check", function(req) -- 1433
	local yarncompile = require("yarncompile") -- 1434
	do -- 1435
		local _type_0 = type(req) -- 1435
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1435
		if _tab_0 then -- 1435
			local code -- 1435
			do -- 1435
				local _obj_0 = req.body -- 1435
				local _type_1 = type(_obj_0) -- 1435
				if "table" == _type_1 or "userdata" == _type_1 then -- 1435
					code = _obj_0.code -- 1435
				end -- 1435
			end -- 1435
			if code ~= nil then -- 1435
				local jsonObject = json.decode(code) -- 1436
				if jsonObject then -- 1436
					local errors = { } -- 1437
					local _list_0 = jsonObject.nodes -- 1438
					for _index_0 = 1, #_list_0 do -- 1438
						local node = _list_0[_index_0] -- 1438
						local title, body = node.title, node.body -- 1439
						local luaCode, err = yarncompile(body) -- 1440
						if not luaCode then -- 1440
							errors[#errors + 1] = title .. ":" .. err -- 1441
						end -- 1440
					end -- 1438
					return { -- 1442
						success = true, -- 1442
						syntaxError = table.concat(errors, "\n\n") -- 1442
					} -- 1442
				end -- 1436
			end -- 1435
		end -- 1435
	end -- 1435
	return { -- 1433
		success = false -- 1433
	} -- 1433
end) -- 1433
HttpServer:post("/yarn/check-file", function(req) -- 1444
	local yarncompile = require("yarncompile") -- 1445
	do -- 1446
		local _type_0 = type(req) -- 1446
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1446
		if _tab_0 then -- 1446
			local code -- 1446
			do -- 1446
				local _obj_0 = req.body -- 1446
				local _type_1 = type(_obj_0) -- 1446
				if "table" == _type_1 or "userdata" == _type_1 then -- 1446
					code = _obj_0.code -- 1446
				end -- 1446
			end -- 1446
			if code ~= nil then -- 1446
				local res, _, err = yarncompile(code, true) -- 1447
				if not res then -- 1447
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1448
					return { -- 1449
						success = false, -- 1449
						message = message, -- 1449
						line = line, -- 1449
						column = column, -- 1449
						node = node -- 1449
					} -- 1449
				end -- 1447
			end -- 1446
		end -- 1446
	end -- 1446
	return { -- 1444
		success = true -- 1444
	} -- 1444
end) -- 1444
local getWaProjectDirFromFile -- 1451
getWaProjectDirFromFile = function(file) -- 1451
	local writablePath = Content.writablePath -- 1452
	local parent, current -- 1453
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1453
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1454
	else -- 1456
		parent, current = nil, nil -- 1456
	end -- 1453
	if not current then -- 1457
		return nil -- 1457
	end -- 1457
	repeat -- 1458
		current = Path:getPath(current) -- 1459
		if current == "" then -- 1460
			break -- 1460
		end -- 1460
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1461
		for _index_0 = 1, #_list_0 do -- 1461
			local f = _list_0[_index_0] -- 1461
			if Path:getFilename(f):lower() == "wa.mod" then -- 1462
				return Path(parent, current, Path:getPath(f)) -- 1463
			end -- 1462
		end -- 1461
	until false -- 1458
	return nil -- 1465
end -- 1451
HttpServer:postSchedule("/wa/update_dora", function(req) -- 1467
	do -- 1468
		local _type_0 = type(req) -- 1468
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1468
		if _tab_0 then -- 1468
			local path -- 1468
			do -- 1468
				local _obj_0 = req.body -- 1468
				local _type_1 = type(_obj_0) -- 1468
				if "table" == _type_1 or "userdata" == _type_1 then -- 1468
					path = _obj_0.path -- 1468
				end -- 1468
			end -- 1468
			if path ~= nil then -- 1468
				local projDir = getWaProjectDirFromFile(path) -- 1469
				if projDir then -- 1469
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 1470
					if not Content:exist(sourceDoraPath) then -- 1471
						return { -- 1472
							success = false, -- 1472
							message = "missing dora template" -- 1472
						} -- 1472
					end -- 1471
					local targetVendorPath = Path(projDir, "vendor") -- 1473
					local targetDoraPath = Path(targetVendorPath, "dora") -- 1474
					if not Content:exist(targetVendorPath) then -- 1475
						if not Content:mkdir(targetVendorPath) then -- 1476
							return { -- 1477
								success = false, -- 1477
								message = "failed to create vendor folder" -- 1477
							} -- 1477
						end -- 1476
					elseif not Content:isdir(targetVendorPath) then -- 1478
						return { -- 1479
							success = false, -- 1479
							message = "vendor path is not a folder" -- 1479
						} -- 1479
					end -- 1475
					if Content:exist(targetDoraPath) then -- 1480
						if not Content:remove(targetDoraPath) then -- 1481
							return { -- 1482
								success = false, -- 1482
								message = "failed to remove old dora" -- 1482
							} -- 1482
						end -- 1481
					end -- 1480
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 1483
						return { -- 1484
							success = false, -- 1484
							message = "failed to copy dora" -- 1484
						} -- 1484
					end -- 1483
					return { -- 1485
						success = true -- 1485
					} -- 1485
				else -- 1487
					return { -- 1487
						success = false, -- 1487
						message = 'Wa file needs a project' -- 1487
					} -- 1487
				end -- 1469
			end -- 1468
		end -- 1468
	end -- 1468
	return { -- 1467
		success = false, -- 1467
		message = "invalid call" -- 1467
	} -- 1467
end) -- 1467
HttpServer:postSchedule("/wa/build", function(req) -- 1489
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
				local projDir = getWaProjectDirFromFile(path) -- 1491
				if projDir then -- 1491
					local message = Wasm:buildWaAsync(projDir) -- 1492
					if message == "" then -- 1493
						return { -- 1494
							success = true -- 1494
						} -- 1494
					else -- 1496
						return { -- 1496
							success = false, -- 1496
							message = message -- 1496
						} -- 1496
					end -- 1493
				else -- 1498
					return { -- 1498
						success = false, -- 1498
						message = 'Wa file needs a project' -- 1498
					} -- 1498
				end -- 1491
			end -- 1490
		end -- 1490
	end -- 1490
	return { -- 1499
		success = false, -- 1499
		message = 'failed to build' -- 1499
	} -- 1499
end) -- 1489
HttpServer:postSchedule("/wa/format", function(req) -- 1501
	do -- 1502
		local _type_0 = type(req) -- 1502
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1502
		if _tab_0 then -- 1502
			local file -- 1502
			do -- 1502
				local _obj_0 = req.body -- 1502
				local _type_1 = type(_obj_0) -- 1502
				if "table" == _type_1 or "userdata" == _type_1 then -- 1502
					file = _obj_0.file -- 1502
				end -- 1502
			end -- 1502
			if file ~= nil then -- 1502
				local code = Wasm:formatWaAsync(file) -- 1503
				if code == "" then -- 1504
					return { -- 1505
						success = false -- 1505
					} -- 1505
				else -- 1507
					return { -- 1507
						success = true, -- 1507
						code = code -- 1507
					} -- 1507
				end -- 1504
			end -- 1502
		end -- 1502
	end -- 1502
	return { -- 1508
		success = false -- 1508
	} -- 1508
end) -- 1501
HttpServer:postSchedule("/wa/create", function(req) -- 1510
	do -- 1511
		local _type_0 = type(req) -- 1511
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1511
		if _tab_0 then -- 1511
			local path -- 1511
			do -- 1511
				local _obj_0 = req.body -- 1511
				local _type_1 = type(_obj_0) -- 1511
				if "table" == _type_1 or "userdata" == _type_1 then -- 1511
					path = _obj_0.path -- 1511
				end -- 1511
			end -- 1511
			if path ~= nil then -- 1511
				if not Content:exist(Path:getPath(path)) then -- 1512
					return { -- 1513
						success = false, -- 1513
						message = "target path not existed" -- 1513
					} -- 1513
				end -- 1512
				if Content:exist(path) then -- 1514
					return { -- 1515
						success = false, -- 1515
						message = "target project folder existed" -- 1515
					} -- 1515
				end -- 1514
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1516
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1517
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1518
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1519
					return { -- 1522
						success = false, -- 1522
						message = "missing template project" -- 1522
					} -- 1522
				end -- 1519
				if not Content:mkdir(path) then -- 1523
					return { -- 1524
						success = false, -- 1524
						message = "failed to create project folder" -- 1524
					} -- 1524
				end -- 1523
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1525
					Content:remove(path) -- 1526
					return { -- 1527
						success = false, -- 1527
						message = "failed to copy template" -- 1527
					} -- 1527
				end -- 1525
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1528
					Content:remove(path) -- 1529
					return { -- 1530
						success = false, -- 1530
						message = "failed to copy template" -- 1530
					} -- 1530
				end -- 1528
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1531
					Content:remove(path) -- 1532
					return { -- 1533
						success = false, -- 1533
						message = "failed to copy template" -- 1533
					} -- 1533
				end -- 1531
				return { -- 1534
					success = true -- 1534
				} -- 1534
			end -- 1511
		end -- 1511
	end -- 1511
	return { -- 1510
		success = false, -- 1510
		message = "invalid call" -- 1510
	} -- 1510
end) -- 1510
local tsBuildGlobs = { -- 1537
	"**/*.ts", -- 1537
	"**/*.tsx", -- 1538
	"!**/.*/**", -- 1539
	"!**/node_modules/**" -- 1540
} -- 1536
local _anon_func_5 = function(path) -- 1549
	local _val_0 = Path:getExt(path) -- 1549
	return "ts" == _val_0 or "tsx" == _val_0 -- 1549
end -- 1549
HttpServer:postSchedule("/ts/build", function(req) -- 1542
	do -- 1543
		local _type_0 = type(req) -- 1543
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1543
		if _tab_0 then -- 1543
			local path -- 1543
			do -- 1543
				local _obj_0 = req.body -- 1543
				local _type_1 = type(_obj_0) -- 1543
				if "table" == _type_1 or "userdata" == _type_1 then -- 1543
					path = _obj_0.path -- 1543
				end -- 1543
			end -- 1543
			if path ~= nil then -- 1543
				if HttpServer.wsConnectionCount == 0 then -- 1544
					return { -- 1545
						success = false, -- 1545
						message = "Web IDE not connected" -- 1545
					} -- 1545
				end -- 1544
				if not Content:exist(path) then -- 1546
					return { -- 1547
						success = false, -- 1547
						message = "path not existed" -- 1547
					} -- 1547
				end -- 1546
				if not Content:isdir(path) then -- 1548
					if not (_anon_func_5(path)) then -- 1549
						return { -- 1550
							success = false, -- 1550
							message = "expecting a TypeScript file" -- 1550
						} -- 1550
					end -- 1549
					local messages = { } -- 1551
					local content = Content:load(path) -- 1552
					if not content then -- 1553
						return { -- 1554
							success = false, -- 1554
							message = "failed to read file" -- 1554
						} -- 1554
					end -- 1553
					emit("AppWS", "Send", json.encode({ -- 1555
						name = "UpdateFile", -- 1555
						file = path, -- 1555
						exists = true, -- 1555
						content = content -- 1555
					})) -- 1555
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1556
						local done = false -- 1557
						do -- 1558
							local _with_0 = Node() -- 1558
							_with_0:gslot("AppWS", function(event) -- 1559
								if event.type == "Receive" then -- 1560
									local res = json.decode(event.msg) -- 1561
									if res then -- 1561
										if res.name == "TranspileTS" and res.file == path then -- 1562
											_with_0:removeFromParent() -- 1563
											if res.success then -- 1564
												local luaFile = Path:replaceExt(path, "lua") -- 1565
												Content:save(luaFile, res.luaCode) -- 1566
												messages[#messages + 1] = { -- 1567
													success = true, -- 1567
													file = path -- 1567
												} -- 1567
											else -- 1569
												messages[#messages + 1] = { -- 1569
													success = false, -- 1569
													file = path, -- 1569
													message = res.message -- 1569
												} -- 1569
											end -- 1564
											done = true -- 1570
										end -- 1562
									end -- 1561
								end -- 1560
							end) -- 1559
						end -- 1558
						emit("AppWS", "Send", json.encode({ -- 1571
							name = "TranspileTS", -- 1571
							file = path, -- 1571
							content = content -- 1571
						})) -- 1571
						wait(function() -- 1572
							return done -- 1572
						end) -- 1572
					end -- 1556
					return { -- 1573
						success = true, -- 1573
						messages = messages -- 1573
					} -- 1573
				else -- 1575
					local fileData = { } -- 1575
					local messages = { } -- 1576
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 1577
					for _index_0 = 1, #_list_0 do -- 1577
						local subFile = _list_0[_index_0] -- 1577
						local file = Path(path, subFile) -- 1578
						local content = Content:load(file) -- 1579
						if content then -- 1579
							fileData[file] = content -- 1580
							emit("AppWS", "Send", json.encode({ -- 1581
								name = "UpdateFile", -- 1581
								file = file, -- 1581
								exists = true, -- 1581
								content = content -- 1581
							})) -- 1581
						else -- 1583
							messages[#messages + 1] = { -- 1583
								success = false, -- 1583
								file = file, -- 1583
								message = "failed to read file" -- 1583
							} -- 1583
						end -- 1579
					end -- 1577
					for file, content in pairs(fileData) do -- 1584
						if "d" == Path:getExt(Path:getName(file)) then -- 1585
							goto _continue_0 -- 1585
						end -- 1585
						local done = false -- 1586
						do -- 1587
							local _with_0 = Node() -- 1587
							_with_0:gslot("AppWS", function(event) -- 1588
								if event.type == "Receive" then -- 1589
									local res = json.decode(event.msg) -- 1590
									if res then -- 1590
										if res.name == "TranspileTS" and res.file == file then -- 1591
											_with_0:removeFromParent() -- 1592
											if res.success then -- 1593
												local luaFile = Path:replaceExt(file, "lua") -- 1594
												Content:save(luaFile, res.luaCode) -- 1595
												messages[#messages + 1] = { -- 1596
													success = true, -- 1596
													file = file -- 1596
												} -- 1596
											else -- 1598
												messages[#messages + 1] = { -- 1598
													success = false, -- 1598
													file = file, -- 1598
													message = res.message -- 1598
												} -- 1598
											end -- 1593
											done = true -- 1599
										end -- 1591
									end -- 1590
								end -- 1589
							end) -- 1588
						end -- 1587
						emit("AppWS", "Send", json.encode({ -- 1600
							name = "TranspileTS", -- 1600
							file = file, -- 1600
							content = content -- 1600
						})) -- 1600
						wait(function() -- 1601
							return done -- 1601
						end) -- 1601
						::_continue_0:: -- 1585
					end -- 1584
					return { -- 1602
						success = true, -- 1602
						messages = messages -- 1602
					} -- 1602
				end -- 1548
			end -- 1543
		end -- 1543
	end -- 1543
	return { -- 1542
		success = false -- 1542
	} -- 1542
end) -- 1542
HttpServer:post("/download", function(req) -- 1604
	do -- 1605
		local _type_0 = type(req) -- 1605
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1605
		if _tab_0 then -- 1605
			local url -- 1605
			do -- 1605
				local _obj_0 = req.body -- 1605
				local _type_1 = type(_obj_0) -- 1605
				if "table" == _type_1 or "userdata" == _type_1 then -- 1605
					url = _obj_0.url -- 1605
				end -- 1605
			end -- 1605
			local target -- 1605
			do -- 1605
				local _obj_0 = req.body -- 1605
				local _type_1 = type(_obj_0) -- 1605
				if "table" == _type_1 or "userdata" == _type_1 then -- 1605
					target = _obj_0.target -- 1605
				end -- 1605
			end -- 1605
			if url ~= nil and target ~= nil then -- 1605
				local Entry = require("Script.Dev.Entry") -- 1606
				Entry.downloadFile(url, target) -- 1607
				return { -- 1608
					success = true -- 1608
				} -- 1608
			end -- 1605
		end -- 1605
	end -- 1605
	return { -- 1604
		success = false -- 1604
	} -- 1604
end) -- 1604
local status = { } -- 1610
_module_0 = status -- 1611
status.buildAsync = function(path) -- 1613
	if not Content:exist(path) then -- 1614
		return { -- 1615
			success = false, -- 1615
			file = path, -- 1615
			message = "file not existed" -- 1615
		} -- 1615
	end -- 1614
	do -- 1616
		local _exp_0 = Path:getExt(path) -- 1616
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1616
			if '' == Path:getExt(Path:getName(path)) then -- 1617
				local content = Content:loadAsync(path) -- 1618
				if content then -- 1618
					local resultCodes, err = compileFileAsync(path, content) -- 1619
					if resultCodes then -- 1619
						return { -- 1620
							success = true, -- 1620
							file = path -- 1620
						} -- 1620
					else -- 1622
						return { -- 1622
							success = false, -- 1622
							file = path, -- 1622
							message = err -- 1622
						} -- 1622
					end -- 1619
				end -- 1618
			end -- 1617
		elseif "lua" == _exp_0 then -- 1623
			local content = Content:loadAsync(path) -- 1624
			if content then -- 1624
				do -- 1625
					local isTIC80 = CheckTIC80Code(content) -- 1625
					if isTIC80 then -- 1625
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1626
					end -- 1625
				end -- 1625
				local success, info -- 1627
				do -- 1627
					local _obj_0 = luaCheck(path, content) -- 1627
					success, info = _obj_0.success, _obj_0.info -- 1627
				end -- 1627
				if success then -- 1628
					return { -- 1629
						success = true, -- 1629
						file = path -- 1629
					} -- 1629
				elseif info and #info > 0 then -- 1630
					local messages = { } -- 1631
					for _index_0 = 1, #info do -- 1632
						local _des_0 = info[_index_0] -- 1632
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 1632
						local lineText = "" -- 1633
						if line then -- 1634
							local currentLine = 1 -- 1635
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1636
								if currentLine == line then -- 1637
									lineText = text -- 1638
									break -- 1639
								end -- 1637
								currentLine = currentLine + 1 -- 1640
							end -- 1636
						end -- 1634
						if line then -- 1641
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1642
						else -- 1644
							messages[#messages + 1] = message -- 1644
						end -- 1641
					end -- 1632
					return { -- 1645
						success = false, -- 1645
						file = path, -- 1645
						message = table.concat(messages, "\n") -- 1645
					} -- 1645
				else -- 1647
					return { -- 1647
						success = false, -- 1647
						file = path, -- 1647
						message = "lua check failed" -- 1647
					} -- 1647
				end -- 1628
			end -- 1624
		elseif "yarn" == _exp_0 then -- 1648
			local content = Content:loadAsync(path) -- 1649
			if content then -- 1649
				local res, _, err = yarncompile(content, true) -- 1650
				if res then -- 1650
					return { -- 1651
						success = true, -- 1651
						file = path -- 1651
					} -- 1651
				else -- 1653
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1653
					local lineText = "" -- 1654
					if line then -- 1655
						local currentLine = 1 -- 1656
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1657
							if currentLine == line then -- 1658
								lineText = text -- 1659
								break -- 1660
							end -- 1658
							currentLine = currentLine + 1 -- 1661
						end -- 1657
					end -- 1655
					if node ~= "" then -- 1662
						node = "node: " .. tostring(node) .. ", " -- 1663
					else -- 1664
						node = "" -- 1664
					end -- 1662
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1665
					return { -- 1666
						success = false, -- 1666
						file = path, -- 1666
						message = message -- 1666
					} -- 1666
				end -- 1650
			end -- 1649
		end -- 1616
	end -- 1616
	return { -- 1667
		success = false, -- 1667
		file = path, -- 1667
		message = "invalid file to build" -- 1667
	} -- 1667
end -- 1613
thread(function() -- 1669
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1670
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1671
	if Content:exist(doraWeb) then -- 1672
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 1673
		local needReload -- 1674
		if Content:exist(doraReady) then -- 1674
			needReload = readyContent ~= Content:load(doraReady) -- 1675
		else -- 1676
			needReload = true -- 1676
		end -- 1674
		if needReload then -- 1677
			Content:remove(Path(Content.appPath, ".www")) -- 1678
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1679
			Content:save(doraReady, readyContent) -- 1683
			print("Dora Dora is ready!") -- 1684
		end -- 1677
	end -- 1672
	if HttpServer:start(8866) then -- 1685
		local localIP = HttpServer.localIP -- 1686
		if localIP == "" then -- 1687
			localIP = "localhost" -- 1687
		end -- 1687
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1688
		return HttpServer:startWS(8868) -- 1689
	else -- 1691
		status.url = nil -- 1691
		return print("8866 Port not available!") -- 1692
	end -- 1685
end) -- 1669
return _module_0 -- 1
