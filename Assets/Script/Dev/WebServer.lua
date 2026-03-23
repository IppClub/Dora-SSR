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
local WebIDEAgentSession = require("Agent.WebIDEAgentSession") -- 130
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
				return WebIDEAgentSession.createSession(projectRoot, title) -- 134
			end -- 133
		end -- 133
	end -- 133
	return invalidArguments -- 132
end) -- 132
HttpServer:post("/agent/session/get", function(req) -- 136
	do -- 137
		local _type_0 = type(req) -- 137
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 137
		if _tab_0 then -- 137
			local sessionId -- 137
			do -- 137
				local _obj_0 = req.body -- 137
				local _type_1 = type(_obj_0) -- 137
				if "table" == _type_1 or "userdata" == _type_1 then -- 137
					sessionId = _obj_0.sessionId -- 137
				end -- 137
			end -- 137
			if sessionId ~= nil then -- 137
				return WebIDEAgentSession.getSession(sessionId) -- 138
			end -- 137
		end -- 137
	end -- 137
	return invalidArguments -- 136
end) -- 136
HttpServer:post("/agent/session/send", function(req) -- 140
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
			local prompt -- 141
			do -- 141
				local _obj_0 = req.body -- 141
				local _type_1 = type(_obj_0) -- 141
				if "table" == _type_1 or "userdata" == _type_1 then -- 141
					prompt = _obj_0.prompt -- 141
				end -- 141
			end -- 141
			local useChineseResponse -- 141
			do -- 141
				local _obj_0 = req.body -- 141
				local _type_1 = type(_obj_0) -- 141
				if "table" == _type_1 or "userdata" == _type_1 then -- 141
					useChineseResponse = _obj_0.useChineseResponse -- 141
				end -- 141
			end -- 141
			if sessionId ~= nil and prompt ~= nil and useChineseResponse ~= nil then -- 141
				return WebIDEAgentSession.sendPrompt(sessionId, prompt, useChineseResponse) -- 142
			end -- 141
		end -- 141
	end -- 141
	return invalidArguments -- 140
end) -- 140
HttpServer:post("/agent/task/status", function(req) -- 144
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
			if sessionId ~= nil then -- 145
				local res = WebIDEAgentSession.getSession(sessionId) -- 146
				if not res.success then -- 147
					return res -- 147
				end -- 147
				local taskId = res.session.currentTaskId -- 148
				local checkpoints -- 149
				if taskId then -- 149
					checkpoints = AgentTools.listCheckpoints(taskId) -- 149
				else -- 149
					checkpoints = { } -- 149
				end -- 149
				return { -- 151
					success = true, -- 151
					session = res.session, -- 152
					messages = res.messages, -- 153
					steps = res.steps, -- 154
					checkpoints = checkpoints -- 155
				} -- 150
			end -- 145
		end -- 145
	end -- 145
	return invalidArguments -- 144
end) -- 144
HttpServer:post("/agent/task/running", function() -- 157
	return WebIDEAgentSession.listRunningSessions() -- 157
end) -- 157
HttpServer:post("/agent/task/stop", function(req) -- 159
	do -- 160
		local _type_0 = type(req) -- 160
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 160
		if _tab_0 then -- 160
			local sessionId -- 160
			do -- 160
				local _obj_0 = req.body -- 160
				local _type_1 = type(_obj_0) -- 160
				if "table" == _type_1 or "userdata" == _type_1 then -- 160
					sessionId = _obj_0.sessionId -- 160
				end -- 160
			end -- 160
			if sessionId ~= nil then -- 160
				return WebIDEAgentSession.stopSessionTask(sessionId) -- 161
			end -- 160
		end -- 160
	end -- 160
	return invalidArguments -- 159
end) -- 159
HttpServer:post("/agent/checkpoint/list", function(req) -- 163
	do -- 164
		local _type_0 = type(req) -- 164
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 164
		if _tab_0 then -- 164
			local taskId -- 164
			do -- 164
				local _obj_0 = req.body -- 164
				local _type_1 = type(_obj_0) -- 164
				if "table" == _type_1 or "userdata" == _type_1 then -- 164
					taskId = _obj_0.taskId -- 164
				end -- 164
			end -- 164
			local sessionId -- 164
			do -- 164
				local _obj_0 = req.body -- 164
				local _type_1 = type(_obj_0) -- 164
				if "table" == _type_1 or "userdata" == _type_1 then -- 164
					sessionId = _obj_0.sessionId -- 164
				end -- 164
			end -- 164
			if sessionId ~= nil then -- 164
				if not taskId and sessionId then -- 165
					taskId = WebIDEAgentSession.getCurrentTaskId(sessionId) -- 166
				end -- 165
				if not taskId then -- 167
					return { -- 167
						success = false, -- 167
						message = "task not found" -- 167
					} -- 167
				end -- 167
				return { -- 169
					success = true, -- 169
					taskId = taskId, -- 170
					checkpoints = AgentTools.listCheckpoints(taskId) -- 171
				} -- 168
			end -- 164
		end -- 164
	end -- 164
	return invalidArguments -- 163
end) -- 163
HttpServer:post("/agent/checkpoint/diff", function(req) -- 173
	do -- 174
		local _type_0 = type(req) -- 174
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 174
		if _tab_0 then -- 174
			local checkpointId -- 174
			do -- 174
				local _obj_0 = req.body -- 174
				local _type_1 = type(_obj_0) -- 174
				if "table" == _type_1 or "userdata" == _type_1 then -- 174
					checkpointId = _obj_0.checkpointId -- 174
				end -- 174
			end -- 174
			if checkpointId ~= nil then -- 174
				if not (checkpointId > 0) then -- 175
					return { -- 175
						success = false, -- 175
						message = "invalid checkpointId" -- 175
					} -- 175
				end -- 175
				return AgentTools.getCheckpointDiff(checkpointId) -- 176
			end -- 174
		end -- 174
	end -- 174
	return invalidArguments -- 173
end) -- 173
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 178
	do -- 179
		local _type_0 = type(req) -- 179
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 179
		if _tab_0 then -- 179
			local sessionId -- 179
			do -- 179
				local _obj_0 = req.body -- 179
				local _type_1 = type(_obj_0) -- 179
				if "table" == _type_1 or "userdata" == _type_1 then -- 179
					sessionId = _obj_0.sessionId -- 179
				end -- 179
			end -- 179
			local checkpointId -- 179
			do -- 179
				local _obj_0 = req.body -- 179
				local _type_1 = type(_obj_0) -- 179
				if "table" == _type_1 or "userdata" == _type_1 then -- 179
					checkpointId = _obj_0.checkpointId -- 179
				end -- 179
			end -- 179
			if sessionId ~= nil and checkpointId ~= nil then -- 179
				if not (checkpointId > 0) then -- 180
					return { -- 180
						success = false, -- 180
						message = "invalid checkpointId" -- 180
					} -- 180
				end -- 180
				local res = WebIDEAgentSession.getSession(sessionId) -- 181
				if not res.success then -- 182
					return res -- 182
				end -- 182
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, res.session.projectRoot) -- 183
				if not rollbackRes.success then -- 184
					return rollbackRes -- 184
				end -- 184
				return { -- 186
					success = true, -- 186
					checkpointId = rollbackRes.checkpointId -- 187
				} -- 185
			end -- 179
		end -- 179
	end -- 179
	return invalidArguments -- 178
end) -- 178
local getSearchPath -- 189
getSearchPath = function(file) -- 189
	do -- 190
		local dir = getProjectDirFromFile(file) -- 190
		if dir then -- 190
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 191
		end -- 190
	end -- 190
	return "" -- 189
end -- 189
local getSearchFolders -- 193
getSearchFolders = function(file) -- 193
	do -- 194
		local dir = getProjectDirFromFile(file) -- 194
		if dir then -- 194
			return { -- 196
				Path(dir, "Script"), -- 196
				dir -- 197
			} -- 195
		end -- 194
	end -- 194
	return { } -- 193
end -- 193
local disabledCheckForLua = { -- 200
	"incompatible number of returns", -- 200
	"unknown", -- 201
	"cannot index", -- 202
	"module not found", -- 203
	"don't know how to resolve", -- 204
	"ContainerItem", -- 205
	"cannot resolve a type", -- 206
	"invalid key", -- 207
	"inconsistent index type", -- 208
	"cannot use operator", -- 209
	"attempting ipairs loop", -- 210
	"expects record or nominal", -- 211
	"variable is not being assigned", -- 212
	"<invalid type>", -- 213
	"<any type>", -- 214
	"using the '#' operator", -- 215
	"can't match a record", -- 216
	"redeclaration of variable", -- 217
	"cannot apply pairs", -- 218
	"not a function", -- 219
	"to%-be%-closed" -- 220
} -- 199
local yueCheck -- 222
yueCheck = function(file, content, lax) -- 222
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 223
	if isTIC80 then -- 224
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 225
	end -- 224
	local searchPath = getSearchPath(file) -- 226
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 227
	local info = { } -- 228
	local globals = { } -- 229
	for _index_0 = 1, #checkResult do -- 230
		local _des_0 = checkResult[_index_0] -- 230
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 230
		if "error" == t then -- 231
			info[#info + 1] = { -- 232
				"syntax", -- 232
				file, -- 232
				line, -- 232
				col, -- 232
				msg -- 232
			} -- 232
		elseif "global" == t then -- 233
			globals[#globals + 1] = { -- 234
				msg, -- 234
				line, -- 234
				col -- 234
			} -- 234
		end -- 231
	end -- 230
	if luaCodes then -- 235
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 236
		if success then -- 237
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 238
			if not (lintResult == "") then -- 239
				lintResult = lintResult .. "\n" -- 239
			end -- 239
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 240
		else -- 241
			for _index_0 = 1, #lintResult do -- 241
				local _des_0 = lintResult[_index_0] -- 241
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 241
				if isTIC80 and tic80APIs[name] then -- 242
					goto _continue_0 -- 242
				end -- 242
				info[#info + 1] = { -- 243
					"syntax", -- 243
					file, -- 243
					line, -- 243
					col, -- 243
					"invalid global variable" -- 243
				} -- 243
				::_continue_0:: -- 242
			end -- 241
		end -- 237
	end -- 235
	return luaCodes, info -- 244
end -- 222
local luaCheck -- 246
luaCheck = function(file, content) -- 246
	local res, err = load(content, "check") -- 247
	if not res then -- 248
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 249
		return { -- 250
			success = false, -- 250
			info = { -- 250
				{ -- 250
					"syntax", -- 250
					file, -- 250
					tonumber(line), -- 250
					0, -- 250
					msg -- 250
				} -- 250
			} -- 250
		} -- 250
	end -- 248
	local success, info = teal.checkAsync(content, file, true, "") -- 251
	if info then -- 252
		do -- 253
			local _accum_0 = { } -- 253
			local _len_0 = 1 -- 253
			for _index_0 = 1, #info do -- 253
				local item = info[_index_0] -- 253
				local useCheck = true -- 254
				if not item[5]:match("unused") then -- 255
					for _index_1 = 1, #disabledCheckForLua do -- 256
						local check = disabledCheckForLua[_index_1] -- 256
						if item[5]:match(check) then -- 257
							useCheck = false -- 258
						end -- 257
					end -- 256
				end -- 255
				if not useCheck then -- 259
					goto _continue_0 -- 259
				end -- 259
				do -- 260
					local _exp_0 = item[1] -- 260
					if "type" == _exp_0 then -- 261
						item[1] = "warning" -- 262
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 263
						goto _continue_0 -- 264
					end -- 260
				end -- 260
				_accum_0[_len_0] = item -- 265
				_len_0 = _len_0 + 1 -- 254
				::_continue_0:: -- 254
			end -- 253
			info = _accum_0 -- 253
		end -- 253
		if #info == 0 then -- 266
			info = nil -- 267
			success = true -- 268
		end -- 266
	end -- 252
	return { -- 269
		success = success, -- 269
		info = info -- 269
	} -- 269
end -- 246
local luaCheckWithLineInfo -- 271
luaCheckWithLineInfo = function(file, luaCodes) -- 271
	local res = luaCheck(file, luaCodes) -- 272
	local info = { } -- 273
	if not res.success then -- 274
		local current = 1 -- 275
		local lastLine = 1 -- 276
		local lineMap = { } -- 277
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 278
			local num = lineCode:match("--%s*(%d+)%s*$") -- 279
			if num then -- 280
				lastLine = tonumber(num) -- 281
			end -- 280
			lineMap[current] = lastLine -- 282
			current = current + 1 -- 283
		end -- 278
		local _list_0 = res.info -- 284
		for _index_0 = 1, #_list_0 do -- 284
			local item = _list_0[_index_0] -- 284
			item[3] = lineMap[item[3]] or 0 -- 285
			item[4] = 0 -- 286
			info[#info + 1] = item -- 287
		end -- 284
		return false, info -- 288
	end -- 274
	return true, info -- 289
end -- 271
local getCompiledYueLine -- 291
getCompiledYueLine = function(content, line, row, file, lax) -- 291
	local luaCodes = yueCheck(file, content, lax) -- 292
	if not luaCodes then -- 293
		return nil -- 293
	end -- 293
	local current = 1 -- 294
	local lastLine = 1 -- 295
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 296
	local targetRow = nil -- 297
	local lineMap = { } -- 298
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 299
		local num = lineCode:match("--%s*(%d+)%s*$") -- 300
		if num then -- 301
			lastLine = tonumber(num) -- 301
		end -- 301
		lineMap[current] = lastLine -- 302
		if row <= lastLine and not targetRow then -- 303
			targetRow = current -- 304
			break -- 305
		end -- 303
		current = current + 1 -- 306
	end -- 299
	targetRow = current -- 307
	if targetLine and targetRow then -- 308
		return luaCodes, targetLine, targetRow, lineMap -- 309
	else -- 311
		return nil -- 311
	end -- 308
end -- 291
HttpServer:postSchedule("/check", function(req) -- 313
	do -- 314
		local _type_0 = type(req) -- 314
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 314
		if _tab_0 then -- 314
			local file -- 314
			do -- 314
				local _obj_0 = req.body -- 314
				local _type_1 = type(_obj_0) -- 314
				if "table" == _type_1 or "userdata" == _type_1 then -- 314
					file = _obj_0.file -- 314
				end -- 314
			end -- 314
			local content -- 314
			do -- 314
				local _obj_0 = req.body -- 314
				local _type_1 = type(_obj_0) -- 314
				if "table" == _type_1 or "userdata" == _type_1 then -- 314
					content = _obj_0.content -- 314
				end -- 314
			end -- 314
			if file ~= nil and content ~= nil then -- 314
				local ext = Path:getExt(file) -- 315
				if "tl" == ext then -- 316
					local searchPath = getSearchPath(file) -- 317
					do -- 318
						local isTIC80 = CheckTIC80Code(content) -- 318
						if isTIC80 then -- 318
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 319
						end -- 318
					end -- 318
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 320
					return { -- 321
						success = success, -- 321
						info = info -- 321
					} -- 321
				elseif "lua" == ext then -- 322
					do -- 323
						local isTIC80 = CheckTIC80Code(content) -- 323
						if isTIC80 then -- 323
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 324
						end -- 323
					end -- 323
					return luaCheck(file, content) -- 325
				elseif "yue" == ext then -- 326
					local luaCodes, info = yueCheck(file, content, false) -- 327
					local success = false -- 328
					if luaCodes then -- 329
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 330
						do -- 331
							local _tab_1 = { } -- 331
							local _idx_0 = #_tab_1 + 1 -- 331
							for _index_0 = 1, #info do -- 331
								local _value_0 = info[_index_0] -- 331
								_tab_1[_idx_0] = _value_0 -- 331
								_idx_0 = _idx_0 + 1 -- 331
							end -- 331
							local _idx_1 = #_tab_1 + 1 -- 331
							for _index_0 = 1, #luaInfo do -- 331
								local _value_0 = luaInfo[_index_0] -- 331
								_tab_1[_idx_1] = _value_0 -- 331
								_idx_1 = _idx_1 + 1 -- 331
							end -- 331
							info = _tab_1 -- 331
						end -- 331
						success = success and luaSuccess -- 332
					end -- 329
					if #info > 0 then -- 333
						return { -- 334
							success = success, -- 334
							info = info -- 334
						} -- 334
					else -- 336
						return { -- 336
							success = success -- 336
						} -- 336
					end -- 333
				elseif "xml" == ext then -- 337
					local success, result = xml.check(content) -- 338
					if success then -- 339
						local info -- 340
						success, info = luaCheckWithLineInfo(file, result) -- 340
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
					else -- 346
						local info -- 346
						do -- 346
							local _accum_0 = { } -- 346
							local _len_0 = 1 -- 346
							for _index_0 = 1, #result do -- 346
								local _des_0 = result[_index_0] -- 346
								local row, err = _des_0[1], _des_0[2] -- 346
								_accum_0[_len_0] = { -- 347
									"syntax", -- 347
									file, -- 347
									row, -- 347
									0, -- 347
									err -- 347
								} -- 347
								_len_0 = _len_0 + 1 -- 347
							end -- 346
							info = _accum_0 -- 346
						end -- 346
						return { -- 348
							success = false, -- 348
							info = info -- 348
						} -- 348
					end -- 339
				end -- 316
			end -- 314
		end -- 314
	end -- 314
	return { -- 313
		success = true -- 313
	} -- 313
end) -- 313
local updateInferedDesc -- 350
updateInferedDesc = function(infered) -- 350
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 351
		return -- 351
	end -- 351
	local key, row = infered.key, infered.row -- 352
	local codes = Content:loadAsync(key) -- 353
	if codes then -- 353
		local comments = { } -- 354
		local line = 0 -- 355
		local skipping = false -- 356
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 357
			line = line + 1 -- 358
			if line >= row then -- 359
				break -- 359
			end -- 359
			if lineCode:match("^%s*%-%- @") then -- 360
				skipping = true -- 361
				goto _continue_0 -- 362
			end -- 360
			local result = lineCode:match("^%s*%-%- (.+)") -- 363
			if result then -- 363
				if not skipping then -- 364
					comments[#comments + 1] = result -- 364
				end -- 364
			elseif #comments > 0 then -- 365
				comments = { } -- 366
				skipping = false -- 367
			end -- 363
			::_continue_0:: -- 358
		end -- 357
		infered.doc = table.concat(comments, "\n") -- 368
	end -- 353
end -- 350
HttpServer:postSchedule("/infer", function(req) -- 370
	do -- 371
		local _type_0 = type(req) -- 371
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 371
		if _tab_0 then -- 371
			local lang -- 371
			do -- 371
				local _obj_0 = req.body -- 371
				local _type_1 = type(_obj_0) -- 371
				if "table" == _type_1 or "userdata" == _type_1 then -- 371
					lang = _obj_0.lang -- 371
				end -- 371
			end -- 371
			local file -- 371
			do -- 371
				local _obj_0 = req.body -- 371
				local _type_1 = type(_obj_0) -- 371
				if "table" == _type_1 or "userdata" == _type_1 then -- 371
					file = _obj_0.file -- 371
				end -- 371
			end -- 371
			local content -- 371
			do -- 371
				local _obj_0 = req.body -- 371
				local _type_1 = type(_obj_0) -- 371
				if "table" == _type_1 or "userdata" == _type_1 then -- 371
					content = _obj_0.content -- 371
				end -- 371
			end -- 371
			local line -- 371
			do -- 371
				local _obj_0 = req.body -- 371
				local _type_1 = type(_obj_0) -- 371
				if "table" == _type_1 or "userdata" == _type_1 then -- 371
					line = _obj_0.line -- 371
				end -- 371
			end -- 371
			local row -- 371
			do -- 371
				local _obj_0 = req.body -- 371
				local _type_1 = type(_obj_0) -- 371
				if "table" == _type_1 or "userdata" == _type_1 then -- 371
					row = _obj_0.row -- 371
				end -- 371
			end -- 371
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 371
				local searchPath = getSearchPath(file) -- 372
				if "tl" == lang or "lua" == lang then -- 373
					if CheckTIC80Code(content) then -- 374
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 375
					end -- 374
					local infered = teal.inferAsync(content, line, row, searchPath) -- 376
					if (infered ~= nil) then -- 377
						updateInferedDesc(infered) -- 378
						return { -- 379
							success = true, -- 379
							infered = infered -- 379
						} -- 379
					end -- 377
				elseif "yue" == lang then -- 380
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 381
					if not luaCodes then -- 382
						return { -- 382
							success = false -- 382
						} -- 382
					end -- 382
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 383
					if (infered ~= nil) then -- 384
						local col -- 385
						file, row, col = infered.file, infered.row, infered.col -- 385
						if file == "" and row > 0 and col > 0 then -- 386
							infered.row = lineMap[row] or 0 -- 387
							infered.col = 0 -- 388
						end -- 386
						updateInferedDesc(infered) -- 389
						return { -- 390
							success = true, -- 390
							infered = infered -- 390
						} -- 390
					end -- 384
				end -- 373
			end -- 371
		end -- 371
	end -- 371
	return { -- 370
		success = false -- 370
	} -- 370
end) -- 370
local _anon_func_2 = function(doc) -- 441
	local _accum_0 = { } -- 441
	local _len_0 = 1 -- 441
	local _list_0 = doc.params -- 441
	for _index_0 = 1, #_list_0 do -- 441
		local param = _list_0[_index_0] -- 441
		_accum_0[_len_0] = param.name -- 441
		_len_0 = _len_0 + 1 -- 441
	end -- 441
	return _accum_0 -- 441
end -- 441
local getParamDocs -- 392
getParamDocs = function(signatures) -- 392
	do -- 393
		local codes = Content:loadAsync(signatures[1].file) -- 393
		if codes then -- 393
			local comments = { } -- 394
			local params = { } -- 395
			local line = 0 -- 396
			local docs = { } -- 397
			local returnType = nil -- 398
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 399
				line = line + 1 -- 400
				local needBreak = true -- 401
				for i, _des_0 in ipairs(signatures) do -- 402
					local row = _des_0.row -- 402
					if line >= row and not (docs[i] ~= nil) then -- 403
						if #comments > 0 or #params > 0 or returnType then -- 404
							docs[i] = { -- 406
								doc = table.concat(comments, "  \n"), -- 406
								returnType = returnType -- 407
							} -- 405
							if #params > 0 then -- 409
								docs[i].params = params -- 409
							end -- 409
						else -- 411
							docs[i] = false -- 411
						end -- 404
					end -- 403
					if not docs[i] then -- 412
						needBreak = false -- 412
					end -- 412
				end -- 402
				if needBreak then -- 413
					break -- 413
				end -- 413
				local result = lineCode:match("%s*%-%- (.+)") -- 414
				if result then -- 414
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 415
					if not name then -- 416
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 417
					end -- 416
					if name then -- 418
						local pname = name -- 419
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 420
							pname = pname .. "?" -- 420
						end -- 420
						params[#params + 1] = { -- 422
							name = tostring(pname) .. ": " .. tostring(typ), -- 422
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 423
						} -- 421
					else -- 426
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 426
						if typ then -- 426
							if returnType then -- 427
								returnType = returnType .. ", " .. typ -- 428
							else -- 430
								returnType = typ -- 430
							end -- 427
							result = result:gsub("@return", "**return:**") -- 431
						end -- 426
						comments[#comments + 1] = result -- 432
					end -- 418
				elseif #comments > 0 then -- 433
					comments = { } -- 434
					params = { } -- 435
					returnType = nil -- 436
				end -- 414
			end -- 399
			local results = { } -- 437
			for _index_0 = 1, #docs do -- 438
				local doc = docs[_index_0] -- 438
				if not doc then -- 439
					goto _continue_0 -- 439
				end -- 439
				if doc.params then -- 440
					doc.desc = "function(" .. tostring(table.concat(_anon_func_2(doc), ', ')) .. ")" -- 441
				else -- 443
					doc.desc = "function()" -- 443
				end -- 440
				if doc.returnType then -- 444
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 445
					doc.returnType = nil -- 446
				end -- 444
				results[#results + 1] = doc -- 447
				::_continue_0:: -- 439
			end -- 438
			if #results > 0 then -- 448
				return results -- 448
			else -- 448
				return nil -- 448
			end -- 448
		end -- 393
	end -- 393
	return nil -- 392
end -- 392
HttpServer:postSchedule("/signature", function(req) -- 450
	do -- 451
		local _type_0 = type(req) -- 451
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 451
		if _tab_0 then -- 451
			local lang -- 451
			do -- 451
				local _obj_0 = req.body -- 451
				local _type_1 = type(_obj_0) -- 451
				if "table" == _type_1 or "userdata" == _type_1 then -- 451
					lang = _obj_0.lang -- 451
				end -- 451
			end -- 451
			local file -- 451
			do -- 451
				local _obj_0 = req.body -- 451
				local _type_1 = type(_obj_0) -- 451
				if "table" == _type_1 or "userdata" == _type_1 then -- 451
					file = _obj_0.file -- 451
				end -- 451
			end -- 451
			local content -- 451
			do -- 451
				local _obj_0 = req.body -- 451
				local _type_1 = type(_obj_0) -- 451
				if "table" == _type_1 or "userdata" == _type_1 then -- 451
					content = _obj_0.content -- 451
				end -- 451
			end -- 451
			local line -- 451
			do -- 451
				local _obj_0 = req.body -- 451
				local _type_1 = type(_obj_0) -- 451
				if "table" == _type_1 or "userdata" == _type_1 then -- 451
					line = _obj_0.line -- 451
				end -- 451
			end -- 451
			local row -- 451
			do -- 451
				local _obj_0 = req.body -- 451
				local _type_1 = type(_obj_0) -- 451
				if "table" == _type_1 or "userdata" == _type_1 then -- 451
					row = _obj_0.row -- 451
				end -- 451
			end -- 451
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 451
				local searchPath = getSearchPath(file) -- 452
				if "tl" == lang or "lua" == lang then -- 453
					if CheckTIC80Code(content) then -- 454
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 455
					end -- 454
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 456
					if signatures then -- 456
						signatures = getParamDocs(signatures) -- 457
						if signatures then -- 457
							return { -- 458
								success = true, -- 458
								signatures = signatures -- 458
							} -- 458
						end -- 457
					end -- 456
				elseif "yue" == lang then -- 459
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 460
					if not luaCodes then -- 461
						return { -- 461
							success = false -- 461
						} -- 461
					end -- 461
					do -- 462
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 462
						if chainOp then -- 462
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 463
							if withVar then -- 463
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 464
							end -- 463
						end -- 462
					end -- 462
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 465
					if signatures then -- 465
						signatures = getParamDocs(signatures) -- 466
						if signatures then -- 466
							return { -- 467
								success = true, -- 467
								signatures = signatures -- 467
							} -- 467
						end -- 466
					else -- 468
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 468
						if signatures then -- 468
							signatures = getParamDocs(signatures) -- 469
							if signatures then -- 469
								return { -- 470
									success = true, -- 470
									signatures = signatures -- 470
								} -- 470
							end -- 469
						end -- 468
					end -- 465
				end -- 453
			end -- 451
		end -- 451
	end -- 451
	return { -- 450
		success = false -- 450
	} -- 450
end) -- 450
local luaKeywords = { -- 473
	'and', -- 473
	'break', -- 474
	'do', -- 475
	'else', -- 476
	'elseif', -- 477
	'end', -- 478
	'false', -- 479
	'for', -- 480
	'function', -- 481
	'goto', -- 482
	'if', -- 483
	'in', -- 484
	'local', -- 485
	'nil', -- 486
	'not', -- 487
	'or', -- 488
	'repeat', -- 489
	'return', -- 490
	'then', -- 491
	'true', -- 492
	'until', -- 493
	'while' -- 494
} -- 472
local tealKeywords = { -- 498
	'record', -- 498
	'as', -- 499
	'is', -- 500
	'type', -- 501
	'embed', -- 502
	'enum', -- 503
	'global', -- 504
	'any', -- 505
	'boolean', -- 506
	'integer', -- 507
	'number', -- 508
	'string', -- 509
	'thread' -- 510
} -- 497
local yueKeywords = { -- 514
	"and", -- 514
	"break", -- 515
	"do", -- 516
	"else", -- 517
	"elseif", -- 518
	"false", -- 519
	"for", -- 520
	"goto", -- 521
	"if", -- 522
	"in", -- 523
	"local", -- 524
	"nil", -- 525
	"not", -- 526
	"or", -- 527
	"repeat", -- 528
	"return", -- 529
	"then", -- 530
	"true", -- 531
	"until", -- 532
	"while", -- 533
	"as", -- 534
	"class", -- 535
	"continue", -- 536
	"export", -- 537
	"extends", -- 538
	"from", -- 539
	"global", -- 540
	"import", -- 541
	"macro", -- 542
	"switch", -- 543
	"try", -- 544
	"unless", -- 545
	"using", -- 546
	"when", -- 547
	"with" -- 548
} -- 513
local _anon_func_3 = function(f) -- 584
	local _val_0 = Path:getExt(f) -- 584
	return "ttf" == _val_0 or "otf" == _val_0 -- 584
end -- 584
local _anon_func_4 = function(suggestions) -- 610
	local _tbl_0 = { } -- 610
	for _index_0 = 1, #suggestions do -- 610
		local item = suggestions[_index_0] -- 610
		_tbl_0[item[1] .. item[2]] = item -- 610
	end -- 610
	return _tbl_0 -- 610
end -- 610
HttpServer:postSchedule("/complete", function(req) -- 551
	do -- 552
		local _type_0 = type(req) -- 552
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 552
		if _tab_0 then -- 552
			local lang -- 552
			do -- 552
				local _obj_0 = req.body -- 552
				local _type_1 = type(_obj_0) -- 552
				if "table" == _type_1 or "userdata" == _type_1 then -- 552
					lang = _obj_0.lang -- 552
				end -- 552
			end -- 552
			local file -- 552
			do -- 552
				local _obj_0 = req.body -- 552
				local _type_1 = type(_obj_0) -- 552
				if "table" == _type_1 or "userdata" == _type_1 then -- 552
					file = _obj_0.file -- 552
				end -- 552
			end -- 552
			local content -- 552
			do -- 552
				local _obj_0 = req.body -- 552
				local _type_1 = type(_obj_0) -- 552
				if "table" == _type_1 or "userdata" == _type_1 then -- 552
					content = _obj_0.content -- 552
				end -- 552
			end -- 552
			local line -- 552
			do -- 552
				local _obj_0 = req.body -- 552
				local _type_1 = type(_obj_0) -- 552
				if "table" == _type_1 or "userdata" == _type_1 then -- 552
					line = _obj_0.line -- 552
				end -- 552
			end -- 552
			local row -- 552
			do -- 552
				local _obj_0 = req.body -- 552
				local _type_1 = type(_obj_0) -- 552
				if "table" == _type_1 or "userdata" == _type_1 then -- 552
					row = _obj_0.row -- 552
				end -- 552
			end -- 552
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 552
				local searchPath = getSearchPath(file) -- 553
				repeat -- 554
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 555
					if lang == "yue" then -- 556
						if not item then -- 557
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 557
						end -- 557
						if not item then -- 558
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 558
						end -- 558
					end -- 556
					local searchType = nil -- 559
					if not item then -- 560
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 561
						if lang == "yue" then -- 562
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 563
						end -- 562
						if (item ~= nil) then -- 564
							searchType = "Image" -- 564
						end -- 564
					end -- 560
					if not item then -- 565
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 566
						if lang == "yue" then -- 567
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 568
						end -- 567
						if (item ~= nil) then -- 569
							searchType = "Font" -- 569
						end -- 569
					end -- 565
					if not item then -- 570
						break -- 570
					end -- 570
					local searchPaths = Content.searchPaths -- 571
					local _list_0 = getSearchFolders(file) -- 572
					for _index_0 = 1, #_list_0 do -- 572
						local folder = _list_0[_index_0] -- 572
						searchPaths[#searchPaths + 1] = folder -- 573
					end -- 572
					if searchType then -- 574
						searchPaths[#searchPaths + 1] = Content.assetPath -- 574
					end -- 574
					local tokens -- 575
					do -- 575
						local _accum_0 = { } -- 575
						local _len_0 = 1 -- 575
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 575
							_accum_0[_len_0] = mod -- 575
							_len_0 = _len_0 + 1 -- 575
						end -- 575
						tokens = _accum_0 -- 575
					end -- 575
					local suggestions = { } -- 576
					for _index_0 = 1, #searchPaths do -- 577
						local path = searchPaths[_index_0] -- 577
						local sPath = Path(path, table.unpack(tokens)) -- 578
						if not Content:exist(sPath) then -- 579
							goto _continue_0 -- 579
						end -- 579
						if searchType == "Font" then -- 580
							local fontPath = Path(sPath, "Font") -- 581
							if Content:exist(fontPath) then -- 582
								local _list_1 = Content:getFiles(fontPath) -- 583
								for _index_1 = 1, #_list_1 do -- 583
									local f = _list_1[_index_1] -- 583
									if _anon_func_3(f) then -- 584
										if "." == f:sub(1, 1) then -- 585
											goto _continue_1 -- 585
										end -- 585
										suggestions[#suggestions + 1] = { -- 586
											Path:getName(f), -- 586
											"font", -- 586
											"field" -- 586
										} -- 586
									end -- 584
									::_continue_1:: -- 584
								end -- 583
							end -- 582
						end -- 580
						local _list_1 = Content:getFiles(sPath) -- 587
						for _index_1 = 1, #_list_1 do -- 587
							local f = _list_1[_index_1] -- 587
							if "Image" == searchType then -- 588
								do -- 589
									local _exp_0 = Path:getExt(f) -- 589
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 589
										if "." == f:sub(1, 1) then -- 590
											goto _continue_2 -- 590
										end -- 590
										suggestions[#suggestions + 1] = { -- 591
											f, -- 591
											"image", -- 591
											"field" -- 591
										} -- 591
									end -- 589
								end -- 589
								goto _continue_2 -- 592
							elseif "Font" == searchType then -- 593
								do -- 594
									local _exp_0 = Path:getExt(f) -- 594
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 594
										if "." == f:sub(1, 1) then -- 595
											goto _continue_2 -- 595
										end -- 595
										suggestions[#suggestions + 1] = { -- 596
											f, -- 596
											"font", -- 596
											"field" -- 596
										} -- 596
									end -- 594
								end -- 594
								goto _continue_2 -- 597
							end -- 588
							local _exp_0 = Path:getExt(f) -- 598
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 598
								local name = Path:getName(f) -- 599
								if "d" == Path:getExt(name) then -- 600
									goto _continue_2 -- 600
								end -- 600
								if "." == name:sub(1, 1) then -- 601
									goto _continue_2 -- 601
								end -- 601
								suggestions[#suggestions + 1] = { -- 602
									name, -- 602
									"module", -- 602
									"field" -- 602
								} -- 602
							end -- 598
							::_continue_2:: -- 588
						end -- 587
						local _list_2 = Content:getDirs(sPath) -- 603
						for _index_1 = 1, #_list_2 do -- 603
							local dir = _list_2[_index_1] -- 603
							if "." == dir:sub(1, 1) then -- 604
								goto _continue_3 -- 604
							end -- 604
							suggestions[#suggestions + 1] = { -- 605
								dir, -- 605
								"folder", -- 605
								"variable" -- 605
							} -- 605
							::_continue_3:: -- 604
						end -- 603
						::_continue_0:: -- 578
					end -- 577
					if item == "" and not searchType then -- 606
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 607
						for _index_0 = 1, #_list_1 do -- 607
							local _des_0 = _list_1[_index_0] -- 607
							local name = _des_0[1] -- 607
							suggestions[#suggestions + 1] = { -- 608
								name, -- 608
								"dora module", -- 608
								"function" -- 608
							} -- 608
						end -- 607
					end -- 606
					if #suggestions > 0 then -- 609
						do -- 610
							local _accum_0 = { } -- 610
							local _len_0 = 1 -- 610
							for _, v in pairs(_anon_func_4(suggestions)) do -- 610
								_accum_0[_len_0] = v -- 610
								_len_0 = _len_0 + 1 -- 610
							end -- 610
							suggestions = _accum_0 -- 610
						end -- 610
						return { -- 611
							success = true, -- 611
							suggestions = suggestions -- 611
						} -- 611
					else -- 613
						return { -- 613
							success = false -- 613
						} -- 613
					end -- 609
				until true -- 554
				if "tl" == lang or "lua" == lang then -- 615
					do -- 616
						local isTIC80 = CheckTIC80Code(content) -- 616
						if isTIC80 then -- 616
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 617
						end -- 616
					end -- 616
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 618
					if not line:match("[%.:]$") then -- 619
						local checkSet -- 620
						do -- 620
							local _tbl_0 = { } -- 620
							for _index_0 = 1, #suggestions do -- 620
								local _des_0 = suggestions[_index_0] -- 620
								local name = _des_0[1] -- 620
								_tbl_0[name] = true -- 620
							end -- 620
							checkSet = _tbl_0 -- 620
						end -- 620
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 621
						for _index_0 = 1, #_list_0 do -- 621
							local item = _list_0[_index_0] -- 621
							if not checkSet[item[1]] then -- 622
								suggestions[#suggestions + 1] = item -- 622
							end -- 622
						end -- 621
						for _index_0 = 1, #luaKeywords do -- 623
							local word = luaKeywords[_index_0] -- 623
							suggestions[#suggestions + 1] = { -- 624
								word, -- 624
								"keyword", -- 624
								"keyword" -- 624
							} -- 624
						end -- 623
						if lang == "tl" then -- 625
							for _index_0 = 1, #tealKeywords do -- 626
								local word = tealKeywords[_index_0] -- 626
								suggestions[#suggestions + 1] = { -- 627
									word, -- 627
									"keyword", -- 627
									"keyword" -- 627
								} -- 627
							end -- 626
						end -- 625
					end -- 619
					if #suggestions > 0 then -- 628
						return { -- 629
							success = true, -- 629
							suggestions = suggestions -- 629
						} -- 629
					end -- 628
				elseif "yue" == lang then -- 630
					local suggestions = { } -- 631
					local gotGlobals = false -- 632
					do -- 633
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 633
						if luaCodes then -- 633
							gotGlobals = true -- 634
							do -- 635
								local chainOp = line:match("[^%w_]([%.\\])$") -- 635
								if chainOp then -- 635
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 636
									if not withVar then -- 637
										return { -- 637
											success = false -- 637
										} -- 637
									end -- 637
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 638
								elseif line:match("^([%.\\])$") then -- 639
									return { -- 640
										success = false -- 640
									} -- 640
								end -- 635
							end -- 635
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 641
							for _index_0 = 1, #_list_0 do -- 641
								local item = _list_0[_index_0] -- 641
								suggestions[#suggestions + 1] = item -- 641
							end -- 641
							if #suggestions == 0 then -- 642
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 643
								for _index_0 = 1, #_list_1 do -- 643
									local item = _list_1[_index_0] -- 643
									suggestions[#suggestions + 1] = item -- 643
								end -- 643
							end -- 642
						end -- 633
					end -- 633
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 644
						local checkSet -- 645
						do -- 645
							local _tbl_0 = { } -- 645
							for _index_0 = 1, #suggestions do -- 645
								local _des_0 = suggestions[_index_0] -- 645
								local name = _des_0[1] -- 645
								_tbl_0[name] = true -- 645
							end -- 645
							checkSet = _tbl_0 -- 645
						end -- 645
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 646
						for _index_0 = 1, #_list_0 do -- 646
							local item = _list_0[_index_0] -- 646
							if not checkSet[item[1]] then -- 647
								suggestions[#suggestions + 1] = item -- 647
							end -- 647
						end -- 646
						if not gotGlobals then -- 648
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 649
							for _index_0 = 1, #_list_1 do -- 649
								local item = _list_1[_index_0] -- 649
								if not checkSet[item[1]] then -- 650
									suggestions[#suggestions + 1] = item -- 650
								end -- 650
							end -- 649
						end -- 648
						for _index_0 = 1, #yueKeywords do -- 651
							local word = yueKeywords[_index_0] -- 651
							if not checkSet[word] then -- 652
								suggestions[#suggestions + 1] = { -- 653
									word, -- 653
									"keyword", -- 653
									"keyword" -- 653
								} -- 653
							end -- 652
						end -- 651
					end -- 644
					if #suggestions > 0 then -- 654
						return { -- 655
							success = true, -- 655
							suggestions = suggestions -- 655
						} -- 655
					end -- 654
				elseif "xml" == lang then -- 656
					local items = xml.complete(content) -- 657
					if #items > 0 then -- 658
						local suggestions -- 659
						do -- 659
							local _accum_0 = { } -- 659
							local _len_0 = 1 -- 659
							for _index_0 = 1, #items do -- 659
								local _des_0 = items[_index_0] -- 659
								local label, insertText = _des_0[1], _des_0[2] -- 659
								_accum_0[_len_0] = { -- 660
									label, -- 660
									insertText, -- 660
									"field" -- 660
								} -- 660
								_len_0 = _len_0 + 1 -- 660
							end -- 659
							suggestions = _accum_0 -- 659
						end -- 659
						return { -- 661
							success = true, -- 661
							suggestions = suggestions -- 661
						} -- 661
					end -- 658
				end -- 615
			end -- 552
		end -- 552
	end -- 552
	return { -- 551
		success = false -- 551
	} -- 551
end) -- 551
HttpServer:upload("/upload", function(req, filename) -- 665
	do -- 666
		local _type_0 = type(req) -- 666
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 666
		if _tab_0 then -- 666
			local path -- 666
			do -- 666
				local _obj_0 = req.params -- 666
				local _type_1 = type(_obj_0) -- 666
				if "table" == _type_1 or "userdata" == _type_1 then -- 666
					path = _obj_0.path -- 666
				end -- 666
			end -- 666
			if path ~= nil then -- 666
				local uploadPath = Path(Content.writablePath, ".upload") -- 667
				if not Content:exist(uploadPath) then -- 668
					Content:mkdir(uploadPath) -- 669
				end -- 668
				local targetPath = Path(uploadPath, filename) -- 670
				Content:mkdir(Path:getPath(targetPath)) -- 671
				return targetPath -- 672
			end -- 666
		end -- 666
	end -- 666
	return nil -- 665
end, function(req, file) -- 673
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
				path = Path(Content.writablePath, path) -- 675
				if Content:exist(path) then -- 676
					local uploadPath = Path(Content.writablePath, ".upload") -- 677
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 678
					Content:mkdir(Path:getPath(targetPath)) -- 679
					if Content:move(file, targetPath) then -- 680
						return true -- 681
					end -- 680
				end -- 676
			end -- 674
		end -- 674
	end -- 674
	return false -- 673
end) -- 663
HttpServer:post("/list", function(req) -- 684
	do -- 685
		local _type_0 = type(req) -- 685
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 685
		if _tab_0 then -- 685
			local path -- 685
			do -- 685
				local _obj_0 = req.body -- 685
				local _type_1 = type(_obj_0) -- 685
				if "table" == _type_1 or "userdata" == _type_1 then -- 685
					path = _obj_0.path -- 685
				end -- 685
			end -- 685
			if path ~= nil then -- 685
				if Content:exist(path) then -- 686
					local files = { } -- 687
					local visitAssets -- 688
					visitAssets = function(path, folder) -- 688
						local dirs = Content:getDirs(path) -- 689
						for _index_0 = 1, #dirs do -- 690
							local dir = dirs[_index_0] -- 690
							if dir:match("^%.") then -- 691
								goto _continue_0 -- 691
							end -- 691
							local current -- 692
							if folder == "" then -- 692
								current = dir -- 693
							else -- 695
								current = Path(folder, dir) -- 695
							end -- 692
							files[#files + 1] = current -- 696
							visitAssets(Path(path, dir), current) -- 697
							::_continue_0:: -- 691
						end -- 690
						local fs = Content:getFiles(path) -- 698
						for _index_0 = 1, #fs do -- 699
							local f = fs[_index_0] -- 699
							if f:match("^%.") then -- 700
								goto _continue_1 -- 700
							end -- 700
							if folder == "" then -- 701
								files[#files + 1] = f -- 702
							else -- 704
								files[#files + 1] = Path(folder, f) -- 704
							end -- 701
							::_continue_1:: -- 700
						end -- 699
					end -- 688
					visitAssets(path, "") -- 705
					if #files == 0 then -- 706
						files = nil -- 706
					end -- 706
					return { -- 707
						success = true, -- 707
						files = files -- 707
					} -- 707
				end -- 686
			end -- 685
		end -- 685
	end -- 685
	return { -- 684
		success = false -- 684
	} -- 684
end) -- 684
HttpServer:post("/info", function() -- 709
	local Entry = require("Script.Dev.Entry") -- 710
	local webProfiler, drawerWidth -- 711
	do -- 711
		local _obj_0 = Entry.getConfig() -- 711
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 711
	end -- 711
	local engineDev = Entry.getEngineDev() -- 712
	Entry.connectWebIDE() -- 713
	return { -- 715
		platform = App.platform, -- 715
		locale = App.locale, -- 716
		version = App.version, -- 717
		engineDev = engineDev, -- 718
		webProfiler = webProfiler, -- 719
		drawerWidth = drawerWidth -- 720
	} -- 714
end) -- 709
local ensureLLMConfigTable -- 722
ensureLLMConfigTable = function() -- 722
	return DB:exec([[		CREATE TABLE IF NOT EXISTS LLMConfig(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			url TEXT NOT NULL,
			model TEXT NOT NULL,
			api_key TEXT NOT NULL,
			active INTEGER NOT NULL DEFAULT 1,
			created_at INTEGER,
			updated_at INTEGER
		);
	]]) -- 723
end -- 722
HttpServer:post("/llm/list", function() -- 736
	ensureLLMConfigTable() -- 737
	local rows = DB:query("\n		select id, name, url, model, api_key, active\n		from LLMConfig\n		order by id asc") -- 738
	local items -- 742
	if rows and #rows > 0 then -- 742
		local _accum_0 = { } -- 743
		local _len_0 = 1 -- 743
		for _index_0 = 1, #rows do -- 743
			local _des_0 = rows[_index_0] -- 743
			local id, name, url, model, key, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6] -- 743
			_accum_0[_len_0] = { -- 744
				id = id, -- 744
				name = name, -- 744
				url = url, -- 744
				model = model, -- 744
				key = key, -- 744
				active = active ~= 0 -- 744
			} -- 744
			_len_0 = _len_0 + 1 -- 744
		end -- 743
		items = _accum_0 -- 742
	end -- 742
	return { -- 745
		success = true, -- 745
		items = items -- 745
	} -- 745
end) -- 736
HttpServer:post("/llm/create", function(req) -- 747
	ensureLLMConfigTable() -- 748
	do -- 749
		local _type_0 = type(req) -- 749
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 749
		if _tab_0 then -- 749
			local body = req.body -- 749
			if body ~= nil then -- 749
				local name, url, model, key, active = body.name, body.url, body.model, body.key, body.active -- 750
				local now = os.time() -- 751
				if name == nil or url == nil or model == nil or key == nil then -- 752
					return { -- 753
						success = false, -- 753
						message = "invalid" -- 753
					} -- 753
				end -- 752
				if active then -- 754
					active = 1 -- 754
				else -- 754
					active = 0 -- 754
				end -- 754
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?\n			)", { -- 761
					tostring(name), -- 761
					tostring(url), -- 762
					tostring(model), -- 763
					tostring(key), -- 764
					active, -- 765
					now, -- 766
					now -- 767
				}) -- 755
				return { -- 769
					success = affected >= 0 -- 769
				} -- 769
			end -- 749
		end -- 749
	end -- 749
	return { -- 747
		success = false, -- 747
		message = "invalid" -- 747
	} -- 747
end) -- 747
HttpServer:post("/llm/update", function(req) -- 771
	ensureLLMConfigTable() -- 772
	do -- 773
		local _type_0 = type(req) -- 773
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 773
		if _tab_0 then -- 773
			local body = req.body -- 773
			if body ~= nil then -- 773
				local id, name, url, model, key, active = body.id, body.name, body.url, body.model, body.key, body.active -- 774
				local now = os.time() -- 775
				id = tonumber(id) -- 776
				if id == nil then -- 777
					return { -- 778
						success = false, -- 778
						message = "invalid" -- 778
					} -- 778
				end -- 777
				if active then -- 779
					active = 1 -- 779
				else -- 779
					active = 0 -- 779
				end -- 779
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, active = ?, updated_at = ?\n			where id = ?", { -- 784
					tostring(name), -- 784
					tostring(url), -- 785
					tostring(model), -- 786
					tostring(key), -- 787
					active, -- 788
					now, -- 789
					id -- 790
				}) -- 780
				return { -- 792
					success = affected >= 0 -- 792
				} -- 792
			end -- 773
		end -- 773
	end -- 773
	return { -- 771
		success = false, -- 771
		message = "invalid" -- 771
	} -- 771
end) -- 771
HttpServer:post("/llm/delete", function(req) -- 794
	ensureLLMConfigTable() -- 795
	do -- 796
		local _type_0 = type(req) -- 796
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 796
		if _tab_0 then -- 796
			local id -- 796
			do -- 796
				local _obj_0 = req.body -- 796
				local _type_1 = type(_obj_0) -- 796
				if "table" == _type_1 or "userdata" == _type_1 then -- 796
					id = _obj_0.id -- 796
				end -- 796
			end -- 796
			if id ~= nil then -- 796
				id = tonumber(id) -- 797
				if id == nil then -- 798
					return { -- 799
						success = false, -- 799
						message = "invalid" -- 799
					} -- 799
				end -- 798
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 800
					id -- 800
				}) -- 800
				return { -- 801
					success = affected >= 0 -- 801
				} -- 801
			end -- 796
		end -- 796
	end -- 796
	return { -- 794
		success = false, -- 794
		message = "invalid" -- 794
	} -- 794
end) -- 794
HttpServer:post("/new", function(req) -- 803
	do -- 804
		local _type_0 = type(req) -- 804
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 804
		if _tab_0 then -- 804
			local path -- 804
			do -- 804
				local _obj_0 = req.body -- 804
				local _type_1 = type(_obj_0) -- 804
				if "table" == _type_1 or "userdata" == _type_1 then -- 804
					path = _obj_0.path -- 804
				end -- 804
			end -- 804
			local content -- 804
			do -- 804
				local _obj_0 = req.body -- 804
				local _type_1 = type(_obj_0) -- 804
				if "table" == _type_1 or "userdata" == _type_1 then -- 804
					content = _obj_0.content -- 804
				end -- 804
			end -- 804
			local folder -- 804
			do -- 804
				local _obj_0 = req.body -- 804
				local _type_1 = type(_obj_0) -- 804
				if "table" == _type_1 or "userdata" == _type_1 then -- 804
					folder = _obj_0.folder -- 804
				end -- 804
			end -- 804
			if path ~= nil and content ~= nil and folder ~= nil then -- 804
				if Content:exist(path) then -- 805
					return { -- 806
						success = false, -- 806
						message = "TargetExisted" -- 806
					} -- 806
				end -- 805
				local parent = Path:getPath(path) -- 807
				local files = Content:getFiles(parent) -- 808
				if folder then -- 809
					local name = Path:getFilename(path):lower() -- 810
					for _index_0 = 1, #files do -- 811
						local file = files[_index_0] -- 811
						if name == Path:getFilename(file):lower() then -- 812
							return { -- 813
								success = false, -- 813
								message = "TargetExisted" -- 813
							} -- 813
						end -- 812
					end -- 811
					if Content:mkdir(path) then -- 814
						return { -- 815
							success = true -- 815
						} -- 815
					end -- 814
				else -- 817
					local name = Path:getName(path):lower() -- 817
					for _index_0 = 1, #files do -- 818
						local file = files[_index_0] -- 818
						if name == Path:getName(file):lower() then -- 819
							local ext = Path:getExt(file) -- 820
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 821
								goto _continue_0 -- 822
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 823
								goto _continue_0 -- 824
							end -- 821
							return { -- 825
								success = false, -- 825
								message = "SourceExisted" -- 825
							} -- 825
						end -- 819
						::_continue_0:: -- 819
					end -- 818
					if Content:save(path, content) then -- 826
						return { -- 827
							success = true -- 827
						} -- 827
					end -- 826
				end -- 809
			end -- 804
		end -- 804
	end -- 804
	return { -- 803
		success = false, -- 803
		message = "Failed" -- 803
	} -- 803
end) -- 803
HttpServer:post("/delete", function(req) -- 829
	do -- 830
		local _type_0 = type(req) -- 830
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 830
		if _tab_0 then -- 830
			local path -- 830
			do -- 830
				local _obj_0 = req.body -- 830
				local _type_1 = type(_obj_0) -- 830
				if "table" == _type_1 or "userdata" == _type_1 then -- 830
					path = _obj_0.path -- 830
				end -- 830
			end -- 830
			if path ~= nil then -- 830
				if Content:exist(path) then -- 831
					local parent = Path:getPath(path) -- 832
					local files = Content:getFiles(parent) -- 833
					local name = Path:getName(path):lower() -- 834
					local ext = Path:getExt(path) -- 835
					for _index_0 = 1, #files do -- 836
						local file = files[_index_0] -- 836
						if name == Path:getName(file):lower() then -- 837
							local _exp_0 = Path:getExt(file) -- 838
							if "tl" == _exp_0 then -- 838
								if ("vs" == ext) then -- 838
									Content:remove(Path(parent, file)) -- 839
								end -- 838
							elseif "lua" == _exp_0 then -- 840
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 840
									Content:remove(Path(parent, file)) -- 841
								end -- 840
							end -- 838
						end -- 837
					end -- 836
					if Content:remove(path) then -- 842
						return { -- 843
							success = true -- 843
						} -- 843
					end -- 842
				end -- 831
			end -- 830
		end -- 830
	end -- 830
	return { -- 829
		success = false -- 829
	} -- 829
end) -- 829
HttpServer:post("/rename", function(req) -- 845
	do -- 846
		local _type_0 = type(req) -- 846
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 846
		if _tab_0 then -- 846
			local old -- 846
			do -- 846
				local _obj_0 = req.body -- 846
				local _type_1 = type(_obj_0) -- 846
				if "table" == _type_1 or "userdata" == _type_1 then -- 846
					old = _obj_0.old -- 846
				end -- 846
			end -- 846
			local new -- 846
			do -- 846
				local _obj_0 = req.body -- 846
				local _type_1 = type(_obj_0) -- 846
				if "table" == _type_1 or "userdata" == _type_1 then -- 846
					new = _obj_0.new -- 846
				end -- 846
			end -- 846
			if old ~= nil and new ~= nil then -- 846
				if Content:exist(old) and not Content:exist(new) then -- 847
					local parent = Path:getPath(new) -- 848
					local files = Content:getFiles(parent) -- 849
					if Content:isdir(old) then -- 850
						local name = Path:getFilename(new):lower() -- 851
						for _index_0 = 1, #files do -- 852
							local file = files[_index_0] -- 852
							if name == Path:getFilename(file):lower() then -- 853
								return { -- 854
									success = false -- 854
								} -- 854
							end -- 853
						end -- 852
					else -- 856
						local name = Path:getName(new):lower() -- 856
						local ext = Path:getExt(new) -- 857
						for _index_0 = 1, #files do -- 858
							local file = files[_index_0] -- 858
							if name == Path:getName(file):lower() then -- 859
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 860
									goto _continue_0 -- 861
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 862
									goto _continue_0 -- 863
								end -- 860
								return { -- 864
									success = false -- 864
								} -- 864
							end -- 859
							::_continue_0:: -- 859
						end -- 858
					end -- 850
					if Content:move(old, new) then -- 865
						local newParent = Path:getPath(new) -- 866
						parent = Path:getPath(old) -- 867
						files = Content:getFiles(parent) -- 868
						local newName = Path:getName(new) -- 869
						local oldName = Path:getName(old) -- 870
						local name = oldName:lower() -- 871
						local ext = Path:getExt(old) -- 872
						for _index_0 = 1, #files do -- 873
							local file = files[_index_0] -- 873
							if name == Path:getName(file):lower() then -- 874
								local _exp_0 = Path:getExt(file) -- 875
								if "tl" == _exp_0 then -- 875
									if ("vs" == ext) then -- 875
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 876
									end -- 875
								elseif "lua" == _exp_0 then -- 877
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 877
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 878
									end -- 877
								end -- 875
							end -- 874
						end -- 873
						return { -- 879
							success = true -- 879
						} -- 879
					end -- 865
				end -- 847
			end -- 846
		end -- 846
	end -- 846
	return { -- 845
		success = false -- 845
	} -- 845
end) -- 845
HttpServer:post("/exist", function(req) -- 881
	do -- 882
		local _type_0 = type(req) -- 882
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 882
		if _tab_0 then -- 882
			local file -- 882
			do -- 882
				local _obj_0 = req.body -- 882
				local _type_1 = type(_obj_0) -- 882
				if "table" == _type_1 or "userdata" == _type_1 then -- 882
					file = _obj_0.file -- 882
				end -- 882
			end -- 882
			if file ~= nil then -- 882
				do -- 883
					local projFile = req.body.projFile -- 883
					if projFile then -- 883
						local projDir = getProjectDirFromFile(projFile) -- 884
						if projDir then -- 884
							local scriptDir = Path(projDir, "Script") -- 885
							local searchPaths = Content.searchPaths -- 886
							if Content:exist(scriptDir) then -- 887
								Content:addSearchPath(scriptDir) -- 887
							end -- 887
							if Content:exist(projDir) then -- 888
								Content:addSearchPath(projDir) -- 888
							end -- 888
							local _ <close> = setmetatable({ }, { -- 889
								__close = function() -- 889
									Content.searchPaths = searchPaths -- 889
								end -- 889
							}) -- 889
							return { -- 890
								success = Content:exist(file) -- 890
							} -- 890
						end -- 884
					end -- 883
				end -- 883
				return { -- 891
					success = Content:exist(file) -- 891
				} -- 891
			end -- 882
		end -- 882
	end -- 882
	return { -- 881
		success = false -- 881
	} -- 881
end) -- 881
HttpServer:postSchedule("/read", function(req) -- 893
	do -- 894
		local _type_0 = type(req) -- 894
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 894
		if _tab_0 then -- 894
			local path -- 894
			do -- 894
				local _obj_0 = req.body -- 894
				local _type_1 = type(_obj_0) -- 894
				if "table" == _type_1 or "userdata" == _type_1 then -- 894
					path = _obj_0.path -- 894
				end -- 894
			end -- 894
			if path ~= nil then -- 894
				local readFile -- 895
				readFile = function() -- 895
					if Content:exist(path) then -- 896
						local content = Content:loadAsync(path) -- 897
						if content then -- 897
							return { -- 898
								content = content, -- 898
								success = true -- 898
							} -- 898
						end -- 897
					end -- 896
					return nil -- 895
				end -- 895
				do -- 899
					local projFile = req.body.projFile -- 899
					if projFile then -- 899
						local projDir = getProjectDirFromFile(projFile) -- 900
						if projDir then -- 900
							local scriptDir = Path(projDir, "Script") -- 901
							local searchPaths = Content.searchPaths -- 902
							if Content:exist(scriptDir) then -- 903
								Content:addSearchPath(scriptDir) -- 903
							end -- 903
							if Content:exist(projDir) then -- 904
								Content:addSearchPath(projDir) -- 904
							end -- 904
							local _ <close> = setmetatable({ }, { -- 905
								__close = function() -- 905
									Content.searchPaths = searchPaths -- 905
								end -- 905
							}) -- 905
							local result = readFile() -- 906
							if result then -- 906
								return result -- 906
							end -- 906
						end -- 900
					end -- 899
				end -- 899
				local result = readFile() -- 907
				if result then -- 907
					return result -- 907
				end -- 907
			end -- 894
		end -- 894
	end -- 894
	return { -- 893
		success = false -- 893
	} -- 893
end) -- 893
HttpServer:get("/read-sync", function(req) -- 909
	do -- 910
		local _type_0 = type(req) -- 910
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 910
		if _tab_0 then -- 910
			local params = req.params -- 910
			if params ~= nil then -- 910
				local path = params.path -- 911
				local exts -- 912
				if params.exts then -- 912
					local _accum_0 = { } -- 913
					local _len_0 = 1 -- 913
					for ext in params.exts:gmatch("[^|]*") do -- 913
						_accum_0[_len_0] = ext -- 914
						_len_0 = _len_0 + 1 -- 914
					end -- 913
					exts = _accum_0 -- 912
				else -- 915
					exts = { -- 915
						"" -- 915
					} -- 915
				end -- 912
				local readFile -- 916
				readFile = function() -- 916
					for _index_0 = 1, #exts do -- 917
						local ext = exts[_index_0] -- 917
						local targetPath = path .. ext -- 918
						if Content:exist(targetPath) then -- 919
							local content = Content:load(targetPath) -- 920
							if content then -- 920
								return { -- 921
									content = content, -- 921
									success = true, -- 921
									fullPath = Content:getFullPath(targetPath) -- 921
								} -- 921
							end -- 920
						end -- 919
					end -- 917
					return nil -- 916
				end -- 916
				local searchPaths = Content.searchPaths -- 922
				local _ <close> = setmetatable({ }, { -- 923
					__close = function() -- 923
						Content.searchPaths = searchPaths -- 923
					end -- 923
				}) -- 923
				do -- 924
					local projFile = req.params.projFile -- 924
					if projFile then -- 924
						local projDir = getProjectDirFromFile(projFile) -- 925
						if projDir then -- 925
							local scriptDir = Path(projDir, "Script") -- 926
							if Content:exist(scriptDir) then -- 927
								Content:addSearchPath(scriptDir) -- 927
							end -- 927
							if Content:exist(projDir) then -- 928
								Content:addSearchPath(projDir) -- 928
							end -- 928
						else -- 930
							projDir = Path:getPath(projFile) -- 930
							if Content:exist(projDir) then -- 931
								Content:addSearchPath(projDir) -- 931
							end -- 931
						end -- 925
					end -- 924
				end -- 924
				local result = readFile() -- 932
				if result then -- 932
					return result -- 932
				end -- 932
			end -- 910
		end -- 910
	end -- 910
	return { -- 909
		success = false -- 909
	} -- 909
end) -- 909
local compileFileAsync -- 934
compileFileAsync = function(inputFile, sourceCodes) -- 934
	local file = inputFile -- 935
	local searchPath -- 936
	do -- 936
		local dir = getProjectDirFromFile(inputFile) -- 936
		if dir then -- 936
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 937
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 938
		else -- 940
			file = Path:getRelative(inputFile, Content.writablePath) -- 940
			if file:sub(1, 2) == ".." then -- 941
				file = Path:getRelative(inputFile, Content.assetPath) -- 942
			end -- 941
			searchPath = "" -- 943
		end -- 936
	end -- 936
	local outputFile = Path:replaceExt(inputFile, "lua") -- 944
	local yueext = yue.options.extension -- 945
	local resultCodes = nil -- 946
	local resultError = nil -- 947
	do -- 948
		local _exp_0 = Path:getExt(inputFile) -- 948
		if yueext == _exp_0 then -- 948
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 949
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 950
				if not codes then -- 951
					resultError = err -- 952
					return -- 953
				end -- 951
				local extraGlobal -- 954
				if isTIC80 then -- 954
					extraGlobal = tic80APIs -- 954
				else -- 954
					extraGlobal = nil -- 954
				end -- 954
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 955
				if not success then -- 956
					resultError = message -- 957
					return -- 958
				end -- 956
				if codes == "" then -- 959
					resultCodes = "" -- 960
					return nil -- 961
				end -- 959
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 962
				return resultCodes -- 963
			end, function(success) -- 950
				if not success then -- 964
					Content:remove(outputFile) -- 965
					if resultCodes == nil then -- 966
						resultCodes = false -- 967
					end -- 966
				end -- 964
			end) -- 950
		elseif "tl" == _exp_0 then -- 968
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 969
			if isTIC80 then -- 970
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 971
			end -- 970
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 972
			if codes then -- 972
				if isTIC80 then -- 973
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 974
				end -- 973
				resultCodes = codes -- 975
				Content:saveAsync(outputFile, codes) -- 976
			else -- 978
				Content:remove(outputFile) -- 978
				resultCodes = false -- 979
				resultError = err -- 980
			end -- 972
		elseif "xml" == _exp_0 then -- 981
			local codes, err = xml.tolua(sourceCodes) -- 982
			if codes then -- 982
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 983
				Content:saveAsync(outputFile, resultCodes) -- 984
			else -- 986
				Content:remove(outputFile) -- 986
				resultCodes = false -- 987
				resultError = err -- 988
			end -- 982
		end -- 948
	end -- 948
	wait(function() -- 989
		return resultCodes ~= nil -- 989
	end) -- 989
	if resultCodes then -- 990
		return resultCodes -- 991
	else -- 993
		return nil, resultError -- 993
	end -- 990
	return nil -- 934
end -- 934
HttpServer:postSchedule("/write", function(req) -- 995
	do -- 996
		local _type_0 = type(req) -- 996
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 996
		if _tab_0 then -- 996
			local path -- 996
			do -- 996
				local _obj_0 = req.body -- 996
				local _type_1 = type(_obj_0) -- 996
				if "table" == _type_1 or "userdata" == _type_1 then -- 996
					path = _obj_0.path -- 996
				end -- 996
			end -- 996
			local content -- 996
			do -- 996
				local _obj_0 = req.body -- 996
				local _type_1 = type(_obj_0) -- 996
				if "table" == _type_1 or "userdata" == _type_1 then -- 996
					content = _obj_0.content -- 996
				end -- 996
			end -- 996
			if path ~= nil and content ~= nil then -- 996
				if Content:saveAsync(path, content) then -- 997
					do -- 998
						local _exp_0 = Path:getExt(path) -- 998
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 998
							if '' == Path:getExt(Path:getName(path)) then -- 999
								local resultCodes = compileFileAsync(path, content) -- 1000
								return { -- 1001
									success = true, -- 1001
									resultCodes = resultCodes -- 1001
								} -- 1001
							end -- 999
						end -- 998
					end -- 998
					return { -- 1002
						success = true -- 1002
					} -- 1002
				end -- 997
			end -- 996
		end -- 996
	end -- 996
	return { -- 995
		success = false -- 995
	} -- 995
end) -- 995
HttpServer:postSchedule("/build", function(req) -- 1004
	do -- 1005
		local _type_0 = type(req) -- 1005
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1005
		if _tab_0 then -- 1005
			local path -- 1005
			do -- 1005
				local _obj_0 = req.body -- 1005
				local _type_1 = type(_obj_0) -- 1005
				if "table" == _type_1 or "userdata" == _type_1 then -- 1005
					path = _obj_0.path -- 1005
				end -- 1005
			end -- 1005
			if path ~= nil then -- 1005
				local _exp_0 = Path:getExt(path) -- 1006
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1006
					if '' == Path:getExt(Path:getName(path)) then -- 1007
						local content = Content:loadAsync(path) -- 1008
						if content then -- 1008
							local resultCodes = compileFileAsync(path, content) -- 1009
							if resultCodes then -- 1009
								return { -- 1010
									success = true, -- 1010
									resultCodes = resultCodes -- 1010
								} -- 1010
							end -- 1009
						end -- 1008
					end -- 1007
				end -- 1006
			end -- 1005
		end -- 1005
	end -- 1005
	return { -- 1004
		success = false -- 1004
	} -- 1004
end) -- 1004
local extentionLevels = { -- 1013
	vs = 2, -- 1013
	bl = 2, -- 1014
	ts = 1, -- 1015
	tsx = 1, -- 1016
	tl = 1, -- 1017
	yue = 1, -- 1018
	xml = 1, -- 1019
	lua = 0 -- 1020
} -- 1012
HttpServer:post("/assets", function() -- 1022
	local Entry = require("Script.Dev.Entry") -- 1025
	local engineDev = Entry.getEngineDev() -- 1026
	local visitAssets -- 1027
	visitAssets = function(path, tag) -- 1027
		local isWorkspace = tag == "Workspace" -- 1028
		local builtin -- 1029
		if tag == "Builtin" then -- 1029
			builtin = true -- 1029
		else -- 1029
			builtin = nil -- 1029
		end -- 1029
		local children = nil -- 1030
		local dirs = Content:getDirs(path) -- 1031
		for _index_0 = 1, #dirs do -- 1032
			local dir = dirs[_index_0] -- 1032
			if isWorkspace then -- 1033
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1034
					goto _continue_0 -- 1035
				end -- 1034
			elseif dir == ".git" then -- 1036
				goto _continue_0 -- 1037
			end -- 1033
			if not children then -- 1038
				children = { } -- 1038
			end -- 1038
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1039
			::_continue_0:: -- 1033
		end -- 1032
		local files = Content:getFiles(path) -- 1040
		local names = { } -- 1041
		for _index_0 = 1, #files do -- 1042
			local file = files[_index_0] -- 1042
			if file:match("^%.") then -- 1043
				goto _continue_1 -- 1043
			end -- 1043
			local name = Path:getName(file) -- 1044
			local ext = names[name] -- 1045
			if ext then -- 1045
				local lv1 -- 1046
				do -- 1046
					local _exp_0 = extentionLevels[ext] -- 1046
					if _exp_0 ~= nil then -- 1046
						lv1 = _exp_0 -- 1046
					else -- 1046
						lv1 = -1 -- 1046
					end -- 1046
				end -- 1046
				ext = Path:getExt(file) -- 1047
				local lv2 -- 1048
				do -- 1048
					local _exp_0 = extentionLevels[ext] -- 1048
					if _exp_0 ~= nil then -- 1048
						lv2 = _exp_0 -- 1048
					else -- 1048
						lv2 = -1 -- 1048
					end -- 1048
				end -- 1048
				if lv2 > lv1 then -- 1049
					names[name] = ext -- 1050
				elseif lv2 == lv1 then -- 1051
					names[name .. '.' .. ext] = "" -- 1052
				end -- 1049
			else -- 1054
				ext = Path:getExt(file) -- 1054
				if not extentionLevels[ext] then -- 1055
					names[file] = "" -- 1056
				else -- 1058
					names[name] = ext -- 1058
				end -- 1055
			end -- 1045
			::_continue_1:: -- 1043
		end -- 1042
		do -- 1059
			local _accum_0 = { } -- 1059
			local _len_0 = 1 -- 1059
			for name, ext in pairs(names) do -- 1059
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1059
				_len_0 = _len_0 + 1 -- 1059
			end -- 1059
			files = _accum_0 -- 1059
		end -- 1059
		for _index_0 = 1, #files do -- 1060
			local file = files[_index_0] -- 1060
			if not children then -- 1061
				children = { } -- 1061
			end -- 1061
			children[#children + 1] = { -- 1063
				key = Path(path, file), -- 1063
				dir = false, -- 1064
				title = file, -- 1065
				builtin = builtin -- 1066
			} -- 1062
		end -- 1060
		if children then -- 1068
			table.sort(children, function(a, b) -- 1069
				if a.dir == b.dir then -- 1070
					return a.title < b.title -- 1071
				else -- 1073
					return a.dir -- 1073
				end -- 1070
			end) -- 1069
		end -- 1068
		if isWorkspace and children then -- 1074
			return children -- 1075
		else -- 1077
			return { -- 1078
				key = path, -- 1078
				dir = true, -- 1079
				title = Path:getFilename(path), -- 1080
				builtin = builtin, -- 1081
				children = children -- 1082
			} -- 1077
		end -- 1074
	end -- 1027
	local zh = (App.locale:match("^zh") ~= nil) -- 1084
	return { -- 1086
		key = Content.writablePath, -- 1086
		dir = true, -- 1087
		root = true, -- 1088
		title = "Assets", -- 1089
		children = (function() -- 1091
			local _tab_0 = { -- 1091
				{ -- 1092
					key = Path(Content.assetPath), -- 1092
					dir = true, -- 1093
					builtin = true, -- 1094
					title = zh and "内置资源" or "Built-in", -- 1095
					children = { -- 1097
						(function() -- 1097
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1097
							_with_0.title = zh and "说明文档" or "Readme" -- 1098
							return _with_0 -- 1097
						end)(), -- 1097
						(function() -- 1099
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1099
							_with_0.title = zh and "接口文档" or "API Doc" -- 1100
							return _with_0 -- 1099
						end)(), -- 1099
						(function() -- 1101
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1101
							_with_0.title = zh and "开发工具" or "Tools" -- 1102
							return _with_0 -- 1101
						end)(), -- 1101
						(function() -- 1103
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1103
							_with_0.title = zh and "字体" or "Font" -- 1104
							return _with_0 -- 1103
						end)(), -- 1103
						(function() -- 1105
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1105
							_with_0.title = zh and "程序库" or "Lib" -- 1106
							if engineDev then -- 1107
								local _list_0 = _with_0.children -- 1108
								for _index_0 = 1, #_list_0 do -- 1108
									local child = _list_0[_index_0] -- 1108
									if not (child.title == "Dora") then -- 1109
										goto _continue_0 -- 1109
									end -- 1109
									local title = zh and "zh-Hans" or "en" -- 1110
									do -- 1111
										local _accum_0 = { } -- 1111
										local _len_0 = 1 -- 1111
										local _list_1 = child.children -- 1111
										for _index_1 = 1, #_list_1 do -- 1111
											local c = _list_1[_index_1] -- 1111
											if c.title ~= title then -- 1111
												_accum_0[_len_0] = c -- 1111
												_len_0 = _len_0 + 1 -- 1111
											end -- 1111
										end -- 1111
										child.children = _accum_0 -- 1111
									end -- 1111
									break -- 1112
									::_continue_0:: -- 1109
								end -- 1108
							else -- 1114
								local _accum_0 = { } -- 1114
								local _len_0 = 1 -- 1114
								local _list_0 = _with_0.children -- 1114
								for _index_0 = 1, #_list_0 do -- 1114
									local child = _list_0[_index_0] -- 1114
									if child.title ~= "Dora" then -- 1114
										_accum_0[_len_0] = child -- 1114
										_len_0 = _len_0 + 1 -- 1114
									end -- 1114
								end -- 1114
								_with_0.children = _accum_0 -- 1114
							end -- 1107
							return _with_0 -- 1105
						end)(), -- 1105
						(function() -- 1115
							if engineDev then -- 1115
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1116
								local _obj_0 = _with_0.children -- 1117
								_obj_0[#_obj_0 + 1] = { -- 1118
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1118
									dir = false, -- 1119
									builtin = true, -- 1120
									title = "init.yue" -- 1121
								} -- 1117
								return _with_0 -- 1116
							end -- 1115
						end)() -- 1115
					} -- 1096
				} -- 1091
			} -- 1125
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1125
			local _idx_0 = #_tab_0 + 1 -- 1125
			for _index_0 = 1, #_obj_0 do -- 1125
				local _value_0 = _obj_0[_index_0] -- 1125
				_tab_0[_idx_0] = _value_0 -- 1125
				_idx_0 = _idx_0 + 1 -- 1125
			end -- 1125
			return _tab_0 -- 1091
		end)() -- 1090
	} -- 1085
end) -- 1022
HttpServer:postSchedule("/run", function(req) -- 1129
	do -- 1130
		local _type_0 = type(req) -- 1130
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1130
		if _tab_0 then -- 1130
			local file -- 1130
			do -- 1130
				local _obj_0 = req.body -- 1130
				local _type_1 = type(_obj_0) -- 1130
				if "table" == _type_1 or "userdata" == _type_1 then -- 1130
					file = _obj_0.file -- 1130
				end -- 1130
			end -- 1130
			local asProj -- 1130
			do -- 1130
				local _obj_0 = req.body -- 1130
				local _type_1 = type(_obj_0) -- 1130
				if "table" == _type_1 or "userdata" == _type_1 then -- 1130
					asProj = _obj_0.asProj -- 1130
				end -- 1130
			end -- 1130
			if file ~= nil and asProj ~= nil then -- 1130
				if not Content:isAbsolutePath(file) then -- 1131
					local devFile = Path(Content.writablePath, file) -- 1132
					if Content:exist(devFile) then -- 1133
						file = devFile -- 1133
					end -- 1133
				end -- 1131
				local Entry = require("Script.Dev.Entry") -- 1134
				local workDir -- 1135
				if asProj then -- 1136
					workDir = getProjectDirFromFile(file) -- 1137
					if workDir then -- 1137
						Entry.allClear() -- 1138
						local target = Path(workDir, "init") -- 1139
						local success, err = Entry.enterEntryAsync({ -- 1140
							entryName = "Project", -- 1140
							fileName = target -- 1140
						}) -- 1140
						target = Path:getName(Path:getPath(target)) -- 1141
						return { -- 1142
							success = success, -- 1142
							target = target, -- 1142
							err = err -- 1142
						} -- 1142
					end -- 1137
				else -- 1144
					workDir = getProjectDirFromFile(file) -- 1144
				end -- 1136
				Entry.allClear() -- 1145
				file = Path:replaceExt(file, "") -- 1146
				local success, err = Entry.enterEntryAsync({ -- 1148
					entryName = Path:getName(file), -- 1148
					fileName = file, -- 1149
					workDir = workDir -- 1150
				}) -- 1147
				return { -- 1151
					success = success, -- 1151
					err = err -- 1151
				} -- 1151
			end -- 1130
		end -- 1130
	end -- 1130
	return { -- 1129
		success = false -- 1129
	} -- 1129
end) -- 1129
HttpServer:postSchedule("/stop", function() -- 1153
	local Entry = require("Script.Dev.Entry") -- 1154
	return { -- 1155
		success = Entry.stop() -- 1155
	} -- 1155
end) -- 1153
local minifyAsync -- 1157
minifyAsync = function(sourcePath, minifyPath) -- 1157
	if not Content:exist(sourcePath) then -- 1158
		return -- 1158
	end -- 1158
	local Entry = require("Script.Dev.Entry") -- 1159
	local errors = { } -- 1160
	local files = Entry.getAllFiles(sourcePath, { -- 1161
		"lua" -- 1161
	}, true) -- 1161
	do -- 1162
		local _accum_0 = { } -- 1162
		local _len_0 = 1 -- 1162
		for _index_0 = 1, #files do -- 1162
			local file = files[_index_0] -- 1162
			if file:sub(1, 1) ~= '.' then -- 1162
				_accum_0[_len_0] = file -- 1162
				_len_0 = _len_0 + 1 -- 1162
			end -- 1162
		end -- 1162
		files = _accum_0 -- 1162
	end -- 1162
	local paths -- 1163
	do -- 1163
		local _tbl_0 = { } -- 1163
		for _index_0 = 1, #files do -- 1163
			local file = files[_index_0] -- 1163
			_tbl_0[Path:getPath(file)] = true -- 1163
		end -- 1163
		paths = _tbl_0 -- 1163
	end -- 1163
	for path in pairs(paths) do -- 1164
		Content:mkdir(Path(minifyPath, path)) -- 1164
	end -- 1164
	local _ <close> = setmetatable({ }, { -- 1165
		__close = function() -- 1165
			package.loaded["luaminify.FormatMini"] = nil -- 1166
			package.loaded["luaminify.ParseLua"] = nil -- 1167
			package.loaded["luaminify.Scope"] = nil -- 1168
			package.loaded["luaminify.Util"] = nil -- 1169
		end -- 1165
	}) -- 1165
	local FormatMini -- 1170
	do -- 1170
		local _obj_0 = require("luaminify") -- 1170
		FormatMini = _obj_0.FormatMini -- 1170
	end -- 1170
	local fileCount = #files -- 1171
	local count = 0 -- 1172
	for _index_0 = 1, #files do -- 1173
		local file = files[_index_0] -- 1173
		thread(function() -- 1174
			local _ <close> = setmetatable({ }, { -- 1175
				__close = function() -- 1175
					count = count + 1 -- 1175
				end -- 1175
			}) -- 1175
			local input = Path(sourcePath, file) -- 1176
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1177
			if Content:exist(input) then -- 1178
				local sourceCodes = Content:loadAsync(input) -- 1179
				local res, err = FormatMini(sourceCodes) -- 1180
				if res then -- 1181
					Content:saveAsync(output, res) -- 1182
					return print("Minify " .. tostring(file)) -- 1183
				else -- 1185
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1185
				end -- 1181
			else -- 1187
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1187
			end -- 1178
		end) -- 1174
		sleep() -- 1188
	end -- 1173
	wait(function() -- 1189
		return count == fileCount -- 1189
	end) -- 1189
	if #errors > 0 then -- 1190
		print(table.concat(errors, '\n')) -- 1191
	end -- 1190
	print("Obfuscation done.") -- 1192
	return files -- 1193
end -- 1157
local zipping = false -- 1195
HttpServer:postSchedule("/zip", function(req) -- 1197
	do -- 1198
		local _type_0 = type(req) -- 1198
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1198
		if _tab_0 then -- 1198
			local path -- 1198
			do -- 1198
				local _obj_0 = req.body -- 1198
				local _type_1 = type(_obj_0) -- 1198
				if "table" == _type_1 or "userdata" == _type_1 then -- 1198
					path = _obj_0.path -- 1198
				end -- 1198
			end -- 1198
			local zipFile -- 1198
			do -- 1198
				local _obj_0 = req.body -- 1198
				local _type_1 = type(_obj_0) -- 1198
				if "table" == _type_1 or "userdata" == _type_1 then -- 1198
					zipFile = _obj_0.zipFile -- 1198
				end -- 1198
			end -- 1198
			local obfuscated -- 1198
			do -- 1198
				local _obj_0 = req.body -- 1198
				local _type_1 = type(_obj_0) -- 1198
				if "table" == _type_1 or "userdata" == _type_1 then -- 1198
					obfuscated = _obj_0.obfuscated -- 1198
				end -- 1198
			end -- 1198
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1198
				if zipping then -- 1199
					goto failed -- 1199
				end -- 1199
				zipping = true -- 1200
				local _ <close> = setmetatable({ }, { -- 1201
					__close = function() -- 1201
						zipping = false -- 1201
					end -- 1201
				}) -- 1201
				if not Content:exist(path) then -- 1202
					goto failed -- 1202
				end -- 1202
				Content:mkdir(Path:getPath(zipFile)) -- 1203
				if obfuscated then -- 1204
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1205
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1206
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1207
					Content:remove(scriptPath) -- 1208
					Content:remove(obfuscatedPath) -- 1209
					Content:remove(tempPath) -- 1210
					Content:mkdir(scriptPath) -- 1211
					Content:mkdir(obfuscatedPath) -- 1212
					Content:mkdir(tempPath) -- 1213
					if not Content:copyAsync(path, tempPath) then -- 1214
						goto failed -- 1214
					end -- 1214
					local Entry = require("Script.Dev.Entry") -- 1215
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1216
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1217
						"tl", -- 1217
						"yue", -- 1217
						"lua", -- 1217
						"ts", -- 1217
						"tsx", -- 1217
						"vs", -- 1217
						"bl", -- 1217
						"xml", -- 1217
						"wa", -- 1217
						"mod" -- 1217
					}, true) -- 1217
					for _index_0 = 1, #scriptFiles do -- 1218
						local file = scriptFiles[_index_0] -- 1218
						Content:remove(Path(tempPath, file)) -- 1219
					end -- 1218
					for _index_0 = 1, #luaFiles do -- 1220
						local file = luaFiles[_index_0] -- 1220
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1221
					end -- 1220
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1222
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1223
					end) then -- 1222
						goto failed -- 1222
					end -- 1222
					return { -- 1224
						success = true -- 1224
					} -- 1224
				else -- 1226
					return { -- 1226
						success = Content:zipAsync(path, zipFile, function(file) -- 1226
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1227
						end) -- 1226
					} -- 1226
				end -- 1204
			end -- 1198
		end -- 1198
	end -- 1198
	::failed:: -- 1228
	return { -- 1197
		success = false -- 1197
	} -- 1197
end) -- 1197
HttpServer:postSchedule("/unzip", function(req) -- 1230
	do -- 1231
		local _type_0 = type(req) -- 1231
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1231
		if _tab_0 then -- 1231
			local zipFile -- 1231
			do -- 1231
				local _obj_0 = req.body -- 1231
				local _type_1 = type(_obj_0) -- 1231
				if "table" == _type_1 or "userdata" == _type_1 then -- 1231
					zipFile = _obj_0.zipFile -- 1231
				end -- 1231
			end -- 1231
			local path -- 1231
			do -- 1231
				local _obj_0 = req.body -- 1231
				local _type_1 = type(_obj_0) -- 1231
				if "table" == _type_1 or "userdata" == _type_1 then -- 1231
					path = _obj_0.path -- 1231
				end -- 1231
			end -- 1231
			if zipFile ~= nil and path ~= nil then -- 1231
				return { -- 1232
					success = Content:unzipAsync(zipFile, path, function(file) -- 1232
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1233
					end) -- 1232
				} -- 1232
			end -- 1231
		end -- 1231
	end -- 1231
	return { -- 1230
		success = false -- 1230
	} -- 1230
end) -- 1230
HttpServer:post("/editing-info", function(req) -- 1235
	local Entry = require("Script.Dev.Entry") -- 1236
	local config = Entry.getConfig() -- 1237
	local _type_0 = type(req) -- 1238
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1238
	local _match_0 = false -- 1238
	if _tab_0 then -- 1238
		local editingInfo -- 1238
		do -- 1238
			local _obj_0 = req.body -- 1238
			local _type_1 = type(_obj_0) -- 1238
			if "table" == _type_1 or "userdata" == _type_1 then -- 1238
				editingInfo = _obj_0.editingInfo -- 1238
			end -- 1238
		end -- 1238
		if editingInfo ~= nil then -- 1238
			_match_0 = true -- 1238
			config.editingInfo = editingInfo -- 1239
			return { -- 1240
				success = true -- 1240
			} -- 1240
		end -- 1238
	end -- 1238
	if not _match_0 then -- 1238
		if not (config.editingInfo ~= nil) then -- 1242
			local folder -- 1243
			if App.locale:match('^zh') then -- 1243
				folder = 'zh-Hans' -- 1243
			else -- 1243
				folder = 'en' -- 1243
			end -- 1243
			config.editingInfo = json.encode({ -- 1245
				index = 0, -- 1245
				files = { -- 1247
					{ -- 1248
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1248
						title = "welcome.md" -- 1249
					} -- 1247
				} -- 1246
			}) -- 1244
		end -- 1242
		return { -- 1253
			success = true, -- 1253
			editingInfo = config.editingInfo -- 1253
		} -- 1253
	end -- 1238
end) -- 1235
HttpServer:post("/command", function(req) -- 1255
	do -- 1256
		local _type_0 = type(req) -- 1256
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1256
		if _tab_0 then -- 1256
			local code -- 1256
			do -- 1256
				local _obj_0 = req.body -- 1256
				local _type_1 = type(_obj_0) -- 1256
				if "table" == _type_1 or "userdata" == _type_1 then -- 1256
					code = _obj_0.code -- 1256
				end -- 1256
			end -- 1256
			local log -- 1256
			do -- 1256
				local _obj_0 = req.body -- 1256
				local _type_1 = type(_obj_0) -- 1256
				if "table" == _type_1 or "userdata" == _type_1 then -- 1256
					log = _obj_0.log -- 1256
				end -- 1256
			end -- 1256
			if code ~= nil and log ~= nil then -- 1256
				emit("AppCommand", code, log) -- 1257
				return { -- 1258
					success = true -- 1258
				} -- 1258
			end -- 1256
		end -- 1256
	end -- 1256
	return { -- 1255
		success = false -- 1255
	} -- 1255
end) -- 1255
HttpServer:post("/log/save", function() -- 1260
	local folder = ".download" -- 1261
	local fullLogFile = "dora_full_logs.txt" -- 1262
	local fullFolder = Path(Content.writablePath, folder) -- 1263
	Content:mkdir(fullFolder) -- 1264
	local logPath = Path(fullFolder, fullLogFile) -- 1265
	if App:saveLog(logPath) then -- 1266
		return { -- 1267
			success = true, -- 1267
			path = Path(folder, fullLogFile) -- 1267
		} -- 1267
	end -- 1266
	return { -- 1260
		success = false -- 1260
	} -- 1260
end) -- 1260
HttpServer:post("/yarn/check", function(req) -- 1269
	local yarncompile = require("yarncompile") -- 1270
	do -- 1271
		local _type_0 = type(req) -- 1271
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1271
		if _tab_0 then -- 1271
			local code -- 1271
			do -- 1271
				local _obj_0 = req.body -- 1271
				local _type_1 = type(_obj_0) -- 1271
				if "table" == _type_1 or "userdata" == _type_1 then -- 1271
					code = _obj_0.code -- 1271
				end -- 1271
			end -- 1271
			if code ~= nil then -- 1271
				local jsonObject = json.decode(code) -- 1272
				if jsonObject then -- 1272
					local errors = { } -- 1273
					local _list_0 = jsonObject.nodes -- 1274
					for _index_0 = 1, #_list_0 do -- 1274
						local node = _list_0[_index_0] -- 1274
						local title, body = node.title, node.body -- 1275
						local luaCode, err = yarncompile(body) -- 1276
						if not luaCode then -- 1276
							errors[#errors + 1] = title .. ":" .. err -- 1277
						end -- 1276
					end -- 1274
					return { -- 1278
						success = true, -- 1278
						syntaxError = table.concat(errors, "\n\n") -- 1278
					} -- 1278
				end -- 1272
			end -- 1271
		end -- 1271
	end -- 1271
	return { -- 1269
		success = false -- 1269
	} -- 1269
end) -- 1269
HttpServer:post("/yarn/check-file", function(req) -- 1280
	local yarncompile = require("yarncompile") -- 1281
	do -- 1282
		local _type_0 = type(req) -- 1282
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1282
		if _tab_0 then -- 1282
			local code -- 1282
			do -- 1282
				local _obj_0 = req.body -- 1282
				local _type_1 = type(_obj_0) -- 1282
				if "table" == _type_1 or "userdata" == _type_1 then -- 1282
					code = _obj_0.code -- 1282
				end -- 1282
			end -- 1282
			if code ~= nil then -- 1282
				local res, _, err = yarncompile(code, true) -- 1283
				if not res then -- 1283
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1284
					return { -- 1285
						success = false, -- 1285
						message = message, -- 1285
						line = line, -- 1285
						column = column, -- 1285
						node = node -- 1285
					} -- 1285
				end -- 1283
			end -- 1282
		end -- 1282
	end -- 1282
	return { -- 1280
		success = true -- 1280
	} -- 1280
end) -- 1280
local getWaProjectDirFromFile -- 1287
getWaProjectDirFromFile = function(file) -- 1287
	local writablePath = Content.writablePath -- 1288
	local parent, current -- 1289
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1289
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1290
	else -- 1292
		parent, current = nil, nil -- 1292
	end -- 1289
	if not current then -- 1293
		return nil -- 1293
	end -- 1293
	repeat -- 1294
		current = Path:getPath(current) -- 1295
		if current == "" then -- 1296
			break -- 1296
		end -- 1296
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1297
		for _index_0 = 1, #_list_0 do -- 1297
			local f = _list_0[_index_0] -- 1297
			if Path:getFilename(f):lower() == "wa.mod" then -- 1298
				return Path(parent, current, Path:getPath(f)) -- 1299
			end -- 1298
		end -- 1297
	until false -- 1294
	return nil -- 1301
end -- 1287
HttpServer:postSchedule("/wa/build", function(req) -- 1303
	do -- 1304
		local _type_0 = type(req) -- 1304
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1304
		if _tab_0 then -- 1304
			local path -- 1304
			do -- 1304
				local _obj_0 = req.body -- 1304
				local _type_1 = type(_obj_0) -- 1304
				if "table" == _type_1 or "userdata" == _type_1 then -- 1304
					path = _obj_0.path -- 1304
				end -- 1304
			end -- 1304
			if path ~= nil then -- 1304
				local projDir = getWaProjectDirFromFile(path) -- 1305
				if projDir then -- 1305
					local message = Wasm:buildWaAsync(projDir) -- 1306
					if message == "" then -- 1307
						return { -- 1308
							success = true -- 1308
						} -- 1308
					else -- 1310
						return { -- 1310
							success = false, -- 1310
							message = message -- 1310
						} -- 1310
					end -- 1307
				else -- 1312
					return { -- 1312
						success = false, -- 1312
						message = 'Wa file needs a project' -- 1312
					} -- 1312
				end -- 1305
			end -- 1304
		end -- 1304
	end -- 1304
	return { -- 1313
		success = false, -- 1313
		message = 'failed to build' -- 1313
	} -- 1313
end) -- 1303
HttpServer:postSchedule("/wa/format", function(req) -- 1315
	do -- 1316
		local _type_0 = type(req) -- 1316
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1316
		if _tab_0 then -- 1316
			local file -- 1316
			do -- 1316
				local _obj_0 = req.body -- 1316
				local _type_1 = type(_obj_0) -- 1316
				if "table" == _type_1 or "userdata" == _type_1 then -- 1316
					file = _obj_0.file -- 1316
				end -- 1316
			end -- 1316
			if file ~= nil then -- 1316
				local code = Wasm:formatWaAsync(file) -- 1317
				if code == "" then -- 1318
					return { -- 1319
						success = false -- 1319
					} -- 1319
				else -- 1321
					return { -- 1321
						success = true, -- 1321
						code = code -- 1321
					} -- 1321
				end -- 1318
			end -- 1316
		end -- 1316
	end -- 1316
	return { -- 1322
		success = false -- 1322
	} -- 1322
end) -- 1315
HttpServer:postSchedule("/wa/create", function(req) -- 1324
	do -- 1325
		local _type_0 = type(req) -- 1325
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1325
		if _tab_0 then -- 1325
			local path -- 1325
			do -- 1325
				local _obj_0 = req.body -- 1325
				local _type_1 = type(_obj_0) -- 1325
				if "table" == _type_1 or "userdata" == _type_1 then -- 1325
					path = _obj_0.path -- 1325
				end -- 1325
			end -- 1325
			if path ~= nil then -- 1325
				if not Content:exist(Path:getPath(path)) then -- 1326
					return { -- 1327
						success = false, -- 1327
						message = "target path not existed" -- 1327
					} -- 1327
				end -- 1326
				if Content:exist(path) then -- 1328
					return { -- 1329
						success = false, -- 1329
						message = "target project folder existed" -- 1329
					} -- 1329
				end -- 1328
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1330
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1331
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1332
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1333
					return { -- 1336
						success = false, -- 1336
						message = "missing template project" -- 1336
					} -- 1336
				end -- 1333
				if not Content:mkdir(path) then -- 1337
					return { -- 1338
						success = false, -- 1338
						message = "failed to create project folder" -- 1338
					} -- 1338
				end -- 1337
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1339
					Content:remove(path) -- 1340
					return { -- 1341
						success = false, -- 1341
						message = "failed to copy template" -- 1341
					} -- 1341
				end -- 1339
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1342
					Content:remove(path) -- 1343
					return { -- 1344
						success = false, -- 1344
						message = "failed to copy template" -- 1344
					} -- 1344
				end -- 1342
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1345
					Content:remove(path) -- 1346
					return { -- 1347
						success = false, -- 1347
						message = "failed to copy template" -- 1347
					} -- 1347
				end -- 1345
				return { -- 1348
					success = true -- 1348
				} -- 1348
			end -- 1325
		end -- 1325
	end -- 1325
	return { -- 1324
		success = false, -- 1324
		message = "invalid call" -- 1324
	} -- 1324
end) -- 1324
local _anon_func_5 = function(path) -- 1357
	local _val_0 = Path:getExt(path) -- 1357
	return "ts" == _val_0 or "tsx" == _val_0 -- 1357
end -- 1357
local _anon_func_6 = function(f) -- 1387
	local _val_0 = Path:getExt(f) -- 1387
	return "ts" == _val_0 or "tsx" == _val_0 -- 1387
end -- 1387
HttpServer:postSchedule("/ts/build", function(req) -- 1350
	do -- 1351
		local _type_0 = type(req) -- 1351
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1351
		if _tab_0 then -- 1351
			local path -- 1351
			do -- 1351
				local _obj_0 = req.body -- 1351
				local _type_1 = type(_obj_0) -- 1351
				if "table" == _type_1 or "userdata" == _type_1 then -- 1351
					path = _obj_0.path -- 1351
				end -- 1351
			end -- 1351
			if path ~= nil then -- 1351
				if HttpServer.wsConnectionCount == 0 then -- 1352
					return { -- 1353
						success = false, -- 1353
						message = "Web IDE not connected" -- 1353
					} -- 1353
				end -- 1352
				if not Content:exist(path) then -- 1354
					return { -- 1355
						success = false, -- 1355
						message = "path not existed" -- 1355
					} -- 1355
				end -- 1354
				if not Content:isdir(path) then -- 1356
					if not (_anon_func_5(path)) then -- 1357
						return { -- 1358
							success = false, -- 1358
							message = "expecting a TypeScript file" -- 1358
						} -- 1358
					end -- 1357
					local messages = { } -- 1359
					local content = Content:load(path) -- 1360
					if not content then -- 1361
						return { -- 1362
							success = false, -- 1362
							message = "failed to read file" -- 1362
						} -- 1362
					end -- 1361
					emit("AppWS", "Send", json.encode({ -- 1363
						name = "UpdateFile", -- 1363
						file = path, -- 1363
						exists = true, -- 1363
						content = content -- 1363
					})) -- 1363
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1364
						local done = false -- 1365
						do -- 1366
							local _with_0 = Node() -- 1366
							_with_0:gslot("AppWS", function(event) -- 1367
								if event.type == "Receive" then -- 1368
									_with_0:removeFromParent() -- 1369
									local res = json.decode(event.msg) -- 1370
									if res then -- 1370
										if res.name == "TranspileTS" then -- 1371
											if res.success then -- 1372
												local luaFile = Path:replaceExt(path, "lua") -- 1373
												Content:save(luaFile, res.luaCode) -- 1374
												messages[#messages + 1] = { -- 1375
													success = true, -- 1375
													file = path -- 1375
												} -- 1375
											else -- 1377
												messages[#messages + 1] = { -- 1377
													success = false, -- 1377
													file = path, -- 1377
													message = res.message -- 1377
												} -- 1377
											end -- 1372
											done = true -- 1378
										end -- 1371
									end -- 1370
								end -- 1368
							end) -- 1367
						end -- 1366
						emit("AppWS", "Send", json.encode({ -- 1379
							name = "TranspileTS", -- 1379
							file = path, -- 1379
							content = content -- 1379
						})) -- 1379
						wait(function() -- 1380
							return done -- 1380
						end) -- 1380
					end -- 1364
					return { -- 1381
						success = true, -- 1381
						messages = messages -- 1381
					} -- 1381
				else -- 1383
					local files = Content:getAllFiles(path) -- 1383
					local fileData = { } -- 1384
					local messages = { } -- 1385
					for _index_0 = 1, #files do -- 1386
						local f = files[_index_0] -- 1386
						if not (_anon_func_6(f)) then -- 1387
							goto _continue_0 -- 1387
						end -- 1387
						local file = Path(path, f) -- 1388
						local content = Content:load(file) -- 1389
						if content then -- 1389
							fileData[file] = content -- 1390
							emit("AppWS", "Send", json.encode({ -- 1391
								name = "UpdateFile", -- 1391
								file = file, -- 1391
								exists = true, -- 1391
								content = content -- 1391
							})) -- 1391
						else -- 1393
							messages[#messages + 1] = { -- 1393
								success = false, -- 1393
								file = file, -- 1393
								message = "failed to read file" -- 1393
							} -- 1393
						end -- 1389
						::_continue_0:: -- 1387
					end -- 1386
					for file, content in pairs(fileData) do -- 1394
						if "d" == Path:getExt(Path:getName(file)) then -- 1395
							goto _continue_1 -- 1395
						end -- 1395
						local done = false -- 1396
						do -- 1397
							local _with_0 = Node() -- 1397
							_with_0:gslot("AppWS", function(event) -- 1398
								if event.type == "Receive" then -- 1399
									_with_0:removeFromParent() -- 1400
									local res = json.decode(event.msg) -- 1401
									if res then -- 1401
										if res.name == "TranspileTS" then -- 1402
											if res.success then -- 1403
												local luaFile = Path:replaceExt(file, "lua") -- 1404
												Content:save(luaFile, res.luaCode) -- 1405
												messages[#messages + 1] = { -- 1406
													success = true, -- 1406
													file = file -- 1406
												} -- 1406
											else -- 1408
												messages[#messages + 1] = { -- 1408
													success = false, -- 1408
													file = file, -- 1408
													message = res.message -- 1408
												} -- 1408
											end -- 1403
											done = true -- 1409
										end -- 1402
									end -- 1401
								end -- 1399
							end) -- 1398
						end -- 1397
						emit("AppWS", "Send", json.encode({ -- 1410
							name = "TranspileTS", -- 1410
							file = file, -- 1410
							content = content -- 1410
						})) -- 1410
						wait(function() -- 1411
							return done -- 1411
						end) -- 1411
						::_continue_1:: -- 1395
					end -- 1394
					return { -- 1412
						success = true, -- 1412
						messages = messages -- 1412
					} -- 1412
				end -- 1356
			end -- 1351
		end -- 1351
	end -- 1351
	return { -- 1350
		success = false -- 1350
	} -- 1350
end) -- 1350
HttpServer:post("/download", function(req) -- 1414
	do -- 1415
		local _type_0 = type(req) -- 1415
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1415
		if _tab_0 then -- 1415
			local url -- 1415
			do -- 1415
				local _obj_0 = req.body -- 1415
				local _type_1 = type(_obj_0) -- 1415
				if "table" == _type_1 or "userdata" == _type_1 then -- 1415
					url = _obj_0.url -- 1415
				end -- 1415
			end -- 1415
			local target -- 1415
			do -- 1415
				local _obj_0 = req.body -- 1415
				local _type_1 = type(_obj_0) -- 1415
				if "table" == _type_1 or "userdata" == _type_1 then -- 1415
					target = _obj_0.target -- 1415
				end -- 1415
			end -- 1415
			if url ~= nil and target ~= nil then -- 1415
				local Entry = require("Script.Dev.Entry") -- 1416
				Entry.downloadFile(url, target) -- 1417
				return { -- 1418
					success = true -- 1418
				} -- 1418
			end -- 1415
		end -- 1415
	end -- 1415
	return { -- 1414
		success = false -- 1414
	} -- 1414
end) -- 1414
local status = { } -- 1420
_module_0 = status -- 1421
status.buildAsync = function(path) -- 1423
	if not Content:exist(path) then -- 1424
		return { -- 1425
			success = false, -- 1425
			file = path, -- 1425
			message = "file not existed" -- 1425
		} -- 1425
	end -- 1424
	do -- 1426
		local _exp_0 = Path:getExt(path) -- 1426
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1426
			if '' == Path:getExt(Path:getName(path)) then -- 1427
				local content = Content:loadAsync(path) -- 1428
				if content then -- 1428
					local resultCodes, err = compileFileAsync(path, content) -- 1429
					if resultCodes then -- 1429
						return { -- 1430
							success = true, -- 1430
							file = path -- 1430
						} -- 1430
					else -- 1432
						return { -- 1432
							success = false, -- 1432
							file = path, -- 1432
							message = err -- 1432
						} -- 1432
					end -- 1429
				end -- 1428
			end -- 1427
		elseif "lua" == _exp_0 then -- 1433
			local content = Content:loadAsync(path) -- 1434
			if content then -- 1434
				do -- 1435
					local isTIC80 = CheckTIC80Code(content) -- 1435
					if isTIC80 then -- 1435
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1436
					end -- 1435
				end -- 1435
				local success, info -- 1437
				do -- 1437
					local _obj_0 = luaCheck(path, content) -- 1437
					success, info = _obj_0.success, _obj_0.info -- 1437
				end -- 1437
				if success then -- 1438
					return { -- 1439
						success = true, -- 1439
						file = path -- 1439
					} -- 1439
				elseif info and #info > 0 then -- 1440
					local messages = { } -- 1441
					for _index_0 = 1, #info do -- 1442
						local _des_0 = info[_index_0] -- 1442
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 1442
						local lineText = "" -- 1443
						if line then -- 1444
							local currentLine = 1 -- 1445
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1446
								if currentLine == line then -- 1447
									lineText = text -- 1448
									break -- 1449
								end -- 1447
								currentLine = currentLine + 1 -- 1450
							end -- 1446
						end -- 1444
						if line then -- 1451
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1452
						else -- 1454
							messages[#messages + 1] = message -- 1454
						end -- 1451
					end -- 1442
					return { -- 1455
						success = false, -- 1455
						file = path, -- 1455
						message = table.concat(messages, "\n") -- 1455
					} -- 1455
				else -- 1457
					return { -- 1457
						success = false, -- 1457
						file = path, -- 1457
						message = "lua check failed" -- 1457
					} -- 1457
				end -- 1438
			end -- 1434
		elseif "yarn" == _exp_0 then -- 1458
			local content = Content:loadAsync(path) -- 1459
			if content then -- 1459
				local res, _, err = yarncompile(content, true) -- 1460
				if res then -- 1460
					return { -- 1461
						success = true, -- 1461
						file = path -- 1461
					} -- 1461
				else -- 1463
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1463
					local lineText = "" -- 1464
					if line then -- 1465
						local currentLine = 1 -- 1466
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1467
							if currentLine == line then -- 1468
								lineText = text -- 1469
								break -- 1470
							end -- 1468
							currentLine = currentLine + 1 -- 1471
						end -- 1467
					end -- 1465
					if node ~= "" then -- 1472
						node = "node: " .. tostring(node) .. ", " -- 1473
					else -- 1474
						node = "" -- 1474
					end -- 1472
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1475
					return { -- 1476
						success = false, -- 1476
						file = path, -- 1476
						message = message -- 1476
					} -- 1476
				end -- 1460
			end -- 1459
		end -- 1426
	end -- 1426
	return { -- 1477
		success = false, -- 1477
		file = path, -- 1477
		message = "invalid file to build" -- 1477
	} -- 1477
end -- 1423
thread(function() -- 1479
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1480
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1481
	if Content:exist(doraWeb) then -- 1482
		local needReload -- 1483
		if Content:exist(doraReady) then -- 1483
			needReload = App.version ~= Content:load(doraReady) -- 1484
		else -- 1485
			needReload = true -- 1485
		end -- 1483
		if needReload then -- 1486
			Content:remove(Path(Content.appPath, ".www")) -- 1487
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1488
			Content:save(doraReady, App.version) -- 1492
			print("Dora Dora is ready!") -- 1493
		end -- 1486
	end -- 1482
	if HttpServer:start(8866) then -- 1494
		local localIP = HttpServer.localIP -- 1495
		if localIP == "" then -- 1496
			localIP = "localhost" -- 1496
		end -- 1496
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1497
		return HttpServer:startWS(8868) -- 1498
	else -- 1500
		status.url = nil -- 1500
		return print("8866 Port not available!") -- 1501
	end -- 1494
end) -- 1479
return _module_0 -- 1
