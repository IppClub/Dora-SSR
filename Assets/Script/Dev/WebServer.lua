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
			supports_function_calling = true, -- 776
			active = true, -- 777
			created_at = true, -- 778
			updated_at = true -- 779
		} -- 766
		local existing = { } -- 781
		local valid = true -- 782
		for _index_0 = 1, #columns do -- 783
			local row = columns[_index_0] -- 783
			local columnName = tostring(row[2]) -- 784
			existing[columnName] = true -- 785
			if not expected[columnName] then -- 786
				valid = false -- 787
				break -- 788
			end -- 786
		end -- 783
		if valid then -- 789
			if not existing.context_window then -- 790
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 791
			end -- 790
			if not existing.temperature then -- 792
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 793
			end -- 792
			if not existing.max_tokens then -- 794
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 795
			end -- 794
			if not existing.reasoning_effort then -- 796
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 797
			end -- 796
			if not existing.supports_function_calling then -- 798
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 799
			end -- 798
		else -- 801
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 801
		end -- 789
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
			supports_function_calling INTEGER NOT NULL DEFAULT 1,
			active INTEGER NOT NULL DEFAULT 1,
			created_at INTEGER,
			updated_at INTEGER
		);
	]]) -- 802
end -- 763
local normalizeContextWindow -- 820
normalizeContextWindow = function(value) -- 820
	local contextWindow = tonumber(value) -- 821
	if contextWindow == nil or contextWindow < 64000 then -- 822
		return 64000 -- 823
	end -- 822
	return math.max(64000, math.floor(contextWindow)) -- 824
end -- 820
local normalizeTemperature -- 826
normalizeTemperature = function(value) -- 826
	local temperature = tonumber(value) -- 827
	if temperature == nil then -- 828
		return 0.1 -- 829
	end -- 828
	return math.max(0, math.min(2, temperature)) -- 830
end -- 826
local normalizeMaxTokens -- 832
normalizeMaxTokens = function(value) -- 832
	local maxTokens = tonumber(value) -- 833
	if maxTokens == nil or maxTokens < 1 then -- 834
		return 8192 -- 835
	end -- 834
	return math.max(1, math.floor(maxTokens)) -- 836
end -- 832
local normalizeReasoningEffort -- 838
normalizeReasoningEffort = function(value) -- 838
	if value == nil then -- 839
		return "" -- 840
	end -- 839
	local effort = tostring(value) -- 841
	return effort:match("^%s*(.-)%s*$") or "" -- 842
end -- 838
HttpServer:post("/llm/list", function() -- 844
	ensureLLMConfigTable() -- 845
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 846
	local items -- 850
	if rows and #rows > 0 then -- 850
		local _accum_0 = { } -- 851
		local _len_0 = 1 -- 851
		for _index_0 = 1, #rows do -- 851
			local _des_0 = rows[_index_0] -- 851
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 851
			_accum_0[_len_0] = { -- 852
				id = id, -- 852
				name = name, -- 852
				url = url, -- 852
				model = model, -- 852
				key = key, -- 852
				contextWindow = normalizeContextWindow(contextWindow), -- 852
				temperature = normalizeTemperature(temperature), -- 852
				maxTokens = normalizeMaxTokens(maxTokens), -- 852
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 852
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 852
				active = active ~= 0 -- 852
			} -- 852
			_len_0 = _len_0 + 1 -- 852
		end -- 851
		items = _accum_0 -- 850
	end -- 850
	return { -- 853
		success = true, -- 853
		items = items -- 853
	} -- 853
end) -- 844
HttpServer:post("/llm/create", function(req) -- 855
	ensureLLMConfigTable() -- 856
	do -- 857
		local _type_0 = type(req) -- 857
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 857
		if _tab_0 then -- 857
			local body = req.body -- 857
			if body ~= nil then -- 857
				local name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.supportsFunctionCalling -- 858
				local now = os.time() -- 859
				if name == nil or url == nil or model == nil or key == nil then -- 860
					return { -- 861
						success = false, -- 861
						message = "invalid" -- 861
					} -- 861
				end -- 860
				contextWindow = normalizeContextWindow(contextWindow) -- 862
				temperature = normalizeTemperature(temperature) -- 863
				maxTokens = normalizeMaxTokens(maxTokens) -- 864
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 865
				if supportsFunctionCalling == false then -- 866
					supportsFunctionCalling = 0 -- 866
				else -- 866
					supportsFunctionCalling = 1 -- 866
				end -- 866
				if active then -- 867
					active = 1 -- 867
				else -- 867
					active = 0 -- 867
				end -- 867
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 874
					tostring(name), -- 874
					tostring(url), -- 875
					tostring(model), -- 876
					tostring(key), -- 877
					contextWindow, -- 878
					temperature, -- 879
					maxTokens, -- 880
					reasoningEffort, -- 881
					supportsFunctionCalling, -- 882
					active, -- 883
					now, -- 884
					now -- 885
				}) -- 868
				return { -- 887
					success = affected >= 0 -- 887
				} -- 887
			end -- 857
		end -- 857
	end -- 857
	return { -- 855
		success = false, -- 855
		message = "invalid" -- 855
	} -- 855
end) -- 855
HttpServer:post("/llm/update", function(req) -- 889
	ensureLLMConfigTable() -- 890
	do -- 891
		local _type_0 = type(req) -- 891
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 891
		if _tab_0 then -- 891
			local body = req.body -- 891
			if body ~= nil then -- 891
				local id, name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.supportsFunctionCalling -- 892
				local now = os.time() -- 893
				id = tonumber(id) -- 894
				if id == nil then -- 895
					return { -- 896
						success = false, -- 896
						message = "invalid" -- 896
					} -- 896
				end -- 895
				contextWindow = normalizeContextWindow(contextWindow) -- 897
				temperature = normalizeTemperature(temperature) -- 898
				maxTokens = normalizeMaxTokens(maxTokens) -- 899
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 900
				if supportsFunctionCalling == false then -- 901
					supportsFunctionCalling = 0 -- 901
				else -- 901
					supportsFunctionCalling = 1 -- 901
				end -- 901
				if active then -- 902
					active = 1 -- 902
				else -- 902
					active = 0 -- 902
				end -- 902
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 907
					tostring(name), -- 907
					tostring(url), -- 908
					tostring(model), -- 909
					tostring(key), -- 910
					contextWindow, -- 911
					temperature, -- 912
					maxTokens, -- 913
					reasoningEffort, -- 914
					supportsFunctionCalling, -- 915
					active, -- 916
					now, -- 917
					id -- 918
				}) -- 903
				return { -- 920
					success = affected >= 0 -- 920
				} -- 920
			end -- 891
		end -- 891
	end -- 891
	return { -- 889
		success = false, -- 889
		message = "invalid" -- 889
	} -- 889
end) -- 889
HttpServer:post("/llm/delete", function(req) -- 922
	ensureLLMConfigTable() -- 923
	do -- 924
		local _type_0 = type(req) -- 924
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 924
		if _tab_0 then -- 924
			local id -- 924
			do -- 924
				local _obj_0 = req.body -- 924
				local _type_1 = type(_obj_0) -- 924
				if "table" == _type_1 or "userdata" == _type_1 then -- 924
					id = _obj_0.id -- 924
				end -- 924
			end -- 924
			if id ~= nil then -- 924
				id = tonumber(id) -- 925
				if id == nil then -- 926
					return { -- 927
						success = false, -- 927
						message = "invalid" -- 927
					} -- 927
				end -- 926
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 928
					id -- 928
				}) -- 928
				return { -- 929
					success = affected >= 0 -- 929
				} -- 929
			end -- 924
		end -- 924
	end -- 924
	return { -- 922
		success = false, -- 922
		message = "invalid" -- 922
	} -- 922
end) -- 922
HttpServer:post("/new", function(req) -- 931
	do -- 932
		local _type_0 = type(req) -- 932
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 932
		if _tab_0 then -- 932
			local path -- 932
			do -- 932
				local _obj_0 = req.body -- 932
				local _type_1 = type(_obj_0) -- 932
				if "table" == _type_1 or "userdata" == _type_1 then -- 932
					path = _obj_0.path -- 932
				end -- 932
			end -- 932
			local content -- 932
			do -- 932
				local _obj_0 = req.body -- 932
				local _type_1 = type(_obj_0) -- 932
				if "table" == _type_1 or "userdata" == _type_1 then -- 932
					content = _obj_0.content -- 932
				end -- 932
			end -- 932
			local folder -- 932
			do -- 932
				local _obj_0 = req.body -- 932
				local _type_1 = type(_obj_0) -- 932
				if "table" == _type_1 or "userdata" == _type_1 then -- 932
					folder = _obj_0.folder -- 932
				end -- 932
			end -- 932
			if path ~= nil and content ~= nil and folder ~= nil then -- 932
				if Content:exist(path) then -- 933
					return { -- 934
						success = false, -- 934
						message = "TargetExisted" -- 934
					} -- 934
				end -- 933
				local parent = Path:getPath(path) -- 935
				local files = Content:getFiles(parent) -- 936
				if folder then -- 937
					local name = Path:getFilename(path):lower() -- 938
					for _index_0 = 1, #files do -- 939
						local file = files[_index_0] -- 939
						if name == Path:getFilename(file):lower() then -- 940
							return { -- 941
								success = false, -- 941
								message = "TargetExisted" -- 941
							} -- 941
						end -- 940
					end -- 939
					if Content:mkdir(path) then -- 942
						return { -- 943
							success = true -- 943
						} -- 943
					end -- 942
				else -- 945
					local name = Path:getName(path):lower() -- 945
					for _index_0 = 1, #files do -- 946
						local file = files[_index_0] -- 946
						if name == Path:getName(file):lower() then -- 947
							local ext = Path:getExt(file) -- 948
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 949
								goto _continue_0 -- 950
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 951
								goto _continue_0 -- 952
							end -- 949
							return { -- 953
								success = false, -- 953
								message = "SourceExisted" -- 953
							} -- 953
						end -- 947
						::_continue_0:: -- 947
					end -- 946
					if Content:save(path, content) then -- 954
						return { -- 955
							success = true -- 955
						} -- 955
					end -- 954
				end -- 937
			end -- 932
		end -- 932
	end -- 932
	return { -- 931
		success = false, -- 931
		message = "Failed" -- 931
	} -- 931
end) -- 931
HttpServer:post("/delete", function(req) -- 957
	do -- 958
		local _type_0 = type(req) -- 958
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 958
		if _tab_0 then -- 958
			local path -- 958
			do -- 958
				local _obj_0 = req.body -- 958
				local _type_1 = type(_obj_0) -- 958
				if "table" == _type_1 or "userdata" == _type_1 then -- 958
					path = _obj_0.path -- 958
				end -- 958
			end -- 958
			if path ~= nil then -- 958
				if Content:exist(path) then -- 959
					local projectRoot -- 960
					if Content:isdir(path) and isProjectRootDir(path) then -- 960
						projectRoot = path -- 960
					else -- 960
						projectRoot = nil -- 960
					end -- 960
					local parent = Path:getPath(path) -- 961
					local files = Content:getFiles(parent) -- 962
					local name = Path:getName(path):lower() -- 963
					local ext = Path:getExt(path) -- 964
					for _index_0 = 1, #files do -- 965
						local file = files[_index_0] -- 965
						if name == Path:getName(file):lower() then -- 966
							local _exp_0 = Path:getExt(file) -- 967
							if "tl" == _exp_0 then -- 967
								if ("vs" == ext) then -- 967
									Content:remove(Path(parent, file)) -- 968
								end -- 967
							elseif "lua" == _exp_0 then -- 969
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 969
									Content:remove(Path(parent, file)) -- 970
								end -- 969
							end -- 967
						end -- 966
					end -- 965
					if Content:remove(path) then -- 971
						if projectRoot then -- 972
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 973
						end -- 972
						return { -- 974
							success = true -- 974
						} -- 974
					end -- 971
				end -- 959
			end -- 958
		end -- 958
	end -- 958
	return { -- 957
		success = false -- 957
	} -- 957
end) -- 957
HttpServer:post("/rename", function(req) -- 976
	do -- 977
		local _type_0 = type(req) -- 977
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 977
		if _tab_0 then -- 977
			local old -- 977
			do -- 977
				local _obj_0 = req.body -- 977
				local _type_1 = type(_obj_0) -- 977
				if "table" == _type_1 or "userdata" == _type_1 then -- 977
					old = _obj_0.old -- 977
				end -- 977
			end -- 977
			local new -- 977
			do -- 977
				local _obj_0 = req.body -- 977
				local _type_1 = type(_obj_0) -- 977
				if "table" == _type_1 or "userdata" == _type_1 then -- 977
					new = _obj_0.new -- 977
				end -- 977
			end -- 977
			if old ~= nil and new ~= nil then -- 977
				if Content:exist(old) and not Content:exist(new) then -- 978
					local renamedDir = Content:isdir(old) -- 979
					local parent = Path:getPath(new) -- 980
					local files = Content:getFiles(parent) -- 981
					if renamedDir then -- 982
						local name = Path:getFilename(new):lower() -- 983
						for _index_0 = 1, #files do -- 984
							local file = files[_index_0] -- 984
							if name == Path:getFilename(file):lower() then -- 985
								return { -- 986
									success = false -- 986
								} -- 986
							end -- 985
						end -- 984
					else -- 988
						local name = Path:getName(new):lower() -- 988
						local ext = Path:getExt(new) -- 989
						for _index_0 = 1, #files do -- 990
							local file = files[_index_0] -- 990
							if name == Path:getName(file):lower() then -- 991
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 992
									goto _continue_0 -- 993
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 994
									goto _continue_0 -- 995
								end -- 992
								return { -- 996
									success = false -- 996
								} -- 996
							end -- 991
							::_continue_0:: -- 991
						end -- 990
					end -- 982
					if Content:move(old, new) then -- 997
						if renamedDir then -- 998
							AgentSession.renameSessionsByProjectRoot(old, new) -- 999
						end -- 998
						local newParent = Path:getPath(new) -- 1000
						parent = Path:getPath(old) -- 1001
						files = Content:getFiles(parent) -- 1002
						local newName = Path:getName(new) -- 1003
						local oldName = Path:getName(old) -- 1004
						local name = oldName:lower() -- 1005
						local ext = Path:getExt(old) -- 1006
						for _index_0 = 1, #files do -- 1007
							local file = files[_index_0] -- 1007
							if name == Path:getName(file):lower() then -- 1008
								local _exp_0 = Path:getExt(file) -- 1009
								if "tl" == _exp_0 then -- 1009
									if ("vs" == ext) then -- 1009
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1010
									end -- 1009
								elseif "lua" == _exp_0 then -- 1011
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1011
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1012
									end -- 1011
								end -- 1009
							end -- 1008
						end -- 1007
						return { -- 1013
							success = true -- 1013
						} -- 1013
					end -- 997
				end -- 978
			end -- 977
		end -- 977
	end -- 977
	return { -- 976
		success = false -- 976
	} -- 976
end) -- 976
HttpServer:post("/exist", function(req) -- 1015
	do -- 1016
		local _type_0 = type(req) -- 1016
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1016
		if _tab_0 then -- 1016
			local file -- 1016
			do -- 1016
				local _obj_0 = req.body -- 1016
				local _type_1 = type(_obj_0) -- 1016
				if "table" == _type_1 or "userdata" == _type_1 then -- 1016
					file = _obj_0.file -- 1016
				end -- 1016
			end -- 1016
			if file ~= nil then -- 1016
				do -- 1017
					local projFile = req.body.projFile -- 1017
					if projFile then -- 1017
						local projDir = getProjectDirFromFile(projFile) -- 1018
						if projDir then -- 1018
							local scriptDir = Path(projDir, "Script") -- 1019
							local searchPaths = Content.searchPaths -- 1020
							if Content:exist(scriptDir) then -- 1021
								Content:addSearchPath(scriptDir) -- 1021
							end -- 1021
							if Content:exist(projDir) then -- 1022
								Content:addSearchPath(projDir) -- 1022
							end -- 1022
							local _ <close> = setmetatable({ }, { -- 1023
								__close = function() -- 1023
									Content.searchPaths = searchPaths -- 1023
								end -- 1023
							}) -- 1023
							return { -- 1024
								success = Content:exist(file) -- 1024
							} -- 1024
						end -- 1018
					end -- 1017
				end -- 1017
				return { -- 1025
					success = Content:exist(file) -- 1025
				} -- 1025
			end -- 1016
		end -- 1016
	end -- 1016
	return { -- 1015
		success = false -- 1015
	} -- 1015
end) -- 1015
HttpServer:postSchedule("/read", function(req) -- 1027
	do -- 1028
		local _type_0 = type(req) -- 1028
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1028
		if _tab_0 then -- 1028
			local path -- 1028
			do -- 1028
				local _obj_0 = req.body -- 1028
				local _type_1 = type(_obj_0) -- 1028
				if "table" == _type_1 or "userdata" == _type_1 then -- 1028
					path = _obj_0.path -- 1028
				end -- 1028
			end -- 1028
			if path ~= nil then -- 1028
				local readFile -- 1029
				readFile = function() -- 1029
					if Content:exist(path) then -- 1030
						local content = Content:loadAsync(path) -- 1031
						if content then -- 1031
							return { -- 1032
								content = content, -- 1032
								success = true, -- 1032
								fullPath = Content:getFullPath(path) -- 1032
							} -- 1032
						end -- 1031
					end -- 1030
					return nil -- 1029
				end -- 1029
				do -- 1033
					local projFile = req.body.projFile -- 1033
					if projFile then -- 1033
						local projDir = getProjectDirFromFile(projFile) -- 1034
						if projDir then -- 1034
							local scriptDir = Path(projDir, "Script") -- 1035
							local searchPaths = Content.searchPaths -- 1036
							if Content:exist(scriptDir) then -- 1037
								Content:addSearchPath(scriptDir) -- 1037
							end -- 1037
							if Content:exist(projDir) then -- 1038
								Content:addSearchPath(projDir) -- 1038
							end -- 1038
							local _ <close> = setmetatable({ }, { -- 1039
								__close = function() -- 1039
									Content.searchPaths = searchPaths -- 1039
								end -- 1039
							}) -- 1039
							local result = readFile() -- 1040
							if result then -- 1040
								return result -- 1040
							end -- 1040
						end -- 1034
					end -- 1033
				end -- 1033
				local result = readFile() -- 1041
				if result then -- 1041
					return result -- 1041
				end -- 1041
			end -- 1028
		end -- 1028
	end -- 1028
	return { -- 1027
		success = false -- 1027
	} -- 1027
end) -- 1027
HttpServer:get("/read-sync", function(req) -- 1043
	do -- 1044
		local _type_0 = type(req) -- 1044
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1044
		if _tab_0 then -- 1044
			local params = req.params -- 1044
			if params ~= nil then -- 1044
				local path = params.path -- 1045
				local exts -- 1046
				if params.exts then -- 1046
					local _accum_0 = { } -- 1047
					local _len_0 = 1 -- 1047
					for ext in params.exts:gmatch("[^|]*") do -- 1047
						_accum_0[_len_0] = ext -- 1048
						_len_0 = _len_0 + 1 -- 1048
					end -- 1047
					exts = _accum_0 -- 1046
				else -- 1049
					exts = { -- 1049
						"" -- 1049
					} -- 1049
				end -- 1046
				local readFile -- 1050
				readFile = function() -- 1050
					for _index_0 = 1, #exts do -- 1051
						local ext = exts[_index_0] -- 1051
						local targetPath = path .. ext -- 1052
						if Content:exist(targetPath) then -- 1053
							local content = Content:load(targetPath) -- 1054
							if content then -- 1054
								return { -- 1055
									content = content, -- 1055
									success = true, -- 1055
									fullPath = Content:getFullPath(targetPath) -- 1055
								} -- 1055
							end -- 1054
						end -- 1053
					end -- 1051
					return nil -- 1050
				end -- 1050
				local searchPaths = Content.searchPaths -- 1056
				local _ <close> = setmetatable({ }, { -- 1057
					__close = function() -- 1057
						Content.searchPaths = searchPaths -- 1057
					end -- 1057
				}) -- 1057
				do -- 1058
					local projFile = req.params.projFile -- 1058
					if projFile then -- 1058
						local projDir = getProjectDirFromFile(projFile) -- 1059
						if projDir then -- 1059
							local scriptDir = Path(projDir, "Script") -- 1060
							if Content:exist(scriptDir) then -- 1061
								Content:addSearchPath(scriptDir) -- 1061
							end -- 1061
							if Content:exist(projDir) then -- 1062
								Content:addSearchPath(projDir) -- 1062
							end -- 1062
						else -- 1064
							projDir = Path:getPath(projFile) -- 1064
							if Content:exist(projDir) then -- 1065
								Content:addSearchPath(projDir) -- 1065
							end -- 1065
						end -- 1059
					end -- 1058
				end -- 1058
				local result = readFile() -- 1066
				if result then -- 1066
					return result -- 1066
				end -- 1066
			end -- 1044
		end -- 1044
	end -- 1044
	return { -- 1043
		success = false -- 1043
	} -- 1043
end) -- 1043
local compileFileAsync -- 1068
compileFileAsync = function(inputFile, sourceCodes) -- 1068
	local file = inputFile -- 1069
	local searchPath -- 1070
	do -- 1070
		local dir = getProjectDirFromFile(inputFile) -- 1070
		if dir then -- 1070
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 1071
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1072
		else -- 1074
			file = Path:getRelative(inputFile, Content.writablePath) -- 1074
			if file:sub(1, 2) == ".." then -- 1075
				file = Path:getRelative(inputFile, Content.assetPath) -- 1076
			end -- 1075
			searchPath = "" -- 1077
		end -- 1070
	end -- 1070
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1078
	local yueext = yue.options.extension -- 1079
	local resultCodes = nil -- 1080
	local resultError = nil -- 1081
	do -- 1082
		local _exp_0 = Path:getExt(inputFile) -- 1082
		if yueext == _exp_0 then -- 1082
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1083
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1084
				if not codes then -- 1085
					resultError = err -- 1086
					return -- 1087
				end -- 1085
				local extraGlobal -- 1088
				if isTIC80 then -- 1088
					extraGlobal = tic80APIs -- 1088
				else -- 1088
					extraGlobal = nil -- 1088
				end -- 1088
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1089
				if not success then -- 1090
					resultError = message -- 1091
					return -- 1092
				end -- 1090
				if codes == "" then -- 1093
					resultCodes = "" -- 1094
					return nil -- 1095
				end -- 1093
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1096
				return resultCodes -- 1097
			end, function(success) -- 1084
				if not success then -- 1098
					Content:remove(outputFile) -- 1099
					if resultCodes == nil then -- 1100
						resultCodes = false -- 1101
					end -- 1100
				end -- 1098
			end) -- 1084
		elseif "tl" == _exp_0 then -- 1102
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1103
			if isTIC80 then -- 1104
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1105
			end -- 1104
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1106
			if codes then -- 1106
				if isTIC80 then -- 1107
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1108
				end -- 1107
				resultCodes = codes -- 1109
				Content:saveAsync(outputFile, codes) -- 1110
			else -- 1112
				Content:remove(outputFile) -- 1112
				resultCodes = false -- 1113
				resultError = err -- 1114
			end -- 1106
		elseif "xml" == _exp_0 then -- 1115
			local codes, err = xml.tolua(sourceCodes) -- 1116
			if codes then -- 1116
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1117
				Content:saveAsync(outputFile, resultCodes) -- 1118
			else -- 1120
				Content:remove(outputFile) -- 1120
				resultCodes = false -- 1121
				resultError = err -- 1122
			end -- 1116
		end -- 1082
	end -- 1082
	wait(function() -- 1123
		return resultCodes ~= nil -- 1123
	end) -- 1123
	if resultCodes then -- 1124
		return resultCodes -- 1125
	else -- 1127
		return nil, resultError -- 1127
	end -- 1124
	return nil -- 1068
end -- 1068
HttpServer:postSchedule("/write", function(req) -- 1129
	do -- 1130
		local _type_0 = type(req) -- 1130
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1130
		if _tab_0 then -- 1130
			local path -- 1130
			do -- 1130
				local _obj_0 = req.body -- 1130
				local _type_1 = type(_obj_0) -- 1130
				if "table" == _type_1 or "userdata" == _type_1 then -- 1130
					path = _obj_0.path -- 1130
				end -- 1130
			end -- 1130
			local content -- 1130
			do -- 1130
				local _obj_0 = req.body -- 1130
				local _type_1 = type(_obj_0) -- 1130
				if "table" == _type_1 or "userdata" == _type_1 then -- 1130
					content = _obj_0.content -- 1130
				end -- 1130
			end -- 1130
			if path ~= nil and content ~= nil then -- 1130
				if Content:saveAsync(path, content) then -- 1131
					do -- 1132
						local _exp_0 = Path:getExt(path) -- 1132
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1132
							if '' == Path:getExt(Path:getName(path)) then -- 1133
								local resultCodes = compileFileAsync(path, content) -- 1134
								return { -- 1135
									success = true, -- 1135
									resultCodes = resultCodes -- 1135
								} -- 1135
							end -- 1133
						end -- 1132
					end -- 1132
					return { -- 1136
						success = true -- 1136
					} -- 1136
				end -- 1131
			end -- 1130
		end -- 1130
	end -- 1130
	return { -- 1129
		success = false -- 1129
	} -- 1129
end) -- 1129
HttpServer:postSchedule("/build", function(req) -- 1138
	do -- 1139
		local _type_0 = type(req) -- 1139
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1139
		if _tab_0 then -- 1139
			local path -- 1139
			do -- 1139
				local _obj_0 = req.body -- 1139
				local _type_1 = type(_obj_0) -- 1139
				if "table" == _type_1 or "userdata" == _type_1 then -- 1139
					path = _obj_0.path -- 1139
				end -- 1139
			end -- 1139
			if path ~= nil then -- 1139
				local _exp_0 = Path:getExt(path) -- 1140
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1140
					if '' == Path:getExt(Path:getName(path)) then -- 1141
						local content = Content:loadAsync(path) -- 1142
						if content then -- 1142
							local resultCodes = compileFileAsync(path, content) -- 1143
							if resultCodes then -- 1143
								return { -- 1144
									success = true, -- 1144
									resultCodes = resultCodes -- 1144
								} -- 1144
							end -- 1143
						end -- 1142
					end -- 1141
				end -- 1140
			end -- 1139
		end -- 1139
	end -- 1139
	return { -- 1138
		success = false -- 1138
	} -- 1138
end) -- 1138
local extentionLevels = { -- 1147
	vs = 2, -- 1147
	bl = 2, -- 1148
	ts = 1, -- 1149
	tsx = 1, -- 1150
	tl = 1, -- 1151
	yue = 1, -- 1152
	xml = 1, -- 1153
	lua = 0 -- 1154
} -- 1146
HttpServer:post("/assets", function() -- 1156
	local Entry = require("Script.Dev.Entry") -- 1159
	local engineDev = Entry.getEngineDev() -- 1160
	local visitAssets -- 1161
	visitAssets = function(path, tag) -- 1161
		local isWorkspace = tag == "Workspace" -- 1162
		local builtin -- 1163
		if tag == "Builtin" then -- 1163
			builtin = true -- 1163
		else -- 1163
			builtin = nil -- 1163
		end -- 1163
		local children = nil -- 1164
		local dirs = Content:getDirs(path) -- 1165
		for _index_0 = 1, #dirs do -- 1166
			local dir = dirs[_index_0] -- 1166
			if isWorkspace then -- 1167
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1168
					goto _continue_0 -- 1169
				end -- 1168
			elseif dir == ".git" then -- 1170
				goto _continue_0 -- 1171
			end -- 1167
			if not children then -- 1172
				children = { } -- 1172
			end -- 1172
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1173
			::_continue_0:: -- 1167
		end -- 1166
		local files = Content:getFiles(path) -- 1174
		local names = { } -- 1175
		for _index_0 = 1, #files do -- 1176
			local file = files[_index_0] -- 1176
			if file:match("^%.") then -- 1177
				goto _continue_1 -- 1177
			end -- 1177
			local name = Path:getName(file) -- 1178
			local ext = names[name] -- 1179
			if ext then -- 1179
				local lv1 -- 1180
				do -- 1180
					local _exp_0 = extentionLevels[ext] -- 1180
					if _exp_0 ~= nil then -- 1180
						lv1 = _exp_0 -- 1180
					else -- 1180
						lv1 = -1 -- 1180
					end -- 1180
				end -- 1180
				ext = Path:getExt(file) -- 1181
				local lv2 -- 1182
				do -- 1182
					local _exp_0 = extentionLevels[ext] -- 1182
					if _exp_0 ~= nil then -- 1182
						lv2 = _exp_0 -- 1182
					else -- 1182
						lv2 = -1 -- 1182
					end -- 1182
				end -- 1182
				if lv2 > lv1 then -- 1183
					names[name] = ext -- 1184
				elseif lv2 == lv1 then -- 1185
					names[name .. '.' .. ext] = "" -- 1186
				end -- 1183
			else -- 1188
				ext = Path:getExt(file) -- 1188
				if not extentionLevels[ext] then -- 1189
					names[file] = "" -- 1190
				else -- 1192
					names[name] = ext -- 1192
				end -- 1189
			end -- 1179
			::_continue_1:: -- 1177
		end -- 1176
		do -- 1193
			local _accum_0 = { } -- 1193
			local _len_0 = 1 -- 1193
			for name, ext in pairs(names) do -- 1193
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1193
				_len_0 = _len_0 + 1 -- 1193
			end -- 1193
			files = _accum_0 -- 1193
		end -- 1193
		for _index_0 = 1, #files do -- 1194
			local file = files[_index_0] -- 1194
			if not children then -- 1195
				children = { } -- 1195
			end -- 1195
			children[#children + 1] = { -- 1197
				key = Path(path, file), -- 1197
				dir = false, -- 1198
				title = file, -- 1199
				builtin = builtin -- 1200
			} -- 1196
		end -- 1194
		if children then -- 1202
			table.sort(children, function(a, b) -- 1203
				if a.dir == b.dir then -- 1204
					return a.title < b.title -- 1205
				else -- 1207
					return a.dir -- 1207
				end -- 1204
			end) -- 1203
		end -- 1202
		if isWorkspace and children then -- 1208
			return children -- 1209
		else -- 1211
			return { -- 1212
				key = path, -- 1212
				dir = true, -- 1213
				title = Path:getFilename(path), -- 1214
				builtin = builtin, -- 1215
				children = children -- 1216
			} -- 1211
		end -- 1208
	end -- 1161
	local zh = (App.locale:match("^zh") ~= nil) -- 1218
	return { -- 1220
		key = Content.writablePath, -- 1220
		dir = true, -- 1221
		root = true, -- 1222
		title = "Assets", -- 1223
		children = (function() -- 1225
			local _tab_0 = { -- 1225
				{ -- 1226
					key = Path(Content.assetPath), -- 1226
					dir = true, -- 1227
					builtin = true, -- 1228
					title = zh and "内置资源" or "Built-in", -- 1229
					children = { -- 1231
						(function() -- 1231
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1231
							_with_0.title = zh and "说明文档" or "Readme" -- 1232
							return _with_0 -- 1231
						end)(), -- 1231
						(function() -- 1233
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1233
							_with_0.title = zh and "接口文档" or "API Doc" -- 1234
							return _with_0 -- 1233
						end)(), -- 1233
						(function() -- 1235
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1235
							_with_0.title = zh and "开发工具" or "Tools" -- 1236
							return _with_0 -- 1235
						end)(), -- 1235
						(function() -- 1237
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1237
							_with_0.title = zh and "字体" or "Font" -- 1238
							return _with_0 -- 1237
						end)(), -- 1237
						(function() -- 1239
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1239
							_with_0.title = zh and "程序库" or "Lib" -- 1240
							if engineDev then -- 1241
								local _list_0 = _with_0.children -- 1242
								for _index_0 = 1, #_list_0 do -- 1242
									local child = _list_0[_index_0] -- 1242
									if not (child.title == "Dora") then -- 1243
										goto _continue_0 -- 1243
									end -- 1243
									local title = zh and "zh-Hans" or "en" -- 1244
									do -- 1245
										local _accum_0 = { } -- 1245
										local _len_0 = 1 -- 1245
										local _list_1 = child.children -- 1245
										for _index_1 = 1, #_list_1 do -- 1245
											local c = _list_1[_index_1] -- 1245
											if c.title ~= title then -- 1245
												_accum_0[_len_0] = c -- 1245
												_len_0 = _len_0 + 1 -- 1245
											end -- 1245
										end -- 1245
										child.children = _accum_0 -- 1245
									end -- 1245
									break -- 1246
									::_continue_0:: -- 1243
								end -- 1242
							else -- 1248
								local _accum_0 = { } -- 1248
								local _len_0 = 1 -- 1248
								local _list_0 = _with_0.children -- 1248
								for _index_0 = 1, #_list_0 do -- 1248
									local child = _list_0[_index_0] -- 1248
									if child.title ~= "Dora" then -- 1248
										_accum_0[_len_0] = child -- 1248
										_len_0 = _len_0 + 1 -- 1248
									end -- 1248
								end -- 1248
								_with_0.children = _accum_0 -- 1248
							end -- 1241
							return _with_0 -- 1239
						end)(), -- 1239
						(function() -- 1249
							if engineDev then -- 1249
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1250
								local _obj_0 = _with_0.children -- 1251
								_obj_0[#_obj_0 + 1] = { -- 1252
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1252
									dir = false, -- 1253
									builtin = true, -- 1254
									title = "init.yue" -- 1255
								} -- 1251
								return _with_0 -- 1250
							end -- 1249
						end)() -- 1249
					} -- 1230
				} -- 1225
			} -- 1259
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1259
			local _idx_0 = #_tab_0 + 1 -- 1259
			for _index_0 = 1, #_obj_0 do -- 1259
				local _value_0 = _obj_0[_index_0] -- 1259
				_tab_0[_idx_0] = _value_0 -- 1259
				_idx_0 = _idx_0 + 1 -- 1259
			end -- 1259
			return _tab_0 -- 1225
		end)() -- 1224
	} -- 1219
end) -- 1156
HttpServer:post("/entry/list", function() -- 1263
	local Entry = require("Script.Dev.Entry") -- 1264
	local res = Entry.getLaunchEntries() -- 1265
	res.success = true -- 1266
	return res -- 1267
end) -- 1263
HttpServer:postSchedule("/run", function(req) -- 1269
	do -- 1270
		local _type_0 = type(req) -- 1270
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1270
		if _tab_0 then -- 1270
			local file -- 1270
			do -- 1270
				local _obj_0 = req.body -- 1270
				local _type_1 = type(_obj_0) -- 1270
				if "table" == _type_1 or "userdata" == _type_1 then -- 1270
					file = _obj_0.file -- 1270
				end -- 1270
			end -- 1270
			local asProj -- 1270
			do -- 1270
				local _obj_0 = req.body -- 1270
				local _type_1 = type(_obj_0) -- 1270
				if "table" == _type_1 or "userdata" == _type_1 then -- 1270
					asProj = _obj_0.asProj -- 1270
				end -- 1270
			end -- 1270
			if file ~= nil and asProj ~= nil then -- 1270
				if not Content:isAbsolutePath(file) then -- 1271
					local devFile = Path(Content.writablePath, file) -- 1272
					if Content:exist(devFile) then -- 1273
						file = devFile -- 1273
					end -- 1273
				end -- 1271
				local Entry = require("Script.Dev.Entry") -- 1274
				local workDir -- 1275
				if asProj then -- 1276
					workDir = getProjectDirFromFile(file) -- 1277
					if workDir then -- 1277
						Entry.allClear() -- 1278
						local target = Path(workDir, "init") -- 1279
						local success, err = Entry.enterEntryAsync({ -- 1280
							entryName = "Project", -- 1280
							fileName = target -- 1280
						}) -- 1280
						target = Path:getName(Path:getPath(target)) -- 1281
						return { -- 1282
							success = success, -- 1282
							target = target, -- 1282
							err = err -- 1282
						} -- 1282
					end -- 1277
				else -- 1284
					workDir = getProjectDirFromFile(file) -- 1284
				end -- 1276
				Entry.allClear() -- 1285
				file = Path:replaceExt(file, "") -- 1286
				local success, err = Entry.enterEntryAsync({ -- 1288
					entryName = Path:getName(file), -- 1288
					fileName = file, -- 1289
					workDir = workDir -- 1290
				}) -- 1287
				return { -- 1291
					success = success, -- 1291
					err = err -- 1291
				} -- 1291
			end -- 1270
		end -- 1270
	end -- 1270
	return { -- 1269
		success = false -- 1269
	} -- 1269
end) -- 1269
HttpServer:postSchedule("/stop", function() -- 1293
	local Entry = require("Script.Dev.Entry") -- 1294
	return { -- 1295
		success = Entry.stop() -- 1295
	} -- 1295
end) -- 1293
local minifyAsync -- 1297
minifyAsync = function(sourcePath, minifyPath) -- 1297
	if not Content:exist(sourcePath) then -- 1298
		return -- 1298
	end -- 1298
	local Entry = require("Script.Dev.Entry") -- 1299
	local errors = { } -- 1300
	local files = Entry.getAllFiles(sourcePath, { -- 1301
		"lua" -- 1301
	}, true) -- 1301
	do -- 1302
		local _accum_0 = { } -- 1302
		local _len_0 = 1 -- 1302
		for _index_0 = 1, #files do -- 1302
			local file = files[_index_0] -- 1302
			if file:sub(1, 1) ~= '.' then -- 1302
				_accum_0[_len_0] = file -- 1302
				_len_0 = _len_0 + 1 -- 1302
			end -- 1302
		end -- 1302
		files = _accum_0 -- 1302
	end -- 1302
	local paths -- 1303
	do -- 1303
		local _tbl_0 = { } -- 1303
		for _index_0 = 1, #files do -- 1303
			local file = files[_index_0] -- 1303
			_tbl_0[Path:getPath(file)] = true -- 1303
		end -- 1303
		paths = _tbl_0 -- 1303
	end -- 1303
	for path in pairs(paths) do -- 1304
		Content:mkdir(Path(minifyPath, path)) -- 1304
	end -- 1304
	local _ <close> = setmetatable({ }, { -- 1305
		__close = function() -- 1305
			package.loaded["luaminify.FormatMini"] = nil -- 1306
			package.loaded["luaminify.ParseLua"] = nil -- 1307
			package.loaded["luaminify.Scope"] = nil -- 1308
			package.loaded["luaminify.Util"] = nil -- 1309
		end -- 1305
	}) -- 1305
	local FormatMini -- 1310
	do -- 1310
		local _obj_0 = require("luaminify") -- 1310
		FormatMini = _obj_0.FormatMini -- 1310
	end -- 1310
	local fileCount = #files -- 1311
	local count = 0 -- 1312
	for _index_0 = 1, #files do -- 1313
		local file = files[_index_0] -- 1313
		thread(function() -- 1314
			local _ <close> = setmetatable({ }, { -- 1315
				__close = function() -- 1315
					count = count + 1 -- 1315
				end -- 1315
			}) -- 1315
			local input = Path(sourcePath, file) -- 1316
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1317
			if Content:exist(input) then -- 1318
				local sourceCodes = Content:loadAsync(input) -- 1319
				local res, err = FormatMini(sourceCodes) -- 1320
				if res then -- 1321
					Content:saveAsync(output, res) -- 1322
					return print("Minify " .. tostring(file)) -- 1323
				else -- 1325
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1325
				end -- 1321
			else -- 1327
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1327
			end -- 1318
		end) -- 1314
		sleep() -- 1328
	end -- 1313
	wait(function() -- 1329
		return count == fileCount -- 1329
	end) -- 1329
	if #errors > 0 then -- 1330
		print(table.concat(errors, '\n')) -- 1331
	end -- 1330
	print("Obfuscation done.") -- 1332
	return files -- 1333
end -- 1297
local zipping = false -- 1335
HttpServer:postSchedule("/zip", function(req) -- 1337
	do -- 1338
		local _type_0 = type(req) -- 1338
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1338
		if _tab_0 then -- 1338
			local path -- 1338
			do -- 1338
				local _obj_0 = req.body -- 1338
				local _type_1 = type(_obj_0) -- 1338
				if "table" == _type_1 or "userdata" == _type_1 then -- 1338
					path = _obj_0.path -- 1338
				end -- 1338
			end -- 1338
			local zipFile -- 1338
			do -- 1338
				local _obj_0 = req.body -- 1338
				local _type_1 = type(_obj_0) -- 1338
				if "table" == _type_1 or "userdata" == _type_1 then -- 1338
					zipFile = _obj_0.zipFile -- 1338
				end -- 1338
			end -- 1338
			local obfuscated -- 1338
			do -- 1338
				local _obj_0 = req.body -- 1338
				local _type_1 = type(_obj_0) -- 1338
				if "table" == _type_1 or "userdata" == _type_1 then -- 1338
					obfuscated = _obj_0.obfuscated -- 1338
				end -- 1338
			end -- 1338
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1338
				if zipping then -- 1339
					goto failed -- 1339
				end -- 1339
				zipping = true -- 1340
				local _ <close> = setmetatable({ }, { -- 1341
					__close = function() -- 1341
						zipping = false -- 1341
					end -- 1341
				}) -- 1341
				if not Content:exist(path) then -- 1342
					goto failed -- 1342
				end -- 1342
				Content:mkdir(Path:getPath(zipFile)) -- 1343
				if obfuscated then -- 1344
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1345
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1346
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1347
					Content:remove(scriptPath) -- 1348
					Content:remove(obfuscatedPath) -- 1349
					Content:remove(tempPath) -- 1350
					Content:mkdir(scriptPath) -- 1351
					Content:mkdir(obfuscatedPath) -- 1352
					Content:mkdir(tempPath) -- 1353
					if not Content:copyAsync(path, tempPath) then -- 1354
						goto failed -- 1354
					end -- 1354
					local Entry = require("Script.Dev.Entry") -- 1355
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1356
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1357
						"tl", -- 1357
						"yue", -- 1357
						"lua", -- 1357
						"ts", -- 1357
						"tsx", -- 1357
						"vs", -- 1357
						"bl", -- 1357
						"xml", -- 1357
						"wa", -- 1357
						"mod" -- 1357
					}, true) -- 1357
					for _index_0 = 1, #scriptFiles do -- 1358
						local file = scriptFiles[_index_0] -- 1358
						Content:remove(Path(tempPath, file)) -- 1359
					end -- 1358
					for _index_0 = 1, #luaFiles do -- 1360
						local file = luaFiles[_index_0] -- 1360
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1361
					end -- 1360
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1362
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1363
					end) then -- 1362
						goto failed -- 1362
					end -- 1362
					return { -- 1364
						success = true -- 1364
					} -- 1364
				else -- 1366
					return { -- 1366
						success = Content:zipAsync(path, zipFile, function(file) -- 1366
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1367
						end) -- 1366
					} -- 1366
				end -- 1344
			end -- 1338
		end -- 1338
	end -- 1338
	::failed:: -- 1368
	return { -- 1337
		success = false -- 1337
	} -- 1337
end) -- 1337
HttpServer:postSchedule("/unzip", function(req) -- 1370
	do -- 1371
		local _type_0 = type(req) -- 1371
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1371
		if _tab_0 then -- 1371
			local zipFile -- 1371
			do -- 1371
				local _obj_0 = req.body -- 1371
				local _type_1 = type(_obj_0) -- 1371
				if "table" == _type_1 or "userdata" == _type_1 then -- 1371
					zipFile = _obj_0.zipFile -- 1371
				end -- 1371
			end -- 1371
			local path -- 1371
			do -- 1371
				local _obj_0 = req.body -- 1371
				local _type_1 = type(_obj_0) -- 1371
				if "table" == _type_1 or "userdata" == _type_1 then -- 1371
					path = _obj_0.path -- 1371
				end -- 1371
			end -- 1371
			if zipFile ~= nil and path ~= nil then -- 1371
				return { -- 1372
					success = Content:unzipAsync(zipFile, path, function(file) -- 1372
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1373
					end) -- 1372
				} -- 1372
			end -- 1371
		end -- 1371
	end -- 1371
	return { -- 1370
		success = false -- 1370
	} -- 1370
end) -- 1370
HttpServer:post("/editing-info", function(req) -- 1375
	local Entry = require("Script.Dev.Entry") -- 1376
	local config = Entry.getConfig() -- 1377
	local _type_0 = type(req) -- 1378
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1378
	local _match_0 = false -- 1378
	if _tab_0 then -- 1378
		local editingInfo -- 1378
		do -- 1378
			local _obj_0 = req.body -- 1378
			local _type_1 = type(_obj_0) -- 1378
			if "table" == _type_1 or "userdata" == _type_1 then -- 1378
				editingInfo = _obj_0.editingInfo -- 1378
			end -- 1378
		end -- 1378
		if editingInfo ~= nil then -- 1378
			_match_0 = true -- 1378
			config.editingInfo = editingInfo -- 1379
			return { -- 1380
				success = true -- 1380
			} -- 1380
		end -- 1378
	end -- 1378
	if not _match_0 then -- 1378
		if not (config.editingInfo ~= nil) then -- 1382
			local folder -- 1383
			if App.locale:match('^zh') then -- 1383
				folder = 'zh-Hans' -- 1383
			else -- 1383
				folder = 'en' -- 1383
			end -- 1383
			config.editingInfo = json.encode({ -- 1385
				index = 0, -- 1385
				files = { -- 1387
					{ -- 1388
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1388
						title = "welcome.md" -- 1389
					} -- 1387
				} -- 1386
			}) -- 1384
		end -- 1382
		return { -- 1393
			success = true, -- 1393
			editingInfo = config.editingInfo -- 1393
		} -- 1393
	end -- 1378
end) -- 1375
HttpServer:post("/command", function(req) -- 1395
	do -- 1396
		local _type_0 = type(req) -- 1396
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1396
		if _tab_0 then -- 1396
			local code -- 1396
			do -- 1396
				local _obj_0 = req.body -- 1396
				local _type_1 = type(_obj_0) -- 1396
				if "table" == _type_1 or "userdata" == _type_1 then -- 1396
					code = _obj_0.code -- 1396
				end -- 1396
			end -- 1396
			local log -- 1396
			do -- 1396
				local _obj_0 = req.body -- 1396
				local _type_1 = type(_obj_0) -- 1396
				if "table" == _type_1 or "userdata" == _type_1 then -- 1396
					log = _obj_0.log -- 1396
				end -- 1396
			end -- 1396
			if code ~= nil and log ~= nil then -- 1396
				emit("AppCommand", code, log) -- 1397
				return { -- 1398
					success = true -- 1398
				} -- 1398
			end -- 1396
		end -- 1396
	end -- 1396
	return { -- 1395
		success = false -- 1395
	} -- 1395
end) -- 1395
HttpServer:post("/log/save", function() -- 1400
	local folder = ".download" -- 1401
	local fullLogFile = "dora_full_logs.txt" -- 1402
	local fullFolder = Path(Content.writablePath, folder) -- 1403
	Content:mkdir(fullFolder) -- 1404
	local logPath = Path(fullFolder, fullLogFile) -- 1405
	if App:saveLog(logPath) then -- 1406
		return { -- 1407
			success = true, -- 1407
			path = Path(folder, fullLogFile) -- 1407
		} -- 1407
	end -- 1406
	return { -- 1400
		success = false -- 1400
	} -- 1400
end) -- 1400
HttpServer:post("/yarn/check", function(req) -- 1409
	local yarncompile = require("yarncompile") -- 1410
	do -- 1411
		local _type_0 = type(req) -- 1411
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1411
		if _tab_0 then -- 1411
			local code -- 1411
			do -- 1411
				local _obj_0 = req.body -- 1411
				local _type_1 = type(_obj_0) -- 1411
				if "table" == _type_1 or "userdata" == _type_1 then -- 1411
					code = _obj_0.code -- 1411
				end -- 1411
			end -- 1411
			if code ~= nil then -- 1411
				local jsonObject = json.decode(code) -- 1412
				if jsonObject then -- 1412
					local errors = { } -- 1413
					local _list_0 = jsonObject.nodes -- 1414
					for _index_0 = 1, #_list_0 do -- 1414
						local node = _list_0[_index_0] -- 1414
						local title, body = node.title, node.body -- 1415
						local luaCode, err = yarncompile(body) -- 1416
						if not luaCode then -- 1416
							errors[#errors + 1] = title .. ":" .. err -- 1417
						end -- 1416
					end -- 1414
					return { -- 1418
						success = true, -- 1418
						syntaxError = table.concat(errors, "\n\n") -- 1418
					} -- 1418
				end -- 1412
			end -- 1411
		end -- 1411
	end -- 1411
	return { -- 1409
		success = false -- 1409
	} -- 1409
end) -- 1409
HttpServer:post("/yarn/check-file", function(req) -- 1420
	local yarncompile = require("yarncompile") -- 1421
	do -- 1422
		local _type_0 = type(req) -- 1422
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1422
		if _tab_0 then -- 1422
			local code -- 1422
			do -- 1422
				local _obj_0 = req.body -- 1422
				local _type_1 = type(_obj_0) -- 1422
				if "table" == _type_1 or "userdata" == _type_1 then -- 1422
					code = _obj_0.code -- 1422
				end -- 1422
			end -- 1422
			if code ~= nil then -- 1422
				local res, _, err = yarncompile(code, true) -- 1423
				if not res then -- 1423
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1424
					return { -- 1425
						success = false, -- 1425
						message = message, -- 1425
						line = line, -- 1425
						column = column, -- 1425
						node = node -- 1425
					} -- 1425
				end -- 1423
			end -- 1422
		end -- 1422
	end -- 1422
	return { -- 1420
		success = true -- 1420
	} -- 1420
end) -- 1420
local getWaProjectDirFromFile -- 1427
getWaProjectDirFromFile = function(file) -- 1427
	local writablePath = Content.writablePath -- 1428
	local parent, current -- 1429
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1429
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1430
	else -- 1432
		parent, current = nil, nil -- 1432
	end -- 1429
	if not current then -- 1433
		return nil -- 1433
	end -- 1433
	repeat -- 1434
		current = Path:getPath(current) -- 1435
		if current == "" then -- 1436
			break -- 1436
		end -- 1436
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1437
		for _index_0 = 1, #_list_0 do -- 1437
			local f = _list_0[_index_0] -- 1437
			if Path:getFilename(f):lower() == "wa.mod" then -- 1438
				return Path(parent, current, Path:getPath(f)) -- 1439
			end -- 1438
		end -- 1437
	until false -- 1434
	return nil -- 1441
end -- 1427
HttpServer:postSchedule("/wa/update_dora", function(req) -- 1443
	do -- 1444
		local _type_0 = type(req) -- 1444
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1444
		if _tab_0 then -- 1444
			local path -- 1444
			do -- 1444
				local _obj_0 = req.body -- 1444
				local _type_1 = type(_obj_0) -- 1444
				if "table" == _type_1 or "userdata" == _type_1 then -- 1444
					path = _obj_0.path -- 1444
				end -- 1444
			end -- 1444
			if path ~= nil then -- 1444
				local projDir = getWaProjectDirFromFile(path) -- 1445
				if projDir then -- 1445
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 1446
					if not Content:exist(sourceDoraPath) then -- 1447
						return { -- 1448
							success = false, -- 1448
							message = "missing dora template" -- 1448
						} -- 1448
					end -- 1447
					local targetVendorPath = Path(projDir, "vendor") -- 1449
					local targetDoraPath = Path(targetVendorPath, "dora") -- 1450
					if not Content:exist(targetVendorPath) then -- 1451
						if not Content:mkdir(targetVendorPath) then -- 1452
							return { -- 1453
								success = false, -- 1453
								message = "failed to create vendor folder" -- 1453
							} -- 1453
						end -- 1452
					elseif not Content:isdir(targetVendorPath) then -- 1454
						return { -- 1455
							success = false, -- 1455
							message = "vendor path is not a folder" -- 1455
						} -- 1455
					end -- 1451
					if Content:exist(targetDoraPath) then -- 1456
						if not Content:remove(targetDoraPath) then -- 1457
							return { -- 1458
								success = false, -- 1458
								message = "failed to remove old dora" -- 1458
							} -- 1458
						end -- 1457
					end -- 1456
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 1459
						return { -- 1460
							success = false, -- 1460
							message = "failed to copy dora" -- 1460
						} -- 1460
					end -- 1459
					return { -- 1461
						success = true -- 1461
					} -- 1461
				else -- 1463
					return { -- 1463
						success = false, -- 1463
						message = 'Wa file needs a project' -- 1463
					} -- 1463
				end -- 1445
			end -- 1444
		end -- 1444
	end -- 1444
	return { -- 1443
		success = false, -- 1443
		message = "invalid call" -- 1443
	} -- 1443
end) -- 1443
HttpServer:postSchedule("/wa/build", function(req) -- 1465
	do -- 1466
		local _type_0 = type(req) -- 1466
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1466
		if _tab_0 then -- 1466
			local path -- 1466
			do -- 1466
				local _obj_0 = req.body -- 1466
				local _type_1 = type(_obj_0) -- 1466
				if "table" == _type_1 or "userdata" == _type_1 then -- 1466
					path = _obj_0.path -- 1466
				end -- 1466
			end -- 1466
			if path ~= nil then -- 1466
				local projDir = getWaProjectDirFromFile(path) -- 1467
				if projDir then -- 1467
					local message = Wasm:buildWaAsync(projDir) -- 1468
					if message == "" then -- 1469
						return { -- 1470
							success = true -- 1470
						} -- 1470
					else -- 1472
						return { -- 1472
							success = false, -- 1472
							message = message -- 1472
						} -- 1472
					end -- 1469
				else -- 1474
					return { -- 1474
						success = false, -- 1474
						message = 'Wa file needs a project' -- 1474
					} -- 1474
				end -- 1467
			end -- 1466
		end -- 1466
	end -- 1466
	return { -- 1475
		success = false, -- 1475
		message = 'failed to build' -- 1475
	} -- 1475
end) -- 1465
HttpServer:postSchedule("/wa/format", function(req) -- 1477
	do -- 1478
		local _type_0 = type(req) -- 1478
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1478
		if _tab_0 then -- 1478
			local file -- 1478
			do -- 1478
				local _obj_0 = req.body -- 1478
				local _type_1 = type(_obj_0) -- 1478
				if "table" == _type_1 or "userdata" == _type_1 then -- 1478
					file = _obj_0.file -- 1478
				end -- 1478
			end -- 1478
			if file ~= nil then -- 1478
				local code = Wasm:formatWaAsync(file) -- 1479
				if code == "" then -- 1480
					return { -- 1481
						success = false -- 1481
					} -- 1481
				else -- 1483
					return { -- 1483
						success = true, -- 1483
						code = code -- 1483
					} -- 1483
				end -- 1480
			end -- 1478
		end -- 1478
	end -- 1478
	return { -- 1484
		success = false -- 1484
	} -- 1484
end) -- 1477
HttpServer:postSchedule("/wa/create", function(req) -- 1486
	do -- 1487
		local _type_0 = type(req) -- 1487
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1487
		if _tab_0 then -- 1487
			local path -- 1487
			do -- 1487
				local _obj_0 = req.body -- 1487
				local _type_1 = type(_obj_0) -- 1487
				if "table" == _type_1 or "userdata" == _type_1 then -- 1487
					path = _obj_0.path -- 1487
				end -- 1487
			end -- 1487
			if path ~= nil then -- 1487
				if not Content:exist(Path:getPath(path)) then -- 1488
					return { -- 1489
						success = false, -- 1489
						message = "target path not existed" -- 1489
					} -- 1489
				end -- 1488
				if Content:exist(path) then -- 1490
					return { -- 1491
						success = false, -- 1491
						message = "target project folder existed" -- 1491
					} -- 1491
				end -- 1490
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1492
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1493
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1494
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1495
					return { -- 1498
						success = false, -- 1498
						message = "missing template project" -- 1498
					} -- 1498
				end -- 1495
				if not Content:mkdir(path) then -- 1499
					return { -- 1500
						success = false, -- 1500
						message = "failed to create project folder" -- 1500
					} -- 1500
				end -- 1499
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1501
					Content:remove(path) -- 1502
					return { -- 1503
						success = false, -- 1503
						message = "failed to copy template" -- 1503
					} -- 1503
				end -- 1501
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1504
					Content:remove(path) -- 1505
					return { -- 1506
						success = false, -- 1506
						message = "failed to copy template" -- 1506
					} -- 1506
				end -- 1504
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1507
					Content:remove(path) -- 1508
					return { -- 1509
						success = false, -- 1509
						message = "failed to copy template" -- 1509
					} -- 1509
				end -- 1507
				return { -- 1510
					success = true -- 1510
				} -- 1510
			end -- 1487
		end -- 1487
	end -- 1487
	return { -- 1486
		success = false, -- 1486
		message = "invalid call" -- 1486
	} -- 1486
end) -- 1486
local _anon_func_5 = function(path) -- 1519
	local _val_0 = Path:getExt(path) -- 1519
	return "ts" == _val_0 or "tsx" == _val_0 -- 1519
end -- 1519
local _anon_func_6 = function(f) -- 1549
	local _val_0 = Path:getExt(f) -- 1549
	return "ts" == _val_0 or "tsx" == _val_0 -- 1549
end -- 1549
HttpServer:postSchedule("/ts/build", function(req) -- 1512
	do -- 1513
		local _type_0 = type(req) -- 1513
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1513
		if _tab_0 then -- 1513
			local path -- 1513
			do -- 1513
				local _obj_0 = req.body -- 1513
				local _type_1 = type(_obj_0) -- 1513
				if "table" == _type_1 or "userdata" == _type_1 then -- 1513
					path = _obj_0.path -- 1513
				end -- 1513
			end -- 1513
			if path ~= nil then -- 1513
				if HttpServer.wsConnectionCount == 0 then -- 1514
					return { -- 1515
						success = false, -- 1515
						message = "Web IDE not connected" -- 1515
					} -- 1515
				end -- 1514
				if not Content:exist(path) then -- 1516
					return { -- 1517
						success = false, -- 1517
						message = "path not existed" -- 1517
					} -- 1517
				end -- 1516
				if not Content:isdir(path) then -- 1518
					if not (_anon_func_5(path)) then -- 1519
						return { -- 1520
							success = false, -- 1520
							message = "expecting a TypeScript file" -- 1520
						} -- 1520
					end -- 1519
					local messages = { } -- 1521
					local content = Content:load(path) -- 1522
					if not content then -- 1523
						return { -- 1524
							success = false, -- 1524
							message = "failed to read file" -- 1524
						} -- 1524
					end -- 1523
					emit("AppWS", "Send", json.encode({ -- 1525
						name = "UpdateFile", -- 1525
						file = path, -- 1525
						exists = true, -- 1525
						content = content -- 1525
					})) -- 1525
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1526
						local done = false -- 1527
						do -- 1528
							local _with_0 = Node() -- 1528
							_with_0:gslot("AppWS", function(event) -- 1529
								if event.type == "Receive" then -- 1530
									local res = json.decode(event.msg) -- 1531
									if res then -- 1531
										if res.name == "TranspileTS" and res.file == path then -- 1532
											_with_0:removeFromParent() -- 1533
											if res.success then -- 1534
												local luaFile = Path:replaceExt(path, "lua") -- 1535
												Content:save(luaFile, res.luaCode) -- 1536
												messages[#messages + 1] = { -- 1537
													success = true, -- 1537
													file = path -- 1537
												} -- 1537
											else -- 1539
												messages[#messages + 1] = { -- 1539
													success = false, -- 1539
													file = path, -- 1539
													message = res.message -- 1539
												} -- 1539
											end -- 1534
											done = true -- 1540
										end -- 1532
									end -- 1531
								end -- 1530
							end) -- 1529
						end -- 1528
						emit("AppWS", "Send", json.encode({ -- 1541
							name = "TranspileTS", -- 1541
							file = path, -- 1541
							content = content -- 1541
						})) -- 1541
						wait(function() -- 1542
							return done -- 1542
						end) -- 1542
					end -- 1526
					return { -- 1543
						success = true, -- 1543
						messages = messages -- 1543
					} -- 1543
				else -- 1545
					local files = Content:getAllFiles(path) -- 1545
					local fileData = { } -- 1546
					local messages = { } -- 1547
					for _index_0 = 1, #files do -- 1548
						local f = files[_index_0] -- 1548
						if not (_anon_func_6(f)) then -- 1549
							goto _continue_0 -- 1549
						end -- 1549
						local file = Path(path, f) -- 1550
						local content = Content:load(file) -- 1551
						if content then -- 1551
							fileData[file] = content -- 1552
							emit("AppWS", "Send", json.encode({ -- 1553
								name = "UpdateFile", -- 1553
								file = file, -- 1553
								exists = true, -- 1553
								content = content -- 1553
							})) -- 1553
						else -- 1555
							messages[#messages + 1] = { -- 1555
								success = false, -- 1555
								file = file, -- 1555
								message = "failed to read file" -- 1555
							} -- 1555
						end -- 1551
						::_continue_0:: -- 1549
					end -- 1548
					for file, content in pairs(fileData) do -- 1556
						if "d" == Path:getExt(Path:getName(file)) then -- 1557
							goto _continue_1 -- 1557
						end -- 1557
						local done = false -- 1558
						do -- 1559
							local _with_0 = Node() -- 1559
							_with_0:gslot("AppWS", function(event) -- 1560
								if event.type == "Receive" then -- 1561
									local res = json.decode(event.msg) -- 1562
									if res then -- 1562
										if res.name == "TranspileTS" and res.file == file then -- 1563
											_with_0:removeFromParent() -- 1564
											if res.success then -- 1565
												local luaFile = Path:replaceExt(file, "lua") -- 1566
												Content:save(luaFile, res.luaCode) -- 1567
												messages[#messages + 1] = { -- 1568
													success = true, -- 1568
													file = file -- 1568
												} -- 1568
											else -- 1570
												messages[#messages + 1] = { -- 1570
													success = false, -- 1570
													file = file, -- 1570
													message = res.message -- 1570
												} -- 1570
											end -- 1565
											done = true -- 1571
										end -- 1563
									end -- 1562
								end -- 1561
							end) -- 1560
						end -- 1559
						emit("AppWS", "Send", json.encode({ -- 1572
							name = "TranspileTS", -- 1572
							file = file, -- 1572
							content = content -- 1572
						})) -- 1572
						wait(function() -- 1573
							return done -- 1573
						end) -- 1573
						::_continue_1:: -- 1557
					end -- 1556
					return { -- 1574
						success = true, -- 1574
						messages = messages -- 1574
					} -- 1574
				end -- 1518
			end -- 1513
		end -- 1513
	end -- 1513
	return { -- 1512
		success = false -- 1512
	} -- 1512
end) -- 1512
HttpServer:post("/download", function(req) -- 1576
	do -- 1577
		local _type_0 = type(req) -- 1577
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1577
		if _tab_0 then -- 1577
			local url -- 1577
			do -- 1577
				local _obj_0 = req.body -- 1577
				local _type_1 = type(_obj_0) -- 1577
				if "table" == _type_1 or "userdata" == _type_1 then -- 1577
					url = _obj_0.url -- 1577
				end -- 1577
			end -- 1577
			local target -- 1577
			do -- 1577
				local _obj_0 = req.body -- 1577
				local _type_1 = type(_obj_0) -- 1577
				if "table" == _type_1 or "userdata" == _type_1 then -- 1577
					target = _obj_0.target -- 1577
				end -- 1577
			end -- 1577
			if url ~= nil and target ~= nil then -- 1577
				local Entry = require("Script.Dev.Entry") -- 1578
				Entry.downloadFile(url, target) -- 1579
				return { -- 1580
					success = true -- 1580
				} -- 1580
			end -- 1577
		end -- 1577
	end -- 1577
	return { -- 1576
		success = false -- 1576
	} -- 1576
end) -- 1576
local status = { } -- 1582
_module_0 = status -- 1583
status.buildAsync = function(path) -- 1585
	if not Content:exist(path) then -- 1586
		return { -- 1587
			success = false, -- 1587
			file = path, -- 1587
			message = "file not existed" -- 1587
		} -- 1587
	end -- 1586
	do -- 1588
		local _exp_0 = Path:getExt(path) -- 1588
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1588
			if '' == Path:getExt(Path:getName(path)) then -- 1589
				local content = Content:loadAsync(path) -- 1590
				if content then -- 1590
					local resultCodes, err = compileFileAsync(path, content) -- 1591
					if resultCodes then -- 1591
						return { -- 1592
							success = true, -- 1592
							file = path -- 1592
						} -- 1592
					else -- 1594
						return { -- 1594
							success = false, -- 1594
							file = path, -- 1594
							message = err -- 1594
						} -- 1594
					end -- 1591
				end -- 1590
			end -- 1589
		elseif "lua" == _exp_0 then -- 1595
			local content = Content:loadAsync(path) -- 1596
			if content then -- 1596
				do -- 1597
					local isTIC80 = CheckTIC80Code(content) -- 1597
					if isTIC80 then -- 1597
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1598
					end -- 1597
				end -- 1597
				local success, info -- 1599
				do -- 1599
					local _obj_0 = luaCheck(path, content) -- 1599
					success, info = _obj_0.success, _obj_0.info -- 1599
				end -- 1599
				if success then -- 1600
					return { -- 1601
						success = true, -- 1601
						file = path -- 1601
					} -- 1601
				elseif info and #info > 0 then -- 1602
					local messages = { } -- 1603
					for _index_0 = 1, #info do -- 1604
						local _des_0 = info[_index_0] -- 1604
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 1604
						local lineText = "" -- 1605
						if line then -- 1606
							local currentLine = 1 -- 1607
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1608
								if currentLine == line then -- 1609
									lineText = text -- 1610
									break -- 1611
								end -- 1609
								currentLine = currentLine + 1 -- 1612
							end -- 1608
						end -- 1606
						if line then -- 1613
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1614
						else -- 1616
							messages[#messages + 1] = message -- 1616
						end -- 1613
					end -- 1604
					return { -- 1617
						success = false, -- 1617
						file = path, -- 1617
						message = table.concat(messages, "\n") -- 1617
					} -- 1617
				else -- 1619
					return { -- 1619
						success = false, -- 1619
						file = path, -- 1619
						message = "lua check failed" -- 1619
					} -- 1619
				end -- 1600
			end -- 1596
		elseif "yarn" == _exp_0 then -- 1620
			local content = Content:loadAsync(path) -- 1621
			if content then -- 1621
				local res, _, err = yarncompile(content, true) -- 1622
				if res then -- 1622
					return { -- 1623
						success = true, -- 1623
						file = path -- 1623
					} -- 1623
				else -- 1625
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1625
					local lineText = "" -- 1626
					if line then -- 1627
						local currentLine = 1 -- 1628
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1629
							if currentLine == line then -- 1630
								lineText = text -- 1631
								break -- 1632
							end -- 1630
							currentLine = currentLine + 1 -- 1633
						end -- 1629
					end -- 1627
					if node ~= "" then -- 1634
						node = "node: " .. tostring(node) .. ", " -- 1635
					else -- 1636
						node = "" -- 1636
					end -- 1634
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1637
					return { -- 1638
						success = false, -- 1638
						file = path, -- 1638
						message = message -- 1638
					} -- 1638
				end -- 1622
			end -- 1621
		end -- 1588
	end -- 1588
	return { -- 1639
		success = false, -- 1639
		file = path, -- 1639
		message = "invalid file to build" -- 1639
	} -- 1639
end -- 1585
thread(function() -- 1641
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1642
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1643
	if Content:exist(doraWeb) then -- 1644
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 1645
		local needReload -- 1646
		if Content:exist(doraReady) then -- 1646
			needReload = readyContent ~= Content:load(doraReady) -- 1647
		else -- 1648
			needReload = true -- 1648
		end -- 1646
		if needReload then -- 1649
			Content:remove(Path(Content.appPath, ".www")) -- 1650
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1651
			Content:save(doraReady, readyContent) -- 1655
			print("Dora Dora is ready!") -- 1656
		end -- 1649
	end -- 1644
	if HttpServer:start(8866) then -- 1657
		local localIP = HttpServer.localIP -- 1658
		if localIP == "" then -- 1659
			localIP = "localhost" -- 1659
		end -- 1659
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1660
		return HttpServer:startWS(8868) -- 1661
	else -- 1663
		status.url = nil -- 1663
		return print("8866 Port not available!") -- 1664
	end -- 1657
end) -- 1641
return _module_0 -- 1
