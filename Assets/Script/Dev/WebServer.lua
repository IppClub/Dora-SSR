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
local getSearchPath -- 106
getSearchPath = function(file) -- 106
	do -- 107
		local dir = getProjectDirFromFile(file) -- 107
		if dir then -- 107
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 108
		end -- 107
	end -- 107
	return "" -- 106
end -- 106
local getSearchFolders -- 110
getSearchFolders = function(file) -- 110
	do -- 111
		local dir = getProjectDirFromFile(file) -- 111
		if dir then -- 111
			return { -- 113
				Path(dir, "Script"), -- 113
				dir -- 114
			} -- 112
		end -- 111
	end -- 111
	return { } -- 110
end -- 110
local disabledCheckForLua = { -- 117
	"incompatible number of returns", -- 117
	"unknown", -- 118
	"cannot index", -- 119
	"module not found", -- 120
	"don't know how to resolve", -- 121
	"ContainerItem", -- 122
	"cannot resolve a type", -- 123
	"invalid key", -- 124
	"inconsistent index type", -- 125
	"cannot use operator", -- 126
	"attempting ipairs loop", -- 127
	"expects record or nominal", -- 128
	"variable is not being assigned", -- 129
	"<invalid type>", -- 130
	"<any type>", -- 131
	"using the '#' operator", -- 132
	"can't match a record", -- 133
	"redeclaration of variable", -- 134
	"cannot apply pairs", -- 135
	"not a function", -- 136
	"to%-be%-closed" -- 137
} -- 116
local yueCheck -- 139
yueCheck = function(file, content, lax) -- 139
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 140
	if isTIC80 then -- 141
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 142
	end -- 141
	local searchPath = getSearchPath(file) -- 143
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 144
	local info = { } -- 145
	local globals = { } -- 146
	for _index_0 = 1, #checkResult do -- 147
		local _des_0 = checkResult[_index_0] -- 147
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 147
		if "error" == t then -- 148
			info[#info + 1] = { -- 149
				"syntax", -- 149
				file, -- 149
				line, -- 149
				col, -- 149
				msg -- 149
			} -- 149
		elseif "global" == t then -- 150
			globals[#globals + 1] = { -- 151
				msg, -- 151
				line, -- 151
				col -- 151
			} -- 151
		end -- 148
	end -- 147
	if luaCodes then -- 152
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 153
		if success then -- 154
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 155
			if not (lintResult == "") then -- 156
				lintResult = lintResult .. "\n" -- 156
			end -- 156
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 157
		else -- 158
			for _index_0 = 1, #lintResult do -- 158
				local _des_0 = lintResult[_index_0] -- 158
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 158
				if isTIC80 and tic80APIs[name] then -- 159
					goto _continue_0 -- 159
				end -- 159
				info[#info + 1] = { -- 160
					"syntax", -- 160
					file, -- 160
					line, -- 160
					col, -- 160
					"invalid global variable" -- 160
				} -- 160
				::_continue_0:: -- 159
			end -- 158
		end -- 154
	end -- 152
	return luaCodes, info -- 161
end -- 139
local luaCheck -- 163
luaCheck = function(file, content) -- 163
	local res, err = load(content, "check") -- 164
	if not res then -- 165
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 166
		return { -- 167
			success = false, -- 167
			info = { -- 167
				{ -- 167
					"syntax", -- 167
					file, -- 167
					tonumber(line), -- 167
					0, -- 167
					msg -- 167
				} -- 167
			} -- 167
		} -- 167
	end -- 165
	local success, info = teal.checkAsync(content, file, true, "") -- 168
	if info then -- 169
		do -- 170
			local _accum_0 = { } -- 170
			local _len_0 = 1 -- 170
			for _index_0 = 1, #info do -- 170
				local item = info[_index_0] -- 170
				local useCheck = true -- 171
				if not item[5]:match("unused") then -- 172
					for _index_1 = 1, #disabledCheckForLua do -- 173
						local check = disabledCheckForLua[_index_1] -- 173
						if item[5]:match(check) then -- 174
							useCheck = false -- 175
						end -- 174
					end -- 173
				end -- 172
				if not useCheck then -- 176
					goto _continue_0 -- 176
				end -- 176
				do -- 177
					local _exp_0 = item[1] -- 177
					if "type" == _exp_0 then -- 178
						item[1] = "warning" -- 179
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 180
						goto _continue_0 -- 181
					end -- 177
				end -- 177
				_accum_0[_len_0] = item -- 182
				_len_0 = _len_0 + 1 -- 171
				::_continue_0:: -- 171
			end -- 170
			info = _accum_0 -- 170
		end -- 170
		if #info == 0 then -- 183
			info = nil -- 184
			success = true -- 185
		end -- 183
	end -- 169
	return { -- 186
		success = success, -- 186
		info = info -- 186
	} -- 186
end -- 163
local luaCheckWithLineInfo -- 188
luaCheckWithLineInfo = function(file, luaCodes) -- 188
	local res = luaCheck(file, luaCodes) -- 189
	local info = { } -- 190
	if not res.success then -- 191
		local current = 1 -- 192
		local lastLine = 1 -- 193
		local lineMap = { } -- 194
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 195
			local num = lineCode:match("--%s*(%d+)%s*$") -- 196
			if num then -- 197
				lastLine = tonumber(num) -- 198
			end -- 197
			lineMap[current] = lastLine -- 199
			current = current + 1 -- 200
		end -- 195
		local _list_0 = res.info -- 201
		for _index_0 = 1, #_list_0 do -- 201
			local item = _list_0[_index_0] -- 201
			item[3] = lineMap[item[3]] or 0 -- 202
			item[4] = 0 -- 203
			info[#info + 1] = item -- 204
		end -- 201
		return false, info -- 205
	end -- 191
	return true, info -- 206
end -- 188
local getCompiledYueLine -- 208
getCompiledYueLine = function(content, line, row, file, lax) -- 208
	local luaCodes = yueCheck(file, content, lax) -- 209
	if not luaCodes then -- 210
		return nil -- 210
	end -- 210
	local current = 1 -- 211
	local lastLine = 1 -- 212
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 213
	local targetRow = nil -- 214
	local lineMap = { } -- 215
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 216
		local num = lineCode:match("--%s*(%d+)%s*$") -- 217
		if num then -- 218
			lastLine = tonumber(num) -- 218
		end -- 218
		lineMap[current] = lastLine -- 219
		if row <= lastLine and not targetRow then -- 220
			targetRow = current -- 221
			break -- 222
		end -- 220
		current = current + 1 -- 223
	end -- 216
	targetRow = current -- 224
	if targetLine and targetRow then -- 225
		return luaCodes, targetLine, targetRow, lineMap -- 226
	else -- 228
		return nil -- 228
	end -- 225
end -- 208
HttpServer:postSchedule("/check", function(req) -- 230
	do -- 231
		local _type_0 = type(req) -- 231
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 231
		if _tab_0 then -- 231
			local file -- 231
			do -- 231
				local _obj_0 = req.body -- 231
				local _type_1 = type(_obj_0) -- 231
				if "table" == _type_1 or "userdata" == _type_1 then -- 231
					file = _obj_0.file -- 231
				end -- 231
			end -- 231
			local content -- 231
			do -- 231
				local _obj_0 = req.body -- 231
				local _type_1 = type(_obj_0) -- 231
				if "table" == _type_1 or "userdata" == _type_1 then -- 231
					content = _obj_0.content -- 231
				end -- 231
			end -- 231
			if file ~= nil and content ~= nil then -- 231
				local ext = Path:getExt(file) -- 232
				if "tl" == ext then -- 233
					local searchPath = getSearchPath(file) -- 234
					do -- 235
						local isTIC80 = CheckTIC80Code(content) -- 235
						if isTIC80 then -- 235
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 236
						end -- 235
					end -- 235
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 237
					return { -- 238
						success = success, -- 238
						info = info -- 238
					} -- 238
				elseif "lua" == ext then -- 239
					do -- 240
						local isTIC80 = CheckTIC80Code(content) -- 240
						if isTIC80 then -- 240
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 241
						end -- 240
					end -- 240
					return luaCheck(file, content) -- 242
				elseif "yue" == ext then -- 243
					local luaCodes, info = yueCheck(file, content, false) -- 244
					local success = false -- 245
					if luaCodes then -- 246
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 247
						do -- 248
							local _tab_1 = { } -- 248
							local _idx_0 = #_tab_1 + 1 -- 248
							for _index_0 = 1, #info do -- 248
								local _value_0 = info[_index_0] -- 248
								_tab_1[_idx_0] = _value_0 -- 248
								_idx_0 = _idx_0 + 1 -- 248
							end -- 248
							local _idx_1 = #_tab_1 + 1 -- 248
							for _index_0 = 1, #luaInfo do -- 248
								local _value_0 = luaInfo[_index_0] -- 248
								_tab_1[_idx_1] = _value_0 -- 248
								_idx_1 = _idx_1 + 1 -- 248
							end -- 248
							info = _tab_1 -- 248
						end -- 248
						success = success and luaSuccess -- 249
					end -- 246
					if #info > 0 then -- 250
						return { -- 251
							success = success, -- 251
							info = info -- 251
						} -- 251
					else -- 253
						return { -- 253
							success = success -- 253
						} -- 253
					end -- 250
				elseif "xml" == ext then -- 254
					local success, result = xml.check(content) -- 255
					if success then -- 256
						local info -- 257
						success, info = luaCheckWithLineInfo(file, result) -- 257
						if #info > 0 then -- 258
							return { -- 259
								success = success, -- 259
								info = info -- 259
							} -- 259
						else -- 261
							return { -- 261
								success = success -- 261
							} -- 261
						end -- 258
					else -- 263
						local info -- 263
						do -- 263
							local _accum_0 = { } -- 263
							local _len_0 = 1 -- 263
							for _index_0 = 1, #result do -- 263
								local _des_0 = result[_index_0] -- 263
								local row, err = _des_0[1], _des_0[2] -- 263
								_accum_0[_len_0] = { -- 264
									"syntax", -- 264
									file, -- 264
									row, -- 264
									0, -- 264
									err -- 264
								} -- 264
								_len_0 = _len_0 + 1 -- 264
							end -- 263
							info = _accum_0 -- 263
						end -- 263
						return { -- 265
							success = false, -- 265
							info = info -- 265
						} -- 265
					end -- 256
				end -- 233
			end -- 231
		end -- 231
	end -- 231
	return { -- 230
		success = true -- 230
	} -- 230
end) -- 230
local updateInferedDesc -- 267
updateInferedDesc = function(infered) -- 267
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 268
		return -- 268
	end -- 268
	local key, row = infered.key, infered.row -- 269
	local codes = Content:loadAsync(key) -- 270
	if codes then -- 270
		local comments = { } -- 271
		local line = 0 -- 272
		local skipping = false -- 273
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 274
			line = line + 1 -- 275
			if line >= row then -- 276
				break -- 276
			end -- 276
			if lineCode:match("^%s*%-%- @") then -- 277
				skipping = true -- 278
				goto _continue_0 -- 279
			end -- 277
			local result = lineCode:match("^%s*%-%- (.+)") -- 280
			if result then -- 280
				if not skipping then -- 281
					comments[#comments + 1] = result -- 281
				end -- 281
			elseif #comments > 0 then -- 282
				comments = { } -- 283
				skipping = false -- 284
			end -- 280
			::_continue_0:: -- 275
		end -- 274
		infered.doc = table.concat(comments, "\n") -- 285
	end -- 270
end -- 267
HttpServer:postSchedule("/infer", function(req) -- 287
	do -- 288
		local _type_0 = type(req) -- 288
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 288
		if _tab_0 then -- 288
			local lang -- 288
			do -- 288
				local _obj_0 = req.body -- 288
				local _type_1 = type(_obj_0) -- 288
				if "table" == _type_1 or "userdata" == _type_1 then -- 288
					lang = _obj_0.lang -- 288
				end -- 288
			end -- 288
			local file -- 288
			do -- 288
				local _obj_0 = req.body -- 288
				local _type_1 = type(_obj_0) -- 288
				if "table" == _type_1 or "userdata" == _type_1 then -- 288
					file = _obj_0.file -- 288
				end -- 288
			end -- 288
			local content -- 288
			do -- 288
				local _obj_0 = req.body -- 288
				local _type_1 = type(_obj_0) -- 288
				if "table" == _type_1 or "userdata" == _type_1 then -- 288
					content = _obj_0.content -- 288
				end -- 288
			end -- 288
			local line -- 288
			do -- 288
				local _obj_0 = req.body -- 288
				local _type_1 = type(_obj_0) -- 288
				if "table" == _type_1 or "userdata" == _type_1 then -- 288
					line = _obj_0.line -- 288
				end -- 288
			end -- 288
			local row -- 288
			do -- 288
				local _obj_0 = req.body -- 288
				local _type_1 = type(_obj_0) -- 288
				if "table" == _type_1 or "userdata" == _type_1 then -- 288
					row = _obj_0.row -- 288
				end -- 288
			end -- 288
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 288
				local searchPath = getSearchPath(file) -- 289
				if "tl" == lang or "lua" == lang then -- 290
					if CheckTIC80Code(content) then -- 291
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 292
					end -- 291
					local infered = teal.inferAsync(content, line, row, searchPath) -- 293
					if (infered ~= nil) then -- 294
						updateInferedDesc(infered) -- 295
						return { -- 296
							success = true, -- 296
							infered = infered -- 296
						} -- 296
					end -- 294
				elseif "yue" == lang then -- 297
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 298
					if not luaCodes then -- 299
						return { -- 299
							success = false -- 299
						} -- 299
					end -- 299
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 300
					if (infered ~= nil) then -- 301
						local col -- 302
						file, row, col = infered.file, infered.row, infered.col -- 302
						if file == "" and row > 0 and col > 0 then -- 303
							infered.row = lineMap[row] or 0 -- 304
							infered.col = 0 -- 305
						end -- 303
						updateInferedDesc(infered) -- 306
						return { -- 307
							success = true, -- 307
							infered = infered -- 307
						} -- 307
					end -- 301
				end -- 290
			end -- 288
		end -- 288
	end -- 288
	return { -- 287
		success = false -- 287
	} -- 287
end) -- 287
local _anon_func_2 = function(doc) -- 358
	local _accum_0 = { } -- 358
	local _len_0 = 1 -- 358
	local _list_0 = doc.params -- 358
	for _index_0 = 1, #_list_0 do -- 358
		local param = _list_0[_index_0] -- 358
		_accum_0[_len_0] = param.name -- 358
		_len_0 = _len_0 + 1 -- 358
	end -- 358
	return _accum_0 -- 358
end -- 358
local getParamDocs -- 309
getParamDocs = function(signatures) -- 309
	do -- 310
		local codes = Content:loadAsync(signatures[1].file) -- 310
		if codes then -- 310
			local comments = { } -- 311
			local params = { } -- 312
			local line = 0 -- 313
			local docs = { } -- 314
			local returnType = nil -- 315
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 316
				line = line + 1 -- 317
				local needBreak = true -- 318
				for i, _des_0 in ipairs(signatures) do -- 319
					local row = _des_0.row -- 319
					if line >= row and not (docs[i] ~= nil) then -- 320
						if #comments > 0 or #params > 0 or returnType then -- 321
							docs[i] = { -- 323
								doc = table.concat(comments, "  \n"), -- 323
								returnType = returnType -- 324
							} -- 322
							if #params > 0 then -- 326
								docs[i].params = params -- 326
							end -- 326
						else -- 328
							docs[i] = false -- 328
						end -- 321
					end -- 320
					if not docs[i] then -- 329
						needBreak = false -- 329
					end -- 329
				end -- 319
				if needBreak then -- 330
					break -- 330
				end -- 330
				local result = lineCode:match("%s*%-%- (.+)") -- 331
				if result then -- 331
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 332
					if not name then -- 333
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 334
					end -- 333
					if name then -- 335
						local pname = name -- 336
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 337
							pname = pname .. "?" -- 337
						end -- 337
						params[#params + 1] = { -- 339
							name = tostring(pname) .. ": " .. tostring(typ), -- 339
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 340
						} -- 338
					else -- 343
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 343
						if typ then -- 343
							if returnType then -- 344
								returnType = returnType .. ", " .. typ -- 345
							else -- 347
								returnType = typ -- 347
							end -- 344
							result = result:gsub("@return", "**return:**") -- 348
						end -- 343
						comments[#comments + 1] = result -- 349
					end -- 335
				elseif #comments > 0 then -- 350
					comments = { } -- 351
					params = { } -- 352
					returnType = nil -- 353
				end -- 331
			end -- 316
			local results = { } -- 354
			for _index_0 = 1, #docs do -- 355
				local doc = docs[_index_0] -- 355
				if not doc then -- 356
					goto _continue_0 -- 356
				end -- 356
				if doc.params then -- 357
					doc.desc = "function(" .. tostring(table.concat(_anon_func_2(doc), ', ')) .. ")" -- 358
				else -- 360
					doc.desc = "function()" -- 360
				end -- 357
				if doc.returnType then -- 361
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 362
					doc.returnType = nil -- 363
				end -- 361
				results[#results + 1] = doc -- 364
				::_continue_0:: -- 356
			end -- 355
			if #results > 0 then -- 365
				return results -- 365
			else -- 365
				return nil -- 365
			end -- 365
		end -- 310
	end -- 310
	return nil -- 309
end -- 309
HttpServer:postSchedule("/signature", function(req) -- 367
	do -- 368
		local _type_0 = type(req) -- 368
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 368
		if _tab_0 then -- 368
			local lang -- 368
			do -- 368
				local _obj_0 = req.body -- 368
				local _type_1 = type(_obj_0) -- 368
				if "table" == _type_1 or "userdata" == _type_1 then -- 368
					lang = _obj_0.lang -- 368
				end -- 368
			end -- 368
			local file -- 368
			do -- 368
				local _obj_0 = req.body -- 368
				local _type_1 = type(_obj_0) -- 368
				if "table" == _type_1 or "userdata" == _type_1 then -- 368
					file = _obj_0.file -- 368
				end -- 368
			end -- 368
			local content -- 368
			do -- 368
				local _obj_0 = req.body -- 368
				local _type_1 = type(_obj_0) -- 368
				if "table" == _type_1 or "userdata" == _type_1 then -- 368
					content = _obj_0.content -- 368
				end -- 368
			end -- 368
			local line -- 368
			do -- 368
				local _obj_0 = req.body -- 368
				local _type_1 = type(_obj_0) -- 368
				if "table" == _type_1 or "userdata" == _type_1 then -- 368
					line = _obj_0.line -- 368
				end -- 368
			end -- 368
			local row -- 368
			do -- 368
				local _obj_0 = req.body -- 368
				local _type_1 = type(_obj_0) -- 368
				if "table" == _type_1 or "userdata" == _type_1 then -- 368
					row = _obj_0.row -- 368
				end -- 368
			end -- 368
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 368
				local searchPath = getSearchPath(file) -- 369
				if "tl" == lang or "lua" == lang then -- 370
					if CheckTIC80Code(content) then -- 371
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 372
					end -- 371
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 373
					if signatures then -- 373
						signatures = getParamDocs(signatures) -- 374
						if signatures then -- 374
							return { -- 375
								success = true, -- 375
								signatures = signatures -- 375
							} -- 375
						end -- 374
					end -- 373
				elseif "yue" == lang then -- 376
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 377
					if not luaCodes then -- 378
						return { -- 378
							success = false -- 378
						} -- 378
					end -- 378
					do -- 379
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 379
						if chainOp then -- 379
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 380
							if withVar then -- 380
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 381
							end -- 380
						end -- 379
					end -- 379
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 382
					if signatures then -- 382
						signatures = getParamDocs(signatures) -- 383
						if signatures then -- 383
							return { -- 384
								success = true, -- 384
								signatures = signatures -- 384
							} -- 384
						end -- 383
					else -- 385
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 385
						if signatures then -- 385
							signatures = getParamDocs(signatures) -- 386
							if signatures then -- 386
								return { -- 387
									success = true, -- 387
									signatures = signatures -- 387
								} -- 387
							end -- 386
						end -- 385
					end -- 382
				end -- 370
			end -- 368
		end -- 368
	end -- 368
	return { -- 367
		success = false -- 367
	} -- 367
end) -- 367
local luaKeywords = { -- 390
	'and', -- 390
	'break', -- 391
	'do', -- 392
	'else', -- 393
	'elseif', -- 394
	'end', -- 395
	'false', -- 396
	'for', -- 397
	'function', -- 398
	'goto', -- 399
	'if', -- 400
	'in', -- 401
	'local', -- 402
	'nil', -- 403
	'not', -- 404
	'or', -- 405
	'repeat', -- 406
	'return', -- 407
	'then', -- 408
	'true', -- 409
	'until', -- 410
	'while' -- 411
} -- 389
local tealKeywords = { -- 415
	'record', -- 415
	'as', -- 416
	'is', -- 417
	'type', -- 418
	'embed', -- 419
	'enum', -- 420
	'global', -- 421
	'any', -- 422
	'boolean', -- 423
	'integer', -- 424
	'number', -- 425
	'string', -- 426
	'thread' -- 427
} -- 414
local yueKeywords = { -- 431
	"and", -- 431
	"break", -- 432
	"do", -- 433
	"else", -- 434
	"elseif", -- 435
	"false", -- 436
	"for", -- 437
	"goto", -- 438
	"if", -- 439
	"in", -- 440
	"local", -- 441
	"nil", -- 442
	"not", -- 443
	"or", -- 444
	"repeat", -- 445
	"return", -- 446
	"then", -- 447
	"true", -- 448
	"until", -- 449
	"while", -- 450
	"as", -- 451
	"class", -- 452
	"continue", -- 453
	"export", -- 454
	"extends", -- 455
	"from", -- 456
	"global", -- 457
	"import", -- 458
	"macro", -- 459
	"switch", -- 460
	"try", -- 461
	"unless", -- 462
	"using", -- 463
	"when", -- 464
	"with" -- 465
} -- 430
local _anon_func_3 = function(f) -- 501
	local _val_0 = Path:getExt(f) -- 501
	return "ttf" == _val_0 or "otf" == _val_0 -- 501
end -- 501
local _anon_func_4 = function(suggestions) -- 527
	local _tbl_0 = { } -- 527
	for _index_0 = 1, #suggestions do -- 527
		local item = suggestions[_index_0] -- 527
		_tbl_0[item[1] .. item[2]] = item -- 527
	end -- 527
	return _tbl_0 -- 527
end -- 527
HttpServer:postSchedule("/complete", function(req) -- 468
	do -- 469
		local _type_0 = type(req) -- 469
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 469
		if _tab_0 then -- 469
			local lang -- 469
			do -- 469
				local _obj_0 = req.body -- 469
				local _type_1 = type(_obj_0) -- 469
				if "table" == _type_1 or "userdata" == _type_1 then -- 469
					lang = _obj_0.lang -- 469
				end -- 469
			end -- 469
			local file -- 469
			do -- 469
				local _obj_0 = req.body -- 469
				local _type_1 = type(_obj_0) -- 469
				if "table" == _type_1 or "userdata" == _type_1 then -- 469
					file = _obj_0.file -- 469
				end -- 469
			end -- 469
			local content -- 469
			do -- 469
				local _obj_0 = req.body -- 469
				local _type_1 = type(_obj_0) -- 469
				if "table" == _type_1 or "userdata" == _type_1 then -- 469
					content = _obj_0.content -- 469
				end -- 469
			end -- 469
			local line -- 469
			do -- 469
				local _obj_0 = req.body -- 469
				local _type_1 = type(_obj_0) -- 469
				if "table" == _type_1 or "userdata" == _type_1 then -- 469
					line = _obj_0.line -- 469
				end -- 469
			end -- 469
			local row -- 469
			do -- 469
				local _obj_0 = req.body -- 469
				local _type_1 = type(_obj_0) -- 469
				if "table" == _type_1 or "userdata" == _type_1 then -- 469
					row = _obj_0.row -- 469
				end -- 469
			end -- 469
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 469
				local searchPath = getSearchPath(file) -- 470
				repeat -- 471
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 472
					if lang == "yue" then -- 473
						if not item then -- 474
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 474
						end -- 474
						if not item then -- 475
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 475
						end -- 475
					end -- 473
					local searchType = nil -- 476
					if not item then -- 477
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 478
						if lang == "yue" then -- 479
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 480
						end -- 479
						if (item ~= nil) then -- 481
							searchType = "Image" -- 481
						end -- 481
					end -- 477
					if not item then -- 482
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 483
						if lang == "yue" then -- 484
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 485
						end -- 484
						if (item ~= nil) then -- 486
							searchType = "Font" -- 486
						end -- 486
					end -- 482
					if not item then -- 487
						break -- 487
					end -- 487
					local searchPaths = Content.searchPaths -- 488
					local _list_0 = getSearchFolders(file) -- 489
					for _index_0 = 1, #_list_0 do -- 489
						local folder = _list_0[_index_0] -- 489
						searchPaths[#searchPaths + 1] = folder -- 490
					end -- 489
					if searchType then -- 491
						searchPaths[#searchPaths + 1] = Content.assetPath -- 491
					end -- 491
					local tokens -- 492
					do -- 492
						local _accum_0 = { } -- 492
						local _len_0 = 1 -- 492
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 492
							_accum_0[_len_0] = mod -- 492
							_len_0 = _len_0 + 1 -- 492
						end -- 492
						tokens = _accum_0 -- 492
					end -- 492
					local suggestions = { } -- 493
					for _index_0 = 1, #searchPaths do -- 494
						local path = searchPaths[_index_0] -- 494
						local sPath = Path(path, table.unpack(tokens)) -- 495
						if not Content:exist(sPath) then -- 496
							goto _continue_0 -- 496
						end -- 496
						if searchType == "Font" then -- 497
							local fontPath = Path(sPath, "Font") -- 498
							if Content:exist(fontPath) then -- 499
								local _list_1 = Content:getFiles(fontPath) -- 500
								for _index_1 = 1, #_list_1 do -- 500
									local f = _list_1[_index_1] -- 500
									if _anon_func_3(f) then -- 501
										if "." == f:sub(1, 1) then -- 502
											goto _continue_1 -- 502
										end -- 502
										suggestions[#suggestions + 1] = { -- 503
											Path:getName(f), -- 503
											"font", -- 503
											"field" -- 503
										} -- 503
									end -- 501
									::_continue_1:: -- 501
								end -- 500
							end -- 499
						end -- 497
						local _list_1 = Content:getFiles(sPath) -- 504
						for _index_1 = 1, #_list_1 do -- 504
							local f = _list_1[_index_1] -- 504
							if "Image" == searchType then -- 505
								do -- 506
									local _exp_0 = Path:getExt(f) -- 506
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 506
										if "." == f:sub(1, 1) then -- 507
											goto _continue_2 -- 507
										end -- 507
										suggestions[#suggestions + 1] = { -- 508
											f, -- 508
											"image", -- 508
											"field" -- 508
										} -- 508
									end -- 506
								end -- 506
								goto _continue_2 -- 509
							elseif "Font" == searchType then -- 510
								do -- 511
									local _exp_0 = Path:getExt(f) -- 511
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 511
										if "." == f:sub(1, 1) then -- 512
											goto _continue_2 -- 512
										end -- 512
										suggestions[#suggestions + 1] = { -- 513
											f, -- 513
											"font", -- 513
											"field" -- 513
										} -- 513
									end -- 511
								end -- 511
								goto _continue_2 -- 514
							end -- 505
							local _exp_0 = Path:getExt(f) -- 515
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 515
								local name = Path:getName(f) -- 516
								if "d" == Path:getExt(name) then -- 517
									goto _continue_2 -- 517
								end -- 517
								if "." == name:sub(1, 1) then -- 518
									goto _continue_2 -- 518
								end -- 518
								suggestions[#suggestions + 1] = { -- 519
									name, -- 519
									"module", -- 519
									"field" -- 519
								} -- 519
							end -- 515
							::_continue_2:: -- 505
						end -- 504
						local _list_2 = Content:getDirs(sPath) -- 520
						for _index_1 = 1, #_list_2 do -- 520
							local dir = _list_2[_index_1] -- 520
							if "." == dir:sub(1, 1) then -- 521
								goto _continue_3 -- 521
							end -- 521
							suggestions[#suggestions + 1] = { -- 522
								dir, -- 522
								"folder", -- 522
								"variable" -- 522
							} -- 522
							::_continue_3:: -- 521
						end -- 520
						::_continue_0:: -- 495
					end -- 494
					if item == "" and not searchType then -- 523
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 524
						for _index_0 = 1, #_list_1 do -- 524
							local _des_0 = _list_1[_index_0] -- 524
							local name = _des_0[1] -- 524
							suggestions[#suggestions + 1] = { -- 525
								name, -- 525
								"dora module", -- 525
								"function" -- 525
							} -- 525
						end -- 524
					end -- 523
					if #suggestions > 0 then -- 526
						do -- 527
							local _accum_0 = { } -- 527
							local _len_0 = 1 -- 527
							for _, v in pairs(_anon_func_4(suggestions)) do -- 527
								_accum_0[_len_0] = v -- 527
								_len_0 = _len_0 + 1 -- 527
							end -- 527
							suggestions = _accum_0 -- 527
						end -- 527
						return { -- 528
							success = true, -- 528
							suggestions = suggestions -- 528
						} -- 528
					else -- 530
						return { -- 530
							success = false -- 530
						} -- 530
					end -- 526
				until true -- 471
				if "tl" == lang or "lua" == lang then -- 532
					do -- 533
						local isTIC80 = CheckTIC80Code(content) -- 533
						if isTIC80 then -- 533
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 534
						end -- 533
					end -- 533
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 535
					if not line:match("[%.:]$") then -- 536
						local checkSet -- 537
						do -- 537
							local _tbl_0 = { } -- 537
							for _index_0 = 1, #suggestions do -- 537
								local _des_0 = suggestions[_index_0] -- 537
								local name = _des_0[1] -- 537
								_tbl_0[name] = true -- 537
							end -- 537
							checkSet = _tbl_0 -- 537
						end -- 537
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 538
						for _index_0 = 1, #_list_0 do -- 538
							local item = _list_0[_index_0] -- 538
							if not checkSet[item[1]] then -- 539
								suggestions[#suggestions + 1] = item -- 539
							end -- 539
						end -- 538
						for _index_0 = 1, #luaKeywords do -- 540
							local word = luaKeywords[_index_0] -- 540
							suggestions[#suggestions + 1] = { -- 541
								word, -- 541
								"keyword", -- 541
								"keyword" -- 541
							} -- 541
						end -- 540
						if lang == "tl" then -- 542
							for _index_0 = 1, #tealKeywords do -- 543
								local word = tealKeywords[_index_0] -- 543
								suggestions[#suggestions + 1] = { -- 544
									word, -- 544
									"keyword", -- 544
									"keyword" -- 544
								} -- 544
							end -- 543
						end -- 542
					end -- 536
					if #suggestions > 0 then -- 545
						return { -- 546
							success = true, -- 546
							suggestions = suggestions -- 546
						} -- 546
					end -- 545
				elseif "yue" == lang then -- 547
					local suggestions = { } -- 548
					local gotGlobals = false -- 549
					do -- 550
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 550
						if luaCodes then -- 550
							gotGlobals = true -- 551
							do -- 552
								local chainOp = line:match("[^%w_]([%.\\])$") -- 552
								if chainOp then -- 552
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 553
									if not withVar then -- 554
										return { -- 554
											success = false -- 554
										} -- 554
									end -- 554
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 555
								elseif line:match("^([%.\\])$") then -- 556
									return { -- 557
										success = false -- 557
									} -- 557
								end -- 552
							end -- 552
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 558
							for _index_0 = 1, #_list_0 do -- 558
								local item = _list_0[_index_0] -- 558
								suggestions[#suggestions + 1] = item -- 558
							end -- 558
							if #suggestions == 0 then -- 559
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 560
								for _index_0 = 1, #_list_1 do -- 560
									local item = _list_1[_index_0] -- 560
									suggestions[#suggestions + 1] = item -- 560
								end -- 560
							end -- 559
						end -- 550
					end -- 550
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 561
						local checkSet -- 562
						do -- 562
							local _tbl_0 = { } -- 562
							for _index_0 = 1, #suggestions do -- 562
								local _des_0 = suggestions[_index_0] -- 562
								local name = _des_0[1] -- 562
								_tbl_0[name] = true -- 562
							end -- 562
							checkSet = _tbl_0 -- 562
						end -- 562
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 563
						for _index_0 = 1, #_list_0 do -- 563
							local item = _list_0[_index_0] -- 563
							if not checkSet[item[1]] then -- 564
								suggestions[#suggestions + 1] = item -- 564
							end -- 564
						end -- 563
						if not gotGlobals then -- 565
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 566
							for _index_0 = 1, #_list_1 do -- 566
								local item = _list_1[_index_0] -- 566
								if not checkSet[item[1]] then -- 567
									suggestions[#suggestions + 1] = item -- 567
								end -- 567
							end -- 566
						end -- 565
						for _index_0 = 1, #yueKeywords do -- 568
							local word = yueKeywords[_index_0] -- 568
							if not checkSet[word] then -- 569
								suggestions[#suggestions + 1] = { -- 570
									word, -- 570
									"keyword", -- 570
									"keyword" -- 570
								} -- 570
							end -- 569
						end -- 568
					end -- 561
					if #suggestions > 0 then -- 571
						return { -- 572
							success = true, -- 572
							suggestions = suggestions -- 572
						} -- 572
					end -- 571
				elseif "xml" == lang then -- 573
					local items = xml.complete(content) -- 574
					if #items > 0 then -- 575
						local suggestions -- 576
						do -- 576
							local _accum_0 = { } -- 576
							local _len_0 = 1 -- 576
							for _index_0 = 1, #items do -- 576
								local _des_0 = items[_index_0] -- 576
								local label, insertText = _des_0[1], _des_0[2] -- 576
								_accum_0[_len_0] = { -- 577
									label, -- 577
									insertText, -- 577
									"field" -- 577
								} -- 577
								_len_0 = _len_0 + 1 -- 577
							end -- 576
							suggestions = _accum_0 -- 576
						end -- 576
						return { -- 578
							success = true, -- 578
							suggestions = suggestions -- 578
						} -- 578
					end -- 575
				end -- 532
			end -- 469
		end -- 469
	end -- 469
	return { -- 468
		success = false -- 468
	} -- 468
end) -- 468
HttpServer:upload("/upload", function(req, filename) -- 582
	do -- 583
		local _type_0 = type(req) -- 583
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 583
		if _tab_0 then -- 583
			local path -- 583
			do -- 583
				local _obj_0 = req.params -- 583
				local _type_1 = type(_obj_0) -- 583
				if "table" == _type_1 or "userdata" == _type_1 then -- 583
					path = _obj_0.path -- 583
				end -- 583
			end -- 583
			if path ~= nil then -- 583
				local uploadPath = Path(Content.writablePath, ".upload") -- 584
				if not Content:exist(uploadPath) then -- 585
					Content:mkdir(uploadPath) -- 586
				end -- 585
				local targetPath = Path(uploadPath, filename) -- 587
				Content:mkdir(Path:getPath(targetPath)) -- 588
				return targetPath -- 589
			end -- 583
		end -- 583
	end -- 583
	return nil -- 582
end, function(req, file) -- 590
	do -- 591
		local _type_0 = type(req) -- 591
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 591
		if _tab_0 then -- 591
			local path -- 591
			do -- 591
				local _obj_0 = req.params -- 591
				local _type_1 = type(_obj_0) -- 591
				if "table" == _type_1 or "userdata" == _type_1 then -- 591
					path = _obj_0.path -- 591
				end -- 591
			end -- 591
			if path ~= nil then -- 591
				path = Path(Content.writablePath, path) -- 592
				if Content:exist(path) then -- 593
					local uploadPath = Path(Content.writablePath, ".upload") -- 594
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 595
					Content:mkdir(Path:getPath(targetPath)) -- 596
					if Content:move(file, targetPath) then -- 597
						return true -- 598
					end -- 597
				end -- 593
			end -- 591
		end -- 591
	end -- 591
	return false -- 590
end) -- 580
HttpServer:post("/list", function(req) -- 601
	do -- 602
		local _type_0 = type(req) -- 602
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 602
		if _tab_0 then -- 602
			local path -- 602
			do -- 602
				local _obj_0 = req.body -- 602
				local _type_1 = type(_obj_0) -- 602
				if "table" == _type_1 or "userdata" == _type_1 then -- 602
					path = _obj_0.path -- 602
				end -- 602
			end -- 602
			if path ~= nil then -- 602
				if Content:exist(path) then -- 603
					local files = { } -- 604
					local visitAssets -- 605
					visitAssets = function(path, folder) -- 605
						local dirs = Content:getDirs(path) -- 606
						for _index_0 = 1, #dirs do -- 607
							local dir = dirs[_index_0] -- 607
							if dir:match("^%.") then -- 608
								goto _continue_0 -- 608
							end -- 608
							local current -- 609
							if folder == "" then -- 609
								current = dir -- 610
							else -- 612
								current = Path(folder, dir) -- 612
							end -- 609
							files[#files + 1] = current -- 613
							visitAssets(Path(path, dir), current) -- 614
							::_continue_0:: -- 608
						end -- 607
						local fs = Content:getFiles(path) -- 615
						for _index_0 = 1, #fs do -- 616
							local f = fs[_index_0] -- 616
							if f:match("^%.") then -- 617
								goto _continue_1 -- 617
							end -- 617
							if folder == "" then -- 618
								files[#files + 1] = f -- 619
							else -- 621
								files[#files + 1] = Path(folder, f) -- 621
							end -- 618
							::_continue_1:: -- 617
						end -- 616
					end -- 605
					visitAssets(path, "") -- 622
					if #files == 0 then -- 623
						files = nil -- 623
					end -- 623
					return { -- 624
						success = true, -- 624
						files = files -- 624
					} -- 624
				end -- 603
			end -- 602
		end -- 602
	end -- 602
	return { -- 601
		success = false -- 601
	} -- 601
end) -- 601
HttpServer:post("/info", function() -- 626
	local Entry = require("Script.Dev.Entry") -- 627
	local webProfiler, drawerWidth -- 628
	do -- 628
		local _obj_0 = Entry.getConfig() -- 628
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 628
	end -- 628
	local engineDev = Entry.getEngineDev() -- 629
	Entry.connectWebIDE() -- 630
	return { -- 632
		platform = App.platform, -- 632
		locale = App.locale, -- 633
		version = App.version, -- 634
		engineDev = engineDev, -- 635
		webProfiler = webProfiler, -- 636
		drawerWidth = drawerWidth -- 637
	} -- 631
end) -- 626
local ensureLLMConfigTable -- 639
ensureLLMConfigTable = function() -- 639
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
	]]) -- 640
end -- 639
HttpServer:post("/llm/list", function() -- 653
	ensureLLMConfigTable() -- 654
	local rows = DB:query("\n		select id, name, url, model, api_key, active\n		from LLMConfig\n		order by id asc") -- 655
	local items -- 659
	if rows and #rows > 0 then -- 659
		local _accum_0 = { } -- 660
		local _len_0 = 1 -- 660
		for _index_0 = 1, #rows do -- 660
			local _des_0 = rows[_index_0] -- 660
			local id, name, url, model, key, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6] -- 660
			_accum_0[_len_0] = { -- 661
				id = id, -- 661
				name = name, -- 661
				url = url, -- 661
				model = model, -- 661
				key = key, -- 661
				active = active ~= 0 -- 661
			} -- 661
			_len_0 = _len_0 + 1 -- 661
		end -- 660
		items = _accum_0 -- 659
	end -- 659
	return { -- 662
		success = true, -- 662
		items = items -- 662
	} -- 662
end) -- 653
HttpServer:post("/llm/create", function(req) -- 664
	ensureLLMConfigTable() -- 665
	do -- 666
		local _type_0 = type(req) -- 666
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 666
		if _tab_0 then -- 666
			local body = req.body -- 666
			if body ~= nil then -- 666
				local name, url, model, key, active = body.name, body.url, body.model, body.key, body.active -- 667
				local now = os.time() -- 668
				if name == nil or url == nil or model == nil or key == nil then -- 669
					return { -- 670
						success = false, -- 670
						message = "invalid" -- 670
					} -- 670
				end -- 669
				if active then -- 671
					active = 1 -- 671
				else -- 671
					active = 0 -- 671
				end -- 671
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?\n			)", { -- 678
					tostring(name), -- 678
					tostring(url), -- 679
					tostring(model), -- 680
					tostring(key), -- 681
					active, -- 682
					now, -- 683
					now -- 684
				}) -- 672
				return { -- 686
					success = affected >= 0 -- 686
				} -- 686
			end -- 666
		end -- 666
	end -- 666
	return { -- 664
		success = false, -- 664
		message = "invalid" -- 664
	} -- 664
end) -- 664
HttpServer:post("/llm/update", function(req) -- 688
	ensureLLMConfigTable() -- 689
	do -- 690
		local _type_0 = type(req) -- 690
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 690
		if _tab_0 then -- 690
			local body = req.body -- 690
			if body ~= nil then -- 690
				local id, name, url, model, key, active = body.id, body.name, body.url, body.model, body.key, body.active -- 691
				local now = os.time() -- 692
				id = tonumber(id) -- 693
				if id == nil then -- 694
					return { -- 695
						success = false, -- 695
						message = "invalid" -- 695
					} -- 695
				end -- 694
				if active then -- 696
					active = 1 -- 696
				else -- 696
					active = 0 -- 696
				end -- 696
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, active = ?, updated_at = ?\n			where id = ?", { -- 701
					tostring(name), -- 701
					tostring(url), -- 702
					tostring(model), -- 703
					tostring(key), -- 704
					active, -- 705
					now, -- 706
					id -- 707
				}) -- 697
				return { -- 709
					success = affected >= 0 -- 709
				} -- 709
			end -- 690
		end -- 690
	end -- 690
	return { -- 688
		success = false, -- 688
		message = "invalid" -- 688
	} -- 688
end) -- 688
HttpServer:post("/llm/delete", function(req) -- 711
	ensureLLMConfigTable() -- 712
	do -- 713
		local _type_0 = type(req) -- 713
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 713
		if _tab_0 then -- 713
			local id -- 713
			do -- 713
				local _obj_0 = req.body -- 713
				local _type_1 = type(_obj_0) -- 713
				if "table" == _type_1 or "userdata" == _type_1 then -- 713
					id = _obj_0.id -- 713
				end -- 713
			end -- 713
			if id ~= nil then -- 713
				id = tonumber(id) -- 714
				if id == nil then -- 715
					return { -- 716
						success = false, -- 716
						message = "invalid" -- 716
					} -- 716
				end -- 715
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 717
					id -- 717
				}) -- 717
				return { -- 718
					success = affected >= 0 -- 718
				} -- 718
			end -- 713
		end -- 713
	end -- 713
	return { -- 711
		success = false, -- 711
		message = "invalid" -- 711
	} -- 711
end) -- 711
HttpServer:post("/new", function(req) -- 720
	do -- 721
		local _type_0 = type(req) -- 721
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 721
		if _tab_0 then -- 721
			local path -- 721
			do -- 721
				local _obj_0 = req.body -- 721
				local _type_1 = type(_obj_0) -- 721
				if "table" == _type_1 or "userdata" == _type_1 then -- 721
					path = _obj_0.path -- 721
				end -- 721
			end -- 721
			local content -- 721
			do -- 721
				local _obj_0 = req.body -- 721
				local _type_1 = type(_obj_0) -- 721
				if "table" == _type_1 or "userdata" == _type_1 then -- 721
					content = _obj_0.content -- 721
				end -- 721
			end -- 721
			local folder -- 721
			do -- 721
				local _obj_0 = req.body -- 721
				local _type_1 = type(_obj_0) -- 721
				if "table" == _type_1 or "userdata" == _type_1 then -- 721
					folder = _obj_0.folder -- 721
				end -- 721
			end -- 721
			if path ~= nil and content ~= nil and folder ~= nil then -- 721
				if Content:exist(path) then -- 722
					return { -- 723
						success = false, -- 723
						message = "TargetExisted" -- 723
					} -- 723
				end -- 722
				local parent = Path:getPath(path) -- 724
				local files = Content:getFiles(parent) -- 725
				if folder then -- 726
					local name = Path:getFilename(path):lower() -- 727
					for _index_0 = 1, #files do -- 728
						local file = files[_index_0] -- 728
						if name == Path:getFilename(file):lower() then -- 729
							return { -- 730
								success = false, -- 730
								message = "TargetExisted" -- 730
							} -- 730
						end -- 729
					end -- 728
					if Content:mkdir(path) then -- 731
						return { -- 732
							success = true -- 732
						} -- 732
					end -- 731
				else -- 734
					local name = Path:getName(path):lower() -- 734
					for _index_0 = 1, #files do -- 735
						local file = files[_index_0] -- 735
						if name == Path:getName(file):lower() then -- 736
							local ext = Path:getExt(file) -- 737
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 738
								goto _continue_0 -- 739
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 740
								goto _continue_0 -- 741
							end -- 738
							return { -- 742
								success = false, -- 742
								message = "SourceExisted" -- 742
							} -- 742
						end -- 736
						::_continue_0:: -- 736
					end -- 735
					if Content:save(path, content) then -- 743
						return { -- 744
							success = true -- 744
						} -- 744
					end -- 743
				end -- 726
			end -- 721
		end -- 721
	end -- 721
	return { -- 720
		success = false, -- 720
		message = "Failed" -- 720
	} -- 720
end) -- 720
HttpServer:post("/delete", function(req) -- 746
	do -- 747
		local _type_0 = type(req) -- 747
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 747
		if _tab_0 then -- 747
			local path -- 747
			do -- 747
				local _obj_0 = req.body -- 747
				local _type_1 = type(_obj_0) -- 747
				if "table" == _type_1 or "userdata" == _type_1 then -- 747
					path = _obj_0.path -- 747
				end -- 747
			end -- 747
			if path ~= nil then -- 747
				if Content:exist(path) then -- 748
					local parent = Path:getPath(path) -- 749
					local files = Content:getFiles(parent) -- 750
					local name = Path:getName(path):lower() -- 751
					local ext = Path:getExt(path) -- 752
					for _index_0 = 1, #files do -- 753
						local file = files[_index_0] -- 753
						if name == Path:getName(file):lower() then -- 754
							local _exp_0 = Path:getExt(file) -- 755
							if "tl" == _exp_0 then -- 755
								if ("vs" == ext) then -- 755
									Content:remove(Path(parent, file)) -- 756
								end -- 755
							elseif "lua" == _exp_0 then -- 757
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 757
									Content:remove(Path(parent, file)) -- 758
								end -- 757
							end -- 755
						end -- 754
					end -- 753
					if Content:remove(path) then -- 759
						return { -- 760
							success = true -- 760
						} -- 760
					end -- 759
				end -- 748
			end -- 747
		end -- 747
	end -- 747
	return { -- 746
		success = false -- 746
	} -- 746
end) -- 746
HttpServer:post("/rename", function(req) -- 762
	do -- 763
		local _type_0 = type(req) -- 763
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 763
		if _tab_0 then -- 763
			local old -- 763
			do -- 763
				local _obj_0 = req.body -- 763
				local _type_1 = type(_obj_0) -- 763
				if "table" == _type_1 or "userdata" == _type_1 then -- 763
					old = _obj_0.old -- 763
				end -- 763
			end -- 763
			local new -- 763
			do -- 763
				local _obj_0 = req.body -- 763
				local _type_1 = type(_obj_0) -- 763
				if "table" == _type_1 or "userdata" == _type_1 then -- 763
					new = _obj_0.new -- 763
				end -- 763
			end -- 763
			if old ~= nil and new ~= nil then -- 763
				if Content:exist(old) and not Content:exist(new) then -- 764
					local parent = Path:getPath(new) -- 765
					local files = Content:getFiles(parent) -- 766
					if Content:isdir(old) then -- 767
						local name = Path:getFilename(new):lower() -- 768
						for _index_0 = 1, #files do -- 769
							local file = files[_index_0] -- 769
							if name == Path:getFilename(file):lower() then -- 770
								return { -- 771
									success = false -- 771
								} -- 771
							end -- 770
						end -- 769
					else -- 773
						local name = Path:getName(new):lower() -- 773
						local ext = Path:getExt(new) -- 774
						for _index_0 = 1, #files do -- 775
							local file = files[_index_0] -- 775
							if name == Path:getName(file):lower() then -- 776
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 777
									goto _continue_0 -- 778
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 779
									goto _continue_0 -- 780
								end -- 777
								return { -- 781
									success = false -- 781
								} -- 781
							end -- 776
							::_continue_0:: -- 776
						end -- 775
					end -- 767
					if Content:move(old, new) then -- 782
						local newParent = Path:getPath(new) -- 783
						parent = Path:getPath(old) -- 784
						files = Content:getFiles(parent) -- 785
						local newName = Path:getName(new) -- 786
						local oldName = Path:getName(old) -- 787
						local name = oldName:lower() -- 788
						local ext = Path:getExt(old) -- 789
						for _index_0 = 1, #files do -- 790
							local file = files[_index_0] -- 790
							if name == Path:getName(file):lower() then -- 791
								local _exp_0 = Path:getExt(file) -- 792
								if "tl" == _exp_0 then -- 792
									if ("vs" == ext) then -- 792
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 793
									end -- 792
								elseif "lua" == _exp_0 then -- 794
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 794
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 795
									end -- 794
								end -- 792
							end -- 791
						end -- 790
						return { -- 796
							success = true -- 796
						} -- 796
					end -- 782
				end -- 764
			end -- 763
		end -- 763
	end -- 763
	return { -- 762
		success = false -- 762
	} -- 762
end) -- 762
HttpServer:post("/exist", function(req) -- 798
	do -- 799
		local _type_0 = type(req) -- 799
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 799
		if _tab_0 then -- 799
			local file -- 799
			do -- 799
				local _obj_0 = req.body -- 799
				local _type_1 = type(_obj_0) -- 799
				if "table" == _type_1 or "userdata" == _type_1 then -- 799
					file = _obj_0.file -- 799
				end -- 799
			end -- 799
			if file ~= nil then -- 799
				do -- 800
					local projFile = req.body.projFile -- 800
					if projFile then -- 800
						local projDir = getProjectDirFromFile(projFile) -- 801
						if projDir then -- 801
							local scriptDir = Path(projDir, "Script") -- 802
							local searchPaths = Content.searchPaths -- 803
							if Content:exist(scriptDir) then -- 804
								Content:addSearchPath(scriptDir) -- 804
							end -- 804
							if Content:exist(projDir) then -- 805
								Content:addSearchPath(projDir) -- 805
							end -- 805
							local _ <close> = setmetatable({ }, { -- 806
								__close = function() -- 806
									Content.searchPaths = searchPaths -- 806
								end -- 806
							}) -- 806
							return { -- 807
								success = Content:exist(file) -- 807
							} -- 807
						end -- 801
					end -- 800
				end -- 800
				return { -- 808
					success = Content:exist(file) -- 808
				} -- 808
			end -- 799
		end -- 799
	end -- 799
	return { -- 798
		success = false -- 798
	} -- 798
end) -- 798
HttpServer:postSchedule("/read", function(req) -- 810
	do -- 811
		local _type_0 = type(req) -- 811
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 811
		if _tab_0 then -- 811
			local path -- 811
			do -- 811
				local _obj_0 = req.body -- 811
				local _type_1 = type(_obj_0) -- 811
				if "table" == _type_1 or "userdata" == _type_1 then -- 811
					path = _obj_0.path -- 811
				end -- 811
			end -- 811
			if path ~= nil then -- 811
				local readFile -- 812
				readFile = function() -- 812
					if Content:exist(path) then -- 813
						local content = Content:loadAsync(path) -- 814
						if content then -- 814
							return { -- 815
								content = content, -- 815
								success = true -- 815
							} -- 815
						end -- 814
					end -- 813
					return nil -- 812
				end -- 812
				do -- 816
					local projFile = req.body.projFile -- 816
					if projFile then -- 816
						local projDir = getProjectDirFromFile(projFile) -- 817
						if projDir then -- 817
							local scriptDir = Path(projDir, "Script") -- 818
							local searchPaths = Content.searchPaths -- 819
							if Content:exist(scriptDir) then -- 820
								Content:addSearchPath(scriptDir) -- 820
							end -- 820
							if Content:exist(projDir) then -- 821
								Content:addSearchPath(projDir) -- 821
							end -- 821
							local _ <close> = setmetatable({ }, { -- 822
								__close = function() -- 822
									Content.searchPaths = searchPaths -- 822
								end -- 822
							}) -- 822
							local result = readFile() -- 823
							if result then -- 823
								return result -- 823
							end -- 823
						end -- 817
					end -- 816
				end -- 816
				local result = readFile() -- 824
				if result then -- 824
					return result -- 824
				end -- 824
			end -- 811
		end -- 811
	end -- 811
	return { -- 810
		success = false -- 810
	} -- 810
end) -- 810
HttpServer:get("/read-sync", function(req) -- 826
	do -- 827
		local _type_0 = type(req) -- 827
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 827
		if _tab_0 then -- 827
			local params = req.params -- 827
			if params ~= nil then -- 827
				local path = params.path -- 828
				local exts -- 829
				if params.exts then -- 829
					local _accum_0 = { } -- 830
					local _len_0 = 1 -- 830
					for ext in params.exts:gmatch("[^|]*") do -- 830
						_accum_0[_len_0] = ext -- 831
						_len_0 = _len_0 + 1 -- 831
					end -- 830
					exts = _accum_0 -- 829
				else -- 832
					exts = { -- 832
						"" -- 832
					} -- 832
				end -- 829
				local readFile -- 833
				readFile = function() -- 833
					for _index_0 = 1, #exts do -- 834
						local ext = exts[_index_0] -- 834
						local targetPath = path .. ext -- 835
						if Content:exist(targetPath) then -- 836
							local content = Content:load(targetPath) -- 837
							if content then -- 837
								return { -- 838
									content = content, -- 838
									success = true, -- 838
									fullPath = Content:getFullPath(targetPath) -- 838
								} -- 838
							end -- 837
						end -- 836
					end -- 834
					return nil -- 833
				end -- 833
				local searchPaths = Content.searchPaths -- 839
				local _ <close> = setmetatable({ }, { -- 840
					__close = function() -- 840
						Content.searchPaths = searchPaths -- 840
					end -- 840
				}) -- 840
				do -- 841
					local projFile = req.params.projFile -- 841
					if projFile then -- 841
						local projDir = getProjectDirFromFile(projFile) -- 842
						if projDir then -- 842
							local scriptDir = Path(projDir, "Script") -- 843
							if Content:exist(scriptDir) then -- 844
								Content:addSearchPath(scriptDir) -- 844
							end -- 844
							if Content:exist(projDir) then -- 845
								Content:addSearchPath(projDir) -- 845
							end -- 845
						else -- 847
							projDir = Path:getPath(projFile) -- 847
							if Content:exist(projDir) then -- 848
								Content:addSearchPath(projDir) -- 848
							end -- 848
						end -- 842
					end -- 841
				end -- 841
				local result = readFile() -- 849
				if result then -- 849
					return result -- 849
				end -- 849
			end -- 827
		end -- 827
	end -- 827
	return { -- 826
		success = false -- 826
	} -- 826
end) -- 826
local compileFileAsync -- 851
compileFileAsync = function(inputFile, sourceCodes) -- 851
	local file = inputFile -- 852
	local searchPath -- 853
	do -- 853
		local dir = getProjectDirFromFile(inputFile) -- 853
		if dir then -- 853
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 854
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 855
		else -- 857
			file = Path:getRelative(inputFile, Content.writablePath) -- 857
			if file:sub(1, 2) == ".." then -- 858
				file = Path:getRelative(inputFile, Content.assetPath) -- 859
			end -- 858
			searchPath = "" -- 860
		end -- 853
	end -- 853
	local outputFile = Path:replaceExt(inputFile, "lua") -- 861
	local yueext = yue.options.extension -- 862
	local resultCodes = nil -- 863
	do -- 864
		local _exp_0 = Path:getExt(inputFile) -- 864
		if yueext == _exp_0 then -- 864
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 865
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 866
				if not codes then -- 867
					return -- 867
				end -- 867
				local extraGlobal -- 868
				if isTIC80 then -- 868
					extraGlobal = tic80APIs -- 868
				else -- 868
					extraGlobal = nil -- 868
				end -- 868
				local success = LintYueGlobals(codes, globals, true, extraGlobal) -- 869
				if not success then -- 870
					return -- 870
				end -- 870
				if codes == "" then -- 871
					resultCodes = "" -- 872
					return nil -- 873
				end -- 871
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 874
				return resultCodes -- 875
			end, function(success) -- 866
				if not success then -- 876
					Content:remove(outputFile) -- 877
					if resultCodes == nil then -- 878
						resultCodes = false -- 879
					end -- 878
				end -- 876
			end) -- 866
		elseif "tl" == _exp_0 then -- 880
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 881
			if isTIC80 then -- 882
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 883
			end -- 882
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 884
			if codes then -- 884
				if isTIC80 then -- 885
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 886
				end -- 885
				resultCodes = codes -- 887
				Content:saveAsync(outputFile, codes) -- 888
			else -- 890
				Content:remove(outputFile) -- 890
				resultCodes = false -- 891
			end -- 884
		elseif "xml" == _exp_0 then -- 892
			local codes = xml.tolua(sourceCodes) -- 893
			if codes then -- 893
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 894
				Content:saveAsync(outputFile, resultCodes) -- 895
			else -- 897
				Content:remove(outputFile) -- 897
				resultCodes = false -- 898
			end -- 893
		end -- 864
	end -- 864
	wait(function() -- 899
		return resultCodes ~= nil -- 899
	end) -- 899
	if resultCodes then -- 900
		return resultCodes -- 900
	end -- 900
	return nil -- 851
end -- 851
HttpServer:postSchedule("/write", function(req) -- 902
	do -- 903
		local _type_0 = type(req) -- 903
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 903
		if _tab_0 then -- 903
			local path -- 903
			do -- 903
				local _obj_0 = req.body -- 903
				local _type_1 = type(_obj_0) -- 903
				if "table" == _type_1 or "userdata" == _type_1 then -- 903
					path = _obj_0.path -- 903
				end -- 903
			end -- 903
			local content -- 903
			do -- 903
				local _obj_0 = req.body -- 903
				local _type_1 = type(_obj_0) -- 903
				if "table" == _type_1 or "userdata" == _type_1 then -- 903
					content = _obj_0.content -- 903
				end -- 903
			end -- 903
			if path ~= nil and content ~= nil then -- 903
				if Content:saveAsync(path, content) then -- 904
					do -- 905
						local _exp_0 = Path:getExt(path) -- 905
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 905
							if '' == Path:getExt(Path:getName(path)) then -- 906
								local resultCodes = compileFileAsync(path, content) -- 907
								return { -- 908
									success = true, -- 908
									resultCodes = resultCodes -- 908
								} -- 908
							end -- 906
						end -- 905
					end -- 905
					return { -- 909
						success = true -- 909
					} -- 909
				end -- 904
			end -- 903
		end -- 903
	end -- 903
	return { -- 902
		success = false -- 902
	} -- 902
end) -- 902
HttpServer:postSchedule("/build", function(req) -- 911
	do -- 912
		local _type_0 = type(req) -- 912
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 912
		if _tab_0 then -- 912
			local path -- 912
			do -- 912
				local _obj_0 = req.body -- 912
				local _type_1 = type(_obj_0) -- 912
				if "table" == _type_1 or "userdata" == _type_1 then -- 912
					path = _obj_0.path -- 912
				end -- 912
			end -- 912
			if path ~= nil then -- 912
				local _exp_0 = Path:getExt(path) -- 913
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 913
					if '' == Path:getExt(Path:getName(path)) then -- 914
						local content = Content:loadAsync(path) -- 915
						if content then -- 915
							local resultCodes = compileFileAsync(path, content) -- 916
							if resultCodes then -- 916
								return { -- 917
									success = true, -- 917
									resultCodes = resultCodes -- 917
								} -- 917
							end -- 916
						end -- 915
					end -- 914
				end -- 913
			end -- 912
		end -- 912
	end -- 912
	return { -- 911
		success = false -- 911
	} -- 911
end) -- 911
local extentionLevels = { -- 920
	vs = 2, -- 920
	bl = 2, -- 921
	ts = 1, -- 922
	tsx = 1, -- 923
	tl = 1, -- 924
	yue = 1, -- 925
	xml = 1, -- 926
	lua = 0 -- 927
} -- 919
HttpServer:post("/assets", function() -- 929
	local Entry = require("Script.Dev.Entry") -- 932
	local engineDev = Entry.getEngineDev() -- 933
	local visitAssets -- 934
	visitAssets = function(path, tag) -- 934
		local isWorkspace = tag == "Workspace" -- 935
		local builtin -- 936
		if tag == "Builtin" then -- 936
			builtin = true -- 936
		else -- 936
			builtin = nil -- 936
		end -- 936
		local children = nil -- 937
		local dirs = Content:getDirs(path) -- 938
		for _index_0 = 1, #dirs do -- 939
			local dir = dirs[_index_0] -- 939
			if isWorkspace then -- 940
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 941
					goto _continue_0 -- 942
				end -- 941
			elseif dir == ".git" then -- 943
				goto _continue_0 -- 944
			end -- 940
			if not children then -- 945
				children = { } -- 945
			end -- 945
			children[#children + 1] = visitAssets(Path(path, dir)) -- 946
			::_continue_0:: -- 940
		end -- 939
		local files = Content:getFiles(path) -- 947
		local names = { } -- 948
		for _index_0 = 1, #files do -- 949
			local file = files[_index_0] -- 949
			if file:match("^%.") then -- 950
				goto _continue_1 -- 950
			end -- 950
			local name = Path:getName(file) -- 951
			local ext = names[name] -- 952
			if ext then -- 952
				local lv1 -- 953
				do -- 953
					local _exp_0 = extentionLevels[ext] -- 953
					if _exp_0 ~= nil then -- 953
						lv1 = _exp_0 -- 953
					else -- 953
						lv1 = -1 -- 953
					end -- 953
				end -- 953
				ext = Path:getExt(file) -- 954
				local lv2 -- 955
				do -- 955
					local _exp_0 = extentionLevels[ext] -- 955
					if _exp_0 ~= nil then -- 955
						lv2 = _exp_0 -- 955
					else -- 955
						lv2 = -1 -- 955
					end -- 955
				end -- 955
				if lv2 > lv1 then -- 956
					names[name] = ext -- 957
				elseif lv2 == lv1 then -- 958
					names[name .. '.' .. ext] = "" -- 959
				end -- 956
			else -- 961
				ext = Path:getExt(file) -- 961
				if not extentionLevels[ext] then -- 962
					names[file] = "" -- 963
				else -- 965
					names[name] = ext -- 965
				end -- 962
			end -- 952
			::_continue_1:: -- 950
		end -- 949
		do -- 966
			local _accum_0 = { } -- 966
			local _len_0 = 1 -- 966
			for name, ext in pairs(names) do -- 966
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 966
				_len_0 = _len_0 + 1 -- 966
			end -- 966
			files = _accum_0 -- 966
		end -- 966
		for _index_0 = 1, #files do -- 967
			local file = files[_index_0] -- 967
			if not children then -- 968
				children = { } -- 968
			end -- 968
			children[#children + 1] = { -- 970
				key = Path(path, file), -- 970
				dir = false, -- 971
				title = file, -- 972
				builtin = builtin -- 973
			} -- 969
		end -- 967
		if children then -- 975
			table.sort(children, function(a, b) -- 976
				if a.dir == b.dir then -- 977
					return a.title < b.title -- 978
				else -- 980
					return a.dir -- 980
				end -- 977
			end) -- 976
		end -- 975
		if isWorkspace and children then -- 981
			return children -- 982
		else -- 984
			return { -- 985
				key = path, -- 985
				dir = true, -- 986
				title = Path:getFilename(path), -- 987
				builtin = builtin, -- 988
				children = children -- 989
			} -- 984
		end -- 981
	end -- 934
	local zh = (App.locale:match("^zh") ~= nil) -- 991
	return { -- 993
		key = Content.writablePath, -- 993
		dir = true, -- 994
		root = true, -- 995
		title = "Assets", -- 996
		children = (function() -- 998
			local _tab_0 = { -- 998
				{ -- 999
					key = Path(Content.assetPath), -- 999
					dir = true, -- 1000
					builtin = true, -- 1001
					title = zh and "内置资源" or "Built-in", -- 1002
					children = { -- 1004
						(function() -- 1004
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1004
							_with_0.title = zh and "说明文档" or "Readme" -- 1005
							return _with_0 -- 1004
						end)(), -- 1004
						(function() -- 1006
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1006
							_with_0.title = zh and "接口文档" or "API Doc" -- 1007
							return _with_0 -- 1006
						end)(), -- 1006
						(function() -- 1008
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1008
							_with_0.title = zh and "开发工具" or "Tools" -- 1009
							return _with_0 -- 1008
						end)(), -- 1008
						(function() -- 1010
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1010
							_with_0.title = zh and "字体" or "Font" -- 1011
							return _with_0 -- 1010
						end)(), -- 1010
						(function() -- 1012
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1012
							_with_0.title = zh and "程序库" or "Lib" -- 1013
							if engineDev then -- 1014
								local _list_0 = _with_0.children -- 1015
								for _index_0 = 1, #_list_0 do -- 1015
									local child = _list_0[_index_0] -- 1015
									if not (child.title == "Dora") then -- 1016
										goto _continue_0 -- 1016
									end -- 1016
									local title = zh and "zh-Hans" or "en" -- 1017
									do -- 1018
										local _accum_0 = { } -- 1018
										local _len_0 = 1 -- 1018
										local _list_1 = child.children -- 1018
										for _index_1 = 1, #_list_1 do -- 1018
											local c = _list_1[_index_1] -- 1018
											if c.title ~= title then -- 1018
												_accum_0[_len_0] = c -- 1018
												_len_0 = _len_0 + 1 -- 1018
											end -- 1018
										end -- 1018
										child.children = _accum_0 -- 1018
									end -- 1018
									break -- 1019
									::_continue_0:: -- 1016
								end -- 1015
							else -- 1021
								local _accum_0 = { } -- 1021
								local _len_0 = 1 -- 1021
								local _list_0 = _with_0.children -- 1021
								for _index_0 = 1, #_list_0 do -- 1021
									local child = _list_0[_index_0] -- 1021
									if child.title ~= "Dora" then -- 1021
										_accum_0[_len_0] = child -- 1021
										_len_0 = _len_0 + 1 -- 1021
									end -- 1021
								end -- 1021
								_with_0.children = _accum_0 -- 1021
							end -- 1014
							return _with_0 -- 1012
						end)(), -- 1012
						(function() -- 1022
							if engineDev then -- 1022
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1023
								local _obj_0 = _with_0.children -- 1024
								_obj_0[#_obj_0 + 1] = { -- 1025
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1025
									dir = false, -- 1026
									builtin = true, -- 1027
									title = "init.yue" -- 1028
								} -- 1024
								return _with_0 -- 1023
							end -- 1022
						end)() -- 1022
					} -- 1003
				} -- 998
			} -- 1032
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1032
			local _idx_0 = #_tab_0 + 1 -- 1032
			for _index_0 = 1, #_obj_0 do -- 1032
				local _value_0 = _obj_0[_index_0] -- 1032
				_tab_0[_idx_0] = _value_0 -- 1032
				_idx_0 = _idx_0 + 1 -- 1032
			end -- 1032
			return _tab_0 -- 998
		end)() -- 997
	} -- 992
end) -- 929
HttpServer:postSchedule("/run", function(req) -- 1036
	do -- 1037
		local _type_0 = type(req) -- 1037
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1037
		if _tab_0 then -- 1037
			local file -- 1037
			do -- 1037
				local _obj_0 = req.body -- 1037
				local _type_1 = type(_obj_0) -- 1037
				if "table" == _type_1 or "userdata" == _type_1 then -- 1037
					file = _obj_0.file -- 1037
				end -- 1037
			end -- 1037
			local asProj -- 1037
			do -- 1037
				local _obj_0 = req.body -- 1037
				local _type_1 = type(_obj_0) -- 1037
				if "table" == _type_1 or "userdata" == _type_1 then -- 1037
					asProj = _obj_0.asProj -- 1037
				end -- 1037
			end -- 1037
			if file ~= nil and asProj ~= nil then -- 1037
				if not Content:isAbsolutePath(file) then -- 1038
					local devFile = Path(Content.writablePath, file) -- 1039
					if Content:exist(devFile) then -- 1040
						file = devFile -- 1040
					end -- 1040
				end -- 1038
				local Entry = require("Script.Dev.Entry") -- 1041
				local workDir -- 1042
				if asProj then -- 1043
					workDir = getProjectDirFromFile(file) -- 1044
					if workDir then -- 1044
						Entry.allClear() -- 1045
						local target = Path(workDir, "init") -- 1046
						local success, err = Entry.enterEntryAsync({ -- 1047
							entryName = "Project", -- 1047
							fileName = target -- 1047
						}) -- 1047
						target = Path:getName(Path:getPath(target)) -- 1048
						return { -- 1049
							success = success, -- 1049
							target = target, -- 1049
							err = err -- 1049
						} -- 1049
					end -- 1044
				else -- 1051
					workDir = getProjectDirFromFile(file) -- 1051
				end -- 1043
				Entry.allClear() -- 1052
				file = Path:replaceExt(file, "") -- 1053
				local success, err = Entry.enterEntryAsync({ -- 1055
					entryName = Path:getName(file), -- 1055
					fileName = file, -- 1056
					workDir = workDir -- 1057
				}) -- 1054
				return { -- 1058
					success = success, -- 1058
					err = err -- 1058
				} -- 1058
			end -- 1037
		end -- 1037
	end -- 1037
	return { -- 1036
		success = false -- 1036
	} -- 1036
end) -- 1036
HttpServer:postSchedule("/stop", function() -- 1060
	local Entry = require("Script.Dev.Entry") -- 1061
	return { -- 1062
		success = Entry.stop() -- 1062
	} -- 1062
end) -- 1060
local minifyAsync -- 1064
minifyAsync = function(sourcePath, minifyPath) -- 1064
	if not Content:exist(sourcePath) then -- 1065
		return -- 1065
	end -- 1065
	local Entry = require("Script.Dev.Entry") -- 1066
	local errors = { } -- 1067
	local files = Entry.getAllFiles(sourcePath, { -- 1068
		"lua" -- 1068
	}, true) -- 1068
	do -- 1069
		local _accum_0 = { } -- 1069
		local _len_0 = 1 -- 1069
		for _index_0 = 1, #files do -- 1069
			local file = files[_index_0] -- 1069
			if file:sub(1, 1) ~= '.' then -- 1069
				_accum_0[_len_0] = file -- 1069
				_len_0 = _len_0 + 1 -- 1069
			end -- 1069
		end -- 1069
		files = _accum_0 -- 1069
	end -- 1069
	local paths -- 1070
	do -- 1070
		local _tbl_0 = { } -- 1070
		for _index_0 = 1, #files do -- 1070
			local file = files[_index_0] -- 1070
			_tbl_0[Path:getPath(file)] = true -- 1070
		end -- 1070
		paths = _tbl_0 -- 1070
	end -- 1070
	for path in pairs(paths) do -- 1071
		Content:mkdir(Path(minifyPath, path)) -- 1071
	end -- 1071
	local _ <close> = setmetatable({ }, { -- 1072
		__close = function() -- 1072
			package.loaded["luaminify.FormatMini"] = nil -- 1073
			package.loaded["luaminify.ParseLua"] = nil -- 1074
			package.loaded["luaminify.Scope"] = nil -- 1075
			package.loaded["luaminify.Util"] = nil -- 1076
		end -- 1072
	}) -- 1072
	local FormatMini -- 1077
	do -- 1077
		local _obj_0 = require("luaminify") -- 1077
		FormatMini = _obj_0.FormatMini -- 1077
	end -- 1077
	local fileCount = #files -- 1078
	local count = 0 -- 1079
	for _index_0 = 1, #files do -- 1080
		local file = files[_index_0] -- 1080
		thread(function() -- 1081
			local _ <close> = setmetatable({ }, { -- 1082
				__close = function() -- 1082
					count = count + 1 -- 1082
				end -- 1082
			}) -- 1082
			local input = Path(sourcePath, file) -- 1083
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1084
			if Content:exist(input) then -- 1085
				local sourceCodes = Content:loadAsync(input) -- 1086
				local res, err = FormatMini(sourceCodes) -- 1087
				if res then -- 1088
					Content:saveAsync(output, res) -- 1089
					return print("Minify " .. tostring(file)) -- 1090
				else -- 1092
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1092
				end -- 1088
			else -- 1094
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1094
			end -- 1085
		end) -- 1081
		sleep() -- 1095
	end -- 1080
	wait(function() -- 1096
		return count == fileCount -- 1096
	end) -- 1096
	if #errors > 0 then -- 1097
		print(table.concat(errors, '\n')) -- 1098
	end -- 1097
	print("Obfuscation done.") -- 1099
	return files -- 1100
end -- 1064
local zipping = false -- 1102
HttpServer:postSchedule("/zip", function(req) -- 1104
	do -- 1105
		local _type_0 = type(req) -- 1105
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1105
		if _tab_0 then -- 1105
			local path -- 1105
			do -- 1105
				local _obj_0 = req.body -- 1105
				local _type_1 = type(_obj_0) -- 1105
				if "table" == _type_1 or "userdata" == _type_1 then -- 1105
					path = _obj_0.path -- 1105
				end -- 1105
			end -- 1105
			local zipFile -- 1105
			do -- 1105
				local _obj_0 = req.body -- 1105
				local _type_1 = type(_obj_0) -- 1105
				if "table" == _type_1 or "userdata" == _type_1 then -- 1105
					zipFile = _obj_0.zipFile -- 1105
				end -- 1105
			end -- 1105
			local obfuscated -- 1105
			do -- 1105
				local _obj_0 = req.body -- 1105
				local _type_1 = type(_obj_0) -- 1105
				if "table" == _type_1 or "userdata" == _type_1 then -- 1105
					obfuscated = _obj_0.obfuscated -- 1105
				end -- 1105
			end -- 1105
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1105
				if zipping then -- 1106
					goto failed -- 1106
				end -- 1106
				zipping = true -- 1107
				local _ <close> = setmetatable({ }, { -- 1108
					__close = function() -- 1108
						zipping = false -- 1108
					end -- 1108
				}) -- 1108
				if not Content:exist(path) then -- 1109
					goto failed -- 1109
				end -- 1109
				Content:mkdir(Path:getPath(zipFile)) -- 1110
				if obfuscated then -- 1111
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1112
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1113
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1114
					Content:remove(scriptPath) -- 1115
					Content:remove(obfuscatedPath) -- 1116
					Content:remove(tempPath) -- 1117
					Content:mkdir(scriptPath) -- 1118
					Content:mkdir(obfuscatedPath) -- 1119
					Content:mkdir(tempPath) -- 1120
					if not Content:copyAsync(path, tempPath) then -- 1121
						goto failed -- 1121
					end -- 1121
					local Entry = require("Script.Dev.Entry") -- 1122
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1123
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1124
						"tl", -- 1124
						"yue", -- 1124
						"lua", -- 1124
						"ts", -- 1124
						"tsx", -- 1124
						"vs", -- 1124
						"bl", -- 1124
						"xml", -- 1124
						"wa", -- 1124
						"mod" -- 1124
					}, true) -- 1124
					for _index_0 = 1, #scriptFiles do -- 1125
						local file = scriptFiles[_index_0] -- 1125
						Content:remove(Path(tempPath, file)) -- 1126
					end -- 1125
					for _index_0 = 1, #luaFiles do -- 1127
						local file = luaFiles[_index_0] -- 1127
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1128
					end -- 1127
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1129
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1130
					end) then -- 1129
						goto failed -- 1129
					end -- 1129
					return { -- 1131
						success = true -- 1131
					} -- 1131
				else -- 1133
					return { -- 1133
						success = Content:zipAsync(path, zipFile, function(file) -- 1133
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1134
						end) -- 1133
					} -- 1133
				end -- 1111
			end -- 1105
		end -- 1105
	end -- 1105
	::failed:: -- 1135
	return { -- 1104
		success = false -- 1104
	} -- 1104
end) -- 1104
HttpServer:postSchedule("/unzip", function(req) -- 1137
	do -- 1138
		local _type_0 = type(req) -- 1138
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1138
		if _tab_0 then -- 1138
			local zipFile -- 1138
			do -- 1138
				local _obj_0 = req.body -- 1138
				local _type_1 = type(_obj_0) -- 1138
				if "table" == _type_1 or "userdata" == _type_1 then -- 1138
					zipFile = _obj_0.zipFile -- 1138
				end -- 1138
			end -- 1138
			local path -- 1138
			do -- 1138
				local _obj_0 = req.body -- 1138
				local _type_1 = type(_obj_0) -- 1138
				if "table" == _type_1 or "userdata" == _type_1 then -- 1138
					path = _obj_0.path -- 1138
				end -- 1138
			end -- 1138
			if zipFile ~= nil and path ~= nil then -- 1138
				return { -- 1139
					success = Content:unzipAsync(zipFile, path, function(file) -- 1139
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1140
					end) -- 1139
				} -- 1139
			end -- 1138
		end -- 1138
	end -- 1138
	return { -- 1137
		success = false -- 1137
	} -- 1137
end) -- 1137
HttpServer:post("/editing-info", function(req) -- 1142
	local Entry = require("Script.Dev.Entry") -- 1143
	local config = Entry.getConfig() -- 1144
	local _type_0 = type(req) -- 1145
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1145
	local _match_0 = false -- 1145
	if _tab_0 then -- 1145
		local editingInfo -- 1145
		do -- 1145
			local _obj_0 = req.body -- 1145
			local _type_1 = type(_obj_0) -- 1145
			if "table" == _type_1 or "userdata" == _type_1 then -- 1145
				editingInfo = _obj_0.editingInfo -- 1145
			end -- 1145
		end -- 1145
		if editingInfo ~= nil then -- 1145
			_match_0 = true -- 1145
			config.editingInfo = editingInfo -- 1146
			return { -- 1147
				success = true -- 1147
			} -- 1147
		end -- 1145
	end -- 1145
	if not _match_0 then -- 1145
		if not (config.editingInfo ~= nil) then -- 1149
			local folder -- 1150
			if App.locale:match('^zh') then -- 1150
				folder = 'zh-Hans' -- 1150
			else -- 1150
				folder = 'en' -- 1150
			end -- 1150
			config.editingInfo = json.encode({ -- 1152
				index = 0, -- 1152
				files = { -- 1154
					{ -- 1155
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1155
						title = "welcome.md" -- 1156
					} -- 1154
				} -- 1153
			}) -- 1151
		end -- 1149
		return { -- 1160
			success = true, -- 1160
			editingInfo = config.editingInfo -- 1160
		} -- 1160
	end -- 1145
end) -- 1142
HttpServer:post("/command", function(req) -- 1162
	do -- 1163
		local _type_0 = type(req) -- 1163
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1163
		if _tab_0 then -- 1163
			local code -- 1163
			do -- 1163
				local _obj_0 = req.body -- 1163
				local _type_1 = type(_obj_0) -- 1163
				if "table" == _type_1 or "userdata" == _type_1 then -- 1163
					code = _obj_0.code -- 1163
				end -- 1163
			end -- 1163
			local log -- 1163
			do -- 1163
				local _obj_0 = req.body -- 1163
				local _type_1 = type(_obj_0) -- 1163
				if "table" == _type_1 or "userdata" == _type_1 then -- 1163
					log = _obj_0.log -- 1163
				end -- 1163
			end -- 1163
			if code ~= nil and log ~= nil then -- 1163
				emit("AppCommand", code, log) -- 1164
				return { -- 1165
					success = true -- 1165
				} -- 1165
			end -- 1163
		end -- 1163
	end -- 1163
	return { -- 1162
		success = false -- 1162
	} -- 1162
end) -- 1162
HttpServer:post("/log/save", function() -- 1167
	local folder = ".download" -- 1168
	local fullLogFile = "dora_full_logs.txt" -- 1169
	local fullFolder = Path(Content.writablePath, folder) -- 1170
	Content:mkdir(fullFolder) -- 1171
	local logPath = Path(fullFolder, fullLogFile) -- 1172
	if App:saveLog(logPath) then -- 1173
		return { -- 1174
			success = true, -- 1174
			path = Path(folder, fullLogFile) -- 1174
		} -- 1174
	end -- 1173
	return { -- 1167
		success = false -- 1167
	} -- 1167
end) -- 1167
HttpServer:post("/yarn/check", function(req) -- 1176
	local yarncompile = require("yarncompile") -- 1177
	do -- 1178
		local _type_0 = type(req) -- 1178
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1178
		if _tab_0 then -- 1178
			local code -- 1178
			do -- 1178
				local _obj_0 = req.body -- 1178
				local _type_1 = type(_obj_0) -- 1178
				if "table" == _type_1 or "userdata" == _type_1 then -- 1178
					code = _obj_0.code -- 1178
				end -- 1178
			end -- 1178
			if code ~= nil then -- 1178
				local jsonObject = json.decode(code) -- 1179
				if jsonObject then -- 1179
					local errors = { } -- 1180
					local _list_0 = jsonObject.nodes -- 1181
					for _index_0 = 1, #_list_0 do -- 1181
						local node = _list_0[_index_0] -- 1181
						local title, body = node.title, node.body -- 1182
						local luaCode, err = yarncompile(body) -- 1183
						if not luaCode then -- 1183
							errors[#errors + 1] = title .. ":" .. err -- 1184
						end -- 1183
					end -- 1181
					return { -- 1185
						success = true, -- 1185
						syntaxError = table.concat(errors, "\n\n") -- 1185
					} -- 1185
				end -- 1179
			end -- 1178
		end -- 1178
	end -- 1178
	return { -- 1176
		success = false -- 1176
	} -- 1176
end) -- 1176
HttpServer:post("/yarn/check-file", function(req) -- 1187
	local yarncompile = require("yarncompile") -- 1188
	do -- 1189
		local _type_0 = type(req) -- 1189
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1189
		if _tab_0 then -- 1189
			local code -- 1189
			do -- 1189
				local _obj_0 = req.body -- 1189
				local _type_1 = type(_obj_0) -- 1189
				if "table" == _type_1 or "userdata" == _type_1 then -- 1189
					code = _obj_0.code -- 1189
				end -- 1189
			end -- 1189
			if code ~= nil then -- 1189
				local res, _, err = yarncompile(code, true) -- 1190
				if not res then -- 1190
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1191
					return { -- 1192
						success = false, -- 1192
						message = message, -- 1192
						line = line, -- 1192
						column = column, -- 1192
						node = node -- 1192
					} -- 1192
				end -- 1190
			end -- 1189
		end -- 1189
	end -- 1189
	return { -- 1187
		success = true -- 1187
	} -- 1187
end) -- 1187
local getWaProjectDirFromFile -- 1194
getWaProjectDirFromFile = function(file) -- 1194
	local writablePath = Content.writablePath -- 1195
	local parent, current -- 1196
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1196
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1197
	else -- 1199
		parent, current = nil, nil -- 1199
	end -- 1196
	if not current then -- 1200
		return nil -- 1200
	end -- 1200
	repeat -- 1201
		current = Path:getPath(current) -- 1202
		if current == "" then -- 1203
			break -- 1203
		end -- 1203
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1204
		for _index_0 = 1, #_list_0 do -- 1204
			local f = _list_0[_index_0] -- 1204
			if Path:getFilename(f):lower() == "wa.mod" then -- 1205
				return Path(parent, current, Path:getPath(f)) -- 1206
			end -- 1205
		end -- 1204
	until false -- 1201
	return nil -- 1208
end -- 1194
HttpServer:postSchedule("/wa/build", function(req) -- 1210
	do -- 1211
		local _type_0 = type(req) -- 1211
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1211
		if _tab_0 then -- 1211
			local path -- 1211
			do -- 1211
				local _obj_0 = req.body -- 1211
				local _type_1 = type(_obj_0) -- 1211
				if "table" == _type_1 or "userdata" == _type_1 then -- 1211
					path = _obj_0.path -- 1211
				end -- 1211
			end -- 1211
			if path ~= nil then -- 1211
				local projDir = getWaProjectDirFromFile(path) -- 1212
				if projDir then -- 1212
					local message = Wasm:buildWaAsync(projDir) -- 1213
					if message == "" then -- 1214
						return { -- 1215
							success = true -- 1215
						} -- 1215
					else -- 1217
						return { -- 1217
							success = false, -- 1217
							message = message -- 1217
						} -- 1217
					end -- 1214
				else -- 1219
					return { -- 1219
						success = false, -- 1219
						message = 'Wa file needs a project' -- 1219
					} -- 1219
				end -- 1212
			end -- 1211
		end -- 1211
	end -- 1211
	return { -- 1220
		success = false, -- 1220
		message = 'failed to build' -- 1220
	} -- 1220
end) -- 1210
HttpServer:postSchedule("/wa/format", function(req) -- 1222
	do -- 1223
		local _type_0 = type(req) -- 1223
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1223
		if _tab_0 then -- 1223
			local file -- 1223
			do -- 1223
				local _obj_0 = req.body -- 1223
				local _type_1 = type(_obj_0) -- 1223
				if "table" == _type_1 or "userdata" == _type_1 then -- 1223
					file = _obj_0.file -- 1223
				end -- 1223
			end -- 1223
			if file ~= nil then -- 1223
				local code = Wasm:formatWaAsync(file) -- 1224
				if code == "" then -- 1225
					return { -- 1226
						success = false -- 1226
					} -- 1226
				else -- 1228
					return { -- 1228
						success = true, -- 1228
						code = code -- 1228
					} -- 1228
				end -- 1225
			end -- 1223
		end -- 1223
	end -- 1223
	return { -- 1229
		success = false -- 1229
	} -- 1229
end) -- 1222
HttpServer:postSchedule("/wa/create", function(req) -- 1231
	do -- 1232
		local _type_0 = type(req) -- 1232
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1232
		if _tab_0 then -- 1232
			local path -- 1232
			do -- 1232
				local _obj_0 = req.body -- 1232
				local _type_1 = type(_obj_0) -- 1232
				if "table" == _type_1 or "userdata" == _type_1 then -- 1232
					path = _obj_0.path -- 1232
				end -- 1232
			end -- 1232
			if path ~= nil then -- 1232
				if not Content:exist(Path:getPath(path)) then -- 1233
					return { -- 1234
						success = false, -- 1234
						message = "target path not existed" -- 1234
					} -- 1234
				end -- 1233
				if Content:exist(path) then -- 1235
					return { -- 1236
						success = false, -- 1236
						message = "target project folder existed" -- 1236
					} -- 1236
				end -- 1235
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1237
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1238
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1239
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1240
					return { -- 1243
						success = false, -- 1243
						message = "missing template project" -- 1243
					} -- 1243
				end -- 1240
				if not Content:mkdir(path) then -- 1244
					return { -- 1245
						success = false, -- 1245
						message = "failed to create project folder" -- 1245
					} -- 1245
				end -- 1244
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1246
					Content:remove(path) -- 1247
					return { -- 1248
						success = false, -- 1248
						message = "failed to copy template" -- 1248
					} -- 1248
				end -- 1246
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1249
					Content:remove(path) -- 1250
					return { -- 1251
						success = false, -- 1251
						message = "failed to copy template" -- 1251
					} -- 1251
				end -- 1249
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1252
					Content:remove(path) -- 1253
					return { -- 1254
						success = false, -- 1254
						message = "failed to copy template" -- 1254
					} -- 1254
				end -- 1252
				return { -- 1255
					success = true -- 1255
				} -- 1255
			end -- 1232
		end -- 1232
	end -- 1232
	return { -- 1231
		success = false, -- 1231
		message = "invalid call" -- 1231
	} -- 1231
end) -- 1231
local _anon_func_5 = function(path) -- 1264
	local _val_0 = Path:getExt(path) -- 1264
	return "ts" == _val_0 or "tsx" == _val_0 -- 1264
end -- 1264
local _anon_func_6 = function(f) -- 1294
	local _val_0 = Path:getExt(f) -- 1294
	return "ts" == _val_0 or "tsx" == _val_0 -- 1294
end -- 1294
HttpServer:postSchedule("/ts/build", function(req) -- 1257
	do -- 1258
		local _type_0 = type(req) -- 1258
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1258
		if _tab_0 then -- 1258
			local path -- 1258
			do -- 1258
				local _obj_0 = req.body -- 1258
				local _type_1 = type(_obj_0) -- 1258
				if "table" == _type_1 or "userdata" == _type_1 then -- 1258
					path = _obj_0.path -- 1258
				end -- 1258
			end -- 1258
			if path ~= nil then -- 1258
				if HttpServer.wsConnectionCount == 0 then -- 1259
					return { -- 1260
						success = false, -- 1260
						message = "Web IDE not connected" -- 1260
					} -- 1260
				end -- 1259
				if not Content:exist(path) then -- 1261
					return { -- 1262
						success = false, -- 1262
						message = "path not existed" -- 1262
					} -- 1262
				end -- 1261
				if not Content:isdir(path) then -- 1263
					if not (_anon_func_5(path)) then -- 1264
						return { -- 1265
							success = false, -- 1265
							message = "expecting a TypeScript file" -- 1265
						} -- 1265
					end -- 1264
					local messages = { } -- 1266
					local content = Content:load(path) -- 1267
					if not content then -- 1268
						return { -- 1269
							success = false, -- 1269
							message = "failed to read file" -- 1269
						} -- 1269
					end -- 1268
					emit("AppWS", "Send", json.encode({ -- 1270
						name = "UpdateTSCode", -- 1270
						file = path, -- 1270
						content = content -- 1270
					})) -- 1270
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1271
						local done = false -- 1272
						do -- 1273
							local _with_0 = Node() -- 1273
							_with_0:gslot("AppWS", function(event) -- 1274
								if event.type == "Receive" then -- 1275
									_with_0:removeFromParent() -- 1276
									local res = json.decode(event.msg) -- 1277
									if res then -- 1277
										if res.name == "TranspileTS" then -- 1278
											if res.success then -- 1279
												local luaFile = Path:replaceExt(path, "lua") -- 1280
												Content:save(luaFile, res.luaCode) -- 1281
												messages[#messages + 1] = { -- 1282
													success = true, -- 1282
													file = path -- 1282
												} -- 1282
											else -- 1284
												messages[#messages + 1] = { -- 1284
													success = false, -- 1284
													file = path, -- 1284
													message = res.message -- 1284
												} -- 1284
											end -- 1279
											done = true -- 1285
										end -- 1278
									end -- 1277
								end -- 1275
							end) -- 1274
						end -- 1273
						emit("AppWS", "Send", json.encode({ -- 1286
							name = "TranspileTS", -- 1286
							file = path, -- 1286
							content = content -- 1286
						})) -- 1286
						wait(function() -- 1287
							return done -- 1287
						end) -- 1287
					end -- 1271
					return { -- 1288
						success = true, -- 1288
						messages = messages -- 1288
					} -- 1288
				else -- 1290
					local files = Content:getAllFiles(path) -- 1290
					local fileData = { } -- 1291
					local messages = { } -- 1292
					for _index_0 = 1, #files do -- 1293
						local f = files[_index_0] -- 1293
						if not (_anon_func_6(f)) then -- 1294
							goto _continue_0 -- 1294
						end -- 1294
						local file = Path(path, f) -- 1295
						local content = Content:load(file) -- 1296
						if content then -- 1296
							fileData[file] = content -- 1297
							emit("AppWS", "Send", json.encode({ -- 1298
								name = "UpdateTSCode", -- 1298
								file = file, -- 1298
								content = content -- 1298
							})) -- 1298
						else -- 1300
							messages[#messages + 1] = { -- 1300
								success = false, -- 1300
								file = file, -- 1300
								message = "failed to read file" -- 1300
							} -- 1300
						end -- 1296
						::_continue_0:: -- 1294
					end -- 1293
					for file, content in pairs(fileData) do -- 1301
						if "d" == Path:getExt(Path:getName(file)) then -- 1302
							goto _continue_1 -- 1302
						end -- 1302
						local done = false -- 1303
						do -- 1304
							local _with_0 = Node() -- 1304
							_with_0:gslot("AppWS", function(event) -- 1305
								if event.type == "Receive" then -- 1306
									_with_0:removeFromParent() -- 1307
									local res = json.decode(event.msg) -- 1308
									if res then -- 1308
										if res.name == "TranspileTS" then -- 1309
											if res.success then -- 1310
												local luaFile = Path:replaceExt(file, "lua") -- 1311
												Content:save(luaFile, res.luaCode) -- 1312
												messages[#messages + 1] = { -- 1313
													success = true, -- 1313
													file = file -- 1313
												} -- 1313
											else -- 1315
												messages[#messages + 1] = { -- 1315
													success = false, -- 1315
													file = file, -- 1315
													message = res.message -- 1315
												} -- 1315
											end -- 1310
											done = true -- 1316
										end -- 1309
									end -- 1308
								end -- 1306
							end) -- 1305
						end -- 1304
						emit("AppWS", "Send", json.encode({ -- 1317
							name = "TranspileTS", -- 1317
							file = file, -- 1317
							content = content -- 1317
						})) -- 1317
						wait(function() -- 1318
							return done -- 1318
						end) -- 1318
						::_continue_1:: -- 1302
					end -- 1301
					return { -- 1319
						success = true, -- 1319
						messages = messages -- 1319
					} -- 1319
				end -- 1263
			end -- 1258
		end -- 1258
	end -- 1258
	return { -- 1257
		success = false -- 1257
	} -- 1257
end) -- 1257
HttpServer:post("/download", function(req) -- 1321
	do -- 1322
		local _type_0 = type(req) -- 1322
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1322
		if _tab_0 then -- 1322
			local url -- 1322
			do -- 1322
				local _obj_0 = req.body -- 1322
				local _type_1 = type(_obj_0) -- 1322
				if "table" == _type_1 or "userdata" == _type_1 then -- 1322
					url = _obj_0.url -- 1322
				end -- 1322
			end -- 1322
			local target -- 1322
			do -- 1322
				local _obj_0 = req.body -- 1322
				local _type_1 = type(_obj_0) -- 1322
				if "table" == _type_1 or "userdata" == _type_1 then -- 1322
					target = _obj_0.target -- 1322
				end -- 1322
			end -- 1322
			if url ~= nil and target ~= nil then -- 1322
				local Entry = require("Script.Dev.Entry") -- 1323
				Entry.downloadFile(url, target) -- 1324
				return { -- 1325
					success = true -- 1325
				} -- 1325
			end -- 1322
		end -- 1322
	end -- 1322
	return { -- 1321
		success = false -- 1321
	} -- 1321
end) -- 1321
local status = { } -- 1327
_module_0 = status -- 1328
thread(function() -- 1330
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1331
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1332
	if Content:exist(doraWeb) then -- 1333
		local needReload -- 1334
		if Content:exist(doraReady) then -- 1334
			needReload = App.version ~= Content:load(doraReady) -- 1335
		else -- 1336
			needReload = true -- 1336
		end -- 1334
		if needReload then -- 1337
			Content:remove(Path(Content.appPath, ".www")) -- 1338
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1339
			Content:save(doraReady, App.version) -- 1343
			print("Dora Dora is ready!") -- 1344
		end -- 1337
	end -- 1333
	if HttpServer:start(8866) then -- 1345
		local localIP = HttpServer.localIP -- 1346
		if localIP == "" then -- 1347
			localIP = "localhost" -- 1347
		end -- 1347
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1348
		return HttpServer:startWS(8868) -- 1349
	else -- 1351
		status.url = nil -- 1351
		return print("8866 Port not available!") -- 1352
	end -- 1345
end) -- 1330
return _module_0 -- 1
