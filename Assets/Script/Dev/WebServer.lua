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
	return DB:exec([[		CREATE TABLE IF NOT EXISTS LLMConfig(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			url TEXT NOT NULL,
			model TEXT NOT NULL,
			api_key TEXT NOT NULL,
			context_window INTEGER NOT NULL DEFAULT 32000,
			active INTEGER NOT NULL DEFAULT 1,
			created_at INTEGER,
			updated_at INTEGER
		);
	]]) -- 723
end -- 722
local normalizeContextWindow -- 737
normalizeContextWindow = function(value) -- 737
	local contextWindow = tonumber(value) -- 738
	if contextWindow == nil or contextWindow < 4000 then -- 739
		return 32000 -- 740
	end -- 739
	return math.max(4000, math.floor(contextWindow)) -- 741
end -- 737
HttpServer:post("/llm/list", function() -- 743
	ensureLLMConfigTable() -- 744
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, active\n		from LLMConfig\n		order by id asc") -- 745
	local items -- 749
	if rows and #rows > 0 then -- 749
		local _accum_0 = { } -- 750
		local _len_0 = 1 -- 750
		for _index_0 = 1, #rows do -- 750
			local _des_0 = rows[_index_0] -- 750
			local id, name, url, model, key, contextWindow, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7] -- 750
			_accum_0[_len_0] = { -- 751
				id = id, -- 751
				name = name, -- 751
				url = url, -- 751
				model = model, -- 751
				key = key, -- 751
				contextWindow = normalizeContextWindow(contextWindow), -- 751
				active = active ~= 0 -- 751
			} -- 751
			_len_0 = _len_0 + 1 -- 751
		end -- 750
		items = _accum_0 -- 749
	end -- 749
	return { -- 752
		success = true, -- 752
		items = items -- 752
	} -- 752
end) -- 743
HttpServer:post("/llm/create", function(req) -- 754
	ensureLLMConfigTable() -- 755
	do -- 756
		local _type_0 = type(req) -- 756
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 756
		if _tab_0 then -- 756
			local body = req.body -- 756
			if body ~= nil then -- 756
				local name, url, model, key, active, contextWindow = body.name, body.url, body.model, body.key, body.active, body.contextWindow -- 757
				local now = os.time() -- 758
				if name == nil or url == nil or model == nil or key == nil then -- 759
					return { -- 760
						success = false, -- 760
						message = "invalid" -- 760
					} -- 760
				end -- 759
				contextWindow = normalizeContextWindow(contextWindow) -- 761
				if active then -- 762
					active = 1 -- 762
				else -- 762
					active = 0 -- 762
				end -- 762
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 769
					tostring(name), -- 769
					tostring(url), -- 770
					tostring(model), -- 771
					tostring(key), -- 772
					contextWindow, -- 773
					active, -- 774
					now, -- 775
					now -- 776
				}) -- 763
				return { -- 778
					success = affected >= 0 -- 778
				} -- 778
			end -- 756
		end -- 756
	end -- 756
	return { -- 754
		success = false, -- 754
		message = "invalid" -- 754
	} -- 754
end) -- 754
HttpServer:post("/llm/update", function(req) -- 780
	ensureLLMConfigTable() -- 781
	do -- 782
		local _type_0 = type(req) -- 782
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 782
		if _tab_0 then -- 782
			local body = req.body -- 782
			if body ~= nil then -- 782
				local id, name, url, model, key, active, contextWindow = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow -- 783
				local now = os.time() -- 784
				id = tonumber(id) -- 785
				if id == nil then -- 786
					return { -- 787
						success = false, -- 787
						message = "invalid" -- 787
					} -- 787
				end -- 786
				contextWindow = normalizeContextWindow(contextWindow) -- 788
				if active then -- 789
					active = 1 -- 789
				else -- 789
					active = 0 -- 789
				end -- 789
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, active = ?, updated_at = ?\n			where id = ?", { -- 794
					tostring(name), -- 794
					tostring(url), -- 795
					tostring(model), -- 796
					tostring(key), -- 797
					contextWindow, -- 798
					active, -- 799
					now, -- 800
					id -- 801
				}) -- 790
				return { -- 803
					success = affected >= 0 -- 803
				} -- 803
			end -- 782
		end -- 782
	end -- 782
	return { -- 780
		success = false, -- 780
		message = "invalid" -- 780
	} -- 780
end) -- 780
HttpServer:post("/llm/delete", function(req) -- 805
	ensureLLMConfigTable() -- 806
	do -- 807
		local _type_0 = type(req) -- 807
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 807
		if _tab_0 then -- 807
			local id -- 807
			do -- 807
				local _obj_0 = req.body -- 807
				local _type_1 = type(_obj_0) -- 807
				if "table" == _type_1 or "userdata" == _type_1 then -- 807
					id = _obj_0.id -- 807
				end -- 807
			end -- 807
			if id ~= nil then -- 807
				id = tonumber(id) -- 808
				if id == nil then -- 809
					return { -- 810
						success = false, -- 810
						message = "invalid" -- 810
					} -- 810
				end -- 809
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 811
					id -- 811
				}) -- 811
				return { -- 812
					success = affected >= 0 -- 812
				} -- 812
			end -- 807
		end -- 807
	end -- 807
	return { -- 805
		success = false, -- 805
		message = "invalid" -- 805
	} -- 805
end) -- 805
HttpServer:post("/new", function(req) -- 814
	do -- 815
		local _type_0 = type(req) -- 815
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 815
		if _tab_0 then -- 815
			local path -- 815
			do -- 815
				local _obj_0 = req.body -- 815
				local _type_1 = type(_obj_0) -- 815
				if "table" == _type_1 or "userdata" == _type_1 then -- 815
					path = _obj_0.path -- 815
				end -- 815
			end -- 815
			local content -- 815
			do -- 815
				local _obj_0 = req.body -- 815
				local _type_1 = type(_obj_0) -- 815
				if "table" == _type_1 or "userdata" == _type_1 then -- 815
					content = _obj_0.content -- 815
				end -- 815
			end -- 815
			local folder -- 815
			do -- 815
				local _obj_0 = req.body -- 815
				local _type_1 = type(_obj_0) -- 815
				if "table" == _type_1 or "userdata" == _type_1 then -- 815
					folder = _obj_0.folder -- 815
				end -- 815
			end -- 815
			if path ~= nil and content ~= nil and folder ~= nil then -- 815
				if Content:exist(path) then -- 816
					return { -- 817
						success = false, -- 817
						message = "TargetExisted" -- 817
					} -- 817
				end -- 816
				local parent = Path:getPath(path) -- 818
				local files = Content:getFiles(parent) -- 819
				if folder then -- 820
					local name = Path:getFilename(path):lower() -- 821
					for _index_0 = 1, #files do -- 822
						local file = files[_index_0] -- 822
						if name == Path:getFilename(file):lower() then -- 823
							return { -- 824
								success = false, -- 824
								message = "TargetExisted" -- 824
							} -- 824
						end -- 823
					end -- 822
					if Content:mkdir(path) then -- 825
						return { -- 826
							success = true -- 826
						} -- 826
					end -- 825
				else -- 828
					local name = Path:getName(path):lower() -- 828
					for _index_0 = 1, #files do -- 829
						local file = files[_index_0] -- 829
						if name == Path:getName(file):lower() then -- 830
							local ext = Path:getExt(file) -- 831
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 832
								goto _continue_0 -- 833
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 834
								goto _continue_0 -- 835
							end -- 832
							return { -- 836
								success = false, -- 836
								message = "SourceExisted" -- 836
							} -- 836
						end -- 830
						::_continue_0:: -- 830
					end -- 829
					if Content:save(path, content) then -- 837
						return { -- 838
							success = true -- 838
						} -- 838
					end -- 837
				end -- 820
			end -- 815
		end -- 815
	end -- 815
	return { -- 814
		success = false, -- 814
		message = "Failed" -- 814
	} -- 814
end) -- 814
HttpServer:post("/delete", function(req) -- 840
	do -- 841
		local _type_0 = type(req) -- 841
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 841
		if _tab_0 then -- 841
			local path -- 841
			do -- 841
				local _obj_0 = req.body -- 841
				local _type_1 = type(_obj_0) -- 841
				if "table" == _type_1 or "userdata" == _type_1 then -- 841
					path = _obj_0.path -- 841
				end -- 841
			end -- 841
			if path ~= nil then -- 841
				if Content:exist(path) then -- 842
					local parent = Path:getPath(path) -- 843
					local files = Content:getFiles(parent) -- 844
					local name = Path:getName(path):lower() -- 845
					local ext = Path:getExt(path) -- 846
					for _index_0 = 1, #files do -- 847
						local file = files[_index_0] -- 847
						if name == Path:getName(file):lower() then -- 848
							local _exp_0 = Path:getExt(file) -- 849
							if "tl" == _exp_0 then -- 849
								if ("vs" == ext) then -- 849
									Content:remove(Path(parent, file)) -- 850
								end -- 849
							elseif "lua" == _exp_0 then -- 851
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 851
									Content:remove(Path(parent, file)) -- 852
								end -- 851
							end -- 849
						end -- 848
					end -- 847
					if Content:remove(path) then -- 853
						return { -- 854
							success = true -- 854
						} -- 854
					end -- 853
				end -- 842
			end -- 841
		end -- 841
	end -- 841
	return { -- 840
		success = false -- 840
	} -- 840
end) -- 840
HttpServer:post("/rename", function(req) -- 856
	do -- 857
		local _type_0 = type(req) -- 857
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 857
		if _tab_0 then -- 857
			local old -- 857
			do -- 857
				local _obj_0 = req.body -- 857
				local _type_1 = type(_obj_0) -- 857
				if "table" == _type_1 or "userdata" == _type_1 then -- 857
					old = _obj_0.old -- 857
				end -- 857
			end -- 857
			local new -- 857
			do -- 857
				local _obj_0 = req.body -- 857
				local _type_1 = type(_obj_0) -- 857
				if "table" == _type_1 or "userdata" == _type_1 then -- 857
					new = _obj_0.new -- 857
				end -- 857
			end -- 857
			if old ~= nil and new ~= nil then -- 857
				if Content:exist(old) and not Content:exist(new) then -- 858
					local parent = Path:getPath(new) -- 859
					local files = Content:getFiles(parent) -- 860
					if Content:isdir(old) then -- 861
						local name = Path:getFilename(new):lower() -- 862
						for _index_0 = 1, #files do -- 863
							local file = files[_index_0] -- 863
							if name == Path:getFilename(file):lower() then -- 864
								return { -- 865
									success = false -- 865
								} -- 865
							end -- 864
						end -- 863
					else -- 867
						local name = Path:getName(new):lower() -- 867
						local ext = Path:getExt(new) -- 868
						for _index_0 = 1, #files do -- 869
							local file = files[_index_0] -- 869
							if name == Path:getName(file):lower() then -- 870
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 871
									goto _continue_0 -- 872
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 873
									goto _continue_0 -- 874
								end -- 871
								return { -- 875
									success = false -- 875
								} -- 875
							end -- 870
							::_continue_0:: -- 870
						end -- 869
					end -- 861
					if Content:move(old, new) then -- 876
						local newParent = Path:getPath(new) -- 877
						parent = Path:getPath(old) -- 878
						files = Content:getFiles(parent) -- 879
						local newName = Path:getName(new) -- 880
						local oldName = Path:getName(old) -- 881
						local name = oldName:lower() -- 882
						local ext = Path:getExt(old) -- 883
						for _index_0 = 1, #files do -- 884
							local file = files[_index_0] -- 884
							if name == Path:getName(file):lower() then -- 885
								local _exp_0 = Path:getExt(file) -- 886
								if "tl" == _exp_0 then -- 886
									if ("vs" == ext) then -- 886
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 887
									end -- 886
								elseif "lua" == _exp_0 then -- 888
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 888
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 889
									end -- 888
								end -- 886
							end -- 885
						end -- 884
						return { -- 890
							success = true -- 890
						} -- 890
					end -- 876
				end -- 858
			end -- 857
		end -- 857
	end -- 857
	return { -- 856
		success = false -- 856
	} -- 856
end) -- 856
HttpServer:post("/exist", function(req) -- 892
	do -- 893
		local _type_0 = type(req) -- 893
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 893
		if _tab_0 then -- 893
			local file -- 893
			do -- 893
				local _obj_0 = req.body -- 893
				local _type_1 = type(_obj_0) -- 893
				if "table" == _type_1 or "userdata" == _type_1 then -- 893
					file = _obj_0.file -- 893
				end -- 893
			end -- 893
			if file ~= nil then -- 893
				do -- 894
					local projFile = req.body.projFile -- 894
					if projFile then -- 894
						local projDir = getProjectDirFromFile(projFile) -- 895
						if projDir then -- 895
							local scriptDir = Path(projDir, "Script") -- 896
							local searchPaths = Content.searchPaths -- 897
							if Content:exist(scriptDir) then -- 898
								Content:addSearchPath(scriptDir) -- 898
							end -- 898
							if Content:exist(projDir) then -- 899
								Content:addSearchPath(projDir) -- 899
							end -- 899
							local _ <close> = setmetatable({ }, { -- 900
								__close = function() -- 900
									Content.searchPaths = searchPaths -- 900
								end -- 900
							}) -- 900
							return { -- 901
								success = Content:exist(file) -- 901
							} -- 901
						end -- 895
					end -- 894
				end -- 894
				return { -- 902
					success = Content:exist(file) -- 902
				} -- 902
			end -- 893
		end -- 893
	end -- 893
	return { -- 892
		success = false -- 892
	} -- 892
end) -- 892
HttpServer:postSchedule("/read", function(req) -- 904
	do -- 905
		local _type_0 = type(req) -- 905
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 905
		if _tab_0 then -- 905
			local path -- 905
			do -- 905
				local _obj_0 = req.body -- 905
				local _type_1 = type(_obj_0) -- 905
				if "table" == _type_1 or "userdata" == _type_1 then -- 905
					path = _obj_0.path -- 905
				end -- 905
			end -- 905
			if path ~= nil then -- 905
				local readFile -- 906
				readFile = function() -- 906
					if Content:exist(path) then -- 907
						local content = Content:loadAsync(path) -- 908
						if content then -- 908
							return { -- 909
								content = content, -- 909
								success = true -- 909
							} -- 909
						end -- 908
					end -- 907
					return nil -- 906
				end -- 906
				do -- 910
					local projFile = req.body.projFile -- 910
					if projFile then -- 910
						local projDir = getProjectDirFromFile(projFile) -- 911
						if projDir then -- 911
							local scriptDir = Path(projDir, "Script") -- 912
							local searchPaths = Content.searchPaths -- 913
							if Content:exist(scriptDir) then -- 914
								Content:addSearchPath(scriptDir) -- 914
							end -- 914
							if Content:exist(projDir) then -- 915
								Content:addSearchPath(projDir) -- 915
							end -- 915
							local _ <close> = setmetatable({ }, { -- 916
								__close = function() -- 916
									Content.searchPaths = searchPaths -- 916
								end -- 916
							}) -- 916
							local result = readFile() -- 917
							if result then -- 917
								return result -- 917
							end -- 917
						end -- 911
					end -- 910
				end -- 910
				local result = readFile() -- 918
				if result then -- 918
					return result -- 918
				end -- 918
			end -- 905
		end -- 905
	end -- 905
	return { -- 904
		success = false -- 904
	} -- 904
end) -- 904
HttpServer:get("/read-sync", function(req) -- 920
	do -- 921
		local _type_0 = type(req) -- 921
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 921
		if _tab_0 then -- 921
			local params = req.params -- 921
			if params ~= nil then -- 921
				local path = params.path -- 922
				local exts -- 923
				if params.exts then -- 923
					local _accum_0 = { } -- 924
					local _len_0 = 1 -- 924
					for ext in params.exts:gmatch("[^|]*") do -- 924
						_accum_0[_len_0] = ext -- 925
						_len_0 = _len_0 + 1 -- 925
					end -- 924
					exts = _accum_0 -- 923
				else -- 926
					exts = { -- 926
						"" -- 926
					} -- 926
				end -- 923
				local readFile -- 927
				readFile = function() -- 927
					for _index_0 = 1, #exts do -- 928
						local ext = exts[_index_0] -- 928
						local targetPath = path .. ext -- 929
						if Content:exist(targetPath) then -- 930
							local content = Content:load(targetPath) -- 931
							if content then -- 931
								return { -- 932
									content = content, -- 932
									success = true, -- 932
									fullPath = Content:getFullPath(targetPath) -- 932
								} -- 932
							end -- 931
						end -- 930
					end -- 928
					return nil -- 927
				end -- 927
				local searchPaths = Content.searchPaths -- 933
				local _ <close> = setmetatable({ }, { -- 934
					__close = function() -- 934
						Content.searchPaths = searchPaths -- 934
					end -- 934
				}) -- 934
				do -- 935
					local projFile = req.params.projFile -- 935
					if projFile then -- 935
						local projDir = getProjectDirFromFile(projFile) -- 936
						if projDir then -- 936
							local scriptDir = Path(projDir, "Script") -- 937
							if Content:exist(scriptDir) then -- 938
								Content:addSearchPath(scriptDir) -- 938
							end -- 938
							if Content:exist(projDir) then -- 939
								Content:addSearchPath(projDir) -- 939
							end -- 939
						else -- 941
							projDir = Path:getPath(projFile) -- 941
							if Content:exist(projDir) then -- 942
								Content:addSearchPath(projDir) -- 942
							end -- 942
						end -- 936
					end -- 935
				end -- 935
				local result = readFile() -- 943
				if result then -- 943
					return result -- 943
				end -- 943
			end -- 921
		end -- 921
	end -- 921
	return { -- 920
		success = false -- 920
	} -- 920
end) -- 920
local compileFileAsync -- 945
compileFileAsync = function(inputFile, sourceCodes) -- 945
	local file = inputFile -- 946
	local searchPath -- 947
	do -- 947
		local dir = getProjectDirFromFile(inputFile) -- 947
		if dir then -- 947
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 948
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 949
		else -- 951
			file = Path:getRelative(inputFile, Content.writablePath) -- 951
			if file:sub(1, 2) == ".." then -- 952
				file = Path:getRelative(inputFile, Content.assetPath) -- 953
			end -- 952
			searchPath = "" -- 954
		end -- 947
	end -- 947
	local outputFile = Path:replaceExt(inputFile, "lua") -- 955
	local yueext = yue.options.extension -- 956
	local resultCodes = nil -- 957
	local resultError = nil -- 958
	do -- 959
		local _exp_0 = Path:getExt(inputFile) -- 959
		if yueext == _exp_0 then -- 959
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 960
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 961
				if not codes then -- 962
					resultError = err -- 963
					return -- 964
				end -- 962
				local extraGlobal -- 965
				if isTIC80 then -- 965
					extraGlobal = tic80APIs -- 965
				else -- 965
					extraGlobal = nil -- 965
				end -- 965
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 966
				if not success then -- 967
					resultError = message -- 968
					return -- 969
				end -- 967
				if codes == "" then -- 970
					resultCodes = "" -- 971
					return nil -- 972
				end -- 970
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 973
				return resultCodes -- 974
			end, function(success) -- 961
				if not success then -- 975
					Content:remove(outputFile) -- 976
					if resultCodes == nil then -- 977
						resultCodes = false -- 978
					end -- 977
				end -- 975
			end) -- 961
		elseif "tl" == _exp_0 then -- 979
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 980
			if isTIC80 then -- 981
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 982
			end -- 981
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 983
			if codes then -- 983
				if isTIC80 then -- 984
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 985
				end -- 984
				resultCodes = codes -- 986
				Content:saveAsync(outputFile, codes) -- 987
			else -- 989
				Content:remove(outputFile) -- 989
				resultCodes = false -- 990
				resultError = err -- 991
			end -- 983
		elseif "xml" == _exp_0 then -- 992
			local codes, err = xml.tolua(sourceCodes) -- 993
			if codes then -- 993
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 994
				Content:saveAsync(outputFile, resultCodes) -- 995
			else -- 997
				Content:remove(outputFile) -- 997
				resultCodes = false -- 998
				resultError = err -- 999
			end -- 993
		end -- 959
	end -- 959
	wait(function() -- 1000
		return resultCodes ~= nil -- 1000
	end) -- 1000
	if resultCodes then -- 1001
		return resultCodes -- 1002
	else -- 1004
		return nil, resultError -- 1004
	end -- 1001
	return nil -- 945
end -- 945
HttpServer:postSchedule("/write", function(req) -- 1006
	do -- 1007
		local _type_0 = type(req) -- 1007
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1007
		if _tab_0 then -- 1007
			local path -- 1007
			do -- 1007
				local _obj_0 = req.body -- 1007
				local _type_1 = type(_obj_0) -- 1007
				if "table" == _type_1 or "userdata" == _type_1 then -- 1007
					path = _obj_0.path -- 1007
				end -- 1007
			end -- 1007
			local content -- 1007
			do -- 1007
				local _obj_0 = req.body -- 1007
				local _type_1 = type(_obj_0) -- 1007
				if "table" == _type_1 or "userdata" == _type_1 then -- 1007
					content = _obj_0.content -- 1007
				end -- 1007
			end -- 1007
			if path ~= nil and content ~= nil then -- 1007
				if Content:saveAsync(path, content) then -- 1008
					do -- 1009
						local _exp_0 = Path:getExt(path) -- 1009
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1009
							if '' == Path:getExt(Path:getName(path)) then -- 1010
								local resultCodes = compileFileAsync(path, content) -- 1011
								return { -- 1012
									success = true, -- 1012
									resultCodes = resultCodes -- 1012
								} -- 1012
							end -- 1010
						end -- 1009
					end -- 1009
					return { -- 1013
						success = true -- 1013
					} -- 1013
				end -- 1008
			end -- 1007
		end -- 1007
	end -- 1007
	return { -- 1006
		success = false -- 1006
	} -- 1006
end) -- 1006
HttpServer:postSchedule("/build", function(req) -- 1015
	do -- 1016
		local _type_0 = type(req) -- 1016
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1016
		if _tab_0 then -- 1016
			local path -- 1016
			do -- 1016
				local _obj_0 = req.body -- 1016
				local _type_1 = type(_obj_0) -- 1016
				if "table" == _type_1 or "userdata" == _type_1 then -- 1016
					path = _obj_0.path -- 1016
				end -- 1016
			end -- 1016
			if path ~= nil then -- 1016
				local _exp_0 = Path:getExt(path) -- 1017
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1017
					if '' == Path:getExt(Path:getName(path)) then -- 1018
						local content = Content:loadAsync(path) -- 1019
						if content then -- 1019
							local resultCodes = compileFileAsync(path, content) -- 1020
							if resultCodes then -- 1020
								return { -- 1021
									success = true, -- 1021
									resultCodes = resultCodes -- 1021
								} -- 1021
							end -- 1020
						end -- 1019
					end -- 1018
				end -- 1017
			end -- 1016
		end -- 1016
	end -- 1016
	return { -- 1015
		success = false -- 1015
	} -- 1015
end) -- 1015
local extentionLevels = { -- 1024
	vs = 2, -- 1024
	bl = 2, -- 1025
	ts = 1, -- 1026
	tsx = 1, -- 1027
	tl = 1, -- 1028
	yue = 1, -- 1029
	xml = 1, -- 1030
	lua = 0 -- 1031
} -- 1023
HttpServer:post("/assets", function() -- 1033
	local Entry = require("Script.Dev.Entry") -- 1036
	local engineDev = Entry.getEngineDev() -- 1037
	local visitAssets -- 1038
	visitAssets = function(path, tag) -- 1038
		local isWorkspace = tag == "Workspace" -- 1039
		local builtin -- 1040
		if tag == "Builtin" then -- 1040
			builtin = true -- 1040
		else -- 1040
			builtin = nil -- 1040
		end -- 1040
		local children = nil -- 1041
		local dirs = Content:getDirs(path) -- 1042
		for _index_0 = 1, #dirs do -- 1043
			local dir = dirs[_index_0] -- 1043
			if isWorkspace then -- 1044
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1045
					goto _continue_0 -- 1046
				end -- 1045
			elseif dir == ".git" then -- 1047
				goto _continue_0 -- 1048
			end -- 1044
			if not children then -- 1049
				children = { } -- 1049
			end -- 1049
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1050
			::_continue_0:: -- 1044
		end -- 1043
		local files = Content:getFiles(path) -- 1051
		local names = { } -- 1052
		for _index_0 = 1, #files do -- 1053
			local file = files[_index_0] -- 1053
			if file:match("^%.") then -- 1054
				goto _continue_1 -- 1054
			end -- 1054
			local name = Path:getName(file) -- 1055
			local ext = names[name] -- 1056
			if ext then -- 1056
				local lv1 -- 1057
				do -- 1057
					local _exp_0 = extentionLevels[ext] -- 1057
					if _exp_0 ~= nil then -- 1057
						lv1 = _exp_0 -- 1057
					else -- 1057
						lv1 = -1 -- 1057
					end -- 1057
				end -- 1057
				ext = Path:getExt(file) -- 1058
				local lv2 -- 1059
				do -- 1059
					local _exp_0 = extentionLevels[ext] -- 1059
					if _exp_0 ~= nil then -- 1059
						lv2 = _exp_0 -- 1059
					else -- 1059
						lv2 = -1 -- 1059
					end -- 1059
				end -- 1059
				if lv2 > lv1 then -- 1060
					names[name] = ext -- 1061
				elseif lv2 == lv1 then -- 1062
					names[name .. '.' .. ext] = "" -- 1063
				end -- 1060
			else -- 1065
				ext = Path:getExt(file) -- 1065
				if not extentionLevels[ext] then -- 1066
					names[file] = "" -- 1067
				else -- 1069
					names[name] = ext -- 1069
				end -- 1066
			end -- 1056
			::_continue_1:: -- 1054
		end -- 1053
		do -- 1070
			local _accum_0 = { } -- 1070
			local _len_0 = 1 -- 1070
			for name, ext in pairs(names) do -- 1070
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1070
				_len_0 = _len_0 + 1 -- 1070
			end -- 1070
			files = _accum_0 -- 1070
		end -- 1070
		for _index_0 = 1, #files do -- 1071
			local file = files[_index_0] -- 1071
			if not children then -- 1072
				children = { } -- 1072
			end -- 1072
			children[#children + 1] = { -- 1074
				key = Path(path, file), -- 1074
				dir = false, -- 1075
				title = file, -- 1076
				builtin = builtin -- 1077
			} -- 1073
		end -- 1071
		if children then -- 1079
			table.sort(children, function(a, b) -- 1080
				if a.dir == b.dir then -- 1081
					return a.title < b.title -- 1082
				else -- 1084
					return a.dir -- 1084
				end -- 1081
			end) -- 1080
		end -- 1079
		if isWorkspace and children then -- 1085
			return children -- 1086
		else -- 1088
			return { -- 1089
				key = path, -- 1089
				dir = true, -- 1090
				title = Path:getFilename(path), -- 1091
				builtin = builtin, -- 1092
				children = children -- 1093
			} -- 1088
		end -- 1085
	end -- 1038
	local zh = (App.locale:match("^zh") ~= nil) -- 1095
	return { -- 1097
		key = Content.writablePath, -- 1097
		dir = true, -- 1098
		root = true, -- 1099
		title = "Assets", -- 1100
		children = (function() -- 1102
			local _tab_0 = { -- 1102
				{ -- 1103
					key = Path(Content.assetPath), -- 1103
					dir = true, -- 1104
					builtin = true, -- 1105
					title = zh and "内置资源" or "Built-in", -- 1106
					children = { -- 1108
						(function() -- 1108
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1108
							_with_0.title = zh and "说明文档" or "Readme" -- 1109
							return _with_0 -- 1108
						end)(), -- 1108
						(function() -- 1110
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1110
							_with_0.title = zh and "接口文档" or "API Doc" -- 1111
							return _with_0 -- 1110
						end)(), -- 1110
						(function() -- 1112
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1112
							_with_0.title = zh and "开发工具" or "Tools" -- 1113
							return _with_0 -- 1112
						end)(), -- 1112
						(function() -- 1114
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1114
							_with_0.title = zh and "字体" or "Font" -- 1115
							return _with_0 -- 1114
						end)(), -- 1114
						(function() -- 1116
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1116
							_with_0.title = zh and "程序库" or "Lib" -- 1117
							if engineDev then -- 1118
								local _list_0 = _with_0.children -- 1119
								for _index_0 = 1, #_list_0 do -- 1119
									local child = _list_0[_index_0] -- 1119
									if not (child.title == "Dora") then -- 1120
										goto _continue_0 -- 1120
									end -- 1120
									local title = zh and "zh-Hans" or "en" -- 1121
									do -- 1122
										local _accum_0 = { } -- 1122
										local _len_0 = 1 -- 1122
										local _list_1 = child.children -- 1122
										for _index_1 = 1, #_list_1 do -- 1122
											local c = _list_1[_index_1] -- 1122
											if c.title ~= title then -- 1122
												_accum_0[_len_0] = c -- 1122
												_len_0 = _len_0 + 1 -- 1122
											end -- 1122
										end -- 1122
										child.children = _accum_0 -- 1122
									end -- 1122
									break -- 1123
									::_continue_0:: -- 1120
								end -- 1119
							else -- 1125
								local _accum_0 = { } -- 1125
								local _len_0 = 1 -- 1125
								local _list_0 = _with_0.children -- 1125
								for _index_0 = 1, #_list_0 do -- 1125
									local child = _list_0[_index_0] -- 1125
									if child.title ~= "Dora" then -- 1125
										_accum_0[_len_0] = child -- 1125
										_len_0 = _len_0 + 1 -- 1125
									end -- 1125
								end -- 1125
								_with_0.children = _accum_0 -- 1125
							end -- 1118
							return _with_0 -- 1116
						end)(), -- 1116
						(function() -- 1126
							if engineDev then -- 1126
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1127
								local _obj_0 = _with_0.children -- 1128
								_obj_0[#_obj_0 + 1] = { -- 1129
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1129
									dir = false, -- 1130
									builtin = true, -- 1131
									title = "init.yue" -- 1132
								} -- 1128
								return _with_0 -- 1127
							end -- 1126
						end)() -- 1126
					} -- 1107
				} -- 1102
			} -- 1136
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1136
			local _idx_0 = #_tab_0 + 1 -- 1136
			for _index_0 = 1, #_obj_0 do -- 1136
				local _value_0 = _obj_0[_index_0] -- 1136
				_tab_0[_idx_0] = _value_0 -- 1136
				_idx_0 = _idx_0 + 1 -- 1136
			end -- 1136
			return _tab_0 -- 1102
		end)() -- 1101
	} -- 1096
end) -- 1033
HttpServer:postSchedule("/run", function(req) -- 1140
	do -- 1141
		local _type_0 = type(req) -- 1141
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1141
		if _tab_0 then -- 1141
			local file -- 1141
			do -- 1141
				local _obj_0 = req.body -- 1141
				local _type_1 = type(_obj_0) -- 1141
				if "table" == _type_1 or "userdata" == _type_1 then -- 1141
					file = _obj_0.file -- 1141
				end -- 1141
			end -- 1141
			local asProj -- 1141
			do -- 1141
				local _obj_0 = req.body -- 1141
				local _type_1 = type(_obj_0) -- 1141
				if "table" == _type_1 or "userdata" == _type_1 then -- 1141
					asProj = _obj_0.asProj -- 1141
				end -- 1141
			end -- 1141
			if file ~= nil and asProj ~= nil then -- 1141
				if not Content:isAbsolutePath(file) then -- 1142
					local devFile = Path(Content.writablePath, file) -- 1143
					if Content:exist(devFile) then -- 1144
						file = devFile -- 1144
					end -- 1144
				end -- 1142
				local Entry = require("Script.Dev.Entry") -- 1145
				local workDir -- 1146
				if asProj then -- 1147
					workDir = getProjectDirFromFile(file) -- 1148
					if workDir then -- 1148
						Entry.allClear() -- 1149
						local target = Path(workDir, "init") -- 1150
						local success, err = Entry.enterEntryAsync({ -- 1151
							entryName = "Project", -- 1151
							fileName = target -- 1151
						}) -- 1151
						target = Path:getName(Path:getPath(target)) -- 1152
						return { -- 1153
							success = success, -- 1153
							target = target, -- 1153
							err = err -- 1153
						} -- 1153
					end -- 1148
				else -- 1155
					workDir = getProjectDirFromFile(file) -- 1155
				end -- 1147
				Entry.allClear() -- 1156
				file = Path:replaceExt(file, "") -- 1157
				local success, err = Entry.enterEntryAsync({ -- 1159
					entryName = Path:getName(file), -- 1159
					fileName = file, -- 1160
					workDir = workDir -- 1161
				}) -- 1158
				return { -- 1162
					success = success, -- 1162
					err = err -- 1162
				} -- 1162
			end -- 1141
		end -- 1141
	end -- 1141
	return { -- 1140
		success = false -- 1140
	} -- 1140
end) -- 1140
HttpServer:postSchedule("/stop", function() -- 1164
	local Entry = require("Script.Dev.Entry") -- 1165
	return { -- 1166
		success = Entry.stop() -- 1166
	} -- 1166
end) -- 1164
local minifyAsync -- 1168
minifyAsync = function(sourcePath, minifyPath) -- 1168
	if not Content:exist(sourcePath) then -- 1169
		return -- 1169
	end -- 1169
	local Entry = require("Script.Dev.Entry") -- 1170
	local errors = { } -- 1171
	local files = Entry.getAllFiles(sourcePath, { -- 1172
		"lua" -- 1172
	}, true) -- 1172
	do -- 1173
		local _accum_0 = { } -- 1173
		local _len_0 = 1 -- 1173
		for _index_0 = 1, #files do -- 1173
			local file = files[_index_0] -- 1173
			if file:sub(1, 1) ~= '.' then -- 1173
				_accum_0[_len_0] = file -- 1173
				_len_0 = _len_0 + 1 -- 1173
			end -- 1173
		end -- 1173
		files = _accum_0 -- 1173
	end -- 1173
	local paths -- 1174
	do -- 1174
		local _tbl_0 = { } -- 1174
		for _index_0 = 1, #files do -- 1174
			local file = files[_index_0] -- 1174
			_tbl_0[Path:getPath(file)] = true -- 1174
		end -- 1174
		paths = _tbl_0 -- 1174
	end -- 1174
	for path in pairs(paths) do -- 1175
		Content:mkdir(Path(minifyPath, path)) -- 1175
	end -- 1175
	local _ <close> = setmetatable({ }, { -- 1176
		__close = function() -- 1176
			package.loaded["luaminify.FormatMini"] = nil -- 1177
			package.loaded["luaminify.ParseLua"] = nil -- 1178
			package.loaded["luaminify.Scope"] = nil -- 1179
			package.loaded["luaminify.Util"] = nil -- 1180
		end -- 1176
	}) -- 1176
	local FormatMini -- 1181
	do -- 1181
		local _obj_0 = require("luaminify") -- 1181
		FormatMini = _obj_0.FormatMini -- 1181
	end -- 1181
	local fileCount = #files -- 1182
	local count = 0 -- 1183
	for _index_0 = 1, #files do -- 1184
		local file = files[_index_0] -- 1184
		thread(function() -- 1185
			local _ <close> = setmetatable({ }, { -- 1186
				__close = function() -- 1186
					count = count + 1 -- 1186
				end -- 1186
			}) -- 1186
			local input = Path(sourcePath, file) -- 1187
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1188
			if Content:exist(input) then -- 1189
				local sourceCodes = Content:loadAsync(input) -- 1190
				local res, err = FormatMini(sourceCodes) -- 1191
				if res then -- 1192
					Content:saveAsync(output, res) -- 1193
					return print("Minify " .. tostring(file)) -- 1194
				else -- 1196
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1196
				end -- 1192
			else -- 1198
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1198
			end -- 1189
		end) -- 1185
		sleep() -- 1199
	end -- 1184
	wait(function() -- 1200
		return count == fileCount -- 1200
	end) -- 1200
	if #errors > 0 then -- 1201
		print(table.concat(errors, '\n')) -- 1202
	end -- 1201
	print("Obfuscation done.") -- 1203
	return files -- 1204
end -- 1168
local zipping = false -- 1206
HttpServer:postSchedule("/zip", function(req) -- 1208
	do -- 1209
		local _type_0 = type(req) -- 1209
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1209
		if _tab_0 then -- 1209
			local path -- 1209
			do -- 1209
				local _obj_0 = req.body -- 1209
				local _type_1 = type(_obj_0) -- 1209
				if "table" == _type_1 or "userdata" == _type_1 then -- 1209
					path = _obj_0.path -- 1209
				end -- 1209
			end -- 1209
			local zipFile -- 1209
			do -- 1209
				local _obj_0 = req.body -- 1209
				local _type_1 = type(_obj_0) -- 1209
				if "table" == _type_1 or "userdata" == _type_1 then -- 1209
					zipFile = _obj_0.zipFile -- 1209
				end -- 1209
			end -- 1209
			local obfuscated -- 1209
			do -- 1209
				local _obj_0 = req.body -- 1209
				local _type_1 = type(_obj_0) -- 1209
				if "table" == _type_1 or "userdata" == _type_1 then -- 1209
					obfuscated = _obj_0.obfuscated -- 1209
				end -- 1209
			end -- 1209
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1209
				if zipping then -- 1210
					goto failed -- 1210
				end -- 1210
				zipping = true -- 1211
				local _ <close> = setmetatable({ }, { -- 1212
					__close = function() -- 1212
						zipping = false -- 1212
					end -- 1212
				}) -- 1212
				if not Content:exist(path) then -- 1213
					goto failed -- 1213
				end -- 1213
				Content:mkdir(Path:getPath(zipFile)) -- 1214
				if obfuscated then -- 1215
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1216
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1217
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1218
					Content:remove(scriptPath) -- 1219
					Content:remove(obfuscatedPath) -- 1220
					Content:remove(tempPath) -- 1221
					Content:mkdir(scriptPath) -- 1222
					Content:mkdir(obfuscatedPath) -- 1223
					Content:mkdir(tempPath) -- 1224
					if not Content:copyAsync(path, tempPath) then -- 1225
						goto failed -- 1225
					end -- 1225
					local Entry = require("Script.Dev.Entry") -- 1226
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1227
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1228
						"tl", -- 1228
						"yue", -- 1228
						"lua", -- 1228
						"ts", -- 1228
						"tsx", -- 1228
						"vs", -- 1228
						"bl", -- 1228
						"xml", -- 1228
						"wa", -- 1228
						"mod" -- 1228
					}, true) -- 1228
					for _index_0 = 1, #scriptFiles do -- 1229
						local file = scriptFiles[_index_0] -- 1229
						Content:remove(Path(tempPath, file)) -- 1230
					end -- 1229
					for _index_0 = 1, #luaFiles do -- 1231
						local file = luaFiles[_index_0] -- 1231
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1232
					end -- 1231
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1233
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1234
					end) then -- 1233
						goto failed -- 1233
					end -- 1233
					return { -- 1235
						success = true -- 1235
					} -- 1235
				else -- 1237
					return { -- 1237
						success = Content:zipAsync(path, zipFile, function(file) -- 1237
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1238
						end) -- 1237
					} -- 1237
				end -- 1215
			end -- 1209
		end -- 1209
	end -- 1209
	::failed:: -- 1239
	return { -- 1208
		success = false -- 1208
	} -- 1208
end) -- 1208
HttpServer:postSchedule("/unzip", function(req) -- 1241
	do -- 1242
		local _type_0 = type(req) -- 1242
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1242
		if _tab_0 then -- 1242
			local zipFile -- 1242
			do -- 1242
				local _obj_0 = req.body -- 1242
				local _type_1 = type(_obj_0) -- 1242
				if "table" == _type_1 or "userdata" == _type_1 then -- 1242
					zipFile = _obj_0.zipFile -- 1242
				end -- 1242
			end -- 1242
			local path -- 1242
			do -- 1242
				local _obj_0 = req.body -- 1242
				local _type_1 = type(_obj_0) -- 1242
				if "table" == _type_1 or "userdata" == _type_1 then -- 1242
					path = _obj_0.path -- 1242
				end -- 1242
			end -- 1242
			if zipFile ~= nil and path ~= nil then -- 1242
				return { -- 1243
					success = Content:unzipAsync(zipFile, path, function(file) -- 1243
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1244
					end) -- 1243
				} -- 1243
			end -- 1242
		end -- 1242
	end -- 1242
	return { -- 1241
		success = false -- 1241
	} -- 1241
end) -- 1241
HttpServer:post("/editing-info", function(req) -- 1246
	local Entry = require("Script.Dev.Entry") -- 1247
	local config = Entry.getConfig() -- 1248
	local _type_0 = type(req) -- 1249
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1249
	local _match_0 = false -- 1249
	if _tab_0 then -- 1249
		local editingInfo -- 1249
		do -- 1249
			local _obj_0 = req.body -- 1249
			local _type_1 = type(_obj_0) -- 1249
			if "table" == _type_1 or "userdata" == _type_1 then -- 1249
				editingInfo = _obj_0.editingInfo -- 1249
			end -- 1249
		end -- 1249
		if editingInfo ~= nil then -- 1249
			_match_0 = true -- 1249
			config.editingInfo = editingInfo -- 1250
			return { -- 1251
				success = true -- 1251
			} -- 1251
		end -- 1249
	end -- 1249
	if not _match_0 then -- 1249
		if not (config.editingInfo ~= nil) then -- 1253
			local folder -- 1254
			if App.locale:match('^zh') then -- 1254
				folder = 'zh-Hans' -- 1254
			else -- 1254
				folder = 'en' -- 1254
			end -- 1254
			config.editingInfo = json.encode({ -- 1256
				index = 0, -- 1256
				files = { -- 1258
					{ -- 1259
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1259
						title = "welcome.md" -- 1260
					} -- 1258
				} -- 1257
			}) -- 1255
		end -- 1253
		return { -- 1264
			success = true, -- 1264
			editingInfo = config.editingInfo -- 1264
		} -- 1264
	end -- 1249
end) -- 1246
HttpServer:post("/command", function(req) -- 1266
	do -- 1267
		local _type_0 = type(req) -- 1267
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1267
		if _tab_0 then -- 1267
			local code -- 1267
			do -- 1267
				local _obj_0 = req.body -- 1267
				local _type_1 = type(_obj_0) -- 1267
				if "table" == _type_1 or "userdata" == _type_1 then -- 1267
					code = _obj_0.code -- 1267
				end -- 1267
			end -- 1267
			local log -- 1267
			do -- 1267
				local _obj_0 = req.body -- 1267
				local _type_1 = type(_obj_0) -- 1267
				if "table" == _type_1 or "userdata" == _type_1 then -- 1267
					log = _obj_0.log -- 1267
				end -- 1267
			end -- 1267
			if code ~= nil and log ~= nil then -- 1267
				emit("AppCommand", code, log) -- 1268
				return { -- 1269
					success = true -- 1269
				} -- 1269
			end -- 1267
		end -- 1267
	end -- 1267
	return { -- 1266
		success = false -- 1266
	} -- 1266
end) -- 1266
HttpServer:post("/log/save", function() -- 1271
	local folder = ".download" -- 1272
	local fullLogFile = "dora_full_logs.txt" -- 1273
	local fullFolder = Path(Content.writablePath, folder) -- 1274
	Content:mkdir(fullFolder) -- 1275
	local logPath = Path(fullFolder, fullLogFile) -- 1276
	if App:saveLog(logPath) then -- 1277
		return { -- 1278
			success = true, -- 1278
			path = Path(folder, fullLogFile) -- 1278
		} -- 1278
	end -- 1277
	return { -- 1271
		success = false -- 1271
	} -- 1271
end) -- 1271
HttpServer:post("/yarn/check", function(req) -- 1280
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
				local jsonObject = json.decode(code) -- 1283
				if jsonObject then -- 1283
					local errors = { } -- 1284
					local _list_0 = jsonObject.nodes -- 1285
					for _index_0 = 1, #_list_0 do -- 1285
						local node = _list_0[_index_0] -- 1285
						local title, body = node.title, node.body -- 1286
						local luaCode, err = yarncompile(body) -- 1287
						if not luaCode then -- 1287
							errors[#errors + 1] = title .. ":" .. err -- 1288
						end -- 1287
					end -- 1285
					return { -- 1289
						success = true, -- 1289
						syntaxError = table.concat(errors, "\n\n") -- 1289
					} -- 1289
				end -- 1283
			end -- 1282
		end -- 1282
	end -- 1282
	return { -- 1280
		success = false -- 1280
	} -- 1280
end) -- 1280
HttpServer:post("/yarn/check-file", function(req) -- 1291
	local yarncompile = require("yarncompile") -- 1292
	do -- 1293
		local _type_0 = type(req) -- 1293
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1293
		if _tab_0 then -- 1293
			local code -- 1293
			do -- 1293
				local _obj_0 = req.body -- 1293
				local _type_1 = type(_obj_0) -- 1293
				if "table" == _type_1 or "userdata" == _type_1 then -- 1293
					code = _obj_0.code -- 1293
				end -- 1293
			end -- 1293
			if code ~= nil then -- 1293
				local res, _, err = yarncompile(code, true) -- 1294
				if not res then -- 1294
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1295
					return { -- 1296
						success = false, -- 1296
						message = message, -- 1296
						line = line, -- 1296
						column = column, -- 1296
						node = node -- 1296
					} -- 1296
				end -- 1294
			end -- 1293
		end -- 1293
	end -- 1293
	return { -- 1291
		success = true -- 1291
	} -- 1291
end) -- 1291
local getWaProjectDirFromFile -- 1298
getWaProjectDirFromFile = function(file) -- 1298
	local writablePath = Content.writablePath -- 1299
	local parent, current -- 1300
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1300
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1301
	else -- 1303
		parent, current = nil, nil -- 1303
	end -- 1300
	if not current then -- 1304
		return nil -- 1304
	end -- 1304
	repeat -- 1305
		current = Path:getPath(current) -- 1306
		if current == "" then -- 1307
			break -- 1307
		end -- 1307
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1308
		for _index_0 = 1, #_list_0 do -- 1308
			local f = _list_0[_index_0] -- 1308
			if Path:getFilename(f):lower() == "wa.mod" then -- 1309
				return Path(parent, current, Path:getPath(f)) -- 1310
			end -- 1309
		end -- 1308
	until false -- 1305
	return nil -- 1312
end -- 1298
HttpServer:postSchedule("/wa/update_dora", function(req) -- 1314
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
			if path ~= nil then -- 1315
				local projDir = getWaProjectDirFromFile(path) -- 1316
				if projDir then -- 1316
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 1317
					if not Content:exist(sourceDoraPath) then -- 1318
						return { -- 1319
							success = false, -- 1319
							message = "missing dora template" -- 1319
						} -- 1319
					end -- 1318
					local targetVendorPath = Path(projDir, "vendor") -- 1320
					local targetDoraPath = Path(targetVendorPath, "dora") -- 1321
					if not Content:exist(targetVendorPath) then -- 1322
						if not Content:mkdir(targetVendorPath) then -- 1323
							return { -- 1324
								success = false, -- 1324
								message = "failed to create vendor folder" -- 1324
							} -- 1324
						end -- 1323
					elseif not Content:isdir(targetVendorPath) then -- 1325
						return { -- 1326
							success = false, -- 1326
							message = "vendor path is not a folder" -- 1326
						} -- 1326
					end -- 1322
					if Content:exist(targetDoraPath) then -- 1327
						if not Content:remove(targetDoraPath) then -- 1328
							return { -- 1329
								success = false, -- 1329
								message = "failed to remove old dora" -- 1329
							} -- 1329
						end -- 1328
					end -- 1327
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 1330
						return { -- 1331
							success = false, -- 1331
							message = "failed to copy dora" -- 1331
						} -- 1331
					end -- 1330
					return { -- 1332
						success = true -- 1332
					} -- 1332
				else -- 1334
					return { -- 1334
						success = false, -- 1334
						message = 'Wa file needs a project' -- 1334
					} -- 1334
				end -- 1316
			end -- 1315
		end -- 1315
	end -- 1315
	return { -- 1314
		success = false, -- 1314
		message = "invalid call" -- 1314
	} -- 1314
end) -- 1314
HttpServer:postSchedule("/wa/build", function(req) -- 1336
	do -- 1337
		local _type_0 = type(req) -- 1337
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1337
		if _tab_0 then -- 1337
			local path -- 1337
			do -- 1337
				local _obj_0 = req.body -- 1337
				local _type_1 = type(_obj_0) -- 1337
				if "table" == _type_1 or "userdata" == _type_1 then -- 1337
					path = _obj_0.path -- 1337
				end -- 1337
			end -- 1337
			if path ~= nil then -- 1337
				local projDir = getWaProjectDirFromFile(path) -- 1338
				if projDir then -- 1338
					local message = Wasm:buildWaAsync(projDir) -- 1339
					if message == "" then -- 1340
						return { -- 1341
							success = true -- 1341
						} -- 1341
					else -- 1343
						return { -- 1343
							success = false, -- 1343
							message = message -- 1343
						} -- 1343
					end -- 1340
				else -- 1345
					return { -- 1345
						success = false, -- 1345
						message = 'Wa file needs a project' -- 1345
					} -- 1345
				end -- 1338
			end -- 1337
		end -- 1337
	end -- 1337
	return { -- 1346
		success = false, -- 1346
		message = 'failed to build' -- 1346
	} -- 1346
end) -- 1336
HttpServer:postSchedule("/wa/format", function(req) -- 1348
	do -- 1349
		local _type_0 = type(req) -- 1349
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1349
		if _tab_0 then -- 1349
			local file -- 1349
			do -- 1349
				local _obj_0 = req.body -- 1349
				local _type_1 = type(_obj_0) -- 1349
				if "table" == _type_1 or "userdata" == _type_1 then -- 1349
					file = _obj_0.file -- 1349
				end -- 1349
			end -- 1349
			if file ~= nil then -- 1349
				local code = Wasm:formatWaAsync(file) -- 1350
				if code == "" then -- 1351
					return { -- 1352
						success = false -- 1352
					} -- 1352
				else -- 1354
					return { -- 1354
						success = true, -- 1354
						code = code -- 1354
					} -- 1354
				end -- 1351
			end -- 1349
		end -- 1349
	end -- 1349
	return { -- 1355
		success = false -- 1355
	} -- 1355
end) -- 1348
HttpServer:postSchedule("/wa/create", function(req) -- 1357
	do -- 1358
		local _type_0 = type(req) -- 1358
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1358
		if _tab_0 then -- 1358
			local path -- 1358
			do -- 1358
				local _obj_0 = req.body -- 1358
				local _type_1 = type(_obj_0) -- 1358
				if "table" == _type_1 or "userdata" == _type_1 then -- 1358
					path = _obj_0.path -- 1358
				end -- 1358
			end -- 1358
			if path ~= nil then -- 1358
				if not Content:exist(Path:getPath(path)) then -- 1359
					return { -- 1360
						success = false, -- 1360
						message = "target path not existed" -- 1360
					} -- 1360
				end -- 1359
				if Content:exist(path) then -- 1361
					return { -- 1362
						success = false, -- 1362
						message = "target project folder existed" -- 1362
					} -- 1362
				end -- 1361
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1363
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1364
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1365
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1366
					return { -- 1369
						success = false, -- 1369
						message = "missing template project" -- 1369
					} -- 1369
				end -- 1366
				if not Content:mkdir(path) then -- 1370
					return { -- 1371
						success = false, -- 1371
						message = "failed to create project folder" -- 1371
					} -- 1371
				end -- 1370
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1372
					Content:remove(path) -- 1373
					return { -- 1374
						success = false, -- 1374
						message = "failed to copy template" -- 1374
					} -- 1374
				end -- 1372
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1375
					Content:remove(path) -- 1376
					return { -- 1377
						success = false, -- 1377
						message = "failed to copy template" -- 1377
					} -- 1377
				end -- 1375
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1378
					Content:remove(path) -- 1379
					return { -- 1380
						success = false, -- 1380
						message = "failed to copy template" -- 1380
					} -- 1380
				end -- 1378
				return { -- 1381
					success = true -- 1381
				} -- 1381
			end -- 1358
		end -- 1358
	end -- 1358
	return { -- 1357
		success = false, -- 1357
		message = "invalid call" -- 1357
	} -- 1357
end) -- 1357
local _anon_func_5 = function(path) -- 1390
	local _val_0 = Path:getExt(path) -- 1390
	return "ts" == _val_0 or "tsx" == _val_0 -- 1390
end -- 1390
local _anon_func_6 = function(f) -- 1420
	local _val_0 = Path:getExt(f) -- 1420
	return "ts" == _val_0 or "tsx" == _val_0 -- 1420
end -- 1420
HttpServer:postSchedule("/ts/build", function(req) -- 1383
	do -- 1384
		local _type_0 = type(req) -- 1384
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1384
		if _tab_0 then -- 1384
			local path -- 1384
			do -- 1384
				local _obj_0 = req.body -- 1384
				local _type_1 = type(_obj_0) -- 1384
				if "table" == _type_1 or "userdata" == _type_1 then -- 1384
					path = _obj_0.path -- 1384
				end -- 1384
			end -- 1384
			if path ~= nil then -- 1384
				if HttpServer.wsConnectionCount == 0 then -- 1385
					return { -- 1386
						success = false, -- 1386
						message = "Web IDE not connected" -- 1386
					} -- 1386
				end -- 1385
				if not Content:exist(path) then -- 1387
					return { -- 1388
						success = false, -- 1388
						message = "path not existed" -- 1388
					} -- 1388
				end -- 1387
				if not Content:isdir(path) then -- 1389
					if not (_anon_func_5(path)) then -- 1390
						return { -- 1391
							success = false, -- 1391
							message = "expecting a TypeScript file" -- 1391
						} -- 1391
					end -- 1390
					local messages = { } -- 1392
					local content = Content:load(path) -- 1393
					if not content then -- 1394
						return { -- 1395
							success = false, -- 1395
							message = "failed to read file" -- 1395
						} -- 1395
					end -- 1394
					emit("AppWS", "Send", json.encode({ -- 1396
						name = "UpdateFile", -- 1396
						file = path, -- 1396
						exists = true, -- 1396
						content = content -- 1396
					})) -- 1396
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1397
						local done = false -- 1398
						do -- 1399
							local _with_0 = Node() -- 1399
							_with_0:gslot("AppWS", function(event) -- 1400
								if event.type == "Receive" then -- 1401
									_with_0:removeFromParent() -- 1402
									local res = json.decode(event.msg) -- 1403
									if res then -- 1403
										if res.name == "TranspileTS" then -- 1404
											if res.success then -- 1405
												local luaFile = Path:replaceExt(path, "lua") -- 1406
												Content:save(luaFile, res.luaCode) -- 1407
												messages[#messages + 1] = { -- 1408
													success = true, -- 1408
													file = path -- 1408
												} -- 1408
											else -- 1410
												messages[#messages + 1] = { -- 1410
													success = false, -- 1410
													file = path, -- 1410
													message = res.message -- 1410
												} -- 1410
											end -- 1405
											done = true -- 1411
										end -- 1404
									end -- 1403
								end -- 1401
							end) -- 1400
						end -- 1399
						emit("AppWS", "Send", json.encode({ -- 1412
							name = "TranspileTS", -- 1412
							file = path, -- 1412
							content = content -- 1412
						})) -- 1412
						wait(function() -- 1413
							return done -- 1413
						end) -- 1413
					end -- 1397
					return { -- 1414
						success = true, -- 1414
						messages = messages -- 1414
					} -- 1414
				else -- 1416
					local files = Content:getAllFiles(path) -- 1416
					local fileData = { } -- 1417
					local messages = { } -- 1418
					for _index_0 = 1, #files do -- 1419
						local f = files[_index_0] -- 1419
						if not (_anon_func_6(f)) then -- 1420
							goto _continue_0 -- 1420
						end -- 1420
						local file = Path(path, f) -- 1421
						local content = Content:load(file) -- 1422
						if content then -- 1422
							fileData[file] = content -- 1423
							emit("AppWS", "Send", json.encode({ -- 1424
								name = "UpdateFile", -- 1424
								file = file, -- 1424
								exists = true, -- 1424
								content = content -- 1424
							})) -- 1424
						else -- 1426
							messages[#messages + 1] = { -- 1426
								success = false, -- 1426
								file = file, -- 1426
								message = "failed to read file" -- 1426
							} -- 1426
						end -- 1422
						::_continue_0:: -- 1420
					end -- 1419
					for file, content in pairs(fileData) do -- 1427
						if "d" == Path:getExt(Path:getName(file)) then -- 1428
							goto _continue_1 -- 1428
						end -- 1428
						local done = false -- 1429
						do -- 1430
							local _with_0 = Node() -- 1430
							_with_0:gslot("AppWS", function(event) -- 1431
								if event.type == "Receive" then -- 1432
									_with_0:removeFromParent() -- 1433
									local res = json.decode(event.msg) -- 1434
									if res then -- 1434
										if res.name == "TranspileTS" then -- 1435
											if res.success then -- 1436
												local luaFile = Path:replaceExt(file, "lua") -- 1437
												Content:save(luaFile, res.luaCode) -- 1438
												messages[#messages + 1] = { -- 1439
													success = true, -- 1439
													file = file -- 1439
												} -- 1439
											else -- 1441
												messages[#messages + 1] = { -- 1441
													success = false, -- 1441
													file = file, -- 1441
													message = res.message -- 1441
												} -- 1441
											end -- 1436
											done = true -- 1442
										end -- 1435
									end -- 1434
								end -- 1432
							end) -- 1431
						end -- 1430
						emit("AppWS", "Send", json.encode({ -- 1443
							name = "TranspileTS", -- 1443
							file = file, -- 1443
							content = content -- 1443
						})) -- 1443
						wait(function() -- 1444
							return done -- 1444
						end) -- 1444
						::_continue_1:: -- 1428
					end -- 1427
					return { -- 1445
						success = true, -- 1445
						messages = messages -- 1445
					} -- 1445
				end -- 1389
			end -- 1384
		end -- 1384
	end -- 1384
	return { -- 1383
		success = false -- 1383
	} -- 1383
end) -- 1383
HttpServer:post("/download", function(req) -- 1447
	do -- 1448
		local _type_0 = type(req) -- 1448
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1448
		if _tab_0 then -- 1448
			local url -- 1448
			do -- 1448
				local _obj_0 = req.body -- 1448
				local _type_1 = type(_obj_0) -- 1448
				if "table" == _type_1 or "userdata" == _type_1 then -- 1448
					url = _obj_0.url -- 1448
				end -- 1448
			end -- 1448
			local target -- 1448
			do -- 1448
				local _obj_0 = req.body -- 1448
				local _type_1 = type(_obj_0) -- 1448
				if "table" == _type_1 or "userdata" == _type_1 then -- 1448
					target = _obj_0.target -- 1448
				end -- 1448
			end -- 1448
			if url ~= nil and target ~= nil then -- 1448
				local Entry = require("Script.Dev.Entry") -- 1449
				Entry.downloadFile(url, target) -- 1450
				return { -- 1451
					success = true -- 1451
				} -- 1451
			end -- 1448
		end -- 1448
	end -- 1448
	return { -- 1447
		success = false -- 1447
	} -- 1447
end) -- 1447
local status = { } -- 1453
_module_0 = status -- 1454
status.buildAsync = function(path) -- 1456
	if not Content:exist(path) then -- 1457
		return { -- 1458
			success = false, -- 1458
			file = path, -- 1458
			message = "file not existed" -- 1458
		} -- 1458
	end -- 1457
	do -- 1459
		local _exp_0 = Path:getExt(path) -- 1459
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1459
			if '' == Path:getExt(Path:getName(path)) then -- 1460
				local content = Content:loadAsync(path) -- 1461
				if content then -- 1461
					local resultCodes, err = compileFileAsync(path, content) -- 1462
					if resultCodes then -- 1462
						return { -- 1463
							success = true, -- 1463
							file = path -- 1463
						} -- 1463
					else -- 1465
						return { -- 1465
							success = false, -- 1465
							file = path, -- 1465
							message = err -- 1465
						} -- 1465
					end -- 1462
				end -- 1461
			end -- 1460
		elseif "lua" == _exp_0 then -- 1466
			local content = Content:loadAsync(path) -- 1467
			if content then -- 1467
				do -- 1468
					local isTIC80 = CheckTIC80Code(content) -- 1468
					if isTIC80 then -- 1468
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1469
					end -- 1468
				end -- 1468
				local success, info -- 1470
				do -- 1470
					local _obj_0 = luaCheck(path, content) -- 1470
					success, info = _obj_0.success, _obj_0.info -- 1470
				end -- 1470
				if success then -- 1471
					return { -- 1472
						success = true, -- 1472
						file = path -- 1472
					} -- 1472
				elseif info and #info > 0 then -- 1473
					local messages = { } -- 1474
					for _index_0 = 1, #info do -- 1475
						local _des_0 = info[_index_0] -- 1475
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 1475
						local lineText = "" -- 1476
						if line then -- 1477
							local currentLine = 1 -- 1478
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1479
								if currentLine == line then -- 1480
									lineText = text -- 1481
									break -- 1482
								end -- 1480
								currentLine = currentLine + 1 -- 1483
							end -- 1479
						end -- 1477
						if line then -- 1484
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1485
						else -- 1487
							messages[#messages + 1] = message -- 1487
						end -- 1484
					end -- 1475
					return { -- 1488
						success = false, -- 1488
						file = path, -- 1488
						message = table.concat(messages, "\n") -- 1488
					} -- 1488
				else -- 1490
					return { -- 1490
						success = false, -- 1490
						file = path, -- 1490
						message = "lua check failed" -- 1490
					} -- 1490
				end -- 1471
			end -- 1467
		elseif "yarn" == _exp_0 then -- 1491
			local content = Content:loadAsync(path) -- 1492
			if content then -- 1492
				local res, _, err = yarncompile(content, true) -- 1493
				if res then -- 1493
					return { -- 1494
						success = true, -- 1494
						file = path -- 1494
					} -- 1494
				else -- 1496
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1496
					local lineText = "" -- 1497
					if line then -- 1498
						local currentLine = 1 -- 1499
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1500
							if currentLine == line then -- 1501
								lineText = text -- 1502
								break -- 1503
							end -- 1501
							currentLine = currentLine + 1 -- 1504
						end -- 1500
					end -- 1498
					if node ~= "" then -- 1505
						node = "node: " .. tostring(node) .. ", " -- 1506
					else -- 1507
						node = "" -- 1507
					end -- 1505
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1508
					return { -- 1509
						success = false, -- 1509
						file = path, -- 1509
						message = message -- 1509
					} -- 1509
				end -- 1493
			end -- 1492
		end -- 1459
	end -- 1459
	return { -- 1510
		success = false, -- 1510
		file = path, -- 1510
		message = "invalid file to build" -- 1510
	} -- 1510
end -- 1456
thread(function() -- 1512
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1513
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1514
	if Content:exist(doraWeb) then -- 1515
		local needReload -- 1516
		if Content:exist(doraReady) then -- 1516
			needReload = App.version ~= Content:load(doraReady) -- 1517
		else -- 1518
			needReload = true -- 1518
		end -- 1516
		if needReload then -- 1519
			Content:remove(Path(Content.appPath, ".www")) -- 1520
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1521
			Content:save(doraReady, App.version) -- 1525
			print("Dora Dora is ready!") -- 1526
		end -- 1519
	end -- 1515
	if HttpServer:start(8866) then -- 1527
		local localIP = HttpServer.localIP -- 1528
		if localIP == "" then -- 1529
			localIP = "localhost" -- 1529
		end -- 1529
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1530
		return HttpServer:startWS(8868) -- 1531
	else -- 1533
		status.url = nil -- 1533
		return print("8866 Port not available!") -- 1534
	end -- 1527
end) -- 1512
return _module_0 -- 1
