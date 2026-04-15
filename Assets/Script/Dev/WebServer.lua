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
					pendingMergeCount = res.pendingMergeCount, -- 158
					pendingMergeJobs = res.pendingMergeJobs, -- 159
					spawnInfo = res.spawnInfo, -- 160
					messages = res.messages, -- 161
					steps = res.steps, -- 162
					checkpoints = checkpoints -- 163
				} -- 154
			end -- 149
		end -- 149
	end -- 149
	return invalidArguments -- 148
end) -- 148
HttpServer:post("/agent/task/running", function() -- 165
	return AgentSession.listRunningSessions() -- 165
end) -- 165
HttpServer:post("/agent/task/stop", function(req) -- 167
	do -- 168
		local _type_0 = type(req) -- 168
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 168
		if _tab_0 then -- 168
			local sessionId -- 168
			do -- 168
				local _obj_0 = req.body -- 168
				local _type_1 = type(_obj_0) -- 168
				if "table" == _type_1 or "userdata" == _type_1 then -- 168
					sessionId = _obj_0.sessionId -- 168
				end -- 168
			end -- 168
			if sessionId ~= nil then -- 168
				return AgentSession.stopSessionTask(sessionId) -- 169
			end -- 168
		end -- 168
	end -- 168
	return invalidArguments -- 167
end) -- 167
HttpServer:post("/agent/checkpoint/list", function(req) -- 171
	do -- 172
		local _type_0 = type(req) -- 172
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 172
		if _tab_0 then -- 172
			local taskId -- 172
			do -- 172
				local _obj_0 = req.body -- 172
				local _type_1 = type(_obj_0) -- 172
				if "table" == _type_1 or "userdata" == _type_1 then -- 172
					taskId = _obj_0.taskId -- 172
				end -- 172
			end -- 172
			local sessionId -- 172
			do -- 172
				local _obj_0 = req.body -- 172
				local _type_1 = type(_obj_0) -- 172
				if "table" == _type_1 or "userdata" == _type_1 then -- 172
					sessionId = _obj_0.sessionId -- 172
				end -- 172
			end -- 172
			if sessionId ~= nil then -- 172
				if not taskId and sessionId then -- 173
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 174
				end -- 173
				if not taskId then -- 175
					return { -- 175
						success = false, -- 175
						message = "task not found" -- 175
					} -- 175
				end -- 175
				return { -- 177
					success = true, -- 177
					taskId = taskId, -- 178
					checkpoints = AgentTools.listCheckpoints(taskId) -- 179
				} -- 176
			end -- 172
		end -- 172
	end -- 172
	return invalidArguments -- 171
end) -- 171
HttpServer:post("/agent/checkpoint/diff", function(req) -- 181
	do -- 182
		local _type_0 = type(req) -- 182
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 182
		if _tab_0 then -- 182
			local checkpointId -- 182
			do -- 182
				local _obj_0 = req.body -- 182
				local _type_1 = type(_obj_0) -- 182
				if "table" == _type_1 or "userdata" == _type_1 then -- 182
					checkpointId = _obj_0.checkpointId -- 182
				end -- 182
			end -- 182
			if checkpointId ~= nil then -- 182
				if not (checkpointId > 0) then -- 183
					return { -- 183
						success = false, -- 183
						message = "invalid checkpointId" -- 183
					} -- 183
				end -- 183
				return AgentTools.getCheckpointDiff(checkpointId) -- 184
			end -- 182
		end -- 182
	end -- 182
	return invalidArguments -- 181
end) -- 181
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 186
	do -- 187
		local _type_0 = type(req) -- 187
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 187
		if _tab_0 then -- 187
			local sessionId -- 187
			do -- 187
				local _obj_0 = req.body -- 187
				local _type_1 = type(_obj_0) -- 187
				if "table" == _type_1 or "userdata" == _type_1 then -- 187
					sessionId = _obj_0.sessionId -- 187
				end -- 187
			end -- 187
			local checkpointId -- 187
			do -- 187
				local _obj_0 = req.body -- 187
				local _type_1 = type(_obj_0) -- 187
				if "table" == _type_1 or "userdata" == _type_1 then -- 187
					checkpointId = _obj_0.checkpointId -- 187
				end -- 187
			end -- 187
			if sessionId ~= nil and checkpointId ~= nil then -- 187
				if not (checkpointId > 0) then -- 188
					return { -- 188
						success = false, -- 188
						message = "invalid checkpointId" -- 188
					} -- 188
				end -- 188
				local res = AgentSession.getSession(sessionId) -- 189
				if not res.success then -- 190
					return res -- 190
				end -- 190
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, res.session.projectRoot) -- 191
				if not rollbackRes.success then -- 192
					return rollbackRes -- 192
				end -- 192
				return { -- 194
					success = true, -- 194
					checkpointId = rollbackRes.checkpointId -- 195
				} -- 193
			end -- 187
		end -- 187
	end -- 187
	return invalidArguments -- 186
end) -- 186
local getSearchPath -- 197
getSearchPath = function(file) -- 197
	do -- 198
		local dir = getProjectDirFromFile(file) -- 198
		if dir then -- 198
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 199
		end -- 198
	end -- 198
	return "" -- 197
end -- 197
local getSearchFolders -- 201
getSearchFolders = function(file) -- 201
	do -- 202
		local dir = getProjectDirFromFile(file) -- 202
		if dir then -- 202
			return { -- 204
				Path(dir, "Script"), -- 204
				dir -- 205
			} -- 203
		end -- 202
	end -- 202
	return { } -- 201
end -- 201
local disabledCheckForLua = { -- 208
	"incompatible number of returns", -- 208
	"unknown", -- 209
	"cannot index", -- 210
	"module not found", -- 211
	"don't know how to resolve", -- 212
	"ContainerItem", -- 213
	"cannot resolve a type", -- 214
	"invalid key", -- 215
	"inconsistent index type", -- 216
	"cannot use operator", -- 217
	"attempting ipairs loop", -- 218
	"expects record or nominal", -- 219
	"variable is not being assigned", -- 220
	"<invalid type>", -- 221
	"<any type>", -- 222
	"using the '#' operator", -- 223
	"can't match a record", -- 224
	"redeclaration of variable", -- 225
	"cannot apply pairs", -- 226
	"not a function", -- 227
	"to%-be%-closed" -- 228
} -- 207
local yueCheck -- 230
yueCheck = function(file, content, lax) -- 230
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 231
	if isTIC80 then -- 232
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 233
	end -- 232
	local searchPath = getSearchPath(file) -- 234
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 235
	local info = { } -- 236
	local globals = { } -- 237
	for _index_0 = 1, #checkResult do -- 238
		local _des_0 = checkResult[_index_0] -- 238
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 238
		if "error" == t then -- 239
			info[#info + 1] = { -- 240
				"syntax", -- 240
				file, -- 240
				line, -- 240
				col, -- 240
				msg -- 240
			} -- 240
		elseif "global" == t then -- 241
			globals[#globals + 1] = { -- 242
				msg, -- 242
				line, -- 242
				col -- 242
			} -- 242
		end -- 239
	end -- 238
	if luaCodes then -- 243
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 244
		if success then -- 245
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 246
			if not (lintResult == "") then -- 247
				lintResult = lintResult .. "\n" -- 247
			end -- 247
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 248
		else -- 249
			for _index_0 = 1, #lintResult do -- 249
				local _des_0 = lintResult[_index_0] -- 249
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 249
				if isTIC80 and tic80APIs[name] then -- 250
					goto _continue_0 -- 250
				end -- 250
				info[#info + 1] = { -- 251
					"syntax", -- 251
					file, -- 251
					line, -- 251
					col, -- 251
					"invalid global variable" -- 251
				} -- 251
				::_continue_0:: -- 250
			end -- 249
		end -- 245
	end -- 243
	return luaCodes, info -- 252
end -- 230
local luaCheck -- 254
luaCheck = function(file, content) -- 254
	local res, err = load(content, "check") -- 255
	if not res then -- 256
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 257
		return { -- 258
			success = false, -- 258
			info = { -- 258
				{ -- 258
					"syntax", -- 258
					file, -- 258
					tonumber(line), -- 258
					0, -- 258
					msg -- 258
				} -- 258
			} -- 258
		} -- 258
	end -- 256
	local success, info = teal.checkAsync(content, file, true, "") -- 259
	if info then -- 260
		do -- 261
			local _accum_0 = { } -- 261
			local _len_0 = 1 -- 261
			for _index_0 = 1, #info do -- 261
				local item = info[_index_0] -- 261
				local useCheck = true -- 262
				if not item[5]:match("unused") then -- 263
					for _index_1 = 1, #disabledCheckForLua do -- 264
						local check = disabledCheckForLua[_index_1] -- 264
						if item[5]:match(check) then -- 265
							useCheck = false -- 266
						end -- 265
					end -- 264
				end -- 263
				if not useCheck then -- 267
					goto _continue_0 -- 267
				end -- 267
				do -- 268
					local _exp_0 = item[1] -- 268
					if "type" == _exp_0 then -- 269
						item[1] = "warning" -- 270
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 271
						goto _continue_0 -- 272
					end -- 268
				end -- 268
				_accum_0[_len_0] = item -- 273
				_len_0 = _len_0 + 1 -- 262
				::_continue_0:: -- 262
			end -- 261
			info = _accum_0 -- 261
		end -- 261
		if #info == 0 then -- 274
			info = nil -- 275
			success = true -- 276
		end -- 274
	end -- 260
	return { -- 277
		success = success, -- 277
		info = info -- 277
	} -- 277
end -- 254
local luaCheckWithLineInfo -- 279
luaCheckWithLineInfo = function(file, luaCodes) -- 279
	local res = luaCheck(file, luaCodes) -- 280
	local info = { } -- 281
	if not res.success then -- 282
		local current = 1 -- 283
		local lastLine = 1 -- 284
		local lineMap = { } -- 285
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 286
			local num = lineCode:match("--%s*(%d+)%s*$") -- 287
			if num then -- 288
				lastLine = tonumber(num) -- 289
			end -- 288
			lineMap[current] = lastLine -- 290
			current = current + 1 -- 291
		end -- 286
		local _list_0 = res.info -- 292
		for _index_0 = 1, #_list_0 do -- 292
			local item = _list_0[_index_0] -- 292
			item[3] = lineMap[item[3]] or 0 -- 293
			item[4] = 0 -- 294
			info[#info + 1] = item -- 295
		end -- 292
		return false, info -- 296
	end -- 282
	return true, info -- 297
end -- 279
local getCompiledYueLine -- 299
getCompiledYueLine = function(content, line, row, file, lax) -- 299
	local luaCodes = yueCheck(file, content, lax) -- 300
	if not luaCodes then -- 301
		return nil -- 301
	end -- 301
	local current = 1 -- 302
	local lastLine = 1 -- 303
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 304
	local targetRow = nil -- 305
	local lineMap = { } -- 306
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 307
		local num = lineCode:match("--%s*(%d+)%s*$") -- 308
		if num then -- 309
			lastLine = tonumber(num) -- 309
		end -- 309
		lineMap[current] = lastLine -- 310
		if row <= lastLine and not targetRow then -- 311
			targetRow = current -- 312
			break -- 313
		end -- 311
		current = current + 1 -- 314
	end -- 307
	targetRow = current -- 315
	if targetLine and targetRow then -- 316
		return luaCodes, targetLine, targetRow, lineMap -- 317
	else -- 319
		return nil -- 319
	end -- 316
end -- 299
HttpServer:postSchedule("/check", function(req) -- 321
	do -- 322
		local _type_0 = type(req) -- 322
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 322
		if _tab_0 then -- 322
			local file -- 322
			do -- 322
				local _obj_0 = req.body -- 322
				local _type_1 = type(_obj_0) -- 322
				if "table" == _type_1 or "userdata" == _type_1 then -- 322
					file = _obj_0.file -- 322
				end -- 322
			end -- 322
			local content -- 322
			do -- 322
				local _obj_0 = req.body -- 322
				local _type_1 = type(_obj_0) -- 322
				if "table" == _type_1 or "userdata" == _type_1 then -- 322
					content = _obj_0.content -- 322
				end -- 322
			end -- 322
			if file ~= nil and content ~= nil then -- 322
				local ext = Path:getExt(file) -- 323
				if "tl" == ext then -- 324
					local searchPath = getSearchPath(file) -- 325
					do -- 326
						local isTIC80 = CheckTIC80Code(content) -- 326
						if isTIC80 then -- 326
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 327
						end -- 326
					end -- 326
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 328
					return { -- 329
						success = success, -- 329
						info = info -- 329
					} -- 329
				elseif "lua" == ext then -- 330
					do -- 331
						local isTIC80 = CheckTIC80Code(content) -- 331
						if isTIC80 then -- 331
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 332
						end -- 331
					end -- 331
					return luaCheck(file, content) -- 333
				elseif "yue" == ext then -- 334
					local luaCodes, info = yueCheck(file, content, false) -- 335
					local success = false -- 336
					if luaCodes then -- 337
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 338
						do -- 339
							local _tab_1 = { } -- 339
							local _idx_0 = #_tab_1 + 1 -- 339
							for _index_0 = 1, #info do -- 339
								local _value_0 = info[_index_0] -- 339
								_tab_1[_idx_0] = _value_0 -- 339
								_idx_0 = _idx_0 + 1 -- 339
							end -- 339
							local _idx_1 = #_tab_1 + 1 -- 339
							for _index_0 = 1, #luaInfo do -- 339
								local _value_0 = luaInfo[_index_0] -- 339
								_tab_1[_idx_1] = _value_0 -- 339
								_idx_1 = _idx_1 + 1 -- 339
							end -- 339
							info = _tab_1 -- 339
						end -- 339
						success = success and luaSuccess -- 340
					end -- 337
					if #info > 0 then -- 341
						return { -- 342
							success = success, -- 342
							info = info -- 342
						} -- 342
					else -- 344
						return { -- 344
							success = success -- 344
						} -- 344
					end -- 341
				elseif "xml" == ext then -- 345
					local success, result = xml.check(content) -- 346
					if success then -- 347
						local info -- 348
						success, info = luaCheckWithLineInfo(file, result) -- 348
						if #info > 0 then -- 349
							return { -- 350
								success = success, -- 350
								info = info -- 350
							} -- 350
						else -- 352
							return { -- 352
								success = success -- 352
							} -- 352
						end -- 349
					else -- 354
						local info -- 354
						do -- 354
							local _accum_0 = { } -- 354
							local _len_0 = 1 -- 354
							for _index_0 = 1, #result do -- 354
								local _des_0 = result[_index_0] -- 354
								local row, err = _des_0[1], _des_0[2] -- 354
								_accum_0[_len_0] = { -- 355
									"syntax", -- 355
									file, -- 355
									row, -- 355
									0, -- 355
									err -- 355
								} -- 355
								_len_0 = _len_0 + 1 -- 355
							end -- 354
							info = _accum_0 -- 354
						end -- 354
						return { -- 356
							success = false, -- 356
							info = info -- 356
						} -- 356
					end -- 347
				end -- 324
			end -- 322
		end -- 322
	end -- 322
	return { -- 321
		success = true -- 321
	} -- 321
end) -- 321
local updateInferedDesc -- 358
updateInferedDesc = function(infered) -- 358
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 359
		return -- 359
	end -- 359
	local key, row = infered.key, infered.row -- 360
	local codes = Content:loadAsync(key) -- 361
	if codes then -- 361
		local comments = { } -- 362
		local line = 0 -- 363
		local skipping = false -- 364
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 365
			line = line + 1 -- 366
			if line >= row then -- 367
				break -- 367
			end -- 367
			if lineCode:match("^%s*%-%- @") then -- 368
				skipping = true -- 369
				goto _continue_0 -- 370
			end -- 368
			local result = lineCode:match("^%s*%-%- (.+)") -- 371
			if result then -- 371
				if not skipping then -- 372
					comments[#comments + 1] = result -- 372
				end -- 372
			elseif #comments > 0 then -- 373
				comments = { } -- 374
				skipping = false -- 375
			end -- 371
			::_continue_0:: -- 366
		end -- 365
		infered.doc = table.concat(comments, "\n") -- 376
	end -- 361
end -- 358
HttpServer:postSchedule("/infer", function(req) -- 378
	do -- 379
		local _type_0 = type(req) -- 379
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 379
		if _tab_0 then -- 379
			local lang -- 379
			do -- 379
				local _obj_0 = req.body -- 379
				local _type_1 = type(_obj_0) -- 379
				if "table" == _type_1 or "userdata" == _type_1 then -- 379
					lang = _obj_0.lang -- 379
				end -- 379
			end -- 379
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
			local line -- 379
			do -- 379
				local _obj_0 = req.body -- 379
				local _type_1 = type(_obj_0) -- 379
				if "table" == _type_1 or "userdata" == _type_1 then -- 379
					line = _obj_0.line -- 379
				end -- 379
			end -- 379
			local row -- 379
			do -- 379
				local _obj_0 = req.body -- 379
				local _type_1 = type(_obj_0) -- 379
				if "table" == _type_1 or "userdata" == _type_1 then -- 379
					row = _obj_0.row -- 379
				end -- 379
			end -- 379
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 379
				local searchPath = getSearchPath(file) -- 380
				if "tl" == lang or "lua" == lang then -- 381
					if CheckTIC80Code(content) then -- 382
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 383
					end -- 382
					local infered = teal.inferAsync(content, line, row, searchPath) -- 384
					if (infered ~= nil) then -- 385
						updateInferedDesc(infered) -- 386
						return { -- 387
							success = true, -- 387
							infered = infered -- 387
						} -- 387
					end -- 385
				elseif "yue" == lang then -- 388
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 389
					if not luaCodes then -- 390
						return { -- 390
							success = false -- 390
						} -- 390
					end -- 390
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 391
					if (infered ~= nil) then -- 392
						local col -- 393
						file, row, col = infered.file, infered.row, infered.col -- 393
						if file == "" and row > 0 and col > 0 then -- 394
							infered.row = lineMap[row] or 0 -- 395
							infered.col = 0 -- 396
						end -- 394
						updateInferedDesc(infered) -- 397
						return { -- 398
							success = true, -- 398
							infered = infered -- 398
						} -- 398
					end -- 392
				end -- 381
			end -- 379
		end -- 379
	end -- 379
	return { -- 378
		success = false -- 378
	} -- 378
end) -- 378
local _anon_func_2 = function(doc) -- 449
	local _accum_0 = { } -- 449
	local _len_0 = 1 -- 449
	local _list_0 = doc.params -- 449
	for _index_0 = 1, #_list_0 do -- 449
		local param = _list_0[_index_0] -- 449
		_accum_0[_len_0] = param.name -- 449
		_len_0 = _len_0 + 1 -- 449
	end -- 449
	return _accum_0 -- 449
end -- 449
local getParamDocs -- 400
getParamDocs = function(signatures) -- 400
	do -- 401
		local codes = Content:loadAsync(signatures[1].file) -- 401
		if codes then -- 401
			local comments = { } -- 402
			local params = { } -- 403
			local line = 0 -- 404
			local docs = { } -- 405
			local returnType = nil -- 406
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 407
				line = line + 1 -- 408
				local needBreak = true -- 409
				for i, _des_0 in ipairs(signatures) do -- 410
					local row = _des_0.row -- 410
					if line >= row and not (docs[i] ~= nil) then -- 411
						if #comments > 0 or #params > 0 or returnType then -- 412
							docs[i] = { -- 414
								doc = table.concat(comments, "  \n"), -- 414
								returnType = returnType -- 415
							} -- 413
							if #params > 0 then -- 417
								docs[i].params = params -- 417
							end -- 417
						else -- 419
							docs[i] = false -- 419
						end -- 412
					end -- 411
					if not docs[i] then -- 420
						needBreak = false -- 420
					end -- 420
				end -- 410
				if needBreak then -- 421
					break -- 421
				end -- 421
				local result = lineCode:match("%s*%-%- (.+)") -- 422
				if result then -- 422
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 423
					if not name then -- 424
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 425
					end -- 424
					if name then -- 426
						local pname = name -- 427
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 428
							pname = pname .. "?" -- 428
						end -- 428
						params[#params + 1] = { -- 430
							name = tostring(pname) .. ": " .. tostring(typ), -- 430
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 431
						} -- 429
					else -- 434
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 434
						if typ then -- 434
							if returnType then -- 435
								returnType = returnType .. ", " .. typ -- 436
							else -- 438
								returnType = typ -- 438
							end -- 435
							result = result:gsub("@return", "**return:**") -- 439
						end -- 434
						comments[#comments + 1] = result -- 440
					end -- 426
				elseif #comments > 0 then -- 441
					comments = { } -- 442
					params = { } -- 443
					returnType = nil -- 444
				end -- 422
			end -- 407
			local results = { } -- 445
			for _index_0 = 1, #docs do -- 446
				local doc = docs[_index_0] -- 446
				if not doc then -- 447
					goto _continue_0 -- 447
				end -- 447
				if doc.params then -- 448
					doc.desc = "function(" .. tostring(table.concat(_anon_func_2(doc), ', ')) .. ")" -- 449
				else -- 451
					doc.desc = "function()" -- 451
				end -- 448
				if doc.returnType then -- 452
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 453
					doc.returnType = nil -- 454
				end -- 452
				results[#results + 1] = doc -- 455
				::_continue_0:: -- 447
			end -- 446
			if #results > 0 then -- 456
				return results -- 456
			else -- 456
				return nil -- 456
			end -- 456
		end -- 401
	end -- 401
	return nil -- 400
end -- 400
HttpServer:postSchedule("/signature", function(req) -- 458
	do -- 459
		local _type_0 = type(req) -- 459
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 459
		if _tab_0 then -- 459
			local lang -- 459
			do -- 459
				local _obj_0 = req.body -- 459
				local _type_1 = type(_obj_0) -- 459
				if "table" == _type_1 or "userdata" == _type_1 then -- 459
					lang = _obj_0.lang -- 459
				end -- 459
			end -- 459
			local file -- 459
			do -- 459
				local _obj_0 = req.body -- 459
				local _type_1 = type(_obj_0) -- 459
				if "table" == _type_1 or "userdata" == _type_1 then -- 459
					file = _obj_0.file -- 459
				end -- 459
			end -- 459
			local content -- 459
			do -- 459
				local _obj_0 = req.body -- 459
				local _type_1 = type(_obj_0) -- 459
				if "table" == _type_1 or "userdata" == _type_1 then -- 459
					content = _obj_0.content -- 459
				end -- 459
			end -- 459
			local line -- 459
			do -- 459
				local _obj_0 = req.body -- 459
				local _type_1 = type(_obj_0) -- 459
				if "table" == _type_1 or "userdata" == _type_1 then -- 459
					line = _obj_0.line -- 459
				end -- 459
			end -- 459
			local row -- 459
			do -- 459
				local _obj_0 = req.body -- 459
				local _type_1 = type(_obj_0) -- 459
				if "table" == _type_1 or "userdata" == _type_1 then -- 459
					row = _obj_0.row -- 459
				end -- 459
			end -- 459
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 459
				local searchPath = getSearchPath(file) -- 460
				if "tl" == lang or "lua" == lang then -- 461
					if CheckTIC80Code(content) then -- 462
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 463
					end -- 462
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 464
					if signatures then -- 464
						signatures = getParamDocs(signatures) -- 465
						if signatures then -- 465
							return { -- 466
								success = true, -- 466
								signatures = signatures -- 466
							} -- 466
						end -- 465
					end -- 464
				elseif "yue" == lang then -- 467
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 468
					if not luaCodes then -- 469
						return { -- 469
							success = false -- 469
						} -- 469
					end -- 469
					do -- 470
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 470
						if chainOp then -- 470
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 471
							if withVar then -- 471
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 472
							end -- 471
						end -- 470
					end -- 470
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 473
					if signatures then -- 473
						signatures = getParamDocs(signatures) -- 474
						if signatures then -- 474
							return { -- 475
								success = true, -- 475
								signatures = signatures -- 475
							} -- 475
						end -- 474
					else -- 476
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 476
						if signatures then -- 476
							signatures = getParamDocs(signatures) -- 477
							if signatures then -- 477
								return { -- 478
									success = true, -- 478
									signatures = signatures -- 478
								} -- 478
							end -- 477
						end -- 476
					end -- 473
				end -- 461
			end -- 459
		end -- 459
	end -- 459
	return { -- 458
		success = false -- 458
	} -- 458
end) -- 458
local luaKeywords = { -- 481
	'and', -- 481
	'break', -- 482
	'do', -- 483
	'else', -- 484
	'elseif', -- 485
	'end', -- 486
	'false', -- 487
	'for', -- 488
	'function', -- 489
	'goto', -- 490
	'if', -- 491
	'in', -- 492
	'local', -- 493
	'nil', -- 494
	'not', -- 495
	'or', -- 496
	'repeat', -- 497
	'return', -- 498
	'then', -- 499
	'true', -- 500
	'until', -- 501
	'while' -- 502
} -- 480
local tealKeywords = { -- 506
	'record', -- 506
	'as', -- 507
	'is', -- 508
	'type', -- 509
	'embed', -- 510
	'enum', -- 511
	'global', -- 512
	'any', -- 513
	'boolean', -- 514
	'integer', -- 515
	'number', -- 516
	'string', -- 517
	'thread' -- 518
} -- 505
local yueKeywords = { -- 522
	"and", -- 522
	"break", -- 523
	"do", -- 524
	"else", -- 525
	"elseif", -- 526
	"false", -- 527
	"for", -- 528
	"goto", -- 529
	"if", -- 530
	"in", -- 531
	"local", -- 532
	"nil", -- 533
	"not", -- 534
	"or", -- 535
	"repeat", -- 536
	"return", -- 537
	"then", -- 538
	"true", -- 539
	"until", -- 540
	"while", -- 541
	"as", -- 542
	"class", -- 543
	"continue", -- 544
	"export", -- 545
	"extends", -- 546
	"from", -- 547
	"global", -- 548
	"import", -- 549
	"macro", -- 550
	"switch", -- 551
	"try", -- 552
	"unless", -- 553
	"using", -- 554
	"when", -- 555
	"with" -- 556
} -- 521
local _anon_func_3 = function(f) -- 592
	local _val_0 = Path:getExt(f) -- 592
	return "ttf" == _val_0 or "otf" == _val_0 -- 592
end -- 592
local _anon_func_4 = function(suggestions) -- 618
	local _tbl_0 = { } -- 618
	for _index_0 = 1, #suggestions do -- 618
		local item = suggestions[_index_0] -- 618
		_tbl_0[item[1] .. item[2]] = item -- 618
	end -- 618
	return _tbl_0 -- 618
end -- 618
HttpServer:postSchedule("/complete", function(req) -- 559
	do -- 560
		local _type_0 = type(req) -- 560
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 560
		if _tab_0 then -- 560
			local lang -- 560
			do -- 560
				local _obj_0 = req.body -- 560
				local _type_1 = type(_obj_0) -- 560
				if "table" == _type_1 or "userdata" == _type_1 then -- 560
					lang = _obj_0.lang -- 560
				end -- 560
			end -- 560
			local file -- 560
			do -- 560
				local _obj_0 = req.body -- 560
				local _type_1 = type(_obj_0) -- 560
				if "table" == _type_1 or "userdata" == _type_1 then -- 560
					file = _obj_0.file -- 560
				end -- 560
			end -- 560
			local content -- 560
			do -- 560
				local _obj_0 = req.body -- 560
				local _type_1 = type(_obj_0) -- 560
				if "table" == _type_1 or "userdata" == _type_1 then -- 560
					content = _obj_0.content -- 560
				end -- 560
			end -- 560
			local line -- 560
			do -- 560
				local _obj_0 = req.body -- 560
				local _type_1 = type(_obj_0) -- 560
				if "table" == _type_1 or "userdata" == _type_1 then -- 560
					line = _obj_0.line -- 560
				end -- 560
			end -- 560
			local row -- 560
			do -- 560
				local _obj_0 = req.body -- 560
				local _type_1 = type(_obj_0) -- 560
				if "table" == _type_1 or "userdata" == _type_1 then -- 560
					row = _obj_0.row -- 560
				end -- 560
			end -- 560
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 560
				local searchPath = getSearchPath(file) -- 561
				repeat -- 562
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 563
					if lang == "yue" then -- 564
						if not item then -- 565
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 565
						end -- 565
						if not item then -- 566
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 566
						end -- 566
					end -- 564
					local searchType = nil -- 567
					if not item then -- 568
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 569
						if lang == "yue" then -- 570
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 571
						end -- 570
						if (item ~= nil) then -- 572
							searchType = "Image" -- 572
						end -- 572
					end -- 568
					if not item then -- 573
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 574
						if lang == "yue" then -- 575
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 576
						end -- 575
						if (item ~= nil) then -- 577
							searchType = "Font" -- 577
						end -- 577
					end -- 573
					if not item then -- 578
						break -- 578
					end -- 578
					local searchPaths = Content.searchPaths -- 579
					local _list_0 = getSearchFolders(file) -- 580
					for _index_0 = 1, #_list_0 do -- 580
						local folder = _list_0[_index_0] -- 580
						searchPaths[#searchPaths + 1] = folder -- 581
					end -- 580
					if searchType then -- 582
						searchPaths[#searchPaths + 1] = Content.assetPath -- 582
					end -- 582
					local tokens -- 583
					do -- 583
						local _accum_0 = { } -- 583
						local _len_0 = 1 -- 583
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 583
							_accum_0[_len_0] = mod -- 583
							_len_0 = _len_0 + 1 -- 583
						end -- 583
						tokens = _accum_0 -- 583
					end -- 583
					local suggestions = { } -- 584
					for _index_0 = 1, #searchPaths do -- 585
						local path = searchPaths[_index_0] -- 585
						local sPath = Path(path, table.unpack(tokens)) -- 586
						if not Content:exist(sPath) then -- 587
							goto _continue_0 -- 587
						end -- 587
						if searchType == "Font" then -- 588
							local fontPath = Path(sPath, "Font") -- 589
							if Content:exist(fontPath) then -- 590
								local _list_1 = Content:getFiles(fontPath) -- 591
								for _index_1 = 1, #_list_1 do -- 591
									local f = _list_1[_index_1] -- 591
									if _anon_func_3(f) then -- 592
										if "." == f:sub(1, 1) then -- 593
											goto _continue_1 -- 593
										end -- 593
										suggestions[#suggestions + 1] = { -- 594
											Path:getName(f), -- 594
											"font", -- 594
											"field" -- 594
										} -- 594
									end -- 592
									::_continue_1:: -- 592
								end -- 591
							end -- 590
						end -- 588
						local _list_1 = Content:getFiles(sPath) -- 595
						for _index_1 = 1, #_list_1 do -- 595
							local f = _list_1[_index_1] -- 595
							if "Image" == searchType then -- 596
								do -- 597
									local _exp_0 = Path:getExt(f) -- 597
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 597
										if "." == f:sub(1, 1) then -- 598
											goto _continue_2 -- 598
										end -- 598
										suggestions[#suggestions + 1] = { -- 599
											f, -- 599
											"image", -- 599
											"field" -- 599
										} -- 599
									end -- 597
								end -- 597
								goto _continue_2 -- 600
							elseif "Font" == searchType then -- 601
								do -- 602
									local _exp_0 = Path:getExt(f) -- 602
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 602
										if "." == f:sub(1, 1) then -- 603
											goto _continue_2 -- 603
										end -- 603
										suggestions[#suggestions + 1] = { -- 604
											f, -- 604
											"font", -- 604
											"field" -- 604
										} -- 604
									end -- 602
								end -- 602
								goto _continue_2 -- 605
							end -- 596
							local _exp_0 = Path:getExt(f) -- 606
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 606
								local name = Path:getName(f) -- 607
								if "d" == Path:getExt(name) then -- 608
									goto _continue_2 -- 608
								end -- 608
								if "." == name:sub(1, 1) then -- 609
									goto _continue_2 -- 609
								end -- 609
								suggestions[#suggestions + 1] = { -- 610
									name, -- 610
									"module", -- 610
									"field" -- 610
								} -- 610
							end -- 606
							::_continue_2:: -- 596
						end -- 595
						local _list_2 = Content:getDirs(sPath) -- 611
						for _index_1 = 1, #_list_2 do -- 611
							local dir = _list_2[_index_1] -- 611
							if "." == dir:sub(1, 1) then -- 612
								goto _continue_3 -- 612
							end -- 612
							suggestions[#suggestions + 1] = { -- 613
								dir, -- 613
								"folder", -- 613
								"variable" -- 613
							} -- 613
							::_continue_3:: -- 612
						end -- 611
						::_continue_0:: -- 586
					end -- 585
					if item == "" and not searchType then -- 614
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 615
						for _index_0 = 1, #_list_1 do -- 615
							local _des_0 = _list_1[_index_0] -- 615
							local name = _des_0[1] -- 615
							suggestions[#suggestions + 1] = { -- 616
								name, -- 616
								"dora module", -- 616
								"function" -- 616
							} -- 616
						end -- 615
					end -- 614
					if #suggestions > 0 then -- 617
						do -- 618
							local _accum_0 = { } -- 618
							local _len_0 = 1 -- 618
							for _, v in pairs(_anon_func_4(suggestions)) do -- 618
								_accum_0[_len_0] = v -- 618
								_len_0 = _len_0 + 1 -- 618
							end -- 618
							suggestions = _accum_0 -- 618
						end -- 618
						return { -- 619
							success = true, -- 619
							suggestions = suggestions -- 619
						} -- 619
					else -- 621
						return { -- 621
							success = false -- 621
						} -- 621
					end -- 617
				until true -- 562
				if "tl" == lang or "lua" == lang then -- 623
					do -- 624
						local isTIC80 = CheckTIC80Code(content) -- 624
						if isTIC80 then -- 624
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 625
						end -- 624
					end -- 624
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 626
					if not line:match("[%.:]$") then -- 627
						local checkSet -- 628
						do -- 628
							local _tbl_0 = { } -- 628
							for _index_0 = 1, #suggestions do -- 628
								local _des_0 = suggestions[_index_0] -- 628
								local name = _des_0[1] -- 628
								_tbl_0[name] = true -- 628
							end -- 628
							checkSet = _tbl_0 -- 628
						end -- 628
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 629
						for _index_0 = 1, #_list_0 do -- 629
							local item = _list_0[_index_0] -- 629
							if not checkSet[item[1]] then -- 630
								suggestions[#suggestions + 1] = item -- 630
							end -- 630
						end -- 629
						for _index_0 = 1, #luaKeywords do -- 631
							local word = luaKeywords[_index_0] -- 631
							suggestions[#suggestions + 1] = { -- 632
								word, -- 632
								"keyword", -- 632
								"keyword" -- 632
							} -- 632
						end -- 631
						if lang == "tl" then -- 633
							for _index_0 = 1, #tealKeywords do -- 634
								local word = tealKeywords[_index_0] -- 634
								suggestions[#suggestions + 1] = { -- 635
									word, -- 635
									"keyword", -- 635
									"keyword" -- 635
								} -- 635
							end -- 634
						end -- 633
					end -- 627
					if #suggestions > 0 then -- 636
						return { -- 637
							success = true, -- 637
							suggestions = suggestions -- 637
						} -- 637
					end -- 636
				elseif "yue" == lang then -- 638
					local suggestions = { } -- 639
					local gotGlobals = false -- 640
					do -- 641
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 641
						if luaCodes then -- 641
							gotGlobals = true -- 642
							do -- 643
								local chainOp = line:match("[^%w_]([%.\\])$") -- 643
								if chainOp then -- 643
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 644
									if not withVar then -- 645
										return { -- 645
											success = false -- 645
										} -- 645
									end -- 645
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 646
								elseif line:match("^([%.\\])$") then -- 647
									return { -- 648
										success = false -- 648
									} -- 648
								end -- 643
							end -- 643
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 649
							for _index_0 = 1, #_list_0 do -- 649
								local item = _list_0[_index_0] -- 649
								suggestions[#suggestions + 1] = item -- 649
							end -- 649
							if #suggestions == 0 then -- 650
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 651
								for _index_0 = 1, #_list_1 do -- 651
									local item = _list_1[_index_0] -- 651
									suggestions[#suggestions + 1] = item -- 651
								end -- 651
							end -- 650
						end -- 641
					end -- 641
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 652
						local checkSet -- 653
						do -- 653
							local _tbl_0 = { } -- 653
							for _index_0 = 1, #suggestions do -- 653
								local _des_0 = suggestions[_index_0] -- 653
								local name = _des_0[1] -- 653
								_tbl_0[name] = true -- 653
							end -- 653
							checkSet = _tbl_0 -- 653
						end -- 653
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 654
						for _index_0 = 1, #_list_0 do -- 654
							local item = _list_0[_index_0] -- 654
							if not checkSet[item[1]] then -- 655
								suggestions[#suggestions + 1] = item -- 655
							end -- 655
						end -- 654
						if not gotGlobals then -- 656
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 657
							for _index_0 = 1, #_list_1 do -- 657
								local item = _list_1[_index_0] -- 657
								if not checkSet[item[1]] then -- 658
									suggestions[#suggestions + 1] = item -- 658
								end -- 658
							end -- 657
						end -- 656
						for _index_0 = 1, #yueKeywords do -- 659
							local word = yueKeywords[_index_0] -- 659
							if not checkSet[word] then -- 660
								suggestions[#suggestions + 1] = { -- 661
									word, -- 661
									"keyword", -- 661
									"keyword" -- 661
								} -- 661
							end -- 660
						end -- 659
					end -- 652
					if #suggestions > 0 then -- 662
						return { -- 663
							success = true, -- 663
							suggestions = suggestions -- 663
						} -- 663
					end -- 662
				elseif "xml" == lang then -- 664
					local items = xml.complete(content) -- 665
					if #items > 0 then -- 666
						local suggestions -- 667
						do -- 667
							local _accum_0 = { } -- 667
							local _len_0 = 1 -- 667
							for _index_0 = 1, #items do -- 667
								local _des_0 = items[_index_0] -- 667
								local label, insertText = _des_0[1], _des_0[2] -- 667
								_accum_0[_len_0] = { -- 668
									label, -- 668
									insertText, -- 668
									"field" -- 668
								} -- 668
								_len_0 = _len_0 + 1 -- 668
							end -- 667
							suggestions = _accum_0 -- 667
						end -- 667
						return { -- 669
							success = true, -- 669
							suggestions = suggestions -- 669
						} -- 669
					end -- 666
				end -- 623
			end -- 560
		end -- 560
	end -- 560
	return { -- 559
		success = false -- 559
	} -- 559
end) -- 559
HttpServer:upload("/upload", function(req, filename) -- 673
	do -- 674
		local _type_0 = type(req) -- 674
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 674
		if _tab_0 then -- 674
			local path -- 674
			do -- 674
				local _obj_0 = req.params -- 674
				local _type_1 = type(_obj_0) -- 674
				if "table" == _type_1 or "userdata" == _type_1 then -- 674
					path = _obj_0.path -- 674
				end -- 674
			end -- 674
			if path ~= nil then -- 674
				local uploadPath = Path(Content.writablePath, ".upload") -- 675
				if not Content:exist(uploadPath) then -- 676
					Content:mkdir(uploadPath) -- 677
				end -- 676
				local targetPath = Path(uploadPath, filename) -- 678
				Content:mkdir(Path:getPath(targetPath)) -- 679
				return targetPath -- 680
			end -- 674
		end -- 674
	end -- 674
	return nil -- 673
end, function(req, file) -- 681
	do -- 682
		local _type_0 = type(req) -- 682
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 682
		if _tab_0 then -- 682
			local path -- 682
			do -- 682
				local _obj_0 = req.params -- 682
				local _type_1 = type(_obj_0) -- 682
				if "table" == _type_1 or "userdata" == _type_1 then -- 682
					path = _obj_0.path -- 682
				end -- 682
			end -- 682
			if path ~= nil then -- 682
				path = Path(Content.writablePath, path) -- 683
				if Content:exist(path) then -- 684
					local uploadPath = Path(Content.writablePath, ".upload") -- 685
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 686
					Content:mkdir(Path:getPath(targetPath)) -- 687
					if Content:move(file, targetPath) then -- 688
						return true -- 689
					end -- 688
				end -- 684
			end -- 682
		end -- 682
	end -- 682
	return false -- 681
end) -- 671
HttpServer:post("/list", function(req) -- 692
	do -- 693
		local _type_0 = type(req) -- 693
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 693
		if _tab_0 then -- 693
			local path -- 693
			do -- 693
				local _obj_0 = req.body -- 693
				local _type_1 = type(_obj_0) -- 693
				if "table" == _type_1 or "userdata" == _type_1 then -- 693
					path = _obj_0.path -- 693
				end -- 693
			end -- 693
			if path ~= nil then -- 693
				if Content:exist(path) then -- 694
					local files = { } -- 695
					local visitAssets -- 696
					visitAssets = function(path, folder) -- 696
						local dirs = Content:getDirs(path) -- 697
						for _index_0 = 1, #dirs do -- 698
							local dir = dirs[_index_0] -- 698
							if dir:match("^%.") then -- 699
								goto _continue_0 -- 699
							end -- 699
							local current -- 700
							if folder == "" then -- 700
								current = dir -- 701
							else -- 703
								current = Path(folder, dir) -- 703
							end -- 700
							files[#files + 1] = current -- 704
							visitAssets(Path(path, dir), current) -- 705
							::_continue_0:: -- 699
						end -- 698
						local fs = Content:getFiles(path) -- 706
						for _index_0 = 1, #fs do -- 707
							local f = fs[_index_0] -- 707
							if f:match("^%.") then -- 708
								goto _continue_1 -- 708
							end -- 708
							if folder == "" then -- 709
								files[#files + 1] = f -- 710
							else -- 712
								files[#files + 1] = Path(folder, f) -- 712
							end -- 709
							::_continue_1:: -- 708
						end -- 707
					end -- 696
					visitAssets(path, "") -- 713
					if #files == 0 then -- 714
						files = nil -- 714
					end -- 714
					return { -- 715
						success = true, -- 715
						files = files -- 715
					} -- 715
				end -- 694
			end -- 693
		end -- 693
	end -- 693
	return { -- 692
		success = false -- 692
	} -- 692
end) -- 692
HttpServer:post("/info", function() -- 717
	local Entry = require("Script.Dev.Entry") -- 718
	local webProfiler, drawerWidth -- 719
	do -- 719
		local _obj_0 = Entry.getConfig() -- 719
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 719
	end -- 719
	local engineDev = Entry.getEngineDev() -- 720
	Entry.connectWebIDE() -- 721
	return { -- 723
		platform = App.platform, -- 723
		locale = App.locale, -- 724
		version = App.version, -- 725
		engineDev = engineDev, -- 726
		webProfiler = webProfiler, -- 727
		drawerWidth = drawerWidth -- 728
	} -- 722
end) -- 717
local ensureLLMConfigTable -- 730
ensureLLMConfigTable = function() -- 730
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 731
	if columns and #columns > 0 then -- 732
		local expected = { -- 734
			id = true, -- 734
			name = true, -- 735
			url = true, -- 736
			model = true, -- 737
			api_key = true, -- 738
			context_window = true, -- 739
			supports_function_calling = true, -- 740
			active = true, -- 741
			created_at = true, -- 742
			updated_at = true -- 743
		} -- 733
		local valid = #columns == 10 -- 745
		if valid then -- 746
			for _index_0 = 1, #columns do -- 747
				local row = columns[_index_0] -- 747
				local columnName = tostring(row[2]) -- 748
				if not expected[columnName] then -- 749
					valid = false -- 750
					break -- 751
				end -- 749
			end -- 747
		end -- 746
		if not valid then -- 752
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 753
		end -- 752
	end -- 732
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
	]]) -- 754
end -- 730
local normalizeContextWindow -- 769
normalizeContextWindow = function(value) -- 769
	local contextWindow = tonumber(value) -- 770
	if contextWindow == nil or contextWindow < 4000 then -- 771
		return 64000 -- 772
	end -- 771
	return math.max(4000, math.floor(contextWindow)) -- 773
end -- 769
HttpServer:post("/llm/list", function() -- 775
	ensureLLMConfigTable() -- 776
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 777
	local items -- 781
	if rows and #rows > 0 then -- 781
		local _accum_0 = { } -- 782
		local _len_0 = 1 -- 782
		for _index_0 = 1, #rows do -- 782
			local _des_0 = rows[_index_0] -- 782
			local id, name, url, model, key, contextWindow, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8] -- 782
			_accum_0[_len_0] = { -- 783
				id = id, -- 783
				name = name, -- 783
				url = url, -- 783
				model = model, -- 783
				key = key, -- 783
				contextWindow = normalizeContextWindow(contextWindow), -- 783
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 783
				active = active ~= 0 -- 783
			} -- 783
			_len_0 = _len_0 + 1 -- 783
		end -- 782
		items = _accum_0 -- 781
	end -- 781
	return { -- 784
		success = true, -- 784
		items = items -- 784
	} -- 784
end) -- 775
HttpServer:post("/llm/create", function(req) -- 786
	ensureLLMConfigTable() -- 787
	do -- 788
		local _type_0 = type(req) -- 788
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 788
		if _tab_0 then -- 788
			local body = req.body -- 788
			if body ~= nil then -- 788
				local name, url, model, key, active, contextWindow, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.supportsFunctionCalling -- 789
				local now = os.time() -- 790
				if name == nil or url == nil or model == nil or key == nil then -- 791
					return { -- 792
						success = false, -- 792
						message = "invalid" -- 792
					} -- 792
				end -- 791
				contextWindow = normalizeContextWindow(contextWindow) -- 793
				if supportsFunctionCalling == false then -- 794
					supportsFunctionCalling = 0 -- 794
				else -- 794
					supportsFunctionCalling = 1 -- 794
				end -- 794
				if active then -- 795
					active = 1 -- 795
				else -- 795
					active = 0 -- 795
				end -- 795
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 802
					tostring(name), -- 802
					tostring(url), -- 803
					tostring(model), -- 804
					tostring(key), -- 805
					contextWindow, -- 806
					supportsFunctionCalling, -- 807
					active, -- 808
					now, -- 809
					now -- 810
				}) -- 796
				return { -- 812
					success = affected >= 0 -- 812
				} -- 812
			end -- 788
		end -- 788
	end -- 788
	return { -- 786
		success = false, -- 786
		message = "invalid" -- 786
	} -- 786
end) -- 786
HttpServer:post("/llm/update", function(req) -- 814
	ensureLLMConfigTable() -- 815
	do -- 816
		local _type_0 = type(req) -- 816
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 816
		if _tab_0 then -- 816
			local body = req.body -- 816
			if body ~= nil then -- 816
				local id, name, url, model, key, active, contextWindow, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.supportsFunctionCalling -- 817
				local now = os.time() -- 818
				id = tonumber(id) -- 819
				if id == nil then -- 820
					return { -- 821
						success = false, -- 821
						message = "invalid" -- 821
					} -- 821
				end -- 820
				contextWindow = normalizeContextWindow(contextWindow) -- 822
				if supportsFunctionCalling == false then -- 823
					supportsFunctionCalling = 0 -- 823
				else -- 823
					supportsFunctionCalling = 1 -- 823
				end -- 823
				if active then -- 824
					active = 1 -- 824
				else -- 824
					active = 0 -- 824
				end -- 824
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 829
					tostring(name), -- 829
					tostring(url), -- 830
					tostring(model), -- 831
					tostring(key), -- 832
					contextWindow, -- 833
					supportsFunctionCalling, -- 834
					active, -- 835
					now, -- 836
					id -- 837
				}) -- 825
				return { -- 839
					success = affected >= 0 -- 839
				} -- 839
			end -- 816
		end -- 816
	end -- 816
	return { -- 814
		success = false, -- 814
		message = "invalid" -- 814
	} -- 814
end) -- 814
HttpServer:post("/llm/delete", function(req) -- 841
	ensureLLMConfigTable() -- 842
	do -- 843
		local _type_0 = type(req) -- 843
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 843
		if _tab_0 then -- 843
			local id -- 843
			do -- 843
				local _obj_0 = req.body -- 843
				local _type_1 = type(_obj_0) -- 843
				if "table" == _type_1 or "userdata" == _type_1 then -- 843
					id = _obj_0.id -- 843
				end -- 843
			end -- 843
			if id ~= nil then -- 843
				id = tonumber(id) -- 844
				if id == nil then -- 845
					return { -- 846
						success = false, -- 846
						message = "invalid" -- 846
					} -- 846
				end -- 845
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 847
					id -- 847
				}) -- 847
				return { -- 848
					success = affected >= 0 -- 848
				} -- 848
			end -- 843
		end -- 843
	end -- 843
	return { -- 841
		success = false, -- 841
		message = "invalid" -- 841
	} -- 841
end) -- 841
HttpServer:post("/new", function(req) -- 850
	do -- 851
		local _type_0 = type(req) -- 851
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 851
		if _tab_0 then -- 851
			local path -- 851
			do -- 851
				local _obj_0 = req.body -- 851
				local _type_1 = type(_obj_0) -- 851
				if "table" == _type_1 or "userdata" == _type_1 then -- 851
					path = _obj_0.path -- 851
				end -- 851
			end -- 851
			local content -- 851
			do -- 851
				local _obj_0 = req.body -- 851
				local _type_1 = type(_obj_0) -- 851
				if "table" == _type_1 or "userdata" == _type_1 then -- 851
					content = _obj_0.content -- 851
				end -- 851
			end -- 851
			local folder -- 851
			do -- 851
				local _obj_0 = req.body -- 851
				local _type_1 = type(_obj_0) -- 851
				if "table" == _type_1 or "userdata" == _type_1 then -- 851
					folder = _obj_0.folder -- 851
				end -- 851
			end -- 851
			if path ~= nil and content ~= nil and folder ~= nil then -- 851
				if Content:exist(path) then -- 852
					return { -- 853
						success = false, -- 853
						message = "TargetExisted" -- 853
					} -- 853
				end -- 852
				local parent = Path:getPath(path) -- 854
				local files = Content:getFiles(parent) -- 855
				if folder then -- 856
					local name = Path:getFilename(path):lower() -- 857
					for _index_0 = 1, #files do -- 858
						local file = files[_index_0] -- 858
						if name == Path:getFilename(file):lower() then -- 859
							return { -- 860
								success = false, -- 860
								message = "TargetExisted" -- 860
							} -- 860
						end -- 859
					end -- 858
					if Content:mkdir(path) then -- 861
						return { -- 862
							success = true -- 862
						} -- 862
					end -- 861
				else -- 864
					local name = Path:getName(path):lower() -- 864
					for _index_0 = 1, #files do -- 865
						local file = files[_index_0] -- 865
						if name == Path:getName(file):lower() then -- 866
							local ext = Path:getExt(file) -- 867
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 868
								goto _continue_0 -- 869
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 870
								goto _continue_0 -- 871
							end -- 868
							return { -- 872
								success = false, -- 872
								message = "SourceExisted" -- 872
							} -- 872
						end -- 866
						::_continue_0:: -- 866
					end -- 865
					if Content:save(path, content) then -- 873
						return { -- 874
							success = true -- 874
						} -- 874
					end -- 873
				end -- 856
			end -- 851
		end -- 851
	end -- 851
	return { -- 850
		success = false, -- 850
		message = "Failed" -- 850
	} -- 850
end) -- 850
HttpServer:post("/delete", function(req) -- 876
	do -- 877
		local _type_0 = type(req) -- 877
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 877
		if _tab_0 then -- 877
			local path -- 877
			do -- 877
				local _obj_0 = req.body -- 877
				local _type_1 = type(_obj_0) -- 877
				if "table" == _type_1 or "userdata" == _type_1 then -- 877
					path = _obj_0.path -- 877
				end -- 877
			end -- 877
			if path ~= nil then -- 877
				if Content:exist(path) then -- 878
					local projectRoot -- 879
					if Content:isdir(path) and isProjectRootDir(path) then -- 879
						projectRoot = path -- 879
					else -- 879
						projectRoot = nil -- 879
					end -- 879
					local parent = Path:getPath(path) -- 880
					local files = Content:getFiles(parent) -- 881
					local name = Path:getName(path):lower() -- 882
					local ext = Path:getExt(path) -- 883
					for _index_0 = 1, #files do -- 884
						local file = files[_index_0] -- 884
						if name == Path:getName(file):lower() then -- 885
							local _exp_0 = Path:getExt(file) -- 886
							if "tl" == _exp_0 then -- 886
								if ("vs" == ext) then -- 886
									Content:remove(Path(parent, file)) -- 887
								end -- 886
							elseif "lua" == _exp_0 then -- 888
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 888
									Content:remove(Path(parent, file)) -- 889
								end -- 888
							end -- 886
						end -- 885
					end -- 884
					if Content:remove(path) then -- 890
						if projectRoot then -- 891
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 892
						end -- 891
						return { -- 893
							success = true -- 893
						} -- 893
					end -- 890
				end -- 878
			end -- 877
		end -- 877
	end -- 877
	return { -- 876
		success = false -- 876
	} -- 876
end) -- 876
HttpServer:post("/rename", function(req) -- 895
	do -- 896
		local _type_0 = type(req) -- 896
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 896
		if _tab_0 then -- 896
			local old -- 896
			do -- 896
				local _obj_0 = req.body -- 896
				local _type_1 = type(_obj_0) -- 896
				if "table" == _type_1 or "userdata" == _type_1 then -- 896
					old = _obj_0.old -- 896
				end -- 896
			end -- 896
			local new -- 896
			do -- 896
				local _obj_0 = req.body -- 896
				local _type_1 = type(_obj_0) -- 896
				if "table" == _type_1 or "userdata" == _type_1 then -- 896
					new = _obj_0.new -- 896
				end -- 896
			end -- 896
			if old ~= nil and new ~= nil then -- 896
				if Content:exist(old) and not Content:exist(new) then -- 897
					local renamedDir = Content:isdir(old) -- 898
					local parent = Path:getPath(new) -- 899
					local files = Content:getFiles(parent) -- 900
					if renamedDir then -- 901
						local name = Path:getFilename(new):lower() -- 902
						for _index_0 = 1, #files do -- 903
							local file = files[_index_0] -- 903
							if name == Path:getFilename(file):lower() then -- 904
								return { -- 905
									success = false -- 905
								} -- 905
							end -- 904
						end -- 903
					else -- 907
						local name = Path:getName(new):lower() -- 907
						local ext = Path:getExt(new) -- 908
						for _index_0 = 1, #files do -- 909
							local file = files[_index_0] -- 909
							if name == Path:getName(file):lower() then -- 910
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 911
									goto _continue_0 -- 912
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 913
									goto _continue_0 -- 914
								end -- 911
								return { -- 915
									success = false -- 915
								} -- 915
							end -- 910
							::_continue_0:: -- 910
						end -- 909
					end -- 901
					if Content:move(old, new) then -- 916
						if renamedDir then -- 917
							AgentSession.renameSessionsByProjectRoot(old, new) -- 918
						end -- 917
						local newParent = Path:getPath(new) -- 919
						parent = Path:getPath(old) -- 920
						files = Content:getFiles(parent) -- 921
						local newName = Path:getName(new) -- 922
						local oldName = Path:getName(old) -- 923
						local name = oldName:lower() -- 924
						local ext = Path:getExt(old) -- 925
						for _index_0 = 1, #files do -- 926
							local file = files[_index_0] -- 926
							if name == Path:getName(file):lower() then -- 927
								local _exp_0 = Path:getExt(file) -- 928
								if "tl" == _exp_0 then -- 928
									if ("vs" == ext) then -- 928
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 929
									end -- 928
								elseif "lua" == _exp_0 then -- 930
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 930
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 931
									end -- 930
								end -- 928
							end -- 927
						end -- 926
						return { -- 932
							success = true -- 932
						} -- 932
					end -- 916
				end -- 897
			end -- 896
		end -- 896
	end -- 896
	return { -- 895
		success = false -- 895
	} -- 895
end) -- 895
HttpServer:post("/exist", function(req) -- 934
	do -- 935
		local _type_0 = type(req) -- 935
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 935
		if _tab_0 then -- 935
			local file -- 935
			do -- 935
				local _obj_0 = req.body -- 935
				local _type_1 = type(_obj_0) -- 935
				if "table" == _type_1 or "userdata" == _type_1 then -- 935
					file = _obj_0.file -- 935
				end -- 935
			end -- 935
			if file ~= nil then -- 935
				do -- 936
					local projFile = req.body.projFile -- 936
					if projFile then -- 936
						local projDir = getProjectDirFromFile(projFile) -- 937
						if projDir then -- 937
							local scriptDir = Path(projDir, "Script") -- 938
							local searchPaths = Content.searchPaths -- 939
							if Content:exist(scriptDir) then -- 940
								Content:addSearchPath(scriptDir) -- 940
							end -- 940
							if Content:exist(projDir) then -- 941
								Content:addSearchPath(projDir) -- 941
							end -- 941
							local _ <close> = setmetatable({ }, { -- 942
								__close = function() -- 942
									Content.searchPaths = searchPaths -- 942
								end -- 942
							}) -- 942
							return { -- 943
								success = Content:exist(file) -- 943
							} -- 943
						end -- 937
					end -- 936
				end -- 936
				return { -- 944
					success = Content:exist(file) -- 944
				} -- 944
			end -- 935
		end -- 935
	end -- 935
	return { -- 934
		success = false -- 934
	} -- 934
end) -- 934
HttpServer:postSchedule("/read", function(req) -- 946
	do -- 947
		local _type_0 = type(req) -- 947
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 947
		if _tab_0 then -- 947
			local path -- 947
			do -- 947
				local _obj_0 = req.body -- 947
				local _type_1 = type(_obj_0) -- 947
				if "table" == _type_1 or "userdata" == _type_1 then -- 947
					path = _obj_0.path -- 947
				end -- 947
			end -- 947
			if path ~= nil then -- 947
				local readFile -- 948
				readFile = function() -- 948
					if Content:exist(path) then -- 949
						local content = Content:loadAsync(path) -- 950
						if content then -- 950
							return { -- 951
								content = content, -- 951
								success = true -- 951
							} -- 951
						end -- 950
					end -- 949
					return nil -- 948
				end -- 948
				do -- 952
					local projFile = req.body.projFile -- 952
					if projFile then -- 952
						local projDir = getProjectDirFromFile(projFile) -- 953
						if projDir then -- 953
							local scriptDir = Path(projDir, "Script") -- 954
							local searchPaths = Content.searchPaths -- 955
							if Content:exist(scriptDir) then -- 956
								Content:addSearchPath(scriptDir) -- 956
							end -- 956
							if Content:exist(projDir) then -- 957
								Content:addSearchPath(projDir) -- 957
							end -- 957
							local _ <close> = setmetatable({ }, { -- 958
								__close = function() -- 958
									Content.searchPaths = searchPaths -- 958
								end -- 958
							}) -- 958
							local result = readFile() -- 959
							if result then -- 959
								return result -- 959
							end -- 959
						end -- 953
					end -- 952
				end -- 952
				local result = readFile() -- 960
				if result then -- 960
					return result -- 960
				end -- 960
			end -- 947
		end -- 947
	end -- 947
	return { -- 946
		success = false -- 946
	} -- 946
end) -- 946
HttpServer:get("/read-sync", function(req) -- 962
	do -- 963
		local _type_0 = type(req) -- 963
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 963
		if _tab_0 then -- 963
			local params = req.params -- 963
			if params ~= nil then -- 963
				local path = params.path -- 964
				local exts -- 965
				if params.exts then -- 965
					local _accum_0 = { } -- 966
					local _len_0 = 1 -- 966
					for ext in params.exts:gmatch("[^|]*") do -- 966
						_accum_0[_len_0] = ext -- 967
						_len_0 = _len_0 + 1 -- 967
					end -- 966
					exts = _accum_0 -- 965
				else -- 968
					exts = { -- 968
						"" -- 968
					} -- 968
				end -- 965
				local readFile -- 969
				readFile = function() -- 969
					for _index_0 = 1, #exts do -- 970
						local ext = exts[_index_0] -- 970
						local targetPath = path .. ext -- 971
						if Content:exist(targetPath) then -- 972
							local content = Content:load(targetPath) -- 973
							if content then -- 973
								return { -- 974
									content = content, -- 974
									success = true, -- 974
									fullPath = Content:getFullPath(targetPath) -- 974
								} -- 974
							end -- 973
						end -- 972
					end -- 970
					return nil -- 969
				end -- 969
				local searchPaths = Content.searchPaths -- 975
				local _ <close> = setmetatable({ }, { -- 976
					__close = function() -- 976
						Content.searchPaths = searchPaths -- 976
					end -- 976
				}) -- 976
				do -- 977
					local projFile = req.params.projFile -- 977
					if projFile then -- 977
						local projDir = getProjectDirFromFile(projFile) -- 978
						if projDir then -- 978
							local scriptDir = Path(projDir, "Script") -- 979
							if Content:exist(scriptDir) then -- 980
								Content:addSearchPath(scriptDir) -- 980
							end -- 980
							if Content:exist(projDir) then -- 981
								Content:addSearchPath(projDir) -- 981
							end -- 981
						else -- 983
							projDir = Path:getPath(projFile) -- 983
							if Content:exist(projDir) then -- 984
								Content:addSearchPath(projDir) -- 984
							end -- 984
						end -- 978
					end -- 977
				end -- 977
				local result = readFile() -- 985
				if result then -- 985
					return result -- 985
				end -- 985
			end -- 963
		end -- 963
	end -- 963
	return { -- 962
		success = false -- 962
	} -- 962
end) -- 962
local compileFileAsync -- 987
compileFileAsync = function(inputFile, sourceCodes) -- 987
	local file = inputFile -- 988
	local searchPath -- 989
	do -- 989
		local dir = getProjectDirFromFile(inputFile) -- 989
		if dir then -- 989
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 990
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 991
		else -- 993
			file = Path:getRelative(inputFile, Content.writablePath) -- 993
			if file:sub(1, 2) == ".." then -- 994
				file = Path:getRelative(inputFile, Content.assetPath) -- 995
			end -- 994
			searchPath = "" -- 996
		end -- 989
	end -- 989
	local outputFile = Path:replaceExt(inputFile, "lua") -- 997
	local yueext = yue.options.extension -- 998
	local resultCodes = nil -- 999
	local resultError = nil -- 1000
	do -- 1001
		local _exp_0 = Path:getExt(inputFile) -- 1001
		if yueext == _exp_0 then -- 1001
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1002
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1003
				if not codes then -- 1004
					resultError = err -- 1005
					return -- 1006
				end -- 1004
				local extraGlobal -- 1007
				if isTIC80 then -- 1007
					extraGlobal = tic80APIs -- 1007
				else -- 1007
					extraGlobal = nil -- 1007
				end -- 1007
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1008
				if not success then -- 1009
					resultError = message -- 1010
					return -- 1011
				end -- 1009
				if codes == "" then -- 1012
					resultCodes = "" -- 1013
					return nil -- 1014
				end -- 1012
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1015
				return resultCodes -- 1016
			end, function(success) -- 1003
				if not success then -- 1017
					Content:remove(outputFile) -- 1018
					if resultCodes == nil then -- 1019
						resultCodes = false -- 1020
					end -- 1019
				end -- 1017
			end) -- 1003
		elseif "tl" == _exp_0 then -- 1021
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1022
			if isTIC80 then -- 1023
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1024
			end -- 1023
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1025
			if codes then -- 1025
				if isTIC80 then -- 1026
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1027
				end -- 1026
				resultCodes = codes -- 1028
				Content:saveAsync(outputFile, codes) -- 1029
			else -- 1031
				Content:remove(outputFile) -- 1031
				resultCodes = false -- 1032
				resultError = err -- 1033
			end -- 1025
		elseif "xml" == _exp_0 then -- 1034
			local codes, err = xml.tolua(sourceCodes) -- 1035
			if codes then -- 1035
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1036
				Content:saveAsync(outputFile, resultCodes) -- 1037
			else -- 1039
				Content:remove(outputFile) -- 1039
				resultCodes = false -- 1040
				resultError = err -- 1041
			end -- 1035
		end -- 1001
	end -- 1001
	wait(function() -- 1042
		return resultCodes ~= nil -- 1042
	end) -- 1042
	if resultCodes then -- 1043
		return resultCodes -- 1044
	else -- 1046
		return nil, resultError -- 1046
	end -- 1043
	return nil -- 987
end -- 987
HttpServer:postSchedule("/write", function(req) -- 1048
	do -- 1049
		local _type_0 = type(req) -- 1049
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1049
		if _tab_0 then -- 1049
			local path -- 1049
			do -- 1049
				local _obj_0 = req.body -- 1049
				local _type_1 = type(_obj_0) -- 1049
				if "table" == _type_1 or "userdata" == _type_1 then -- 1049
					path = _obj_0.path -- 1049
				end -- 1049
			end -- 1049
			local content -- 1049
			do -- 1049
				local _obj_0 = req.body -- 1049
				local _type_1 = type(_obj_0) -- 1049
				if "table" == _type_1 or "userdata" == _type_1 then -- 1049
					content = _obj_0.content -- 1049
				end -- 1049
			end -- 1049
			if path ~= nil and content ~= nil then -- 1049
				if Content:saveAsync(path, content) then -- 1050
					do -- 1051
						local _exp_0 = Path:getExt(path) -- 1051
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1051
							if '' == Path:getExt(Path:getName(path)) then -- 1052
								local resultCodes = compileFileAsync(path, content) -- 1053
								return { -- 1054
									success = true, -- 1054
									resultCodes = resultCodes -- 1054
								} -- 1054
							end -- 1052
						end -- 1051
					end -- 1051
					return { -- 1055
						success = true -- 1055
					} -- 1055
				end -- 1050
			end -- 1049
		end -- 1049
	end -- 1049
	return { -- 1048
		success = false -- 1048
	} -- 1048
end) -- 1048
HttpServer:postSchedule("/build", function(req) -- 1057
	do -- 1058
		local _type_0 = type(req) -- 1058
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1058
		if _tab_0 then -- 1058
			local path -- 1058
			do -- 1058
				local _obj_0 = req.body -- 1058
				local _type_1 = type(_obj_0) -- 1058
				if "table" == _type_1 or "userdata" == _type_1 then -- 1058
					path = _obj_0.path -- 1058
				end -- 1058
			end -- 1058
			if path ~= nil then -- 1058
				local _exp_0 = Path:getExt(path) -- 1059
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1059
					if '' == Path:getExt(Path:getName(path)) then -- 1060
						local content = Content:loadAsync(path) -- 1061
						if content then -- 1061
							local resultCodes = compileFileAsync(path, content) -- 1062
							if resultCodes then -- 1062
								return { -- 1063
									success = true, -- 1063
									resultCodes = resultCodes -- 1063
								} -- 1063
							end -- 1062
						end -- 1061
					end -- 1060
				end -- 1059
			end -- 1058
		end -- 1058
	end -- 1058
	return { -- 1057
		success = false -- 1057
	} -- 1057
end) -- 1057
local extentionLevels = { -- 1066
	vs = 2, -- 1066
	bl = 2, -- 1067
	ts = 1, -- 1068
	tsx = 1, -- 1069
	tl = 1, -- 1070
	yue = 1, -- 1071
	xml = 1, -- 1072
	lua = 0 -- 1073
} -- 1065
HttpServer:post("/assets", function() -- 1075
	local Entry = require("Script.Dev.Entry") -- 1078
	local engineDev = Entry.getEngineDev() -- 1079
	local visitAssets -- 1080
	visitAssets = function(path, tag) -- 1080
		local isWorkspace = tag == "Workspace" -- 1081
		local builtin -- 1082
		if tag == "Builtin" then -- 1082
			builtin = true -- 1082
		else -- 1082
			builtin = nil -- 1082
		end -- 1082
		local children = nil -- 1083
		local dirs = Content:getDirs(path) -- 1084
		for _index_0 = 1, #dirs do -- 1085
			local dir = dirs[_index_0] -- 1085
			if isWorkspace then -- 1086
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1087
					goto _continue_0 -- 1088
				end -- 1087
			elseif dir == ".git" then -- 1089
				goto _continue_0 -- 1090
			end -- 1086
			if not children then -- 1091
				children = { } -- 1091
			end -- 1091
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1092
			::_continue_0:: -- 1086
		end -- 1085
		local files = Content:getFiles(path) -- 1093
		local names = { } -- 1094
		for _index_0 = 1, #files do -- 1095
			local file = files[_index_0] -- 1095
			if file:match("^%.") then -- 1096
				goto _continue_1 -- 1096
			end -- 1096
			local name = Path:getName(file) -- 1097
			local ext = names[name] -- 1098
			if ext then -- 1098
				local lv1 -- 1099
				do -- 1099
					local _exp_0 = extentionLevels[ext] -- 1099
					if _exp_0 ~= nil then -- 1099
						lv1 = _exp_0 -- 1099
					else -- 1099
						lv1 = -1 -- 1099
					end -- 1099
				end -- 1099
				ext = Path:getExt(file) -- 1100
				local lv2 -- 1101
				do -- 1101
					local _exp_0 = extentionLevels[ext] -- 1101
					if _exp_0 ~= nil then -- 1101
						lv2 = _exp_0 -- 1101
					else -- 1101
						lv2 = -1 -- 1101
					end -- 1101
				end -- 1101
				if lv2 > lv1 then -- 1102
					names[name] = ext -- 1103
				elseif lv2 == lv1 then -- 1104
					names[name .. '.' .. ext] = "" -- 1105
				end -- 1102
			else -- 1107
				ext = Path:getExt(file) -- 1107
				if not extentionLevels[ext] then -- 1108
					names[file] = "" -- 1109
				else -- 1111
					names[name] = ext -- 1111
				end -- 1108
			end -- 1098
			::_continue_1:: -- 1096
		end -- 1095
		do -- 1112
			local _accum_0 = { } -- 1112
			local _len_0 = 1 -- 1112
			for name, ext in pairs(names) do -- 1112
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1112
				_len_0 = _len_0 + 1 -- 1112
			end -- 1112
			files = _accum_0 -- 1112
		end -- 1112
		for _index_0 = 1, #files do -- 1113
			local file = files[_index_0] -- 1113
			if not children then -- 1114
				children = { } -- 1114
			end -- 1114
			children[#children + 1] = { -- 1116
				key = Path(path, file), -- 1116
				dir = false, -- 1117
				title = file, -- 1118
				builtin = builtin -- 1119
			} -- 1115
		end -- 1113
		if children then -- 1121
			table.sort(children, function(a, b) -- 1122
				if a.dir == b.dir then -- 1123
					return a.title < b.title -- 1124
				else -- 1126
					return a.dir -- 1126
				end -- 1123
			end) -- 1122
		end -- 1121
		if isWorkspace and children then -- 1127
			return children -- 1128
		else -- 1130
			return { -- 1131
				key = path, -- 1131
				dir = true, -- 1132
				title = Path:getFilename(path), -- 1133
				builtin = builtin, -- 1134
				children = children -- 1135
			} -- 1130
		end -- 1127
	end -- 1080
	local zh = (App.locale:match("^zh") ~= nil) -- 1137
	return { -- 1139
		key = Content.writablePath, -- 1139
		dir = true, -- 1140
		root = true, -- 1141
		title = "Assets", -- 1142
		children = (function() -- 1144
			local _tab_0 = { -- 1144
				{ -- 1145
					key = Path(Content.assetPath), -- 1145
					dir = true, -- 1146
					builtin = true, -- 1147
					title = zh and "内置资源" or "Built-in", -- 1148
					children = { -- 1150
						(function() -- 1150
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1150
							_with_0.title = zh and "说明文档" or "Readme" -- 1151
							return _with_0 -- 1150
						end)(), -- 1150
						(function() -- 1152
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1152
							_with_0.title = zh and "接口文档" or "API Doc" -- 1153
							return _with_0 -- 1152
						end)(), -- 1152
						(function() -- 1154
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1154
							_with_0.title = zh and "开发工具" or "Tools" -- 1155
							return _with_0 -- 1154
						end)(), -- 1154
						(function() -- 1156
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1156
							_with_0.title = zh and "字体" or "Font" -- 1157
							return _with_0 -- 1156
						end)(), -- 1156
						(function() -- 1158
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1158
							_with_0.title = zh and "程序库" or "Lib" -- 1159
							if engineDev then -- 1160
								local _list_0 = _with_0.children -- 1161
								for _index_0 = 1, #_list_0 do -- 1161
									local child = _list_0[_index_0] -- 1161
									if not (child.title == "Dora") then -- 1162
										goto _continue_0 -- 1162
									end -- 1162
									local title = zh and "zh-Hans" or "en" -- 1163
									do -- 1164
										local _accum_0 = { } -- 1164
										local _len_0 = 1 -- 1164
										local _list_1 = child.children -- 1164
										for _index_1 = 1, #_list_1 do -- 1164
											local c = _list_1[_index_1] -- 1164
											if c.title ~= title then -- 1164
												_accum_0[_len_0] = c -- 1164
												_len_0 = _len_0 + 1 -- 1164
											end -- 1164
										end -- 1164
										child.children = _accum_0 -- 1164
									end -- 1164
									break -- 1165
									::_continue_0:: -- 1162
								end -- 1161
							else -- 1167
								local _accum_0 = { } -- 1167
								local _len_0 = 1 -- 1167
								local _list_0 = _with_0.children -- 1167
								for _index_0 = 1, #_list_0 do -- 1167
									local child = _list_0[_index_0] -- 1167
									if child.title ~= "Dora" then -- 1167
										_accum_0[_len_0] = child -- 1167
										_len_0 = _len_0 + 1 -- 1167
									end -- 1167
								end -- 1167
								_with_0.children = _accum_0 -- 1167
							end -- 1160
							return _with_0 -- 1158
						end)(), -- 1158
						(function() -- 1168
							if engineDev then -- 1168
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1169
								local _obj_0 = _with_0.children -- 1170
								_obj_0[#_obj_0 + 1] = { -- 1171
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1171
									dir = false, -- 1172
									builtin = true, -- 1173
									title = "init.yue" -- 1174
								} -- 1170
								return _with_0 -- 1169
							end -- 1168
						end)() -- 1168
					} -- 1149
				} -- 1144
			} -- 1178
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1178
			local _idx_0 = #_tab_0 + 1 -- 1178
			for _index_0 = 1, #_obj_0 do -- 1178
				local _value_0 = _obj_0[_index_0] -- 1178
				_tab_0[_idx_0] = _value_0 -- 1178
				_idx_0 = _idx_0 + 1 -- 1178
			end -- 1178
			return _tab_0 -- 1144
		end)() -- 1143
	} -- 1138
end) -- 1075
HttpServer:postSchedule("/run", function(req) -- 1182
	do -- 1183
		local _type_0 = type(req) -- 1183
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1183
		if _tab_0 then -- 1183
			local file -- 1183
			do -- 1183
				local _obj_0 = req.body -- 1183
				local _type_1 = type(_obj_0) -- 1183
				if "table" == _type_1 or "userdata" == _type_1 then -- 1183
					file = _obj_0.file -- 1183
				end -- 1183
			end -- 1183
			local asProj -- 1183
			do -- 1183
				local _obj_0 = req.body -- 1183
				local _type_1 = type(_obj_0) -- 1183
				if "table" == _type_1 or "userdata" == _type_1 then -- 1183
					asProj = _obj_0.asProj -- 1183
				end -- 1183
			end -- 1183
			if file ~= nil and asProj ~= nil then -- 1183
				if not Content:isAbsolutePath(file) then -- 1184
					local devFile = Path(Content.writablePath, file) -- 1185
					if Content:exist(devFile) then -- 1186
						file = devFile -- 1186
					end -- 1186
				end -- 1184
				local Entry = require("Script.Dev.Entry") -- 1187
				local workDir -- 1188
				if asProj then -- 1189
					workDir = getProjectDirFromFile(file) -- 1190
					if workDir then -- 1190
						Entry.allClear() -- 1191
						local target = Path(workDir, "init") -- 1192
						local success, err = Entry.enterEntryAsync({ -- 1193
							entryName = "Project", -- 1193
							fileName = target -- 1193
						}) -- 1193
						target = Path:getName(Path:getPath(target)) -- 1194
						return { -- 1195
							success = success, -- 1195
							target = target, -- 1195
							err = err -- 1195
						} -- 1195
					end -- 1190
				else -- 1197
					workDir = getProjectDirFromFile(file) -- 1197
				end -- 1189
				Entry.allClear() -- 1198
				file = Path:replaceExt(file, "") -- 1199
				local success, err = Entry.enterEntryAsync({ -- 1201
					entryName = Path:getName(file), -- 1201
					fileName = file, -- 1202
					workDir = workDir -- 1203
				}) -- 1200
				return { -- 1204
					success = success, -- 1204
					err = err -- 1204
				} -- 1204
			end -- 1183
		end -- 1183
	end -- 1183
	return { -- 1182
		success = false -- 1182
	} -- 1182
end) -- 1182
HttpServer:postSchedule("/stop", function() -- 1206
	local Entry = require("Script.Dev.Entry") -- 1207
	return { -- 1208
		success = Entry.stop() -- 1208
	} -- 1208
end) -- 1206
local minifyAsync -- 1210
minifyAsync = function(sourcePath, minifyPath) -- 1210
	if not Content:exist(sourcePath) then -- 1211
		return -- 1211
	end -- 1211
	local Entry = require("Script.Dev.Entry") -- 1212
	local errors = { } -- 1213
	local files = Entry.getAllFiles(sourcePath, { -- 1214
		"lua" -- 1214
	}, true) -- 1214
	do -- 1215
		local _accum_0 = { } -- 1215
		local _len_0 = 1 -- 1215
		for _index_0 = 1, #files do -- 1215
			local file = files[_index_0] -- 1215
			if file:sub(1, 1) ~= '.' then -- 1215
				_accum_0[_len_0] = file -- 1215
				_len_0 = _len_0 + 1 -- 1215
			end -- 1215
		end -- 1215
		files = _accum_0 -- 1215
	end -- 1215
	local paths -- 1216
	do -- 1216
		local _tbl_0 = { } -- 1216
		for _index_0 = 1, #files do -- 1216
			local file = files[_index_0] -- 1216
			_tbl_0[Path:getPath(file)] = true -- 1216
		end -- 1216
		paths = _tbl_0 -- 1216
	end -- 1216
	for path in pairs(paths) do -- 1217
		Content:mkdir(Path(minifyPath, path)) -- 1217
	end -- 1217
	local _ <close> = setmetatable({ }, { -- 1218
		__close = function() -- 1218
			package.loaded["luaminify.FormatMini"] = nil -- 1219
			package.loaded["luaminify.ParseLua"] = nil -- 1220
			package.loaded["luaminify.Scope"] = nil -- 1221
			package.loaded["luaminify.Util"] = nil -- 1222
		end -- 1218
	}) -- 1218
	local FormatMini -- 1223
	do -- 1223
		local _obj_0 = require("luaminify") -- 1223
		FormatMini = _obj_0.FormatMini -- 1223
	end -- 1223
	local fileCount = #files -- 1224
	local count = 0 -- 1225
	for _index_0 = 1, #files do -- 1226
		local file = files[_index_0] -- 1226
		thread(function() -- 1227
			local _ <close> = setmetatable({ }, { -- 1228
				__close = function() -- 1228
					count = count + 1 -- 1228
				end -- 1228
			}) -- 1228
			local input = Path(sourcePath, file) -- 1229
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1230
			if Content:exist(input) then -- 1231
				local sourceCodes = Content:loadAsync(input) -- 1232
				local res, err = FormatMini(sourceCodes) -- 1233
				if res then -- 1234
					Content:saveAsync(output, res) -- 1235
					return print("Minify " .. tostring(file)) -- 1236
				else -- 1238
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1238
				end -- 1234
			else -- 1240
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1240
			end -- 1231
		end) -- 1227
		sleep() -- 1241
	end -- 1226
	wait(function() -- 1242
		return count == fileCount -- 1242
	end) -- 1242
	if #errors > 0 then -- 1243
		print(table.concat(errors, '\n')) -- 1244
	end -- 1243
	print("Obfuscation done.") -- 1245
	return files -- 1246
end -- 1210
local zipping = false -- 1248
HttpServer:postSchedule("/zip", function(req) -- 1250
	do -- 1251
		local _type_0 = type(req) -- 1251
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1251
		if _tab_0 then -- 1251
			local path -- 1251
			do -- 1251
				local _obj_0 = req.body -- 1251
				local _type_1 = type(_obj_0) -- 1251
				if "table" == _type_1 or "userdata" == _type_1 then -- 1251
					path = _obj_0.path -- 1251
				end -- 1251
			end -- 1251
			local zipFile -- 1251
			do -- 1251
				local _obj_0 = req.body -- 1251
				local _type_1 = type(_obj_0) -- 1251
				if "table" == _type_1 or "userdata" == _type_1 then -- 1251
					zipFile = _obj_0.zipFile -- 1251
				end -- 1251
			end -- 1251
			local obfuscated -- 1251
			do -- 1251
				local _obj_0 = req.body -- 1251
				local _type_1 = type(_obj_0) -- 1251
				if "table" == _type_1 or "userdata" == _type_1 then -- 1251
					obfuscated = _obj_0.obfuscated -- 1251
				end -- 1251
			end -- 1251
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1251
				if zipping then -- 1252
					goto failed -- 1252
				end -- 1252
				zipping = true -- 1253
				local _ <close> = setmetatable({ }, { -- 1254
					__close = function() -- 1254
						zipping = false -- 1254
					end -- 1254
				}) -- 1254
				if not Content:exist(path) then -- 1255
					goto failed -- 1255
				end -- 1255
				Content:mkdir(Path:getPath(zipFile)) -- 1256
				if obfuscated then -- 1257
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1258
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1259
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1260
					Content:remove(scriptPath) -- 1261
					Content:remove(obfuscatedPath) -- 1262
					Content:remove(tempPath) -- 1263
					Content:mkdir(scriptPath) -- 1264
					Content:mkdir(obfuscatedPath) -- 1265
					Content:mkdir(tempPath) -- 1266
					if not Content:copyAsync(path, tempPath) then -- 1267
						goto failed -- 1267
					end -- 1267
					local Entry = require("Script.Dev.Entry") -- 1268
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1269
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1270
						"tl", -- 1270
						"yue", -- 1270
						"lua", -- 1270
						"ts", -- 1270
						"tsx", -- 1270
						"vs", -- 1270
						"bl", -- 1270
						"xml", -- 1270
						"wa", -- 1270
						"mod" -- 1270
					}, true) -- 1270
					for _index_0 = 1, #scriptFiles do -- 1271
						local file = scriptFiles[_index_0] -- 1271
						Content:remove(Path(tempPath, file)) -- 1272
					end -- 1271
					for _index_0 = 1, #luaFiles do -- 1273
						local file = luaFiles[_index_0] -- 1273
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1274
					end -- 1273
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1275
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1276
					end) then -- 1275
						goto failed -- 1275
					end -- 1275
					return { -- 1277
						success = true -- 1277
					} -- 1277
				else -- 1279
					return { -- 1279
						success = Content:zipAsync(path, zipFile, function(file) -- 1279
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1280
						end) -- 1279
					} -- 1279
				end -- 1257
			end -- 1251
		end -- 1251
	end -- 1251
	::failed:: -- 1281
	return { -- 1250
		success = false -- 1250
	} -- 1250
end) -- 1250
HttpServer:postSchedule("/unzip", function(req) -- 1283
	do -- 1284
		local _type_0 = type(req) -- 1284
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1284
		if _tab_0 then -- 1284
			local zipFile -- 1284
			do -- 1284
				local _obj_0 = req.body -- 1284
				local _type_1 = type(_obj_0) -- 1284
				if "table" == _type_1 or "userdata" == _type_1 then -- 1284
					zipFile = _obj_0.zipFile -- 1284
				end -- 1284
			end -- 1284
			local path -- 1284
			do -- 1284
				local _obj_0 = req.body -- 1284
				local _type_1 = type(_obj_0) -- 1284
				if "table" == _type_1 or "userdata" == _type_1 then -- 1284
					path = _obj_0.path -- 1284
				end -- 1284
			end -- 1284
			if zipFile ~= nil and path ~= nil then -- 1284
				return { -- 1285
					success = Content:unzipAsync(zipFile, path, function(file) -- 1285
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1286
					end) -- 1285
				} -- 1285
			end -- 1284
		end -- 1284
	end -- 1284
	return { -- 1283
		success = false -- 1283
	} -- 1283
end) -- 1283
HttpServer:post("/editing-info", function(req) -- 1288
	local Entry = require("Script.Dev.Entry") -- 1289
	local config = Entry.getConfig() -- 1290
	local _type_0 = type(req) -- 1291
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1291
	local _match_0 = false -- 1291
	if _tab_0 then -- 1291
		local editingInfo -- 1291
		do -- 1291
			local _obj_0 = req.body -- 1291
			local _type_1 = type(_obj_0) -- 1291
			if "table" == _type_1 or "userdata" == _type_1 then -- 1291
				editingInfo = _obj_0.editingInfo -- 1291
			end -- 1291
		end -- 1291
		if editingInfo ~= nil then -- 1291
			_match_0 = true -- 1291
			config.editingInfo = editingInfo -- 1292
			return { -- 1293
				success = true -- 1293
			} -- 1293
		end -- 1291
	end -- 1291
	if not _match_0 then -- 1291
		if not (config.editingInfo ~= nil) then -- 1295
			local folder -- 1296
			if App.locale:match('^zh') then -- 1296
				folder = 'zh-Hans' -- 1296
			else -- 1296
				folder = 'en' -- 1296
			end -- 1296
			config.editingInfo = json.encode({ -- 1298
				index = 0, -- 1298
				files = { -- 1300
					{ -- 1301
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1301
						title = "welcome.md" -- 1302
					} -- 1300
				} -- 1299
			}) -- 1297
		end -- 1295
		return { -- 1306
			success = true, -- 1306
			editingInfo = config.editingInfo -- 1306
		} -- 1306
	end -- 1291
end) -- 1288
HttpServer:post("/command", function(req) -- 1308
	do -- 1309
		local _type_0 = type(req) -- 1309
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1309
		if _tab_0 then -- 1309
			local code -- 1309
			do -- 1309
				local _obj_0 = req.body -- 1309
				local _type_1 = type(_obj_0) -- 1309
				if "table" == _type_1 or "userdata" == _type_1 then -- 1309
					code = _obj_0.code -- 1309
				end -- 1309
			end -- 1309
			local log -- 1309
			do -- 1309
				local _obj_0 = req.body -- 1309
				local _type_1 = type(_obj_0) -- 1309
				if "table" == _type_1 or "userdata" == _type_1 then -- 1309
					log = _obj_0.log -- 1309
				end -- 1309
			end -- 1309
			if code ~= nil and log ~= nil then -- 1309
				emit("AppCommand", code, log) -- 1310
				return { -- 1311
					success = true -- 1311
				} -- 1311
			end -- 1309
		end -- 1309
	end -- 1309
	return { -- 1308
		success = false -- 1308
	} -- 1308
end) -- 1308
HttpServer:post("/log/save", function() -- 1313
	local folder = ".download" -- 1314
	local fullLogFile = "dora_full_logs.txt" -- 1315
	local fullFolder = Path(Content.writablePath, folder) -- 1316
	Content:mkdir(fullFolder) -- 1317
	local logPath = Path(fullFolder, fullLogFile) -- 1318
	if App:saveLog(logPath) then -- 1319
		return { -- 1320
			success = true, -- 1320
			path = Path(folder, fullLogFile) -- 1320
		} -- 1320
	end -- 1319
	return { -- 1313
		success = false -- 1313
	} -- 1313
end) -- 1313
HttpServer:post("/yarn/check", function(req) -- 1322
	local yarncompile = require("yarncompile") -- 1323
	do -- 1324
		local _type_0 = type(req) -- 1324
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1324
		if _tab_0 then -- 1324
			local code -- 1324
			do -- 1324
				local _obj_0 = req.body -- 1324
				local _type_1 = type(_obj_0) -- 1324
				if "table" == _type_1 or "userdata" == _type_1 then -- 1324
					code = _obj_0.code -- 1324
				end -- 1324
			end -- 1324
			if code ~= nil then -- 1324
				local jsonObject = json.decode(code) -- 1325
				if jsonObject then -- 1325
					local errors = { } -- 1326
					local _list_0 = jsonObject.nodes -- 1327
					for _index_0 = 1, #_list_0 do -- 1327
						local node = _list_0[_index_0] -- 1327
						local title, body = node.title, node.body -- 1328
						local luaCode, err = yarncompile(body) -- 1329
						if not luaCode then -- 1329
							errors[#errors + 1] = title .. ":" .. err -- 1330
						end -- 1329
					end -- 1327
					return { -- 1331
						success = true, -- 1331
						syntaxError = table.concat(errors, "\n\n") -- 1331
					} -- 1331
				end -- 1325
			end -- 1324
		end -- 1324
	end -- 1324
	return { -- 1322
		success = false -- 1322
	} -- 1322
end) -- 1322
HttpServer:post("/yarn/check-file", function(req) -- 1333
	local yarncompile = require("yarncompile") -- 1334
	do -- 1335
		local _type_0 = type(req) -- 1335
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1335
		if _tab_0 then -- 1335
			local code -- 1335
			do -- 1335
				local _obj_0 = req.body -- 1335
				local _type_1 = type(_obj_0) -- 1335
				if "table" == _type_1 or "userdata" == _type_1 then -- 1335
					code = _obj_0.code -- 1335
				end -- 1335
			end -- 1335
			if code ~= nil then -- 1335
				local res, _, err = yarncompile(code, true) -- 1336
				if not res then -- 1336
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1337
					return { -- 1338
						success = false, -- 1338
						message = message, -- 1338
						line = line, -- 1338
						column = column, -- 1338
						node = node -- 1338
					} -- 1338
				end -- 1336
			end -- 1335
		end -- 1335
	end -- 1335
	return { -- 1333
		success = true -- 1333
	} -- 1333
end) -- 1333
local getWaProjectDirFromFile -- 1340
getWaProjectDirFromFile = function(file) -- 1340
	local writablePath = Content.writablePath -- 1341
	local parent, current -- 1342
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1342
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1343
	else -- 1345
		parent, current = nil, nil -- 1345
	end -- 1342
	if not current then -- 1346
		return nil -- 1346
	end -- 1346
	repeat -- 1347
		current = Path:getPath(current) -- 1348
		if current == "" then -- 1349
			break -- 1349
		end -- 1349
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1350
		for _index_0 = 1, #_list_0 do -- 1350
			local f = _list_0[_index_0] -- 1350
			if Path:getFilename(f):lower() == "wa.mod" then -- 1351
				return Path(parent, current, Path:getPath(f)) -- 1352
			end -- 1351
		end -- 1350
	until false -- 1347
	return nil -- 1354
end -- 1340
HttpServer:postSchedule("/wa/update_dora", function(req) -- 1356
	do -- 1357
		local _type_0 = type(req) -- 1357
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1357
		if _tab_0 then -- 1357
			local path -- 1357
			do -- 1357
				local _obj_0 = req.body -- 1357
				local _type_1 = type(_obj_0) -- 1357
				if "table" == _type_1 or "userdata" == _type_1 then -- 1357
					path = _obj_0.path -- 1357
				end -- 1357
			end -- 1357
			if path ~= nil then -- 1357
				local projDir = getWaProjectDirFromFile(path) -- 1358
				if projDir then -- 1358
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 1359
					if not Content:exist(sourceDoraPath) then -- 1360
						return { -- 1361
							success = false, -- 1361
							message = "missing dora template" -- 1361
						} -- 1361
					end -- 1360
					local targetVendorPath = Path(projDir, "vendor") -- 1362
					local targetDoraPath = Path(targetVendorPath, "dora") -- 1363
					if not Content:exist(targetVendorPath) then -- 1364
						if not Content:mkdir(targetVendorPath) then -- 1365
							return { -- 1366
								success = false, -- 1366
								message = "failed to create vendor folder" -- 1366
							} -- 1366
						end -- 1365
					elseif not Content:isdir(targetVendorPath) then -- 1367
						return { -- 1368
							success = false, -- 1368
							message = "vendor path is not a folder" -- 1368
						} -- 1368
					end -- 1364
					if Content:exist(targetDoraPath) then -- 1369
						if not Content:remove(targetDoraPath) then -- 1370
							return { -- 1371
								success = false, -- 1371
								message = "failed to remove old dora" -- 1371
							} -- 1371
						end -- 1370
					end -- 1369
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 1372
						return { -- 1373
							success = false, -- 1373
							message = "failed to copy dora" -- 1373
						} -- 1373
					end -- 1372
					return { -- 1374
						success = true -- 1374
					} -- 1374
				else -- 1376
					return { -- 1376
						success = false, -- 1376
						message = 'Wa file needs a project' -- 1376
					} -- 1376
				end -- 1358
			end -- 1357
		end -- 1357
	end -- 1357
	return { -- 1356
		success = false, -- 1356
		message = "invalid call" -- 1356
	} -- 1356
end) -- 1356
HttpServer:postSchedule("/wa/build", function(req) -- 1378
	do -- 1379
		local _type_0 = type(req) -- 1379
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1379
		if _tab_0 then -- 1379
			local path -- 1379
			do -- 1379
				local _obj_0 = req.body -- 1379
				local _type_1 = type(_obj_0) -- 1379
				if "table" == _type_1 or "userdata" == _type_1 then -- 1379
					path = _obj_0.path -- 1379
				end -- 1379
			end -- 1379
			if path ~= nil then -- 1379
				local projDir = getWaProjectDirFromFile(path) -- 1380
				if projDir then -- 1380
					local message = Wasm:buildWaAsync(projDir) -- 1381
					if message == "" then -- 1382
						return { -- 1383
							success = true -- 1383
						} -- 1383
					else -- 1385
						return { -- 1385
							success = false, -- 1385
							message = message -- 1385
						} -- 1385
					end -- 1382
				else -- 1387
					return { -- 1387
						success = false, -- 1387
						message = 'Wa file needs a project' -- 1387
					} -- 1387
				end -- 1380
			end -- 1379
		end -- 1379
	end -- 1379
	return { -- 1388
		success = false, -- 1388
		message = 'failed to build' -- 1388
	} -- 1388
end) -- 1378
HttpServer:postSchedule("/wa/format", function(req) -- 1390
	do -- 1391
		local _type_0 = type(req) -- 1391
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1391
		if _tab_0 then -- 1391
			local file -- 1391
			do -- 1391
				local _obj_0 = req.body -- 1391
				local _type_1 = type(_obj_0) -- 1391
				if "table" == _type_1 or "userdata" == _type_1 then -- 1391
					file = _obj_0.file -- 1391
				end -- 1391
			end -- 1391
			if file ~= nil then -- 1391
				local code = Wasm:formatWaAsync(file) -- 1392
				if code == "" then -- 1393
					return { -- 1394
						success = false -- 1394
					} -- 1394
				else -- 1396
					return { -- 1396
						success = true, -- 1396
						code = code -- 1396
					} -- 1396
				end -- 1393
			end -- 1391
		end -- 1391
	end -- 1391
	return { -- 1397
		success = false -- 1397
	} -- 1397
end) -- 1390
HttpServer:postSchedule("/wa/create", function(req) -- 1399
	do -- 1400
		local _type_0 = type(req) -- 1400
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1400
		if _tab_0 then -- 1400
			local path -- 1400
			do -- 1400
				local _obj_0 = req.body -- 1400
				local _type_1 = type(_obj_0) -- 1400
				if "table" == _type_1 or "userdata" == _type_1 then -- 1400
					path = _obj_0.path -- 1400
				end -- 1400
			end -- 1400
			if path ~= nil then -- 1400
				if not Content:exist(Path:getPath(path)) then -- 1401
					return { -- 1402
						success = false, -- 1402
						message = "target path not existed" -- 1402
					} -- 1402
				end -- 1401
				if Content:exist(path) then -- 1403
					return { -- 1404
						success = false, -- 1404
						message = "target project folder existed" -- 1404
					} -- 1404
				end -- 1403
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1405
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1406
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1407
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1408
					return { -- 1411
						success = false, -- 1411
						message = "missing template project" -- 1411
					} -- 1411
				end -- 1408
				if not Content:mkdir(path) then -- 1412
					return { -- 1413
						success = false, -- 1413
						message = "failed to create project folder" -- 1413
					} -- 1413
				end -- 1412
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1414
					Content:remove(path) -- 1415
					return { -- 1416
						success = false, -- 1416
						message = "failed to copy template" -- 1416
					} -- 1416
				end -- 1414
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1417
					Content:remove(path) -- 1418
					return { -- 1419
						success = false, -- 1419
						message = "failed to copy template" -- 1419
					} -- 1419
				end -- 1417
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1420
					Content:remove(path) -- 1421
					return { -- 1422
						success = false, -- 1422
						message = "failed to copy template" -- 1422
					} -- 1422
				end -- 1420
				return { -- 1423
					success = true -- 1423
				} -- 1423
			end -- 1400
		end -- 1400
	end -- 1400
	return { -- 1399
		success = false, -- 1399
		message = "invalid call" -- 1399
	} -- 1399
end) -- 1399
local _anon_func_5 = function(path) -- 1432
	local _val_0 = Path:getExt(path) -- 1432
	return "ts" == _val_0 or "tsx" == _val_0 -- 1432
end -- 1432
local _anon_func_6 = function(f) -- 1462
	local _val_0 = Path:getExt(f) -- 1462
	return "ts" == _val_0 or "tsx" == _val_0 -- 1462
end -- 1462
HttpServer:postSchedule("/ts/build", function(req) -- 1425
	do -- 1426
		local _type_0 = type(req) -- 1426
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1426
		if _tab_0 then -- 1426
			local path -- 1426
			do -- 1426
				local _obj_0 = req.body -- 1426
				local _type_1 = type(_obj_0) -- 1426
				if "table" == _type_1 or "userdata" == _type_1 then -- 1426
					path = _obj_0.path -- 1426
				end -- 1426
			end -- 1426
			if path ~= nil then -- 1426
				if HttpServer.wsConnectionCount == 0 then -- 1427
					return { -- 1428
						success = false, -- 1428
						message = "Web IDE not connected" -- 1428
					} -- 1428
				end -- 1427
				if not Content:exist(path) then -- 1429
					return { -- 1430
						success = false, -- 1430
						message = "path not existed" -- 1430
					} -- 1430
				end -- 1429
				if not Content:isdir(path) then -- 1431
					if not (_anon_func_5(path)) then -- 1432
						return { -- 1433
							success = false, -- 1433
							message = "expecting a TypeScript file" -- 1433
						} -- 1433
					end -- 1432
					local messages = { } -- 1434
					local content = Content:load(path) -- 1435
					if not content then -- 1436
						return { -- 1437
							success = false, -- 1437
							message = "failed to read file" -- 1437
						} -- 1437
					end -- 1436
					emit("AppWS", "Send", json.encode({ -- 1438
						name = "UpdateFile", -- 1438
						file = path, -- 1438
						exists = true, -- 1438
						content = content -- 1438
					})) -- 1438
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1439
						local done = false -- 1440
						do -- 1441
							local _with_0 = Node() -- 1441
							_with_0:gslot("AppWS", function(event) -- 1442
								if event.type == "Receive" then -- 1443
									local res = json.decode(event.msg) -- 1444
									if res then -- 1444
										if res.name == "TranspileTS" and res.file == path then -- 1445
											_with_0:removeFromParent() -- 1446
											if res.success then -- 1447
												local luaFile = Path:replaceExt(path, "lua") -- 1448
												Content:save(luaFile, res.luaCode) -- 1449
												messages[#messages + 1] = { -- 1450
													success = true, -- 1450
													file = path -- 1450
												} -- 1450
											else -- 1452
												messages[#messages + 1] = { -- 1452
													success = false, -- 1452
													file = path, -- 1452
													message = res.message -- 1452
												} -- 1452
											end -- 1447
											done = true -- 1453
										end -- 1445
									end -- 1444
								end -- 1443
							end) -- 1442
						end -- 1441
						emit("AppWS", "Send", json.encode({ -- 1454
							name = "TranspileTS", -- 1454
							file = path, -- 1454
							content = content -- 1454
						})) -- 1454
						wait(function() -- 1455
							return done -- 1455
						end) -- 1455
					end -- 1439
					return { -- 1456
						success = true, -- 1456
						messages = messages -- 1456
					} -- 1456
				else -- 1458
					local files = Content:getAllFiles(path) -- 1458
					local fileData = { } -- 1459
					local messages = { } -- 1460
					for _index_0 = 1, #files do -- 1461
						local f = files[_index_0] -- 1461
						if not (_anon_func_6(f)) then -- 1462
							goto _continue_0 -- 1462
						end -- 1462
						local file = Path(path, f) -- 1463
						local content = Content:load(file) -- 1464
						if content then -- 1464
							fileData[file] = content -- 1465
							emit("AppWS", "Send", json.encode({ -- 1466
								name = "UpdateFile", -- 1466
								file = file, -- 1466
								exists = true, -- 1466
								content = content -- 1466
							})) -- 1466
						else -- 1468
							messages[#messages + 1] = { -- 1468
								success = false, -- 1468
								file = file, -- 1468
								message = "failed to read file" -- 1468
							} -- 1468
						end -- 1464
						::_continue_0:: -- 1462
					end -- 1461
					for file, content in pairs(fileData) do -- 1469
						if "d" == Path:getExt(Path:getName(file)) then -- 1470
							goto _continue_1 -- 1470
						end -- 1470
						local done = false -- 1471
						do -- 1472
							local _with_0 = Node() -- 1472
							_with_0:gslot("AppWS", function(event) -- 1473
								if event.type == "Receive" then -- 1474
									local res = json.decode(event.msg) -- 1475
									if res then -- 1475
										if res.name == "TranspileTS" and res.file == file then -- 1476
											_with_0:removeFromParent() -- 1477
											if res.success then -- 1478
												local luaFile = Path:replaceExt(file, "lua") -- 1479
												Content:save(luaFile, res.luaCode) -- 1480
												messages[#messages + 1] = { -- 1481
													success = true, -- 1481
													file = file -- 1481
												} -- 1481
											else -- 1483
												messages[#messages + 1] = { -- 1483
													success = false, -- 1483
													file = file, -- 1483
													message = res.message -- 1483
												} -- 1483
											end -- 1478
											done = true -- 1484
										end -- 1476
									end -- 1475
								end -- 1474
							end) -- 1473
						end -- 1472
						emit("AppWS", "Send", json.encode({ -- 1485
							name = "TranspileTS", -- 1485
							file = file, -- 1485
							content = content -- 1485
						})) -- 1485
						wait(function() -- 1486
							return done -- 1486
						end) -- 1486
						::_continue_1:: -- 1470
					end -- 1469
					return { -- 1487
						success = true, -- 1487
						messages = messages -- 1487
					} -- 1487
				end -- 1431
			end -- 1426
		end -- 1426
	end -- 1426
	return { -- 1425
		success = false -- 1425
	} -- 1425
end) -- 1425
HttpServer:post("/download", function(req) -- 1489
	do -- 1490
		local _type_0 = type(req) -- 1490
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1490
		if _tab_0 then -- 1490
			local url -- 1490
			do -- 1490
				local _obj_0 = req.body -- 1490
				local _type_1 = type(_obj_0) -- 1490
				if "table" == _type_1 or "userdata" == _type_1 then -- 1490
					url = _obj_0.url -- 1490
				end -- 1490
			end -- 1490
			local target -- 1490
			do -- 1490
				local _obj_0 = req.body -- 1490
				local _type_1 = type(_obj_0) -- 1490
				if "table" == _type_1 or "userdata" == _type_1 then -- 1490
					target = _obj_0.target -- 1490
				end -- 1490
			end -- 1490
			if url ~= nil and target ~= nil then -- 1490
				local Entry = require("Script.Dev.Entry") -- 1491
				Entry.downloadFile(url, target) -- 1492
				return { -- 1493
					success = true -- 1493
				} -- 1493
			end -- 1490
		end -- 1490
	end -- 1490
	return { -- 1489
		success = false -- 1489
	} -- 1489
end) -- 1489
local status = { } -- 1495
_module_0 = status -- 1496
status.buildAsync = function(path) -- 1498
	if not Content:exist(path) then -- 1499
		return { -- 1500
			success = false, -- 1500
			file = path, -- 1500
			message = "file not existed" -- 1500
		} -- 1500
	end -- 1499
	do -- 1501
		local _exp_0 = Path:getExt(path) -- 1501
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1501
			if '' == Path:getExt(Path:getName(path)) then -- 1502
				local content = Content:loadAsync(path) -- 1503
				if content then -- 1503
					local resultCodes, err = compileFileAsync(path, content) -- 1504
					if resultCodes then -- 1504
						return { -- 1505
							success = true, -- 1505
							file = path -- 1505
						} -- 1505
					else -- 1507
						return { -- 1507
							success = false, -- 1507
							file = path, -- 1507
							message = err -- 1507
						} -- 1507
					end -- 1504
				end -- 1503
			end -- 1502
		elseif "lua" == _exp_0 then -- 1508
			local content = Content:loadAsync(path) -- 1509
			if content then -- 1509
				do -- 1510
					local isTIC80 = CheckTIC80Code(content) -- 1510
					if isTIC80 then -- 1510
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1511
					end -- 1510
				end -- 1510
				local success, info -- 1512
				do -- 1512
					local _obj_0 = luaCheck(path, content) -- 1512
					success, info = _obj_0.success, _obj_0.info -- 1512
				end -- 1512
				if success then -- 1513
					return { -- 1514
						success = true, -- 1514
						file = path -- 1514
					} -- 1514
				elseif info and #info > 0 then -- 1515
					local messages = { } -- 1516
					for _index_0 = 1, #info do -- 1517
						local _des_0 = info[_index_0] -- 1517
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 1517
						local lineText = "" -- 1518
						if line then -- 1519
							local currentLine = 1 -- 1520
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1521
								if currentLine == line then -- 1522
									lineText = text -- 1523
									break -- 1524
								end -- 1522
								currentLine = currentLine + 1 -- 1525
							end -- 1521
						end -- 1519
						if line then -- 1526
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1527
						else -- 1529
							messages[#messages + 1] = message -- 1529
						end -- 1526
					end -- 1517
					return { -- 1530
						success = false, -- 1530
						file = path, -- 1530
						message = table.concat(messages, "\n") -- 1530
					} -- 1530
				else -- 1532
					return { -- 1532
						success = false, -- 1532
						file = path, -- 1532
						message = "lua check failed" -- 1532
					} -- 1532
				end -- 1513
			end -- 1509
		elseif "yarn" == _exp_0 then -- 1533
			local content = Content:loadAsync(path) -- 1534
			if content then -- 1534
				local res, _, err = yarncompile(content, true) -- 1535
				if res then -- 1535
					return { -- 1536
						success = true, -- 1536
						file = path -- 1536
					} -- 1536
				else -- 1538
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1538
					local lineText = "" -- 1539
					if line then -- 1540
						local currentLine = 1 -- 1541
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1542
							if currentLine == line then -- 1543
								lineText = text -- 1544
								break -- 1545
							end -- 1543
							currentLine = currentLine + 1 -- 1546
						end -- 1542
					end -- 1540
					if node ~= "" then -- 1547
						node = "node: " .. tostring(node) .. ", " -- 1548
					else -- 1549
						node = "" -- 1549
					end -- 1547
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1550
					return { -- 1551
						success = false, -- 1551
						file = path, -- 1551
						message = message -- 1551
					} -- 1551
				end -- 1535
			end -- 1534
		end -- 1501
	end -- 1501
	return { -- 1552
		success = false, -- 1552
		file = path, -- 1552
		message = "invalid file to build" -- 1552
	} -- 1552
end -- 1498
thread(function() -- 1554
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1555
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1556
	if Content:exist(doraWeb) then -- 1557
		local needReload -- 1558
		if Content:exist(doraReady) then -- 1558
			needReload = App.version ~= Content:load(doraReady) -- 1559
		else -- 1560
			needReload = true -- 1560
		end -- 1558
		if needReload then -- 1561
			Content:remove(Path(Content.appPath, ".www")) -- 1562
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1563
			Content:save(doraReady, App.version) -- 1567
			print("Dora Dora is ready!") -- 1568
		end -- 1561
	end -- 1557
	if HttpServer:start(8866) then -- 1569
		local localIP = HttpServer.localIP -- 1570
		if localIP == "" then -- 1571
			localIP = "localhost" -- 1571
		end -- 1571
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1572
		return HttpServer:startWS(8868) -- 1573
	else -- 1575
		status.url = nil -- 1575
		return print("8866 Port not available!") -- 1576
	end -- 1569
end) -- 1554
return _module_0 -- 1
