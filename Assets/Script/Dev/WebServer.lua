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
					local parent = Path:getPath(path) -- 871
					local files = Content:getFiles(parent) -- 872
					local name = Path:getName(path):lower() -- 873
					local ext = Path:getExt(path) -- 874
					for _index_0 = 1, #files do -- 875
						local file = files[_index_0] -- 875
						if name == Path:getName(file):lower() then -- 876
							local _exp_0 = Path:getExt(file) -- 877
							if "tl" == _exp_0 then -- 877
								if ("vs" == ext) then -- 877
									Content:remove(Path(parent, file)) -- 878
								end -- 877
							elseif "lua" == _exp_0 then -- 879
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 879
									Content:remove(Path(parent, file)) -- 880
								end -- 879
							end -- 877
						end -- 876
					end -- 875
					if Content:remove(path) then -- 881
						return { -- 882
							success = true -- 882
						} -- 882
					end -- 881
				end -- 870
			end -- 869
		end -- 869
	end -- 869
	return { -- 868
		success = false -- 868
	} -- 868
end) -- 868
HttpServer:post("/rename", function(req) -- 884
	do -- 885
		local _type_0 = type(req) -- 885
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 885
		if _tab_0 then -- 885
			local old -- 885
			do -- 885
				local _obj_0 = req.body -- 885
				local _type_1 = type(_obj_0) -- 885
				if "table" == _type_1 or "userdata" == _type_1 then -- 885
					old = _obj_0.old -- 885
				end -- 885
			end -- 885
			local new -- 885
			do -- 885
				local _obj_0 = req.body -- 885
				local _type_1 = type(_obj_0) -- 885
				if "table" == _type_1 or "userdata" == _type_1 then -- 885
					new = _obj_0.new -- 885
				end -- 885
			end -- 885
			if old ~= nil and new ~= nil then -- 885
				if Content:exist(old) and not Content:exist(new) then -- 886
					local parent = Path:getPath(new) -- 887
					local files = Content:getFiles(parent) -- 888
					if Content:isdir(old) then -- 889
						local name = Path:getFilename(new):lower() -- 890
						for _index_0 = 1, #files do -- 891
							local file = files[_index_0] -- 891
							if name == Path:getFilename(file):lower() then -- 892
								return { -- 893
									success = false -- 893
								} -- 893
							end -- 892
						end -- 891
					else -- 895
						local name = Path:getName(new):lower() -- 895
						local ext = Path:getExt(new) -- 896
						for _index_0 = 1, #files do -- 897
							local file = files[_index_0] -- 897
							if name == Path:getName(file):lower() then -- 898
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 899
									goto _continue_0 -- 900
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 901
									goto _continue_0 -- 902
								end -- 899
								return { -- 903
									success = false -- 903
								} -- 903
							end -- 898
							::_continue_0:: -- 898
						end -- 897
					end -- 889
					if Content:move(old, new) then -- 904
						local newParent = Path:getPath(new) -- 905
						parent = Path:getPath(old) -- 906
						files = Content:getFiles(parent) -- 907
						local newName = Path:getName(new) -- 908
						local oldName = Path:getName(old) -- 909
						local name = oldName:lower() -- 910
						local ext = Path:getExt(old) -- 911
						for _index_0 = 1, #files do -- 912
							local file = files[_index_0] -- 912
							if name == Path:getName(file):lower() then -- 913
								local _exp_0 = Path:getExt(file) -- 914
								if "tl" == _exp_0 then -- 914
									if ("vs" == ext) then -- 914
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 915
									end -- 914
								elseif "lua" == _exp_0 then -- 916
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 916
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 917
									end -- 916
								end -- 914
							end -- 913
						end -- 912
						return { -- 918
							success = true -- 918
						} -- 918
					end -- 904
				end -- 886
			end -- 885
		end -- 885
	end -- 885
	return { -- 884
		success = false -- 884
	} -- 884
end) -- 884
HttpServer:post("/exist", function(req) -- 920
	do -- 921
		local _type_0 = type(req) -- 921
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 921
		if _tab_0 then -- 921
			local file -- 921
			do -- 921
				local _obj_0 = req.body -- 921
				local _type_1 = type(_obj_0) -- 921
				if "table" == _type_1 or "userdata" == _type_1 then -- 921
					file = _obj_0.file -- 921
				end -- 921
			end -- 921
			if file ~= nil then -- 921
				do -- 922
					local projFile = req.body.projFile -- 922
					if projFile then -- 922
						local projDir = getProjectDirFromFile(projFile) -- 923
						if projDir then -- 923
							local scriptDir = Path(projDir, "Script") -- 924
							local searchPaths = Content.searchPaths -- 925
							if Content:exist(scriptDir) then -- 926
								Content:addSearchPath(scriptDir) -- 926
							end -- 926
							if Content:exist(projDir) then -- 927
								Content:addSearchPath(projDir) -- 927
							end -- 927
							local _ <close> = setmetatable({ }, { -- 928
								__close = function() -- 928
									Content.searchPaths = searchPaths -- 928
								end -- 928
							}) -- 928
							return { -- 929
								success = Content:exist(file) -- 929
							} -- 929
						end -- 923
					end -- 922
				end -- 922
				return { -- 930
					success = Content:exist(file) -- 930
				} -- 930
			end -- 921
		end -- 921
	end -- 921
	return { -- 920
		success = false -- 920
	} -- 920
end) -- 920
HttpServer:postSchedule("/read", function(req) -- 932
	do -- 933
		local _type_0 = type(req) -- 933
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 933
		if _tab_0 then -- 933
			local path -- 933
			do -- 933
				local _obj_0 = req.body -- 933
				local _type_1 = type(_obj_0) -- 933
				if "table" == _type_1 or "userdata" == _type_1 then -- 933
					path = _obj_0.path -- 933
				end -- 933
			end -- 933
			if path ~= nil then -- 933
				local readFile -- 934
				readFile = function() -- 934
					if Content:exist(path) then -- 935
						local content = Content:loadAsync(path) -- 936
						if content then -- 936
							return { -- 937
								content = content, -- 937
								success = true -- 937
							} -- 937
						end -- 936
					end -- 935
					return nil -- 934
				end -- 934
				do -- 938
					local projFile = req.body.projFile -- 938
					if projFile then -- 938
						local projDir = getProjectDirFromFile(projFile) -- 939
						if projDir then -- 939
							local scriptDir = Path(projDir, "Script") -- 940
							local searchPaths = Content.searchPaths -- 941
							if Content:exist(scriptDir) then -- 942
								Content:addSearchPath(scriptDir) -- 942
							end -- 942
							if Content:exist(projDir) then -- 943
								Content:addSearchPath(projDir) -- 943
							end -- 943
							local _ <close> = setmetatable({ }, { -- 944
								__close = function() -- 944
									Content.searchPaths = searchPaths -- 944
								end -- 944
							}) -- 944
							local result = readFile() -- 945
							if result then -- 945
								return result -- 945
							end -- 945
						end -- 939
					end -- 938
				end -- 938
				local result = readFile() -- 946
				if result then -- 946
					return result -- 946
				end -- 946
			end -- 933
		end -- 933
	end -- 933
	return { -- 932
		success = false -- 932
	} -- 932
end) -- 932
HttpServer:get("/read-sync", function(req) -- 948
	do -- 949
		local _type_0 = type(req) -- 949
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 949
		if _tab_0 then -- 949
			local params = req.params -- 949
			if params ~= nil then -- 949
				local path = params.path -- 950
				local exts -- 951
				if params.exts then -- 951
					local _accum_0 = { } -- 952
					local _len_0 = 1 -- 952
					for ext in params.exts:gmatch("[^|]*") do -- 952
						_accum_0[_len_0] = ext -- 953
						_len_0 = _len_0 + 1 -- 953
					end -- 952
					exts = _accum_0 -- 951
				else -- 954
					exts = { -- 954
						"" -- 954
					} -- 954
				end -- 951
				local readFile -- 955
				readFile = function() -- 955
					for _index_0 = 1, #exts do -- 956
						local ext = exts[_index_0] -- 956
						local targetPath = path .. ext -- 957
						if Content:exist(targetPath) then -- 958
							local content = Content:load(targetPath) -- 959
							if content then -- 959
								return { -- 960
									content = content, -- 960
									success = true, -- 960
									fullPath = Content:getFullPath(targetPath) -- 960
								} -- 960
							end -- 959
						end -- 958
					end -- 956
					return nil -- 955
				end -- 955
				local searchPaths = Content.searchPaths -- 961
				local _ <close> = setmetatable({ }, { -- 962
					__close = function() -- 962
						Content.searchPaths = searchPaths -- 962
					end -- 962
				}) -- 962
				do -- 963
					local projFile = req.params.projFile -- 963
					if projFile then -- 963
						local projDir = getProjectDirFromFile(projFile) -- 964
						if projDir then -- 964
							local scriptDir = Path(projDir, "Script") -- 965
							if Content:exist(scriptDir) then -- 966
								Content:addSearchPath(scriptDir) -- 966
							end -- 966
							if Content:exist(projDir) then -- 967
								Content:addSearchPath(projDir) -- 967
							end -- 967
						else -- 969
							projDir = Path:getPath(projFile) -- 969
							if Content:exist(projDir) then -- 970
								Content:addSearchPath(projDir) -- 970
							end -- 970
						end -- 964
					end -- 963
				end -- 963
				local result = readFile() -- 971
				if result then -- 971
					return result -- 971
				end -- 971
			end -- 949
		end -- 949
	end -- 949
	return { -- 948
		success = false -- 948
	} -- 948
end) -- 948
local compileFileAsync -- 973
compileFileAsync = function(inputFile, sourceCodes) -- 973
	local file = inputFile -- 974
	local searchPath -- 975
	do -- 975
		local dir = getProjectDirFromFile(inputFile) -- 975
		if dir then -- 975
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 976
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 977
		else -- 979
			file = Path:getRelative(inputFile, Content.writablePath) -- 979
			if file:sub(1, 2) == ".." then -- 980
				file = Path:getRelative(inputFile, Content.assetPath) -- 981
			end -- 980
			searchPath = "" -- 982
		end -- 975
	end -- 975
	local outputFile = Path:replaceExt(inputFile, "lua") -- 983
	local yueext = yue.options.extension -- 984
	local resultCodes = nil -- 985
	local resultError = nil -- 986
	do -- 987
		local _exp_0 = Path:getExt(inputFile) -- 987
		if yueext == _exp_0 then -- 987
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 988
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 989
				if not codes then -- 990
					resultError = err -- 991
					return -- 992
				end -- 990
				local extraGlobal -- 993
				if isTIC80 then -- 993
					extraGlobal = tic80APIs -- 993
				else -- 993
					extraGlobal = nil -- 993
				end -- 993
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 994
				if not success then -- 995
					resultError = message -- 996
					return -- 997
				end -- 995
				if codes == "" then -- 998
					resultCodes = "" -- 999
					return nil -- 1000
				end -- 998
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1001
				return resultCodes -- 1002
			end, function(success) -- 989
				if not success then -- 1003
					Content:remove(outputFile) -- 1004
					if resultCodes == nil then -- 1005
						resultCodes = false -- 1006
					end -- 1005
				end -- 1003
			end) -- 989
		elseif "tl" == _exp_0 then -- 1007
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1008
			if isTIC80 then -- 1009
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1010
			end -- 1009
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1011
			if codes then -- 1011
				if isTIC80 then -- 1012
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1013
				end -- 1012
				resultCodes = codes -- 1014
				Content:saveAsync(outputFile, codes) -- 1015
			else -- 1017
				Content:remove(outputFile) -- 1017
				resultCodes = false -- 1018
				resultError = err -- 1019
			end -- 1011
		elseif "xml" == _exp_0 then -- 1020
			local codes, err = xml.tolua(sourceCodes) -- 1021
			if codes then -- 1021
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1022
				Content:saveAsync(outputFile, resultCodes) -- 1023
			else -- 1025
				Content:remove(outputFile) -- 1025
				resultCodes = false -- 1026
				resultError = err -- 1027
			end -- 1021
		end -- 987
	end -- 987
	wait(function() -- 1028
		return resultCodes ~= nil -- 1028
	end) -- 1028
	if resultCodes then -- 1029
		return resultCodes -- 1030
	else -- 1032
		return nil, resultError -- 1032
	end -- 1029
	return nil -- 973
end -- 973
HttpServer:postSchedule("/write", function(req) -- 1034
	do -- 1035
		local _type_0 = type(req) -- 1035
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1035
		if _tab_0 then -- 1035
			local path -- 1035
			do -- 1035
				local _obj_0 = req.body -- 1035
				local _type_1 = type(_obj_0) -- 1035
				if "table" == _type_1 or "userdata" == _type_1 then -- 1035
					path = _obj_0.path -- 1035
				end -- 1035
			end -- 1035
			local content -- 1035
			do -- 1035
				local _obj_0 = req.body -- 1035
				local _type_1 = type(_obj_0) -- 1035
				if "table" == _type_1 or "userdata" == _type_1 then -- 1035
					content = _obj_0.content -- 1035
				end -- 1035
			end -- 1035
			if path ~= nil and content ~= nil then -- 1035
				if Content:saveAsync(path, content) then -- 1036
					do -- 1037
						local _exp_0 = Path:getExt(path) -- 1037
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1037
							if '' == Path:getExt(Path:getName(path)) then -- 1038
								local resultCodes = compileFileAsync(path, content) -- 1039
								return { -- 1040
									success = true, -- 1040
									resultCodes = resultCodes -- 1040
								} -- 1040
							end -- 1038
						end -- 1037
					end -- 1037
					return { -- 1041
						success = true -- 1041
					} -- 1041
				end -- 1036
			end -- 1035
		end -- 1035
	end -- 1035
	return { -- 1034
		success = false -- 1034
	} -- 1034
end) -- 1034
HttpServer:postSchedule("/build", function(req) -- 1043
	do -- 1044
		local _type_0 = type(req) -- 1044
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1044
		if _tab_0 then -- 1044
			local path -- 1044
			do -- 1044
				local _obj_0 = req.body -- 1044
				local _type_1 = type(_obj_0) -- 1044
				if "table" == _type_1 or "userdata" == _type_1 then -- 1044
					path = _obj_0.path -- 1044
				end -- 1044
			end -- 1044
			if path ~= nil then -- 1044
				local _exp_0 = Path:getExt(path) -- 1045
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1045
					if '' == Path:getExt(Path:getName(path)) then -- 1046
						local content = Content:loadAsync(path) -- 1047
						if content then -- 1047
							local resultCodes = compileFileAsync(path, content) -- 1048
							if resultCodes then -- 1048
								return { -- 1049
									success = true, -- 1049
									resultCodes = resultCodes -- 1049
								} -- 1049
							end -- 1048
						end -- 1047
					end -- 1046
				end -- 1045
			end -- 1044
		end -- 1044
	end -- 1044
	return { -- 1043
		success = false -- 1043
	} -- 1043
end) -- 1043
local extentionLevels = { -- 1052
	vs = 2, -- 1052
	bl = 2, -- 1053
	ts = 1, -- 1054
	tsx = 1, -- 1055
	tl = 1, -- 1056
	yue = 1, -- 1057
	xml = 1, -- 1058
	lua = 0 -- 1059
} -- 1051
HttpServer:post("/assets", function() -- 1061
	local Entry = require("Script.Dev.Entry") -- 1064
	local engineDev = Entry.getEngineDev() -- 1065
	local visitAssets -- 1066
	visitAssets = function(path, tag) -- 1066
		local isWorkspace = tag == "Workspace" -- 1067
		local builtin -- 1068
		if tag == "Builtin" then -- 1068
			builtin = true -- 1068
		else -- 1068
			builtin = nil -- 1068
		end -- 1068
		local children = nil -- 1069
		local dirs = Content:getDirs(path) -- 1070
		for _index_0 = 1, #dirs do -- 1071
			local dir = dirs[_index_0] -- 1071
			if isWorkspace then -- 1072
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1073
					goto _continue_0 -- 1074
				end -- 1073
			elseif dir == ".git" then -- 1075
				goto _continue_0 -- 1076
			end -- 1072
			if not children then -- 1077
				children = { } -- 1077
			end -- 1077
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1078
			::_continue_0:: -- 1072
		end -- 1071
		local files = Content:getFiles(path) -- 1079
		local names = { } -- 1080
		for _index_0 = 1, #files do -- 1081
			local file = files[_index_0] -- 1081
			if file:match("^%.") then -- 1082
				goto _continue_1 -- 1082
			end -- 1082
			local name = Path:getName(file) -- 1083
			local ext = names[name] -- 1084
			if ext then -- 1084
				local lv1 -- 1085
				do -- 1085
					local _exp_0 = extentionLevels[ext] -- 1085
					if _exp_0 ~= nil then -- 1085
						lv1 = _exp_0 -- 1085
					else -- 1085
						lv1 = -1 -- 1085
					end -- 1085
				end -- 1085
				ext = Path:getExt(file) -- 1086
				local lv2 -- 1087
				do -- 1087
					local _exp_0 = extentionLevels[ext] -- 1087
					if _exp_0 ~= nil then -- 1087
						lv2 = _exp_0 -- 1087
					else -- 1087
						lv2 = -1 -- 1087
					end -- 1087
				end -- 1087
				if lv2 > lv1 then -- 1088
					names[name] = ext -- 1089
				elseif lv2 == lv1 then -- 1090
					names[name .. '.' .. ext] = "" -- 1091
				end -- 1088
			else -- 1093
				ext = Path:getExt(file) -- 1093
				if not extentionLevels[ext] then -- 1094
					names[file] = "" -- 1095
				else -- 1097
					names[name] = ext -- 1097
				end -- 1094
			end -- 1084
			::_continue_1:: -- 1082
		end -- 1081
		do -- 1098
			local _accum_0 = { } -- 1098
			local _len_0 = 1 -- 1098
			for name, ext in pairs(names) do -- 1098
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1098
				_len_0 = _len_0 + 1 -- 1098
			end -- 1098
			files = _accum_0 -- 1098
		end -- 1098
		for _index_0 = 1, #files do -- 1099
			local file = files[_index_0] -- 1099
			if not children then -- 1100
				children = { } -- 1100
			end -- 1100
			children[#children + 1] = { -- 1102
				key = Path(path, file), -- 1102
				dir = false, -- 1103
				title = file, -- 1104
				builtin = builtin -- 1105
			} -- 1101
		end -- 1099
		if children then -- 1107
			table.sort(children, function(a, b) -- 1108
				if a.dir == b.dir then -- 1109
					return a.title < b.title -- 1110
				else -- 1112
					return a.dir -- 1112
				end -- 1109
			end) -- 1108
		end -- 1107
		if isWorkspace and children then -- 1113
			return children -- 1114
		else -- 1116
			return { -- 1117
				key = path, -- 1117
				dir = true, -- 1118
				title = Path:getFilename(path), -- 1119
				builtin = builtin, -- 1120
				children = children -- 1121
			} -- 1116
		end -- 1113
	end -- 1066
	local zh = (App.locale:match("^zh") ~= nil) -- 1123
	return { -- 1125
		key = Content.writablePath, -- 1125
		dir = true, -- 1126
		root = true, -- 1127
		title = "Assets", -- 1128
		children = (function() -- 1130
			local _tab_0 = { -- 1130
				{ -- 1131
					key = Path(Content.assetPath), -- 1131
					dir = true, -- 1132
					builtin = true, -- 1133
					title = zh and "内置资源" or "Built-in", -- 1134
					children = { -- 1136
						(function() -- 1136
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1136
							_with_0.title = zh and "说明文档" or "Readme" -- 1137
							return _with_0 -- 1136
						end)(), -- 1136
						(function() -- 1138
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1138
							_with_0.title = zh and "接口文档" or "API Doc" -- 1139
							return _with_0 -- 1138
						end)(), -- 1138
						(function() -- 1140
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1140
							_with_0.title = zh and "开发工具" or "Tools" -- 1141
							return _with_0 -- 1140
						end)(), -- 1140
						(function() -- 1142
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1142
							_with_0.title = zh and "字体" or "Font" -- 1143
							return _with_0 -- 1142
						end)(), -- 1142
						(function() -- 1144
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1144
							_with_0.title = zh and "程序库" or "Lib" -- 1145
							if engineDev then -- 1146
								local _list_0 = _with_0.children -- 1147
								for _index_0 = 1, #_list_0 do -- 1147
									local child = _list_0[_index_0] -- 1147
									if not (child.title == "Dora") then -- 1148
										goto _continue_0 -- 1148
									end -- 1148
									local title = zh and "zh-Hans" or "en" -- 1149
									do -- 1150
										local _accum_0 = { } -- 1150
										local _len_0 = 1 -- 1150
										local _list_1 = child.children -- 1150
										for _index_1 = 1, #_list_1 do -- 1150
											local c = _list_1[_index_1] -- 1150
											if c.title ~= title then -- 1150
												_accum_0[_len_0] = c -- 1150
												_len_0 = _len_0 + 1 -- 1150
											end -- 1150
										end -- 1150
										child.children = _accum_0 -- 1150
									end -- 1150
									break -- 1151
									::_continue_0:: -- 1148
								end -- 1147
							else -- 1153
								local _accum_0 = { } -- 1153
								local _len_0 = 1 -- 1153
								local _list_0 = _with_0.children -- 1153
								for _index_0 = 1, #_list_0 do -- 1153
									local child = _list_0[_index_0] -- 1153
									if child.title ~= "Dora" then -- 1153
										_accum_0[_len_0] = child -- 1153
										_len_0 = _len_0 + 1 -- 1153
									end -- 1153
								end -- 1153
								_with_0.children = _accum_0 -- 1153
							end -- 1146
							return _with_0 -- 1144
						end)(), -- 1144
						(function() -- 1154
							if engineDev then -- 1154
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1155
								local _obj_0 = _with_0.children -- 1156
								_obj_0[#_obj_0 + 1] = { -- 1157
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1157
									dir = false, -- 1158
									builtin = true, -- 1159
									title = "init.yue" -- 1160
								} -- 1156
								return _with_0 -- 1155
							end -- 1154
						end)() -- 1154
					} -- 1135
				} -- 1130
			} -- 1164
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1164
			local _idx_0 = #_tab_0 + 1 -- 1164
			for _index_0 = 1, #_obj_0 do -- 1164
				local _value_0 = _obj_0[_index_0] -- 1164
				_tab_0[_idx_0] = _value_0 -- 1164
				_idx_0 = _idx_0 + 1 -- 1164
			end -- 1164
			return _tab_0 -- 1130
		end)() -- 1129
	} -- 1124
end) -- 1061
HttpServer:postSchedule("/run", function(req) -- 1168
	do -- 1169
		local _type_0 = type(req) -- 1169
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1169
		if _tab_0 then -- 1169
			local file -- 1169
			do -- 1169
				local _obj_0 = req.body -- 1169
				local _type_1 = type(_obj_0) -- 1169
				if "table" == _type_1 or "userdata" == _type_1 then -- 1169
					file = _obj_0.file -- 1169
				end -- 1169
			end -- 1169
			local asProj -- 1169
			do -- 1169
				local _obj_0 = req.body -- 1169
				local _type_1 = type(_obj_0) -- 1169
				if "table" == _type_1 or "userdata" == _type_1 then -- 1169
					asProj = _obj_0.asProj -- 1169
				end -- 1169
			end -- 1169
			if file ~= nil and asProj ~= nil then -- 1169
				if not Content:isAbsolutePath(file) then -- 1170
					local devFile = Path(Content.writablePath, file) -- 1171
					if Content:exist(devFile) then -- 1172
						file = devFile -- 1172
					end -- 1172
				end -- 1170
				local Entry = require("Script.Dev.Entry") -- 1173
				local workDir -- 1174
				if asProj then -- 1175
					workDir = getProjectDirFromFile(file) -- 1176
					if workDir then -- 1176
						Entry.allClear() -- 1177
						local target = Path(workDir, "init") -- 1178
						local success, err = Entry.enterEntryAsync({ -- 1179
							entryName = "Project", -- 1179
							fileName = target -- 1179
						}) -- 1179
						target = Path:getName(Path:getPath(target)) -- 1180
						return { -- 1181
							success = success, -- 1181
							target = target, -- 1181
							err = err -- 1181
						} -- 1181
					end -- 1176
				else -- 1183
					workDir = getProjectDirFromFile(file) -- 1183
				end -- 1175
				Entry.allClear() -- 1184
				file = Path:replaceExt(file, "") -- 1185
				local success, err = Entry.enterEntryAsync({ -- 1187
					entryName = Path:getName(file), -- 1187
					fileName = file, -- 1188
					workDir = workDir -- 1189
				}) -- 1186
				return { -- 1190
					success = success, -- 1190
					err = err -- 1190
				} -- 1190
			end -- 1169
		end -- 1169
	end -- 1169
	return { -- 1168
		success = false -- 1168
	} -- 1168
end) -- 1168
HttpServer:postSchedule("/stop", function() -- 1192
	local Entry = require("Script.Dev.Entry") -- 1193
	return { -- 1194
		success = Entry.stop() -- 1194
	} -- 1194
end) -- 1192
local minifyAsync -- 1196
minifyAsync = function(sourcePath, minifyPath) -- 1196
	if not Content:exist(sourcePath) then -- 1197
		return -- 1197
	end -- 1197
	local Entry = require("Script.Dev.Entry") -- 1198
	local errors = { } -- 1199
	local files = Entry.getAllFiles(sourcePath, { -- 1200
		"lua" -- 1200
	}, true) -- 1200
	do -- 1201
		local _accum_0 = { } -- 1201
		local _len_0 = 1 -- 1201
		for _index_0 = 1, #files do -- 1201
			local file = files[_index_0] -- 1201
			if file:sub(1, 1) ~= '.' then -- 1201
				_accum_0[_len_0] = file -- 1201
				_len_0 = _len_0 + 1 -- 1201
			end -- 1201
		end -- 1201
		files = _accum_0 -- 1201
	end -- 1201
	local paths -- 1202
	do -- 1202
		local _tbl_0 = { } -- 1202
		for _index_0 = 1, #files do -- 1202
			local file = files[_index_0] -- 1202
			_tbl_0[Path:getPath(file)] = true -- 1202
		end -- 1202
		paths = _tbl_0 -- 1202
	end -- 1202
	for path in pairs(paths) do -- 1203
		Content:mkdir(Path(minifyPath, path)) -- 1203
	end -- 1203
	local _ <close> = setmetatable({ }, { -- 1204
		__close = function() -- 1204
			package.loaded["luaminify.FormatMini"] = nil -- 1205
			package.loaded["luaminify.ParseLua"] = nil -- 1206
			package.loaded["luaminify.Scope"] = nil -- 1207
			package.loaded["luaminify.Util"] = nil -- 1208
		end -- 1204
	}) -- 1204
	local FormatMini -- 1209
	do -- 1209
		local _obj_0 = require("luaminify") -- 1209
		FormatMini = _obj_0.FormatMini -- 1209
	end -- 1209
	local fileCount = #files -- 1210
	local count = 0 -- 1211
	for _index_0 = 1, #files do -- 1212
		local file = files[_index_0] -- 1212
		thread(function() -- 1213
			local _ <close> = setmetatable({ }, { -- 1214
				__close = function() -- 1214
					count = count + 1 -- 1214
				end -- 1214
			}) -- 1214
			local input = Path(sourcePath, file) -- 1215
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1216
			if Content:exist(input) then -- 1217
				local sourceCodes = Content:loadAsync(input) -- 1218
				local res, err = FormatMini(sourceCodes) -- 1219
				if res then -- 1220
					Content:saveAsync(output, res) -- 1221
					return print("Minify " .. tostring(file)) -- 1222
				else -- 1224
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1224
				end -- 1220
			else -- 1226
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1226
			end -- 1217
		end) -- 1213
		sleep() -- 1227
	end -- 1212
	wait(function() -- 1228
		return count == fileCount -- 1228
	end) -- 1228
	if #errors > 0 then -- 1229
		print(table.concat(errors, '\n')) -- 1230
	end -- 1229
	print("Obfuscation done.") -- 1231
	return files -- 1232
end -- 1196
local zipping = false -- 1234
HttpServer:postSchedule("/zip", function(req) -- 1236
	do -- 1237
		local _type_0 = type(req) -- 1237
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1237
		if _tab_0 then -- 1237
			local path -- 1237
			do -- 1237
				local _obj_0 = req.body -- 1237
				local _type_1 = type(_obj_0) -- 1237
				if "table" == _type_1 or "userdata" == _type_1 then -- 1237
					path = _obj_0.path -- 1237
				end -- 1237
			end -- 1237
			local zipFile -- 1237
			do -- 1237
				local _obj_0 = req.body -- 1237
				local _type_1 = type(_obj_0) -- 1237
				if "table" == _type_1 or "userdata" == _type_1 then -- 1237
					zipFile = _obj_0.zipFile -- 1237
				end -- 1237
			end -- 1237
			local obfuscated -- 1237
			do -- 1237
				local _obj_0 = req.body -- 1237
				local _type_1 = type(_obj_0) -- 1237
				if "table" == _type_1 or "userdata" == _type_1 then -- 1237
					obfuscated = _obj_0.obfuscated -- 1237
				end -- 1237
			end -- 1237
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1237
				if zipping then -- 1238
					goto failed -- 1238
				end -- 1238
				zipping = true -- 1239
				local _ <close> = setmetatable({ }, { -- 1240
					__close = function() -- 1240
						zipping = false -- 1240
					end -- 1240
				}) -- 1240
				if not Content:exist(path) then -- 1241
					goto failed -- 1241
				end -- 1241
				Content:mkdir(Path:getPath(zipFile)) -- 1242
				if obfuscated then -- 1243
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1244
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1245
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1246
					Content:remove(scriptPath) -- 1247
					Content:remove(obfuscatedPath) -- 1248
					Content:remove(tempPath) -- 1249
					Content:mkdir(scriptPath) -- 1250
					Content:mkdir(obfuscatedPath) -- 1251
					Content:mkdir(tempPath) -- 1252
					if not Content:copyAsync(path, tempPath) then -- 1253
						goto failed -- 1253
					end -- 1253
					local Entry = require("Script.Dev.Entry") -- 1254
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1255
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1256
						"tl", -- 1256
						"yue", -- 1256
						"lua", -- 1256
						"ts", -- 1256
						"tsx", -- 1256
						"vs", -- 1256
						"bl", -- 1256
						"xml", -- 1256
						"wa", -- 1256
						"mod" -- 1256
					}, true) -- 1256
					for _index_0 = 1, #scriptFiles do -- 1257
						local file = scriptFiles[_index_0] -- 1257
						Content:remove(Path(tempPath, file)) -- 1258
					end -- 1257
					for _index_0 = 1, #luaFiles do -- 1259
						local file = luaFiles[_index_0] -- 1259
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1260
					end -- 1259
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1261
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1262
					end) then -- 1261
						goto failed -- 1261
					end -- 1261
					return { -- 1263
						success = true -- 1263
					} -- 1263
				else -- 1265
					return { -- 1265
						success = Content:zipAsync(path, zipFile, function(file) -- 1265
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1266
						end) -- 1265
					} -- 1265
				end -- 1243
			end -- 1237
		end -- 1237
	end -- 1237
	::failed:: -- 1267
	return { -- 1236
		success = false -- 1236
	} -- 1236
end) -- 1236
HttpServer:postSchedule("/unzip", function(req) -- 1269
	do -- 1270
		local _type_0 = type(req) -- 1270
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1270
		if _tab_0 then -- 1270
			local zipFile -- 1270
			do -- 1270
				local _obj_0 = req.body -- 1270
				local _type_1 = type(_obj_0) -- 1270
				if "table" == _type_1 or "userdata" == _type_1 then -- 1270
					zipFile = _obj_0.zipFile -- 1270
				end -- 1270
			end -- 1270
			local path -- 1270
			do -- 1270
				local _obj_0 = req.body -- 1270
				local _type_1 = type(_obj_0) -- 1270
				if "table" == _type_1 or "userdata" == _type_1 then -- 1270
					path = _obj_0.path -- 1270
				end -- 1270
			end -- 1270
			if zipFile ~= nil and path ~= nil then -- 1270
				return { -- 1271
					success = Content:unzipAsync(zipFile, path, function(file) -- 1271
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1272
					end) -- 1271
				} -- 1271
			end -- 1270
		end -- 1270
	end -- 1270
	return { -- 1269
		success = false -- 1269
	} -- 1269
end) -- 1269
HttpServer:post("/editing-info", function(req) -- 1274
	local Entry = require("Script.Dev.Entry") -- 1275
	local config = Entry.getConfig() -- 1276
	local _type_0 = type(req) -- 1277
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1277
	local _match_0 = false -- 1277
	if _tab_0 then -- 1277
		local editingInfo -- 1277
		do -- 1277
			local _obj_0 = req.body -- 1277
			local _type_1 = type(_obj_0) -- 1277
			if "table" == _type_1 or "userdata" == _type_1 then -- 1277
				editingInfo = _obj_0.editingInfo -- 1277
			end -- 1277
		end -- 1277
		if editingInfo ~= nil then -- 1277
			_match_0 = true -- 1277
			config.editingInfo = editingInfo -- 1278
			return { -- 1279
				success = true -- 1279
			} -- 1279
		end -- 1277
	end -- 1277
	if not _match_0 then -- 1277
		if not (config.editingInfo ~= nil) then -- 1281
			local folder -- 1282
			if App.locale:match('^zh') then -- 1282
				folder = 'zh-Hans' -- 1282
			else -- 1282
				folder = 'en' -- 1282
			end -- 1282
			config.editingInfo = json.encode({ -- 1284
				index = 0, -- 1284
				files = { -- 1286
					{ -- 1287
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1287
						title = "welcome.md" -- 1288
					} -- 1286
				} -- 1285
			}) -- 1283
		end -- 1281
		return { -- 1292
			success = true, -- 1292
			editingInfo = config.editingInfo -- 1292
		} -- 1292
	end -- 1277
end) -- 1274
HttpServer:post("/command", function(req) -- 1294
	do -- 1295
		local _type_0 = type(req) -- 1295
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1295
		if _tab_0 then -- 1295
			local code -- 1295
			do -- 1295
				local _obj_0 = req.body -- 1295
				local _type_1 = type(_obj_0) -- 1295
				if "table" == _type_1 or "userdata" == _type_1 then -- 1295
					code = _obj_0.code -- 1295
				end -- 1295
			end -- 1295
			local log -- 1295
			do -- 1295
				local _obj_0 = req.body -- 1295
				local _type_1 = type(_obj_0) -- 1295
				if "table" == _type_1 or "userdata" == _type_1 then -- 1295
					log = _obj_0.log -- 1295
				end -- 1295
			end -- 1295
			if code ~= nil and log ~= nil then -- 1295
				emit("AppCommand", code, log) -- 1296
				return { -- 1297
					success = true -- 1297
				} -- 1297
			end -- 1295
		end -- 1295
	end -- 1295
	return { -- 1294
		success = false -- 1294
	} -- 1294
end) -- 1294
HttpServer:post("/log/save", function() -- 1299
	local folder = ".download" -- 1300
	local fullLogFile = "dora_full_logs.txt" -- 1301
	local fullFolder = Path(Content.writablePath, folder) -- 1302
	Content:mkdir(fullFolder) -- 1303
	local logPath = Path(fullFolder, fullLogFile) -- 1304
	if App:saveLog(logPath) then -- 1305
		return { -- 1306
			success = true, -- 1306
			path = Path(folder, fullLogFile) -- 1306
		} -- 1306
	end -- 1305
	return { -- 1299
		success = false -- 1299
	} -- 1299
end) -- 1299
HttpServer:post("/yarn/check", function(req) -- 1308
	local yarncompile = require("yarncompile") -- 1309
	do -- 1310
		local _type_0 = type(req) -- 1310
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1310
		if _tab_0 then -- 1310
			local code -- 1310
			do -- 1310
				local _obj_0 = req.body -- 1310
				local _type_1 = type(_obj_0) -- 1310
				if "table" == _type_1 or "userdata" == _type_1 then -- 1310
					code = _obj_0.code -- 1310
				end -- 1310
			end -- 1310
			if code ~= nil then -- 1310
				local jsonObject = json.decode(code) -- 1311
				if jsonObject then -- 1311
					local errors = { } -- 1312
					local _list_0 = jsonObject.nodes -- 1313
					for _index_0 = 1, #_list_0 do -- 1313
						local node = _list_0[_index_0] -- 1313
						local title, body = node.title, node.body -- 1314
						local luaCode, err = yarncompile(body) -- 1315
						if not luaCode then -- 1315
							errors[#errors + 1] = title .. ":" .. err -- 1316
						end -- 1315
					end -- 1313
					return { -- 1317
						success = true, -- 1317
						syntaxError = table.concat(errors, "\n\n") -- 1317
					} -- 1317
				end -- 1311
			end -- 1310
		end -- 1310
	end -- 1310
	return { -- 1308
		success = false -- 1308
	} -- 1308
end) -- 1308
HttpServer:post("/yarn/check-file", function(req) -- 1319
	local yarncompile = require("yarncompile") -- 1320
	do -- 1321
		local _type_0 = type(req) -- 1321
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1321
		if _tab_0 then -- 1321
			local code -- 1321
			do -- 1321
				local _obj_0 = req.body -- 1321
				local _type_1 = type(_obj_0) -- 1321
				if "table" == _type_1 or "userdata" == _type_1 then -- 1321
					code = _obj_0.code -- 1321
				end -- 1321
			end -- 1321
			if code ~= nil then -- 1321
				local res, _, err = yarncompile(code, true) -- 1322
				if not res then -- 1322
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1323
					return { -- 1324
						success = false, -- 1324
						message = message, -- 1324
						line = line, -- 1324
						column = column, -- 1324
						node = node -- 1324
					} -- 1324
				end -- 1322
			end -- 1321
		end -- 1321
	end -- 1321
	return { -- 1319
		success = true -- 1319
	} -- 1319
end) -- 1319
local getWaProjectDirFromFile -- 1326
getWaProjectDirFromFile = function(file) -- 1326
	local writablePath = Content.writablePath -- 1327
	local parent, current -- 1328
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1328
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1329
	else -- 1331
		parent, current = nil, nil -- 1331
	end -- 1328
	if not current then -- 1332
		return nil -- 1332
	end -- 1332
	repeat -- 1333
		current = Path:getPath(current) -- 1334
		if current == "" then -- 1335
			break -- 1335
		end -- 1335
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1336
		for _index_0 = 1, #_list_0 do -- 1336
			local f = _list_0[_index_0] -- 1336
			if Path:getFilename(f):lower() == "wa.mod" then -- 1337
				return Path(parent, current, Path:getPath(f)) -- 1338
			end -- 1337
		end -- 1336
	until false -- 1333
	return nil -- 1340
end -- 1326
HttpServer:postSchedule("/wa/update_dora", function(req) -- 1342
	do -- 1343
		local _type_0 = type(req) -- 1343
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1343
		if _tab_0 then -- 1343
			local path -- 1343
			do -- 1343
				local _obj_0 = req.body -- 1343
				local _type_1 = type(_obj_0) -- 1343
				if "table" == _type_1 or "userdata" == _type_1 then -- 1343
					path = _obj_0.path -- 1343
				end -- 1343
			end -- 1343
			if path ~= nil then -- 1343
				local projDir = getWaProjectDirFromFile(path) -- 1344
				if projDir then -- 1344
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 1345
					if not Content:exist(sourceDoraPath) then -- 1346
						return { -- 1347
							success = false, -- 1347
							message = "missing dora template" -- 1347
						} -- 1347
					end -- 1346
					local targetVendorPath = Path(projDir, "vendor") -- 1348
					local targetDoraPath = Path(targetVendorPath, "dora") -- 1349
					if not Content:exist(targetVendorPath) then -- 1350
						if not Content:mkdir(targetVendorPath) then -- 1351
							return { -- 1352
								success = false, -- 1352
								message = "failed to create vendor folder" -- 1352
							} -- 1352
						end -- 1351
					elseif not Content:isdir(targetVendorPath) then -- 1353
						return { -- 1354
							success = false, -- 1354
							message = "vendor path is not a folder" -- 1354
						} -- 1354
					end -- 1350
					if Content:exist(targetDoraPath) then -- 1355
						if not Content:remove(targetDoraPath) then -- 1356
							return { -- 1357
								success = false, -- 1357
								message = "failed to remove old dora" -- 1357
							} -- 1357
						end -- 1356
					end -- 1355
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 1358
						return { -- 1359
							success = false, -- 1359
							message = "failed to copy dora" -- 1359
						} -- 1359
					end -- 1358
					return { -- 1360
						success = true -- 1360
					} -- 1360
				else -- 1362
					return { -- 1362
						success = false, -- 1362
						message = 'Wa file needs a project' -- 1362
					} -- 1362
				end -- 1344
			end -- 1343
		end -- 1343
	end -- 1343
	return { -- 1342
		success = false, -- 1342
		message = "invalid call" -- 1342
	} -- 1342
end) -- 1342
HttpServer:postSchedule("/wa/build", function(req) -- 1364
	do -- 1365
		local _type_0 = type(req) -- 1365
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1365
		if _tab_0 then -- 1365
			local path -- 1365
			do -- 1365
				local _obj_0 = req.body -- 1365
				local _type_1 = type(_obj_0) -- 1365
				if "table" == _type_1 or "userdata" == _type_1 then -- 1365
					path = _obj_0.path -- 1365
				end -- 1365
			end -- 1365
			if path ~= nil then -- 1365
				local projDir = getWaProjectDirFromFile(path) -- 1366
				if projDir then -- 1366
					local message = Wasm:buildWaAsync(projDir) -- 1367
					if message == "" then -- 1368
						return { -- 1369
							success = true -- 1369
						} -- 1369
					else -- 1371
						return { -- 1371
							success = false, -- 1371
							message = message -- 1371
						} -- 1371
					end -- 1368
				else -- 1373
					return { -- 1373
						success = false, -- 1373
						message = 'Wa file needs a project' -- 1373
					} -- 1373
				end -- 1366
			end -- 1365
		end -- 1365
	end -- 1365
	return { -- 1374
		success = false, -- 1374
		message = 'failed to build' -- 1374
	} -- 1374
end) -- 1364
HttpServer:postSchedule("/wa/format", function(req) -- 1376
	do -- 1377
		local _type_0 = type(req) -- 1377
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1377
		if _tab_0 then -- 1377
			local file -- 1377
			do -- 1377
				local _obj_0 = req.body -- 1377
				local _type_1 = type(_obj_0) -- 1377
				if "table" == _type_1 or "userdata" == _type_1 then -- 1377
					file = _obj_0.file -- 1377
				end -- 1377
			end -- 1377
			if file ~= nil then -- 1377
				local code = Wasm:formatWaAsync(file) -- 1378
				if code == "" then -- 1379
					return { -- 1380
						success = false -- 1380
					} -- 1380
				else -- 1382
					return { -- 1382
						success = true, -- 1382
						code = code -- 1382
					} -- 1382
				end -- 1379
			end -- 1377
		end -- 1377
	end -- 1377
	return { -- 1383
		success = false -- 1383
	} -- 1383
end) -- 1376
HttpServer:postSchedule("/wa/create", function(req) -- 1385
	do -- 1386
		local _type_0 = type(req) -- 1386
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1386
		if _tab_0 then -- 1386
			local path -- 1386
			do -- 1386
				local _obj_0 = req.body -- 1386
				local _type_1 = type(_obj_0) -- 1386
				if "table" == _type_1 or "userdata" == _type_1 then -- 1386
					path = _obj_0.path -- 1386
				end -- 1386
			end -- 1386
			if path ~= nil then -- 1386
				if not Content:exist(Path:getPath(path)) then -- 1387
					return { -- 1388
						success = false, -- 1388
						message = "target path not existed" -- 1388
					} -- 1388
				end -- 1387
				if Content:exist(path) then -- 1389
					return { -- 1390
						success = false, -- 1390
						message = "target project folder existed" -- 1390
					} -- 1390
				end -- 1389
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1391
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1392
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1393
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1394
					return { -- 1397
						success = false, -- 1397
						message = "missing template project" -- 1397
					} -- 1397
				end -- 1394
				if not Content:mkdir(path) then -- 1398
					return { -- 1399
						success = false, -- 1399
						message = "failed to create project folder" -- 1399
					} -- 1399
				end -- 1398
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1400
					Content:remove(path) -- 1401
					return { -- 1402
						success = false, -- 1402
						message = "failed to copy template" -- 1402
					} -- 1402
				end -- 1400
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1403
					Content:remove(path) -- 1404
					return { -- 1405
						success = false, -- 1405
						message = "failed to copy template" -- 1405
					} -- 1405
				end -- 1403
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1406
					Content:remove(path) -- 1407
					return { -- 1408
						success = false, -- 1408
						message = "failed to copy template" -- 1408
					} -- 1408
				end -- 1406
				return { -- 1409
					success = true -- 1409
				} -- 1409
			end -- 1386
		end -- 1386
	end -- 1386
	return { -- 1385
		success = false, -- 1385
		message = "invalid call" -- 1385
	} -- 1385
end) -- 1385
local _anon_func_5 = function(path) -- 1418
	local _val_0 = Path:getExt(path) -- 1418
	return "ts" == _val_0 or "tsx" == _val_0 -- 1418
end -- 1418
local _anon_func_6 = function(f) -- 1448
	local _val_0 = Path:getExt(f) -- 1448
	return "ts" == _val_0 or "tsx" == _val_0 -- 1448
end -- 1448
HttpServer:postSchedule("/ts/build", function(req) -- 1411
	do -- 1412
		local _type_0 = type(req) -- 1412
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1412
		if _tab_0 then -- 1412
			local path -- 1412
			do -- 1412
				local _obj_0 = req.body -- 1412
				local _type_1 = type(_obj_0) -- 1412
				if "table" == _type_1 or "userdata" == _type_1 then -- 1412
					path = _obj_0.path -- 1412
				end -- 1412
			end -- 1412
			if path ~= nil then -- 1412
				if HttpServer.wsConnectionCount == 0 then -- 1413
					return { -- 1414
						success = false, -- 1414
						message = "Web IDE not connected" -- 1414
					} -- 1414
				end -- 1413
				if not Content:exist(path) then -- 1415
					return { -- 1416
						success = false, -- 1416
						message = "path not existed" -- 1416
					} -- 1416
				end -- 1415
				if not Content:isdir(path) then -- 1417
					if not (_anon_func_5(path)) then -- 1418
						return { -- 1419
							success = false, -- 1419
							message = "expecting a TypeScript file" -- 1419
						} -- 1419
					end -- 1418
					local messages = { } -- 1420
					local content = Content:load(path) -- 1421
					if not content then -- 1422
						return { -- 1423
							success = false, -- 1423
							message = "failed to read file" -- 1423
						} -- 1423
					end -- 1422
					emit("AppWS", "Send", json.encode({ -- 1424
						name = "UpdateFile", -- 1424
						file = path, -- 1424
						exists = true, -- 1424
						content = content -- 1424
					})) -- 1424
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1425
						local done = false -- 1426
						do -- 1427
							local _with_0 = Node() -- 1427
							_with_0:gslot("AppWS", function(event) -- 1428
								if event.type == "Receive" then -- 1429
									_with_0:removeFromParent() -- 1430
									local res = json.decode(event.msg) -- 1431
									if res then -- 1431
										if res.name == "TranspileTS" then -- 1432
											if res.success then -- 1433
												local luaFile = Path:replaceExt(path, "lua") -- 1434
												Content:save(luaFile, res.luaCode) -- 1435
												messages[#messages + 1] = { -- 1436
													success = true, -- 1436
													file = path -- 1436
												} -- 1436
											else -- 1438
												messages[#messages + 1] = { -- 1438
													success = false, -- 1438
													file = path, -- 1438
													message = res.message -- 1438
												} -- 1438
											end -- 1433
											done = true -- 1439
										end -- 1432
									end -- 1431
								end -- 1429
							end) -- 1428
						end -- 1427
						emit("AppWS", "Send", json.encode({ -- 1440
							name = "TranspileTS", -- 1440
							file = path, -- 1440
							content = content -- 1440
						})) -- 1440
						wait(function() -- 1441
							return done -- 1441
						end) -- 1441
					end -- 1425
					return { -- 1442
						success = true, -- 1442
						messages = messages -- 1442
					} -- 1442
				else -- 1444
					local files = Content:getAllFiles(path) -- 1444
					local fileData = { } -- 1445
					local messages = { } -- 1446
					for _index_0 = 1, #files do -- 1447
						local f = files[_index_0] -- 1447
						if not (_anon_func_6(f)) then -- 1448
							goto _continue_0 -- 1448
						end -- 1448
						local file = Path(path, f) -- 1449
						local content = Content:load(file) -- 1450
						if content then -- 1450
							fileData[file] = content -- 1451
							emit("AppWS", "Send", json.encode({ -- 1452
								name = "UpdateFile", -- 1452
								file = file, -- 1452
								exists = true, -- 1452
								content = content -- 1452
							})) -- 1452
						else -- 1454
							messages[#messages + 1] = { -- 1454
								success = false, -- 1454
								file = file, -- 1454
								message = "failed to read file" -- 1454
							} -- 1454
						end -- 1450
						::_continue_0:: -- 1448
					end -- 1447
					for file, content in pairs(fileData) do -- 1455
						if "d" == Path:getExt(Path:getName(file)) then -- 1456
							goto _continue_1 -- 1456
						end -- 1456
						local done = false -- 1457
						do -- 1458
							local _with_0 = Node() -- 1458
							_with_0:gslot("AppWS", function(event) -- 1459
								if event.type == "Receive" then -- 1460
									_with_0:removeFromParent() -- 1461
									local res = json.decode(event.msg) -- 1462
									if res then -- 1462
										if res.name == "TranspileTS" then -- 1463
											if res.success then -- 1464
												local luaFile = Path:replaceExt(file, "lua") -- 1465
												Content:save(luaFile, res.luaCode) -- 1466
												messages[#messages + 1] = { -- 1467
													success = true, -- 1467
													file = file -- 1467
												} -- 1467
											else -- 1469
												messages[#messages + 1] = { -- 1469
													success = false, -- 1469
													file = file, -- 1469
													message = res.message -- 1469
												} -- 1469
											end -- 1464
											done = true -- 1470
										end -- 1463
									end -- 1462
								end -- 1460
							end) -- 1459
						end -- 1458
						emit("AppWS", "Send", json.encode({ -- 1471
							name = "TranspileTS", -- 1471
							file = file, -- 1471
							content = content -- 1471
						})) -- 1471
						wait(function() -- 1472
							return done -- 1472
						end) -- 1472
						::_continue_1:: -- 1456
					end -- 1455
					return { -- 1473
						success = true, -- 1473
						messages = messages -- 1473
					} -- 1473
				end -- 1417
			end -- 1412
		end -- 1412
	end -- 1412
	return { -- 1411
		success = false -- 1411
	} -- 1411
end) -- 1411
HttpServer:post("/download", function(req) -- 1475
	do -- 1476
		local _type_0 = type(req) -- 1476
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1476
		if _tab_0 then -- 1476
			local url -- 1476
			do -- 1476
				local _obj_0 = req.body -- 1476
				local _type_1 = type(_obj_0) -- 1476
				if "table" == _type_1 or "userdata" == _type_1 then -- 1476
					url = _obj_0.url -- 1476
				end -- 1476
			end -- 1476
			local target -- 1476
			do -- 1476
				local _obj_0 = req.body -- 1476
				local _type_1 = type(_obj_0) -- 1476
				if "table" == _type_1 or "userdata" == _type_1 then -- 1476
					target = _obj_0.target -- 1476
				end -- 1476
			end -- 1476
			if url ~= nil and target ~= nil then -- 1476
				local Entry = require("Script.Dev.Entry") -- 1477
				Entry.downloadFile(url, target) -- 1478
				return { -- 1479
					success = true -- 1479
				} -- 1479
			end -- 1476
		end -- 1476
	end -- 1476
	return { -- 1475
		success = false -- 1475
	} -- 1475
end) -- 1475
local status = { } -- 1481
_module_0 = status -- 1482
status.buildAsync = function(path) -- 1484
	if not Content:exist(path) then -- 1485
		return { -- 1486
			success = false, -- 1486
			file = path, -- 1486
			message = "file not existed" -- 1486
		} -- 1486
	end -- 1485
	do -- 1487
		local _exp_0 = Path:getExt(path) -- 1487
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1487
			if '' == Path:getExt(Path:getName(path)) then -- 1488
				local content = Content:loadAsync(path) -- 1489
				if content then -- 1489
					local resultCodes, err = compileFileAsync(path, content) -- 1490
					if resultCodes then -- 1490
						return { -- 1491
							success = true, -- 1491
							file = path -- 1491
						} -- 1491
					else -- 1493
						return { -- 1493
							success = false, -- 1493
							file = path, -- 1493
							message = err -- 1493
						} -- 1493
					end -- 1490
				end -- 1489
			end -- 1488
		elseif "lua" == _exp_0 then -- 1494
			local content = Content:loadAsync(path) -- 1495
			if content then -- 1495
				do -- 1496
					local isTIC80 = CheckTIC80Code(content) -- 1496
					if isTIC80 then -- 1496
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1497
					end -- 1496
				end -- 1496
				local success, info -- 1498
				do -- 1498
					local _obj_0 = luaCheck(path, content) -- 1498
					success, info = _obj_0.success, _obj_0.info -- 1498
				end -- 1498
				if success then -- 1499
					return { -- 1500
						success = true, -- 1500
						file = path -- 1500
					} -- 1500
				elseif info and #info > 0 then -- 1501
					local messages = { } -- 1502
					for _index_0 = 1, #info do -- 1503
						local _des_0 = info[_index_0] -- 1503
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 1503
						local lineText = "" -- 1504
						if line then -- 1505
							local currentLine = 1 -- 1506
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1507
								if currentLine == line then -- 1508
									lineText = text -- 1509
									break -- 1510
								end -- 1508
								currentLine = currentLine + 1 -- 1511
							end -- 1507
						end -- 1505
						if line then -- 1512
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1513
						else -- 1515
							messages[#messages + 1] = message -- 1515
						end -- 1512
					end -- 1503
					return { -- 1516
						success = false, -- 1516
						file = path, -- 1516
						message = table.concat(messages, "\n") -- 1516
					} -- 1516
				else -- 1518
					return { -- 1518
						success = false, -- 1518
						file = path, -- 1518
						message = "lua check failed" -- 1518
					} -- 1518
				end -- 1499
			end -- 1495
		elseif "yarn" == _exp_0 then -- 1519
			local content = Content:loadAsync(path) -- 1520
			if content then -- 1520
				local res, _, err = yarncompile(content, true) -- 1521
				if res then -- 1521
					return { -- 1522
						success = true, -- 1522
						file = path -- 1522
					} -- 1522
				else -- 1524
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1524
					local lineText = "" -- 1525
					if line then -- 1526
						local currentLine = 1 -- 1527
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1528
							if currentLine == line then -- 1529
								lineText = text -- 1530
								break -- 1531
							end -- 1529
							currentLine = currentLine + 1 -- 1532
						end -- 1528
					end -- 1526
					if node ~= "" then -- 1533
						node = "node: " .. tostring(node) .. ", " -- 1534
					else -- 1535
						node = "" -- 1535
					end -- 1533
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1536
					return { -- 1537
						success = false, -- 1537
						file = path, -- 1537
						message = message -- 1537
					} -- 1537
				end -- 1521
			end -- 1520
		end -- 1487
	end -- 1487
	return { -- 1538
		success = false, -- 1538
		file = path, -- 1538
		message = "invalid file to build" -- 1538
	} -- 1538
end -- 1484
thread(function() -- 1540
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1541
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1542
	if Content:exist(doraWeb) then -- 1543
		local needReload -- 1544
		if Content:exist(doraReady) then -- 1544
			needReload = App.version ~= Content:load(doraReady) -- 1545
		else -- 1546
			needReload = true -- 1546
		end -- 1544
		if needReload then -- 1547
			Content:remove(Path(Content.appPath, ".www")) -- 1548
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1549
			Content:save(doraReady, App.version) -- 1553
			print("Dora Dora is ready!") -- 1554
		end -- 1547
	end -- 1543
	if HttpServer:start(8866) then -- 1555
		local localIP = HttpServer.localIP -- 1556
		if localIP == "" then -- 1557
			localIP = "localhost" -- 1557
		end -- 1557
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1558
		return HttpServer:startWS(8868) -- 1559
	else -- 1561
		status.url = nil -- 1561
		return print("8866 Port not available!") -- 1562
	end -- 1555
end) -- 1540
return _module_0 -- 1
