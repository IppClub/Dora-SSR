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
		return nil, "current directory is not a project root" -- 117
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
			local targetSeq -- 179
			do -- 179
				local _obj_0 = req.body -- 179
				local _type_1 = type(_obj_0) -- 179
				if "table" == _type_1 or "userdata" == _type_1 then -- 179
					targetSeq = _obj_0.targetSeq -- 179
				end -- 179
			end -- 179
			if sessionId ~= nil and targetSeq ~= nil then -- 179
				if not (targetSeq >= 0) then -- 180
					return { -- 180
						success = false, -- 180
						message = "invalid targetSeq" -- 180
					} -- 180
				end -- 180
				local res = WebIDEAgentSession.getSession(sessionId) -- 181
				if not res.success then -- 182
					return res -- 182
				end -- 182
				local taskId = res.session.currentTaskId -- 183
				if not taskId then -- 184
					return { -- 184
						success = false, -- 184
						message = "task not found" -- 184
					} -- 184
				end -- 184
				local rollbackRes = AgentTools.rollbackToCheckpoint(taskId, res.session.projectRoot, targetSeq) -- 185
				if not rollbackRes.success then -- 186
					return rollbackRes -- 186
				end -- 186
				return { -- 188
					success = true, -- 188
					taskId = taskId, -- 189
					headSeq = rollbackRes.headSeq -- 190
				} -- 187
			end -- 179
		end -- 179
	end -- 179
	return invalidArguments -- 178
end) -- 178
local getSearchPath -- 192
getSearchPath = function(file) -- 192
	do -- 193
		local dir = getProjectDirFromFile(file) -- 193
		if dir then -- 193
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 194
		end -- 193
	end -- 193
	return "" -- 192
end -- 192
local getSearchFolders -- 196
getSearchFolders = function(file) -- 196
	do -- 197
		local dir = getProjectDirFromFile(file) -- 197
		if dir then -- 197
			return { -- 199
				Path(dir, "Script"), -- 199
				dir -- 200
			} -- 198
		end -- 197
	end -- 197
	return { } -- 196
end -- 196
local disabledCheckForLua = { -- 203
	"incompatible number of returns", -- 203
	"unknown", -- 204
	"cannot index", -- 205
	"module not found", -- 206
	"don't know how to resolve", -- 207
	"ContainerItem", -- 208
	"cannot resolve a type", -- 209
	"invalid key", -- 210
	"inconsistent index type", -- 211
	"cannot use operator", -- 212
	"attempting ipairs loop", -- 213
	"expects record or nominal", -- 214
	"variable is not being assigned", -- 215
	"<invalid type>", -- 216
	"<any type>", -- 217
	"using the '#' operator", -- 218
	"can't match a record", -- 219
	"redeclaration of variable", -- 220
	"cannot apply pairs", -- 221
	"not a function", -- 222
	"to%-be%-closed" -- 223
} -- 202
local yueCheck -- 225
yueCheck = function(file, content, lax) -- 225
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 226
	if isTIC80 then -- 227
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 228
	end -- 227
	local searchPath = getSearchPath(file) -- 229
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 230
	local info = { } -- 231
	local globals = { } -- 232
	for _index_0 = 1, #checkResult do -- 233
		local _des_0 = checkResult[_index_0] -- 233
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 233
		if "error" == t then -- 234
			info[#info + 1] = { -- 235
				"syntax", -- 235
				file, -- 235
				line, -- 235
				col, -- 235
				msg -- 235
			} -- 235
		elseif "global" == t then -- 236
			globals[#globals + 1] = { -- 237
				msg, -- 237
				line, -- 237
				col -- 237
			} -- 237
		end -- 234
	end -- 233
	if luaCodes then -- 238
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 239
		if success then -- 240
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 241
			if not (lintResult == "") then -- 242
				lintResult = lintResult .. "\n" -- 242
			end -- 242
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 243
		else -- 244
			for _index_0 = 1, #lintResult do -- 244
				local _des_0 = lintResult[_index_0] -- 244
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 244
				if isTIC80 and tic80APIs[name] then -- 245
					goto _continue_0 -- 245
				end -- 245
				info[#info + 1] = { -- 246
					"syntax", -- 246
					file, -- 246
					line, -- 246
					col, -- 246
					"invalid global variable" -- 246
				} -- 246
				::_continue_0:: -- 245
			end -- 244
		end -- 240
	end -- 238
	return luaCodes, info -- 247
end -- 225
local luaCheck -- 249
luaCheck = function(file, content) -- 249
	local res, err = load(content, "check") -- 250
	if not res then -- 251
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 252
		return { -- 253
			success = false, -- 253
			info = { -- 253
				{ -- 253
					"syntax", -- 253
					file, -- 253
					tonumber(line), -- 253
					0, -- 253
					msg -- 253
				} -- 253
			} -- 253
		} -- 253
	end -- 251
	local success, info = teal.checkAsync(content, file, true, "") -- 254
	if info then -- 255
		do -- 256
			local _accum_0 = { } -- 256
			local _len_0 = 1 -- 256
			for _index_0 = 1, #info do -- 256
				local item = info[_index_0] -- 256
				local useCheck = true -- 257
				if not item[5]:match("unused") then -- 258
					for _index_1 = 1, #disabledCheckForLua do -- 259
						local check = disabledCheckForLua[_index_1] -- 259
						if item[5]:match(check) then -- 260
							useCheck = false -- 261
						end -- 260
					end -- 259
				end -- 258
				if not useCheck then -- 262
					goto _continue_0 -- 262
				end -- 262
				do -- 263
					local _exp_0 = item[1] -- 263
					if "type" == _exp_0 then -- 264
						item[1] = "warning" -- 265
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 266
						goto _continue_0 -- 267
					end -- 263
				end -- 263
				_accum_0[_len_0] = item -- 268
				_len_0 = _len_0 + 1 -- 257
				::_continue_0:: -- 257
			end -- 256
			info = _accum_0 -- 256
		end -- 256
		if #info == 0 then -- 269
			info = nil -- 270
			success = true -- 271
		end -- 269
	end -- 255
	return { -- 272
		success = success, -- 272
		info = info -- 272
	} -- 272
end -- 249
local luaCheckWithLineInfo -- 274
luaCheckWithLineInfo = function(file, luaCodes) -- 274
	local res = luaCheck(file, luaCodes) -- 275
	local info = { } -- 276
	if not res.success then -- 277
		local current = 1 -- 278
		local lastLine = 1 -- 279
		local lineMap = { } -- 280
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 281
			local num = lineCode:match("--%s*(%d+)%s*$") -- 282
			if num then -- 283
				lastLine = tonumber(num) -- 284
			end -- 283
			lineMap[current] = lastLine -- 285
			current = current + 1 -- 286
		end -- 281
		local _list_0 = res.info -- 287
		for _index_0 = 1, #_list_0 do -- 287
			local item = _list_0[_index_0] -- 287
			item[3] = lineMap[item[3]] or 0 -- 288
			item[4] = 0 -- 289
			info[#info + 1] = item -- 290
		end -- 287
		return false, info -- 291
	end -- 277
	return true, info -- 292
end -- 274
local getCompiledYueLine -- 294
getCompiledYueLine = function(content, line, row, file, lax) -- 294
	local luaCodes = yueCheck(file, content, lax) -- 295
	if not luaCodes then -- 296
		return nil -- 296
	end -- 296
	local current = 1 -- 297
	local lastLine = 1 -- 298
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 299
	local targetRow = nil -- 300
	local lineMap = { } -- 301
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 302
		local num = lineCode:match("--%s*(%d+)%s*$") -- 303
		if num then -- 304
			lastLine = tonumber(num) -- 304
		end -- 304
		lineMap[current] = lastLine -- 305
		if row <= lastLine and not targetRow then -- 306
			targetRow = current -- 307
			break -- 308
		end -- 306
		current = current + 1 -- 309
	end -- 302
	targetRow = current -- 310
	if targetLine and targetRow then -- 311
		return luaCodes, targetLine, targetRow, lineMap -- 312
	else -- 314
		return nil -- 314
	end -- 311
end -- 294
HttpServer:postSchedule("/check", function(req) -- 316
	do -- 317
		local _type_0 = type(req) -- 317
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 317
		if _tab_0 then -- 317
			local file -- 317
			do -- 317
				local _obj_0 = req.body -- 317
				local _type_1 = type(_obj_0) -- 317
				if "table" == _type_1 or "userdata" == _type_1 then -- 317
					file = _obj_0.file -- 317
				end -- 317
			end -- 317
			local content -- 317
			do -- 317
				local _obj_0 = req.body -- 317
				local _type_1 = type(_obj_0) -- 317
				if "table" == _type_1 or "userdata" == _type_1 then -- 317
					content = _obj_0.content -- 317
				end -- 317
			end -- 317
			if file ~= nil and content ~= nil then -- 317
				local ext = Path:getExt(file) -- 318
				if "tl" == ext then -- 319
					local searchPath = getSearchPath(file) -- 320
					do -- 321
						local isTIC80 = CheckTIC80Code(content) -- 321
						if isTIC80 then -- 321
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 322
						end -- 321
					end -- 321
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 323
					return { -- 324
						success = success, -- 324
						info = info -- 324
					} -- 324
				elseif "lua" == ext then -- 325
					do -- 326
						local isTIC80 = CheckTIC80Code(content) -- 326
						if isTIC80 then -- 326
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 327
						end -- 326
					end -- 326
					return luaCheck(file, content) -- 328
				elseif "yue" == ext then -- 329
					local luaCodes, info = yueCheck(file, content, false) -- 330
					local success = false -- 331
					if luaCodes then -- 332
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 333
						do -- 334
							local _tab_1 = { } -- 334
							local _idx_0 = #_tab_1 + 1 -- 334
							for _index_0 = 1, #info do -- 334
								local _value_0 = info[_index_0] -- 334
								_tab_1[_idx_0] = _value_0 -- 334
								_idx_0 = _idx_0 + 1 -- 334
							end -- 334
							local _idx_1 = #_tab_1 + 1 -- 334
							for _index_0 = 1, #luaInfo do -- 334
								local _value_0 = luaInfo[_index_0] -- 334
								_tab_1[_idx_1] = _value_0 -- 334
								_idx_1 = _idx_1 + 1 -- 334
							end -- 334
							info = _tab_1 -- 334
						end -- 334
						success = success and luaSuccess -- 335
					end -- 332
					if #info > 0 then -- 336
						return { -- 337
							success = success, -- 337
							info = info -- 337
						} -- 337
					else -- 339
						return { -- 339
							success = success -- 339
						} -- 339
					end -- 336
				elseif "xml" == ext then -- 340
					local success, result = xml.check(content) -- 341
					if success then -- 342
						local info -- 343
						success, info = luaCheckWithLineInfo(file, result) -- 343
						if #info > 0 then -- 344
							return { -- 345
								success = success, -- 345
								info = info -- 345
							} -- 345
						else -- 347
							return { -- 347
								success = success -- 347
							} -- 347
						end -- 344
					else -- 349
						local info -- 349
						do -- 349
							local _accum_0 = { } -- 349
							local _len_0 = 1 -- 349
							for _index_0 = 1, #result do -- 349
								local _des_0 = result[_index_0] -- 349
								local row, err = _des_0[1], _des_0[2] -- 349
								_accum_0[_len_0] = { -- 350
									"syntax", -- 350
									file, -- 350
									row, -- 350
									0, -- 350
									err -- 350
								} -- 350
								_len_0 = _len_0 + 1 -- 350
							end -- 349
							info = _accum_0 -- 349
						end -- 349
						return { -- 351
							success = false, -- 351
							info = info -- 351
						} -- 351
					end -- 342
				end -- 319
			end -- 317
		end -- 317
	end -- 317
	return { -- 316
		success = true -- 316
	} -- 316
end) -- 316
local updateInferedDesc -- 353
updateInferedDesc = function(infered) -- 353
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 354
		return -- 354
	end -- 354
	local key, row = infered.key, infered.row -- 355
	local codes = Content:loadAsync(key) -- 356
	if codes then -- 356
		local comments = { } -- 357
		local line = 0 -- 358
		local skipping = false -- 359
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 360
			line = line + 1 -- 361
			if line >= row then -- 362
				break -- 362
			end -- 362
			if lineCode:match("^%s*%-%- @") then -- 363
				skipping = true -- 364
				goto _continue_0 -- 365
			end -- 363
			local result = lineCode:match("^%s*%-%- (.+)") -- 366
			if result then -- 366
				if not skipping then -- 367
					comments[#comments + 1] = result -- 367
				end -- 367
			elseif #comments > 0 then -- 368
				comments = { } -- 369
				skipping = false -- 370
			end -- 366
			::_continue_0:: -- 361
		end -- 360
		infered.doc = table.concat(comments, "\n") -- 371
	end -- 356
end -- 353
HttpServer:postSchedule("/infer", function(req) -- 373
	do -- 374
		local _type_0 = type(req) -- 374
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 374
		if _tab_0 then -- 374
			local lang -- 374
			do -- 374
				local _obj_0 = req.body -- 374
				local _type_1 = type(_obj_0) -- 374
				if "table" == _type_1 or "userdata" == _type_1 then -- 374
					lang = _obj_0.lang -- 374
				end -- 374
			end -- 374
			local file -- 374
			do -- 374
				local _obj_0 = req.body -- 374
				local _type_1 = type(_obj_0) -- 374
				if "table" == _type_1 or "userdata" == _type_1 then -- 374
					file = _obj_0.file -- 374
				end -- 374
			end -- 374
			local content -- 374
			do -- 374
				local _obj_0 = req.body -- 374
				local _type_1 = type(_obj_0) -- 374
				if "table" == _type_1 or "userdata" == _type_1 then -- 374
					content = _obj_0.content -- 374
				end -- 374
			end -- 374
			local line -- 374
			do -- 374
				local _obj_0 = req.body -- 374
				local _type_1 = type(_obj_0) -- 374
				if "table" == _type_1 or "userdata" == _type_1 then -- 374
					line = _obj_0.line -- 374
				end -- 374
			end -- 374
			local row -- 374
			do -- 374
				local _obj_0 = req.body -- 374
				local _type_1 = type(_obj_0) -- 374
				if "table" == _type_1 or "userdata" == _type_1 then -- 374
					row = _obj_0.row -- 374
				end -- 374
			end -- 374
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 374
				local searchPath = getSearchPath(file) -- 375
				if "tl" == lang or "lua" == lang then -- 376
					if CheckTIC80Code(content) then -- 377
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 378
					end -- 377
					local infered = teal.inferAsync(content, line, row, searchPath) -- 379
					if (infered ~= nil) then -- 380
						updateInferedDesc(infered) -- 381
						return { -- 382
							success = true, -- 382
							infered = infered -- 382
						} -- 382
					end -- 380
				elseif "yue" == lang then -- 383
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 384
					if not luaCodes then -- 385
						return { -- 385
							success = false -- 385
						} -- 385
					end -- 385
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 386
					if (infered ~= nil) then -- 387
						local col -- 388
						file, row, col = infered.file, infered.row, infered.col -- 388
						if file == "" and row > 0 and col > 0 then -- 389
							infered.row = lineMap[row] or 0 -- 390
							infered.col = 0 -- 391
						end -- 389
						updateInferedDesc(infered) -- 392
						return { -- 393
							success = true, -- 393
							infered = infered -- 393
						} -- 393
					end -- 387
				end -- 376
			end -- 374
		end -- 374
	end -- 374
	return { -- 373
		success = false -- 373
	} -- 373
end) -- 373
local _anon_func_2 = function(doc) -- 444
	local _accum_0 = { } -- 444
	local _len_0 = 1 -- 444
	local _list_0 = doc.params -- 444
	for _index_0 = 1, #_list_0 do -- 444
		local param = _list_0[_index_0] -- 444
		_accum_0[_len_0] = param.name -- 444
		_len_0 = _len_0 + 1 -- 444
	end -- 444
	return _accum_0 -- 444
end -- 444
local getParamDocs -- 395
getParamDocs = function(signatures) -- 395
	do -- 396
		local codes = Content:loadAsync(signatures[1].file) -- 396
		if codes then -- 396
			local comments = { } -- 397
			local params = { } -- 398
			local line = 0 -- 399
			local docs = { } -- 400
			local returnType = nil -- 401
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 402
				line = line + 1 -- 403
				local needBreak = true -- 404
				for i, _des_0 in ipairs(signatures) do -- 405
					local row = _des_0.row -- 405
					if line >= row and not (docs[i] ~= nil) then -- 406
						if #comments > 0 or #params > 0 or returnType then -- 407
							docs[i] = { -- 409
								doc = table.concat(comments, "  \n"), -- 409
								returnType = returnType -- 410
							} -- 408
							if #params > 0 then -- 412
								docs[i].params = params -- 412
							end -- 412
						else -- 414
							docs[i] = false -- 414
						end -- 407
					end -- 406
					if not docs[i] then -- 415
						needBreak = false -- 415
					end -- 415
				end -- 405
				if needBreak then -- 416
					break -- 416
				end -- 416
				local result = lineCode:match("%s*%-%- (.+)") -- 417
				if result then -- 417
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 418
					if not name then -- 419
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 420
					end -- 419
					if name then -- 421
						local pname = name -- 422
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 423
							pname = pname .. "?" -- 423
						end -- 423
						params[#params + 1] = { -- 425
							name = tostring(pname) .. ": " .. tostring(typ), -- 425
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 426
						} -- 424
					else -- 429
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 429
						if typ then -- 429
							if returnType then -- 430
								returnType = returnType .. ", " .. typ -- 431
							else -- 433
								returnType = typ -- 433
							end -- 430
							result = result:gsub("@return", "**return:**") -- 434
						end -- 429
						comments[#comments + 1] = result -- 435
					end -- 421
				elseif #comments > 0 then -- 436
					comments = { } -- 437
					params = { } -- 438
					returnType = nil -- 439
				end -- 417
			end -- 402
			local results = { } -- 440
			for _index_0 = 1, #docs do -- 441
				local doc = docs[_index_0] -- 441
				if not doc then -- 442
					goto _continue_0 -- 442
				end -- 442
				if doc.params then -- 443
					doc.desc = "function(" .. tostring(table.concat(_anon_func_2(doc), ', ')) .. ")" -- 444
				else -- 446
					doc.desc = "function()" -- 446
				end -- 443
				if doc.returnType then -- 447
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 448
					doc.returnType = nil -- 449
				end -- 447
				results[#results + 1] = doc -- 450
				::_continue_0:: -- 442
			end -- 441
			if #results > 0 then -- 451
				return results -- 451
			else -- 451
				return nil -- 451
			end -- 451
		end -- 396
	end -- 396
	return nil -- 395
end -- 395
HttpServer:postSchedule("/signature", function(req) -- 453
	do -- 454
		local _type_0 = type(req) -- 454
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 454
		if _tab_0 then -- 454
			local lang -- 454
			do -- 454
				local _obj_0 = req.body -- 454
				local _type_1 = type(_obj_0) -- 454
				if "table" == _type_1 or "userdata" == _type_1 then -- 454
					lang = _obj_0.lang -- 454
				end -- 454
			end -- 454
			local file -- 454
			do -- 454
				local _obj_0 = req.body -- 454
				local _type_1 = type(_obj_0) -- 454
				if "table" == _type_1 or "userdata" == _type_1 then -- 454
					file = _obj_0.file -- 454
				end -- 454
			end -- 454
			local content -- 454
			do -- 454
				local _obj_0 = req.body -- 454
				local _type_1 = type(_obj_0) -- 454
				if "table" == _type_1 or "userdata" == _type_1 then -- 454
					content = _obj_0.content -- 454
				end -- 454
			end -- 454
			local line -- 454
			do -- 454
				local _obj_0 = req.body -- 454
				local _type_1 = type(_obj_0) -- 454
				if "table" == _type_1 or "userdata" == _type_1 then -- 454
					line = _obj_0.line -- 454
				end -- 454
			end -- 454
			local row -- 454
			do -- 454
				local _obj_0 = req.body -- 454
				local _type_1 = type(_obj_0) -- 454
				if "table" == _type_1 or "userdata" == _type_1 then -- 454
					row = _obj_0.row -- 454
				end -- 454
			end -- 454
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 454
				local searchPath = getSearchPath(file) -- 455
				if "tl" == lang or "lua" == lang then -- 456
					if CheckTIC80Code(content) then -- 457
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 458
					end -- 457
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 459
					if signatures then -- 459
						signatures = getParamDocs(signatures) -- 460
						if signatures then -- 460
							return { -- 461
								success = true, -- 461
								signatures = signatures -- 461
							} -- 461
						end -- 460
					end -- 459
				elseif "yue" == lang then -- 462
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 463
					if not luaCodes then -- 464
						return { -- 464
							success = false -- 464
						} -- 464
					end -- 464
					do -- 465
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 465
						if chainOp then -- 465
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 466
							if withVar then -- 466
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 467
							end -- 466
						end -- 465
					end -- 465
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 468
					if signatures then -- 468
						signatures = getParamDocs(signatures) -- 469
						if signatures then -- 469
							return { -- 470
								success = true, -- 470
								signatures = signatures -- 470
							} -- 470
						end -- 469
					else -- 471
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 471
						if signatures then -- 471
							signatures = getParamDocs(signatures) -- 472
							if signatures then -- 472
								return { -- 473
									success = true, -- 473
									signatures = signatures -- 473
								} -- 473
							end -- 472
						end -- 471
					end -- 468
				end -- 456
			end -- 454
		end -- 454
	end -- 454
	return { -- 453
		success = false -- 453
	} -- 453
end) -- 453
local luaKeywords = { -- 476
	'and', -- 476
	'break', -- 477
	'do', -- 478
	'else', -- 479
	'elseif', -- 480
	'end', -- 481
	'false', -- 482
	'for', -- 483
	'function', -- 484
	'goto', -- 485
	'if', -- 486
	'in', -- 487
	'local', -- 488
	'nil', -- 489
	'not', -- 490
	'or', -- 491
	'repeat', -- 492
	'return', -- 493
	'then', -- 494
	'true', -- 495
	'until', -- 496
	'while' -- 497
} -- 475
local tealKeywords = { -- 501
	'record', -- 501
	'as', -- 502
	'is', -- 503
	'type', -- 504
	'embed', -- 505
	'enum', -- 506
	'global', -- 507
	'any', -- 508
	'boolean', -- 509
	'integer', -- 510
	'number', -- 511
	'string', -- 512
	'thread' -- 513
} -- 500
local yueKeywords = { -- 517
	"and", -- 517
	"break", -- 518
	"do", -- 519
	"else", -- 520
	"elseif", -- 521
	"false", -- 522
	"for", -- 523
	"goto", -- 524
	"if", -- 525
	"in", -- 526
	"local", -- 527
	"nil", -- 528
	"not", -- 529
	"or", -- 530
	"repeat", -- 531
	"return", -- 532
	"then", -- 533
	"true", -- 534
	"until", -- 535
	"while", -- 536
	"as", -- 537
	"class", -- 538
	"continue", -- 539
	"export", -- 540
	"extends", -- 541
	"from", -- 542
	"global", -- 543
	"import", -- 544
	"macro", -- 545
	"switch", -- 546
	"try", -- 547
	"unless", -- 548
	"using", -- 549
	"when", -- 550
	"with" -- 551
} -- 516
local _anon_func_3 = function(f) -- 587
	local _val_0 = Path:getExt(f) -- 587
	return "ttf" == _val_0 or "otf" == _val_0 -- 587
end -- 587
local _anon_func_4 = function(suggestions) -- 613
	local _tbl_0 = { } -- 613
	for _index_0 = 1, #suggestions do -- 613
		local item = suggestions[_index_0] -- 613
		_tbl_0[item[1] .. item[2]] = item -- 613
	end -- 613
	return _tbl_0 -- 613
end -- 613
HttpServer:postSchedule("/complete", function(req) -- 554
	do -- 555
		local _type_0 = type(req) -- 555
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 555
		if _tab_0 then -- 555
			local lang -- 555
			do -- 555
				local _obj_0 = req.body -- 555
				local _type_1 = type(_obj_0) -- 555
				if "table" == _type_1 or "userdata" == _type_1 then -- 555
					lang = _obj_0.lang -- 555
				end -- 555
			end -- 555
			local file -- 555
			do -- 555
				local _obj_0 = req.body -- 555
				local _type_1 = type(_obj_0) -- 555
				if "table" == _type_1 or "userdata" == _type_1 then -- 555
					file = _obj_0.file -- 555
				end -- 555
			end -- 555
			local content -- 555
			do -- 555
				local _obj_0 = req.body -- 555
				local _type_1 = type(_obj_0) -- 555
				if "table" == _type_1 or "userdata" == _type_1 then -- 555
					content = _obj_0.content -- 555
				end -- 555
			end -- 555
			local line -- 555
			do -- 555
				local _obj_0 = req.body -- 555
				local _type_1 = type(_obj_0) -- 555
				if "table" == _type_1 or "userdata" == _type_1 then -- 555
					line = _obj_0.line -- 555
				end -- 555
			end -- 555
			local row -- 555
			do -- 555
				local _obj_0 = req.body -- 555
				local _type_1 = type(_obj_0) -- 555
				if "table" == _type_1 or "userdata" == _type_1 then -- 555
					row = _obj_0.row -- 555
				end -- 555
			end -- 555
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 555
				local searchPath = getSearchPath(file) -- 556
				repeat -- 557
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 558
					if lang == "yue" then -- 559
						if not item then -- 560
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 560
						end -- 560
						if not item then -- 561
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 561
						end -- 561
					end -- 559
					local searchType = nil -- 562
					if not item then -- 563
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 564
						if lang == "yue" then -- 565
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 566
						end -- 565
						if (item ~= nil) then -- 567
							searchType = "Image" -- 567
						end -- 567
					end -- 563
					if not item then -- 568
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 569
						if lang == "yue" then -- 570
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 571
						end -- 570
						if (item ~= nil) then -- 572
							searchType = "Font" -- 572
						end -- 572
					end -- 568
					if not item then -- 573
						break -- 573
					end -- 573
					local searchPaths = Content.searchPaths -- 574
					local _list_0 = getSearchFolders(file) -- 575
					for _index_0 = 1, #_list_0 do -- 575
						local folder = _list_0[_index_0] -- 575
						searchPaths[#searchPaths + 1] = folder -- 576
					end -- 575
					if searchType then -- 577
						searchPaths[#searchPaths + 1] = Content.assetPath -- 577
					end -- 577
					local tokens -- 578
					do -- 578
						local _accum_0 = { } -- 578
						local _len_0 = 1 -- 578
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 578
							_accum_0[_len_0] = mod -- 578
							_len_0 = _len_0 + 1 -- 578
						end -- 578
						tokens = _accum_0 -- 578
					end -- 578
					local suggestions = { } -- 579
					for _index_0 = 1, #searchPaths do -- 580
						local path = searchPaths[_index_0] -- 580
						local sPath = Path(path, table.unpack(tokens)) -- 581
						if not Content:exist(sPath) then -- 582
							goto _continue_0 -- 582
						end -- 582
						if searchType == "Font" then -- 583
							local fontPath = Path(sPath, "Font") -- 584
							if Content:exist(fontPath) then -- 585
								local _list_1 = Content:getFiles(fontPath) -- 586
								for _index_1 = 1, #_list_1 do -- 586
									local f = _list_1[_index_1] -- 586
									if _anon_func_3(f) then -- 587
										if "." == f:sub(1, 1) then -- 588
											goto _continue_1 -- 588
										end -- 588
										suggestions[#suggestions + 1] = { -- 589
											Path:getName(f), -- 589
											"font", -- 589
											"field" -- 589
										} -- 589
									end -- 587
									::_continue_1:: -- 587
								end -- 586
							end -- 585
						end -- 583
						local _list_1 = Content:getFiles(sPath) -- 590
						for _index_1 = 1, #_list_1 do -- 590
							local f = _list_1[_index_1] -- 590
							if "Image" == searchType then -- 591
								do -- 592
									local _exp_0 = Path:getExt(f) -- 592
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 592
										if "." == f:sub(1, 1) then -- 593
											goto _continue_2 -- 593
										end -- 593
										suggestions[#suggestions + 1] = { -- 594
											f, -- 594
											"image", -- 594
											"field" -- 594
										} -- 594
									end -- 592
								end -- 592
								goto _continue_2 -- 595
							elseif "Font" == searchType then -- 596
								do -- 597
									local _exp_0 = Path:getExt(f) -- 597
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 597
										if "." == f:sub(1, 1) then -- 598
											goto _continue_2 -- 598
										end -- 598
										suggestions[#suggestions + 1] = { -- 599
											f, -- 599
											"font", -- 599
											"field" -- 599
										} -- 599
									end -- 597
								end -- 597
								goto _continue_2 -- 600
							end -- 591
							local _exp_0 = Path:getExt(f) -- 601
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 601
								local name = Path:getName(f) -- 602
								if "d" == Path:getExt(name) then -- 603
									goto _continue_2 -- 603
								end -- 603
								if "." == name:sub(1, 1) then -- 604
									goto _continue_2 -- 604
								end -- 604
								suggestions[#suggestions + 1] = { -- 605
									name, -- 605
									"module", -- 605
									"field" -- 605
								} -- 605
							end -- 601
							::_continue_2:: -- 591
						end -- 590
						local _list_2 = Content:getDirs(sPath) -- 606
						for _index_1 = 1, #_list_2 do -- 606
							local dir = _list_2[_index_1] -- 606
							if "." == dir:sub(1, 1) then -- 607
								goto _continue_3 -- 607
							end -- 607
							suggestions[#suggestions + 1] = { -- 608
								dir, -- 608
								"folder", -- 608
								"variable" -- 608
							} -- 608
							::_continue_3:: -- 607
						end -- 606
						::_continue_0:: -- 581
					end -- 580
					if item == "" and not searchType then -- 609
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 610
						for _index_0 = 1, #_list_1 do -- 610
							local _des_0 = _list_1[_index_0] -- 610
							local name = _des_0[1] -- 610
							suggestions[#suggestions + 1] = { -- 611
								name, -- 611
								"dora module", -- 611
								"function" -- 611
							} -- 611
						end -- 610
					end -- 609
					if #suggestions > 0 then -- 612
						do -- 613
							local _accum_0 = { } -- 613
							local _len_0 = 1 -- 613
							for _, v in pairs(_anon_func_4(suggestions)) do -- 613
								_accum_0[_len_0] = v -- 613
								_len_0 = _len_0 + 1 -- 613
							end -- 613
							suggestions = _accum_0 -- 613
						end -- 613
						return { -- 614
							success = true, -- 614
							suggestions = suggestions -- 614
						} -- 614
					else -- 616
						return { -- 616
							success = false -- 616
						} -- 616
					end -- 612
				until true -- 557
				if "tl" == lang or "lua" == lang then -- 618
					do -- 619
						local isTIC80 = CheckTIC80Code(content) -- 619
						if isTIC80 then -- 619
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 620
						end -- 619
					end -- 619
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 621
					if not line:match("[%.:]$") then -- 622
						local checkSet -- 623
						do -- 623
							local _tbl_0 = { } -- 623
							for _index_0 = 1, #suggestions do -- 623
								local _des_0 = suggestions[_index_0] -- 623
								local name = _des_0[1] -- 623
								_tbl_0[name] = true -- 623
							end -- 623
							checkSet = _tbl_0 -- 623
						end -- 623
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 624
						for _index_0 = 1, #_list_0 do -- 624
							local item = _list_0[_index_0] -- 624
							if not checkSet[item[1]] then -- 625
								suggestions[#suggestions + 1] = item -- 625
							end -- 625
						end -- 624
						for _index_0 = 1, #luaKeywords do -- 626
							local word = luaKeywords[_index_0] -- 626
							suggestions[#suggestions + 1] = { -- 627
								word, -- 627
								"keyword", -- 627
								"keyword" -- 627
							} -- 627
						end -- 626
						if lang == "tl" then -- 628
							for _index_0 = 1, #tealKeywords do -- 629
								local word = tealKeywords[_index_0] -- 629
								suggestions[#suggestions + 1] = { -- 630
									word, -- 630
									"keyword", -- 630
									"keyword" -- 630
								} -- 630
							end -- 629
						end -- 628
					end -- 622
					if #suggestions > 0 then -- 631
						return { -- 632
							success = true, -- 632
							suggestions = suggestions -- 632
						} -- 632
					end -- 631
				elseif "yue" == lang then -- 633
					local suggestions = { } -- 634
					local gotGlobals = false -- 635
					do -- 636
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 636
						if luaCodes then -- 636
							gotGlobals = true -- 637
							do -- 638
								local chainOp = line:match("[^%w_]([%.\\])$") -- 638
								if chainOp then -- 638
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 639
									if not withVar then -- 640
										return { -- 640
											success = false -- 640
										} -- 640
									end -- 640
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 641
								elseif line:match("^([%.\\])$") then -- 642
									return { -- 643
										success = false -- 643
									} -- 643
								end -- 638
							end -- 638
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 644
							for _index_0 = 1, #_list_0 do -- 644
								local item = _list_0[_index_0] -- 644
								suggestions[#suggestions + 1] = item -- 644
							end -- 644
							if #suggestions == 0 then -- 645
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 646
								for _index_0 = 1, #_list_1 do -- 646
									local item = _list_1[_index_0] -- 646
									suggestions[#suggestions + 1] = item -- 646
								end -- 646
							end -- 645
						end -- 636
					end -- 636
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 647
						local checkSet -- 648
						do -- 648
							local _tbl_0 = { } -- 648
							for _index_0 = 1, #suggestions do -- 648
								local _des_0 = suggestions[_index_0] -- 648
								local name = _des_0[1] -- 648
								_tbl_0[name] = true -- 648
							end -- 648
							checkSet = _tbl_0 -- 648
						end -- 648
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 649
						for _index_0 = 1, #_list_0 do -- 649
							local item = _list_0[_index_0] -- 649
							if not checkSet[item[1]] then -- 650
								suggestions[#suggestions + 1] = item -- 650
							end -- 650
						end -- 649
						if not gotGlobals then -- 651
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 652
							for _index_0 = 1, #_list_1 do -- 652
								local item = _list_1[_index_0] -- 652
								if not checkSet[item[1]] then -- 653
									suggestions[#suggestions + 1] = item -- 653
								end -- 653
							end -- 652
						end -- 651
						for _index_0 = 1, #yueKeywords do -- 654
							local word = yueKeywords[_index_0] -- 654
							if not checkSet[word] then -- 655
								suggestions[#suggestions + 1] = { -- 656
									word, -- 656
									"keyword", -- 656
									"keyword" -- 656
								} -- 656
							end -- 655
						end -- 654
					end -- 647
					if #suggestions > 0 then -- 657
						return { -- 658
							success = true, -- 658
							suggestions = suggestions -- 658
						} -- 658
					end -- 657
				elseif "xml" == lang then -- 659
					local items = xml.complete(content) -- 660
					if #items > 0 then -- 661
						local suggestions -- 662
						do -- 662
							local _accum_0 = { } -- 662
							local _len_0 = 1 -- 662
							for _index_0 = 1, #items do -- 662
								local _des_0 = items[_index_0] -- 662
								local label, insertText = _des_0[1], _des_0[2] -- 662
								_accum_0[_len_0] = { -- 663
									label, -- 663
									insertText, -- 663
									"field" -- 663
								} -- 663
								_len_0 = _len_0 + 1 -- 663
							end -- 662
							suggestions = _accum_0 -- 662
						end -- 662
						return { -- 664
							success = true, -- 664
							suggestions = suggestions -- 664
						} -- 664
					end -- 661
				end -- 618
			end -- 555
		end -- 555
	end -- 555
	return { -- 554
		success = false -- 554
	} -- 554
end) -- 554
HttpServer:upload("/upload", function(req, filename) -- 668
	do -- 669
		local _type_0 = type(req) -- 669
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 669
		if _tab_0 then -- 669
			local path -- 669
			do -- 669
				local _obj_0 = req.params -- 669
				local _type_1 = type(_obj_0) -- 669
				if "table" == _type_1 or "userdata" == _type_1 then -- 669
					path = _obj_0.path -- 669
				end -- 669
			end -- 669
			if path ~= nil then -- 669
				local uploadPath = Path(Content.writablePath, ".upload") -- 670
				if not Content:exist(uploadPath) then -- 671
					Content:mkdir(uploadPath) -- 672
				end -- 671
				local targetPath = Path(uploadPath, filename) -- 673
				Content:mkdir(Path:getPath(targetPath)) -- 674
				return targetPath -- 675
			end -- 669
		end -- 669
	end -- 669
	return nil -- 668
end, function(req, file) -- 676
	do -- 677
		local _type_0 = type(req) -- 677
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 677
		if _tab_0 then -- 677
			local path -- 677
			do -- 677
				local _obj_0 = req.params -- 677
				local _type_1 = type(_obj_0) -- 677
				if "table" == _type_1 or "userdata" == _type_1 then -- 677
					path = _obj_0.path -- 677
				end -- 677
			end -- 677
			if path ~= nil then -- 677
				path = Path(Content.writablePath, path) -- 678
				if Content:exist(path) then -- 679
					local uploadPath = Path(Content.writablePath, ".upload") -- 680
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 681
					Content:mkdir(Path:getPath(targetPath)) -- 682
					if Content:move(file, targetPath) then -- 683
						return true -- 684
					end -- 683
				end -- 679
			end -- 677
		end -- 677
	end -- 677
	return false -- 676
end) -- 666
HttpServer:post("/list", function(req) -- 687
	do -- 688
		local _type_0 = type(req) -- 688
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 688
		if _tab_0 then -- 688
			local path -- 688
			do -- 688
				local _obj_0 = req.body -- 688
				local _type_1 = type(_obj_0) -- 688
				if "table" == _type_1 or "userdata" == _type_1 then -- 688
					path = _obj_0.path -- 688
				end -- 688
			end -- 688
			if path ~= nil then -- 688
				if Content:exist(path) then -- 689
					local files = { } -- 690
					local visitAssets -- 691
					visitAssets = function(path, folder) -- 691
						local dirs = Content:getDirs(path) -- 692
						for _index_0 = 1, #dirs do -- 693
							local dir = dirs[_index_0] -- 693
							if dir:match("^%.") then -- 694
								goto _continue_0 -- 694
							end -- 694
							local current -- 695
							if folder == "" then -- 695
								current = dir -- 696
							else -- 698
								current = Path(folder, dir) -- 698
							end -- 695
							files[#files + 1] = current -- 699
							visitAssets(Path(path, dir), current) -- 700
							::_continue_0:: -- 694
						end -- 693
						local fs = Content:getFiles(path) -- 701
						for _index_0 = 1, #fs do -- 702
							local f = fs[_index_0] -- 702
							if f:match("^%.") then -- 703
								goto _continue_1 -- 703
							end -- 703
							if folder == "" then -- 704
								files[#files + 1] = f -- 705
							else -- 707
								files[#files + 1] = Path(folder, f) -- 707
							end -- 704
							::_continue_1:: -- 703
						end -- 702
					end -- 691
					visitAssets(path, "") -- 708
					if #files == 0 then -- 709
						files = nil -- 709
					end -- 709
					return { -- 710
						success = true, -- 710
						files = files -- 710
					} -- 710
				end -- 689
			end -- 688
		end -- 688
	end -- 688
	return { -- 687
		success = false -- 687
	} -- 687
end) -- 687
HttpServer:post("/info", function() -- 712
	local Entry = require("Script.Dev.Entry") -- 713
	local webProfiler, drawerWidth -- 714
	do -- 714
		local _obj_0 = Entry.getConfig() -- 714
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 714
	end -- 714
	local engineDev = Entry.getEngineDev() -- 715
	Entry.connectWebIDE() -- 716
	return { -- 718
		platform = App.platform, -- 718
		locale = App.locale, -- 719
		version = App.version, -- 720
		engineDev = engineDev, -- 721
		webProfiler = webProfiler, -- 722
		drawerWidth = drawerWidth -- 723
	} -- 717
end) -- 712
local ensureLLMConfigTable -- 725
ensureLLMConfigTable = function() -- 725
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
	]]) -- 726
end -- 725
HttpServer:post("/llm/list", function() -- 739
	ensureLLMConfigTable() -- 740
	local rows = DB:query("\n		select id, name, url, model, api_key, active\n		from LLMConfig\n		order by id asc") -- 741
	local items -- 745
	if rows and #rows > 0 then -- 745
		local _accum_0 = { } -- 746
		local _len_0 = 1 -- 746
		for _index_0 = 1, #rows do -- 746
			local _des_0 = rows[_index_0] -- 746
			local id, name, url, model, key, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6] -- 746
			_accum_0[_len_0] = { -- 747
				id = id, -- 747
				name = name, -- 747
				url = url, -- 747
				model = model, -- 747
				key = key, -- 747
				active = active ~= 0 -- 747
			} -- 747
			_len_0 = _len_0 + 1 -- 747
		end -- 746
		items = _accum_0 -- 745
	end -- 745
	return { -- 748
		success = true, -- 748
		items = items -- 748
	} -- 748
end) -- 739
HttpServer:post("/llm/create", function(req) -- 750
	ensureLLMConfigTable() -- 751
	do -- 752
		local _type_0 = type(req) -- 752
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 752
		if _tab_0 then -- 752
			local body = req.body -- 752
			if body ~= nil then -- 752
				local name, url, model, key, active = body.name, body.url, body.model, body.key, body.active -- 753
				local now = os.time() -- 754
				if name == nil or url == nil or model == nil or key == nil then -- 755
					return { -- 756
						success = false, -- 756
						message = "invalid" -- 756
					} -- 756
				end -- 755
				if active then -- 757
					active = 1 -- 757
				else -- 757
					active = 0 -- 757
				end -- 757
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?\n			)", { -- 764
					tostring(name), -- 764
					tostring(url), -- 765
					tostring(model), -- 766
					tostring(key), -- 767
					active, -- 768
					now, -- 769
					now -- 770
				}) -- 758
				return { -- 772
					success = affected >= 0 -- 772
				} -- 772
			end -- 752
		end -- 752
	end -- 752
	return { -- 750
		success = false, -- 750
		message = "invalid" -- 750
	} -- 750
end) -- 750
HttpServer:post("/llm/update", function(req) -- 774
	ensureLLMConfigTable() -- 775
	do -- 776
		local _type_0 = type(req) -- 776
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 776
		if _tab_0 then -- 776
			local body = req.body -- 776
			if body ~= nil then -- 776
				local id, name, url, model, key, active = body.id, body.name, body.url, body.model, body.key, body.active -- 777
				local now = os.time() -- 778
				id = tonumber(id) -- 779
				if id == nil then -- 780
					return { -- 781
						success = false, -- 781
						message = "invalid" -- 781
					} -- 781
				end -- 780
				if active then -- 782
					active = 1 -- 782
				else -- 782
					active = 0 -- 782
				end -- 782
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, active = ?, updated_at = ?\n			where id = ?", { -- 787
					tostring(name), -- 787
					tostring(url), -- 788
					tostring(model), -- 789
					tostring(key), -- 790
					active, -- 791
					now, -- 792
					id -- 793
				}) -- 783
				return { -- 795
					success = affected >= 0 -- 795
				} -- 795
			end -- 776
		end -- 776
	end -- 776
	return { -- 774
		success = false, -- 774
		message = "invalid" -- 774
	} -- 774
end) -- 774
HttpServer:post("/llm/delete", function(req) -- 797
	ensureLLMConfigTable() -- 798
	do -- 799
		local _type_0 = type(req) -- 799
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 799
		if _tab_0 then -- 799
			local id -- 799
			do -- 799
				local _obj_0 = req.body -- 799
				local _type_1 = type(_obj_0) -- 799
				if "table" == _type_1 or "userdata" == _type_1 then -- 799
					id = _obj_0.id -- 799
				end -- 799
			end -- 799
			if id ~= nil then -- 799
				id = tonumber(id) -- 800
				if id == nil then -- 801
					return { -- 802
						success = false, -- 802
						message = "invalid" -- 802
					} -- 802
				end -- 801
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 803
					id -- 803
				}) -- 803
				return { -- 804
					success = affected >= 0 -- 804
				} -- 804
			end -- 799
		end -- 799
	end -- 799
	return { -- 797
		success = false, -- 797
		message = "invalid" -- 797
	} -- 797
end) -- 797
HttpServer:post("/new", function(req) -- 806
	do -- 807
		local _type_0 = type(req) -- 807
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 807
		if _tab_0 then -- 807
			local path -- 807
			do -- 807
				local _obj_0 = req.body -- 807
				local _type_1 = type(_obj_0) -- 807
				if "table" == _type_1 or "userdata" == _type_1 then -- 807
					path = _obj_0.path -- 807
				end -- 807
			end -- 807
			local content -- 807
			do -- 807
				local _obj_0 = req.body -- 807
				local _type_1 = type(_obj_0) -- 807
				if "table" == _type_1 or "userdata" == _type_1 then -- 807
					content = _obj_0.content -- 807
				end -- 807
			end -- 807
			local folder -- 807
			do -- 807
				local _obj_0 = req.body -- 807
				local _type_1 = type(_obj_0) -- 807
				if "table" == _type_1 or "userdata" == _type_1 then -- 807
					folder = _obj_0.folder -- 807
				end -- 807
			end -- 807
			if path ~= nil and content ~= nil and folder ~= nil then -- 807
				if Content:exist(path) then -- 808
					return { -- 809
						success = false, -- 809
						message = "TargetExisted" -- 809
					} -- 809
				end -- 808
				local parent = Path:getPath(path) -- 810
				local files = Content:getFiles(parent) -- 811
				if folder then -- 812
					local name = Path:getFilename(path):lower() -- 813
					for _index_0 = 1, #files do -- 814
						local file = files[_index_0] -- 814
						if name == Path:getFilename(file):lower() then -- 815
							return { -- 816
								success = false, -- 816
								message = "TargetExisted" -- 816
							} -- 816
						end -- 815
					end -- 814
					if Content:mkdir(path) then -- 817
						return { -- 818
							success = true -- 818
						} -- 818
					end -- 817
				else -- 820
					local name = Path:getName(path):lower() -- 820
					for _index_0 = 1, #files do -- 821
						local file = files[_index_0] -- 821
						if name == Path:getName(file):lower() then -- 822
							local ext = Path:getExt(file) -- 823
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 824
								goto _continue_0 -- 825
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 826
								goto _continue_0 -- 827
							end -- 824
							return { -- 828
								success = false, -- 828
								message = "SourceExisted" -- 828
							} -- 828
						end -- 822
						::_continue_0:: -- 822
					end -- 821
					if Content:save(path, content) then -- 829
						return { -- 830
							success = true -- 830
						} -- 830
					end -- 829
				end -- 812
			end -- 807
		end -- 807
	end -- 807
	return { -- 806
		success = false, -- 806
		message = "Failed" -- 806
	} -- 806
end) -- 806
HttpServer:post("/delete", function(req) -- 832
	do -- 833
		local _type_0 = type(req) -- 833
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 833
		if _tab_0 then -- 833
			local path -- 833
			do -- 833
				local _obj_0 = req.body -- 833
				local _type_1 = type(_obj_0) -- 833
				if "table" == _type_1 or "userdata" == _type_1 then -- 833
					path = _obj_0.path -- 833
				end -- 833
			end -- 833
			if path ~= nil then -- 833
				if Content:exist(path) then -- 834
					local parent = Path:getPath(path) -- 835
					local files = Content:getFiles(parent) -- 836
					local name = Path:getName(path):lower() -- 837
					local ext = Path:getExt(path) -- 838
					for _index_0 = 1, #files do -- 839
						local file = files[_index_0] -- 839
						if name == Path:getName(file):lower() then -- 840
							local _exp_0 = Path:getExt(file) -- 841
							if "tl" == _exp_0 then -- 841
								if ("vs" == ext) then -- 841
									Content:remove(Path(parent, file)) -- 842
								end -- 841
							elseif "lua" == _exp_0 then -- 843
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 843
									Content:remove(Path(parent, file)) -- 844
								end -- 843
							end -- 841
						end -- 840
					end -- 839
					if Content:remove(path) then -- 845
						return { -- 846
							success = true -- 846
						} -- 846
					end -- 845
				end -- 834
			end -- 833
		end -- 833
	end -- 833
	return { -- 832
		success = false -- 832
	} -- 832
end) -- 832
HttpServer:post("/rename", function(req) -- 848
	do -- 849
		local _type_0 = type(req) -- 849
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 849
		if _tab_0 then -- 849
			local old -- 849
			do -- 849
				local _obj_0 = req.body -- 849
				local _type_1 = type(_obj_0) -- 849
				if "table" == _type_1 or "userdata" == _type_1 then -- 849
					old = _obj_0.old -- 849
				end -- 849
			end -- 849
			local new -- 849
			do -- 849
				local _obj_0 = req.body -- 849
				local _type_1 = type(_obj_0) -- 849
				if "table" == _type_1 or "userdata" == _type_1 then -- 849
					new = _obj_0.new -- 849
				end -- 849
			end -- 849
			if old ~= nil and new ~= nil then -- 849
				if Content:exist(old) and not Content:exist(new) then -- 850
					local parent = Path:getPath(new) -- 851
					local files = Content:getFiles(parent) -- 852
					if Content:isdir(old) then -- 853
						local name = Path:getFilename(new):lower() -- 854
						for _index_0 = 1, #files do -- 855
							local file = files[_index_0] -- 855
							if name == Path:getFilename(file):lower() then -- 856
								return { -- 857
									success = false -- 857
								} -- 857
							end -- 856
						end -- 855
					else -- 859
						local name = Path:getName(new):lower() -- 859
						local ext = Path:getExt(new) -- 860
						for _index_0 = 1, #files do -- 861
							local file = files[_index_0] -- 861
							if name == Path:getName(file):lower() then -- 862
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 863
									goto _continue_0 -- 864
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 865
									goto _continue_0 -- 866
								end -- 863
								return { -- 867
									success = false -- 867
								} -- 867
							end -- 862
							::_continue_0:: -- 862
						end -- 861
					end -- 853
					if Content:move(old, new) then -- 868
						local newParent = Path:getPath(new) -- 869
						parent = Path:getPath(old) -- 870
						files = Content:getFiles(parent) -- 871
						local newName = Path:getName(new) -- 872
						local oldName = Path:getName(old) -- 873
						local name = oldName:lower() -- 874
						local ext = Path:getExt(old) -- 875
						for _index_0 = 1, #files do -- 876
							local file = files[_index_0] -- 876
							if name == Path:getName(file):lower() then -- 877
								local _exp_0 = Path:getExt(file) -- 878
								if "tl" == _exp_0 then -- 878
									if ("vs" == ext) then -- 878
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 879
									end -- 878
								elseif "lua" == _exp_0 then -- 880
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 880
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 881
									end -- 880
								end -- 878
							end -- 877
						end -- 876
						return { -- 882
							success = true -- 882
						} -- 882
					end -- 868
				end -- 850
			end -- 849
		end -- 849
	end -- 849
	return { -- 848
		success = false -- 848
	} -- 848
end) -- 848
HttpServer:post("/exist", function(req) -- 884
	do -- 885
		local _type_0 = type(req) -- 885
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 885
		if _tab_0 then -- 885
			local file -- 885
			do -- 885
				local _obj_0 = req.body -- 885
				local _type_1 = type(_obj_0) -- 885
				if "table" == _type_1 or "userdata" == _type_1 then -- 885
					file = _obj_0.file -- 885
				end -- 885
			end -- 885
			if file ~= nil then -- 885
				do -- 886
					local projFile = req.body.projFile -- 886
					if projFile then -- 886
						local projDir = getProjectDirFromFile(projFile) -- 887
						if projDir then -- 887
							local scriptDir = Path(projDir, "Script") -- 888
							local searchPaths = Content.searchPaths -- 889
							if Content:exist(scriptDir) then -- 890
								Content:addSearchPath(scriptDir) -- 890
							end -- 890
							if Content:exist(projDir) then -- 891
								Content:addSearchPath(projDir) -- 891
							end -- 891
							local _ <close> = setmetatable({ }, { -- 892
								__close = function() -- 892
									Content.searchPaths = searchPaths -- 892
								end -- 892
							}) -- 892
							return { -- 893
								success = Content:exist(file) -- 893
							} -- 893
						end -- 887
					end -- 886
				end -- 886
				return { -- 894
					success = Content:exist(file) -- 894
				} -- 894
			end -- 885
		end -- 885
	end -- 885
	return { -- 884
		success = false -- 884
	} -- 884
end) -- 884
HttpServer:postSchedule("/read", function(req) -- 896
	do -- 897
		local _type_0 = type(req) -- 897
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 897
		if _tab_0 then -- 897
			local path -- 897
			do -- 897
				local _obj_0 = req.body -- 897
				local _type_1 = type(_obj_0) -- 897
				if "table" == _type_1 or "userdata" == _type_1 then -- 897
					path = _obj_0.path -- 897
				end -- 897
			end -- 897
			if path ~= nil then -- 897
				local readFile -- 898
				readFile = function() -- 898
					if Content:exist(path) then -- 899
						local content = Content:loadAsync(path) -- 900
						if content then -- 900
							return { -- 901
								content = content, -- 901
								success = true -- 901
							} -- 901
						end -- 900
					end -- 899
					return nil -- 898
				end -- 898
				do -- 902
					local projFile = req.body.projFile -- 902
					if projFile then -- 902
						local projDir = getProjectDirFromFile(projFile) -- 903
						if projDir then -- 903
							local scriptDir = Path(projDir, "Script") -- 904
							local searchPaths = Content.searchPaths -- 905
							if Content:exist(scriptDir) then -- 906
								Content:addSearchPath(scriptDir) -- 906
							end -- 906
							if Content:exist(projDir) then -- 907
								Content:addSearchPath(projDir) -- 907
							end -- 907
							local _ <close> = setmetatable({ }, { -- 908
								__close = function() -- 908
									Content.searchPaths = searchPaths -- 908
								end -- 908
							}) -- 908
							local result = readFile() -- 909
							if result then -- 909
								return result -- 909
							end -- 909
						end -- 903
					end -- 902
				end -- 902
				local result = readFile() -- 910
				if result then -- 910
					return result -- 910
				end -- 910
			end -- 897
		end -- 897
	end -- 897
	return { -- 896
		success = false -- 896
	} -- 896
end) -- 896
HttpServer:get("/read-sync", function(req) -- 912
	do -- 913
		local _type_0 = type(req) -- 913
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 913
		if _tab_0 then -- 913
			local params = req.params -- 913
			if params ~= nil then -- 913
				local path = params.path -- 914
				local exts -- 915
				if params.exts then -- 915
					local _accum_0 = { } -- 916
					local _len_0 = 1 -- 916
					for ext in params.exts:gmatch("[^|]*") do -- 916
						_accum_0[_len_0] = ext -- 917
						_len_0 = _len_0 + 1 -- 917
					end -- 916
					exts = _accum_0 -- 915
				else -- 918
					exts = { -- 918
						"" -- 918
					} -- 918
				end -- 915
				local readFile -- 919
				readFile = function() -- 919
					for _index_0 = 1, #exts do -- 920
						local ext = exts[_index_0] -- 920
						local targetPath = path .. ext -- 921
						if Content:exist(targetPath) then -- 922
							local content = Content:load(targetPath) -- 923
							if content then -- 923
								return { -- 924
									content = content, -- 924
									success = true, -- 924
									fullPath = Content:getFullPath(targetPath) -- 924
								} -- 924
							end -- 923
						end -- 922
					end -- 920
					return nil -- 919
				end -- 919
				local searchPaths = Content.searchPaths -- 925
				local _ <close> = setmetatable({ }, { -- 926
					__close = function() -- 926
						Content.searchPaths = searchPaths -- 926
					end -- 926
				}) -- 926
				do -- 927
					local projFile = req.params.projFile -- 927
					if projFile then -- 927
						local projDir = getProjectDirFromFile(projFile) -- 928
						if projDir then -- 928
							local scriptDir = Path(projDir, "Script") -- 929
							if Content:exist(scriptDir) then -- 930
								Content:addSearchPath(scriptDir) -- 930
							end -- 930
							if Content:exist(projDir) then -- 931
								Content:addSearchPath(projDir) -- 931
							end -- 931
						else -- 933
							projDir = Path:getPath(projFile) -- 933
							if Content:exist(projDir) then -- 934
								Content:addSearchPath(projDir) -- 934
							end -- 934
						end -- 928
					end -- 927
				end -- 927
				local result = readFile() -- 935
				if result then -- 935
					return result -- 935
				end -- 935
			end -- 913
		end -- 913
	end -- 913
	return { -- 912
		success = false -- 912
	} -- 912
end) -- 912
local compileFileAsync -- 937
compileFileAsync = function(inputFile, sourceCodes) -- 937
	local file = inputFile -- 938
	local searchPath -- 939
	do -- 939
		local dir = getProjectDirFromFile(inputFile) -- 939
		if dir then -- 939
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 940
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 941
		else -- 943
			file = Path:getRelative(inputFile, Content.writablePath) -- 943
			if file:sub(1, 2) == ".." then -- 944
				file = Path:getRelative(inputFile, Content.assetPath) -- 945
			end -- 944
			searchPath = "" -- 946
		end -- 939
	end -- 939
	local outputFile = Path:replaceExt(inputFile, "lua") -- 947
	local yueext = yue.options.extension -- 948
	local resultCodes = nil -- 949
	local resultError = nil -- 950
	do -- 951
		local _exp_0 = Path:getExt(inputFile) -- 951
		if yueext == _exp_0 then -- 951
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 952
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 953
				if not codes then -- 954
					resultError = err -- 955
					return -- 956
				end -- 954
				local extraGlobal -- 957
				if isTIC80 then -- 957
					extraGlobal = tic80APIs -- 957
				else -- 957
					extraGlobal = nil -- 957
				end -- 957
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 958
				if not success then -- 959
					resultError = message -- 960
					return -- 961
				end -- 959
				if codes == "" then -- 962
					resultCodes = "" -- 963
					return nil -- 964
				end -- 962
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 965
				return resultCodes -- 966
			end, function(success) -- 953
				if not success then -- 967
					Content:remove(outputFile) -- 968
					if resultCodes == nil then -- 969
						resultCodes = false -- 970
					end -- 969
				end -- 967
			end) -- 953
		elseif "tl" == _exp_0 then -- 971
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 972
			if isTIC80 then -- 973
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 974
			end -- 973
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 975
			if codes then -- 975
				if isTIC80 then -- 976
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 977
				end -- 976
				resultCodes = codes -- 978
				Content:saveAsync(outputFile, codes) -- 979
			else -- 981
				Content:remove(outputFile) -- 981
				resultCodes = false -- 982
				resultError = err -- 983
			end -- 975
		elseif "xml" == _exp_0 then -- 984
			local codes, err = xml.tolua(sourceCodes) -- 985
			if codes then -- 985
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 986
				Content:saveAsync(outputFile, resultCodes) -- 987
			else -- 989
				Content:remove(outputFile) -- 989
				resultCodes = false -- 990
				resultError = err -- 991
			end -- 985
		end -- 951
	end -- 951
	wait(function() -- 992
		return resultCodes ~= nil -- 992
	end) -- 992
	if resultCodes then -- 993
		return resultCodes -- 994
	else -- 996
		return nil, resultError -- 996
	end -- 993
	return nil -- 937
end -- 937
HttpServer:postSchedule("/write", function(req) -- 998
	do -- 999
		local _type_0 = type(req) -- 999
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 999
		if _tab_0 then -- 999
			local path -- 999
			do -- 999
				local _obj_0 = req.body -- 999
				local _type_1 = type(_obj_0) -- 999
				if "table" == _type_1 or "userdata" == _type_1 then -- 999
					path = _obj_0.path -- 999
				end -- 999
			end -- 999
			local content -- 999
			do -- 999
				local _obj_0 = req.body -- 999
				local _type_1 = type(_obj_0) -- 999
				if "table" == _type_1 or "userdata" == _type_1 then -- 999
					content = _obj_0.content -- 999
				end -- 999
			end -- 999
			if path ~= nil and content ~= nil then -- 999
				if Content:saveAsync(path, content) then -- 1000
					do -- 1001
						local _exp_0 = Path:getExt(path) -- 1001
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1001
							if '' == Path:getExt(Path:getName(path)) then -- 1002
								local resultCodes = compileFileAsync(path, content) -- 1003
								return { -- 1004
									success = true, -- 1004
									resultCodes = resultCodes -- 1004
								} -- 1004
							end -- 1002
						end -- 1001
					end -- 1001
					return { -- 1005
						success = true -- 1005
					} -- 1005
				end -- 1000
			end -- 999
		end -- 999
	end -- 999
	return { -- 998
		success = false -- 998
	} -- 998
end) -- 998
HttpServer:postSchedule("/build", function(req) -- 1007
	do -- 1008
		local _type_0 = type(req) -- 1008
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1008
		if _tab_0 then -- 1008
			local path -- 1008
			do -- 1008
				local _obj_0 = req.body -- 1008
				local _type_1 = type(_obj_0) -- 1008
				if "table" == _type_1 or "userdata" == _type_1 then -- 1008
					path = _obj_0.path -- 1008
				end -- 1008
			end -- 1008
			if path ~= nil then -- 1008
				local _exp_0 = Path:getExt(path) -- 1009
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1009
					if '' == Path:getExt(Path:getName(path)) then -- 1010
						local content = Content:loadAsync(path) -- 1011
						if content then -- 1011
							local resultCodes = compileFileAsync(path, content) -- 1012
							if resultCodes then -- 1012
								return { -- 1013
									success = true, -- 1013
									resultCodes = resultCodes -- 1013
								} -- 1013
							end -- 1012
						end -- 1011
					end -- 1010
				end -- 1009
			end -- 1008
		end -- 1008
	end -- 1008
	return { -- 1007
		success = false -- 1007
	} -- 1007
end) -- 1007
local extentionLevels = { -- 1016
	vs = 2, -- 1016
	bl = 2, -- 1017
	ts = 1, -- 1018
	tsx = 1, -- 1019
	tl = 1, -- 1020
	yue = 1, -- 1021
	xml = 1, -- 1022
	lua = 0 -- 1023
} -- 1015
HttpServer:post("/assets", function() -- 1025
	local Entry = require("Script.Dev.Entry") -- 1028
	local engineDev = Entry.getEngineDev() -- 1029
	local visitAssets -- 1030
	visitAssets = function(path, tag) -- 1030
		local isWorkspace = tag == "Workspace" -- 1031
		local builtin -- 1032
		if tag == "Builtin" then -- 1032
			builtin = true -- 1032
		else -- 1032
			builtin = nil -- 1032
		end -- 1032
		local children = nil -- 1033
		local dirs = Content:getDirs(path) -- 1034
		for _index_0 = 1, #dirs do -- 1035
			local dir = dirs[_index_0] -- 1035
			if isWorkspace then -- 1036
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1037
					goto _continue_0 -- 1038
				end -- 1037
			elseif dir == ".git" then -- 1039
				goto _continue_0 -- 1040
			end -- 1036
			if not children then -- 1041
				children = { } -- 1041
			end -- 1041
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1042
			::_continue_0:: -- 1036
		end -- 1035
		local files = Content:getFiles(path) -- 1043
		local names = { } -- 1044
		for _index_0 = 1, #files do -- 1045
			local file = files[_index_0] -- 1045
			if file:match("^%.") then -- 1046
				goto _continue_1 -- 1046
			end -- 1046
			local name = Path:getName(file) -- 1047
			local ext = names[name] -- 1048
			if ext then -- 1048
				local lv1 -- 1049
				do -- 1049
					local _exp_0 = extentionLevels[ext] -- 1049
					if _exp_0 ~= nil then -- 1049
						lv1 = _exp_0 -- 1049
					else -- 1049
						lv1 = -1 -- 1049
					end -- 1049
				end -- 1049
				ext = Path:getExt(file) -- 1050
				local lv2 -- 1051
				do -- 1051
					local _exp_0 = extentionLevels[ext] -- 1051
					if _exp_0 ~= nil then -- 1051
						lv2 = _exp_0 -- 1051
					else -- 1051
						lv2 = -1 -- 1051
					end -- 1051
				end -- 1051
				if lv2 > lv1 then -- 1052
					names[name] = ext -- 1053
				elseif lv2 == lv1 then -- 1054
					names[name .. '.' .. ext] = "" -- 1055
				end -- 1052
			else -- 1057
				ext = Path:getExt(file) -- 1057
				if not extentionLevels[ext] then -- 1058
					names[file] = "" -- 1059
				else -- 1061
					names[name] = ext -- 1061
				end -- 1058
			end -- 1048
			::_continue_1:: -- 1046
		end -- 1045
		do -- 1062
			local _accum_0 = { } -- 1062
			local _len_0 = 1 -- 1062
			for name, ext in pairs(names) do -- 1062
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1062
				_len_0 = _len_0 + 1 -- 1062
			end -- 1062
			files = _accum_0 -- 1062
		end -- 1062
		for _index_0 = 1, #files do -- 1063
			local file = files[_index_0] -- 1063
			if not children then -- 1064
				children = { } -- 1064
			end -- 1064
			children[#children + 1] = { -- 1066
				key = Path(path, file), -- 1066
				dir = false, -- 1067
				title = file, -- 1068
				builtin = builtin -- 1069
			} -- 1065
		end -- 1063
		if children then -- 1071
			table.sort(children, function(a, b) -- 1072
				if a.dir == b.dir then -- 1073
					return a.title < b.title -- 1074
				else -- 1076
					return a.dir -- 1076
				end -- 1073
			end) -- 1072
		end -- 1071
		if isWorkspace and children then -- 1077
			return children -- 1078
		else -- 1080
			return { -- 1081
				key = path, -- 1081
				dir = true, -- 1082
				title = Path:getFilename(path), -- 1083
				builtin = builtin, -- 1084
				children = children -- 1085
			} -- 1080
		end -- 1077
	end -- 1030
	local zh = (App.locale:match("^zh") ~= nil) -- 1087
	return { -- 1089
		key = Content.writablePath, -- 1089
		dir = true, -- 1090
		root = true, -- 1091
		title = "Assets", -- 1092
		children = (function() -- 1094
			local _tab_0 = { -- 1094
				{ -- 1095
					key = Path(Content.assetPath), -- 1095
					dir = true, -- 1096
					builtin = true, -- 1097
					title = zh and "内置资源" or "Built-in", -- 1098
					children = { -- 1100
						(function() -- 1100
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1100
							_with_0.title = zh and "说明文档" or "Readme" -- 1101
							return _with_0 -- 1100
						end)(), -- 1100
						(function() -- 1102
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1102
							_with_0.title = zh and "接口文档" or "API Doc" -- 1103
							return _with_0 -- 1102
						end)(), -- 1102
						(function() -- 1104
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1104
							_with_0.title = zh and "开发工具" or "Tools" -- 1105
							return _with_0 -- 1104
						end)(), -- 1104
						(function() -- 1106
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1106
							_with_0.title = zh and "字体" or "Font" -- 1107
							return _with_0 -- 1106
						end)(), -- 1106
						(function() -- 1108
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1108
							_with_0.title = zh and "程序库" or "Lib" -- 1109
							if engineDev then -- 1110
								local _list_0 = _with_0.children -- 1111
								for _index_0 = 1, #_list_0 do -- 1111
									local child = _list_0[_index_0] -- 1111
									if not (child.title == "Dora") then -- 1112
										goto _continue_0 -- 1112
									end -- 1112
									local title = zh and "zh-Hans" or "en" -- 1113
									do -- 1114
										local _accum_0 = { } -- 1114
										local _len_0 = 1 -- 1114
										local _list_1 = child.children -- 1114
										for _index_1 = 1, #_list_1 do -- 1114
											local c = _list_1[_index_1] -- 1114
											if c.title ~= title then -- 1114
												_accum_0[_len_0] = c -- 1114
												_len_0 = _len_0 + 1 -- 1114
											end -- 1114
										end -- 1114
										child.children = _accum_0 -- 1114
									end -- 1114
									break -- 1115
									::_continue_0:: -- 1112
								end -- 1111
							else -- 1117
								local _accum_0 = { } -- 1117
								local _len_0 = 1 -- 1117
								local _list_0 = _with_0.children -- 1117
								for _index_0 = 1, #_list_0 do -- 1117
									local child = _list_0[_index_0] -- 1117
									if child.title ~= "Dora" then -- 1117
										_accum_0[_len_0] = child -- 1117
										_len_0 = _len_0 + 1 -- 1117
									end -- 1117
								end -- 1117
								_with_0.children = _accum_0 -- 1117
							end -- 1110
							return _with_0 -- 1108
						end)(), -- 1108
						(function() -- 1118
							if engineDev then -- 1118
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1119
								local _obj_0 = _with_0.children -- 1120
								_obj_0[#_obj_0 + 1] = { -- 1121
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1121
									dir = false, -- 1122
									builtin = true, -- 1123
									title = "init.yue" -- 1124
								} -- 1120
								return _with_0 -- 1119
							end -- 1118
						end)() -- 1118
					} -- 1099
				} -- 1094
			} -- 1128
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1128
			local _idx_0 = #_tab_0 + 1 -- 1128
			for _index_0 = 1, #_obj_0 do -- 1128
				local _value_0 = _obj_0[_index_0] -- 1128
				_tab_0[_idx_0] = _value_0 -- 1128
				_idx_0 = _idx_0 + 1 -- 1128
			end -- 1128
			return _tab_0 -- 1094
		end)() -- 1093
	} -- 1088
end) -- 1025
HttpServer:postSchedule("/run", function(req) -- 1132
	do -- 1133
		local _type_0 = type(req) -- 1133
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1133
		if _tab_0 then -- 1133
			local file -- 1133
			do -- 1133
				local _obj_0 = req.body -- 1133
				local _type_1 = type(_obj_0) -- 1133
				if "table" == _type_1 or "userdata" == _type_1 then -- 1133
					file = _obj_0.file -- 1133
				end -- 1133
			end -- 1133
			local asProj -- 1133
			do -- 1133
				local _obj_0 = req.body -- 1133
				local _type_1 = type(_obj_0) -- 1133
				if "table" == _type_1 or "userdata" == _type_1 then -- 1133
					asProj = _obj_0.asProj -- 1133
				end -- 1133
			end -- 1133
			if file ~= nil and asProj ~= nil then -- 1133
				if not Content:isAbsolutePath(file) then -- 1134
					local devFile = Path(Content.writablePath, file) -- 1135
					if Content:exist(devFile) then -- 1136
						file = devFile -- 1136
					end -- 1136
				end -- 1134
				local Entry = require("Script.Dev.Entry") -- 1137
				local workDir -- 1138
				if asProj then -- 1139
					workDir = getProjectDirFromFile(file) -- 1140
					if workDir then -- 1140
						Entry.allClear() -- 1141
						local target = Path(workDir, "init") -- 1142
						local success, err = Entry.enterEntryAsync({ -- 1143
							entryName = "Project", -- 1143
							fileName = target -- 1143
						}) -- 1143
						target = Path:getName(Path:getPath(target)) -- 1144
						return { -- 1145
							success = success, -- 1145
							target = target, -- 1145
							err = err -- 1145
						} -- 1145
					end -- 1140
				else -- 1147
					workDir = getProjectDirFromFile(file) -- 1147
				end -- 1139
				Entry.allClear() -- 1148
				file = Path:replaceExt(file, "") -- 1149
				local success, err = Entry.enterEntryAsync({ -- 1151
					entryName = Path:getName(file), -- 1151
					fileName = file, -- 1152
					workDir = workDir -- 1153
				}) -- 1150
				return { -- 1154
					success = success, -- 1154
					err = err -- 1154
				} -- 1154
			end -- 1133
		end -- 1133
	end -- 1133
	return { -- 1132
		success = false -- 1132
	} -- 1132
end) -- 1132
HttpServer:postSchedule("/stop", function() -- 1156
	local Entry = require("Script.Dev.Entry") -- 1157
	return { -- 1158
		success = Entry.stop() -- 1158
	} -- 1158
end) -- 1156
local minifyAsync -- 1160
minifyAsync = function(sourcePath, minifyPath) -- 1160
	if not Content:exist(sourcePath) then -- 1161
		return -- 1161
	end -- 1161
	local Entry = require("Script.Dev.Entry") -- 1162
	local errors = { } -- 1163
	local files = Entry.getAllFiles(sourcePath, { -- 1164
		"lua" -- 1164
	}, true) -- 1164
	do -- 1165
		local _accum_0 = { } -- 1165
		local _len_0 = 1 -- 1165
		for _index_0 = 1, #files do -- 1165
			local file = files[_index_0] -- 1165
			if file:sub(1, 1) ~= '.' then -- 1165
				_accum_0[_len_0] = file -- 1165
				_len_0 = _len_0 + 1 -- 1165
			end -- 1165
		end -- 1165
		files = _accum_0 -- 1165
	end -- 1165
	local paths -- 1166
	do -- 1166
		local _tbl_0 = { } -- 1166
		for _index_0 = 1, #files do -- 1166
			local file = files[_index_0] -- 1166
			_tbl_0[Path:getPath(file)] = true -- 1166
		end -- 1166
		paths = _tbl_0 -- 1166
	end -- 1166
	for path in pairs(paths) do -- 1167
		Content:mkdir(Path(minifyPath, path)) -- 1167
	end -- 1167
	local _ <close> = setmetatable({ }, { -- 1168
		__close = function() -- 1168
			package.loaded["luaminify.FormatMini"] = nil -- 1169
			package.loaded["luaminify.ParseLua"] = nil -- 1170
			package.loaded["luaminify.Scope"] = nil -- 1171
			package.loaded["luaminify.Util"] = nil -- 1172
		end -- 1168
	}) -- 1168
	local FormatMini -- 1173
	do -- 1173
		local _obj_0 = require("luaminify") -- 1173
		FormatMini = _obj_0.FormatMini -- 1173
	end -- 1173
	local fileCount = #files -- 1174
	local count = 0 -- 1175
	for _index_0 = 1, #files do -- 1176
		local file = files[_index_0] -- 1176
		thread(function() -- 1177
			local _ <close> = setmetatable({ }, { -- 1178
				__close = function() -- 1178
					count = count + 1 -- 1178
				end -- 1178
			}) -- 1178
			local input = Path(sourcePath, file) -- 1179
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1180
			if Content:exist(input) then -- 1181
				local sourceCodes = Content:loadAsync(input) -- 1182
				local res, err = FormatMini(sourceCodes) -- 1183
				if res then -- 1184
					Content:saveAsync(output, res) -- 1185
					return print("Minify " .. tostring(file)) -- 1186
				else -- 1188
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1188
				end -- 1184
			else -- 1190
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1190
			end -- 1181
		end) -- 1177
		sleep() -- 1191
	end -- 1176
	wait(function() -- 1192
		return count == fileCount -- 1192
	end) -- 1192
	if #errors > 0 then -- 1193
		print(table.concat(errors, '\n')) -- 1194
	end -- 1193
	print("Obfuscation done.") -- 1195
	return files -- 1196
end -- 1160
local zipping = false -- 1198
HttpServer:postSchedule("/zip", function(req) -- 1200
	do -- 1201
		local _type_0 = type(req) -- 1201
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1201
		if _tab_0 then -- 1201
			local path -- 1201
			do -- 1201
				local _obj_0 = req.body -- 1201
				local _type_1 = type(_obj_0) -- 1201
				if "table" == _type_1 or "userdata" == _type_1 then -- 1201
					path = _obj_0.path -- 1201
				end -- 1201
			end -- 1201
			local zipFile -- 1201
			do -- 1201
				local _obj_0 = req.body -- 1201
				local _type_1 = type(_obj_0) -- 1201
				if "table" == _type_1 or "userdata" == _type_1 then -- 1201
					zipFile = _obj_0.zipFile -- 1201
				end -- 1201
			end -- 1201
			local obfuscated -- 1201
			do -- 1201
				local _obj_0 = req.body -- 1201
				local _type_1 = type(_obj_0) -- 1201
				if "table" == _type_1 or "userdata" == _type_1 then -- 1201
					obfuscated = _obj_0.obfuscated -- 1201
				end -- 1201
			end -- 1201
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1201
				if zipping then -- 1202
					goto failed -- 1202
				end -- 1202
				zipping = true -- 1203
				local _ <close> = setmetatable({ }, { -- 1204
					__close = function() -- 1204
						zipping = false -- 1204
					end -- 1204
				}) -- 1204
				if not Content:exist(path) then -- 1205
					goto failed -- 1205
				end -- 1205
				Content:mkdir(Path:getPath(zipFile)) -- 1206
				if obfuscated then -- 1207
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1208
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1209
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1210
					Content:remove(scriptPath) -- 1211
					Content:remove(obfuscatedPath) -- 1212
					Content:remove(tempPath) -- 1213
					Content:mkdir(scriptPath) -- 1214
					Content:mkdir(obfuscatedPath) -- 1215
					Content:mkdir(tempPath) -- 1216
					if not Content:copyAsync(path, tempPath) then -- 1217
						goto failed -- 1217
					end -- 1217
					local Entry = require("Script.Dev.Entry") -- 1218
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1219
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1220
						"tl", -- 1220
						"yue", -- 1220
						"lua", -- 1220
						"ts", -- 1220
						"tsx", -- 1220
						"vs", -- 1220
						"bl", -- 1220
						"xml", -- 1220
						"wa", -- 1220
						"mod" -- 1220
					}, true) -- 1220
					for _index_0 = 1, #scriptFiles do -- 1221
						local file = scriptFiles[_index_0] -- 1221
						Content:remove(Path(tempPath, file)) -- 1222
					end -- 1221
					for _index_0 = 1, #luaFiles do -- 1223
						local file = luaFiles[_index_0] -- 1223
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1224
					end -- 1223
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1225
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1226
					end) then -- 1225
						goto failed -- 1225
					end -- 1225
					return { -- 1227
						success = true -- 1227
					} -- 1227
				else -- 1229
					return { -- 1229
						success = Content:zipAsync(path, zipFile, function(file) -- 1229
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1230
						end) -- 1229
					} -- 1229
				end -- 1207
			end -- 1201
		end -- 1201
	end -- 1201
	::failed:: -- 1231
	return { -- 1200
		success = false -- 1200
	} -- 1200
end) -- 1200
HttpServer:postSchedule("/unzip", function(req) -- 1233
	do -- 1234
		local _type_0 = type(req) -- 1234
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1234
		if _tab_0 then -- 1234
			local zipFile -- 1234
			do -- 1234
				local _obj_0 = req.body -- 1234
				local _type_1 = type(_obj_0) -- 1234
				if "table" == _type_1 or "userdata" == _type_1 then -- 1234
					zipFile = _obj_0.zipFile -- 1234
				end -- 1234
			end -- 1234
			local path -- 1234
			do -- 1234
				local _obj_0 = req.body -- 1234
				local _type_1 = type(_obj_0) -- 1234
				if "table" == _type_1 or "userdata" == _type_1 then -- 1234
					path = _obj_0.path -- 1234
				end -- 1234
			end -- 1234
			if zipFile ~= nil and path ~= nil then -- 1234
				return { -- 1235
					success = Content:unzipAsync(zipFile, path, function(file) -- 1235
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1236
					end) -- 1235
				} -- 1235
			end -- 1234
		end -- 1234
	end -- 1234
	return { -- 1233
		success = false -- 1233
	} -- 1233
end) -- 1233
HttpServer:post("/editing-info", function(req) -- 1238
	local Entry = require("Script.Dev.Entry") -- 1239
	local config = Entry.getConfig() -- 1240
	local _type_0 = type(req) -- 1241
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1241
	local _match_0 = false -- 1241
	if _tab_0 then -- 1241
		local editingInfo -- 1241
		do -- 1241
			local _obj_0 = req.body -- 1241
			local _type_1 = type(_obj_0) -- 1241
			if "table" == _type_1 or "userdata" == _type_1 then -- 1241
				editingInfo = _obj_0.editingInfo -- 1241
			end -- 1241
		end -- 1241
		if editingInfo ~= nil then -- 1241
			_match_0 = true -- 1241
			config.editingInfo = editingInfo -- 1242
			return { -- 1243
				success = true -- 1243
			} -- 1243
		end -- 1241
	end -- 1241
	if not _match_0 then -- 1241
		if not (config.editingInfo ~= nil) then -- 1245
			local folder -- 1246
			if App.locale:match('^zh') then -- 1246
				folder = 'zh-Hans' -- 1246
			else -- 1246
				folder = 'en' -- 1246
			end -- 1246
			config.editingInfo = json.encode({ -- 1248
				index = 0, -- 1248
				files = { -- 1250
					{ -- 1251
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1251
						title = "welcome.md" -- 1252
					} -- 1250
				} -- 1249
			}) -- 1247
		end -- 1245
		return { -- 1256
			success = true, -- 1256
			editingInfo = config.editingInfo -- 1256
		} -- 1256
	end -- 1241
end) -- 1238
HttpServer:post("/command", function(req) -- 1258
	do -- 1259
		local _type_0 = type(req) -- 1259
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1259
		if _tab_0 then -- 1259
			local code -- 1259
			do -- 1259
				local _obj_0 = req.body -- 1259
				local _type_1 = type(_obj_0) -- 1259
				if "table" == _type_1 or "userdata" == _type_1 then -- 1259
					code = _obj_0.code -- 1259
				end -- 1259
			end -- 1259
			local log -- 1259
			do -- 1259
				local _obj_0 = req.body -- 1259
				local _type_1 = type(_obj_0) -- 1259
				if "table" == _type_1 or "userdata" == _type_1 then -- 1259
					log = _obj_0.log -- 1259
				end -- 1259
			end -- 1259
			if code ~= nil and log ~= nil then -- 1259
				emit("AppCommand", code, log) -- 1260
				return { -- 1261
					success = true -- 1261
				} -- 1261
			end -- 1259
		end -- 1259
	end -- 1259
	return { -- 1258
		success = false -- 1258
	} -- 1258
end) -- 1258
HttpServer:post("/log/save", function() -- 1263
	local folder = ".download" -- 1264
	local fullLogFile = "dora_full_logs.txt" -- 1265
	local fullFolder = Path(Content.writablePath, folder) -- 1266
	Content:mkdir(fullFolder) -- 1267
	local logPath = Path(fullFolder, fullLogFile) -- 1268
	if App:saveLog(logPath) then -- 1269
		return { -- 1270
			success = true, -- 1270
			path = Path(folder, fullLogFile) -- 1270
		} -- 1270
	end -- 1269
	return { -- 1263
		success = false -- 1263
	} -- 1263
end) -- 1263
HttpServer:post("/yarn/check", function(req) -- 1272
	local yarncompile = require("yarncompile") -- 1273
	do -- 1274
		local _type_0 = type(req) -- 1274
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1274
		if _tab_0 then -- 1274
			local code -- 1274
			do -- 1274
				local _obj_0 = req.body -- 1274
				local _type_1 = type(_obj_0) -- 1274
				if "table" == _type_1 or "userdata" == _type_1 then -- 1274
					code = _obj_0.code -- 1274
				end -- 1274
			end -- 1274
			if code ~= nil then -- 1274
				local jsonObject = json.decode(code) -- 1275
				if jsonObject then -- 1275
					local errors = { } -- 1276
					local _list_0 = jsonObject.nodes -- 1277
					for _index_0 = 1, #_list_0 do -- 1277
						local node = _list_0[_index_0] -- 1277
						local title, body = node.title, node.body -- 1278
						local luaCode, err = yarncompile(body) -- 1279
						if not luaCode then -- 1279
							errors[#errors + 1] = title .. ":" .. err -- 1280
						end -- 1279
					end -- 1277
					return { -- 1281
						success = true, -- 1281
						syntaxError = table.concat(errors, "\n\n") -- 1281
					} -- 1281
				end -- 1275
			end -- 1274
		end -- 1274
	end -- 1274
	return { -- 1272
		success = false -- 1272
	} -- 1272
end) -- 1272
HttpServer:post("/yarn/check-file", function(req) -- 1283
	local yarncompile = require("yarncompile") -- 1284
	do -- 1285
		local _type_0 = type(req) -- 1285
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1285
		if _tab_0 then -- 1285
			local code -- 1285
			do -- 1285
				local _obj_0 = req.body -- 1285
				local _type_1 = type(_obj_0) -- 1285
				if "table" == _type_1 or "userdata" == _type_1 then -- 1285
					code = _obj_0.code -- 1285
				end -- 1285
			end -- 1285
			if code ~= nil then -- 1285
				local res, _, err = yarncompile(code, true) -- 1286
				if not res then -- 1286
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1287
					return { -- 1288
						success = false, -- 1288
						message = message, -- 1288
						line = line, -- 1288
						column = column, -- 1288
						node = node -- 1288
					} -- 1288
				end -- 1286
			end -- 1285
		end -- 1285
	end -- 1285
	return { -- 1283
		success = true -- 1283
	} -- 1283
end) -- 1283
local getWaProjectDirFromFile -- 1290
getWaProjectDirFromFile = function(file) -- 1290
	local writablePath = Content.writablePath -- 1291
	local parent, current -- 1292
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1292
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1293
	else -- 1295
		parent, current = nil, nil -- 1295
	end -- 1292
	if not current then -- 1296
		return nil -- 1296
	end -- 1296
	repeat -- 1297
		current = Path:getPath(current) -- 1298
		if current == "" then -- 1299
			break -- 1299
		end -- 1299
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1300
		for _index_0 = 1, #_list_0 do -- 1300
			local f = _list_0[_index_0] -- 1300
			if Path:getFilename(f):lower() == "wa.mod" then -- 1301
				return Path(parent, current, Path:getPath(f)) -- 1302
			end -- 1301
		end -- 1300
	until false -- 1297
	return nil -- 1304
end -- 1290
HttpServer:postSchedule("/wa/build", function(req) -- 1306
	do -- 1307
		local _type_0 = type(req) -- 1307
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1307
		if _tab_0 then -- 1307
			local path -- 1307
			do -- 1307
				local _obj_0 = req.body -- 1307
				local _type_1 = type(_obj_0) -- 1307
				if "table" == _type_1 or "userdata" == _type_1 then -- 1307
					path = _obj_0.path -- 1307
				end -- 1307
			end -- 1307
			if path ~= nil then -- 1307
				local projDir = getWaProjectDirFromFile(path) -- 1308
				if projDir then -- 1308
					local message = Wasm:buildWaAsync(projDir) -- 1309
					if message == "" then -- 1310
						return { -- 1311
							success = true -- 1311
						} -- 1311
					else -- 1313
						return { -- 1313
							success = false, -- 1313
							message = message -- 1313
						} -- 1313
					end -- 1310
				else -- 1315
					return { -- 1315
						success = false, -- 1315
						message = 'Wa file needs a project' -- 1315
					} -- 1315
				end -- 1308
			end -- 1307
		end -- 1307
	end -- 1307
	return { -- 1316
		success = false, -- 1316
		message = 'failed to build' -- 1316
	} -- 1316
end) -- 1306
HttpServer:postSchedule("/wa/format", function(req) -- 1318
	do -- 1319
		local _type_0 = type(req) -- 1319
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1319
		if _tab_0 then -- 1319
			local file -- 1319
			do -- 1319
				local _obj_0 = req.body -- 1319
				local _type_1 = type(_obj_0) -- 1319
				if "table" == _type_1 or "userdata" == _type_1 then -- 1319
					file = _obj_0.file -- 1319
				end -- 1319
			end -- 1319
			if file ~= nil then -- 1319
				local code = Wasm:formatWaAsync(file) -- 1320
				if code == "" then -- 1321
					return { -- 1322
						success = false -- 1322
					} -- 1322
				else -- 1324
					return { -- 1324
						success = true, -- 1324
						code = code -- 1324
					} -- 1324
				end -- 1321
			end -- 1319
		end -- 1319
	end -- 1319
	return { -- 1325
		success = false -- 1325
	} -- 1325
end) -- 1318
HttpServer:postSchedule("/wa/create", function(req) -- 1327
	do -- 1328
		local _type_0 = type(req) -- 1328
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1328
		if _tab_0 then -- 1328
			local path -- 1328
			do -- 1328
				local _obj_0 = req.body -- 1328
				local _type_1 = type(_obj_0) -- 1328
				if "table" == _type_1 or "userdata" == _type_1 then -- 1328
					path = _obj_0.path -- 1328
				end -- 1328
			end -- 1328
			if path ~= nil then -- 1328
				if not Content:exist(Path:getPath(path)) then -- 1329
					return { -- 1330
						success = false, -- 1330
						message = "target path not existed" -- 1330
					} -- 1330
				end -- 1329
				if Content:exist(path) then -- 1331
					return { -- 1332
						success = false, -- 1332
						message = "target project folder existed" -- 1332
					} -- 1332
				end -- 1331
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1333
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1334
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1335
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1336
					return { -- 1339
						success = false, -- 1339
						message = "missing template project" -- 1339
					} -- 1339
				end -- 1336
				if not Content:mkdir(path) then -- 1340
					return { -- 1341
						success = false, -- 1341
						message = "failed to create project folder" -- 1341
					} -- 1341
				end -- 1340
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1342
					Content:remove(path) -- 1343
					return { -- 1344
						success = false, -- 1344
						message = "failed to copy template" -- 1344
					} -- 1344
				end -- 1342
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1345
					Content:remove(path) -- 1346
					return { -- 1347
						success = false, -- 1347
						message = "failed to copy template" -- 1347
					} -- 1347
				end -- 1345
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1348
					Content:remove(path) -- 1349
					return { -- 1350
						success = false, -- 1350
						message = "failed to copy template" -- 1350
					} -- 1350
				end -- 1348
				return { -- 1351
					success = true -- 1351
				} -- 1351
			end -- 1328
		end -- 1328
	end -- 1328
	return { -- 1327
		success = false, -- 1327
		message = "invalid call" -- 1327
	} -- 1327
end) -- 1327
local _anon_func_5 = function(path) -- 1360
	local _val_0 = Path:getExt(path) -- 1360
	return "ts" == _val_0 or "tsx" == _val_0 -- 1360
end -- 1360
local _anon_func_6 = function(f) -- 1390
	local _val_0 = Path:getExt(f) -- 1390
	return "ts" == _val_0 or "tsx" == _val_0 -- 1390
end -- 1390
HttpServer:postSchedule("/ts/build", function(req) -- 1353
	do -- 1354
		local _type_0 = type(req) -- 1354
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1354
		if _tab_0 then -- 1354
			local path -- 1354
			do -- 1354
				local _obj_0 = req.body -- 1354
				local _type_1 = type(_obj_0) -- 1354
				if "table" == _type_1 or "userdata" == _type_1 then -- 1354
					path = _obj_0.path -- 1354
				end -- 1354
			end -- 1354
			if path ~= nil then -- 1354
				if HttpServer.wsConnectionCount == 0 then -- 1355
					return { -- 1356
						success = false, -- 1356
						message = "Web IDE not connected" -- 1356
					} -- 1356
				end -- 1355
				if not Content:exist(path) then -- 1357
					return { -- 1358
						success = false, -- 1358
						message = "path not existed" -- 1358
					} -- 1358
				end -- 1357
				if not Content:isdir(path) then -- 1359
					if not (_anon_func_5(path)) then -- 1360
						return { -- 1361
							success = false, -- 1361
							message = "expecting a TypeScript file" -- 1361
						} -- 1361
					end -- 1360
					local messages = { } -- 1362
					local content = Content:load(path) -- 1363
					if not content then -- 1364
						return { -- 1365
							success = false, -- 1365
							message = "failed to read file" -- 1365
						} -- 1365
					end -- 1364
					emit("AppWS", "Send", json.encode({ -- 1366
						name = "UpdateTSCode", -- 1366
						file = path, -- 1366
						content = content -- 1366
					})) -- 1366
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1367
						local done = false -- 1368
						do -- 1369
							local _with_0 = Node() -- 1369
							_with_0:gslot("AppWS", function(event) -- 1370
								if event.type == "Receive" then -- 1371
									_with_0:removeFromParent() -- 1372
									local res = json.decode(event.msg) -- 1373
									if res then -- 1373
										if res.name == "TranspileTS" then -- 1374
											if res.success then -- 1375
												local luaFile = Path:replaceExt(path, "lua") -- 1376
												Content:save(luaFile, res.luaCode) -- 1377
												messages[#messages + 1] = { -- 1378
													success = true, -- 1378
													file = path -- 1378
												} -- 1378
											else -- 1380
												messages[#messages + 1] = { -- 1380
													success = false, -- 1380
													file = path, -- 1380
													message = res.message -- 1380
												} -- 1380
											end -- 1375
											done = true -- 1381
										end -- 1374
									end -- 1373
								end -- 1371
							end) -- 1370
						end -- 1369
						emit("AppWS", "Send", json.encode({ -- 1382
							name = "TranspileTS", -- 1382
							file = path, -- 1382
							content = content -- 1382
						})) -- 1382
						wait(function() -- 1383
							return done -- 1383
						end) -- 1383
					end -- 1367
					return { -- 1384
						success = true, -- 1384
						messages = messages -- 1384
					} -- 1384
				else -- 1386
					local files = Content:getAllFiles(path) -- 1386
					local fileData = { } -- 1387
					local messages = { } -- 1388
					for _index_0 = 1, #files do -- 1389
						local f = files[_index_0] -- 1389
						if not (_anon_func_6(f)) then -- 1390
							goto _continue_0 -- 1390
						end -- 1390
						local file = Path(path, f) -- 1391
						local content = Content:load(file) -- 1392
						if content then -- 1392
							fileData[file] = content -- 1393
							emit("AppWS", "Send", json.encode({ -- 1394
								name = "UpdateTSCode", -- 1394
								file = file, -- 1394
								content = content -- 1394
							})) -- 1394
						else -- 1396
							messages[#messages + 1] = { -- 1396
								success = false, -- 1396
								file = file, -- 1396
								message = "failed to read file" -- 1396
							} -- 1396
						end -- 1392
						::_continue_0:: -- 1390
					end -- 1389
					for file, content in pairs(fileData) do -- 1397
						if "d" == Path:getExt(Path:getName(file)) then -- 1398
							goto _continue_1 -- 1398
						end -- 1398
						local done = false -- 1399
						do -- 1400
							local _with_0 = Node() -- 1400
							_with_0:gslot("AppWS", function(event) -- 1401
								if event.type == "Receive" then -- 1402
									_with_0:removeFromParent() -- 1403
									local res = json.decode(event.msg) -- 1404
									if res then -- 1404
										if res.name == "TranspileTS" then -- 1405
											if res.success then -- 1406
												local luaFile = Path:replaceExt(file, "lua") -- 1407
												Content:save(luaFile, res.luaCode) -- 1408
												messages[#messages + 1] = { -- 1409
													success = true, -- 1409
													file = file -- 1409
												} -- 1409
											else -- 1411
												messages[#messages + 1] = { -- 1411
													success = false, -- 1411
													file = file, -- 1411
													message = res.message -- 1411
												} -- 1411
											end -- 1406
											done = true -- 1412
										end -- 1405
									end -- 1404
								end -- 1402
							end) -- 1401
						end -- 1400
						emit("AppWS", "Send", json.encode({ -- 1413
							name = "TranspileTS", -- 1413
							file = file, -- 1413
							content = content -- 1413
						})) -- 1413
						wait(function() -- 1414
							return done -- 1414
						end) -- 1414
						::_continue_1:: -- 1398
					end -- 1397
					return { -- 1415
						success = true, -- 1415
						messages = messages -- 1415
					} -- 1415
				end -- 1359
			end -- 1354
		end -- 1354
	end -- 1354
	return { -- 1353
		success = false -- 1353
	} -- 1353
end) -- 1353
HttpServer:post("/download", function(req) -- 1417
	do -- 1418
		local _type_0 = type(req) -- 1418
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1418
		if _tab_0 then -- 1418
			local url -- 1418
			do -- 1418
				local _obj_0 = req.body -- 1418
				local _type_1 = type(_obj_0) -- 1418
				if "table" == _type_1 or "userdata" == _type_1 then -- 1418
					url = _obj_0.url -- 1418
				end -- 1418
			end -- 1418
			local target -- 1418
			do -- 1418
				local _obj_0 = req.body -- 1418
				local _type_1 = type(_obj_0) -- 1418
				if "table" == _type_1 or "userdata" == _type_1 then -- 1418
					target = _obj_0.target -- 1418
				end -- 1418
			end -- 1418
			if url ~= nil and target ~= nil then -- 1418
				local Entry = require("Script.Dev.Entry") -- 1419
				Entry.downloadFile(url, target) -- 1420
				return { -- 1421
					success = true -- 1421
				} -- 1421
			end -- 1418
		end -- 1418
	end -- 1418
	return { -- 1417
		success = false -- 1417
	} -- 1417
end) -- 1417
local status = { } -- 1423
_module_0 = status -- 1424
status.buildAsync = function(path) -- 1426
	if not Content:exist(path) then -- 1427
		return { -- 1428
			success = false, -- 1428
			file = path, -- 1428
			message = "file not existed" -- 1428
		} -- 1428
	end -- 1427
	do -- 1429
		local _exp_0 = Path:getExt(path) -- 1429
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1429
			if '' == Path:getExt(Path:getName(path)) then -- 1430
				local content = Content:loadAsync(path) -- 1431
				if content then -- 1431
					local resultCodes, err = compileFileAsync(path, content) -- 1432
					if resultCodes then -- 1432
						return { -- 1433
							success = true, -- 1433
							file = path -- 1433
						} -- 1433
					else -- 1435
						return { -- 1435
							success = false, -- 1435
							file = path, -- 1435
							message = err -- 1435
						} -- 1435
					end -- 1432
				end -- 1431
			end -- 1430
		elseif "lua" == _exp_0 then -- 1436
			local content = Content:loadAsync(path) -- 1437
			if content then -- 1437
				do -- 1438
					local isTIC80 = CheckTIC80Code(content) -- 1438
					if isTIC80 then -- 1438
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1439
					end -- 1438
				end -- 1438
				local success, info -- 1440
				do -- 1440
					local _obj_0 = luaCheck(path, content) -- 1440
					success, info = _obj_0.success, _obj_0.info -- 1440
				end -- 1440
				if success then -- 1441
					return { -- 1442
						success = true, -- 1442
						file = path -- 1442
					} -- 1442
				elseif info and #info > 0 then -- 1443
					local messages = { } -- 1444
					for _index_0 = 1, #info do -- 1445
						local _des_0 = info[_index_0] -- 1445
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 1445
						local lineText = "" -- 1446
						if line then -- 1447
							local currentLine = 1 -- 1448
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1449
								if currentLine == line then -- 1450
									lineText = text -- 1451
									break -- 1452
								end -- 1450
								currentLine = currentLine + 1 -- 1453
							end -- 1449
						end -- 1447
						if line then -- 1454
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1455
						else -- 1457
							messages[#messages + 1] = message -- 1457
						end -- 1454
					end -- 1445
					return { -- 1458
						success = false, -- 1458
						file = path, -- 1458
						message = table.concat(messages, "\n") -- 1458
					} -- 1458
				else -- 1460
					return { -- 1460
						success = false, -- 1460
						file = path, -- 1460
						message = "lua check failed" -- 1460
					} -- 1460
				end -- 1441
			end -- 1437
		elseif "yarn" == _exp_0 then -- 1461
			local content = Content:loadAsync(path) -- 1462
			if content then -- 1462
				local res, _, err = yarncompile(content, true) -- 1463
				if res then -- 1463
					return { -- 1464
						success = true, -- 1464
						file = path -- 1464
					} -- 1464
				else -- 1466
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1466
					local lineText = "" -- 1467
					if line then -- 1468
						local currentLine = 1 -- 1469
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1470
							if currentLine == line then -- 1471
								lineText = text -- 1472
								break -- 1473
							end -- 1471
							currentLine = currentLine + 1 -- 1474
						end -- 1470
					end -- 1468
					if node ~= "" then -- 1475
						node = "node: " .. tostring(node) .. ", " -- 1476
					else -- 1477
						node = "" -- 1477
					end -- 1475
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1478
					return { -- 1479
						success = false, -- 1479
						file = path, -- 1479
						message = message -- 1479
					} -- 1479
				end -- 1463
			end -- 1462
		end -- 1429
	end -- 1429
	return { -- 1480
		success = false, -- 1480
		file = path, -- 1480
		message = "invalid file to build" -- 1480
	} -- 1480
end -- 1426
thread(function() -- 1482
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1483
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1484
	if Content:exist(doraWeb) then -- 1485
		local needReload -- 1486
		if Content:exist(doraReady) then -- 1486
			needReload = App.version ~= Content:load(doraReady) -- 1487
		else -- 1488
			needReload = true -- 1488
		end -- 1486
		if needReload then -- 1489
			Content:remove(Path(Content.appPath, ".www")) -- 1490
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1491
			Content:save(doraReady, App.version) -- 1495
			print("Dora Dora is ready!") -- 1496
		end -- 1489
	end -- 1485
	if HttpServer:start(8866) then -- 1497
		local localIP = HttpServer.localIP -- 1498
		if localIP == "" then -- 1499
			localIP = "localhost" -- 1499
		end -- 1499
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1500
		return HttpServer:startWS(8868) -- 1501
	else -- 1503
		status.url = nil -- 1503
		return print("8866 Port not available!") -- 1504
	end -- 1497
end) -- 1482
return _module_0 -- 1
