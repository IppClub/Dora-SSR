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
HttpServer:stop() -- 12
HttpServer.wwwPath = Path(Content.appPath, ".www") -- 14
HttpServer.authRequired = true -- 16
HttpServer.authToken = "" -- 17
local authFailedCount = 0 -- 19
local authLockedUntil = 0.0 -- 20
local PendingTTL = 60 -- 22
local genAuthToken -- 24
genAuthToken = function() -- 24
	local parts = { } -- 25
	for _ = 1, 4 do -- 26
		parts[#parts + 1] = string.format("%08x", math.random(0, 0x7fffffff)) -- 27
	end -- 26
	return table.concat(parts) -- 28
end -- 24
local genSessionId -- 30
genSessionId = function() -- 30
	local parts = { } -- 31
	for _ = 1, 2 do -- 32
		parts[#parts + 1] = string.format("%08x", math.random(0, 0x7fffffff)) -- 33
	end -- 32
	return table.concat(parts) -- 34
end -- 30
local genConfirmCode -- 36
genConfirmCode = function() -- 36
	return string.format("%04d", math.random(0, 9999)) -- 37
end -- 36
HttpServer:post("/auth", function(req) -- 39
	local Entry = require("Script.Dev.Entry") -- 40
	local AuthSession = Entry.AuthSession -- 41
	local authCode = Entry.getAuthCode() -- 42
	local now = os.time() -- 43
	if now < authLockedUntil then -- 44
		return { -- 45
			success = false, -- 45
			message = "locked", -- 45
			retryAfter = authLockedUntil - now -- 45
		} -- 45
	end -- 44
	local code = nil -- 46
	do -- 48
		local _type_0 = type(req) -- 48
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 48
		if _tab_0 then -- 48
			do -- 48
				local _obj_0 = req.body -- 48
				local _type_1 = type(_obj_0) -- 48
				if "table" == _type_1 or "userdata" == _type_1 then -- 48
					code = _obj_0.code -- 48
				end -- 48
			end -- 48
			if code ~= nil then -- 48
				code = code -- 49
			end -- 48
		end -- 47
	end -- 47
	if code and tostring(code) == authCode then -- 50
		authFailedCount = 0 -- 51
		Entry.invalidateAuthCode() -- 52
		do -- 53
			local pending = AuthSession.getPending() -- 53
			if pending then -- 53
				if now < pending.expiresAt and not pending.approved then -- 54
					return { -- 55
						success = true, -- 55
						pending = true, -- 55
						sessionId = pending.sessionId, -- 55
						confirmCode = pending.confirmCode, -- 55
						expiresIn = pending.expiresAt - now -- 55
					} -- 55
				end -- 54
			end -- 53
		end -- 53
		local sessionId = genSessionId() -- 56
		local confirmCode = genConfirmCode() -- 57
		AuthSession.beginPending(sessionId, confirmCode, now + PendingTTL, PendingTTL) -- 58
		return { -- 59
			success = true, -- 59
			pending = true, -- 59
			sessionId = sessionId, -- 59
			confirmCode = confirmCode, -- 59
			expiresIn = PendingTTL -- 59
		} -- 59
	else -- 61
		authFailedCount = authFailedCount + 1 -- 61
		if authFailedCount >= 3 then -- 62
			authFailedCount = 0 -- 63
			authLockedUntil = now + 30 -- 64
			return { -- 65
				success = false, -- 65
				message = "locked", -- 65
				retryAfter = 30 -- 65
			} -- 65
		end -- 62
		return { -- 66
			success = false, -- 66
			message = "invalid code" -- 66
		} -- 66
	end -- 50
end) -- 39
HttpServer:post("/auth/confirm", function(req) -- 68
	local now = os.time() -- 69
	local sessionId = nil -- 70
	do -- 72
		local _type_0 = type(req) -- 72
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 72
		if _tab_0 then -- 72
			do -- 72
				local _obj_0 = req.body -- 72
				local _type_1 = type(_obj_0) -- 72
				if "table" == _type_1 or "userdata" == _type_1 then -- 72
					sessionId = _obj_0.sessionId -- 72
				end -- 72
			end -- 72
			if sessionId ~= nil then -- 72
				sessionId = sessionId -- 73
			end -- 72
		end -- 71
	end -- 71
	if not sessionId then -- 74
		return { -- 75
			success = false, -- 75
			message = "invalid session" -- 75
		} -- 75
	end -- 74
	local Entry = require("Script.Dev.Entry") -- 76
	local AuthSession = Entry.AuthSession -- 77
	do -- 78
		local pending = AuthSession.getPending() -- 78
		if pending then -- 78
			if pending.sessionId ~= sessionId then -- 79
				return { -- 80
					success = false, -- 80
					message = "invalid session" -- 80
				} -- 80
			end -- 79
			if now >= pending.expiresAt then -- 81
				AuthSession.clearPending() -- 82
				return { -- 83
					success = false, -- 83
					message = "expired" -- 83
				} -- 83
			end -- 81
			if pending.approved then -- 84
				local secret = genAuthToken() -- 85
				HttpServer.authToken = tostring(sessionId) .. ":" .. tostring(secret) -- 86
				AuthSession.setSession(sessionId, secret) -- 87
				AuthSession.clearPending() -- 88
				return { -- 89
					success = true, -- 89
					sessionId = sessionId, -- 89
					sessionSecret = secret -- 89
				} -- 89
			end -- 84
			return { -- 90
				success = false, -- 90
				message = "pending", -- 90
				retryAfter = 2 -- 90
			} -- 90
		end -- 78
	end -- 78
	return { -- 91
		success = false, -- 91
		message = "invalid session" -- 91
	} -- 91
end) -- 68
local LintYueGlobals, CheckTIC80Code -- 93
do -- 93
	local _obj_0 = require("Utils") -- 93
	LintYueGlobals, CheckTIC80Code = _obj_0.LintYueGlobals, _obj_0.CheckTIC80Code -- 93
end -- 93
local getProjectDirFromFile -- 95
getProjectDirFromFile = function(file) -- 95
	local writablePath, assetPath = Content.writablePath, Content.assetPath -- 96
	local parent, current -- 97
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 97
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 98
	elseif (".." ~= Path:getRelative(file, assetPath):sub(1, 2)) and assetPath == file:sub(1, #assetPath) then -- 99
		local dir = Path(assetPath, "Script") -- 100
		parent, current = dir, Path:getRelative(file, dir) -- 101
	else -- 103
		parent, current = nil, nil -- 103
	end -- 97
	if not current then -- 104
		return nil -- 104
	end -- 104
	repeat -- 105
		current = Path:getPath(current) -- 106
		if current == "" then -- 107
			break -- 107
		end -- 107
		local _list_0 = Content:getFiles(Path(parent, current)) -- 108
		for _index_0 = 1, #_list_0 do -- 108
			local f = _list_0[_index_0] -- 108
			if Path:getName(f):lower() == "init" then -- 109
				return Path(parent, current, Path:getPath(f)) -- 110
			end -- 109
		end -- 108
	until false -- 105
	return nil -- 112
end -- 95
local getSearchPath -- 114
getSearchPath = function(file) -- 114
	do -- 115
		local dir = getProjectDirFromFile(file) -- 115
		if dir then -- 115
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 116
		end -- 115
	end -- 115
	return "" -- 114
end -- 114
local getSearchFolders -- 118
getSearchFolders = function(file) -- 118
	do -- 119
		local dir = getProjectDirFromFile(file) -- 119
		if dir then -- 119
			return { -- 121
				Path(dir, "Script"), -- 121
				dir -- 122
			} -- 120
		end -- 119
	end -- 119
	return { } -- 118
end -- 118
local disabledCheckForLua = { -- 125
	"incompatible number of returns", -- 125
	"unknown", -- 126
	"cannot index", -- 127
	"module not found", -- 128
	"don't know how to resolve", -- 129
	"ContainerItem", -- 130
	"cannot resolve a type", -- 131
	"invalid key", -- 132
	"inconsistent index type", -- 133
	"cannot use operator", -- 134
	"attempting ipairs loop", -- 135
	"expects record or nominal", -- 136
	"variable is not being assigned", -- 137
	"<invalid type>", -- 138
	"<any type>", -- 139
	"using the '#' operator", -- 140
	"can't match a record", -- 141
	"redeclaration of variable", -- 142
	"cannot apply pairs", -- 143
	"not a function", -- 144
	"to%-be%-closed" -- 145
} -- 124
local yueCheck -- 147
yueCheck = function(file, content, lax) -- 147
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 148
	if isTIC80 then -- 149
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 150
	end -- 149
	local searchPath = getSearchPath(file) -- 151
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 152
	local info = { } -- 153
	local globals = { } -- 154
	for _index_0 = 1, #checkResult do -- 155
		local _des_0 = checkResult[_index_0] -- 155
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 155
		if "error" == t then -- 156
			info[#info + 1] = { -- 157
				"syntax", -- 157
				file, -- 157
				line, -- 157
				col, -- 157
				msg -- 157
			} -- 157
		elseif "global" == t then -- 158
			globals[#globals + 1] = { -- 159
				msg, -- 159
				line, -- 159
				col -- 159
			} -- 159
		end -- 156
	end -- 155
	if luaCodes then -- 160
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 161
		if success then -- 162
			if lax then -- 163
				luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 164
				if not (lintResult == "") then -- 165
					lintResult = lintResult .. "\n" -- 165
				end -- 165
				luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 166
			else -- 168
				luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(luaCodes) -- 168
			end -- 163
		else -- 169
			for _index_0 = 1, #lintResult do -- 169
				local _des_0 = lintResult[_index_0] -- 169
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 169
				if isTIC80 and tic80APIs[name] then -- 170
					goto _continue_0 -- 170
				end -- 170
				info[#info + 1] = { -- 171
					"syntax", -- 171
					file, -- 171
					line, -- 171
					col, -- 171
					"invalid global variable" -- 171
				} -- 171
				::_continue_0:: -- 170
			end -- 169
		end -- 162
	end -- 160
	return luaCodes, info -- 172
end -- 147
local luaCheck -- 174
luaCheck = function(file, content) -- 174
	local res, err = load(content, "check") -- 175
	if not res then -- 176
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 177
		return { -- 178
			success = false, -- 178
			info = { -- 178
				{ -- 178
					"syntax", -- 178
					file, -- 178
					tonumber(line), -- 178
					0, -- 178
					msg -- 178
				} -- 178
			} -- 178
		} -- 178
	end -- 176
	local success, info = teal.checkAsync(content, file, true, "") -- 179
	if info then -- 180
		do -- 181
			local _accum_0 = { } -- 181
			local _len_0 = 1 -- 181
			for _index_0 = 1, #info do -- 181
				local item = info[_index_0] -- 181
				local useCheck = true -- 182
				if not item[5]:match("unused") then -- 183
					for _index_1 = 1, #disabledCheckForLua do -- 184
						local check = disabledCheckForLua[_index_1] -- 184
						if item[5]:match(check) then -- 185
							useCheck = false -- 186
						end -- 185
					end -- 184
				end -- 183
				if not useCheck then -- 187
					goto _continue_0 -- 187
				end -- 187
				do -- 188
					local _exp_0 = item[1] -- 188
					if "type" == _exp_0 then -- 189
						item[1] = "warning" -- 190
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 191
						goto _continue_0 -- 192
					end -- 188
				end -- 188
				_accum_0[_len_0] = item -- 193
				_len_0 = _len_0 + 1 -- 182
				::_continue_0:: -- 182
			end -- 181
			info = _accum_0 -- 181
		end -- 181
		if #info == 0 then -- 194
			info = nil -- 195
			success = true -- 196
		end -- 194
	end -- 180
	return { -- 197
		success = success, -- 197
		info = info -- 197
	} -- 197
end -- 174
local luaCheckWithLineInfo -- 199
luaCheckWithLineInfo = function(file, luaCodes) -- 199
	local res = luaCheck(file, luaCodes) -- 200
	local info = { } -- 201
	if not res.success then -- 202
		local current = 1 -- 203
		local lastLine = 1 -- 204
		local lineMap = { } -- 205
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 206
			local num = lineCode:match("--%s*(%d+)%s*$") -- 207
			if num then -- 208
				lastLine = tonumber(num) -- 209
			end -- 208
			lineMap[current] = lastLine -- 210
			current = current + 1 -- 211
		end -- 206
		local _list_0 = res.info -- 212
		for _index_0 = 1, #_list_0 do -- 212
			local item = _list_0[_index_0] -- 212
			item[3] = lineMap[item[3]] or 0 -- 213
			item[4] = 0 -- 214
			info[#info + 1] = item -- 215
		end -- 212
		return false, info -- 216
	end -- 202
	return true, info -- 217
end -- 199
local getCompiledYueLine -- 219
getCompiledYueLine = function(content, line, row, file, lax) -- 219
	local luaCodes = yueCheck(file, content, lax) -- 220
	if not luaCodes then -- 221
		return nil -- 221
	end -- 221
	local current = 1 -- 222
	local lastLine = 1 -- 223
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 224
	local targetRow = nil -- 225
	local lineMap = { } -- 226
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 227
		local num = lineCode:match("--%s*(%d+)%s*$") -- 228
		if num then -- 229
			lastLine = tonumber(num) -- 229
		end -- 229
		lineMap[current] = lastLine -- 230
		if row <= lastLine and not targetRow then -- 231
			targetRow = current -- 232
			break -- 233
		end -- 231
		current = current + 1 -- 234
	end -- 227
	targetRow = current -- 235
	if targetLine and targetRow then -- 236
		return luaCodes, targetLine, targetRow, lineMap -- 237
	else -- 239
		return nil -- 239
	end -- 236
end -- 219
HttpServer:postSchedule("/check", function(req) -- 241
	do -- 242
		local _type_0 = type(req) -- 242
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 242
		if _tab_0 then -- 242
			local file -- 242
			do -- 242
				local _obj_0 = req.body -- 242
				local _type_1 = type(_obj_0) -- 242
				if "table" == _type_1 or "userdata" == _type_1 then -- 242
					file = _obj_0.file -- 242
				end -- 242
			end -- 242
			local content -- 242
			do -- 242
				local _obj_0 = req.body -- 242
				local _type_1 = type(_obj_0) -- 242
				if "table" == _type_1 or "userdata" == _type_1 then -- 242
					content = _obj_0.content -- 242
				end -- 242
			end -- 242
			if file ~= nil and content ~= nil then -- 242
				local ext = Path:getExt(file) -- 243
				if "tl" == ext then -- 244
					local searchPath = getSearchPath(file) -- 245
					do -- 246
						local isTIC80 = CheckTIC80Code(content) -- 246
						if isTIC80 then -- 246
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 247
						end -- 246
					end -- 246
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 248
					return { -- 249
						success = success, -- 249
						info = info -- 249
					} -- 249
				elseif "lua" == ext then -- 250
					do -- 251
						local isTIC80 = CheckTIC80Code(content) -- 251
						if isTIC80 then -- 251
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 252
						end -- 251
					end -- 251
					return luaCheck(file, content) -- 253
				elseif "yue" == ext then -- 254
					local luaCodes, info = yueCheck(file, content, false) -- 255
					local success = false -- 256
					if luaCodes then -- 257
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 258
						do -- 259
							local _tab_1 = { } -- 259
							local _idx_0 = #_tab_1 + 1 -- 259
							for _index_0 = 1, #info do -- 259
								local _value_0 = info[_index_0] -- 259
								_tab_1[_idx_0] = _value_0 -- 259
								_idx_0 = _idx_0 + 1 -- 259
							end -- 259
							local _idx_1 = #_tab_1 + 1 -- 259
							for _index_0 = 1, #luaInfo do -- 259
								local _value_0 = luaInfo[_index_0] -- 259
								_tab_1[_idx_1] = _value_0 -- 259
								_idx_1 = _idx_1 + 1 -- 259
							end -- 259
							info = _tab_1 -- 259
						end -- 259
						success = success and luaSuccess -- 260
					end -- 257
					if #info > 0 then -- 261
						return { -- 262
							success = success, -- 262
							info = info -- 262
						} -- 262
					else -- 264
						return { -- 264
							success = success -- 264
						} -- 264
					end -- 261
				elseif "xml" == ext then -- 265
					local success, result = xml.check(content) -- 266
					if success then -- 267
						local info -- 268
						success, info = luaCheckWithLineInfo(file, result) -- 268
						if #info > 0 then -- 269
							return { -- 270
								success = success, -- 270
								info = info -- 270
							} -- 270
						else -- 272
							return { -- 272
								success = success -- 272
							} -- 272
						end -- 269
					else -- 274
						local info -- 274
						do -- 274
							local _accum_0 = { } -- 274
							local _len_0 = 1 -- 274
							for _index_0 = 1, #result do -- 274
								local _des_0 = result[_index_0] -- 274
								local row, err = _des_0[1], _des_0[2] -- 274
								_accum_0[_len_0] = { -- 275
									"syntax", -- 275
									file, -- 275
									row, -- 275
									0, -- 275
									err -- 275
								} -- 275
								_len_0 = _len_0 + 1 -- 275
							end -- 274
							info = _accum_0 -- 274
						end -- 274
						return { -- 276
							success = false, -- 276
							info = info -- 276
						} -- 276
					end -- 267
				end -- 244
			end -- 242
		end -- 242
	end -- 242
	return { -- 241
		success = true -- 241
	} -- 241
end) -- 241
local updateInferedDesc -- 278
updateInferedDesc = function(infered) -- 278
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 279
		return -- 279
	end -- 279
	local key, row = infered.key, infered.row -- 280
	local codes = Content:loadAsync(key) -- 281
	if codes then -- 281
		local comments = { } -- 282
		local line = 0 -- 283
		local skipping = false -- 284
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 285
			line = line + 1 -- 286
			if line >= row then -- 287
				break -- 287
			end -- 287
			if lineCode:match("^%s*%-%- @") then -- 288
				skipping = true -- 289
				goto _continue_0 -- 290
			end -- 288
			local result = lineCode:match("^%s*%-%- (.+)") -- 291
			if result then -- 291
				if not skipping then -- 292
					comments[#comments + 1] = result -- 292
				end -- 292
			elseif #comments > 0 then -- 293
				comments = { } -- 294
				skipping = false -- 295
			end -- 291
			::_continue_0:: -- 286
		end -- 285
		infered.doc = table.concat(comments, "\n") -- 296
	end -- 281
end -- 278
HttpServer:postSchedule("/infer", function(req) -- 298
	do -- 299
		local _type_0 = type(req) -- 299
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 299
		if _tab_0 then -- 299
			local lang -- 299
			do -- 299
				local _obj_0 = req.body -- 299
				local _type_1 = type(_obj_0) -- 299
				if "table" == _type_1 or "userdata" == _type_1 then -- 299
					lang = _obj_0.lang -- 299
				end -- 299
			end -- 299
			local file -- 299
			do -- 299
				local _obj_0 = req.body -- 299
				local _type_1 = type(_obj_0) -- 299
				if "table" == _type_1 or "userdata" == _type_1 then -- 299
					file = _obj_0.file -- 299
				end -- 299
			end -- 299
			local content -- 299
			do -- 299
				local _obj_0 = req.body -- 299
				local _type_1 = type(_obj_0) -- 299
				if "table" == _type_1 or "userdata" == _type_1 then -- 299
					content = _obj_0.content -- 299
				end -- 299
			end -- 299
			local line -- 299
			do -- 299
				local _obj_0 = req.body -- 299
				local _type_1 = type(_obj_0) -- 299
				if "table" == _type_1 or "userdata" == _type_1 then -- 299
					line = _obj_0.line -- 299
				end -- 299
			end -- 299
			local row -- 299
			do -- 299
				local _obj_0 = req.body -- 299
				local _type_1 = type(_obj_0) -- 299
				if "table" == _type_1 or "userdata" == _type_1 then -- 299
					row = _obj_0.row -- 299
				end -- 299
			end -- 299
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 299
				local searchPath = getSearchPath(file) -- 300
				if "tl" == lang or "lua" == lang then -- 301
					if CheckTIC80Code(content) then -- 302
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 303
					end -- 302
					local infered = teal.inferAsync(content, line, row, searchPath) -- 304
					if (infered ~= nil) then -- 305
						updateInferedDesc(infered) -- 306
						return { -- 307
							success = true, -- 307
							infered = infered -- 307
						} -- 307
					end -- 305
				elseif "yue" == lang then -- 308
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 309
					if not luaCodes then -- 310
						return { -- 310
							success = false -- 310
						} -- 310
					end -- 310
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 311
					if (infered ~= nil) then -- 312
						local col -- 313
						file, row, col = infered.file, infered.row, infered.col -- 313
						if file == "" and row > 0 and col > 0 then -- 314
							infered.row = lineMap[row] or 0 -- 315
							infered.col = 0 -- 316
						end -- 314
						updateInferedDesc(infered) -- 317
						return { -- 318
							success = true, -- 318
							infered = infered -- 318
						} -- 318
					end -- 312
				end -- 301
			end -- 299
		end -- 299
	end -- 299
	return { -- 298
		success = false -- 298
	} -- 298
end) -- 298
local _anon_func_0 = function(doc) -- 369
	local _accum_0 = { } -- 369
	local _len_0 = 1 -- 369
	local _list_0 = doc.params -- 369
	for _index_0 = 1, #_list_0 do -- 369
		local param = _list_0[_index_0] -- 369
		_accum_0[_len_0] = param.name -- 369
		_len_0 = _len_0 + 1 -- 369
	end -- 369
	return _accum_0 -- 369
end -- 369
local getParamDocs -- 320
getParamDocs = function(signatures) -- 320
	do -- 321
		local codes = Content:loadAsync(signatures[1].file) -- 321
		if codes then -- 321
			local comments = { } -- 322
			local params = { } -- 323
			local line = 0 -- 324
			local docs = { } -- 325
			local returnType = nil -- 326
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 327
				line = line + 1 -- 328
				local needBreak = true -- 329
				for i, _des_0 in ipairs(signatures) do -- 330
					local row = _des_0.row -- 330
					if line >= row and not (docs[i] ~= nil) then -- 331
						if #comments > 0 or #params > 0 or returnType then -- 332
							docs[i] = { -- 334
								doc = table.concat(comments, "  \n"), -- 334
								returnType = returnType -- 335
							} -- 333
							if #params > 0 then -- 337
								docs[i].params = params -- 337
							end -- 337
						else -- 339
							docs[i] = false -- 339
						end -- 332
					end -- 331
					if not docs[i] then -- 340
						needBreak = false -- 340
					end -- 340
				end -- 330
				if needBreak then -- 341
					break -- 341
				end -- 341
				local result = lineCode:match("%s*%-%- (.+)") -- 342
				if result then -- 342
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 343
					if not name then -- 344
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 345
					end -- 344
					if name then -- 346
						local pname = name -- 347
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 348
							pname = pname .. "?" -- 348
						end -- 348
						params[#params + 1] = { -- 350
							name = tostring(pname) .. ": " .. tostring(typ), -- 350
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 351
						} -- 349
					else -- 354
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 354
						if typ then -- 354
							if returnType then -- 355
								returnType = returnType .. ", " .. typ -- 356
							else -- 358
								returnType = typ -- 358
							end -- 355
							result = result:gsub("@return", "**return:**") -- 359
						end -- 354
						comments[#comments + 1] = result -- 360
					end -- 346
				elseif #comments > 0 then -- 361
					comments = { } -- 362
					params = { } -- 363
					returnType = nil -- 364
				end -- 342
			end -- 327
			local results = { } -- 365
			for _index_0 = 1, #docs do -- 366
				local doc = docs[_index_0] -- 366
				if not doc then -- 367
					goto _continue_0 -- 367
				end -- 367
				if doc.params then -- 368
					doc.desc = "function(" .. tostring(table.concat(_anon_func_0(doc), ', ')) .. ")" -- 369
				else -- 371
					doc.desc = "function()" -- 371
				end -- 368
				if doc.returnType then -- 372
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 373
					doc.returnType = nil -- 374
				end -- 372
				results[#results + 1] = doc -- 375
				::_continue_0:: -- 367
			end -- 366
			if #results > 0 then -- 376
				return results -- 376
			else -- 376
				return nil -- 376
			end -- 376
		end -- 321
	end -- 321
	return nil -- 320
end -- 320
HttpServer:postSchedule("/signature", function(req) -- 378
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
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 384
					if signatures then -- 384
						signatures = getParamDocs(signatures) -- 385
						if signatures then -- 385
							return { -- 386
								success = true, -- 386
								signatures = signatures -- 386
							} -- 386
						end -- 385
					end -- 384
				elseif "yue" == lang then -- 387
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 388
					if not luaCodes then -- 389
						return { -- 389
							success = false -- 389
						} -- 389
					end -- 389
					do -- 390
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 390
						if chainOp then -- 390
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 391
							if withVar then -- 391
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 392
							end -- 391
						end -- 390
					end -- 390
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 393
					if signatures then -- 393
						signatures = getParamDocs(signatures) -- 394
						if signatures then -- 394
							return { -- 395
								success = true, -- 395
								signatures = signatures -- 395
							} -- 395
						end -- 394
					else -- 396
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 396
						if signatures then -- 396
							signatures = getParamDocs(signatures) -- 397
							if signatures then -- 397
								return { -- 398
									success = true, -- 398
									signatures = signatures -- 398
								} -- 398
							end -- 397
						end -- 396
					end -- 393
				end -- 381
			end -- 379
		end -- 379
	end -- 379
	return { -- 378
		success = false -- 378
	} -- 378
end) -- 378
local luaKeywords = { -- 401
	'and', -- 401
	'break', -- 402
	'do', -- 403
	'else', -- 404
	'elseif', -- 405
	'end', -- 406
	'false', -- 407
	'for', -- 408
	'function', -- 409
	'goto', -- 410
	'if', -- 411
	'in', -- 412
	'local', -- 413
	'nil', -- 414
	'not', -- 415
	'or', -- 416
	'repeat', -- 417
	'return', -- 418
	'then', -- 419
	'true', -- 420
	'until', -- 421
	'while' -- 422
} -- 400
local tealKeywords = { -- 426
	'record', -- 426
	'as', -- 427
	'is', -- 428
	'type', -- 429
	'embed', -- 430
	'enum', -- 431
	'global', -- 432
	'any', -- 433
	'boolean', -- 434
	'integer', -- 435
	'number', -- 436
	'string', -- 437
	'thread' -- 438
} -- 425
local yueKeywords = { -- 442
	"and", -- 442
	"break", -- 443
	"do", -- 444
	"else", -- 445
	"elseif", -- 446
	"false", -- 447
	"for", -- 448
	"goto", -- 449
	"if", -- 450
	"in", -- 451
	"local", -- 452
	"nil", -- 453
	"not", -- 454
	"or", -- 455
	"repeat", -- 456
	"return", -- 457
	"then", -- 458
	"true", -- 459
	"until", -- 460
	"while", -- 461
	"as", -- 462
	"class", -- 463
	"continue", -- 464
	"export", -- 465
	"extends", -- 466
	"from", -- 467
	"global", -- 468
	"import", -- 469
	"macro", -- 470
	"switch", -- 471
	"try", -- 472
	"unless", -- 473
	"using", -- 474
	"when", -- 475
	"with" -- 476
} -- 441
local _anon_func_1 = function(f) -- 512
	local _val_0 = Path:getExt(f) -- 512
	return "ttf" == _val_0 or "otf" == _val_0 -- 512
end -- 512
local _anon_func_2 = function(suggestions) -- 538
	local _tbl_0 = { } -- 538
	for _index_0 = 1, #suggestions do -- 538
		local item = suggestions[_index_0] -- 538
		_tbl_0[item[1] .. item[2]] = item -- 538
	end -- 538
	return _tbl_0 -- 538
end -- 538
HttpServer:postSchedule("/complete", function(req) -- 479
	do -- 480
		local _type_0 = type(req) -- 480
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 480
		if _tab_0 then -- 480
			local lang -- 480
			do -- 480
				local _obj_0 = req.body -- 480
				local _type_1 = type(_obj_0) -- 480
				if "table" == _type_1 or "userdata" == _type_1 then -- 480
					lang = _obj_0.lang -- 480
				end -- 480
			end -- 480
			local file -- 480
			do -- 480
				local _obj_0 = req.body -- 480
				local _type_1 = type(_obj_0) -- 480
				if "table" == _type_1 or "userdata" == _type_1 then -- 480
					file = _obj_0.file -- 480
				end -- 480
			end -- 480
			local content -- 480
			do -- 480
				local _obj_0 = req.body -- 480
				local _type_1 = type(_obj_0) -- 480
				if "table" == _type_1 or "userdata" == _type_1 then -- 480
					content = _obj_0.content -- 480
				end -- 480
			end -- 480
			local line -- 480
			do -- 480
				local _obj_0 = req.body -- 480
				local _type_1 = type(_obj_0) -- 480
				if "table" == _type_1 or "userdata" == _type_1 then -- 480
					line = _obj_0.line -- 480
				end -- 480
			end -- 480
			local row -- 480
			do -- 480
				local _obj_0 = req.body -- 480
				local _type_1 = type(_obj_0) -- 480
				if "table" == _type_1 or "userdata" == _type_1 then -- 480
					row = _obj_0.row -- 480
				end -- 480
			end -- 480
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 480
				local searchPath = getSearchPath(file) -- 481
				repeat -- 482
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 483
					if lang == "yue" then -- 484
						if not item then -- 485
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 485
						end -- 485
						if not item then -- 486
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 486
						end -- 486
					end -- 484
					local searchType = nil -- 487
					if not item then -- 488
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 489
						if lang == "yue" then -- 490
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 491
						end -- 490
						if (item ~= nil) then -- 492
							searchType = "Image" -- 492
						end -- 492
					end -- 488
					if not item then -- 493
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 494
						if lang == "yue" then -- 495
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 496
						end -- 495
						if (item ~= nil) then -- 497
							searchType = "Font" -- 497
						end -- 497
					end -- 493
					if not item then -- 498
						break -- 498
					end -- 498
					local searchPaths = Content.searchPaths -- 499
					local _list_0 = getSearchFolders(file) -- 500
					for _index_0 = 1, #_list_0 do -- 500
						local folder = _list_0[_index_0] -- 500
						searchPaths[#searchPaths + 1] = folder -- 501
					end -- 500
					if searchType then -- 502
						searchPaths[#searchPaths + 1] = Content.assetPath -- 502
					end -- 502
					local tokens -- 503
					do -- 503
						local _accum_0 = { } -- 503
						local _len_0 = 1 -- 503
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 503
							_accum_0[_len_0] = mod -- 503
							_len_0 = _len_0 + 1 -- 503
						end -- 503
						tokens = _accum_0 -- 503
					end -- 503
					local suggestions = { } -- 504
					for _index_0 = 1, #searchPaths do -- 505
						local path = searchPaths[_index_0] -- 505
						local sPath = Path(path, table.unpack(tokens)) -- 506
						if not Content:exist(sPath) then -- 507
							goto _continue_0 -- 507
						end -- 507
						if searchType == "Font" then -- 508
							local fontPath = Path(sPath, "Font") -- 509
							if Content:exist(fontPath) then -- 510
								local _list_1 = Content:getFiles(fontPath) -- 511
								for _index_1 = 1, #_list_1 do -- 511
									local f = _list_1[_index_1] -- 511
									if _anon_func_1(f) then -- 512
										if "." == f:sub(1, 1) then -- 513
											goto _continue_1 -- 513
										end -- 513
										suggestions[#suggestions + 1] = { -- 514
											Path:getName(f), -- 514
											"font", -- 514
											"field" -- 514
										} -- 514
									end -- 512
									::_continue_1:: -- 512
								end -- 511
							end -- 510
						end -- 508
						local _list_1 = Content:getFiles(sPath) -- 515
						for _index_1 = 1, #_list_1 do -- 515
							local f = _list_1[_index_1] -- 515
							if "Image" == searchType then -- 516
								do -- 517
									local _exp_0 = Path:getExt(f) -- 517
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 517
										if "." == f:sub(1, 1) then -- 518
											goto _continue_2 -- 518
										end -- 518
										suggestions[#suggestions + 1] = { -- 519
											f, -- 519
											"image", -- 519
											"field" -- 519
										} -- 519
									end -- 517
								end -- 517
								goto _continue_2 -- 520
							elseif "Font" == searchType then -- 521
								do -- 522
									local _exp_0 = Path:getExt(f) -- 522
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 522
										if "." == f:sub(1, 1) then -- 523
											goto _continue_2 -- 523
										end -- 523
										suggestions[#suggestions + 1] = { -- 524
											f, -- 524
											"font", -- 524
											"field" -- 524
										} -- 524
									end -- 522
								end -- 522
								goto _continue_2 -- 525
							end -- 516
							local _exp_0 = Path:getExt(f) -- 526
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 526
								local name = Path:getName(f) -- 527
								if "d" == Path:getExt(name) then -- 528
									goto _continue_2 -- 528
								end -- 528
								if "." == name:sub(1, 1) then -- 529
									goto _continue_2 -- 529
								end -- 529
								suggestions[#suggestions + 1] = { -- 530
									name, -- 530
									"module", -- 530
									"field" -- 530
								} -- 530
							end -- 526
							::_continue_2:: -- 516
						end -- 515
						local _list_2 = Content:getDirs(sPath) -- 531
						for _index_1 = 1, #_list_2 do -- 531
							local dir = _list_2[_index_1] -- 531
							if "." == dir:sub(1, 1) then -- 532
								goto _continue_3 -- 532
							end -- 532
							suggestions[#suggestions + 1] = { -- 533
								dir, -- 533
								"folder", -- 533
								"variable" -- 533
							} -- 533
							::_continue_3:: -- 532
						end -- 531
						::_continue_0:: -- 506
					end -- 505
					if item == "" and not searchType then -- 534
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 535
						for _index_0 = 1, #_list_1 do -- 535
							local _des_0 = _list_1[_index_0] -- 535
							local name = _des_0[1] -- 535
							suggestions[#suggestions + 1] = { -- 536
								name, -- 536
								"dora module", -- 536
								"function" -- 536
							} -- 536
						end -- 535
					end -- 534
					if #suggestions > 0 then -- 537
						do -- 538
							local _accum_0 = { } -- 538
							local _len_0 = 1 -- 538
							for _, v in pairs(_anon_func_2(suggestions)) do -- 538
								_accum_0[_len_0] = v -- 538
								_len_0 = _len_0 + 1 -- 538
							end -- 538
							suggestions = _accum_0 -- 538
						end -- 538
						return { -- 539
							success = true, -- 539
							suggestions = suggestions -- 539
						} -- 539
					else -- 541
						return { -- 541
							success = false -- 541
						} -- 541
					end -- 537
				until true -- 482
				if "tl" == lang or "lua" == lang then -- 543
					do -- 544
						local isTIC80 = CheckTIC80Code(content) -- 544
						if isTIC80 then -- 544
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 545
						end -- 544
					end -- 544
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 546
					if not line:match("[%.:]$") then -- 547
						local checkSet -- 548
						do -- 548
							local _tbl_0 = { } -- 548
							for _index_0 = 1, #suggestions do -- 548
								local _des_0 = suggestions[_index_0] -- 548
								local name = _des_0[1] -- 548
								_tbl_0[name] = true -- 548
							end -- 548
							checkSet = _tbl_0 -- 548
						end -- 548
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 549
						for _index_0 = 1, #_list_0 do -- 549
							local item = _list_0[_index_0] -- 549
							if not checkSet[item[1]] then -- 550
								suggestions[#suggestions + 1] = item -- 550
							end -- 550
						end -- 549
						for _index_0 = 1, #luaKeywords do -- 551
							local word = luaKeywords[_index_0] -- 551
							suggestions[#suggestions + 1] = { -- 552
								word, -- 552
								"keyword", -- 552
								"keyword" -- 552
							} -- 552
						end -- 551
						if lang == "tl" then -- 553
							for _index_0 = 1, #tealKeywords do -- 554
								local word = tealKeywords[_index_0] -- 554
								suggestions[#suggestions + 1] = { -- 555
									word, -- 555
									"keyword", -- 555
									"keyword" -- 555
								} -- 555
							end -- 554
						end -- 553
					end -- 547
					if #suggestions > 0 then -- 556
						return { -- 557
							success = true, -- 557
							suggestions = suggestions -- 557
						} -- 557
					end -- 556
				elseif "yue" == lang then -- 558
					local suggestions = { } -- 559
					local gotGlobals = false -- 560
					do -- 561
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 561
						if luaCodes then -- 561
							gotGlobals = true -- 562
							do -- 563
								local chainOp = line:match("[^%w_]([%.\\])$") -- 563
								if chainOp then -- 563
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 564
									if not withVar then -- 565
										return { -- 565
											success = false -- 565
										} -- 565
									end -- 565
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 566
								elseif line:match("^([%.\\])$") then -- 567
									return { -- 568
										success = false -- 568
									} -- 568
								end -- 563
							end -- 563
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 569
							for _index_0 = 1, #_list_0 do -- 569
								local item = _list_0[_index_0] -- 569
								suggestions[#suggestions + 1] = item -- 569
							end -- 569
							if #suggestions == 0 then -- 570
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 571
								for _index_0 = 1, #_list_1 do -- 571
									local item = _list_1[_index_0] -- 571
									suggestions[#suggestions + 1] = item -- 571
								end -- 571
							end -- 570
						end -- 561
					end -- 561
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 572
						local checkSet -- 573
						do -- 573
							local _tbl_0 = { } -- 573
							for _index_0 = 1, #suggestions do -- 573
								local _des_0 = suggestions[_index_0] -- 573
								local name = _des_0[1] -- 573
								_tbl_0[name] = true -- 573
							end -- 573
							checkSet = _tbl_0 -- 573
						end -- 573
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 574
						for _index_0 = 1, #_list_0 do -- 574
							local item = _list_0[_index_0] -- 574
							if not checkSet[item[1]] then -- 575
								suggestions[#suggestions + 1] = item -- 575
							end -- 575
						end -- 574
						if not gotGlobals then -- 576
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 577
							for _index_0 = 1, #_list_1 do -- 577
								local item = _list_1[_index_0] -- 577
								if not checkSet[item[1]] then -- 578
									suggestions[#suggestions + 1] = item -- 578
								end -- 578
							end -- 577
						end -- 576
						for _index_0 = 1, #yueKeywords do -- 579
							local word = yueKeywords[_index_0] -- 579
							if not checkSet[word] then -- 580
								suggestions[#suggestions + 1] = { -- 581
									word, -- 581
									"keyword", -- 581
									"keyword" -- 581
								} -- 581
							end -- 580
						end -- 579
					end -- 572
					if #suggestions > 0 then -- 582
						return { -- 583
							success = true, -- 583
							suggestions = suggestions -- 583
						} -- 583
					end -- 582
				elseif "xml" == lang then -- 584
					local items = xml.complete(content) -- 585
					if #items > 0 then -- 586
						local suggestions -- 587
						do -- 587
							local _accum_0 = { } -- 587
							local _len_0 = 1 -- 587
							for _index_0 = 1, #items do -- 587
								local _des_0 = items[_index_0] -- 587
								local label, insertText = _des_0[1], _des_0[2] -- 587
								_accum_0[_len_0] = { -- 588
									label, -- 588
									insertText, -- 588
									"field" -- 588
								} -- 588
								_len_0 = _len_0 + 1 -- 588
							end -- 587
							suggestions = _accum_0 -- 587
						end -- 587
						return { -- 589
							success = true, -- 589
							suggestions = suggestions -- 589
						} -- 589
					end -- 586
				end -- 543
			end -- 480
		end -- 480
	end -- 480
	return { -- 479
		success = false -- 479
	} -- 479
end) -- 479
HttpServer:upload("/upload", function(req, filename) -- 593
	do -- 594
		local _type_0 = type(req) -- 594
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 594
		if _tab_0 then -- 594
			local path -- 594
			do -- 594
				local _obj_0 = req.params -- 594
				local _type_1 = type(_obj_0) -- 594
				if "table" == _type_1 or "userdata" == _type_1 then -- 594
					path = _obj_0.path -- 594
				end -- 594
			end -- 594
			if path ~= nil then -- 594
				local uploadPath = Path(Content.writablePath, ".upload") -- 595
				if not Content:exist(uploadPath) then -- 596
					Content:mkdir(uploadPath) -- 597
				end -- 596
				local targetPath = Path(uploadPath, filename) -- 598
				Content:mkdir(Path:getPath(targetPath)) -- 599
				return targetPath -- 600
			end -- 594
		end -- 594
	end -- 594
	return nil -- 593
end, function(req, file) -- 601
	do -- 602
		local _type_0 = type(req) -- 602
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 602
		if _tab_0 then -- 602
			local path -- 602
			do -- 602
				local _obj_0 = req.params -- 602
				local _type_1 = type(_obj_0) -- 602
				if "table" == _type_1 or "userdata" == _type_1 then -- 602
					path = _obj_0.path -- 602
				end -- 602
			end -- 602
			if path ~= nil then -- 602
				path = Path(Content.writablePath, path) -- 603
				if Content:exist(path) then -- 604
					local uploadPath = Path(Content.writablePath, ".upload") -- 605
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 606
					Content:mkdir(Path:getPath(targetPath)) -- 607
					if Content:move(file, targetPath) then -- 608
						return true -- 609
					end -- 608
				end -- 604
			end -- 602
		end -- 602
	end -- 602
	return false -- 601
end) -- 591
HttpServer:post("/list", function(req) -- 612
	do -- 613
		local _type_0 = type(req) -- 613
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 613
		if _tab_0 then -- 613
			local path -- 613
			do -- 613
				local _obj_0 = req.body -- 613
				local _type_1 = type(_obj_0) -- 613
				if "table" == _type_1 or "userdata" == _type_1 then -- 613
					path = _obj_0.path -- 613
				end -- 613
			end -- 613
			if path ~= nil then -- 613
				if Content:exist(path) then -- 614
					local files = { } -- 615
					local visitAssets -- 616
					visitAssets = function(path, folder) -- 616
						local dirs = Content:getDirs(path) -- 617
						for _index_0 = 1, #dirs do -- 618
							local dir = dirs[_index_0] -- 618
							if dir:match("^%.") then -- 619
								goto _continue_0 -- 619
							end -- 619
							local current -- 620
							if folder == "" then -- 620
								current = dir -- 621
							else -- 623
								current = Path(folder, dir) -- 623
							end -- 620
							files[#files + 1] = current -- 624
							visitAssets(Path(path, dir), current) -- 625
							::_continue_0:: -- 619
						end -- 618
						local fs = Content:getFiles(path) -- 626
						for _index_0 = 1, #fs do -- 627
							local f = fs[_index_0] -- 627
							if f:match("^%.") then -- 628
								goto _continue_1 -- 628
							end -- 628
							if folder == "" then -- 629
								files[#files + 1] = f -- 630
							else -- 632
								files[#files + 1] = Path(folder, f) -- 632
							end -- 629
							::_continue_1:: -- 628
						end -- 627
					end -- 616
					visitAssets(path, "") -- 633
					if #files == 0 then -- 634
						files = nil -- 634
					end -- 634
					return { -- 635
						success = true, -- 635
						files = files -- 635
					} -- 635
				end -- 614
			end -- 613
		end -- 613
	end -- 613
	return { -- 612
		success = false -- 612
	} -- 612
end) -- 612
HttpServer:post("/info", function() -- 637
	local Entry = require("Script.Dev.Entry") -- 638
	local webProfiler, drawerWidth -- 639
	do -- 639
		local _obj_0 = Entry.getConfig() -- 639
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 639
	end -- 639
	local engineDev = Entry.getEngineDev() -- 640
	Entry.connectWebIDE() -- 641
	return { -- 643
		platform = App.platform, -- 643
		locale = App.locale, -- 644
		version = App.version, -- 645
		engineDev = engineDev, -- 646
		webProfiler = webProfiler, -- 647
		drawerWidth = drawerWidth -- 648
	} -- 642
end) -- 637
local ensureLLMConfigTable -- 650
ensureLLMConfigTable = function() -- 650
	return DB:exec([[		CREATE TABLE IF NOT EXISTS LLMConfig(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			url TEXT NOT NULL,
			model TEXT NOT NULL,
			api_key TEXT NOT NULL,
			created_at INTEGER,
			updated_at INTEGER
		);
	]]) -- 651
end -- 650
HttpServer:post("/llm/list", function() -- 663
	ensureLLMConfigTable() -- 664
	local rows = DB:query("\n		select id, name, url, model, api_key\n		from LLMConfig\n		order by id asc") -- 665
	local items -- 669
	if rows and #rows > 0 then -- 669
		local _accum_0 = { } -- 670
		local _len_0 = 1 -- 670
		for _index_0 = 1, #rows do -- 670
			local _des_0 = rows[_index_0] -- 670
			local id, name, url, model, key = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 670
			_accum_0[_len_0] = { -- 671
				id = id, -- 671
				name = name, -- 671
				url = url, -- 671
				model = model, -- 671
				key = key -- 671
			} -- 671
			_len_0 = _len_0 + 1 -- 671
		end -- 670
		items = _accum_0 -- 670
	end -- 669
	return { -- 672
		success = true, -- 672
		items = items -- 672
	} -- 672
end) -- 663
HttpServer:post("/llm/create", function(req) -- 674
	ensureLLMConfigTable() -- 675
	do -- 676
		local _type_0 = type(req) -- 676
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 676
		if _tab_0 then -- 676
			local name -- 676
			do -- 676
				local _obj_0 = req.body -- 676
				local _type_1 = type(_obj_0) -- 676
				if "table" == _type_1 or "userdata" == _type_1 then -- 676
					name = _obj_0.name -- 676
				end -- 676
			end -- 676
			local url -- 676
			do -- 676
				local _obj_0 = req.body -- 676
				local _type_1 = type(_obj_0) -- 676
				if "table" == _type_1 or "userdata" == _type_1 then -- 676
					url = _obj_0.url -- 676
				end -- 676
			end -- 676
			local model -- 676
			do -- 676
				local _obj_0 = req.body -- 676
				local _type_1 = type(_obj_0) -- 676
				if "table" == _type_1 or "userdata" == _type_1 then -- 676
					model = _obj_0.model -- 676
				end -- 676
			end -- 676
			local key -- 676
			do -- 676
				local _obj_0 = req.body -- 676
				local _type_1 = type(_obj_0) -- 676
				if "table" == _type_1 or "userdata" == _type_1 then -- 676
					key = _obj_0.key -- 676
				end -- 676
			end -- 676
			if name ~= nil and url ~= nil and model ~= nil and key ~= nil then -- 676
				local now = os.time() -- 677
				if name == nil or url == nil or model == nil or key == nil then -- 678
					return { -- 679
						success = false, -- 679
						message = "invalid" -- 679
					} -- 679
				end -- 678
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?\n			)", { -- 686
					tostring(name), -- 686
					tostring(url), -- 687
					tostring(model), -- 688
					tostring(key), -- 689
					now, -- 690
					now -- 691
				}) -- 680
				return { -- 693
					success = affected >= 0 -- 693
				} -- 693
			end -- 676
		end -- 676
	end -- 676
	return { -- 674
		success = false, -- 674
		message = "invalid" -- 674
	} -- 674
end) -- 674
HttpServer:post("/llm/update", function(req) -- 695
	ensureLLMConfigTable() -- 696
	do -- 697
		local _type_0 = type(req) -- 697
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 697
		if _tab_0 then -- 697
			local id -- 697
			do -- 697
				local _obj_0 = req.body -- 697
				local _type_1 = type(_obj_0) -- 697
				if "table" == _type_1 or "userdata" == _type_1 then -- 697
					id = _obj_0.id -- 697
				end -- 697
			end -- 697
			local name -- 697
			do -- 697
				local _obj_0 = req.body -- 697
				local _type_1 = type(_obj_0) -- 697
				if "table" == _type_1 or "userdata" == _type_1 then -- 697
					name = _obj_0.name -- 697
				end -- 697
			end -- 697
			local url -- 697
			do -- 697
				local _obj_0 = req.body -- 697
				local _type_1 = type(_obj_0) -- 697
				if "table" == _type_1 or "userdata" == _type_1 then -- 697
					url = _obj_0.url -- 697
				end -- 697
			end -- 697
			local model -- 697
			do -- 697
				local _obj_0 = req.body -- 697
				local _type_1 = type(_obj_0) -- 697
				if "table" == _type_1 or "userdata" == _type_1 then -- 697
					model = _obj_0.model -- 697
				end -- 697
			end -- 697
			local key -- 697
			do -- 697
				local _obj_0 = req.body -- 697
				local _type_1 = type(_obj_0) -- 697
				if "table" == _type_1 or "userdata" == _type_1 then -- 697
					key = _obj_0.key -- 697
				end -- 697
			end -- 697
			if id ~= nil and name ~= nil and url ~= nil and model ~= nil and key ~= nil then -- 697
				local now = os.time() -- 698
				id = tonumber(id) -- 699
				if id == nil then -- 700
					return { -- 701
						success = false, -- 701
						message = "invalid" -- 701
					} -- 701
				end -- 700
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, updated_at = ?\n			where id = ?", { -- 706
					tostring(name), -- 706
					tostring(url), -- 707
					tostring(model), -- 708
					tostring(key), -- 709
					now, -- 710
					id -- 711
				}) -- 702
				return { -- 713
					success = affected >= 0 -- 713
				} -- 713
			end -- 697
		end -- 697
	end -- 697
	return { -- 695
		success = false, -- 695
		message = "invalid" -- 695
	} -- 695
end) -- 695
HttpServer:post("/llm/delete", function(req) -- 715
	ensureLLMConfigTable() -- 716
	do -- 717
		local _type_0 = type(req) -- 717
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 717
		if _tab_0 then -- 717
			local id -- 717
			do -- 717
				local _obj_0 = req.body -- 717
				local _type_1 = type(_obj_0) -- 717
				if "table" == _type_1 or "userdata" == _type_1 then -- 717
					id = _obj_0.id -- 717
				end -- 717
			end -- 717
			if id ~= nil then -- 717
				id = tonumber(id) -- 718
				if id == nil then -- 719
					return { -- 720
						success = false, -- 720
						message = "invalid" -- 720
					} -- 720
				end -- 719
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 721
					id -- 721
				}) -- 721
				return { -- 722
					success = affected >= 0 -- 722
				} -- 722
			end -- 717
		end -- 717
	end -- 717
	return { -- 715
		success = false, -- 715
		message = "invalid" -- 715
	} -- 715
end) -- 715
HttpServer:post("/new", function(req) -- 724
	do -- 725
		local _type_0 = type(req) -- 725
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 725
		if _tab_0 then -- 725
			local path -- 725
			do -- 725
				local _obj_0 = req.body -- 725
				local _type_1 = type(_obj_0) -- 725
				if "table" == _type_1 or "userdata" == _type_1 then -- 725
					path = _obj_0.path -- 725
				end -- 725
			end -- 725
			local content -- 725
			do -- 725
				local _obj_0 = req.body -- 725
				local _type_1 = type(_obj_0) -- 725
				if "table" == _type_1 or "userdata" == _type_1 then -- 725
					content = _obj_0.content -- 725
				end -- 725
			end -- 725
			local folder -- 725
			do -- 725
				local _obj_0 = req.body -- 725
				local _type_1 = type(_obj_0) -- 725
				if "table" == _type_1 or "userdata" == _type_1 then -- 725
					folder = _obj_0.folder -- 725
				end -- 725
			end -- 725
			if path ~= nil and content ~= nil and folder ~= nil then -- 725
				if Content:exist(path) then -- 726
					return { -- 727
						success = false, -- 727
						message = "TargetExisted" -- 727
					} -- 727
				end -- 726
				local parent = Path:getPath(path) -- 728
				local files = Content:getFiles(parent) -- 729
				if folder then -- 730
					local name = Path:getFilename(path):lower() -- 731
					for _index_0 = 1, #files do -- 732
						local file = files[_index_0] -- 732
						if name == Path:getFilename(file):lower() then -- 733
							return { -- 734
								success = false, -- 734
								message = "TargetExisted" -- 734
							} -- 734
						end -- 733
					end -- 732
					if Content:mkdir(path) then -- 735
						return { -- 736
							success = true -- 736
						} -- 736
					end -- 735
				else -- 738
					local name = Path:getName(path):lower() -- 738
					for _index_0 = 1, #files do -- 739
						local file = files[_index_0] -- 739
						if name == Path:getName(file):lower() then -- 740
							local ext = Path:getExt(file) -- 741
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 742
								goto _continue_0 -- 743
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 744
								goto _continue_0 -- 745
							end -- 742
							return { -- 746
								success = false, -- 746
								message = "SourceExisted" -- 746
							} -- 746
						end -- 740
						::_continue_0:: -- 740
					end -- 739
					if Content:save(path, content) then -- 747
						return { -- 748
							success = true -- 748
						} -- 748
					end -- 747
				end -- 730
			end -- 725
		end -- 725
	end -- 725
	return { -- 724
		success = false, -- 724
		message = "Failed" -- 724
	} -- 724
end) -- 724
HttpServer:post("/delete", function(req) -- 750
	do -- 751
		local _type_0 = type(req) -- 751
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 751
		if _tab_0 then -- 751
			local path -- 751
			do -- 751
				local _obj_0 = req.body -- 751
				local _type_1 = type(_obj_0) -- 751
				if "table" == _type_1 or "userdata" == _type_1 then -- 751
					path = _obj_0.path -- 751
				end -- 751
			end -- 751
			if path ~= nil then -- 751
				if Content:exist(path) then -- 752
					local parent = Path:getPath(path) -- 753
					local files = Content:getFiles(parent) -- 754
					local name = Path:getName(path):lower() -- 755
					local ext = Path:getExt(path) -- 756
					for _index_0 = 1, #files do -- 757
						local file = files[_index_0] -- 757
						if name == Path:getName(file):lower() then -- 758
							local _exp_0 = Path:getExt(file) -- 759
							if "tl" == _exp_0 then -- 759
								if ("vs" == ext) then -- 759
									Content:remove(Path(parent, file)) -- 760
								end -- 759
							elseif "lua" == _exp_0 then -- 761
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 761
									Content:remove(Path(parent, file)) -- 762
								end -- 761
							end -- 759
						end -- 758
					end -- 757
					if Content:remove(path) then -- 763
						return { -- 764
							success = true -- 764
						} -- 764
					end -- 763
				end -- 752
			end -- 751
		end -- 751
	end -- 751
	return { -- 750
		success = false -- 750
	} -- 750
end) -- 750
HttpServer:post("/rename", function(req) -- 766
	do -- 767
		local _type_0 = type(req) -- 767
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 767
		if _tab_0 then -- 767
			local old -- 767
			do -- 767
				local _obj_0 = req.body -- 767
				local _type_1 = type(_obj_0) -- 767
				if "table" == _type_1 or "userdata" == _type_1 then -- 767
					old = _obj_0.old -- 767
				end -- 767
			end -- 767
			local new -- 767
			do -- 767
				local _obj_0 = req.body -- 767
				local _type_1 = type(_obj_0) -- 767
				if "table" == _type_1 or "userdata" == _type_1 then -- 767
					new = _obj_0.new -- 767
				end -- 767
			end -- 767
			if old ~= nil and new ~= nil then -- 767
				if Content:exist(old) and not Content:exist(new) then -- 768
					local parent = Path:getPath(new) -- 769
					local files = Content:getFiles(parent) -- 770
					if Content:isdir(old) then -- 771
						local name = Path:getFilename(new):lower() -- 772
						for _index_0 = 1, #files do -- 773
							local file = files[_index_0] -- 773
							if name == Path:getFilename(file):lower() then -- 774
								return { -- 775
									success = false -- 775
								} -- 775
							end -- 774
						end -- 773
					else -- 777
						local name = Path:getName(new):lower() -- 777
						local ext = Path:getExt(new) -- 778
						for _index_0 = 1, #files do -- 779
							local file = files[_index_0] -- 779
							if name == Path:getName(file):lower() then -- 780
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 781
									goto _continue_0 -- 782
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 783
									goto _continue_0 -- 784
								end -- 781
								return { -- 785
									success = false -- 785
								} -- 785
							end -- 780
							::_continue_0:: -- 780
						end -- 779
					end -- 771
					if Content:move(old, new) then -- 786
						local newParent = Path:getPath(new) -- 787
						parent = Path:getPath(old) -- 788
						files = Content:getFiles(parent) -- 789
						local newName = Path:getName(new) -- 790
						local oldName = Path:getName(old) -- 791
						local name = oldName:lower() -- 792
						local ext = Path:getExt(old) -- 793
						for _index_0 = 1, #files do -- 794
							local file = files[_index_0] -- 794
							if name == Path:getName(file):lower() then -- 795
								local _exp_0 = Path:getExt(file) -- 796
								if "tl" == _exp_0 then -- 796
									if ("vs" == ext) then -- 796
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 797
									end -- 796
								elseif "lua" == _exp_0 then -- 798
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 798
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 799
									end -- 798
								end -- 796
							end -- 795
						end -- 794
						return { -- 800
							success = true -- 800
						} -- 800
					end -- 786
				end -- 768
			end -- 767
		end -- 767
	end -- 767
	return { -- 766
		success = false -- 766
	} -- 766
end) -- 766
HttpServer:post("/exist", function(req) -- 802
	do -- 803
		local _type_0 = type(req) -- 803
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 803
		if _tab_0 then -- 803
			local file -- 803
			do -- 803
				local _obj_0 = req.body -- 803
				local _type_1 = type(_obj_0) -- 803
				if "table" == _type_1 or "userdata" == _type_1 then -- 803
					file = _obj_0.file -- 803
				end -- 803
			end -- 803
			if file ~= nil then -- 803
				do -- 804
					local projFile = req.body.projFile -- 804
					if projFile then -- 804
						local projDir = getProjectDirFromFile(projFile) -- 805
						if projDir then -- 805
							local scriptDir = Path(projDir, "Script") -- 806
							local searchPaths = Content.searchPaths -- 807
							if Content:exist(scriptDir) then -- 808
								Content:addSearchPath(scriptDir) -- 808
							end -- 808
							if Content:exist(projDir) then -- 809
								Content:addSearchPath(projDir) -- 809
							end -- 809
							local _ <close> = setmetatable({ }, { -- 810
								__close = function() -- 810
									Content.searchPaths = searchPaths -- 810
								end -- 810
							}) -- 810
							return { -- 811
								success = Content:exist(file) -- 811
							} -- 811
						end -- 805
					end -- 804
				end -- 804
				return { -- 812
					success = Content:exist(file) -- 812
				} -- 812
			end -- 803
		end -- 803
	end -- 803
	return { -- 802
		success = false -- 802
	} -- 802
end) -- 802
HttpServer:postSchedule("/read", function(req) -- 814
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
			if path ~= nil then -- 815
				local readFile -- 816
				readFile = function() -- 816
					if Content:exist(path) then -- 817
						local content = Content:loadAsync(path) -- 818
						if content then -- 818
							return { -- 819
								content = content, -- 819
								success = true -- 819
							} -- 819
						end -- 818
					end -- 817
					return nil -- 816
				end -- 816
				do -- 820
					local projFile = req.body.projFile -- 820
					if projFile then -- 820
						local projDir = getProjectDirFromFile(projFile) -- 821
						if projDir then -- 821
							local scriptDir = Path(projDir, "Script") -- 822
							local searchPaths = Content.searchPaths -- 823
							if Content:exist(scriptDir) then -- 824
								Content:addSearchPath(scriptDir) -- 824
							end -- 824
							if Content:exist(projDir) then -- 825
								Content:addSearchPath(projDir) -- 825
							end -- 825
							local _ <close> = setmetatable({ }, { -- 826
								__close = function() -- 826
									Content.searchPaths = searchPaths -- 826
								end -- 826
							}) -- 826
							local result = readFile() -- 827
							if result then -- 827
								return result -- 827
							end -- 827
						end -- 821
					end -- 820
				end -- 820
				local result = readFile() -- 828
				if result then -- 828
					return result -- 828
				end -- 828
			end -- 815
		end -- 815
	end -- 815
	return { -- 814
		success = false -- 814
	} -- 814
end) -- 814
HttpServer:get("/read-sync", function(req) -- 830
	do -- 831
		local _type_0 = type(req) -- 831
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 831
		if _tab_0 then -- 831
			local params = req.params -- 831
			if params ~= nil then -- 831
				local path = params.path -- 832
				local exts -- 833
				if params.exts then -- 833
					local _accum_0 = { } -- 834
					local _len_0 = 1 -- 834
					for ext in params.exts:gmatch("[^|]*") do -- 834
						_accum_0[_len_0] = ext -- 835
						_len_0 = _len_0 + 1 -- 835
					end -- 834
					exts = _accum_0 -- 834
				else -- 836
					exts = { -- 836
						"" -- 836
					} -- 836
				end -- 833
				local readFile -- 837
				readFile = function() -- 837
					for _index_0 = 1, #exts do -- 838
						local ext = exts[_index_0] -- 838
						local targetPath = path .. ext -- 839
						if Content:exist(targetPath) then -- 840
							local content = Content:load(targetPath) -- 841
							if content then -- 841
								return { -- 842
									content = content, -- 842
									success = true, -- 842
									fullPath = Content:getFullPath(targetPath) -- 842
								} -- 842
							end -- 841
						end -- 840
					end -- 838
					return nil -- 837
				end -- 837
				local searchPaths = Content.searchPaths -- 843
				local _ <close> = setmetatable({ }, { -- 844
					__close = function() -- 844
						Content.searchPaths = searchPaths -- 844
					end -- 844
				}) -- 844
				do -- 845
					local projFile = req.params.projFile -- 845
					if projFile then -- 845
						local projDir = getProjectDirFromFile(projFile) -- 846
						if projDir then -- 846
							local scriptDir = Path(projDir, "Script") -- 847
							if Content:exist(scriptDir) then -- 848
								Content:addSearchPath(scriptDir) -- 848
							end -- 848
							if Content:exist(projDir) then -- 849
								Content:addSearchPath(projDir) -- 849
							end -- 849
						else -- 851
							projDir = Path:getPath(projFile) -- 851
							if Content:exist(projDir) then -- 852
								Content:addSearchPath(projDir) -- 852
							end -- 852
						end -- 846
					end -- 845
				end -- 845
				local result = readFile() -- 853
				if result then -- 853
					return result -- 853
				end -- 853
			end -- 831
		end -- 831
	end -- 831
	return { -- 830
		success = false -- 830
	} -- 830
end) -- 830
local compileFileAsync -- 855
compileFileAsync = function(inputFile, sourceCodes) -- 855
	local file = inputFile -- 856
	local searchPath -- 857
	do -- 857
		local dir = getProjectDirFromFile(inputFile) -- 857
		if dir then -- 857
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 858
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 859
		else -- 861
			file = Path:getRelative(inputFile, Content.writablePath) -- 861
			if file:sub(1, 2) == ".." then -- 862
				file = Path:getRelative(inputFile, Content.assetPath) -- 863
			end -- 862
			searchPath = "" -- 864
		end -- 857
	end -- 857
	local outputFile = Path:replaceExt(inputFile, "lua") -- 865
	local yueext = yue.options.extension -- 866
	local resultCodes = nil -- 867
	do -- 868
		local _exp_0 = Path:getExt(inputFile) -- 868
		if yueext == _exp_0 then -- 868
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 869
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 870
				if not codes then -- 871
					return -- 871
				end -- 871
				local extraGlobal -- 872
				if isTIC80 then -- 872
					extraGlobal = tic80APIs -- 872
				else -- 872
					extraGlobal = nil -- 872
				end -- 872
				local success = LintYueGlobals(codes, globals, true, extraGlobal) -- 873
				if not success then -- 874
					return -- 874
				end -- 874
				if codes == "" then -- 875
					resultCodes = "" -- 876
					return nil -- 877
				end -- 875
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 878
				return resultCodes -- 879
			end, function(success) -- 870
				if not success then -- 880
					Content:remove(outputFile) -- 881
					if resultCodes == nil then -- 882
						resultCodes = false -- 883
					end -- 882
				end -- 880
			end) -- 870
		elseif "tl" == _exp_0 then -- 884
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 885
			if isTIC80 then -- 886
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 887
			end -- 886
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 888
			if codes then -- 888
				if isTIC80 then -- 889
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 890
				end -- 889
				resultCodes = codes -- 891
				Content:saveAsync(outputFile, codes) -- 892
			else -- 894
				Content:remove(outputFile) -- 894
				resultCodes = false -- 895
			end -- 888
		elseif "xml" == _exp_0 then -- 896
			local codes = xml.tolua(sourceCodes) -- 897
			if codes then -- 897
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 898
				Content:saveAsync(outputFile, resultCodes) -- 899
			else -- 901
				Content:remove(outputFile) -- 901
				resultCodes = false -- 902
			end -- 897
		end -- 868
	end -- 868
	wait(function() -- 903
		return resultCodes ~= nil -- 903
	end) -- 903
	if resultCodes then -- 904
		return resultCodes -- 904
	end -- 904
	return nil -- 855
end -- 855
HttpServer:postSchedule("/write", function(req) -- 906
	do -- 907
		local _type_0 = type(req) -- 907
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 907
		if _tab_0 then -- 907
			local path -- 907
			do -- 907
				local _obj_0 = req.body -- 907
				local _type_1 = type(_obj_0) -- 907
				if "table" == _type_1 or "userdata" == _type_1 then -- 907
					path = _obj_0.path -- 907
				end -- 907
			end -- 907
			local content -- 907
			do -- 907
				local _obj_0 = req.body -- 907
				local _type_1 = type(_obj_0) -- 907
				if "table" == _type_1 or "userdata" == _type_1 then -- 907
					content = _obj_0.content -- 907
				end -- 907
			end -- 907
			if path ~= nil and content ~= nil then -- 907
				if Content:saveAsync(path, content) then -- 908
					do -- 909
						local _exp_0 = Path:getExt(path) -- 909
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 909
							if '' == Path:getExt(Path:getName(path)) then -- 910
								local resultCodes = compileFileAsync(path, content) -- 911
								return { -- 912
									success = true, -- 912
									resultCodes = resultCodes -- 912
								} -- 912
							end -- 910
						end -- 909
					end -- 909
					return { -- 913
						success = true -- 913
					} -- 913
				end -- 908
			end -- 907
		end -- 907
	end -- 907
	return { -- 906
		success = false -- 906
	} -- 906
end) -- 906
HttpServer:postSchedule("/build", function(req) -- 915
	do -- 916
		local _type_0 = type(req) -- 916
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 916
		if _tab_0 then -- 916
			local path -- 916
			do -- 916
				local _obj_0 = req.body -- 916
				local _type_1 = type(_obj_0) -- 916
				if "table" == _type_1 or "userdata" == _type_1 then -- 916
					path = _obj_0.path -- 916
				end -- 916
			end -- 916
			if path ~= nil then -- 916
				local _exp_0 = Path:getExt(path) -- 917
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 917
					if '' == Path:getExt(Path:getName(path)) then -- 918
						local content = Content:loadAsync(path) -- 919
						if content then -- 919
							local resultCodes = compileFileAsync(path, content) -- 920
							if resultCodes then -- 920
								return { -- 921
									success = true, -- 921
									resultCodes = resultCodes -- 921
								} -- 921
							end -- 920
						end -- 919
					end -- 918
				end -- 917
			end -- 916
		end -- 916
	end -- 916
	return { -- 915
		success = false -- 915
	} -- 915
end) -- 915
local extentionLevels = { -- 924
	vs = 2, -- 924
	bl = 2, -- 925
	ts = 1, -- 926
	tsx = 1, -- 927
	tl = 1, -- 928
	yue = 1, -- 929
	xml = 1, -- 930
	lua = 0 -- 931
} -- 923
HttpServer:post("/assets", function() -- 933
	local Entry = require("Script.Dev.Entry") -- 936
	local engineDev = Entry.getEngineDev() -- 937
	local visitAssets -- 938
	visitAssets = function(path, tag) -- 938
		local isWorkspace = tag == "Workspace" -- 939
		local builtin -- 940
		if tag == "Builtin" then -- 940
			builtin = true -- 940
		else -- 940
			builtin = nil -- 940
		end -- 940
		local children = nil -- 941
		local dirs = Content:getDirs(path) -- 942
		for _index_0 = 1, #dirs do -- 943
			local dir = dirs[_index_0] -- 943
			if isWorkspace then -- 944
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 945
					goto _continue_0 -- 946
				end -- 945
			elseif dir == ".git" then -- 947
				goto _continue_0 -- 948
			end -- 944
			if not children then -- 949
				children = { } -- 949
			end -- 949
			children[#children + 1] = visitAssets(Path(path, dir)) -- 950
			::_continue_0:: -- 944
		end -- 943
		local files = Content:getFiles(path) -- 951
		local names = { } -- 952
		for _index_0 = 1, #files do -- 953
			local file = files[_index_0] -- 953
			if file:match("^%.") then -- 954
				goto _continue_1 -- 954
			end -- 954
			local name = Path:getName(file) -- 955
			local ext = names[name] -- 956
			if ext then -- 956
				local lv1 -- 957
				do -- 957
					local _exp_0 = extentionLevels[ext] -- 957
					if _exp_0 ~= nil then -- 957
						lv1 = _exp_0 -- 957
					else -- 957
						lv1 = -1 -- 957
					end -- 957
				end -- 957
				ext = Path:getExt(file) -- 958
				local lv2 -- 959
				do -- 959
					local _exp_0 = extentionLevels[ext] -- 959
					if _exp_0 ~= nil then -- 959
						lv2 = _exp_0 -- 959
					else -- 959
						lv2 = -1 -- 959
					end -- 959
				end -- 959
				if lv2 > lv1 then -- 960
					names[name] = ext -- 961
				elseif lv2 == lv1 then -- 962
					names[name .. '.' .. ext] = "" -- 963
				end -- 960
			else -- 965
				ext = Path:getExt(file) -- 965
				if not extentionLevels[ext] then -- 966
					names[file] = "" -- 967
				else -- 969
					names[name] = ext -- 969
				end -- 966
			end -- 956
			::_continue_1:: -- 954
		end -- 953
		do -- 970
			local _accum_0 = { } -- 970
			local _len_0 = 1 -- 970
			for name, ext in pairs(names) do -- 970
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 970
				_len_0 = _len_0 + 1 -- 970
			end -- 970
			files = _accum_0 -- 970
		end -- 970
		for _index_0 = 1, #files do -- 971
			local file = files[_index_0] -- 971
			if not children then -- 972
				children = { } -- 972
			end -- 972
			children[#children + 1] = { -- 974
				key = Path(path, file), -- 974
				dir = false, -- 975
				title = file, -- 976
				builtin = builtin -- 977
			} -- 973
		end -- 971
		if children then -- 979
			table.sort(children, function(a, b) -- 980
				if a.dir == b.dir then -- 981
					return a.title < b.title -- 982
				else -- 984
					return a.dir -- 984
				end -- 981
			end) -- 980
		end -- 979
		if isWorkspace and children then -- 985
			return children -- 986
		else -- 988
			return { -- 989
				key = path, -- 989
				dir = true, -- 990
				title = Path:getFilename(path), -- 991
				builtin = builtin, -- 992
				children = children -- 993
			} -- 988
		end -- 985
	end -- 938
	local zh = (App.locale:match("^zh") ~= nil) -- 995
	return { -- 997
		key = Content.writablePath, -- 997
		dir = true, -- 998
		root = true, -- 999
		title = "Assets", -- 1000
		children = (function() -- 1002
			local _tab_0 = { -- 1002
				{ -- 1003
					key = Path(Content.assetPath), -- 1003
					dir = true, -- 1004
					builtin = true, -- 1005
					title = zh and "内置资源" or "Built-in", -- 1006
					children = { -- 1008
						(function() -- 1008
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1008
							_with_0.title = zh and "说明文档" or "Readme" -- 1009
							return _with_0 -- 1008
						end)(), -- 1008
						(function() -- 1010
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1010
							_with_0.title = zh and "接口文档" or "API Doc" -- 1011
							return _with_0 -- 1010
						end)(), -- 1010
						(function() -- 1012
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1012
							_with_0.title = zh and "开发工具" or "Tools" -- 1013
							return _with_0 -- 1012
						end)(), -- 1012
						(function() -- 1014
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1014
							_with_0.title = zh and "字体" or "Font" -- 1015
							return _with_0 -- 1014
						end)(), -- 1014
						(function() -- 1016
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1016
							_with_0.title = zh and "程序库" or "Lib" -- 1017
							if engineDev then -- 1018
								local _list_0 = _with_0.children -- 1019
								for _index_0 = 1, #_list_0 do -- 1019
									local child = _list_0[_index_0] -- 1019
									if not (child.title == "Dora") then -- 1020
										goto _continue_0 -- 1020
									end -- 1020
									local title = zh and "zh-Hans" or "en" -- 1021
									do -- 1022
										local _accum_0 = { } -- 1022
										local _len_0 = 1 -- 1022
										local _list_1 = child.children -- 1022
										for _index_1 = 1, #_list_1 do -- 1022
											local c = _list_1[_index_1] -- 1022
											if c.title ~= title then -- 1022
												_accum_0[_len_0] = c -- 1022
												_len_0 = _len_0 + 1 -- 1022
											end -- 1022
										end -- 1022
										child.children = _accum_0 -- 1022
									end -- 1022
									break -- 1023
									::_continue_0:: -- 1020
								end -- 1019
							else -- 1025
								local _accum_0 = { } -- 1025
								local _len_0 = 1 -- 1025
								local _list_0 = _with_0.children -- 1025
								for _index_0 = 1, #_list_0 do -- 1025
									local child = _list_0[_index_0] -- 1025
									if child.title ~= "Dora" then -- 1025
										_accum_0[_len_0] = child -- 1025
										_len_0 = _len_0 + 1 -- 1025
									end -- 1025
								end -- 1025
								_with_0.children = _accum_0 -- 1025
							end -- 1018
							return _with_0 -- 1016
						end)(), -- 1016
						(function() -- 1026
							if engineDev then -- 1026
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1027
								local _obj_0 = _with_0.children -- 1028
								_obj_0[#_obj_0 + 1] = { -- 1029
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1029
									dir = false, -- 1030
									builtin = true, -- 1031
									title = "init.yue" -- 1032
								} -- 1028
								return _with_0 -- 1027
							end -- 1026
						end)() -- 1026
					} -- 1007
				} -- 1002
			} -- 1036
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1036
			local _idx_0 = #_tab_0 + 1 -- 1036
			for _index_0 = 1, #_obj_0 do -- 1036
				local _value_0 = _obj_0[_index_0] -- 1036
				_tab_0[_idx_0] = _value_0 -- 1036
				_idx_0 = _idx_0 + 1 -- 1036
			end -- 1036
			return _tab_0 -- 1002
		end)() -- 1001
	} -- 996
end) -- 933
HttpServer:postSchedule("/run", function(req) -- 1040
	do -- 1041
		local _type_0 = type(req) -- 1041
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1041
		if _tab_0 then -- 1041
			local file -- 1041
			do -- 1041
				local _obj_0 = req.body -- 1041
				local _type_1 = type(_obj_0) -- 1041
				if "table" == _type_1 or "userdata" == _type_1 then -- 1041
					file = _obj_0.file -- 1041
				end -- 1041
			end -- 1041
			local asProj -- 1041
			do -- 1041
				local _obj_0 = req.body -- 1041
				local _type_1 = type(_obj_0) -- 1041
				if "table" == _type_1 or "userdata" == _type_1 then -- 1041
					asProj = _obj_0.asProj -- 1041
				end -- 1041
			end -- 1041
			if file ~= nil and asProj ~= nil then -- 1041
				if not Content:isAbsolutePath(file) then -- 1042
					local devFile = Path(Content.writablePath, file) -- 1043
					if Content:exist(devFile) then -- 1044
						file = devFile -- 1044
					end -- 1044
				end -- 1042
				local Entry = require("Script.Dev.Entry") -- 1045
				local workDir -- 1046
				if asProj then -- 1047
					workDir = getProjectDirFromFile(file) -- 1048
					if workDir then -- 1048
						Entry.allClear() -- 1049
						local target = Path(workDir, "init") -- 1050
						local success, err = Entry.enterEntryAsync({ -- 1051
							entryName = "Project", -- 1051
							fileName = target -- 1051
						}) -- 1051
						target = Path:getName(Path:getPath(target)) -- 1052
						return { -- 1053
							success = success, -- 1053
							target = target, -- 1053
							err = err -- 1053
						} -- 1053
					end -- 1048
				else -- 1055
					workDir = getProjectDirFromFile(file) -- 1055
				end -- 1047
				Entry.allClear() -- 1056
				file = Path:replaceExt(file, "") -- 1057
				local success, err = Entry.enterEntryAsync({ -- 1059
					entryName = Path:getName(file), -- 1059
					fileName = file, -- 1060
					workDir = workDir -- 1061
				}) -- 1058
				return { -- 1062
					success = success, -- 1062
					err = err -- 1062
				} -- 1062
			end -- 1041
		end -- 1041
	end -- 1041
	return { -- 1040
		success = false -- 1040
	} -- 1040
end) -- 1040
HttpServer:postSchedule("/stop", function() -- 1064
	local Entry = require("Script.Dev.Entry") -- 1065
	return { -- 1066
		success = Entry.stop() -- 1066
	} -- 1066
end) -- 1064
local minifyAsync -- 1068
minifyAsync = function(sourcePath, minifyPath) -- 1068
	if not Content:exist(sourcePath) then -- 1069
		return -- 1069
	end -- 1069
	local Entry = require("Script.Dev.Entry") -- 1070
	local errors = { } -- 1071
	local files = Entry.getAllFiles(sourcePath, { -- 1072
		"lua" -- 1072
	}, true) -- 1072
	do -- 1073
		local _accum_0 = { } -- 1073
		local _len_0 = 1 -- 1073
		for _index_0 = 1, #files do -- 1073
			local file = files[_index_0] -- 1073
			if file:sub(1, 1) ~= '.' then -- 1073
				_accum_0[_len_0] = file -- 1073
				_len_0 = _len_0 + 1 -- 1073
			end -- 1073
		end -- 1073
		files = _accum_0 -- 1073
	end -- 1073
	local paths -- 1074
	do -- 1074
		local _tbl_0 = { } -- 1074
		for _index_0 = 1, #files do -- 1074
			local file = files[_index_0] -- 1074
			_tbl_0[Path:getPath(file)] = true -- 1074
		end -- 1074
		paths = _tbl_0 -- 1074
	end -- 1074
	for path in pairs(paths) do -- 1075
		Content:mkdir(Path(minifyPath, path)) -- 1075
	end -- 1075
	local _ <close> = setmetatable({ }, { -- 1076
		__close = function() -- 1076
			package.loaded["luaminify.FormatMini"] = nil -- 1077
			package.loaded["luaminify.ParseLua"] = nil -- 1078
			package.loaded["luaminify.Scope"] = nil -- 1079
			package.loaded["luaminify.Util"] = nil -- 1080
		end -- 1076
	}) -- 1076
	local FormatMini -- 1081
	do -- 1081
		local _obj_0 = require("luaminify") -- 1081
		FormatMini = _obj_0.FormatMini -- 1081
	end -- 1081
	local fileCount = #files -- 1082
	local count = 0 -- 1083
	for _index_0 = 1, #files do -- 1084
		local file = files[_index_0] -- 1084
		thread(function() -- 1085
			local _ <close> = setmetatable({ }, { -- 1086
				__close = function() -- 1086
					count = count + 1 -- 1086
				end -- 1086
			}) -- 1086
			local input = Path(sourcePath, file) -- 1087
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1088
			if Content:exist(input) then -- 1089
				local sourceCodes = Content:loadAsync(input) -- 1090
				local res, err = FormatMini(sourceCodes) -- 1091
				if res then -- 1092
					Content:saveAsync(output, res) -- 1093
					return print("Minify " .. tostring(file)) -- 1094
				else -- 1096
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1096
				end -- 1092
			else -- 1098
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1098
			end -- 1089
		end) -- 1085
		sleep() -- 1099
	end -- 1084
	wait(function() -- 1100
		return count == fileCount -- 1100
	end) -- 1100
	if #errors > 0 then -- 1101
		print(table.concat(errors, '\n')) -- 1102
	end -- 1101
	print("Obfuscation done.") -- 1103
	return files -- 1104
end -- 1068
local zipping = false -- 1106
HttpServer:postSchedule("/zip", function(req) -- 1108
	do -- 1109
		local _type_0 = type(req) -- 1109
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1109
		if _tab_0 then -- 1109
			local path -- 1109
			do -- 1109
				local _obj_0 = req.body -- 1109
				local _type_1 = type(_obj_0) -- 1109
				if "table" == _type_1 or "userdata" == _type_1 then -- 1109
					path = _obj_0.path -- 1109
				end -- 1109
			end -- 1109
			local zipFile -- 1109
			do -- 1109
				local _obj_0 = req.body -- 1109
				local _type_1 = type(_obj_0) -- 1109
				if "table" == _type_1 or "userdata" == _type_1 then -- 1109
					zipFile = _obj_0.zipFile -- 1109
				end -- 1109
			end -- 1109
			local obfuscated -- 1109
			do -- 1109
				local _obj_0 = req.body -- 1109
				local _type_1 = type(_obj_0) -- 1109
				if "table" == _type_1 or "userdata" == _type_1 then -- 1109
					obfuscated = _obj_0.obfuscated -- 1109
				end -- 1109
			end -- 1109
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1109
				if zipping then -- 1110
					goto failed -- 1110
				end -- 1110
				zipping = true -- 1111
				local _ <close> = setmetatable({ }, { -- 1112
					__close = function() -- 1112
						zipping = false -- 1112
					end -- 1112
				}) -- 1112
				if not Content:exist(path) then -- 1113
					goto failed -- 1113
				end -- 1113
				Content:mkdir(Path:getPath(zipFile)) -- 1114
				if obfuscated then -- 1115
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1116
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1117
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1118
					Content:remove(scriptPath) -- 1119
					Content:remove(obfuscatedPath) -- 1120
					Content:remove(tempPath) -- 1121
					Content:mkdir(scriptPath) -- 1122
					Content:mkdir(obfuscatedPath) -- 1123
					Content:mkdir(tempPath) -- 1124
					if not Content:copyAsync(path, tempPath) then -- 1125
						goto failed -- 1125
					end -- 1125
					local Entry = require("Script.Dev.Entry") -- 1126
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1127
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1128
						"tl", -- 1128
						"yue", -- 1128
						"lua", -- 1128
						"ts", -- 1128
						"tsx", -- 1128
						"vs", -- 1128
						"bl", -- 1128
						"xml", -- 1128
						"wa", -- 1128
						"mod" -- 1128
					}, true) -- 1128
					for _index_0 = 1, #scriptFiles do -- 1129
						local file = scriptFiles[_index_0] -- 1129
						Content:remove(Path(tempPath, file)) -- 1130
					end -- 1129
					for _index_0 = 1, #luaFiles do -- 1131
						local file = luaFiles[_index_0] -- 1131
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1132
					end -- 1131
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1133
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1134
					end) then -- 1133
						goto failed -- 1133
					end -- 1133
					return { -- 1135
						success = true -- 1135
					} -- 1135
				else -- 1137
					return { -- 1137
						success = Content:zipAsync(path, zipFile, function(file) -- 1137
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1138
						end) -- 1137
					} -- 1137
				end -- 1115
			end -- 1109
		end -- 1109
	end -- 1109
	::failed:: -- 1139
	return { -- 1108
		success = false -- 1108
	} -- 1108
end) -- 1108
HttpServer:postSchedule("/unzip", function(req) -- 1141
	do -- 1142
		local _type_0 = type(req) -- 1142
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1142
		if _tab_0 then -- 1142
			local zipFile -- 1142
			do -- 1142
				local _obj_0 = req.body -- 1142
				local _type_1 = type(_obj_0) -- 1142
				if "table" == _type_1 or "userdata" == _type_1 then -- 1142
					zipFile = _obj_0.zipFile -- 1142
				end -- 1142
			end -- 1142
			local path -- 1142
			do -- 1142
				local _obj_0 = req.body -- 1142
				local _type_1 = type(_obj_0) -- 1142
				if "table" == _type_1 or "userdata" == _type_1 then -- 1142
					path = _obj_0.path -- 1142
				end -- 1142
			end -- 1142
			if zipFile ~= nil and path ~= nil then -- 1142
				return { -- 1143
					success = Content:unzipAsync(zipFile, path, function(file) -- 1143
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1144
					end) -- 1143
				} -- 1143
			end -- 1142
		end -- 1142
	end -- 1142
	return { -- 1141
		success = false -- 1141
	} -- 1141
end) -- 1141
HttpServer:post("/editing-info", function(req) -- 1146
	local Entry = require("Script.Dev.Entry") -- 1147
	local config = Entry.getConfig() -- 1148
	local _type_0 = type(req) -- 1149
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1149
	local _match_0 = false -- 1149
	if _tab_0 then -- 1149
		local editingInfo -- 1149
		do -- 1149
			local _obj_0 = req.body -- 1149
			local _type_1 = type(_obj_0) -- 1149
			if "table" == _type_1 or "userdata" == _type_1 then -- 1149
				editingInfo = _obj_0.editingInfo -- 1149
			end -- 1149
		end -- 1149
		if editingInfo ~= nil then -- 1149
			_match_0 = true -- 1149
			config.editingInfo = editingInfo -- 1150
			return { -- 1151
				success = true -- 1151
			} -- 1151
		end -- 1149
	end -- 1149
	if not _match_0 then -- 1149
		if not (config.editingInfo ~= nil) then -- 1153
			local folder -- 1154
			if App.locale:match('^zh') then -- 1154
				folder = 'zh-Hans' -- 1154
			else -- 1154
				folder = 'en' -- 1154
			end -- 1154
			config.editingInfo = json.encode({ -- 1156
				index = 0, -- 1156
				files = { -- 1158
					{ -- 1159
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1159
						title = "welcome.md" -- 1160
					} -- 1158
				} -- 1157
			}) -- 1155
		end -- 1153
		return { -- 1164
			success = true, -- 1164
			editingInfo = config.editingInfo -- 1164
		} -- 1164
	end -- 1149
end) -- 1146
HttpServer:post("/command", function(req) -- 1166
	do -- 1167
		local _type_0 = type(req) -- 1167
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1167
		if _tab_0 then -- 1167
			local code -- 1167
			do -- 1167
				local _obj_0 = req.body -- 1167
				local _type_1 = type(_obj_0) -- 1167
				if "table" == _type_1 or "userdata" == _type_1 then -- 1167
					code = _obj_0.code -- 1167
				end -- 1167
			end -- 1167
			local log -- 1167
			do -- 1167
				local _obj_0 = req.body -- 1167
				local _type_1 = type(_obj_0) -- 1167
				if "table" == _type_1 or "userdata" == _type_1 then -- 1167
					log = _obj_0.log -- 1167
				end -- 1167
			end -- 1167
			if code ~= nil and log ~= nil then -- 1167
				emit("AppCommand", code, log) -- 1168
				return { -- 1169
					success = true -- 1169
				} -- 1169
			end -- 1167
		end -- 1167
	end -- 1167
	return { -- 1166
		success = false -- 1166
	} -- 1166
end) -- 1166
HttpServer:post("/log/save", function() -- 1171
	local folder = ".download" -- 1172
	local fullLogFile = "dora_full_logs.txt" -- 1173
	local fullFolder = Path(Content.writablePath, folder) -- 1174
	Content:mkdir(fullFolder) -- 1175
	local logPath = Path(fullFolder, fullLogFile) -- 1176
	if App:saveLog(logPath) then -- 1177
		return { -- 1178
			success = true, -- 1178
			path = Path(folder, fullLogFile) -- 1178
		} -- 1178
	end -- 1177
	return { -- 1171
		success = false -- 1171
	} -- 1171
end) -- 1171
HttpServer:post("/yarn/check", function(req) -- 1180
	local yarncompile = require("yarncompile") -- 1181
	do -- 1182
		local _type_0 = type(req) -- 1182
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1182
		if _tab_0 then -- 1182
			local code -- 1182
			do -- 1182
				local _obj_0 = req.body -- 1182
				local _type_1 = type(_obj_0) -- 1182
				if "table" == _type_1 or "userdata" == _type_1 then -- 1182
					code = _obj_0.code -- 1182
				end -- 1182
			end -- 1182
			if code ~= nil then -- 1182
				local jsonObject = json.decode(code) -- 1183
				if jsonObject then -- 1183
					local errors = { } -- 1184
					local _list_0 = jsonObject.nodes -- 1185
					for _index_0 = 1, #_list_0 do -- 1185
						local node = _list_0[_index_0] -- 1185
						local title, body = node.title, node.body -- 1186
						local luaCode, err = yarncompile(body) -- 1187
						if not luaCode then -- 1187
							errors[#errors + 1] = title .. ":" .. err -- 1188
						end -- 1187
					end -- 1185
					return { -- 1189
						success = true, -- 1189
						syntaxError = table.concat(errors, "\n\n") -- 1189
					} -- 1189
				end -- 1183
			end -- 1182
		end -- 1182
	end -- 1182
	return { -- 1180
		success = false -- 1180
	} -- 1180
end) -- 1180
HttpServer:post("/yarn/check-file", function(req) -- 1191
	local yarncompile = require("yarncompile") -- 1192
	do -- 1193
		local _type_0 = type(req) -- 1193
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1193
		if _tab_0 then -- 1193
			local code -- 1193
			do -- 1193
				local _obj_0 = req.body -- 1193
				local _type_1 = type(_obj_0) -- 1193
				if "table" == _type_1 or "userdata" == _type_1 then -- 1193
					code = _obj_0.code -- 1193
				end -- 1193
			end -- 1193
			if code ~= nil then -- 1193
				local res, _, err = yarncompile(code, true) -- 1194
				if not res then -- 1194
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1195
					return { -- 1196
						success = false, -- 1196
						message = message, -- 1196
						line = line, -- 1196
						column = column, -- 1196
						node = node -- 1196
					} -- 1196
				end -- 1194
			end -- 1193
		end -- 1193
	end -- 1193
	return { -- 1191
		success = true -- 1191
	} -- 1191
end) -- 1191
local getWaProjectDirFromFile -- 1198
getWaProjectDirFromFile = function(file) -- 1198
	local writablePath = Content.writablePath -- 1199
	local parent, current -- 1200
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1200
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1201
	else -- 1203
		parent, current = nil, nil -- 1203
	end -- 1200
	if not current then -- 1204
		return nil -- 1204
	end -- 1204
	repeat -- 1205
		current = Path:getPath(current) -- 1206
		if current == "" then -- 1207
			break -- 1207
		end -- 1207
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1208
		for _index_0 = 1, #_list_0 do -- 1208
			local f = _list_0[_index_0] -- 1208
			if Path:getFilename(f):lower() == "wa.mod" then -- 1209
				return Path(parent, current, Path:getPath(f)) -- 1210
			end -- 1209
		end -- 1208
	until false -- 1205
	return nil -- 1212
end -- 1198
HttpServer:postSchedule("/wa/build", function(req) -- 1214
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
				local projDir = getWaProjectDirFromFile(path) -- 1216
				if projDir then -- 1216
					local message = Wasm:buildWaAsync(projDir) -- 1217
					if message == "" then -- 1218
						return { -- 1219
							success = true -- 1219
						} -- 1219
					else -- 1221
						return { -- 1221
							success = false, -- 1221
							message = message -- 1221
						} -- 1221
					end -- 1218
				else -- 1223
					return { -- 1223
						success = false, -- 1223
						message = 'Wa file needs a project' -- 1223
					} -- 1223
				end -- 1216
			end -- 1215
		end -- 1215
	end -- 1215
	return { -- 1224
		success = false, -- 1224
		message = 'failed to build' -- 1224
	} -- 1224
end) -- 1214
HttpServer:postSchedule("/wa/format", function(req) -- 1226
	do -- 1227
		local _type_0 = type(req) -- 1227
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1227
		if _tab_0 then -- 1227
			local file -- 1227
			do -- 1227
				local _obj_0 = req.body -- 1227
				local _type_1 = type(_obj_0) -- 1227
				if "table" == _type_1 or "userdata" == _type_1 then -- 1227
					file = _obj_0.file -- 1227
				end -- 1227
			end -- 1227
			if file ~= nil then -- 1227
				local code = Wasm:formatWaAsync(file) -- 1228
				if code == "" then -- 1229
					return { -- 1230
						success = false -- 1230
					} -- 1230
				else -- 1232
					return { -- 1232
						success = true, -- 1232
						code = code -- 1232
					} -- 1232
				end -- 1229
			end -- 1227
		end -- 1227
	end -- 1227
	return { -- 1233
		success = false -- 1233
	} -- 1233
end) -- 1226
HttpServer:postSchedule("/wa/create", function(req) -- 1235
	do -- 1236
		local _type_0 = type(req) -- 1236
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1236
		if _tab_0 then -- 1236
			local path -- 1236
			do -- 1236
				local _obj_0 = req.body -- 1236
				local _type_1 = type(_obj_0) -- 1236
				if "table" == _type_1 or "userdata" == _type_1 then -- 1236
					path = _obj_0.path -- 1236
				end -- 1236
			end -- 1236
			if path ~= nil then -- 1236
				if not Content:exist(Path:getPath(path)) then -- 1237
					return { -- 1238
						success = false, -- 1238
						message = "target path not existed" -- 1238
					} -- 1238
				end -- 1237
				if Content:exist(path) then -- 1239
					return { -- 1240
						success = false, -- 1240
						message = "target project folder existed" -- 1240
					} -- 1240
				end -- 1239
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1241
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1242
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1243
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1244
					return { -- 1247
						success = false, -- 1247
						message = "missing template project" -- 1247
					} -- 1247
				end -- 1244
				if not Content:mkdir(path) then -- 1248
					return { -- 1249
						success = false, -- 1249
						message = "failed to create project folder" -- 1249
					} -- 1249
				end -- 1248
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1250
					Content:remove(path) -- 1251
					return { -- 1252
						success = false, -- 1252
						message = "failed to copy template" -- 1252
					} -- 1252
				end -- 1250
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1253
					Content:remove(path) -- 1254
					return { -- 1255
						success = false, -- 1255
						message = "failed to copy template" -- 1255
					} -- 1255
				end -- 1253
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1256
					Content:remove(path) -- 1257
					return { -- 1258
						success = false, -- 1258
						message = "failed to copy template" -- 1258
					} -- 1258
				end -- 1256
				return { -- 1259
					success = true -- 1259
				} -- 1259
			end -- 1236
		end -- 1236
	end -- 1236
	return { -- 1235
		success = false, -- 1235
		message = "invalid call" -- 1235
	} -- 1235
end) -- 1235
local _anon_func_3 = function(path) -- 1268
	local _val_0 = Path:getExt(path) -- 1268
	return "ts" == _val_0 or "tsx" == _val_0 -- 1268
end -- 1268
local _anon_func_4 = function(f) -- 1298
	local _val_0 = Path:getExt(f) -- 1298
	return "ts" == _val_0 or "tsx" == _val_0 -- 1298
end -- 1298
HttpServer:postSchedule("/ts/build", function(req) -- 1261
	do -- 1262
		local _type_0 = type(req) -- 1262
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1262
		if _tab_0 then -- 1262
			local path -- 1262
			do -- 1262
				local _obj_0 = req.body -- 1262
				local _type_1 = type(_obj_0) -- 1262
				if "table" == _type_1 or "userdata" == _type_1 then -- 1262
					path = _obj_0.path -- 1262
				end -- 1262
			end -- 1262
			if path ~= nil then -- 1262
				if HttpServer.wsConnectionCount == 0 then -- 1263
					return { -- 1264
						success = false, -- 1264
						message = "Web IDE not connected" -- 1264
					} -- 1264
				end -- 1263
				if not Content:exist(path) then -- 1265
					return { -- 1266
						success = false, -- 1266
						message = "path not existed" -- 1266
					} -- 1266
				end -- 1265
				if not Content:isdir(path) then -- 1267
					if not (_anon_func_3(path)) then -- 1268
						return { -- 1269
							success = false, -- 1269
							message = "expecting a TypeScript file" -- 1269
						} -- 1269
					end -- 1268
					local messages = { } -- 1270
					local content = Content:load(path) -- 1271
					if not content then -- 1272
						return { -- 1273
							success = false, -- 1273
							message = "failed to read file" -- 1273
						} -- 1273
					end -- 1272
					emit("AppWS", "Send", json.encode({ -- 1274
						name = "UpdateTSCode", -- 1274
						file = path, -- 1274
						content = content -- 1274
					})) -- 1274
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1275
						local done = false -- 1276
						do -- 1277
							local _with_0 = Node() -- 1277
							_with_0:gslot("AppWS", function(eventType, msg) -- 1278
								if eventType == "Receive" then -- 1279
									_with_0:removeFromParent() -- 1280
									local res = json.decode(msg) -- 1281
									if res then -- 1281
										if res.name == "TranspileTS" then -- 1282
											if res.success then -- 1283
												local luaFile = Path:replaceExt(path, "lua") -- 1284
												Content:save(luaFile, res.luaCode) -- 1285
												messages[#messages + 1] = { -- 1286
													success = true, -- 1286
													file = path -- 1286
												} -- 1286
											else -- 1288
												messages[#messages + 1] = { -- 1288
													success = false, -- 1288
													file = path, -- 1288
													message = res.message -- 1288
												} -- 1288
											end -- 1283
											done = true -- 1289
										end -- 1282
									end -- 1281
								end -- 1279
							end) -- 1278
						end -- 1277
						emit("AppWS", "Send", json.encode({ -- 1290
							name = "TranspileTS", -- 1290
							file = path, -- 1290
							content = content -- 1290
						})) -- 1290
						wait(function() -- 1291
							return done -- 1291
						end) -- 1291
					end -- 1275
					return { -- 1292
						success = true, -- 1292
						messages = messages -- 1292
					} -- 1292
				else -- 1294
					local files = Content:getAllFiles(path) -- 1294
					local fileData = { } -- 1295
					local messages = { } -- 1296
					for _index_0 = 1, #files do -- 1297
						local f = files[_index_0] -- 1297
						if not (_anon_func_4(f)) then -- 1298
							goto _continue_0 -- 1298
						end -- 1298
						local file = Path(path, f) -- 1299
						local content = Content:load(file) -- 1300
						if content then -- 1300
							fileData[file] = content -- 1301
							emit("AppWS", "Send", json.encode({ -- 1302
								name = "UpdateTSCode", -- 1302
								file = file, -- 1302
								content = content -- 1302
							})) -- 1302
						else -- 1304
							messages[#messages + 1] = { -- 1304
								success = false, -- 1304
								file = file, -- 1304
								message = "failed to read file" -- 1304
							} -- 1304
						end -- 1300
						::_continue_0:: -- 1298
					end -- 1297
					for file, content in pairs(fileData) do -- 1305
						if "d" == Path:getExt(Path:getName(file)) then -- 1306
							goto _continue_1 -- 1306
						end -- 1306
						local done = false -- 1307
						do -- 1308
							local _with_0 = Node() -- 1308
							_with_0:gslot("AppWS", function(eventType, msg) -- 1309
								if eventType == "Receive" then -- 1310
									_with_0:removeFromParent() -- 1311
									local res = json.decode(msg) -- 1312
									if res then -- 1312
										if res.name == "TranspileTS" then -- 1313
											if res.success then -- 1314
												local luaFile = Path:replaceExt(file, "lua") -- 1315
												Content:save(luaFile, res.luaCode) -- 1316
												messages[#messages + 1] = { -- 1317
													success = true, -- 1317
													file = file -- 1317
												} -- 1317
											else -- 1319
												messages[#messages + 1] = { -- 1319
													success = false, -- 1319
													file = file, -- 1319
													message = res.message -- 1319
												} -- 1319
											end -- 1314
											done = true -- 1320
										end -- 1313
									end -- 1312
								end -- 1310
							end) -- 1309
						end -- 1308
						emit("AppWS", "Send", json.encode({ -- 1321
							name = "TranspileTS", -- 1321
							file = file, -- 1321
							content = content -- 1321
						})) -- 1321
						wait(function() -- 1322
							return done -- 1322
						end) -- 1322
						::_continue_1:: -- 1306
					end -- 1305
					return { -- 1323
						success = true, -- 1323
						messages = messages -- 1323
					} -- 1323
				end -- 1267
			end -- 1262
		end -- 1262
	end -- 1262
	return { -- 1261
		success = false -- 1261
	} -- 1261
end) -- 1261
HttpServer:post("/download", function(req) -- 1325
	do -- 1326
		local _type_0 = type(req) -- 1326
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1326
		if _tab_0 then -- 1326
			local url -- 1326
			do -- 1326
				local _obj_0 = req.body -- 1326
				local _type_1 = type(_obj_0) -- 1326
				if "table" == _type_1 or "userdata" == _type_1 then -- 1326
					url = _obj_0.url -- 1326
				end -- 1326
			end -- 1326
			local target -- 1326
			do -- 1326
				local _obj_0 = req.body -- 1326
				local _type_1 = type(_obj_0) -- 1326
				if "table" == _type_1 or "userdata" == _type_1 then -- 1326
					target = _obj_0.target -- 1326
				end -- 1326
			end -- 1326
			if url ~= nil and target ~= nil then -- 1326
				local Entry = require("Script.Dev.Entry") -- 1327
				Entry.downloadFile(url, target) -- 1328
				return { -- 1329
					success = true -- 1329
				} -- 1329
			end -- 1326
		end -- 1326
	end -- 1326
	return { -- 1325
		success = false -- 1325
	} -- 1325
end) -- 1325
local status = { } -- 1331
_module_0 = status -- 1332
thread(function() -- 1334
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1335
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1336
	if Content:exist(doraWeb) then -- 1337
		local needReload -- 1338
		if Content:exist(doraReady) then -- 1338
			needReload = App.version ~= Content:load(doraReady) -- 1339
		else -- 1340
			needReload = true -- 1340
		end -- 1338
		if needReload then -- 1341
			Content:remove(Path(Content.appPath, ".www")) -- 1342
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1343
			Content:save(doraReady, App.version) -- 1347
			print("Dora Dora is ready!") -- 1348
		end -- 1341
	end -- 1337
	if HttpServer:start(8866) then -- 1349
		local localIP = HttpServer.localIP -- 1350
		if localIP == "" then -- 1351
			localIP = "localhost" -- 1351
		end -- 1351
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1352
		return HttpServer:startWS(8868) -- 1353
	else -- 1355
		status.url = nil -- 1355
		return print("8866 Port not available!") -- 1356
	end -- 1349
end) -- 1334
return _module_0 -- 1
