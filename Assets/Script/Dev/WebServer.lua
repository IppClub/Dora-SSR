-- [yue]: Script/Dev/WebServer.yue
local _module_0 = nil -- 1
local _ENV = Dora -- 9
local HttpServer <const> = HttpServer -- 10
local Path <const> = Path -- 10
local Content <const> = Content -- 10
local string <const> = string -- 10
local math <const> = math -- 10
local table <const> = table -- 10
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
local AuthSession = require("Script.Dev.AuthSession") -- 11
HttpServer:stop() -- 12
HttpServer.wwwPath = Path(Content.appPath, ".www") -- 14
HttpServer.authRequired = true -- 16
HttpServer.authToken = "" -- 17
local authFailedCount = 0 -- 19
local authLockedUntil = 0.0 -- 20
local PendingTTL = 60 -- 21
local genAuthToken -- 22
genAuthToken = function() -- 22
	local parts = { } -- 23
	for _ = 1, 4 do -- 24
		parts[#parts + 1] = string.format("%08x", math.random(0, 0x7fffffff)) -- 25
	end -- 24
	return table.concat(parts) -- 26
end -- 22
local genSessionId -- 28
genSessionId = function() -- 28
	local parts = { } -- 29
	for _ = 1, 2 do -- 30
		parts[#parts + 1] = string.format("%08x", math.random(0, 0x7fffffff)) -- 31
	end -- 30
	return table.concat(parts) -- 32
end -- 28
local genConfirmCode -- 34
genConfirmCode = function() -- 34
	return string.format("%04d", math.random(0, 9999)) -- 35
end -- 34
HttpServer:post("/auth", function(req) -- 37
	local Entry = require("Script.Dev.Entry") -- 38
	local authCode = Entry.getAuthCode() -- 39
	local now = os.time() -- 40
	if now < authLockedUntil then -- 41
		return { -- 42
			success = false, -- 42
			message = "locked", -- 42
			retryAfter = authLockedUntil - now -- 42
		} -- 42
	end -- 41
	local code = nil -- 43
	do -- 45
		local _type_0 = type(req) -- 45
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 45
		if _tab_0 then -- 45
			do -- 45
				local _obj_0 = req.body -- 45
				local _type_1 = type(_obj_0) -- 45
				if "table" == _type_1 or "userdata" == _type_1 then -- 45
					code = _obj_0.code -- 45
				end -- 45
			end -- 45
			if code ~= nil then -- 45
				code = code -- 46
			end -- 45
		end -- 44
	end -- 44
	if code and tostring(code) == authCode then -- 47
		authFailedCount = 0 -- 48
		Entry.invalidateAuthCode() -- 49
		local pending = AuthSession.getPending() -- 50
		if pending and now < pending.expiresAt and not pending.approved then -- 51
			return { -- 52
				success = true, -- 52
				pending = true, -- 52
				sessionId = pending.sessionId, -- 52
				confirmCode = pending.confirmCode, -- 52
				expiresIn = pending.expiresAt - now -- 52
			} -- 52
		end -- 51
		local sessionId = genSessionId() -- 53
		local confirmCode = genConfirmCode() -- 54
		AuthSession.beginPending(sessionId, confirmCode, now + PendingTTL, PendingTTL) -- 55
		return { -- 56
			success = true, -- 56
			pending = true, -- 56
			sessionId = sessionId, -- 56
			confirmCode = confirmCode, -- 56
			expiresIn = PendingTTL -- 56
		} -- 56
	else -- 58
		authFailedCount = authFailedCount + 1 -- 58
		if authFailedCount >= 3 then -- 59
			authFailedCount = 0 -- 60
			authLockedUntil = now + 30 -- 61
			return { -- 62
				success = false, -- 62
				message = "locked", -- 62
				retryAfter = 30 -- 62
			} -- 62
		end -- 59
		return { -- 63
			success = false, -- 63
			message = "invalid code" -- 63
		} -- 63
	end -- 47
end) -- 37
HttpServer:post("/auth/confirm", function(req) -- 65
	local now = os.time() -- 66
	local sessionId = nil -- 67
	do -- 69
		local _type_0 = type(req) -- 69
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 69
		if _tab_0 then -- 69
			do -- 69
				local _obj_0 = req.body -- 69
				local _type_1 = type(_obj_0) -- 69
				if "table" == _type_1 or "userdata" == _type_1 then -- 69
					sessionId = _obj_0.sessionId -- 69
				end -- 69
			end -- 69
			if sessionId ~= nil then -- 69
				sessionId = sessionId -- 70
			end -- 69
		end -- 68
	end -- 68
	if not sessionId then -- 71
		return { -- 72
			success = false, -- 72
			message = "invalid session" -- 72
		} -- 72
	end -- 71
	local pending = AuthSession.getPending() -- 73
	if pending then -- 74
		if pending.sessionId ~= sessionId then -- 75
			return { -- 76
				success = false, -- 76
				message = "invalid session" -- 76
			} -- 76
		end -- 75
		if now >= pending.expiresAt then -- 77
			AuthSession.clearPending() -- 78
			return { -- 79
				success = false, -- 79
				message = "expired" -- 79
			} -- 79
		end -- 77
		if pending.approved then -- 80
			local secret = genAuthToken() -- 81
			HttpServer.authToken = sessionId .. ":" .. secret -- 82
			AuthSession.setSession(sessionId, secret) -- 83
			AuthSession.clearPending() -- 84
			return { -- 85
				success = true, -- 85
				sessionId = sessionId, -- 85
				sessionSecret = secret -- 85
			} -- 85
		end -- 80
		return { -- 86
			success = false, -- 86
			message = "pending", -- 86
			retryAfter = 2 -- 86
		} -- 86
	end -- 74
	return { -- 87
		success = false, -- 87
		message = "invalid session" -- 87
	} -- 87
end) -- 65
local LintYueGlobals, CheckTIC80Code -- 89
do -- 89
	local _obj_0 = require("Utils") -- 89
	LintYueGlobals, CheckTIC80Code = _obj_0.LintYueGlobals, _obj_0.CheckTIC80Code -- 89
end -- 89
local getProjectDirFromFile -- 91
getProjectDirFromFile = function(file) -- 91
	local writablePath, assetPath = Content.writablePath, Content.assetPath -- 54
	local parent, current -- 55
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 55
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 56
	elseif (".." ~= Path:getRelative(file, assetPath):sub(1, 2)) and assetPath == file:sub(1, #assetPath) then -- 57
		local dir = Path(assetPath, "Script") -- 58
		parent, current = dir, Path:getRelative(file, dir) -- 59
	else -- 61
		parent, current = nil, nil -- 61
	end -- 55
	if not current then -- 62
		return nil -- 62
	end -- 62
	repeat -- 63
		current = Path:getPath(current) -- 64
		if current == "" then -- 65
			break -- 65
		end -- 65
		local _list_0 = Content:getFiles(Path(parent, current)) -- 66
		for _index_0 = 1, #_list_0 do -- 66
			local f = _list_0[_index_0] -- 66
			if Path:getName(f):lower() == "init" then -- 67
				return Path(parent, current, Path:getPath(f)) -- 68
			end -- 67
		end -- 66
	until false -- 63
	return nil -- 70
end -- 53
local getSearchPath -- 72
getSearchPath = function(file) -- 72
	do -- 73
		local dir = getProjectDirFromFile(file) -- 73
		if dir then -- 73
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 74
		end -- 73
	end -- 73
	return "" -- 72
end -- 72
local getSearchFolders -- 76
getSearchFolders = function(file) -- 76
	do -- 77
		local dir = getProjectDirFromFile(file) -- 77
		if dir then -- 77
			return { -- 79
				Path(dir, "Script"), -- 79
				dir -- 80
			} -- 78
		end -- 77
	end -- 77
	return { } -- 76
end -- 76
local disabledCheckForLua = { -- 83
	"incompatible number of returns", -- 83
	"unknown", -- 84
	"cannot index", -- 85
	"module not found", -- 86
	"don't know how to resolve", -- 87
	"ContainerItem", -- 88
	"cannot resolve a type", -- 89
	"invalid key", -- 90
	"inconsistent index type", -- 91
	"cannot use operator", -- 92
	"attempting ipairs loop", -- 93
	"expects record or nominal", -- 94
	"variable is not being assigned", -- 95
	"<invalid type>", -- 96
	"<any type>", -- 97
	"using the '#' operator", -- 98
	"can't match a record", -- 99
	"redeclaration of variable", -- 100
	"cannot apply pairs", -- 101
	"not a function", -- 102
	"to%-be%-closed" -- 103
} -- 82
local yueCheck -- 105
yueCheck = function(file, content, lax) -- 105
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 106
	if isTIC80 then -- 107
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 108
	end -- 107
	local searchPath = getSearchPath(file) -- 109
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 110
	local info = { } -- 111
	local globals = { } -- 112
	for _index_0 = 1, #checkResult do -- 113
		local _des_0 = checkResult[_index_0] -- 113
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 113
		if "error" == t then -- 114
			info[#info + 1] = { -- 115
				"syntax", -- 115
				file, -- 115
				line, -- 115
				col, -- 115
				msg -- 115
			} -- 115
		elseif "global" == t then -- 116
			globals[#globals + 1] = { -- 117
				msg, -- 117
				line, -- 117
				col -- 117
			} -- 117
		end -- 114
	end -- 113
	if luaCodes then -- 118
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 119
		if success then -- 120
			if lax then -- 121
				luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 122
				if not (lintResult == "") then -- 123
					lintResult = lintResult .. "\n" -- 123
				end -- 123
				luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 124
			else -- 126
				luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(luaCodes) -- 126
			end -- 121
		else -- 127
			for _index_0 = 1, #lintResult do -- 127
				local _des_0 = lintResult[_index_0] -- 127
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 127
				if isTIC80 and tic80APIs[name] then -- 128
					goto _continue_0 -- 128
				end -- 128
				info[#info + 1] = { -- 129
					"syntax", -- 129
					file, -- 129
					line, -- 129
					col, -- 129
					"invalid global variable" -- 129
				} -- 129
				::_continue_0:: -- 128
			end -- 127
		end -- 120
	end -- 118
	return luaCodes, info -- 130
end -- 105
local luaCheck -- 132
luaCheck = function(file, content) -- 132
	local res, err = load(content, "check") -- 133
	if not res then -- 134
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 135
		return { -- 136
			success = false, -- 136
			info = { -- 136
				{ -- 136
					"syntax", -- 136
					file, -- 136
					tonumber(line), -- 136
					0, -- 136
					msg -- 136
				} -- 136
			} -- 136
		} -- 136
	end -- 134
	local success, info = teal.checkAsync(content, file, true, "") -- 137
	if info then -- 138
		do -- 139
			local _accum_0 = { } -- 139
			local _len_0 = 1 -- 139
			for _index_0 = 1, #info do -- 139
				local item = info[_index_0] -- 139
				local useCheck = true -- 140
				if not item[5]:match("unused") then -- 141
					for _index_1 = 1, #disabledCheckForLua do -- 142
						local check = disabledCheckForLua[_index_1] -- 142
						if item[5]:match(check) then -- 143
							useCheck = false -- 144
						end -- 143
					end -- 142
				end -- 141
				if not useCheck then -- 145
					goto _continue_0 -- 145
				end -- 145
				do -- 146
					local _exp_0 = item[1] -- 146
					if "type" == _exp_0 then -- 147
						item[1] = "warning" -- 148
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 149
						goto _continue_0 -- 150
					end -- 146
				end -- 146
				_accum_0[_len_0] = item -- 151
				_len_0 = _len_0 + 1 -- 140
				::_continue_0:: -- 140
			end -- 139
			info = _accum_0 -- 139
		end -- 139
		if #info == 0 then -- 152
			info = nil -- 153
			success = true -- 154
		end -- 152
	end -- 138
	return { -- 155
		success = success, -- 155
		info = info -- 155
	} -- 155
end -- 132
local luaCheckWithLineInfo -- 157
luaCheckWithLineInfo = function(file, luaCodes) -- 157
	local res = luaCheck(file, luaCodes) -- 158
	local info = { } -- 159
	if not res.success then -- 160
		local current = 1 -- 161
		local lastLine = 1 -- 162
		local lineMap = { } -- 163
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 164
			local num = lineCode:match("--%s*(%d+)%s*$") -- 165
			if num then -- 166
				lastLine = tonumber(num) -- 167
			end -- 166
			lineMap[current] = lastLine -- 168
			current = current + 1 -- 169
		end -- 164
		local _list_0 = res.info -- 170
		for _index_0 = 1, #_list_0 do -- 170
			local item = _list_0[_index_0] -- 170
			item[3] = lineMap[item[3]] or 0 -- 171
			item[4] = 0 -- 172
			info[#info + 1] = item -- 173
		end -- 170
		return false, info -- 174
	end -- 160
	return true, info -- 175
end -- 157
local getCompiledYueLine -- 177
getCompiledYueLine = function(content, line, row, file, lax) -- 177
	local luaCodes = yueCheck(file, content, lax) -- 178
	if not luaCodes then -- 179
		return nil -- 179
	end -- 179
	local current = 1 -- 180
	local lastLine = 1 -- 181
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 182
	local targetRow = nil -- 183
	local lineMap = { } -- 184
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 185
		local num = lineCode:match("--%s*(%d+)%s*$") -- 186
		if num then -- 187
			lastLine = tonumber(num) -- 187
		end -- 187
		lineMap[current] = lastLine -- 188
		if row <= lastLine and not targetRow then -- 189
			targetRow = current -- 190
			break -- 191
		end -- 189
		current = current + 1 -- 192
	end -- 185
	targetRow = current -- 193
	if targetLine and targetRow then -- 194
		return luaCodes, targetLine, targetRow, lineMap -- 195
	else -- 197
		return nil -- 197
	end -- 194
end -- 177
HttpServer:postSchedule("/check", function(req) -- 199
	do -- 200
		local _type_0 = type(req) -- 200
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 200
		if _tab_0 then -- 200
			local file -- 200
			do -- 200
				local _obj_0 = req.body -- 200
				local _type_1 = type(_obj_0) -- 200
				if "table" == _type_1 or "userdata" == _type_1 then -- 200
					file = _obj_0.file -- 200
				end -- 200
			end -- 200
			local content -- 200
			do -- 200
				local _obj_0 = req.body -- 200
				local _type_1 = type(_obj_0) -- 200
				if "table" == _type_1 or "userdata" == _type_1 then -- 200
					content = _obj_0.content -- 200
				end -- 200
			end -- 200
			if file ~= nil and content ~= nil then -- 200
				local ext = Path:getExt(file) -- 201
				if "tl" == ext then -- 202
					local searchPath = getSearchPath(file) -- 203
					do -- 204
						local isTIC80 = CheckTIC80Code(content) -- 204
						if isTIC80 then -- 204
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 205
						end -- 204
					end -- 204
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 206
					return { -- 207
						success = success, -- 207
						info = info -- 207
					} -- 207
				elseif "lua" == ext then -- 208
					do -- 209
						local isTIC80 = CheckTIC80Code(content) -- 209
						if isTIC80 then -- 209
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 210
						end -- 209
					end -- 209
					return luaCheck(file, content) -- 211
				elseif "yue" == ext then -- 212
					local luaCodes, info = yueCheck(file, content, false) -- 213
					local success = false -- 214
					if luaCodes then -- 215
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 216
						do -- 217
							local _tab_1 = { } -- 217
							local _idx_0 = #_tab_1 + 1 -- 217
							for _index_0 = 1, #info do -- 217
								local _value_0 = info[_index_0] -- 217
								_tab_1[_idx_0] = _value_0 -- 217
								_idx_0 = _idx_0 + 1 -- 217
							end -- 217
							local _idx_1 = #_tab_1 + 1 -- 217
							for _index_0 = 1, #luaInfo do -- 217
								local _value_0 = luaInfo[_index_0] -- 217
								_tab_1[_idx_1] = _value_0 -- 217
								_idx_1 = _idx_1 + 1 -- 217
							end -- 217
							info = _tab_1 -- 217
						end -- 217
						success = success and luaSuccess -- 218
					end -- 215
					if #info > 0 then -- 219
						return { -- 220
							success = success, -- 220
							info = info -- 220
						} -- 220
					else -- 222
						return { -- 222
							success = success -- 222
						} -- 222
					end -- 219
				elseif "xml" == ext then -- 223
					local success, result = xml.check(content) -- 224
					if success then -- 225
						local info -- 226
						success, info = luaCheckWithLineInfo(file, result) -- 226
						if #info > 0 then -- 227
							return { -- 228
								success = success, -- 228
								info = info -- 228
							} -- 228
						else -- 230
							return { -- 230
								success = success -- 230
							} -- 230
						end -- 227
					else -- 232
						local info -- 232
						do -- 232
							local _accum_0 = { } -- 232
							local _len_0 = 1 -- 232
							for _index_0 = 1, #result do -- 232
								local _des_0 = result[_index_0] -- 232
								local row, err = _des_0[1], _des_0[2] -- 232
								_accum_0[_len_0] = { -- 233
									"syntax", -- 233
									file, -- 233
									row, -- 233
									0, -- 233
									err -- 233
								} -- 233
								_len_0 = _len_0 + 1 -- 233
							end -- 232
							info = _accum_0 -- 232
						end -- 232
						return { -- 234
							success = false, -- 234
							info = info -- 234
						} -- 234
					end -- 225
				end -- 202
			end -- 200
		end -- 200
	end -- 200
	return { -- 199
		success = true -- 199
	} -- 199
end) -- 199
local updateInferedDesc -- 236
updateInferedDesc = function(infered) -- 236
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 237
		return -- 237
	end -- 237
	local key, row = infered.key, infered.row -- 238
	local codes = Content:loadAsync(key) -- 239
	if codes then -- 239
		local comments = { } -- 240
		local line = 0 -- 241
		local skipping = false -- 242
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 243
			line = line + 1 -- 244
			if line >= row then -- 245
				break -- 245
			end -- 245
			if lineCode:match("^%s*%-%- @") then -- 246
				skipping = true -- 247
				goto _continue_0 -- 248
			end -- 246
			local result = lineCode:match("^%s*%-%- (.+)") -- 249
			if result then -- 249
				if not skipping then -- 250
					comments[#comments + 1] = result -- 250
				end -- 250
			elseif #comments > 0 then -- 251
				comments = { } -- 252
				skipping = false -- 253
			end -- 249
			::_continue_0:: -- 244
		end -- 243
		infered.doc = table.concat(comments, "\n") -- 254
	end -- 239
end -- 236
HttpServer:postSchedule("/infer", function(req) -- 256
	do -- 257
		local _type_0 = type(req) -- 257
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 257
		if _tab_0 then -- 257
			local lang -- 257
			do -- 257
				local _obj_0 = req.body -- 257
				local _type_1 = type(_obj_0) -- 257
				if "table" == _type_1 or "userdata" == _type_1 then -- 257
					lang = _obj_0.lang -- 257
				end -- 257
			end -- 257
			local file -- 257
			do -- 257
				local _obj_0 = req.body -- 257
				local _type_1 = type(_obj_0) -- 257
				if "table" == _type_1 or "userdata" == _type_1 then -- 257
					file = _obj_0.file -- 257
				end -- 257
			end -- 257
			local content -- 257
			do -- 257
				local _obj_0 = req.body -- 257
				local _type_1 = type(_obj_0) -- 257
				if "table" == _type_1 or "userdata" == _type_1 then -- 257
					content = _obj_0.content -- 257
				end -- 257
			end -- 257
			local line -- 257
			do -- 257
				local _obj_0 = req.body -- 257
				local _type_1 = type(_obj_0) -- 257
				if "table" == _type_1 or "userdata" == _type_1 then -- 257
					line = _obj_0.line -- 257
				end -- 257
			end -- 257
			local row -- 257
			do -- 257
				local _obj_0 = req.body -- 257
				local _type_1 = type(_obj_0) -- 257
				if "table" == _type_1 or "userdata" == _type_1 then -- 257
					row = _obj_0.row -- 257
				end -- 257
			end -- 257
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 257
				local searchPath = getSearchPath(file) -- 258
				if "tl" == lang or "lua" == lang then -- 259
					if CheckTIC80Code(content) then -- 260
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 261
					end -- 260
					local infered = teal.inferAsync(content, line, row, searchPath) -- 262
					if (infered ~= nil) then -- 263
						updateInferedDesc(infered) -- 264
						return { -- 265
							success = true, -- 265
							infered = infered -- 265
						} -- 265
					end -- 263
				elseif "yue" == lang then -- 266
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 267
					if not luaCodes then -- 268
						return { -- 268
							success = false -- 268
						} -- 268
					end -- 268
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 269
					if (infered ~= nil) then -- 270
						local col -- 271
						file, row, col = infered.file, infered.row, infered.col -- 271
						if file == "" and row > 0 and col > 0 then -- 272
							infered.row = lineMap[row] or 0 -- 273
							infered.col = 0 -- 274
						end -- 272
						updateInferedDesc(infered) -- 275
						return { -- 276
							success = true, -- 276
							infered = infered -- 276
						} -- 276
					end -- 270
				end -- 259
			end -- 257
		end -- 257
	end -- 257
	return { -- 256
		success = false -- 256
	} -- 256
end) -- 256
local _anon_func_0 = function(doc) -- 327
	local _accum_0 = { } -- 327
	local _len_0 = 1 -- 327
	local _list_0 = doc.params -- 327
	for _index_0 = 1, #_list_0 do -- 327
		local param = _list_0[_index_0] -- 327
		_accum_0[_len_0] = param.name -- 327
		_len_0 = _len_0 + 1 -- 327
	end -- 327
	return _accum_0 -- 327
end -- 327
local getParamDocs -- 278
getParamDocs = function(signatures) -- 278
	do -- 279
		local codes = Content:loadAsync(signatures[1].file) -- 279
		if codes then -- 279
			local comments = { } -- 280
			local params = { } -- 281
			local line = 0 -- 282
			local docs = { } -- 283
			local returnType = nil -- 284
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 285
				line = line + 1 -- 286
				local needBreak = true -- 287
				for i, _des_0 in ipairs(signatures) do -- 288
					local row = _des_0.row -- 288
					if line >= row and not (docs[i] ~= nil) then -- 289
						if #comments > 0 or #params > 0 or returnType then -- 290
							docs[i] = { -- 292
								doc = table.concat(comments, "  \n"), -- 292
								returnType = returnType -- 293
							} -- 291
							if #params > 0 then -- 295
								docs[i].params = params -- 295
							end -- 295
						else -- 297
							docs[i] = false -- 297
						end -- 290
					end -- 289
					if not docs[i] then -- 298
						needBreak = false -- 298
					end -- 298
				end -- 288
				if needBreak then -- 299
					break -- 299
				end -- 299
				local result = lineCode:match("%s*%-%- (.+)") -- 300
				if result then -- 300
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 301
					if not name then -- 302
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 303
					end -- 302
					if name then -- 304
						local pname = name -- 305
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 306
							pname = pname .. "?" -- 306
						end -- 306
						params[#params + 1] = { -- 308
							name = tostring(pname) .. ": " .. tostring(typ), -- 308
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 309
						} -- 307
					else -- 312
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 312
						if typ then -- 312
							if returnType then -- 313
								returnType = returnType .. ", " .. typ -- 314
							else -- 316
								returnType = typ -- 316
							end -- 313
							result = result:gsub("@return", "**return:**") -- 317
						end -- 312
						comments[#comments + 1] = result -- 318
					end -- 304
				elseif #comments > 0 then -- 319
					comments = { } -- 320
					params = { } -- 321
					returnType = nil -- 322
				end -- 300
			end -- 285
			local results = { } -- 323
			for _index_0 = 1, #docs do -- 324
				local doc = docs[_index_0] -- 324
				if not doc then -- 325
					goto _continue_0 -- 325
				end -- 325
				if doc.params then -- 326
					doc.desc = "function(" .. tostring(table.concat(_anon_func_0(doc), ', ')) .. ")" -- 327
				else -- 329
					doc.desc = "function()" -- 329
				end -- 326
				if doc.returnType then -- 330
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 331
					doc.returnType = nil -- 332
				end -- 330
				results[#results + 1] = doc -- 333
				::_continue_0:: -- 325
			end -- 324
			if #results > 0 then -- 334
				return results -- 334
			else -- 334
				return nil -- 334
			end -- 334
		end -- 279
	end -- 279
	return nil -- 278
end -- 278
HttpServer:postSchedule("/signature", function(req) -- 336
	do -- 337
		local _type_0 = type(req) -- 337
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 337
		if _tab_0 then -- 337
			local lang -- 337
			do -- 337
				local _obj_0 = req.body -- 337
				local _type_1 = type(_obj_0) -- 337
				if "table" == _type_1 or "userdata" == _type_1 then -- 337
					lang = _obj_0.lang -- 337
				end -- 337
			end -- 337
			local file -- 337
			do -- 337
				local _obj_0 = req.body -- 337
				local _type_1 = type(_obj_0) -- 337
				if "table" == _type_1 or "userdata" == _type_1 then -- 337
					file = _obj_0.file -- 337
				end -- 337
			end -- 337
			local content -- 337
			do -- 337
				local _obj_0 = req.body -- 337
				local _type_1 = type(_obj_0) -- 337
				if "table" == _type_1 or "userdata" == _type_1 then -- 337
					content = _obj_0.content -- 337
				end -- 337
			end -- 337
			local line -- 337
			do -- 337
				local _obj_0 = req.body -- 337
				local _type_1 = type(_obj_0) -- 337
				if "table" == _type_1 or "userdata" == _type_1 then -- 337
					line = _obj_0.line -- 337
				end -- 337
			end -- 337
			local row -- 337
			do -- 337
				local _obj_0 = req.body -- 337
				local _type_1 = type(_obj_0) -- 337
				if "table" == _type_1 or "userdata" == _type_1 then -- 337
					row = _obj_0.row -- 337
				end -- 337
			end -- 337
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 337
				local searchPath = getSearchPath(file) -- 338
				if "tl" == lang or "lua" == lang then -- 339
					if CheckTIC80Code(content) then -- 340
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 341
					end -- 340
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 342
					if signatures then -- 342
						signatures = getParamDocs(signatures) -- 343
						if signatures then -- 343
							return { -- 344
								success = true, -- 344
								signatures = signatures -- 344
							} -- 344
						end -- 343
					end -- 342
				elseif "yue" == lang then -- 345
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 346
					if not luaCodes then -- 347
						return { -- 347
							success = false -- 347
						} -- 347
					end -- 347
					do -- 348
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 348
						if chainOp then -- 348
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 349
							if withVar then -- 349
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 350
							end -- 349
						end -- 348
					end -- 348
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 351
					if signatures then -- 351
						signatures = getParamDocs(signatures) -- 352
						if signatures then -- 352
							return { -- 353
								success = true, -- 353
								signatures = signatures -- 353
							} -- 353
						end -- 352
					else -- 354
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 354
						if signatures then -- 354
							signatures = getParamDocs(signatures) -- 355
							if signatures then -- 355
								return { -- 356
									success = true, -- 356
									signatures = signatures -- 356
								} -- 356
							end -- 355
						end -- 354
					end -- 351
				end -- 339
			end -- 337
		end -- 337
	end -- 337
	return { -- 336
		success = false -- 336
	} -- 336
end) -- 336
local luaKeywords = { -- 359
	'and', -- 359
	'break', -- 360
	'do', -- 361
	'else', -- 362
	'elseif', -- 363
	'end', -- 364
	'false', -- 365
	'for', -- 366
	'function', -- 367
	'goto', -- 368
	'if', -- 369
	'in', -- 370
	'local', -- 371
	'nil', -- 372
	'not', -- 373
	'or', -- 374
	'repeat', -- 375
	'return', -- 376
	'then', -- 377
	'true', -- 378
	'until', -- 379
	'while' -- 380
} -- 358
local tealKeywords = { -- 384
	'record', -- 384
	'as', -- 385
	'is', -- 386
	'type', -- 387
	'embed', -- 388
	'enum', -- 389
	'global', -- 390
	'any', -- 391
	'boolean', -- 392
	'integer', -- 393
	'number', -- 394
	'string', -- 395
	'thread' -- 396
} -- 383
local yueKeywords = { -- 400
	"and", -- 400
	"break", -- 401
	"do", -- 402
	"else", -- 403
	"elseif", -- 404
	"false", -- 405
	"for", -- 406
	"goto", -- 407
	"if", -- 408
	"in", -- 409
	"local", -- 410
	"nil", -- 411
	"not", -- 412
	"or", -- 413
	"repeat", -- 414
	"return", -- 415
	"then", -- 416
	"true", -- 417
	"until", -- 418
	"while", -- 419
	"as", -- 420
	"class", -- 421
	"continue", -- 422
	"export", -- 423
	"extends", -- 424
	"from", -- 425
	"global", -- 426
	"import", -- 427
	"macro", -- 428
	"switch", -- 429
	"try", -- 430
	"unless", -- 431
	"using", -- 432
	"when", -- 433
	"with" -- 434
} -- 399
local _anon_func_1 = function(f) -- 470
	local _val_0 = Path:getExt(f) -- 470
	return "ttf" == _val_0 or "otf" == _val_0 -- 470
end -- 470
local _anon_func_2 = function(suggestions) -- 496
	local _tbl_0 = { } -- 496
	for _index_0 = 1, #suggestions do -- 496
		local item = suggestions[_index_0] -- 496
		_tbl_0[item[1] .. item[2]] = item -- 496
	end -- 496
	return _tbl_0 -- 496
end -- 496
HttpServer:postSchedule("/complete", function(req) -- 437
	do -- 438
		local _type_0 = type(req) -- 438
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 438
		if _tab_0 then -- 438
			local lang -- 438
			do -- 438
				local _obj_0 = req.body -- 438
				local _type_1 = type(_obj_0) -- 438
				if "table" == _type_1 or "userdata" == _type_1 then -- 438
					lang = _obj_0.lang -- 438
				end -- 438
			end -- 438
			local file -- 438
			do -- 438
				local _obj_0 = req.body -- 438
				local _type_1 = type(_obj_0) -- 438
				if "table" == _type_1 or "userdata" == _type_1 then -- 438
					file = _obj_0.file -- 438
				end -- 438
			end -- 438
			local content -- 438
			do -- 438
				local _obj_0 = req.body -- 438
				local _type_1 = type(_obj_0) -- 438
				if "table" == _type_1 or "userdata" == _type_1 then -- 438
					content = _obj_0.content -- 438
				end -- 438
			end -- 438
			local line -- 438
			do -- 438
				local _obj_0 = req.body -- 438
				local _type_1 = type(_obj_0) -- 438
				if "table" == _type_1 or "userdata" == _type_1 then -- 438
					line = _obj_0.line -- 438
				end -- 438
			end -- 438
			local row -- 438
			do -- 438
				local _obj_0 = req.body -- 438
				local _type_1 = type(_obj_0) -- 438
				if "table" == _type_1 or "userdata" == _type_1 then -- 438
					row = _obj_0.row -- 438
				end -- 438
			end -- 438
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 438
				local searchPath = getSearchPath(file) -- 439
				repeat -- 440
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 441
					if lang == "yue" then -- 442
						if not item then -- 443
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 443
						end -- 443
						if not item then -- 444
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 444
						end -- 444
					end -- 442
					local searchType = nil -- 445
					if not item then -- 446
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 447
						if lang == "yue" then -- 448
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 449
						end -- 448
						if (item ~= nil) then -- 450
							searchType = "Image" -- 450
						end -- 450
					end -- 446
					if not item then -- 451
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 452
						if lang == "yue" then -- 453
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 454
						end -- 453
						if (item ~= nil) then -- 455
							searchType = "Font" -- 455
						end -- 455
					end -- 451
					if not item then -- 456
						break -- 456
					end -- 456
					local searchPaths = Content.searchPaths -- 457
					local _list_0 = getSearchFolders(file) -- 458
					for _index_0 = 1, #_list_0 do -- 458
						local folder = _list_0[_index_0] -- 458
						searchPaths[#searchPaths + 1] = folder -- 459
					end -- 458
					if searchType then -- 460
						searchPaths[#searchPaths + 1] = Content.assetPath -- 460
					end -- 460
					local tokens -- 461
					do -- 461
						local _accum_0 = { } -- 461
						local _len_0 = 1 -- 461
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 461
							_accum_0[_len_0] = mod -- 461
							_len_0 = _len_0 + 1 -- 461
						end -- 461
						tokens = _accum_0 -- 461
					end -- 461
					local suggestions = { } -- 462
					for _index_0 = 1, #searchPaths do -- 463
						local path = searchPaths[_index_0] -- 463
						local sPath = Path(path, table.unpack(tokens)) -- 464
						if not Content:exist(sPath) then -- 465
							goto _continue_0 -- 465
						end -- 465
						if searchType == "Font" then -- 466
							local fontPath = Path(sPath, "Font") -- 467
							if Content:exist(fontPath) then -- 468
								local _list_1 = Content:getFiles(fontPath) -- 469
								for _index_1 = 1, #_list_1 do -- 469
									local f = _list_1[_index_1] -- 469
									if _anon_func_1(f) then -- 470
										if "." == f:sub(1, 1) then -- 471
											goto _continue_1 -- 471
										end -- 471
										suggestions[#suggestions + 1] = { -- 472
											Path:getName(f), -- 472
											"font", -- 472
											"field" -- 472
										} -- 472
									end -- 470
									::_continue_1:: -- 470
								end -- 469
							end -- 468
						end -- 466
						local _list_1 = Content:getFiles(sPath) -- 473
						for _index_1 = 1, #_list_1 do -- 473
							local f = _list_1[_index_1] -- 473
							if "Image" == searchType then -- 474
								do -- 475
									local _exp_0 = Path:getExt(f) -- 475
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 475
										if "." == f:sub(1, 1) then -- 476
											goto _continue_2 -- 476
										end -- 476
										suggestions[#suggestions + 1] = { -- 477
											f, -- 477
											"image", -- 477
											"field" -- 477
										} -- 477
									end -- 475
								end -- 475
								goto _continue_2 -- 478
							elseif "Font" == searchType then -- 479
								do -- 480
									local _exp_0 = Path:getExt(f) -- 480
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 480
										if "." == f:sub(1, 1) then -- 481
											goto _continue_2 -- 481
										end -- 481
										suggestions[#suggestions + 1] = { -- 482
											f, -- 482
											"font", -- 482
											"field" -- 482
										} -- 482
									end -- 480
								end -- 480
								goto _continue_2 -- 483
							end -- 474
							local _exp_0 = Path:getExt(f) -- 484
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 484
								local name = Path:getName(f) -- 485
								if "d" == Path:getExt(name) then -- 486
									goto _continue_2 -- 486
								end -- 486
								if "." == name:sub(1, 1) then -- 487
									goto _continue_2 -- 487
								end -- 487
								suggestions[#suggestions + 1] = { -- 488
									name, -- 488
									"module", -- 488
									"field" -- 488
								} -- 488
							end -- 484
							::_continue_2:: -- 474
						end -- 473
						local _list_2 = Content:getDirs(sPath) -- 489
						for _index_1 = 1, #_list_2 do -- 489
							local dir = _list_2[_index_1] -- 489
							if "." == dir:sub(1, 1) then -- 490
								goto _continue_3 -- 490
							end -- 490
							suggestions[#suggestions + 1] = { -- 491
								dir, -- 491
								"folder", -- 491
								"variable" -- 491
							} -- 491
							::_continue_3:: -- 490
						end -- 489
						::_continue_0:: -- 464
					end -- 463
					if item == "" and not searchType then -- 492
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 493
						for _index_0 = 1, #_list_1 do -- 493
							local _des_0 = _list_1[_index_0] -- 493
							local name = _des_0[1] -- 493
							suggestions[#suggestions + 1] = { -- 494
								name, -- 494
								"dora module", -- 494
								"function" -- 494
							} -- 494
						end -- 493
					end -- 492
					if #suggestions > 0 then -- 495
						do -- 496
							local _accum_0 = { } -- 496
							local _len_0 = 1 -- 496
							for _, v in pairs(_anon_func_2(suggestions)) do -- 496
								_accum_0[_len_0] = v -- 496
								_len_0 = _len_0 + 1 -- 496
							end -- 496
							suggestions = _accum_0 -- 496
						end -- 496
						return { -- 497
							success = true, -- 497
							suggestions = suggestions -- 497
						} -- 497
					else -- 499
						return { -- 499
							success = false -- 499
						} -- 499
					end -- 495
				until true -- 440
				if "tl" == lang or "lua" == lang then -- 501
					do -- 502
						local isTIC80 = CheckTIC80Code(content) -- 502
						if isTIC80 then -- 502
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 503
						end -- 502
					end -- 502
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 504
					if not line:match("[%.:]$") then -- 505
						local checkSet -- 506
						do -- 506
							local _tbl_0 = { } -- 506
							for _index_0 = 1, #suggestions do -- 506
								local _des_0 = suggestions[_index_0] -- 506
								local name = _des_0[1] -- 506
								_tbl_0[name] = true -- 506
							end -- 506
							checkSet = _tbl_0 -- 506
						end -- 506
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 507
						for _index_0 = 1, #_list_0 do -- 507
							local item = _list_0[_index_0] -- 507
							if not checkSet[item[1]] then -- 508
								suggestions[#suggestions + 1] = item -- 508
							end -- 508
						end -- 507
						for _index_0 = 1, #luaKeywords do -- 509
							local word = luaKeywords[_index_0] -- 509
							suggestions[#suggestions + 1] = { -- 510
								word, -- 510
								"keyword", -- 510
								"keyword" -- 510
							} -- 510
						end -- 509
						if lang == "tl" then -- 511
							for _index_0 = 1, #tealKeywords do -- 512
								local word = tealKeywords[_index_0] -- 512
								suggestions[#suggestions + 1] = { -- 513
									word, -- 513
									"keyword", -- 513
									"keyword" -- 513
								} -- 513
							end -- 512
						end -- 511
					end -- 505
					if #suggestions > 0 then -- 514
						return { -- 515
							success = true, -- 515
							suggestions = suggestions -- 515
						} -- 515
					end -- 514
				elseif "yue" == lang then -- 516
					local suggestions = { } -- 517
					local gotGlobals = false -- 518
					do -- 519
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 519
						if luaCodes then -- 519
							gotGlobals = true -- 520
							do -- 521
								local chainOp = line:match("[^%w_]([%.\\])$") -- 521
								if chainOp then -- 521
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 522
									if not withVar then -- 523
										return { -- 523
											success = false -- 523
										} -- 523
									end -- 523
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 524
								elseif line:match("^([%.\\])$") then -- 525
									return { -- 526
										success = false -- 526
									} -- 526
								end -- 521
							end -- 521
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 527
							for _index_0 = 1, #_list_0 do -- 527
								local item = _list_0[_index_0] -- 527
								suggestions[#suggestions + 1] = item -- 527
							end -- 527
							if #suggestions == 0 then -- 528
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 529
								for _index_0 = 1, #_list_1 do -- 529
									local item = _list_1[_index_0] -- 529
									suggestions[#suggestions + 1] = item -- 529
								end -- 529
							end -- 528
						end -- 519
					end -- 519
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 530
						local checkSet -- 531
						do -- 531
							local _tbl_0 = { } -- 531
							for _index_0 = 1, #suggestions do -- 531
								local _des_0 = suggestions[_index_0] -- 531
								local name = _des_0[1] -- 531
								_tbl_0[name] = true -- 531
							end -- 531
							checkSet = _tbl_0 -- 531
						end -- 531
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 532
						for _index_0 = 1, #_list_0 do -- 532
							local item = _list_0[_index_0] -- 532
							if not checkSet[item[1]] then -- 533
								suggestions[#suggestions + 1] = item -- 533
							end -- 533
						end -- 532
						if not gotGlobals then -- 534
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 535
							for _index_0 = 1, #_list_1 do -- 535
								local item = _list_1[_index_0] -- 535
								if not checkSet[item[1]] then -- 536
									suggestions[#suggestions + 1] = item -- 536
								end -- 536
							end -- 535
						end -- 534
						for _index_0 = 1, #yueKeywords do -- 537
							local word = yueKeywords[_index_0] -- 537
							if not checkSet[word] then -- 538
								suggestions[#suggestions + 1] = { -- 539
									word, -- 539
									"keyword", -- 539
									"keyword" -- 539
								} -- 539
							end -- 538
						end -- 537
					end -- 530
					if #suggestions > 0 then -- 540
						return { -- 541
							success = true, -- 541
							suggestions = suggestions -- 541
						} -- 541
					end -- 540
				elseif "xml" == lang then -- 542
					local items = xml.complete(content) -- 543
					if #items > 0 then -- 544
						local suggestions -- 545
						do -- 545
							local _accum_0 = { } -- 545
							local _len_0 = 1 -- 545
							for _index_0 = 1, #items do -- 545
								local _des_0 = items[_index_0] -- 545
								local label, insertText = _des_0[1], _des_0[2] -- 545
								_accum_0[_len_0] = { -- 546
									label, -- 546
									insertText, -- 546
									"field" -- 546
								} -- 546
								_len_0 = _len_0 + 1 -- 546
							end -- 545
							suggestions = _accum_0 -- 545
						end -- 545
						return { -- 547
							success = true, -- 547
							suggestions = suggestions -- 547
						} -- 547
					end -- 544
				end -- 501
			end -- 438
		end -- 438
	end -- 438
	return { -- 437
		success = false -- 437
	} -- 437
end) -- 437
HttpServer:upload("/upload", function(req, filename) -- 551
	do -- 552
		local _type_0 = type(req) -- 552
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 552
		if _tab_0 then -- 552
			local path -- 552
			do -- 552
				local _obj_0 = req.params -- 552
				local _type_1 = type(_obj_0) -- 552
				if "table" == _type_1 or "userdata" == _type_1 then -- 552
					path = _obj_0.path -- 552
				end -- 552
			end -- 552
			if path ~= nil then -- 552
				local uploadPath = Path(Content.writablePath, ".upload") -- 553
				if not Content:exist(uploadPath) then -- 554
					Content:mkdir(uploadPath) -- 555
				end -- 554
				local targetPath = Path(uploadPath, filename) -- 556
				Content:mkdir(Path:getPath(targetPath)) -- 557
				return targetPath -- 558
			end -- 552
		end -- 552
	end -- 552
	return nil -- 551
end, function(req, file) -- 559
	do -- 560
		local _type_0 = type(req) -- 560
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 560
		if _tab_0 then -- 560
			local path -- 560
			do -- 560
				local _obj_0 = req.params -- 560
				local _type_1 = type(_obj_0) -- 560
				if "table" == _type_1 or "userdata" == _type_1 then -- 560
					path = _obj_0.path -- 560
				end -- 560
			end -- 560
			if path ~= nil then -- 560
				path = Path(Content.writablePath, path) -- 561
				if Content:exist(path) then -- 562
					local uploadPath = Path(Content.writablePath, ".upload") -- 563
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 564
					Content:mkdir(Path:getPath(targetPath)) -- 565
					if Content:move(file, targetPath) then -- 566
						return true -- 567
					end -- 566
				end -- 562
			end -- 560
		end -- 560
	end -- 560
	return false -- 559
end) -- 549
HttpServer:post("/list", function(req) -- 570
	do -- 571
		local _type_0 = type(req) -- 571
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 571
		if _tab_0 then -- 571
			local path -- 571
			do -- 571
				local _obj_0 = req.body -- 571
				local _type_1 = type(_obj_0) -- 571
				if "table" == _type_1 or "userdata" == _type_1 then -- 571
					path = _obj_0.path -- 571
				end -- 571
			end -- 571
			if path ~= nil then -- 571
				if Content:exist(path) then -- 572
					local files = { } -- 573
					local visitAssets -- 574
					visitAssets = function(path, folder) -- 574
						local dirs = Content:getDirs(path) -- 575
						for _index_0 = 1, #dirs do -- 576
							local dir = dirs[_index_0] -- 576
							if dir:match("^%.") then -- 577
								goto _continue_0 -- 577
							end -- 577
							local current -- 578
							if folder == "" then -- 578
								current = dir -- 579
							else -- 581
								current = Path(folder, dir) -- 581
							end -- 578
							files[#files + 1] = current -- 582
							visitAssets(Path(path, dir), current) -- 583
							::_continue_0:: -- 577
						end -- 576
						local fs = Content:getFiles(path) -- 584
						for _index_0 = 1, #fs do -- 585
							local f = fs[_index_0] -- 585
							if f:match("^%.") then -- 586
								goto _continue_1 -- 586
							end -- 586
							if folder == "" then -- 587
								files[#files + 1] = f -- 588
							else -- 590
								files[#files + 1] = Path(folder, f) -- 590
							end -- 587
							::_continue_1:: -- 586
						end -- 585
					end -- 574
					visitAssets(path, "") -- 591
					if #files == 0 then -- 592
						files = nil -- 592
					end -- 592
					return { -- 593
						success = true, -- 593
						files = files -- 593
					} -- 593
				end -- 572
			end -- 571
		end -- 571
	end -- 571
	return { -- 570
		success = false -- 570
	} -- 570
end) -- 570
HttpServer:post("/info", function() -- 595
	local Entry = require("Script.Dev.Entry") -- 596
	local webProfiler, drawerWidth -- 597
	do -- 597
		local _obj_0 = Entry.getConfig() -- 597
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 597
	end -- 597
	local engineDev = Entry.getEngineDev() -- 598
	Entry.connectWebIDE() -- 599
	return { -- 601
		platform = App.platform, -- 601
		locale = App.locale, -- 602
		version = App.version, -- 603
		engineDev = engineDev, -- 604
		webProfiler = webProfiler, -- 605
		drawerWidth = drawerWidth -- 606
	} -- 600
end) -- 595
local ensureLLMConfigTable -- 608
ensureLLMConfigTable = function() -- 608
	return DB:exec([[		CREATE TABLE IF NOT EXISTS LLMConfig(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			url TEXT NOT NULL,
			model TEXT NOT NULL,
			api_key TEXT NOT NULL,
			created_at INTEGER,
			updated_at INTEGER
		);
	]]) -- 609
end -- 608
HttpServer:post("/llm/list", function() -- 621
	ensureLLMConfigTable() -- 622
	local rows = DB:query("\n		select id, name, url, model, api_key\n		from LLMConfig\n		order by id asc") -- 623
	local items -- 627
	if rows and #rows > 0 then -- 627
		local _accum_0 = { } -- 628
		local _len_0 = 1 -- 628
		for _index_0 = 1, #rows do -- 628
			local _des_0 = rows[_index_0] -- 628
			local id, name, url, model, key = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 628
			_accum_0[_len_0] = { -- 629
				id = id, -- 629
				name = name, -- 629
				url = url, -- 629
				model = model, -- 629
				key = key -- 629
			} -- 629
			_len_0 = _len_0 + 1 -- 629
		end -- 628
		items = _accum_0 -- 628
	end -- 627
	return { -- 630
		success = true, -- 630
		items = items -- 630
	} -- 630
end) -- 621
HttpServer:post("/llm/create", function(req) -- 632
	ensureLLMConfigTable() -- 633
	do -- 634
		local _type_0 = type(req) -- 634
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 634
		if _tab_0 then -- 634
			local name -- 634
			do -- 634
				local _obj_0 = req.body -- 634
				local _type_1 = type(_obj_0) -- 634
				if "table" == _type_1 or "userdata" == _type_1 then -- 634
					name = _obj_0.name -- 634
				end -- 634
			end -- 634
			local url -- 634
			do -- 634
				local _obj_0 = req.body -- 634
				local _type_1 = type(_obj_0) -- 634
				if "table" == _type_1 or "userdata" == _type_1 then -- 634
					url = _obj_0.url -- 634
				end -- 634
			end -- 634
			local model -- 634
			do -- 634
				local _obj_0 = req.body -- 634
				local _type_1 = type(_obj_0) -- 634
				if "table" == _type_1 or "userdata" == _type_1 then -- 634
					model = _obj_0.model -- 634
				end -- 634
			end -- 634
			local key -- 634
			do -- 634
				local _obj_0 = req.body -- 634
				local _type_1 = type(_obj_0) -- 634
				if "table" == _type_1 or "userdata" == _type_1 then -- 634
					key = _obj_0.key -- 634
				end -- 634
			end -- 634
			if name ~= nil and url ~= nil and model ~= nil and key ~= nil then -- 634
				local now = os.time() -- 635
				if name == nil or url == nil or model == nil or key == nil then -- 636
					return { -- 637
						success = false, -- 637
						message = "invalid" -- 637
					} -- 637
				end -- 636
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?\n			)", { -- 644
					tostring(name), -- 644
					tostring(url), -- 645
					tostring(model), -- 646
					tostring(key), -- 647
					now, -- 648
					now -- 649
				}) -- 638
				return { -- 651
					success = affected >= 0 -- 651
				} -- 651
			end -- 634
		end -- 634
	end -- 634
	return { -- 632
		success = false, -- 632
		message = "invalid" -- 632
	} -- 632
end) -- 632
HttpServer:post("/llm/update", function(req) -- 653
	ensureLLMConfigTable() -- 654
	do -- 655
		local _type_0 = type(req) -- 655
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 655
		if _tab_0 then -- 655
			local id -- 655
			do -- 655
				local _obj_0 = req.body -- 655
				local _type_1 = type(_obj_0) -- 655
				if "table" == _type_1 or "userdata" == _type_1 then -- 655
					id = _obj_0.id -- 655
				end -- 655
			end -- 655
			local name -- 655
			do -- 655
				local _obj_0 = req.body -- 655
				local _type_1 = type(_obj_0) -- 655
				if "table" == _type_1 or "userdata" == _type_1 then -- 655
					name = _obj_0.name -- 655
				end -- 655
			end -- 655
			local url -- 655
			do -- 655
				local _obj_0 = req.body -- 655
				local _type_1 = type(_obj_0) -- 655
				if "table" == _type_1 or "userdata" == _type_1 then -- 655
					url = _obj_0.url -- 655
				end -- 655
			end -- 655
			local model -- 655
			do -- 655
				local _obj_0 = req.body -- 655
				local _type_1 = type(_obj_0) -- 655
				if "table" == _type_1 or "userdata" == _type_1 then -- 655
					model = _obj_0.model -- 655
				end -- 655
			end -- 655
			local key -- 655
			do -- 655
				local _obj_0 = req.body -- 655
				local _type_1 = type(_obj_0) -- 655
				if "table" == _type_1 or "userdata" == _type_1 then -- 655
					key = _obj_0.key -- 655
				end -- 655
			end -- 655
			if id ~= nil and name ~= nil and url ~= nil and model ~= nil and key ~= nil then -- 655
				local now = os.time() -- 656
				id = tonumber(id) -- 657
				if id == nil then -- 658
					return { -- 659
						success = false, -- 659
						message = "invalid" -- 659
					} -- 659
				end -- 658
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, updated_at = ?\n			where id = ?", { -- 664
					tostring(name), -- 664
					tostring(url), -- 665
					tostring(model), -- 666
					tostring(key), -- 667
					now, -- 668
					id -- 669
				}) -- 660
				return { -- 671
					success = affected >= 0 -- 671
				} -- 671
			end -- 655
		end -- 655
	end -- 655
	return { -- 653
		success = false, -- 653
		message = "invalid" -- 653
	} -- 653
end) -- 653
HttpServer:post("/llm/delete", function(req) -- 673
	ensureLLMConfigTable() -- 674
	do -- 675
		local _type_0 = type(req) -- 675
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 675
		if _tab_0 then -- 675
			local id -- 675
			do -- 675
				local _obj_0 = req.body -- 675
				local _type_1 = type(_obj_0) -- 675
				if "table" == _type_1 or "userdata" == _type_1 then -- 675
					id = _obj_0.id -- 675
				end -- 675
			end -- 675
			if id ~= nil then -- 675
				id = tonumber(id) -- 676
				if id == nil then -- 677
					return { -- 678
						success = false, -- 678
						message = "invalid" -- 678
					} -- 678
				end -- 677
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 679
					id -- 679
				}) -- 679
				return { -- 680
					success = affected >= 0 -- 680
				} -- 680
			end -- 675
		end -- 675
	end -- 675
	return { -- 673
		success = false, -- 673
		message = "invalid" -- 673
	} -- 673
end) -- 673
HttpServer:post("/new", function(req) -- 682
	do -- 683
		local _type_0 = type(req) -- 683
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 683
		if _tab_0 then -- 683
			local path -- 683
			do -- 683
				local _obj_0 = req.body -- 683
				local _type_1 = type(_obj_0) -- 683
				if "table" == _type_1 or "userdata" == _type_1 then -- 683
					path = _obj_0.path -- 683
				end -- 683
			end -- 683
			local content -- 683
			do -- 683
				local _obj_0 = req.body -- 683
				local _type_1 = type(_obj_0) -- 683
				if "table" == _type_1 or "userdata" == _type_1 then -- 683
					content = _obj_0.content -- 683
				end -- 683
			end -- 683
			local folder -- 683
			do -- 683
				local _obj_0 = req.body -- 683
				local _type_1 = type(_obj_0) -- 683
				if "table" == _type_1 or "userdata" == _type_1 then -- 683
					folder = _obj_0.folder -- 683
				end -- 683
			end -- 683
			if path ~= nil and content ~= nil and folder ~= nil then -- 683
				if Content:exist(path) then -- 684
					return { -- 685
						success = false, -- 685
						message = "TargetExisted" -- 685
					} -- 685
				end -- 684
				local parent = Path:getPath(path) -- 686
				local files = Content:getFiles(parent) -- 687
				if folder then -- 688
					local name = Path:getFilename(path):lower() -- 689
					for _index_0 = 1, #files do -- 690
						local file = files[_index_0] -- 690
						if name == Path:getFilename(file):lower() then -- 691
							return { -- 692
								success = false, -- 692
								message = "TargetExisted" -- 692
							} -- 692
						end -- 691
					end -- 690
					if Content:mkdir(path) then -- 693
						return { -- 694
							success = true -- 694
						} -- 694
					end -- 693
				else -- 696
					local name = Path:getName(path):lower() -- 696
					for _index_0 = 1, #files do -- 697
						local file = files[_index_0] -- 697
						if name == Path:getName(file):lower() then -- 698
							local ext = Path:getExt(file) -- 699
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 700
								goto _continue_0 -- 701
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 702
								goto _continue_0 -- 703
							end -- 700
							return { -- 704
								success = false, -- 704
								message = "SourceExisted" -- 704
							} -- 704
						end -- 698
						::_continue_0:: -- 698
					end -- 697
					if Content:save(path, content) then -- 705
						return { -- 706
							success = true -- 706
						} -- 706
					end -- 705
				end -- 688
			end -- 683
		end -- 683
	end -- 683
	return { -- 682
		success = false, -- 682
		message = "Failed" -- 682
	} -- 682
end) -- 682
HttpServer:post("/delete", function(req) -- 708
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
					local parent = Path:getPath(path) -- 711
					local files = Content:getFiles(parent) -- 712
					local name = Path:getName(path):lower() -- 713
					local ext = Path:getExt(path) -- 714
					for _index_0 = 1, #files do -- 715
						local file = files[_index_0] -- 715
						if name == Path:getName(file):lower() then -- 716
							local _exp_0 = Path:getExt(file) -- 717
							if "tl" == _exp_0 then -- 717
								if ("vs" == ext) then -- 717
									Content:remove(Path(parent, file)) -- 718
								end -- 717
							elseif "lua" == _exp_0 then -- 719
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 719
									Content:remove(Path(parent, file)) -- 720
								end -- 719
							end -- 717
						end -- 716
					end -- 715
					if Content:remove(path) then -- 721
						return { -- 722
							success = true -- 722
						} -- 722
					end -- 721
				end -- 710
			end -- 709
		end -- 709
	end -- 709
	return { -- 708
		success = false -- 708
	} -- 708
end) -- 708
HttpServer:post("/rename", function(req) -- 724
	do -- 725
		local _type_0 = type(req) -- 725
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 725
		if _tab_0 then -- 725
			local old -- 725
			do -- 725
				local _obj_0 = req.body -- 725
				local _type_1 = type(_obj_0) -- 725
				if "table" == _type_1 or "userdata" == _type_1 then -- 725
					old = _obj_0.old -- 725
				end -- 725
			end -- 725
			local new -- 725
			do -- 725
				local _obj_0 = req.body -- 725
				local _type_1 = type(_obj_0) -- 725
				if "table" == _type_1 or "userdata" == _type_1 then -- 725
					new = _obj_0.new -- 725
				end -- 725
			end -- 725
			if old ~= nil and new ~= nil then -- 725
				if Content:exist(old) and not Content:exist(new) then -- 726
					local parent = Path:getPath(new) -- 727
					local files = Content:getFiles(parent) -- 728
					if Content:isdir(old) then -- 729
						local name = Path:getFilename(new):lower() -- 730
						for _index_0 = 1, #files do -- 731
							local file = files[_index_0] -- 731
							if name == Path:getFilename(file):lower() then -- 732
								return { -- 733
									success = false -- 733
								} -- 733
							end -- 732
						end -- 731
					else -- 735
						local name = Path:getName(new):lower() -- 735
						local ext = Path:getExt(new) -- 736
						for _index_0 = 1, #files do -- 737
							local file = files[_index_0] -- 737
							if name == Path:getName(file):lower() then -- 738
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 739
									goto _continue_0 -- 740
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 741
									goto _continue_0 -- 742
								end -- 739
								return { -- 743
									success = false -- 743
								} -- 743
							end -- 738
							::_continue_0:: -- 738
						end -- 737
					end -- 729
					if Content:move(old, new) then -- 744
						local newParent = Path:getPath(new) -- 745
						parent = Path:getPath(old) -- 746
						files = Content:getFiles(parent) -- 747
						local newName = Path:getName(new) -- 748
						local oldName = Path:getName(old) -- 749
						local name = oldName:lower() -- 750
						local ext = Path:getExt(old) -- 751
						for _index_0 = 1, #files do -- 752
							local file = files[_index_0] -- 752
							if name == Path:getName(file):lower() then -- 753
								local _exp_0 = Path:getExt(file) -- 754
								if "tl" == _exp_0 then -- 754
									if ("vs" == ext) then -- 754
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 755
									end -- 754
								elseif "lua" == _exp_0 then -- 756
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 756
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 757
									end -- 756
								end -- 754
							end -- 753
						end -- 752
						return { -- 758
							success = true -- 758
						} -- 758
					end -- 744
				end -- 726
			end -- 725
		end -- 725
	end -- 725
	return { -- 724
		success = false -- 724
	} -- 724
end) -- 724
HttpServer:post("/exist", function(req) -- 760
	do -- 761
		local _type_0 = type(req) -- 761
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 761
		if _tab_0 then -- 761
			local file -- 761
			do -- 761
				local _obj_0 = req.body -- 761
				local _type_1 = type(_obj_0) -- 761
				if "table" == _type_1 or "userdata" == _type_1 then -- 761
					file = _obj_0.file -- 761
				end -- 761
			end -- 761
			if file ~= nil then -- 761
				do -- 762
					local projFile = req.body.projFile -- 762
					if projFile then -- 762
						local projDir = getProjectDirFromFile(projFile) -- 763
						if projDir then -- 763
							local scriptDir = Path(projDir, "Script") -- 764
							local searchPaths = Content.searchPaths -- 765
							if Content:exist(scriptDir) then -- 766
								Content:addSearchPath(scriptDir) -- 766
							end -- 766
							if Content:exist(projDir) then -- 767
								Content:addSearchPath(projDir) -- 767
							end -- 767
							local _ <close> = setmetatable({ }, { -- 768
								__close = function() -- 768
									Content.searchPaths = searchPaths -- 768
								end -- 768
							}) -- 768
							return { -- 769
								success = Content:exist(file) -- 769
							} -- 769
						end -- 763
					end -- 762
				end -- 762
				return { -- 770
					success = Content:exist(file) -- 770
				} -- 770
			end -- 761
		end -- 761
	end -- 761
	return { -- 760
		success = false -- 760
	} -- 760
end) -- 760
HttpServer:postSchedule("/read", function(req) -- 772
	do -- 773
		local _type_0 = type(req) -- 773
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 773
		if _tab_0 then -- 773
			local path -- 773
			do -- 773
				local _obj_0 = req.body -- 773
				local _type_1 = type(_obj_0) -- 773
				if "table" == _type_1 or "userdata" == _type_1 then -- 773
					path = _obj_0.path -- 773
				end -- 773
			end -- 773
			if path ~= nil then -- 773
				local readFile -- 774
				readFile = function() -- 774
					if Content:exist(path) then -- 775
						local content = Content:loadAsync(path) -- 776
						if content then -- 776
							return { -- 777
								content = content, -- 777
								success = true -- 777
							} -- 777
						end -- 776
					end -- 775
					return nil -- 774
				end -- 774
				do -- 778
					local projFile = req.body.projFile -- 778
					if projFile then -- 778
						local projDir = getProjectDirFromFile(projFile) -- 779
						if projDir then -- 779
							local scriptDir = Path(projDir, "Script") -- 780
							local searchPaths = Content.searchPaths -- 781
							if Content:exist(scriptDir) then -- 782
								Content:addSearchPath(scriptDir) -- 782
							end -- 782
							if Content:exist(projDir) then -- 783
								Content:addSearchPath(projDir) -- 783
							end -- 783
							local _ <close> = setmetatable({ }, { -- 784
								__close = function() -- 784
									Content.searchPaths = searchPaths -- 784
								end -- 784
							}) -- 784
							local result = readFile() -- 785
							if result then -- 785
								return result -- 785
							end -- 785
						end -- 779
					end -- 778
				end -- 778
				local result = readFile() -- 786
				if result then -- 786
					return result -- 786
				end -- 786
			end -- 773
		end -- 773
	end -- 773
	return { -- 772
		success = false -- 772
	} -- 772
end) -- 772
HttpServer:post("/read-sync", function(req) -- 788
	do -- 789
		local _type_0 = type(req) -- 789
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 789
		if _tab_0 then -- 789
			local path -- 789
			do -- 789
				local _obj_0 = req.body -- 789
				local _type_1 = type(_obj_0) -- 789
				if "table" == _type_1 or "userdata" == _type_1 then -- 789
					path = _obj_0.path -- 789
				end -- 789
			end -- 789
			local exts -- 789
			do -- 789
				local _obj_0 = req.body -- 789
				local _type_1 = type(_obj_0) -- 789
				if "table" == _type_1 or "userdata" == _type_1 then -- 789
					exts = _obj_0.exts -- 789
				end -- 789
			end -- 789
			if path ~= nil and exts ~= nil then -- 789
				local readFile -- 790
				readFile = function() -- 790
					for _index_0 = 1, #exts do -- 791
						local ext = exts[_index_0] -- 791
						local targetPath = path .. ext -- 792
						if Content:exist(targetPath) then -- 793
							local content = Content:load(targetPath) -- 794
							if content then -- 794
								return { -- 795
									content = content, -- 795
									success = true, -- 795
									fullPath = Content:getFullPath(targetPath) -- 795
								} -- 795
							end -- 794
						end -- 793
					end -- 791
					return nil -- 790
				end -- 790
				local searchPaths = Content.searchPaths -- 796
				local _ <close> = setmetatable({ }, { -- 797
					__close = function() -- 797
						Content.searchPaths = searchPaths -- 797
					end -- 797
				}) -- 797
				do -- 798
					local projFile = req.body.projFile -- 798
					if projFile then -- 798
						local projDir = getProjectDirFromFile(projFile) -- 799
						if projDir then -- 799
							local scriptDir = Path(projDir, "Script") -- 800
							if Content:exist(scriptDir) then -- 801
								Content:addSearchPath(scriptDir) -- 801
							end -- 801
							if Content:exist(projDir) then -- 802
								Content:addSearchPath(projDir) -- 802
							end -- 802
						else -- 804
							projDir = Path:getPath(projFile) -- 804
							if Content:exist(projDir) then -- 805
								Content:addSearchPath(projDir) -- 805
							end -- 805
						end -- 799
					end -- 798
				end -- 798
				local result = readFile() -- 806
				if result then -- 806
					return result -- 806
				end -- 806
			end -- 789
		end -- 789
	end -- 789
	return { -- 788
		success = false -- 788
	} -- 788
end) -- 788
local compileFileAsync -- 808
compileFileAsync = function(inputFile, sourceCodes) -- 808
	local file = inputFile -- 809
	local searchPath -- 810
	do -- 810
		local dir = getProjectDirFromFile(inputFile) -- 810
		if dir then -- 810
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 811
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 812
		else -- 814
			file = Path:getRelative(inputFile, Content.writablePath) -- 814
			if file:sub(1, 2) == ".." then -- 815
				file = Path:getRelative(inputFile, Content.assetPath) -- 816
			end -- 815
			searchPath = "" -- 817
		end -- 810
	end -- 810
	local outputFile = Path:replaceExt(inputFile, "lua") -- 818
	local yueext = yue.options.extension -- 819
	local resultCodes = nil -- 820
	do -- 821
		local _exp_0 = Path:getExt(inputFile) -- 821
		if yueext == _exp_0 then -- 821
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 822
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 823
				if not codes then -- 824
					return -- 824
				end -- 824
				local extraGlobal -- 825
				if isTIC80 then -- 825
					extraGlobal = tic80APIs -- 825
				else -- 825
					extraGlobal = nil -- 825
				end -- 825
				local success = LintYueGlobals(codes, globals, true, extraGlobal) -- 826
				if not success then -- 827
					return -- 827
				end -- 827
				if codes == "" then -- 828
					resultCodes = "" -- 829
					return nil -- 830
				end -- 828
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 831
				return resultCodes -- 832
			end, function(success) -- 823
				if not success then -- 833
					Content:remove(outputFile) -- 834
					if resultCodes == nil then -- 835
						resultCodes = false -- 836
					end -- 835
				end -- 833
			end) -- 823
		elseif "tl" == _exp_0 then -- 837
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 838
			if isTIC80 then -- 839
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 840
			end -- 839
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 841
			if codes then -- 841
				if isTIC80 then -- 842
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 843
				end -- 842
				resultCodes = codes -- 844
				Content:saveAsync(outputFile, codes) -- 845
			else -- 847
				Content:remove(outputFile) -- 847
				resultCodes = false -- 848
			end -- 841
		elseif "xml" == _exp_0 then -- 849
			local codes = xml.tolua(sourceCodes) -- 850
			if codes then -- 850
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 851
				Content:saveAsync(outputFile, resultCodes) -- 852
			else -- 854
				Content:remove(outputFile) -- 854
				resultCodes = false -- 855
			end -- 850
		end -- 821
	end -- 821
	wait(function() -- 856
		return resultCodes ~= nil -- 856
	end) -- 856
	if resultCodes then -- 857
		return resultCodes -- 857
	end -- 857
	return nil -- 808
end -- 808
HttpServer:postSchedule("/write", function(req) -- 859
	do -- 860
		local _type_0 = type(req) -- 860
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 860
		if _tab_0 then -- 860
			local path -- 860
			do -- 860
				local _obj_0 = req.body -- 860
				local _type_1 = type(_obj_0) -- 860
				if "table" == _type_1 or "userdata" == _type_1 then -- 860
					path = _obj_0.path -- 860
				end -- 860
			end -- 860
			local content -- 860
			do -- 860
				local _obj_0 = req.body -- 860
				local _type_1 = type(_obj_0) -- 860
				if "table" == _type_1 or "userdata" == _type_1 then -- 860
					content = _obj_0.content -- 860
				end -- 860
			end -- 860
			if path ~= nil and content ~= nil then -- 860
				if Content:saveAsync(path, content) then -- 861
					do -- 862
						local _exp_0 = Path:getExt(path) -- 862
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 862
							if '' == Path:getExt(Path:getName(path)) then -- 863
								local resultCodes = compileFileAsync(path, content) -- 864
								return { -- 865
									success = true, -- 865
									resultCodes = resultCodes -- 865
								} -- 865
							end -- 863
						end -- 862
					end -- 862
					return { -- 866
						success = true -- 866
					} -- 866
				end -- 861
			end -- 860
		end -- 860
	end -- 860
	return { -- 859
		success = false -- 859
	} -- 859
end) -- 859
HttpServer:postSchedule("/build", function(req) -- 868
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
				local _exp_0 = Path:getExt(path) -- 870
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 870
					if '' == Path:getExt(Path:getName(path)) then -- 871
						local content = Content:loadAsync(path) -- 872
						if content then -- 872
							local resultCodes = compileFileAsync(path, content) -- 873
							if resultCodes then -- 873
								return { -- 874
									success = true, -- 874
									resultCodes = resultCodes -- 874
								} -- 874
							end -- 873
						end -- 872
					end -- 871
				end -- 870
			end -- 869
		end -- 869
	end -- 869
	return { -- 868
		success = false -- 868
	} -- 868
end) -- 868
local extentionLevels = { -- 877
	vs = 2, -- 877
	bl = 2, -- 878
	ts = 1, -- 879
	tsx = 1, -- 880
	tl = 1, -- 881
	yue = 1, -- 882
	xml = 1, -- 883
	lua = 0 -- 884
} -- 876
HttpServer:post("/assets", function() -- 886
	local Entry = require("Script.Dev.Entry") -- 889
	local engineDev = Entry.getEngineDev() -- 890
	local visitAssets -- 891
	visitAssets = function(path, tag) -- 891
		local isWorkspace = tag == "Workspace" -- 892
		local builtin -- 893
		if tag == "Builtin" then -- 893
			builtin = true -- 893
		else -- 893
			builtin = nil -- 893
		end -- 893
		local children = nil -- 894
		local dirs = Content:getDirs(path) -- 895
		for _index_0 = 1, #dirs do -- 896
			local dir = dirs[_index_0] -- 896
			if isWorkspace then -- 897
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 898
					goto _continue_0 -- 899
				end -- 898
			elseif dir == ".git" then -- 900
				goto _continue_0 -- 901
			end -- 897
			if not children then -- 902
				children = { } -- 902
			end -- 902
			children[#children + 1] = visitAssets(Path(path, dir)) -- 903
			::_continue_0:: -- 897
		end -- 896
		local files = Content:getFiles(path) -- 904
		local names = { } -- 905
		for _index_0 = 1, #files do -- 906
			local file = files[_index_0] -- 906
			if file:match("^%.") then -- 907
				goto _continue_1 -- 907
			end -- 907
			local name = Path:getName(file) -- 908
			local ext = names[name] -- 909
			if ext then -- 909
				local lv1 -- 910
				do -- 910
					local _exp_0 = extentionLevels[ext] -- 910
					if _exp_0 ~= nil then -- 910
						lv1 = _exp_0 -- 910
					else -- 910
						lv1 = -1 -- 910
					end -- 910
				end -- 910
				ext = Path:getExt(file) -- 911
				local lv2 -- 912
				do -- 912
					local _exp_0 = extentionLevels[ext] -- 912
					if _exp_0 ~= nil then -- 912
						lv2 = _exp_0 -- 912
					else -- 912
						lv2 = -1 -- 912
					end -- 912
				end -- 912
				if lv2 > lv1 then -- 913
					names[name] = ext -- 914
				elseif lv2 == lv1 then -- 915
					names[name .. '.' .. ext] = "" -- 916
				end -- 913
			else -- 918
				ext = Path:getExt(file) -- 918
				if not extentionLevels[ext] then -- 919
					names[file] = "" -- 920
				else -- 922
					names[name] = ext -- 922
				end -- 919
			end -- 909
			::_continue_1:: -- 907
		end -- 906
		do -- 923
			local _accum_0 = { } -- 923
			local _len_0 = 1 -- 923
			for name, ext in pairs(names) do -- 923
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 923
				_len_0 = _len_0 + 1 -- 923
			end -- 923
			files = _accum_0 -- 923
		end -- 923
		for _index_0 = 1, #files do -- 924
			local file = files[_index_0] -- 924
			if not children then -- 925
				children = { } -- 925
			end -- 925
			children[#children + 1] = { -- 927
				key = Path(path, file), -- 927
				dir = false, -- 928
				title = file, -- 929
				builtin = builtin -- 930
			} -- 926
		end -- 924
		if children then -- 932
			table.sort(children, function(a, b) -- 933
				if a.dir == b.dir then -- 934
					return a.title < b.title -- 935
				else -- 937
					return a.dir -- 937
				end -- 934
			end) -- 933
		end -- 932
		if isWorkspace and children then -- 938
			return children -- 939
		else -- 941
			return { -- 942
				key = path, -- 942
				dir = true, -- 943
				title = Path:getFilename(path), -- 944
				builtin = builtin, -- 945
				children = children -- 946
			} -- 941
		end -- 938
	end -- 891
	local zh = (App.locale:match("^zh") ~= nil) -- 948
	return { -- 950
		key = Content.writablePath, -- 950
		dir = true, -- 951
		root = true, -- 952
		title = "Assets", -- 953
		children = (function() -- 955
			local _tab_0 = { -- 955
				{ -- 956
					key = Path(Content.assetPath), -- 956
					dir = true, -- 957
					builtin = true, -- 958
					title = zh and "内置资源" or "Built-in", -- 959
					children = { -- 961
						(function() -- 961
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 961
							_with_0.title = zh and "说明文档" or "Readme" -- 962
							return _with_0 -- 961
						end)(), -- 961
						(function() -- 963
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 963
							_with_0.title = zh and "接口文档" or "API Doc" -- 964
							return _with_0 -- 963
						end)(), -- 963
						(function() -- 965
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 965
							_with_0.title = zh and "开发工具" or "Tools" -- 966
							return _with_0 -- 965
						end)(), -- 965
						(function() -- 967
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 967
							_with_0.title = zh and "字体" or "Font" -- 968
							return _with_0 -- 967
						end)(), -- 967
						(function() -- 969
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 969
							_with_0.title = zh and "程序库" or "Lib" -- 970
							if engineDev then -- 971
								local _list_0 = _with_0.children -- 972
								for _index_0 = 1, #_list_0 do -- 972
									local child = _list_0[_index_0] -- 972
									if not (child.title == "Dora") then -- 973
										goto _continue_0 -- 973
									end -- 973
									local title = zh and "zh-Hans" or "en" -- 974
									do -- 975
										local _accum_0 = { } -- 975
										local _len_0 = 1 -- 975
										local _list_1 = child.children -- 975
										for _index_1 = 1, #_list_1 do -- 975
											local c = _list_1[_index_1] -- 975
											if c.title ~= title then -- 975
												_accum_0[_len_0] = c -- 975
												_len_0 = _len_0 + 1 -- 975
											end -- 975
										end -- 975
										child.children = _accum_0 -- 975
									end -- 975
									break -- 976
									::_continue_0:: -- 973
								end -- 972
							else -- 978
								local _accum_0 = { } -- 978
								local _len_0 = 1 -- 978
								local _list_0 = _with_0.children -- 978
								for _index_0 = 1, #_list_0 do -- 978
									local child = _list_0[_index_0] -- 978
									if child.title ~= "Dora" then -- 978
										_accum_0[_len_0] = child -- 978
										_len_0 = _len_0 + 1 -- 978
									end -- 978
								end -- 978
								_with_0.children = _accum_0 -- 978
							end -- 971
							return _with_0 -- 969
						end)(), -- 969
						(function() -- 979
							if engineDev then -- 979
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 980
								local _obj_0 = _with_0.children -- 981
								_obj_0[#_obj_0 + 1] = { -- 982
									key = Path(Content.assetPath, "Script", "init.yue"), -- 982
									dir = false, -- 983
									builtin = true, -- 984
									title = "init.yue" -- 985
								} -- 981
								return _with_0 -- 980
							end -- 979
						end)() -- 979
					} -- 960
				} -- 955
			} -- 989
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 989
			local _idx_0 = #_tab_0 + 1 -- 989
			for _index_0 = 1, #_obj_0 do -- 989
				local _value_0 = _obj_0[_index_0] -- 989
				_tab_0[_idx_0] = _value_0 -- 989
				_idx_0 = _idx_0 + 1 -- 989
			end -- 989
			return _tab_0 -- 955
		end)() -- 954
	} -- 949
end) -- 886
HttpServer:postSchedule("/run", function(req) -- 993
	do -- 994
		local _type_0 = type(req) -- 994
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 994
		if _tab_0 then -- 994
			local file -- 994
			do -- 994
				local _obj_0 = req.body -- 994
				local _type_1 = type(_obj_0) -- 994
				if "table" == _type_1 or "userdata" == _type_1 then -- 994
					file = _obj_0.file -- 994
				end -- 994
			end -- 994
			local asProj -- 994
			do -- 994
				local _obj_0 = req.body -- 994
				local _type_1 = type(_obj_0) -- 994
				if "table" == _type_1 or "userdata" == _type_1 then -- 994
					asProj = _obj_0.asProj -- 994
				end -- 994
			end -- 994
			if file ~= nil and asProj ~= nil then -- 994
				if not Content:isAbsolutePath(file) then -- 995
					local devFile = Path(Content.writablePath, file) -- 996
					if Content:exist(devFile) then -- 997
						file = devFile -- 997
					end -- 997
				end -- 995
				local Entry = require("Script.Dev.Entry") -- 998
				local workDir -- 999
				if asProj then -- 1000
					workDir = getProjectDirFromFile(file) -- 1001
					if workDir then -- 1001
						Entry.allClear() -- 1002
						local target = Path(workDir, "init") -- 1003
						local success, err = Entry.enterEntryAsync({ -- 1004
							entryName = "Project", -- 1004
							fileName = target -- 1004
						}) -- 1004
						target = Path:getName(Path:getPath(target)) -- 1005
						return { -- 1006
							success = success, -- 1006
							target = target, -- 1006
							err = err -- 1006
						} -- 1006
					end -- 1001
				else -- 1008
					workDir = getProjectDirFromFile(file) -- 1008
				end -- 1000
				Entry.allClear() -- 1009
				file = Path:replaceExt(file, "") -- 1010
				local success, err = Entry.enterEntryAsync({ -- 1012
					entryName = Path:getName(file), -- 1012
					fileName = file, -- 1013
					workDir = workDir -- 1014
				}) -- 1011
				return { -- 1015
					success = success, -- 1015
					err = err -- 1015
				} -- 1015
			end -- 994
		end -- 994
	end -- 994
	return { -- 993
		success = false -- 993
	} -- 993
end) -- 993
HttpServer:postSchedule("/stop", function() -- 1017
	local Entry = require("Script.Dev.Entry") -- 1018
	return { -- 1019
		success = Entry.stop() -- 1019
	} -- 1019
end) -- 1017
local minifyAsync -- 1021
minifyAsync = function(sourcePath, minifyPath) -- 1021
	if not Content:exist(sourcePath) then -- 1022
		return -- 1022
	end -- 1022
	local Entry = require("Script.Dev.Entry") -- 1023
	local errors = { } -- 1024
	local files = Entry.getAllFiles(sourcePath, { -- 1025
		"lua" -- 1025
	}, true) -- 1025
	do -- 1026
		local _accum_0 = { } -- 1026
		local _len_0 = 1 -- 1026
		for _index_0 = 1, #files do -- 1026
			local file = files[_index_0] -- 1026
			if file:sub(1, 1) ~= '.' then -- 1026
				_accum_0[_len_0] = file -- 1026
				_len_0 = _len_0 + 1 -- 1026
			end -- 1026
		end -- 1026
		files = _accum_0 -- 1026
	end -- 1026
	local paths -- 1027
	do -- 1027
		local _tbl_0 = { } -- 1027
		for _index_0 = 1, #files do -- 1027
			local file = files[_index_0] -- 1027
			_tbl_0[Path:getPath(file)] = true -- 1027
		end -- 1027
		paths = _tbl_0 -- 1027
	end -- 1027
	for path in pairs(paths) do -- 1028
		Content:mkdir(Path(minifyPath, path)) -- 1028
	end -- 1028
	local _ <close> = setmetatable({ }, { -- 1029
		__close = function() -- 1029
			package.loaded["luaminify.FormatMini"] = nil -- 1030
			package.loaded["luaminify.ParseLua"] = nil -- 1031
			package.loaded["luaminify.Scope"] = nil -- 1032
			package.loaded["luaminify.Util"] = nil -- 1033
		end -- 1029
	}) -- 1029
	local FormatMini -- 1034
	do -- 1034
		local _obj_0 = require("luaminify") -- 1034
		FormatMini = _obj_0.FormatMini -- 1034
	end -- 1034
	local fileCount = #files -- 1035
	local count = 0 -- 1036
	for _index_0 = 1, #files do -- 1037
		local file = files[_index_0] -- 1037
		thread(function() -- 1038
			local _ <close> = setmetatable({ }, { -- 1039
				__close = function() -- 1039
					count = count + 1 -- 1039
				end -- 1039
			}) -- 1039
			local input = Path(sourcePath, file) -- 1040
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1041
			if Content:exist(input) then -- 1042
				local sourceCodes = Content:loadAsync(input) -- 1043
				local res, err = FormatMini(sourceCodes) -- 1044
				if res then -- 1045
					Content:saveAsync(output, res) -- 1046
					return print("Minify " .. tostring(file)) -- 1047
				else -- 1049
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1049
				end -- 1045
			else -- 1051
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1051
			end -- 1042
		end) -- 1038
		sleep() -- 1052
	end -- 1037
	wait(function() -- 1053
		return count == fileCount -- 1053
	end) -- 1053
	if #errors > 0 then -- 1054
		print(table.concat(errors, '\n')) -- 1055
	end -- 1054
	print("Obfuscation done.") -- 1056
	return files -- 1057
end -- 1021
local zipping = false -- 1059
HttpServer:postSchedule("/zip", function(req) -- 1061
	do -- 1062
		local _type_0 = type(req) -- 1062
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1062
		if _tab_0 then -- 1062
			local path -- 1062
			do -- 1062
				local _obj_0 = req.body -- 1062
				local _type_1 = type(_obj_0) -- 1062
				if "table" == _type_1 or "userdata" == _type_1 then -- 1062
					path = _obj_0.path -- 1062
				end -- 1062
			end -- 1062
			local zipFile -- 1062
			do -- 1062
				local _obj_0 = req.body -- 1062
				local _type_1 = type(_obj_0) -- 1062
				if "table" == _type_1 or "userdata" == _type_1 then -- 1062
					zipFile = _obj_0.zipFile -- 1062
				end -- 1062
			end -- 1062
			local obfuscated -- 1062
			do -- 1062
				local _obj_0 = req.body -- 1062
				local _type_1 = type(_obj_0) -- 1062
				if "table" == _type_1 or "userdata" == _type_1 then -- 1062
					obfuscated = _obj_0.obfuscated -- 1062
				end -- 1062
			end -- 1062
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1062
				if zipping then -- 1063
					goto failed -- 1063
				end -- 1063
				zipping = true -- 1064
				local _ <close> = setmetatable({ }, { -- 1065
					__close = function() -- 1065
						zipping = false -- 1065
					end -- 1065
				}) -- 1065
				if not Content:exist(path) then -- 1066
					goto failed -- 1066
				end -- 1066
				Content:mkdir(Path:getPath(zipFile)) -- 1067
				if obfuscated then -- 1068
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1069
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1070
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1071
					Content:remove(scriptPath) -- 1072
					Content:remove(obfuscatedPath) -- 1073
					Content:remove(tempPath) -- 1074
					Content:mkdir(scriptPath) -- 1075
					Content:mkdir(obfuscatedPath) -- 1076
					Content:mkdir(tempPath) -- 1077
					if not Content:copyAsync(path, tempPath) then -- 1078
						goto failed -- 1078
					end -- 1078
					local Entry = require("Script.Dev.Entry") -- 1079
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1080
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1081
						"tl", -- 1081
						"yue", -- 1081
						"lua", -- 1081
						"ts", -- 1081
						"tsx", -- 1081
						"vs", -- 1081
						"bl", -- 1081
						"xml", -- 1081
						"wa", -- 1081
						"mod" -- 1081
					}, true) -- 1081
					for _index_0 = 1, #scriptFiles do -- 1082
						local file = scriptFiles[_index_0] -- 1082
						Content:remove(Path(tempPath, file)) -- 1083
					end -- 1082
					for _index_0 = 1, #luaFiles do -- 1084
						local file = luaFiles[_index_0] -- 1084
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1085
					end -- 1084
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1086
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1087
					end) then -- 1086
						goto failed -- 1086
					end -- 1086
					return { -- 1088
						success = true -- 1088
					} -- 1088
				else -- 1090
					return { -- 1090
						success = Content:zipAsync(path, zipFile, function(file) -- 1090
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1091
						end) -- 1090
					} -- 1090
				end -- 1068
			end -- 1062
		end -- 1062
	end -- 1062
	::failed:: -- 1092
	return { -- 1061
		success = false -- 1061
	} -- 1061
end) -- 1061
HttpServer:postSchedule("/unzip", function(req) -- 1094
	do -- 1095
		local _type_0 = type(req) -- 1095
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1095
		if _tab_0 then -- 1095
			local zipFile -- 1095
			do -- 1095
				local _obj_0 = req.body -- 1095
				local _type_1 = type(_obj_0) -- 1095
				if "table" == _type_1 or "userdata" == _type_1 then -- 1095
					zipFile = _obj_0.zipFile -- 1095
				end -- 1095
			end -- 1095
			local path -- 1095
			do -- 1095
				local _obj_0 = req.body -- 1095
				local _type_1 = type(_obj_0) -- 1095
				if "table" == _type_1 or "userdata" == _type_1 then -- 1095
					path = _obj_0.path -- 1095
				end -- 1095
			end -- 1095
			if zipFile ~= nil and path ~= nil then -- 1095
				return { -- 1096
					success = Content:unzipAsync(zipFile, path, function(file) -- 1096
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1097
					end) -- 1096
				} -- 1096
			end -- 1095
		end -- 1095
	end -- 1095
	return { -- 1094
		success = false -- 1094
	} -- 1094
end) -- 1094
HttpServer:post("/editing-info", function(req) -- 1099
	local Entry = require("Script.Dev.Entry") -- 1100
	local config = Entry.getConfig() -- 1101
	local _type_0 = type(req) -- 1102
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1102
	local _match_0 = false -- 1102
	if _tab_0 then -- 1102
		local editingInfo -- 1102
		do -- 1102
			local _obj_0 = req.body -- 1102
			local _type_1 = type(_obj_0) -- 1102
			if "table" == _type_1 or "userdata" == _type_1 then -- 1102
				editingInfo = _obj_0.editingInfo -- 1102
			end -- 1102
		end -- 1102
		if editingInfo ~= nil then -- 1102
			_match_0 = true -- 1102
			config.editingInfo = editingInfo -- 1103
			return { -- 1104
				success = true -- 1104
			} -- 1104
		end -- 1102
	end -- 1102
	if not _match_0 then -- 1102
		if not (config.editingInfo ~= nil) then -- 1106
			local folder -- 1107
			if App.locale:match('^zh') then -- 1107
				folder = 'zh-Hans' -- 1107
			else -- 1107
				folder = 'en' -- 1107
			end -- 1107
			config.editingInfo = json.encode({ -- 1109
				index = 0, -- 1109
				files = { -- 1111
					{ -- 1112
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1112
						title = "welcome.md" -- 1113
					} -- 1111
				} -- 1110
			}) -- 1108
		end -- 1106
		return { -- 1117
			success = true, -- 1117
			editingInfo = config.editingInfo -- 1117
		} -- 1117
	end -- 1102
end) -- 1099
HttpServer:post("/command", function(req) -- 1119
	do -- 1120
		local _type_0 = type(req) -- 1120
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1120
		if _tab_0 then -- 1120
			local code -- 1120
			do -- 1120
				local _obj_0 = req.body -- 1120
				local _type_1 = type(_obj_0) -- 1120
				if "table" == _type_1 or "userdata" == _type_1 then -- 1120
					code = _obj_0.code -- 1120
				end -- 1120
			end -- 1120
			local log -- 1120
			do -- 1120
				local _obj_0 = req.body -- 1120
				local _type_1 = type(_obj_0) -- 1120
				if "table" == _type_1 or "userdata" == _type_1 then -- 1120
					log = _obj_0.log -- 1120
				end -- 1120
			end -- 1120
			if code ~= nil and log ~= nil then -- 1120
				emit("AppCommand", code, log) -- 1121
				return { -- 1122
					success = true -- 1122
				} -- 1122
			end -- 1120
		end -- 1120
	end -- 1120
	return { -- 1119
		success = false -- 1119
	} -- 1119
end) -- 1119
HttpServer:post("/log/save", function() -- 1124
	local folder = ".download" -- 1125
	local fullLogFile = "dora_full_logs.txt" -- 1126
	local fullFolder = Path(Content.writablePath, folder) -- 1127
	Content:mkdir(fullFolder) -- 1128
	local logPath = Path(fullFolder, fullLogFile) -- 1129
	if App:saveLog(logPath) then -- 1130
		return { -- 1131
			success = true, -- 1131
			path = Path(folder, fullLogFile) -- 1131
		} -- 1131
	end -- 1130
	return { -- 1124
		success = false -- 1124
	} -- 1124
end) -- 1124
HttpServer:post("/yarn/check", function(req) -- 1133
	local yarncompile = require("yarncompile") -- 1134
	do -- 1135
		local _type_0 = type(req) -- 1135
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1135
		if _tab_0 then -- 1135
			local code -- 1135
			do -- 1135
				local _obj_0 = req.body -- 1135
				local _type_1 = type(_obj_0) -- 1135
				if "table" == _type_1 or "userdata" == _type_1 then -- 1135
					code = _obj_0.code -- 1135
				end -- 1135
			end -- 1135
			if code ~= nil then -- 1135
				local jsonObject = json.decode(code) -- 1136
				if jsonObject then -- 1136
					local errors = { } -- 1137
					local _list_0 = jsonObject.nodes -- 1138
					for _index_0 = 1, #_list_0 do -- 1138
						local node = _list_0[_index_0] -- 1138
						local title, body = node.title, node.body -- 1139
						local luaCode, err = yarncompile(body) -- 1140
						if not luaCode then -- 1140
							errors[#errors + 1] = title .. ":" .. err -- 1141
						end -- 1140
					end -- 1138
					return { -- 1142
						success = true, -- 1142
						syntaxError = table.concat(errors, "\n\n") -- 1142
					} -- 1142
				end -- 1136
			end -- 1135
		end -- 1135
	end -- 1135
	return { -- 1133
		success = false -- 1133
	} -- 1133
end) -- 1133
HttpServer:post("/yarn/check-file", function(req) -- 1144
	local yarncompile = require("yarncompile") -- 1145
	do -- 1146
		local _type_0 = type(req) -- 1146
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1146
		if _tab_0 then -- 1146
			local code -- 1146
			do -- 1146
				local _obj_0 = req.body -- 1146
				local _type_1 = type(_obj_0) -- 1146
				if "table" == _type_1 or "userdata" == _type_1 then -- 1146
					code = _obj_0.code -- 1146
				end -- 1146
			end -- 1146
			if code ~= nil then -- 1146
				local res, _, err = yarncompile(code, true) -- 1147
				if not res then -- 1147
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1148
					return { -- 1149
						success = false, -- 1149
						message = message, -- 1149
						line = line, -- 1149
						column = column, -- 1149
						node = node -- 1149
					} -- 1149
				end -- 1147
			end -- 1146
		end -- 1146
	end -- 1146
	return { -- 1144
		success = true -- 1144
	} -- 1144
end) -- 1144
local getWaProjectDirFromFile -- 1151
getWaProjectDirFromFile = function(file) -- 1151
	local writablePath = Content.writablePath -- 1152
	local parent, current -- 1153
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1153
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1154
	else -- 1156
		parent, current = nil, nil -- 1156
	end -- 1153
	if not current then -- 1157
		return nil -- 1157
	end -- 1157
	repeat -- 1158
		current = Path:getPath(current) -- 1159
		if current == "" then -- 1160
			break -- 1160
		end -- 1160
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1161
		for _index_0 = 1, #_list_0 do -- 1161
			local f = _list_0[_index_0] -- 1161
			if Path:getFilename(f):lower() == "wa.mod" then -- 1162
				return Path(parent, current, Path:getPath(f)) -- 1163
			end -- 1162
		end -- 1161
	until false -- 1158
	return nil -- 1165
end -- 1151
HttpServer:postSchedule("/wa/build", function(req) -- 1167
	do -- 1168
		local _type_0 = type(req) -- 1168
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1168
		if _tab_0 then -- 1168
			local path -- 1168
			do -- 1168
				local _obj_0 = req.body -- 1168
				local _type_1 = type(_obj_0) -- 1168
				if "table" == _type_1 or "userdata" == _type_1 then -- 1168
					path = _obj_0.path -- 1168
				end -- 1168
			end -- 1168
			if path ~= nil then -- 1168
				local projDir = getWaProjectDirFromFile(path) -- 1169
				if projDir then -- 1169
					local message = Wasm:buildWaAsync(projDir) -- 1170
					if message == "" then -- 1171
						return { -- 1172
							success = true -- 1172
						} -- 1172
					else -- 1174
						return { -- 1174
							success = false, -- 1174
							message = message -- 1174
						} -- 1174
					end -- 1171
				else -- 1176
					return { -- 1176
						success = false, -- 1176
						message = 'Wa file needs a project' -- 1176
					} -- 1176
				end -- 1169
			end -- 1168
		end -- 1168
	end -- 1168
	return { -- 1177
		success = false, -- 1177
		message = 'failed to build' -- 1177
	} -- 1177
end) -- 1167
HttpServer:postSchedule("/wa/format", function(req) -- 1179
	do -- 1180
		local _type_0 = type(req) -- 1180
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1180
		if _tab_0 then -- 1180
			local file -- 1180
			do -- 1180
				local _obj_0 = req.body -- 1180
				local _type_1 = type(_obj_0) -- 1180
				if "table" == _type_1 or "userdata" == _type_1 then -- 1180
					file = _obj_0.file -- 1180
				end -- 1180
			end -- 1180
			if file ~= nil then -- 1180
				local code = Wasm:formatWaAsync(file) -- 1181
				if code == "" then -- 1182
					return { -- 1183
						success = false -- 1183
					} -- 1183
				else -- 1185
					return { -- 1185
						success = true, -- 1185
						code = code -- 1185
					} -- 1185
				end -- 1182
			end -- 1180
		end -- 1180
	end -- 1180
	return { -- 1186
		success = false -- 1186
	} -- 1186
end) -- 1179
HttpServer:postSchedule("/wa/create", function(req) -- 1188
	do -- 1189
		local _type_0 = type(req) -- 1189
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1189
		if _tab_0 then -- 1189
			local path -- 1189
			do -- 1189
				local _obj_0 = req.body -- 1189
				local _type_1 = type(_obj_0) -- 1189
				if "table" == _type_1 or "userdata" == _type_1 then -- 1189
					path = _obj_0.path -- 1189
				end -- 1189
			end -- 1189
			if path ~= nil then -- 1189
				if not Content:exist(Path:getPath(path)) then -- 1190
					return { -- 1191
						success = false, -- 1191
						message = "target path not existed" -- 1191
					} -- 1191
				end -- 1190
				if Content:exist(path) then -- 1192
					return { -- 1193
						success = false, -- 1193
						message = "target project folder existed" -- 1193
					} -- 1193
				end -- 1192
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1194
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1195
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1196
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1197
					return { -- 1200
						success = false, -- 1200
						message = "missing template project" -- 1200
					} -- 1200
				end -- 1197
				if not Content:mkdir(path) then -- 1201
					return { -- 1202
						success = false, -- 1202
						message = "failed to create project folder" -- 1202
					} -- 1202
				end -- 1201
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1203
					Content:remove(path) -- 1204
					return { -- 1205
						success = false, -- 1205
						message = "failed to copy template" -- 1205
					} -- 1205
				end -- 1203
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1206
					Content:remove(path) -- 1207
					return { -- 1208
						success = false, -- 1208
						message = "failed to copy template" -- 1208
					} -- 1208
				end -- 1206
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1209
					Content:remove(path) -- 1210
					return { -- 1211
						success = false, -- 1211
						message = "failed to copy template" -- 1211
					} -- 1211
				end -- 1209
				return { -- 1212
					success = true -- 1212
				} -- 1212
			end -- 1189
		end -- 1189
	end -- 1189
	return { -- 1188
		success = false, -- 1188
		message = "invalid call" -- 1188
	} -- 1188
end) -- 1188
local _anon_func_3 = function(path) -- 1221
	local _val_0 = Path:getExt(path) -- 1221
	return "ts" == _val_0 or "tsx" == _val_0 -- 1221
end -- 1221
local _anon_func_4 = function(f) -- 1251
	local _val_0 = Path:getExt(f) -- 1251
	return "ts" == _val_0 or "tsx" == _val_0 -- 1251
end -- 1251
HttpServer:postSchedule("/ts/build", function(req) -- 1214
	do -- 1215
		local _type_0 = type(req) -- 1215
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1215
		if _tab_0 then -- 1215
			local path -- 1215
			do -- 1215
				local _obj_0 = req.body -- 1215
				local _type_1 = type(_obj_0) -- 1215
				if "table" == _type_1 or "userdata" == _type_1 then -- 1215
					path = _obj_0.path -- 1215
				end -- 1215
			end -- 1215
			if path ~= nil then -- 1215
				if HttpServer.wsConnectionCount == 0 then -- 1216
					return { -- 1217
						success = false, -- 1217
						message = "Web IDE not connected" -- 1217
					} -- 1217
				end -- 1216
				if not Content:exist(path) then -- 1218
					return { -- 1219
						success = false, -- 1219
						message = "path not existed" -- 1219
					} -- 1219
				end -- 1218
				if not Content:isdir(path) then -- 1220
					if not (_anon_func_3(path)) then -- 1221
						return { -- 1222
							success = false, -- 1222
							message = "expecting a TypeScript file" -- 1222
						} -- 1222
					end -- 1221
					local messages = { } -- 1223
					local content = Content:load(path) -- 1224
					if not content then -- 1225
						return { -- 1226
							success = false, -- 1226
							message = "failed to read file" -- 1226
						} -- 1226
					end -- 1225
					emit("AppWS", "Send", json.encode({ -- 1227
						name = "UpdateTSCode", -- 1227
						file = path, -- 1227
						content = content -- 1227
					})) -- 1227
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1228
						local done = false -- 1229
						do -- 1230
							local _with_0 = Node() -- 1230
							_with_0:gslot("AppWS", function(eventType, msg) -- 1231
								if eventType == "Receive" then -- 1232
									_with_0:removeFromParent() -- 1233
									local res = json.decode(msg) -- 1234
									if res then -- 1234
										if res.name == "TranspileTS" then -- 1235
											if res.success then -- 1236
												local luaFile = Path:replaceExt(path, "lua") -- 1237
												Content:save(luaFile, res.luaCode) -- 1238
												messages[#messages + 1] = { -- 1239
													success = true, -- 1239
													file = path -- 1239
												} -- 1239
											else -- 1241
												messages[#messages + 1] = { -- 1241
													success = false, -- 1241
													file = path, -- 1241
													message = res.message -- 1241
												} -- 1241
											end -- 1236
											done = true -- 1242
										end -- 1235
									end -- 1234
								end -- 1232
							end) -- 1231
						end -- 1230
						emit("AppWS", "Send", json.encode({ -- 1243
							name = "TranspileTS", -- 1243
							file = path, -- 1243
							content = content -- 1243
						})) -- 1243
						wait(function() -- 1244
							return done -- 1244
						end) -- 1244
					end -- 1228
					return { -- 1245
						success = true, -- 1245
						messages = messages -- 1245
					} -- 1245
				else -- 1247
					local files = Content:getAllFiles(path) -- 1247
					local fileData = { } -- 1248
					local messages = { } -- 1249
					for _index_0 = 1, #files do -- 1250
						local f = files[_index_0] -- 1250
						if not (_anon_func_4(f)) then -- 1251
							goto _continue_0 -- 1251
						end -- 1251
						local file = Path(path, f) -- 1252
						local content = Content:load(file) -- 1253
						if content then -- 1253
							fileData[file] = content -- 1254
							emit("AppWS", "Send", json.encode({ -- 1255
								name = "UpdateTSCode", -- 1255
								file = file, -- 1255
								content = content -- 1255
							})) -- 1255
						else -- 1257
							messages[#messages + 1] = { -- 1257
								success = false, -- 1257
								file = file, -- 1257
								message = "failed to read file" -- 1257
							} -- 1257
						end -- 1253
						::_continue_0:: -- 1251
					end -- 1250
					for file, content in pairs(fileData) do -- 1258
						if "d" == Path:getExt(Path:getName(file)) then -- 1259
							goto _continue_1 -- 1259
						end -- 1259
						local done = false -- 1260
						do -- 1261
							local _with_0 = Node() -- 1261
							_with_0:gslot("AppWS", function(eventType, msg) -- 1262
								if eventType == "Receive" then -- 1263
									_with_0:removeFromParent() -- 1264
									local res = json.decode(msg) -- 1265
									if res then -- 1265
										if res.name == "TranspileTS" then -- 1266
											if res.success then -- 1267
												local luaFile = Path:replaceExt(file, "lua") -- 1268
												Content:save(luaFile, res.luaCode) -- 1269
												messages[#messages + 1] = { -- 1270
													success = true, -- 1270
													file = file -- 1270
												} -- 1270
											else -- 1272
												messages[#messages + 1] = { -- 1272
													success = false, -- 1272
													file = file, -- 1272
													message = res.message -- 1272
												} -- 1272
											end -- 1267
											done = true -- 1273
										end -- 1266
									end -- 1265
								end -- 1263
							end) -- 1262
						end -- 1261
						emit("AppWS", "Send", json.encode({ -- 1274
							name = "TranspileTS", -- 1274
							file = file, -- 1274
							content = content -- 1274
						})) -- 1274
						wait(function() -- 1275
							return done -- 1275
						end) -- 1275
						::_continue_1:: -- 1259
					end -- 1258
					return { -- 1276
						success = true, -- 1276
						messages = messages -- 1276
					} -- 1276
				end -- 1220
			end -- 1215
		end -- 1215
	end -- 1215
	return { -- 1214
		success = false -- 1214
	} -- 1214
end) -- 1214
HttpServer:post("/download", function(req) -- 1278
	do -- 1279
		local _type_0 = type(req) -- 1279
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1279
		if _tab_0 then -- 1279
			local url -- 1279
			do -- 1279
				local _obj_0 = req.body -- 1279
				local _type_1 = type(_obj_0) -- 1279
				if "table" == _type_1 or "userdata" == _type_1 then -- 1279
					url = _obj_0.url -- 1279
				end -- 1279
			end -- 1279
			local target -- 1279
			do -- 1279
				local _obj_0 = req.body -- 1279
				local _type_1 = type(_obj_0) -- 1279
				if "table" == _type_1 or "userdata" == _type_1 then -- 1279
					target = _obj_0.target -- 1279
				end -- 1279
			end -- 1279
			if url ~= nil and target ~= nil then -- 1279
				local Entry = require("Script.Dev.Entry") -- 1280
				Entry.downloadFile(url, target) -- 1281
				return { -- 1282
					success = true -- 1282
				} -- 1282
			end -- 1279
		end -- 1279
	end -- 1279
	return { -- 1278
		success = false -- 1278
	} -- 1278
end) -- 1278
local status = { } -- 1284
_module_0 = status -- 1285
thread(function() -- 1287
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1288
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1289
	if Content:exist(doraWeb) then -- 1290
		local needReload -- 1291
		if Content:exist(doraReady) then -- 1291
			needReload = App.version ~= Content:load(doraReady) -- 1292
		else -- 1293
			needReload = true -- 1293
		end -- 1291
		if needReload then -- 1294
			Content:remove(Path(Content.appPath, ".www")) -- 1295
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1296
			Content:save(doraReady, App.version) -- 1300
			print("Dora Dora is ready!") -- 1301
		end -- 1294
	end -- 1290
	if HttpServer:start(8866) then -- 1302
		local localIP = HttpServer.localIP -- 1303
		if localIP == "" then -- 1304
			localIP = "localhost" -- 1304
		end -- 1304
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1305
		return HttpServer:startWS(8868) -- 1306
	else -- 1308
		status.url = nil -- 1308
		return print("8866 Port not available!") -- 1309
	end -- 1302
end) -- 1287
return _module_0 -- 1
