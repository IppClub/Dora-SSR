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
			if sessionId ~= nil and prompt ~= nil then -- 141
				return WebIDEAgentSession.sendPrompt(sessionId, prompt) -- 142
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
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 723
	if columns and #columns > 0 then -- 724
		local expected = { -- 726
			id = true, -- 726
			name = true, -- 727
			url = true, -- 728
			model = true, -- 729
			api_key = true, -- 730
			context_window = true, -- 731
			supports_function_calling = true, -- 732
			active = true, -- 733
			created_at = true, -- 734
			updated_at = true -- 735
		} -- 725
		local valid = #columns == 10 -- 737
		if valid then -- 738
			for _index_0 = 1, #columns do -- 739
				local row = columns[_index_0] -- 739
				local columnName = tostring(row[2]) -- 740
				if not expected[columnName] then -- 741
					valid = false -- 742
					break -- 743
				end -- 741
			end -- 739
		end -- 738
		if not valid then -- 744
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 745
		end -- 744
	end -- 724
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
	]]) -- 746
end -- 722
local normalizeContextWindow -- 761
normalizeContextWindow = function(value) -- 761
	local contextWindow = tonumber(value) -- 762
	if contextWindow == nil or contextWindow < 4000 then -- 763
		return 64000 -- 764
	end -- 763
	return math.max(4000, math.floor(contextWindow)) -- 765
end -- 761
HttpServer:post("/llm/list", function() -- 767
	ensureLLMConfigTable() -- 768
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 769
	local items -- 773
	if rows and #rows > 0 then -- 773
		local _accum_0 = { } -- 774
		local _len_0 = 1 -- 774
		for _index_0 = 1, #rows do -- 774
			local _des_0 = rows[_index_0] -- 774
			local id, name, url, model, key, contextWindow, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8] -- 774
			_accum_0[_len_0] = { -- 775
				id = id, -- 775
				name = name, -- 775
				url = url, -- 775
				model = model, -- 775
				key = key, -- 775
				contextWindow = normalizeContextWindow(contextWindow), -- 775
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 775
				active = active ~= 0 -- 775
			} -- 775
			_len_0 = _len_0 + 1 -- 775
		end -- 774
		items = _accum_0 -- 773
	end -- 773
	return { -- 776
		success = true, -- 776
		items = items -- 776
	} -- 776
end) -- 767
HttpServer:post("/llm/create", function(req) -- 778
	ensureLLMConfigTable() -- 779
	do -- 780
		local _type_0 = type(req) -- 780
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 780
		if _tab_0 then -- 780
			local body = req.body -- 780
			if body ~= nil then -- 780
				local name, url, model, key, active, contextWindow, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.supportsFunctionCalling -- 781
				local now = os.time() -- 782
				if name == nil or url == nil or model == nil or key == nil then -- 783
					return { -- 784
						success = false, -- 784
						message = "invalid" -- 784
					} -- 784
				end -- 783
				contextWindow = normalizeContextWindow(contextWindow) -- 785
				if supportsFunctionCalling == false then -- 786
					supportsFunctionCalling = 0 -- 786
				else -- 786
					supportsFunctionCalling = 1 -- 786
				end -- 786
				if active then -- 787
					active = 1 -- 787
				else -- 787
					active = 0 -- 787
				end -- 787
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 794
					tostring(name), -- 794
					tostring(url), -- 795
					tostring(model), -- 796
					tostring(key), -- 797
					contextWindow, -- 798
					supportsFunctionCalling, -- 799
					active, -- 800
					now, -- 801
					now -- 802
				}) -- 788
				return { -- 804
					success = affected >= 0 -- 804
				} -- 804
			end -- 780
		end -- 780
	end -- 780
	return { -- 778
		success = false, -- 778
		message = "invalid" -- 778
	} -- 778
end) -- 778
HttpServer:post("/llm/update", function(req) -- 806
	ensureLLMConfigTable() -- 807
	do -- 808
		local _type_0 = type(req) -- 808
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 808
		if _tab_0 then -- 808
			local body = req.body -- 808
			if body ~= nil then -- 808
				local id, name, url, model, key, active, contextWindow, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.supportsFunctionCalling -- 809
				local now = os.time() -- 810
				id = tonumber(id) -- 811
				if id == nil then -- 812
					return { -- 813
						success = false, -- 813
						message = "invalid" -- 813
					} -- 813
				end -- 812
				contextWindow = normalizeContextWindow(contextWindow) -- 814
				if supportsFunctionCalling == false then -- 815
					supportsFunctionCalling = 0 -- 815
				else -- 815
					supportsFunctionCalling = 1 -- 815
				end -- 815
				if active then -- 816
					active = 1 -- 816
				else -- 816
					active = 0 -- 816
				end -- 816
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 821
					tostring(name), -- 821
					tostring(url), -- 822
					tostring(model), -- 823
					tostring(key), -- 824
					contextWindow, -- 825
					supportsFunctionCalling, -- 826
					active, -- 827
					now, -- 828
					id -- 829
				}) -- 817
				return { -- 831
					success = affected >= 0 -- 831
				} -- 831
			end -- 808
		end -- 808
	end -- 808
	return { -- 806
		success = false, -- 806
		message = "invalid" -- 806
	} -- 806
end) -- 806
HttpServer:post("/llm/delete", function(req) -- 833
	ensureLLMConfigTable() -- 834
	do -- 835
		local _type_0 = type(req) -- 835
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 835
		if _tab_0 then -- 835
			local id -- 835
			do -- 835
				local _obj_0 = req.body -- 835
				local _type_1 = type(_obj_0) -- 835
				if "table" == _type_1 or "userdata" == _type_1 then -- 835
					id = _obj_0.id -- 835
				end -- 835
			end -- 835
			if id ~= nil then -- 835
				id = tonumber(id) -- 836
				if id == nil then -- 837
					return { -- 838
						success = false, -- 838
						message = "invalid" -- 838
					} -- 838
				end -- 837
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 839
					id -- 839
				}) -- 839
				return { -- 840
					success = affected >= 0 -- 840
				} -- 840
			end -- 835
		end -- 835
	end -- 835
	return { -- 833
		success = false, -- 833
		message = "invalid" -- 833
	} -- 833
end) -- 833
HttpServer:post("/new", function(req) -- 842
	do -- 843
		local _type_0 = type(req) -- 843
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 843
		if _tab_0 then -- 843
			local path -- 843
			do -- 843
				local _obj_0 = req.body -- 843
				local _type_1 = type(_obj_0) -- 843
				if "table" == _type_1 or "userdata" == _type_1 then -- 843
					path = _obj_0.path -- 843
				end -- 843
			end -- 843
			local content -- 843
			do -- 843
				local _obj_0 = req.body -- 843
				local _type_1 = type(_obj_0) -- 843
				if "table" == _type_1 or "userdata" == _type_1 then -- 843
					content = _obj_0.content -- 843
				end -- 843
			end -- 843
			local folder -- 843
			do -- 843
				local _obj_0 = req.body -- 843
				local _type_1 = type(_obj_0) -- 843
				if "table" == _type_1 or "userdata" == _type_1 then -- 843
					folder = _obj_0.folder -- 843
				end -- 843
			end -- 843
			if path ~= nil and content ~= nil and folder ~= nil then -- 843
				if Content:exist(path) then -- 844
					return { -- 845
						success = false, -- 845
						message = "TargetExisted" -- 845
					} -- 845
				end -- 844
				local parent = Path:getPath(path) -- 846
				local files = Content:getFiles(parent) -- 847
				if folder then -- 848
					local name = Path:getFilename(path):lower() -- 849
					for _index_0 = 1, #files do -- 850
						local file = files[_index_0] -- 850
						if name == Path:getFilename(file):lower() then -- 851
							return { -- 852
								success = false, -- 852
								message = "TargetExisted" -- 852
							} -- 852
						end -- 851
					end -- 850
					if Content:mkdir(path) then -- 853
						return { -- 854
							success = true -- 854
						} -- 854
					end -- 853
				else -- 856
					local name = Path:getName(path):lower() -- 856
					for _index_0 = 1, #files do -- 857
						local file = files[_index_0] -- 857
						if name == Path:getName(file):lower() then -- 858
							local ext = Path:getExt(file) -- 859
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 860
								goto _continue_0 -- 861
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 862
								goto _continue_0 -- 863
							end -- 860
							return { -- 864
								success = false, -- 864
								message = "SourceExisted" -- 864
							} -- 864
						end -- 858
						::_continue_0:: -- 858
					end -- 857
					if Content:save(path, content) then -- 865
						return { -- 866
							success = true -- 866
						} -- 866
					end -- 865
				end -- 848
			end -- 843
		end -- 843
	end -- 843
	return { -- 842
		success = false, -- 842
		message = "Failed" -- 842
	} -- 842
end) -- 842
HttpServer:post("/delete", function(req) -- 868
	do -- 869
		local _type_0 = type(req) -- 869
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 869
		if _tab_0 then -- 869
			local path -- 869
			do -- 869
				local _obj_0 = req.body -- 869
				local _type_1 = type(_obj_0) -- 869
				if "table" == _type_1 or "userdata" == _type_1 then -- 869
					path = _obj_0.path -- 869
				end -- 869
			end -- 869
			if path ~= nil then -- 869
				if Content:exist(path) then -- 870
					local projectRoot -- 871
					if Content:isdir(path) and isProjectRootDir(path) then -- 871
						projectRoot = path -- 871
					else -- 871
						projectRoot = nil -- 871
					end -- 871
					local parent = Path:getPath(path) -- 872
					local files = Content:getFiles(parent) -- 873
					local name = Path:getName(path):lower() -- 874
					local ext = Path:getExt(path) -- 875
					for _index_0 = 1, #files do -- 876
						local file = files[_index_0] -- 876
						if name == Path:getName(file):lower() then -- 877
							local _exp_0 = Path:getExt(file) -- 878
							if "tl" == _exp_0 then -- 878
								if ("vs" == ext) then -- 878
									Content:remove(Path(parent, file)) -- 879
								end -- 878
							elseif "lua" == _exp_0 then -- 880
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 880
									Content:remove(Path(parent, file)) -- 881
								end -- 880
							end -- 878
						end -- 877
					end -- 876
					if Content:remove(path) then -- 882
						if projectRoot then -- 883
							WebIDEAgentSession.deleteSessionsByProjectRoot(projectRoot) -- 884
						end -- 883
						return { -- 885
							success = true -- 885
						} -- 885
					end -- 882
				end -- 870
			end -- 869
		end -- 869
	end -- 869
	return { -- 868
		success = false -- 868
	} -- 868
end) -- 868
HttpServer:post("/rename", function(req) -- 887
	do -- 888
		local _type_0 = type(req) -- 888
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 888
		if _tab_0 then -- 888
			local old -- 888
			do -- 888
				local _obj_0 = req.body -- 888
				local _type_1 = type(_obj_0) -- 888
				if "table" == _type_1 or "userdata" == _type_1 then -- 888
					old = _obj_0.old -- 888
				end -- 888
			end -- 888
			local new -- 888
			do -- 888
				local _obj_0 = req.body -- 888
				local _type_1 = type(_obj_0) -- 888
				if "table" == _type_1 or "userdata" == _type_1 then -- 888
					new = _obj_0.new -- 888
				end -- 888
			end -- 888
			if old ~= nil and new ~= nil then -- 888
				if Content:exist(old) and not Content:exist(new) then -- 889
					local renamedDir = Content:isdir(old) -- 890
					local parent = Path:getPath(new) -- 891
					local files = Content:getFiles(parent) -- 892
					if renamedDir then -- 893
						local name = Path:getFilename(new):lower() -- 894
						for _index_0 = 1, #files do -- 895
							local file = files[_index_0] -- 895
							if name == Path:getFilename(file):lower() then -- 896
								return { -- 897
									success = false -- 897
								} -- 897
							end -- 896
						end -- 895
					else -- 899
						local name = Path:getName(new):lower() -- 899
						local ext = Path:getExt(new) -- 900
						for _index_0 = 1, #files do -- 901
							local file = files[_index_0] -- 901
							if name == Path:getName(file):lower() then -- 902
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 903
									goto _continue_0 -- 904
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 905
									goto _continue_0 -- 906
								end -- 903
								return { -- 907
									success = false -- 907
								} -- 907
							end -- 902
							::_continue_0:: -- 902
						end -- 901
					end -- 893
					if Content:move(old, new) then -- 908
						if renamedDir then -- 909
							WebIDEAgentSession.renameSessionsByProjectRoot(old, new) -- 910
						end -- 909
						local newParent = Path:getPath(new) -- 911
						parent = Path:getPath(old) -- 912
						files = Content:getFiles(parent) -- 913
						local newName = Path:getName(new) -- 914
						local oldName = Path:getName(old) -- 915
						local name = oldName:lower() -- 916
						local ext = Path:getExt(old) -- 917
						for _index_0 = 1, #files do -- 918
							local file = files[_index_0] -- 918
							if name == Path:getName(file):lower() then -- 919
								local _exp_0 = Path:getExt(file) -- 920
								if "tl" == _exp_0 then -- 920
									if ("vs" == ext) then -- 920
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 921
									end -- 920
								elseif "lua" == _exp_0 then -- 922
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 922
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 923
									end -- 922
								end -- 920
							end -- 919
						end -- 918
						return { -- 924
							success = true -- 924
						} -- 924
					end -- 908
				end -- 889
			end -- 888
		end -- 888
	end -- 888
	return { -- 887
		success = false -- 887
	} -- 887
end) -- 887
HttpServer:post("/exist", function(req) -- 926
	do -- 927
		local _type_0 = type(req) -- 927
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 927
		if _tab_0 then -- 927
			local file -- 927
			do -- 927
				local _obj_0 = req.body -- 927
				local _type_1 = type(_obj_0) -- 927
				if "table" == _type_1 or "userdata" == _type_1 then -- 927
					file = _obj_0.file -- 927
				end -- 927
			end -- 927
			if file ~= nil then -- 927
				do -- 928
					local projFile = req.body.projFile -- 928
					if projFile then -- 928
						local projDir = getProjectDirFromFile(projFile) -- 929
						if projDir then -- 929
							local scriptDir = Path(projDir, "Script") -- 930
							local searchPaths = Content.searchPaths -- 931
							if Content:exist(scriptDir) then -- 932
								Content:addSearchPath(scriptDir) -- 932
							end -- 932
							if Content:exist(projDir) then -- 933
								Content:addSearchPath(projDir) -- 933
							end -- 933
							local _ <close> = setmetatable({ }, { -- 934
								__close = function() -- 934
									Content.searchPaths = searchPaths -- 934
								end -- 934
							}) -- 934
							return { -- 935
								success = Content:exist(file) -- 935
							} -- 935
						end -- 929
					end -- 928
				end -- 928
				return { -- 936
					success = Content:exist(file) -- 936
				} -- 936
			end -- 927
		end -- 927
	end -- 927
	return { -- 926
		success = false -- 926
	} -- 926
end) -- 926
HttpServer:postSchedule("/read", function(req) -- 938
	do -- 939
		local _type_0 = type(req) -- 939
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 939
		if _tab_0 then -- 939
			local path -- 939
			do -- 939
				local _obj_0 = req.body -- 939
				local _type_1 = type(_obj_0) -- 939
				if "table" == _type_1 or "userdata" == _type_1 then -- 939
					path = _obj_0.path -- 939
				end -- 939
			end -- 939
			if path ~= nil then -- 939
				local readFile -- 940
				readFile = function() -- 940
					if Content:exist(path) then -- 941
						local content = Content:loadAsync(path) -- 942
						if content then -- 942
							return { -- 943
								content = content, -- 943
								success = true -- 943
							} -- 943
						end -- 942
					end -- 941
					return nil -- 940
				end -- 940
				do -- 944
					local projFile = req.body.projFile -- 944
					if projFile then -- 944
						local projDir = getProjectDirFromFile(projFile) -- 945
						if projDir then -- 945
							local scriptDir = Path(projDir, "Script") -- 946
							local searchPaths = Content.searchPaths -- 947
							if Content:exist(scriptDir) then -- 948
								Content:addSearchPath(scriptDir) -- 948
							end -- 948
							if Content:exist(projDir) then -- 949
								Content:addSearchPath(projDir) -- 949
							end -- 949
							local _ <close> = setmetatable({ }, { -- 950
								__close = function() -- 950
									Content.searchPaths = searchPaths -- 950
								end -- 950
							}) -- 950
							local result = readFile() -- 951
							if result then -- 951
								return result -- 951
							end -- 951
						end -- 945
					end -- 944
				end -- 944
				local result = readFile() -- 952
				if result then -- 952
					return result -- 952
				end -- 952
			end -- 939
		end -- 939
	end -- 939
	return { -- 938
		success = false -- 938
	} -- 938
end) -- 938
HttpServer:get("/read-sync", function(req) -- 954
	do -- 955
		local _type_0 = type(req) -- 955
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 955
		if _tab_0 then -- 955
			local params = req.params -- 955
			if params ~= nil then -- 955
				local path = params.path -- 956
				local exts -- 957
				if params.exts then -- 957
					local _accum_0 = { } -- 958
					local _len_0 = 1 -- 958
					for ext in params.exts:gmatch("[^|]*") do -- 958
						_accum_0[_len_0] = ext -- 959
						_len_0 = _len_0 + 1 -- 959
					end -- 958
					exts = _accum_0 -- 957
				else -- 960
					exts = { -- 960
						"" -- 960
					} -- 960
				end -- 957
				local readFile -- 961
				readFile = function() -- 961
					for _index_0 = 1, #exts do -- 962
						local ext = exts[_index_0] -- 962
						local targetPath = path .. ext -- 963
						if Content:exist(targetPath) then -- 964
							local content = Content:load(targetPath) -- 965
							if content then -- 965
								return { -- 966
									content = content, -- 966
									success = true, -- 966
									fullPath = Content:getFullPath(targetPath) -- 966
								} -- 966
							end -- 965
						end -- 964
					end -- 962
					return nil -- 961
				end -- 961
				local searchPaths = Content.searchPaths -- 967
				local _ <close> = setmetatable({ }, { -- 968
					__close = function() -- 968
						Content.searchPaths = searchPaths -- 968
					end -- 968
				}) -- 968
				do -- 969
					local projFile = req.params.projFile -- 969
					if projFile then -- 969
						local projDir = getProjectDirFromFile(projFile) -- 970
						if projDir then -- 970
							local scriptDir = Path(projDir, "Script") -- 971
							if Content:exist(scriptDir) then -- 972
								Content:addSearchPath(scriptDir) -- 972
							end -- 972
							if Content:exist(projDir) then -- 973
								Content:addSearchPath(projDir) -- 973
							end -- 973
						else -- 975
							projDir = Path:getPath(projFile) -- 975
							if Content:exist(projDir) then -- 976
								Content:addSearchPath(projDir) -- 976
							end -- 976
						end -- 970
					end -- 969
				end -- 969
				local result = readFile() -- 977
				if result then -- 977
					return result -- 977
				end -- 977
			end -- 955
		end -- 955
	end -- 955
	return { -- 954
		success = false -- 954
	} -- 954
end) -- 954
local compileFileAsync -- 979
compileFileAsync = function(inputFile, sourceCodes) -- 979
	local file = inputFile -- 980
	local searchPath -- 981
	do -- 981
		local dir = getProjectDirFromFile(inputFile) -- 981
		if dir then -- 981
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 982
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 983
		else -- 985
			file = Path:getRelative(inputFile, Content.writablePath) -- 985
			if file:sub(1, 2) == ".." then -- 986
				file = Path:getRelative(inputFile, Content.assetPath) -- 987
			end -- 986
			searchPath = "" -- 988
		end -- 981
	end -- 981
	local outputFile = Path:replaceExt(inputFile, "lua") -- 989
	local yueext = yue.options.extension -- 990
	local resultCodes = nil -- 991
	local resultError = nil -- 992
	do -- 993
		local _exp_0 = Path:getExt(inputFile) -- 993
		if yueext == _exp_0 then -- 993
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 994
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 995
				if not codes then -- 996
					resultError = err -- 997
					return -- 998
				end -- 996
				local extraGlobal -- 999
				if isTIC80 then -- 999
					extraGlobal = tic80APIs -- 999
				else -- 999
					extraGlobal = nil -- 999
				end -- 999
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1000
				if not success then -- 1001
					resultError = message -- 1002
					return -- 1003
				end -- 1001
				if codes == "" then -- 1004
					resultCodes = "" -- 1005
					return nil -- 1006
				end -- 1004
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1007
				return resultCodes -- 1008
			end, function(success) -- 995
				if not success then -- 1009
					Content:remove(outputFile) -- 1010
					if resultCodes == nil then -- 1011
						resultCodes = false -- 1012
					end -- 1011
				end -- 1009
			end) -- 995
		elseif "tl" == _exp_0 then -- 1013
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1014
			if isTIC80 then -- 1015
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1016
			end -- 1015
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1017
			if codes then -- 1017
				if isTIC80 then -- 1018
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1019
				end -- 1018
				resultCodes = codes -- 1020
				Content:saveAsync(outputFile, codes) -- 1021
			else -- 1023
				Content:remove(outputFile) -- 1023
				resultCodes = false -- 1024
				resultError = err -- 1025
			end -- 1017
		elseif "xml" == _exp_0 then -- 1026
			local codes, err = xml.tolua(sourceCodes) -- 1027
			if codes then -- 1027
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1028
				Content:saveAsync(outputFile, resultCodes) -- 1029
			else -- 1031
				Content:remove(outputFile) -- 1031
				resultCodes = false -- 1032
				resultError = err -- 1033
			end -- 1027
		end -- 993
	end -- 993
	wait(function() -- 1034
		return resultCodes ~= nil -- 1034
	end) -- 1034
	if resultCodes then -- 1035
		return resultCodes -- 1036
	else -- 1038
		return nil, resultError -- 1038
	end -- 1035
	return nil -- 979
end -- 979
HttpServer:postSchedule("/write", function(req) -- 1040
	do -- 1041
		local _type_0 = type(req) -- 1041
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1041
		if _tab_0 then -- 1041
			local path -- 1041
			do -- 1041
				local _obj_0 = req.body -- 1041
				local _type_1 = type(_obj_0) -- 1041
				if "table" == _type_1 or "userdata" == _type_1 then -- 1041
					path = _obj_0.path -- 1041
				end -- 1041
			end -- 1041
			local content -- 1041
			do -- 1041
				local _obj_0 = req.body -- 1041
				local _type_1 = type(_obj_0) -- 1041
				if "table" == _type_1 or "userdata" == _type_1 then -- 1041
					content = _obj_0.content -- 1041
				end -- 1041
			end -- 1041
			if path ~= nil and content ~= nil then -- 1041
				if Content:saveAsync(path, content) then -- 1042
					do -- 1043
						local _exp_0 = Path:getExt(path) -- 1043
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1043
							if '' == Path:getExt(Path:getName(path)) then -- 1044
								local resultCodes = compileFileAsync(path, content) -- 1045
								return { -- 1046
									success = true, -- 1046
									resultCodes = resultCodes -- 1046
								} -- 1046
							end -- 1044
						end -- 1043
					end -- 1043
					return { -- 1047
						success = true -- 1047
					} -- 1047
				end -- 1042
			end -- 1041
		end -- 1041
	end -- 1041
	return { -- 1040
		success = false -- 1040
	} -- 1040
end) -- 1040
HttpServer:postSchedule("/build", function(req) -- 1049
	do -- 1050
		local _type_0 = type(req) -- 1050
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1050
		if _tab_0 then -- 1050
			local path -- 1050
			do -- 1050
				local _obj_0 = req.body -- 1050
				local _type_1 = type(_obj_0) -- 1050
				if "table" == _type_1 or "userdata" == _type_1 then -- 1050
					path = _obj_0.path -- 1050
				end -- 1050
			end -- 1050
			if path ~= nil then -- 1050
				local _exp_0 = Path:getExt(path) -- 1051
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1051
					if '' == Path:getExt(Path:getName(path)) then -- 1052
						local content = Content:loadAsync(path) -- 1053
						if content then -- 1053
							local resultCodes = compileFileAsync(path, content) -- 1054
							if resultCodes then -- 1054
								return { -- 1055
									success = true, -- 1055
									resultCodes = resultCodes -- 1055
								} -- 1055
							end -- 1054
						end -- 1053
					end -- 1052
				end -- 1051
			end -- 1050
		end -- 1050
	end -- 1050
	return { -- 1049
		success = false -- 1049
	} -- 1049
end) -- 1049
local extentionLevels = { -- 1058
	vs = 2, -- 1058
	bl = 2, -- 1059
	ts = 1, -- 1060
	tsx = 1, -- 1061
	tl = 1, -- 1062
	yue = 1, -- 1063
	xml = 1, -- 1064
	lua = 0 -- 1065
} -- 1057
HttpServer:post("/assets", function() -- 1067
	local Entry = require("Script.Dev.Entry") -- 1070
	local engineDev = Entry.getEngineDev() -- 1071
	local visitAssets -- 1072
	visitAssets = function(path, tag) -- 1072
		local isWorkspace = tag == "Workspace" -- 1073
		local builtin -- 1074
		if tag == "Builtin" then -- 1074
			builtin = true -- 1074
		else -- 1074
			builtin = nil -- 1074
		end -- 1074
		local children = nil -- 1075
		local dirs = Content:getDirs(path) -- 1076
		for _index_0 = 1, #dirs do -- 1077
			local dir = dirs[_index_0] -- 1077
			if isWorkspace then -- 1078
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1079
					goto _continue_0 -- 1080
				end -- 1079
			elseif dir == ".git" then -- 1081
				goto _continue_0 -- 1082
			end -- 1078
			if not children then -- 1083
				children = { } -- 1083
			end -- 1083
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1084
			::_continue_0:: -- 1078
		end -- 1077
		local files = Content:getFiles(path) -- 1085
		local names = { } -- 1086
		for _index_0 = 1, #files do -- 1087
			local file = files[_index_0] -- 1087
			if file:match("^%.") then -- 1088
				goto _continue_1 -- 1088
			end -- 1088
			local name = Path:getName(file) -- 1089
			local ext = names[name] -- 1090
			if ext then -- 1090
				local lv1 -- 1091
				do -- 1091
					local _exp_0 = extentionLevels[ext] -- 1091
					if _exp_0 ~= nil then -- 1091
						lv1 = _exp_0 -- 1091
					else -- 1091
						lv1 = -1 -- 1091
					end -- 1091
				end -- 1091
				ext = Path:getExt(file) -- 1092
				local lv2 -- 1093
				do -- 1093
					local _exp_0 = extentionLevels[ext] -- 1093
					if _exp_0 ~= nil then -- 1093
						lv2 = _exp_0 -- 1093
					else -- 1093
						lv2 = -1 -- 1093
					end -- 1093
				end -- 1093
				if lv2 > lv1 then -- 1094
					names[name] = ext -- 1095
				elseif lv2 == lv1 then -- 1096
					names[name .. '.' .. ext] = "" -- 1097
				end -- 1094
			else -- 1099
				ext = Path:getExt(file) -- 1099
				if not extentionLevels[ext] then -- 1100
					names[file] = "" -- 1101
				else -- 1103
					names[name] = ext -- 1103
				end -- 1100
			end -- 1090
			::_continue_1:: -- 1088
		end -- 1087
		do -- 1104
			local _accum_0 = { } -- 1104
			local _len_0 = 1 -- 1104
			for name, ext in pairs(names) do -- 1104
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1104
				_len_0 = _len_0 + 1 -- 1104
			end -- 1104
			files = _accum_0 -- 1104
		end -- 1104
		for _index_0 = 1, #files do -- 1105
			local file = files[_index_0] -- 1105
			if not children then -- 1106
				children = { } -- 1106
			end -- 1106
			children[#children + 1] = { -- 1108
				key = Path(path, file), -- 1108
				dir = false, -- 1109
				title = file, -- 1110
				builtin = builtin -- 1111
			} -- 1107
		end -- 1105
		if children then -- 1113
			table.sort(children, function(a, b) -- 1114
				if a.dir == b.dir then -- 1115
					return a.title < b.title -- 1116
				else -- 1118
					return a.dir -- 1118
				end -- 1115
			end) -- 1114
		end -- 1113
		if isWorkspace and children then -- 1119
			return children -- 1120
		else -- 1122
			return { -- 1123
				key = path, -- 1123
				dir = true, -- 1124
				title = Path:getFilename(path), -- 1125
				builtin = builtin, -- 1126
				children = children -- 1127
			} -- 1122
		end -- 1119
	end -- 1072
	local zh = (App.locale:match("^zh") ~= nil) -- 1129
	return { -- 1131
		key = Content.writablePath, -- 1131
		dir = true, -- 1132
		root = true, -- 1133
		title = "Assets", -- 1134
		children = (function() -- 1136
			local _tab_0 = { -- 1136
				{ -- 1137
					key = Path(Content.assetPath), -- 1137
					dir = true, -- 1138
					builtin = true, -- 1139
					title = zh and "内置资源" or "Built-in", -- 1140
					children = { -- 1142
						(function() -- 1142
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1142
							_with_0.title = zh and "说明文档" or "Readme" -- 1143
							return _with_0 -- 1142
						end)(), -- 1142
						(function() -- 1144
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1144
							_with_0.title = zh and "接口文档" or "API Doc" -- 1145
							return _with_0 -- 1144
						end)(), -- 1144
						(function() -- 1146
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1146
							_with_0.title = zh and "开发工具" or "Tools" -- 1147
							return _with_0 -- 1146
						end)(), -- 1146
						(function() -- 1148
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1148
							_with_0.title = zh and "字体" or "Font" -- 1149
							return _with_0 -- 1148
						end)(), -- 1148
						(function() -- 1150
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1150
							_with_0.title = zh and "程序库" or "Lib" -- 1151
							if engineDev then -- 1152
								local _list_0 = _with_0.children -- 1153
								for _index_0 = 1, #_list_0 do -- 1153
									local child = _list_0[_index_0] -- 1153
									if not (child.title == "Dora") then -- 1154
										goto _continue_0 -- 1154
									end -- 1154
									local title = zh and "zh-Hans" or "en" -- 1155
									do -- 1156
										local _accum_0 = { } -- 1156
										local _len_0 = 1 -- 1156
										local _list_1 = child.children -- 1156
										for _index_1 = 1, #_list_1 do -- 1156
											local c = _list_1[_index_1] -- 1156
											if c.title ~= title then -- 1156
												_accum_0[_len_0] = c -- 1156
												_len_0 = _len_0 + 1 -- 1156
											end -- 1156
										end -- 1156
										child.children = _accum_0 -- 1156
									end -- 1156
									break -- 1157
									::_continue_0:: -- 1154
								end -- 1153
							else -- 1159
								local _accum_0 = { } -- 1159
								local _len_0 = 1 -- 1159
								local _list_0 = _with_0.children -- 1159
								for _index_0 = 1, #_list_0 do -- 1159
									local child = _list_0[_index_0] -- 1159
									if child.title ~= "Dora" then -- 1159
										_accum_0[_len_0] = child -- 1159
										_len_0 = _len_0 + 1 -- 1159
									end -- 1159
								end -- 1159
								_with_0.children = _accum_0 -- 1159
							end -- 1152
							return _with_0 -- 1150
						end)(), -- 1150
						(function() -- 1160
							if engineDev then -- 1160
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1161
								local _obj_0 = _with_0.children -- 1162
								_obj_0[#_obj_0 + 1] = { -- 1163
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1163
									dir = false, -- 1164
									builtin = true, -- 1165
									title = "init.yue" -- 1166
								} -- 1162
								return _with_0 -- 1161
							end -- 1160
						end)() -- 1160
					} -- 1141
				} -- 1136
			} -- 1170
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1170
			local _idx_0 = #_tab_0 + 1 -- 1170
			for _index_0 = 1, #_obj_0 do -- 1170
				local _value_0 = _obj_0[_index_0] -- 1170
				_tab_0[_idx_0] = _value_0 -- 1170
				_idx_0 = _idx_0 + 1 -- 1170
			end -- 1170
			return _tab_0 -- 1136
		end)() -- 1135
	} -- 1130
end) -- 1067
HttpServer:postSchedule("/run", function(req) -- 1174
	do -- 1175
		local _type_0 = type(req) -- 1175
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1175
		if _tab_0 then -- 1175
			local file -- 1175
			do -- 1175
				local _obj_0 = req.body -- 1175
				local _type_1 = type(_obj_0) -- 1175
				if "table" == _type_1 or "userdata" == _type_1 then -- 1175
					file = _obj_0.file -- 1175
				end -- 1175
			end -- 1175
			local asProj -- 1175
			do -- 1175
				local _obj_0 = req.body -- 1175
				local _type_1 = type(_obj_0) -- 1175
				if "table" == _type_1 or "userdata" == _type_1 then -- 1175
					asProj = _obj_0.asProj -- 1175
				end -- 1175
			end -- 1175
			if file ~= nil and asProj ~= nil then -- 1175
				if not Content:isAbsolutePath(file) then -- 1176
					local devFile = Path(Content.writablePath, file) -- 1177
					if Content:exist(devFile) then -- 1178
						file = devFile -- 1178
					end -- 1178
				end -- 1176
				local Entry = require("Script.Dev.Entry") -- 1179
				local workDir -- 1180
				if asProj then -- 1181
					workDir = getProjectDirFromFile(file) -- 1182
					if workDir then -- 1182
						Entry.allClear() -- 1183
						local target = Path(workDir, "init") -- 1184
						local success, err = Entry.enterEntryAsync({ -- 1185
							entryName = "Project", -- 1185
							fileName = target -- 1185
						}) -- 1185
						target = Path:getName(Path:getPath(target)) -- 1186
						return { -- 1187
							success = success, -- 1187
							target = target, -- 1187
							err = err -- 1187
						} -- 1187
					end -- 1182
				else -- 1189
					workDir = getProjectDirFromFile(file) -- 1189
				end -- 1181
				Entry.allClear() -- 1190
				file = Path:replaceExt(file, "") -- 1191
				local success, err = Entry.enterEntryAsync({ -- 1193
					entryName = Path:getName(file), -- 1193
					fileName = file, -- 1194
					workDir = workDir -- 1195
				}) -- 1192
				return { -- 1196
					success = success, -- 1196
					err = err -- 1196
				} -- 1196
			end -- 1175
		end -- 1175
	end -- 1175
	return { -- 1174
		success = false -- 1174
	} -- 1174
end) -- 1174
HttpServer:postSchedule("/stop", function() -- 1198
	local Entry = require("Script.Dev.Entry") -- 1199
	return { -- 1200
		success = Entry.stop() -- 1200
	} -- 1200
end) -- 1198
local minifyAsync -- 1202
minifyAsync = function(sourcePath, minifyPath) -- 1202
	if not Content:exist(sourcePath) then -- 1203
		return -- 1203
	end -- 1203
	local Entry = require("Script.Dev.Entry") -- 1204
	local errors = { } -- 1205
	local files = Entry.getAllFiles(sourcePath, { -- 1206
		"lua" -- 1206
	}, true) -- 1206
	do -- 1207
		local _accum_0 = { } -- 1207
		local _len_0 = 1 -- 1207
		for _index_0 = 1, #files do -- 1207
			local file = files[_index_0] -- 1207
			if file:sub(1, 1) ~= '.' then -- 1207
				_accum_0[_len_0] = file -- 1207
				_len_0 = _len_0 + 1 -- 1207
			end -- 1207
		end -- 1207
		files = _accum_0 -- 1207
	end -- 1207
	local paths -- 1208
	do -- 1208
		local _tbl_0 = { } -- 1208
		for _index_0 = 1, #files do -- 1208
			local file = files[_index_0] -- 1208
			_tbl_0[Path:getPath(file)] = true -- 1208
		end -- 1208
		paths = _tbl_0 -- 1208
	end -- 1208
	for path in pairs(paths) do -- 1209
		Content:mkdir(Path(minifyPath, path)) -- 1209
	end -- 1209
	local _ <close> = setmetatable({ }, { -- 1210
		__close = function() -- 1210
			package.loaded["luaminify.FormatMini"] = nil -- 1211
			package.loaded["luaminify.ParseLua"] = nil -- 1212
			package.loaded["luaminify.Scope"] = nil -- 1213
			package.loaded["luaminify.Util"] = nil -- 1214
		end -- 1210
	}) -- 1210
	local FormatMini -- 1215
	do -- 1215
		local _obj_0 = require("luaminify") -- 1215
		FormatMini = _obj_0.FormatMini -- 1215
	end -- 1215
	local fileCount = #files -- 1216
	local count = 0 -- 1217
	for _index_0 = 1, #files do -- 1218
		local file = files[_index_0] -- 1218
		thread(function() -- 1219
			local _ <close> = setmetatable({ }, { -- 1220
				__close = function() -- 1220
					count = count + 1 -- 1220
				end -- 1220
			}) -- 1220
			local input = Path(sourcePath, file) -- 1221
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1222
			if Content:exist(input) then -- 1223
				local sourceCodes = Content:loadAsync(input) -- 1224
				local res, err = FormatMini(sourceCodes) -- 1225
				if res then -- 1226
					Content:saveAsync(output, res) -- 1227
					return print("Minify " .. tostring(file)) -- 1228
				else -- 1230
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1230
				end -- 1226
			else -- 1232
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1232
			end -- 1223
		end) -- 1219
		sleep() -- 1233
	end -- 1218
	wait(function() -- 1234
		return count == fileCount -- 1234
	end) -- 1234
	if #errors > 0 then -- 1235
		print(table.concat(errors, '\n')) -- 1236
	end -- 1235
	print("Obfuscation done.") -- 1237
	return files -- 1238
end -- 1202
local zipping = false -- 1240
HttpServer:postSchedule("/zip", function(req) -- 1242
	do -- 1243
		local _type_0 = type(req) -- 1243
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1243
		if _tab_0 then -- 1243
			local path -- 1243
			do -- 1243
				local _obj_0 = req.body -- 1243
				local _type_1 = type(_obj_0) -- 1243
				if "table" == _type_1 or "userdata" == _type_1 then -- 1243
					path = _obj_0.path -- 1243
				end -- 1243
			end -- 1243
			local zipFile -- 1243
			do -- 1243
				local _obj_0 = req.body -- 1243
				local _type_1 = type(_obj_0) -- 1243
				if "table" == _type_1 or "userdata" == _type_1 then -- 1243
					zipFile = _obj_0.zipFile -- 1243
				end -- 1243
			end -- 1243
			local obfuscated -- 1243
			do -- 1243
				local _obj_0 = req.body -- 1243
				local _type_1 = type(_obj_0) -- 1243
				if "table" == _type_1 or "userdata" == _type_1 then -- 1243
					obfuscated = _obj_0.obfuscated -- 1243
				end -- 1243
			end -- 1243
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1243
				if zipping then -- 1244
					goto failed -- 1244
				end -- 1244
				zipping = true -- 1245
				local _ <close> = setmetatable({ }, { -- 1246
					__close = function() -- 1246
						zipping = false -- 1246
					end -- 1246
				}) -- 1246
				if not Content:exist(path) then -- 1247
					goto failed -- 1247
				end -- 1247
				Content:mkdir(Path:getPath(zipFile)) -- 1248
				if obfuscated then -- 1249
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1250
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1251
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1252
					Content:remove(scriptPath) -- 1253
					Content:remove(obfuscatedPath) -- 1254
					Content:remove(tempPath) -- 1255
					Content:mkdir(scriptPath) -- 1256
					Content:mkdir(obfuscatedPath) -- 1257
					Content:mkdir(tempPath) -- 1258
					if not Content:copyAsync(path, tempPath) then -- 1259
						goto failed -- 1259
					end -- 1259
					local Entry = require("Script.Dev.Entry") -- 1260
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1261
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1262
						"tl", -- 1262
						"yue", -- 1262
						"lua", -- 1262
						"ts", -- 1262
						"tsx", -- 1262
						"vs", -- 1262
						"bl", -- 1262
						"xml", -- 1262
						"wa", -- 1262
						"mod" -- 1262
					}, true) -- 1262
					for _index_0 = 1, #scriptFiles do -- 1263
						local file = scriptFiles[_index_0] -- 1263
						Content:remove(Path(tempPath, file)) -- 1264
					end -- 1263
					for _index_0 = 1, #luaFiles do -- 1265
						local file = luaFiles[_index_0] -- 1265
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1266
					end -- 1265
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1267
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1268
					end) then -- 1267
						goto failed -- 1267
					end -- 1267
					return { -- 1269
						success = true -- 1269
					} -- 1269
				else -- 1271
					return { -- 1271
						success = Content:zipAsync(path, zipFile, function(file) -- 1271
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1272
						end) -- 1271
					} -- 1271
				end -- 1249
			end -- 1243
		end -- 1243
	end -- 1243
	::failed:: -- 1273
	return { -- 1242
		success = false -- 1242
	} -- 1242
end) -- 1242
HttpServer:postSchedule("/unzip", function(req) -- 1275
	do -- 1276
		local _type_0 = type(req) -- 1276
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1276
		if _tab_0 then -- 1276
			local zipFile -- 1276
			do -- 1276
				local _obj_0 = req.body -- 1276
				local _type_1 = type(_obj_0) -- 1276
				if "table" == _type_1 or "userdata" == _type_1 then -- 1276
					zipFile = _obj_0.zipFile -- 1276
				end -- 1276
			end -- 1276
			local path -- 1276
			do -- 1276
				local _obj_0 = req.body -- 1276
				local _type_1 = type(_obj_0) -- 1276
				if "table" == _type_1 or "userdata" == _type_1 then -- 1276
					path = _obj_0.path -- 1276
				end -- 1276
			end -- 1276
			if zipFile ~= nil and path ~= nil then -- 1276
				return { -- 1277
					success = Content:unzipAsync(zipFile, path, function(file) -- 1277
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1278
					end) -- 1277
				} -- 1277
			end -- 1276
		end -- 1276
	end -- 1276
	return { -- 1275
		success = false -- 1275
	} -- 1275
end) -- 1275
HttpServer:post("/editing-info", function(req) -- 1280
	local Entry = require("Script.Dev.Entry") -- 1281
	local config = Entry.getConfig() -- 1282
	local _type_0 = type(req) -- 1283
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1283
	local _match_0 = false -- 1283
	if _tab_0 then -- 1283
		local editingInfo -- 1283
		do -- 1283
			local _obj_0 = req.body -- 1283
			local _type_1 = type(_obj_0) -- 1283
			if "table" == _type_1 or "userdata" == _type_1 then -- 1283
				editingInfo = _obj_0.editingInfo -- 1283
			end -- 1283
		end -- 1283
		if editingInfo ~= nil then -- 1283
			_match_0 = true -- 1283
			config.editingInfo = editingInfo -- 1284
			return { -- 1285
				success = true -- 1285
			} -- 1285
		end -- 1283
	end -- 1283
	if not _match_0 then -- 1283
		if not (config.editingInfo ~= nil) then -- 1287
			local folder -- 1288
			if App.locale:match('^zh') then -- 1288
				folder = 'zh-Hans' -- 1288
			else -- 1288
				folder = 'en' -- 1288
			end -- 1288
			config.editingInfo = json.encode({ -- 1290
				index = 0, -- 1290
				files = { -- 1292
					{ -- 1293
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1293
						title = "welcome.md" -- 1294
					} -- 1292
				} -- 1291
			}) -- 1289
		end -- 1287
		return { -- 1298
			success = true, -- 1298
			editingInfo = config.editingInfo -- 1298
		} -- 1298
	end -- 1283
end) -- 1280
HttpServer:post("/command", function(req) -- 1300
	do -- 1301
		local _type_0 = type(req) -- 1301
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1301
		if _tab_0 then -- 1301
			local code -- 1301
			do -- 1301
				local _obj_0 = req.body -- 1301
				local _type_1 = type(_obj_0) -- 1301
				if "table" == _type_1 or "userdata" == _type_1 then -- 1301
					code = _obj_0.code -- 1301
				end -- 1301
			end -- 1301
			local log -- 1301
			do -- 1301
				local _obj_0 = req.body -- 1301
				local _type_1 = type(_obj_0) -- 1301
				if "table" == _type_1 or "userdata" == _type_1 then -- 1301
					log = _obj_0.log -- 1301
				end -- 1301
			end -- 1301
			if code ~= nil and log ~= nil then -- 1301
				emit("AppCommand", code, log) -- 1302
				return { -- 1303
					success = true -- 1303
				} -- 1303
			end -- 1301
		end -- 1301
	end -- 1301
	return { -- 1300
		success = false -- 1300
	} -- 1300
end) -- 1300
HttpServer:post("/log/save", function() -- 1305
	local folder = ".download" -- 1306
	local fullLogFile = "dora_full_logs.txt" -- 1307
	local fullFolder = Path(Content.writablePath, folder) -- 1308
	Content:mkdir(fullFolder) -- 1309
	local logPath = Path(fullFolder, fullLogFile) -- 1310
	if App:saveLog(logPath) then -- 1311
		return { -- 1312
			success = true, -- 1312
			path = Path(folder, fullLogFile) -- 1312
		} -- 1312
	end -- 1311
	return { -- 1305
		success = false -- 1305
	} -- 1305
end) -- 1305
HttpServer:post("/yarn/check", function(req) -- 1314
	local yarncompile = require("yarncompile") -- 1315
	do -- 1316
		local _type_0 = type(req) -- 1316
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1316
		if _tab_0 then -- 1316
			local code -- 1316
			do -- 1316
				local _obj_0 = req.body -- 1316
				local _type_1 = type(_obj_0) -- 1316
				if "table" == _type_1 or "userdata" == _type_1 then -- 1316
					code = _obj_0.code -- 1316
				end -- 1316
			end -- 1316
			if code ~= nil then -- 1316
				local jsonObject = json.decode(code) -- 1317
				if jsonObject then -- 1317
					local errors = { } -- 1318
					local _list_0 = jsonObject.nodes -- 1319
					for _index_0 = 1, #_list_0 do -- 1319
						local node = _list_0[_index_0] -- 1319
						local title, body = node.title, node.body -- 1320
						local luaCode, err = yarncompile(body) -- 1321
						if not luaCode then -- 1321
							errors[#errors + 1] = title .. ":" .. err -- 1322
						end -- 1321
					end -- 1319
					return { -- 1323
						success = true, -- 1323
						syntaxError = table.concat(errors, "\n\n") -- 1323
					} -- 1323
				end -- 1317
			end -- 1316
		end -- 1316
	end -- 1316
	return { -- 1314
		success = false -- 1314
	} -- 1314
end) -- 1314
HttpServer:post("/yarn/check-file", function(req) -- 1325
	local yarncompile = require("yarncompile") -- 1326
	do -- 1327
		local _type_0 = type(req) -- 1327
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1327
		if _tab_0 then -- 1327
			local code -- 1327
			do -- 1327
				local _obj_0 = req.body -- 1327
				local _type_1 = type(_obj_0) -- 1327
				if "table" == _type_1 or "userdata" == _type_1 then -- 1327
					code = _obj_0.code -- 1327
				end -- 1327
			end -- 1327
			if code ~= nil then -- 1327
				local res, _, err = yarncompile(code, true) -- 1328
				if not res then -- 1328
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1329
					return { -- 1330
						success = false, -- 1330
						message = message, -- 1330
						line = line, -- 1330
						column = column, -- 1330
						node = node -- 1330
					} -- 1330
				end -- 1328
			end -- 1327
		end -- 1327
	end -- 1327
	return { -- 1325
		success = true -- 1325
	} -- 1325
end) -- 1325
local getWaProjectDirFromFile -- 1332
getWaProjectDirFromFile = function(file) -- 1332
	local writablePath = Content.writablePath -- 1333
	local parent, current -- 1334
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1334
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1335
	else -- 1337
		parent, current = nil, nil -- 1337
	end -- 1334
	if not current then -- 1338
		return nil -- 1338
	end -- 1338
	repeat -- 1339
		current = Path:getPath(current) -- 1340
		if current == "" then -- 1341
			break -- 1341
		end -- 1341
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1342
		for _index_0 = 1, #_list_0 do -- 1342
			local f = _list_0[_index_0] -- 1342
			if Path:getFilename(f):lower() == "wa.mod" then -- 1343
				return Path(parent, current, Path:getPath(f)) -- 1344
			end -- 1343
		end -- 1342
	until false -- 1339
	return nil -- 1346
end -- 1332
HttpServer:postSchedule("/wa/update_dora", function(req) -- 1348
	do -- 1349
		local _type_0 = type(req) -- 1349
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1349
		if _tab_0 then -- 1349
			local path -- 1349
			do -- 1349
				local _obj_0 = req.body -- 1349
				local _type_1 = type(_obj_0) -- 1349
				if "table" == _type_1 or "userdata" == _type_1 then -- 1349
					path = _obj_0.path -- 1349
				end -- 1349
			end -- 1349
			if path ~= nil then -- 1349
				local projDir = getWaProjectDirFromFile(path) -- 1350
				if projDir then -- 1350
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 1351
					if not Content:exist(sourceDoraPath) then -- 1352
						return { -- 1353
							success = false, -- 1353
							message = "missing dora template" -- 1353
						} -- 1353
					end -- 1352
					local targetVendorPath = Path(projDir, "vendor") -- 1354
					local targetDoraPath = Path(targetVendorPath, "dora") -- 1355
					if not Content:exist(targetVendorPath) then -- 1356
						if not Content:mkdir(targetVendorPath) then -- 1357
							return { -- 1358
								success = false, -- 1358
								message = "failed to create vendor folder" -- 1358
							} -- 1358
						end -- 1357
					elseif not Content:isdir(targetVendorPath) then -- 1359
						return { -- 1360
							success = false, -- 1360
							message = "vendor path is not a folder" -- 1360
						} -- 1360
					end -- 1356
					if Content:exist(targetDoraPath) then -- 1361
						if not Content:remove(targetDoraPath) then -- 1362
							return { -- 1363
								success = false, -- 1363
								message = "failed to remove old dora" -- 1363
							} -- 1363
						end -- 1362
					end -- 1361
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 1364
						return { -- 1365
							success = false, -- 1365
							message = "failed to copy dora" -- 1365
						} -- 1365
					end -- 1364
					return { -- 1366
						success = true -- 1366
					} -- 1366
				else -- 1368
					return { -- 1368
						success = false, -- 1368
						message = 'Wa file needs a project' -- 1368
					} -- 1368
				end -- 1350
			end -- 1349
		end -- 1349
	end -- 1349
	return { -- 1348
		success = false, -- 1348
		message = "invalid call" -- 1348
	} -- 1348
end) -- 1348
HttpServer:postSchedule("/wa/build", function(req) -- 1370
	do -- 1371
		local _type_0 = type(req) -- 1371
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1371
		if _tab_0 then -- 1371
			local path -- 1371
			do -- 1371
				local _obj_0 = req.body -- 1371
				local _type_1 = type(_obj_0) -- 1371
				if "table" == _type_1 or "userdata" == _type_1 then -- 1371
					path = _obj_0.path -- 1371
				end -- 1371
			end -- 1371
			if path ~= nil then -- 1371
				local projDir = getWaProjectDirFromFile(path) -- 1372
				if projDir then -- 1372
					local message = Wasm:buildWaAsync(projDir) -- 1373
					if message == "" then -- 1374
						return { -- 1375
							success = true -- 1375
						} -- 1375
					else -- 1377
						return { -- 1377
							success = false, -- 1377
							message = message -- 1377
						} -- 1377
					end -- 1374
				else -- 1379
					return { -- 1379
						success = false, -- 1379
						message = 'Wa file needs a project' -- 1379
					} -- 1379
				end -- 1372
			end -- 1371
		end -- 1371
	end -- 1371
	return { -- 1380
		success = false, -- 1380
		message = 'failed to build' -- 1380
	} -- 1380
end) -- 1370
HttpServer:postSchedule("/wa/format", function(req) -- 1382
	do -- 1383
		local _type_0 = type(req) -- 1383
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1383
		if _tab_0 then -- 1383
			local file -- 1383
			do -- 1383
				local _obj_0 = req.body -- 1383
				local _type_1 = type(_obj_0) -- 1383
				if "table" == _type_1 or "userdata" == _type_1 then -- 1383
					file = _obj_0.file -- 1383
				end -- 1383
			end -- 1383
			if file ~= nil then -- 1383
				local code = Wasm:formatWaAsync(file) -- 1384
				if code == "" then -- 1385
					return { -- 1386
						success = false -- 1386
					} -- 1386
				else -- 1388
					return { -- 1388
						success = true, -- 1388
						code = code -- 1388
					} -- 1388
				end -- 1385
			end -- 1383
		end -- 1383
	end -- 1383
	return { -- 1389
		success = false -- 1389
	} -- 1389
end) -- 1382
HttpServer:postSchedule("/wa/create", function(req) -- 1391
	do -- 1392
		local _type_0 = type(req) -- 1392
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1392
		if _tab_0 then -- 1392
			local path -- 1392
			do -- 1392
				local _obj_0 = req.body -- 1392
				local _type_1 = type(_obj_0) -- 1392
				if "table" == _type_1 or "userdata" == _type_1 then -- 1392
					path = _obj_0.path -- 1392
				end -- 1392
			end -- 1392
			if path ~= nil then -- 1392
				if not Content:exist(Path:getPath(path)) then -- 1393
					return { -- 1394
						success = false, -- 1394
						message = "target path not existed" -- 1394
					} -- 1394
				end -- 1393
				if Content:exist(path) then -- 1395
					return { -- 1396
						success = false, -- 1396
						message = "target project folder existed" -- 1396
					} -- 1396
				end -- 1395
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1397
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1398
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1399
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1400
					return { -- 1403
						success = false, -- 1403
						message = "missing template project" -- 1403
					} -- 1403
				end -- 1400
				if not Content:mkdir(path) then -- 1404
					return { -- 1405
						success = false, -- 1405
						message = "failed to create project folder" -- 1405
					} -- 1405
				end -- 1404
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1406
					Content:remove(path) -- 1407
					return { -- 1408
						success = false, -- 1408
						message = "failed to copy template" -- 1408
					} -- 1408
				end -- 1406
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1409
					Content:remove(path) -- 1410
					return { -- 1411
						success = false, -- 1411
						message = "failed to copy template" -- 1411
					} -- 1411
				end -- 1409
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1412
					Content:remove(path) -- 1413
					return { -- 1414
						success = false, -- 1414
						message = "failed to copy template" -- 1414
					} -- 1414
				end -- 1412
				return { -- 1415
					success = true -- 1415
				} -- 1415
			end -- 1392
		end -- 1392
	end -- 1392
	return { -- 1391
		success = false, -- 1391
		message = "invalid call" -- 1391
	} -- 1391
end) -- 1391
local _anon_func_5 = function(path) -- 1424
	local _val_0 = Path:getExt(path) -- 1424
	return "ts" == _val_0 or "tsx" == _val_0 -- 1424
end -- 1424
local _anon_func_6 = function(f) -- 1454
	local _val_0 = Path:getExt(f) -- 1454
	return "ts" == _val_0 or "tsx" == _val_0 -- 1454
end -- 1454
HttpServer:postSchedule("/ts/build", function(req) -- 1417
	do -- 1418
		local _type_0 = type(req) -- 1418
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1418
		if _tab_0 then -- 1418
			local path -- 1418
			do -- 1418
				local _obj_0 = req.body -- 1418
				local _type_1 = type(_obj_0) -- 1418
				if "table" == _type_1 or "userdata" == _type_1 then -- 1418
					path = _obj_0.path -- 1418
				end -- 1418
			end -- 1418
			if path ~= nil then -- 1418
				if HttpServer.wsConnectionCount == 0 then -- 1419
					return { -- 1420
						success = false, -- 1420
						message = "Web IDE not connected" -- 1420
					} -- 1420
				end -- 1419
				if not Content:exist(path) then -- 1421
					return { -- 1422
						success = false, -- 1422
						message = "path not existed" -- 1422
					} -- 1422
				end -- 1421
				if not Content:isdir(path) then -- 1423
					if not (_anon_func_5(path)) then -- 1424
						return { -- 1425
							success = false, -- 1425
							message = "expecting a TypeScript file" -- 1425
						} -- 1425
					end -- 1424
					local messages = { } -- 1426
					local content = Content:load(path) -- 1427
					if not content then -- 1428
						return { -- 1429
							success = false, -- 1429
							message = "failed to read file" -- 1429
						} -- 1429
					end -- 1428
					emit("AppWS", "Send", json.encode({ -- 1430
						name = "UpdateFile", -- 1430
						file = path, -- 1430
						exists = true, -- 1430
						content = content -- 1430
					})) -- 1430
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1431
						local done = false -- 1432
						do -- 1433
							local _with_0 = Node() -- 1433
							_with_0:gslot("AppWS", function(event) -- 1434
								if event.type == "Receive" then -- 1435
									_with_0:removeFromParent() -- 1436
									local res = json.decode(event.msg) -- 1437
									if res then -- 1437
										if res.name == "TranspileTS" then -- 1438
											if res.success then -- 1439
												local luaFile = Path:replaceExt(path, "lua") -- 1440
												Content:save(luaFile, res.luaCode) -- 1441
												messages[#messages + 1] = { -- 1442
													success = true, -- 1442
													file = path -- 1442
												} -- 1442
											else -- 1444
												messages[#messages + 1] = { -- 1444
													success = false, -- 1444
													file = path, -- 1444
													message = res.message -- 1444
												} -- 1444
											end -- 1439
											done = true -- 1445
										end -- 1438
									end -- 1437
								end -- 1435
							end) -- 1434
						end -- 1433
						emit("AppWS", "Send", json.encode({ -- 1446
							name = "TranspileTS", -- 1446
							file = path, -- 1446
							content = content -- 1446
						})) -- 1446
						wait(function() -- 1447
							return done -- 1447
						end) -- 1447
					end -- 1431
					return { -- 1448
						success = true, -- 1448
						messages = messages -- 1448
					} -- 1448
				else -- 1450
					local files = Content:getAllFiles(path) -- 1450
					local fileData = { } -- 1451
					local messages = { } -- 1452
					for _index_0 = 1, #files do -- 1453
						local f = files[_index_0] -- 1453
						if not (_anon_func_6(f)) then -- 1454
							goto _continue_0 -- 1454
						end -- 1454
						local file = Path(path, f) -- 1455
						local content = Content:load(file) -- 1456
						if content then -- 1456
							fileData[file] = content -- 1457
							emit("AppWS", "Send", json.encode({ -- 1458
								name = "UpdateFile", -- 1458
								file = file, -- 1458
								exists = true, -- 1458
								content = content -- 1458
							})) -- 1458
						else -- 1460
							messages[#messages + 1] = { -- 1460
								success = false, -- 1460
								file = file, -- 1460
								message = "failed to read file" -- 1460
							} -- 1460
						end -- 1456
						::_continue_0:: -- 1454
					end -- 1453
					for file, content in pairs(fileData) do -- 1461
						if "d" == Path:getExt(Path:getName(file)) then -- 1462
							goto _continue_1 -- 1462
						end -- 1462
						local done = false -- 1463
						do -- 1464
							local _with_0 = Node() -- 1464
							_with_0:gslot("AppWS", function(event) -- 1465
								if event.type == "Receive" then -- 1466
									_with_0:removeFromParent() -- 1467
									local res = json.decode(event.msg) -- 1468
									if res then -- 1468
										if res.name == "TranspileTS" then -- 1469
											if res.success then -- 1470
												local luaFile = Path:replaceExt(file, "lua") -- 1471
												Content:save(luaFile, res.luaCode) -- 1472
												messages[#messages + 1] = { -- 1473
													success = true, -- 1473
													file = file -- 1473
												} -- 1473
											else -- 1475
												messages[#messages + 1] = { -- 1475
													success = false, -- 1475
													file = file, -- 1475
													message = res.message -- 1475
												} -- 1475
											end -- 1470
											done = true -- 1476
										end -- 1469
									end -- 1468
								end -- 1466
							end) -- 1465
						end -- 1464
						emit("AppWS", "Send", json.encode({ -- 1477
							name = "TranspileTS", -- 1477
							file = file, -- 1477
							content = content -- 1477
						})) -- 1477
						wait(function() -- 1478
							return done -- 1478
						end) -- 1478
						::_continue_1:: -- 1462
					end -- 1461
					return { -- 1479
						success = true, -- 1479
						messages = messages -- 1479
					} -- 1479
				end -- 1423
			end -- 1418
		end -- 1418
	end -- 1418
	return { -- 1417
		success = false -- 1417
	} -- 1417
end) -- 1417
HttpServer:post("/download", function(req) -- 1481
	do -- 1482
		local _type_0 = type(req) -- 1482
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1482
		if _tab_0 then -- 1482
			local url -- 1482
			do -- 1482
				local _obj_0 = req.body -- 1482
				local _type_1 = type(_obj_0) -- 1482
				if "table" == _type_1 or "userdata" == _type_1 then -- 1482
					url = _obj_0.url -- 1482
				end -- 1482
			end -- 1482
			local target -- 1482
			do -- 1482
				local _obj_0 = req.body -- 1482
				local _type_1 = type(_obj_0) -- 1482
				if "table" == _type_1 or "userdata" == _type_1 then -- 1482
					target = _obj_0.target -- 1482
				end -- 1482
			end -- 1482
			if url ~= nil and target ~= nil then -- 1482
				local Entry = require("Script.Dev.Entry") -- 1483
				Entry.downloadFile(url, target) -- 1484
				return { -- 1485
					success = true -- 1485
				} -- 1485
			end -- 1482
		end -- 1482
	end -- 1482
	return { -- 1481
		success = false -- 1481
	} -- 1481
end) -- 1481
local status = { } -- 1487
_module_0 = status -- 1488
status.buildAsync = function(path) -- 1490
	if not Content:exist(path) then -- 1491
		return { -- 1492
			success = false, -- 1492
			file = path, -- 1492
			message = "file not existed" -- 1492
		} -- 1492
	end -- 1491
	do -- 1493
		local _exp_0 = Path:getExt(path) -- 1493
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1493
			if '' == Path:getExt(Path:getName(path)) then -- 1494
				local content = Content:loadAsync(path) -- 1495
				if content then -- 1495
					local resultCodes, err = compileFileAsync(path, content) -- 1496
					if resultCodes then -- 1496
						return { -- 1497
							success = true, -- 1497
							file = path -- 1497
						} -- 1497
					else -- 1499
						return { -- 1499
							success = false, -- 1499
							file = path, -- 1499
							message = err -- 1499
						} -- 1499
					end -- 1496
				end -- 1495
			end -- 1494
		elseif "lua" == _exp_0 then -- 1500
			local content = Content:loadAsync(path) -- 1501
			if content then -- 1501
				do -- 1502
					local isTIC80 = CheckTIC80Code(content) -- 1502
					if isTIC80 then -- 1502
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1503
					end -- 1502
				end -- 1502
				local success, info -- 1504
				do -- 1504
					local _obj_0 = luaCheck(path, content) -- 1504
					success, info = _obj_0.success, _obj_0.info -- 1504
				end -- 1504
				if success then -- 1505
					return { -- 1506
						success = true, -- 1506
						file = path -- 1506
					} -- 1506
				elseif info and #info > 0 then -- 1507
					local messages = { } -- 1508
					for _index_0 = 1, #info do -- 1509
						local _des_0 = info[_index_0] -- 1509
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 1509
						local lineText = "" -- 1510
						if line then -- 1511
							local currentLine = 1 -- 1512
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1513
								if currentLine == line then -- 1514
									lineText = text -- 1515
									break -- 1516
								end -- 1514
								currentLine = currentLine + 1 -- 1517
							end -- 1513
						end -- 1511
						if line then -- 1518
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1519
						else -- 1521
							messages[#messages + 1] = message -- 1521
						end -- 1518
					end -- 1509
					return { -- 1522
						success = false, -- 1522
						file = path, -- 1522
						message = table.concat(messages, "\n") -- 1522
					} -- 1522
				else -- 1524
					return { -- 1524
						success = false, -- 1524
						file = path, -- 1524
						message = "lua check failed" -- 1524
					} -- 1524
				end -- 1505
			end -- 1501
		elseif "yarn" == _exp_0 then -- 1525
			local content = Content:loadAsync(path) -- 1526
			if content then -- 1526
				local res, _, err = yarncompile(content, true) -- 1527
				if res then -- 1527
					return { -- 1528
						success = true, -- 1528
						file = path -- 1528
					} -- 1528
				else -- 1530
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1530
					local lineText = "" -- 1531
					if line then -- 1532
						local currentLine = 1 -- 1533
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1534
							if currentLine == line then -- 1535
								lineText = text -- 1536
								break -- 1537
							end -- 1535
							currentLine = currentLine + 1 -- 1538
						end -- 1534
					end -- 1532
					if node ~= "" then -- 1539
						node = "node: " .. tostring(node) .. ", " -- 1540
					else -- 1541
						node = "" -- 1541
					end -- 1539
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1542
					return { -- 1543
						success = false, -- 1543
						file = path, -- 1543
						message = message -- 1543
					} -- 1543
				end -- 1527
			end -- 1526
		end -- 1493
	end -- 1493
	return { -- 1544
		success = false, -- 1544
		file = path, -- 1544
		message = "invalid file to build" -- 1544
	} -- 1544
end -- 1490
thread(function() -- 1546
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1547
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1548
	if Content:exist(doraWeb) then -- 1549
		local needReload -- 1550
		if Content:exist(doraReady) then -- 1550
			needReload = App.version ~= Content:load(doraReady) -- 1551
		else -- 1552
			needReload = true -- 1552
		end -- 1550
		if needReload then -- 1553
			Content:remove(Path(Content.appPath, ".www")) -- 1554
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1555
			Content:save(doraReady, App.version) -- 1559
			print("Dora Dora is ready!") -- 1560
		end -- 1553
	end -- 1549
	if HttpServer:start(8866) then -- 1561
		local localIP = HttpServer.localIP -- 1562
		if localIP == "" then -- 1563
			localIP = "localhost" -- 1563
		end -- 1563
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1564
		return HttpServer:startWS(8868) -- 1565
	else -- 1567
		status.url = nil -- 1567
		return print("8866 Port not available!") -- 1568
	end -- 1561
end) -- 1546
return _module_0 -- 1
