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
HttpServer.authToken = "" -- 16
local authFailedCount = 0 -- 18
local authLockedUntil = 0.0 -- 19
local PendingTTL = 60 -- 21
local genAuthToken -- 23
genAuthToken = function() -- 23
	local parts = { } -- 24
	for _ = 1, 4 do -- 25
		parts[#parts + 1] = string.format("%08x", math.random(0, 0x7fffffff)) -- 26
	end -- 25
	return table.concat(parts) -- 27
end -- 23
local genSessionId -- 29
genSessionId = function() -- 29
	local parts = { } -- 30
	for _ = 1, 2 do -- 31
		parts[#parts + 1] = string.format("%08x", math.random(0, 0x7fffffff)) -- 32
	end -- 31
	return table.concat(parts) -- 33
end -- 29
local genConfirmCode -- 35
genConfirmCode = function() -- 35
	return string.format("%04d", math.random(0, 9999)) -- 36
end -- 35
HttpServer:post("/auth", function(req) -- 38
	local Entry = require("Script.Dev.Entry") -- 39
	local AuthSession = Entry.AuthSession -- 40
	local authCode = Entry.getAuthCode() -- 41
	local now = os.time() -- 42
	if now < authLockedUntil then -- 43
		return { -- 44
			success = false, -- 44
			message = "locked", -- 44
			retryAfter = authLockedUntil - now -- 44
		} -- 44
	end -- 43
	local code = nil -- 45
	do -- 47
		local _type_0 = type(req) -- 47
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 47
		if _tab_0 then -- 47
			do -- 47
				local _obj_0 = req.body -- 47
				local _type_1 = type(_obj_0) -- 47
				if "table" == _type_1 or "userdata" == _type_1 then -- 47
					code = _obj_0.code -- 47
				end -- 47
			end -- 47
			if code ~= nil then -- 47
				code = code -- 48
			end -- 47
		end -- 46
	end -- 46
	if code and tostring(code) == authCode then -- 49
		authFailedCount = 0 -- 50
		Entry.invalidateAuthCode() -- 51
		do -- 52
			local pending = AuthSession.getPending() -- 52
			if pending then -- 52
				if now < pending.expiresAt and not pending.approved then -- 53
					return { -- 54
						success = true, -- 54
						pending = true, -- 54
						sessionId = pending.sessionId, -- 54
						confirmCode = pending.confirmCode, -- 54
						expiresIn = pending.expiresAt - now -- 54
					} -- 54
				end -- 53
			end -- 52
		end -- 52
		local sessionId = genSessionId() -- 55
		local confirmCode = genConfirmCode() -- 56
		AuthSession.beginPending(sessionId, confirmCode, now + PendingTTL, PendingTTL) -- 57
		return { -- 58
			success = true, -- 58
			pending = true, -- 58
			sessionId = sessionId, -- 58
			confirmCode = confirmCode, -- 58
			expiresIn = PendingTTL -- 58
		} -- 58
	else -- 60
		authFailedCount = authFailedCount + 1 -- 60
		if authFailedCount >= 3 then -- 61
			authFailedCount = 0 -- 62
			authLockedUntil = now + 30 -- 63
			return { -- 64
				success = false, -- 64
				message = "locked", -- 64
				retryAfter = 30 -- 64
			} -- 64
		end -- 61
		return { -- 65
			success = false, -- 65
			message = "invalid code" -- 65
		} -- 65
	end -- 49
end) -- 38
HttpServer:post("/auth/confirm", function(req) -- 67
	local now = os.time() -- 68
	local sessionId = nil -- 69
	do -- 71
		local _type_0 = type(req) -- 71
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 71
		if _tab_0 then -- 71
			do -- 71
				local _obj_0 = req.body -- 71
				local _type_1 = type(_obj_0) -- 71
				if "table" == _type_1 or "userdata" == _type_1 then -- 71
					sessionId = _obj_0.sessionId -- 71
				end -- 71
			end -- 71
			if sessionId ~= nil then -- 71
				sessionId = sessionId -- 72
			end -- 71
		end -- 70
	end -- 70
	if not sessionId then -- 73
		return { -- 74
			success = false, -- 74
			message = "invalid session" -- 74
		} -- 74
	end -- 73
	local Entry = require("Script.Dev.Entry") -- 75
	local AuthSession = Entry.AuthSession -- 76
	do -- 77
		local pending = AuthSession.getPending() -- 77
		if pending then -- 77
			if pending.sessionId ~= sessionId then -- 78
				return { -- 79
					success = false, -- 79
					message = "invalid session" -- 79
				} -- 79
			end -- 78
			if now >= pending.expiresAt then -- 80
				AuthSession.clearPending() -- 81
				return { -- 82
					success = false, -- 82
					message = "expired" -- 82
				} -- 82
			end -- 80
			if pending.approved then -- 83
				local secret = genAuthToken() -- 84
				HttpServer.authToken = tostring(sessionId) .. ":" .. tostring(secret) -- 85
				AuthSession.setSession(sessionId, secret) -- 86
				AuthSession.clearPending() -- 87
				return { -- 88
					success = true, -- 88
					sessionId = sessionId, -- 88
					sessionSecret = secret -- 88
				} -- 88
			end -- 83
			return { -- 89
				success = false, -- 89
				message = "pending", -- 89
				retryAfter = 2 -- 89
			} -- 89
		end -- 77
	end -- 77
	return { -- 90
		success = false, -- 90
		message = "invalid session" -- 90
	} -- 90
end) -- 67
local LintYueGlobals, CheckTIC80Code -- 92
do -- 92
	local _obj_0 = require("Utils") -- 92
	LintYueGlobals, CheckTIC80Code = _obj_0.LintYueGlobals, _obj_0.CheckTIC80Code -- 92
end -- 92
local getProjectDirFromFile -- 94
getProjectDirFromFile = function(file) -- 94
	local writablePath, assetPath = Content.writablePath, Content.assetPath -- 95
	local parent, current -- 96
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 96
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 97
	elseif (".." ~= Path:getRelative(file, assetPath):sub(1, 2)) and assetPath == file:sub(1, #assetPath) then -- 98
		local dir = Path(assetPath, "Script") -- 99
		parent, current = dir, Path:getRelative(file, dir) -- 100
	else -- 102
		parent, current = nil, nil -- 102
	end -- 96
	if not current then -- 103
		return nil -- 103
	end -- 103
	repeat -- 104
		current = Path:getPath(current) -- 105
		if current == "" then -- 106
			break -- 106
		end -- 106
		local _list_0 = Content:getFiles(Path(parent, current)) -- 107
		for _index_0 = 1, #_list_0 do -- 107
			local f = _list_0[_index_0] -- 107
			if Path:getName(f):lower() == "init" then -- 108
				return Path(parent, current, Path:getPath(f)) -- 109
			end -- 108
		end -- 107
	until false -- 104
	return nil -- 111
end -- 94
local getSearchPath -- 113
getSearchPath = function(file) -- 113
	do -- 114
		local dir = getProjectDirFromFile(file) -- 114
		if dir then -- 114
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 115
		end -- 114
	end -- 114
	return "" -- 113
end -- 113
local getSearchFolders -- 117
getSearchFolders = function(file) -- 117
	do -- 118
		local dir = getProjectDirFromFile(file) -- 118
		if dir then -- 118
			return { -- 120
				Path(dir, "Script"), -- 120
				dir -- 121
			} -- 119
		end -- 118
	end -- 118
	return { } -- 117
end -- 117
local disabledCheckForLua = { -- 124
	"incompatible number of returns", -- 124
	"unknown", -- 125
	"cannot index", -- 126
	"module not found", -- 127
	"don't know how to resolve", -- 128
	"ContainerItem", -- 129
	"cannot resolve a type", -- 130
	"invalid key", -- 131
	"inconsistent index type", -- 132
	"cannot use operator", -- 133
	"attempting ipairs loop", -- 134
	"expects record or nominal", -- 135
	"variable is not being assigned", -- 136
	"<invalid type>", -- 137
	"<any type>", -- 138
	"using the '#' operator", -- 139
	"can't match a record", -- 140
	"redeclaration of variable", -- 141
	"cannot apply pairs", -- 142
	"not a function", -- 143
	"to%-be%-closed" -- 144
} -- 123
local yueCheck -- 146
yueCheck = function(file, content, lax) -- 146
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 147
	if isTIC80 then -- 148
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 149
	end -- 148
	local searchPath = getSearchPath(file) -- 150
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 151
	local info = { } -- 152
	local globals = { } -- 153
	for _index_0 = 1, #checkResult do -- 154
		local _des_0 = checkResult[_index_0] -- 154
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 154
		if "error" == t then -- 155
			info[#info + 1] = { -- 156
				"syntax", -- 156
				file, -- 156
				line, -- 156
				col, -- 156
				msg -- 156
			} -- 156
		elseif "global" == t then -- 157
			globals[#globals + 1] = { -- 158
				msg, -- 158
				line, -- 158
				col -- 158
			} -- 158
		end -- 155
	end -- 154
	if luaCodes then -- 159
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 160
		if success then -- 161
			if lax then -- 162
				luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 163
				if not (lintResult == "") then -- 164
					lintResult = lintResult .. "\n" -- 164
				end -- 164
				luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 165
			else -- 167
				luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(luaCodes) -- 167
			end -- 162
		else -- 168
			for _index_0 = 1, #lintResult do -- 168
				local _des_0 = lintResult[_index_0] -- 168
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 168
				if isTIC80 and tic80APIs[name] then -- 169
					goto _continue_0 -- 169
				end -- 169
				info[#info + 1] = { -- 170
					"syntax", -- 170
					file, -- 170
					line, -- 170
					col, -- 170
					"invalid global variable" -- 170
				} -- 170
				::_continue_0:: -- 169
			end -- 168
		end -- 161
	end -- 159
	return luaCodes, info -- 171
end -- 146
local luaCheck -- 173
luaCheck = function(file, content) -- 173
	local res, err = load(content, "check") -- 174
	if not res then -- 175
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 176
		return { -- 177
			success = false, -- 177
			info = { -- 177
				{ -- 177
					"syntax", -- 177
					file, -- 177
					tonumber(line), -- 177
					0, -- 177
					msg -- 177
				} -- 177
			} -- 177
		} -- 177
	end -- 175
	local success, info = teal.checkAsync(content, file, true, "") -- 178
	if info then -- 179
		do -- 180
			local _accum_0 = { } -- 180
			local _len_0 = 1 -- 180
			for _index_0 = 1, #info do -- 180
				local item = info[_index_0] -- 180
				local useCheck = true -- 181
				if not item[5]:match("unused") then -- 182
					for _index_1 = 1, #disabledCheckForLua do -- 183
						local check = disabledCheckForLua[_index_1] -- 183
						if item[5]:match(check) then -- 184
							useCheck = false -- 185
						end -- 184
					end -- 183
				end -- 182
				if not useCheck then -- 186
					goto _continue_0 -- 186
				end -- 186
				do -- 187
					local _exp_0 = item[1] -- 187
					if "type" == _exp_0 then -- 188
						item[1] = "warning" -- 189
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 190
						goto _continue_0 -- 191
					end -- 187
				end -- 187
				_accum_0[_len_0] = item -- 192
				_len_0 = _len_0 + 1 -- 181
				::_continue_0:: -- 181
			end -- 180
			info = _accum_0 -- 180
		end -- 180
		if #info == 0 then -- 193
			info = nil -- 194
			success = true -- 195
		end -- 193
	end -- 179
	return { -- 196
		success = success, -- 196
		info = info -- 196
	} -- 196
end -- 173
local luaCheckWithLineInfo -- 198
luaCheckWithLineInfo = function(file, luaCodes) -- 198
	local res = luaCheck(file, luaCodes) -- 199
	local info = { } -- 200
	if not res.success then -- 201
		local current = 1 -- 202
		local lastLine = 1 -- 203
		local lineMap = { } -- 204
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 205
			local num = lineCode:match("--%s*(%d+)%s*$") -- 206
			if num then -- 207
				lastLine = tonumber(num) -- 208
			end -- 207
			lineMap[current] = lastLine -- 209
			current = current + 1 -- 210
		end -- 205
		local _list_0 = res.info -- 211
		for _index_0 = 1, #_list_0 do -- 211
			local item = _list_0[_index_0] -- 211
			item[3] = lineMap[item[3]] or 0 -- 212
			item[4] = 0 -- 213
			info[#info + 1] = item -- 214
		end -- 211
		return false, info -- 215
	end -- 201
	return true, info -- 216
end -- 198
local getCompiledYueLine -- 218
getCompiledYueLine = function(content, line, row, file, lax) -- 218
	local luaCodes = yueCheck(file, content, lax) -- 219
	if not luaCodes then -- 220
		return nil -- 220
	end -- 220
	local current = 1 -- 221
	local lastLine = 1 -- 222
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 223
	local targetRow = nil -- 224
	local lineMap = { } -- 225
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 226
		local num = lineCode:match("--%s*(%d+)%s*$") -- 227
		if num then -- 228
			lastLine = tonumber(num) -- 228
		end -- 228
		lineMap[current] = lastLine -- 229
		if row <= lastLine and not targetRow then -- 230
			targetRow = current -- 231
			break -- 232
		end -- 230
		current = current + 1 -- 233
	end -- 226
	targetRow = current -- 234
	if targetLine and targetRow then -- 235
		return luaCodes, targetLine, targetRow, lineMap -- 236
	else -- 238
		return nil -- 238
	end -- 235
end -- 218
HttpServer:postSchedule("/check", function(req) -- 240
	do -- 241
		local _type_0 = type(req) -- 241
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 241
		if _tab_0 then -- 241
			local file -- 241
			do -- 241
				local _obj_0 = req.body -- 241
				local _type_1 = type(_obj_0) -- 241
				if "table" == _type_1 or "userdata" == _type_1 then -- 241
					file = _obj_0.file -- 241
				end -- 241
			end -- 241
			local content -- 241
			do -- 241
				local _obj_0 = req.body -- 241
				local _type_1 = type(_obj_0) -- 241
				if "table" == _type_1 or "userdata" == _type_1 then -- 241
					content = _obj_0.content -- 241
				end -- 241
			end -- 241
			if file ~= nil and content ~= nil then -- 241
				local ext = Path:getExt(file) -- 242
				if "tl" == ext then -- 243
					local searchPath = getSearchPath(file) -- 244
					do -- 245
						local isTIC80 = CheckTIC80Code(content) -- 245
						if isTIC80 then -- 245
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 246
						end -- 245
					end -- 245
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 247
					return { -- 248
						success = success, -- 248
						info = info -- 248
					} -- 248
				elseif "lua" == ext then -- 249
					do -- 250
						local isTIC80 = CheckTIC80Code(content) -- 250
						if isTIC80 then -- 250
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 251
						end -- 250
					end -- 250
					return luaCheck(file, content) -- 252
				elseif "yue" == ext then -- 253
					local luaCodes, info = yueCheck(file, content, false) -- 254
					local success = false -- 255
					if luaCodes then -- 256
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 257
						do -- 258
							local _tab_1 = { } -- 258
							local _idx_0 = #_tab_1 + 1 -- 258
							for _index_0 = 1, #info do -- 258
								local _value_0 = info[_index_0] -- 258
								_tab_1[_idx_0] = _value_0 -- 258
								_idx_0 = _idx_0 + 1 -- 258
							end -- 258
							local _idx_1 = #_tab_1 + 1 -- 258
							for _index_0 = 1, #luaInfo do -- 258
								local _value_0 = luaInfo[_index_0] -- 258
								_tab_1[_idx_1] = _value_0 -- 258
								_idx_1 = _idx_1 + 1 -- 258
							end -- 258
							info = _tab_1 -- 258
						end -- 258
						success = success and luaSuccess -- 259
					end -- 256
					if #info > 0 then -- 260
						return { -- 261
							success = success, -- 261
							info = info -- 261
						} -- 261
					else -- 263
						return { -- 263
							success = success -- 263
						} -- 263
					end -- 260
				elseif "xml" == ext then -- 264
					local success, result = xml.check(content) -- 265
					if success then -- 266
						local info -- 267
						success, info = luaCheckWithLineInfo(file, result) -- 267
						if #info > 0 then -- 268
							return { -- 269
								success = success, -- 269
								info = info -- 269
							} -- 269
						else -- 271
							return { -- 271
								success = success -- 271
							} -- 271
						end -- 268
					else -- 273
						local info -- 273
						do -- 273
							local _accum_0 = { } -- 273
							local _len_0 = 1 -- 273
							for _index_0 = 1, #result do -- 273
								local _des_0 = result[_index_0] -- 273
								local row, err = _des_0[1], _des_0[2] -- 273
								_accum_0[_len_0] = { -- 274
									"syntax", -- 274
									file, -- 274
									row, -- 274
									0, -- 274
									err -- 274
								} -- 274
								_len_0 = _len_0 + 1 -- 274
							end -- 273
							info = _accum_0 -- 273
						end -- 273
						return { -- 275
							success = false, -- 275
							info = info -- 275
						} -- 275
					end -- 266
				end -- 243
			end -- 241
		end -- 241
	end -- 241
	return { -- 240
		success = true -- 240
	} -- 240
end) -- 240
local updateInferedDesc -- 277
updateInferedDesc = function(infered) -- 277
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 278
		return -- 278
	end -- 278
	local key, row = infered.key, infered.row -- 279
	local codes = Content:loadAsync(key) -- 280
	if codes then -- 280
		local comments = { } -- 281
		local line = 0 -- 282
		local skipping = false -- 283
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 284
			line = line + 1 -- 285
			if line >= row then -- 286
				break -- 286
			end -- 286
			if lineCode:match("^%s*%-%- @") then -- 287
				skipping = true -- 288
				goto _continue_0 -- 289
			end -- 287
			local result = lineCode:match("^%s*%-%- (.+)") -- 290
			if result then -- 290
				if not skipping then -- 291
					comments[#comments + 1] = result -- 291
				end -- 291
			elseif #comments > 0 then -- 292
				comments = { } -- 293
				skipping = false -- 294
			end -- 290
			::_continue_0:: -- 285
		end -- 284
		infered.doc = table.concat(comments, "\n") -- 295
	end -- 280
end -- 277
HttpServer:postSchedule("/infer", function(req) -- 297
	do -- 298
		local _type_0 = type(req) -- 298
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 298
		if _tab_0 then -- 298
			local lang -- 298
			do -- 298
				local _obj_0 = req.body -- 298
				local _type_1 = type(_obj_0) -- 298
				if "table" == _type_1 or "userdata" == _type_1 then -- 298
					lang = _obj_0.lang -- 298
				end -- 298
			end -- 298
			local file -- 298
			do -- 298
				local _obj_0 = req.body -- 298
				local _type_1 = type(_obj_0) -- 298
				if "table" == _type_1 or "userdata" == _type_1 then -- 298
					file = _obj_0.file -- 298
				end -- 298
			end -- 298
			local content -- 298
			do -- 298
				local _obj_0 = req.body -- 298
				local _type_1 = type(_obj_0) -- 298
				if "table" == _type_1 or "userdata" == _type_1 then -- 298
					content = _obj_0.content -- 298
				end -- 298
			end -- 298
			local line -- 298
			do -- 298
				local _obj_0 = req.body -- 298
				local _type_1 = type(_obj_0) -- 298
				if "table" == _type_1 or "userdata" == _type_1 then -- 298
					line = _obj_0.line -- 298
				end -- 298
			end -- 298
			local row -- 298
			do -- 298
				local _obj_0 = req.body -- 298
				local _type_1 = type(_obj_0) -- 298
				if "table" == _type_1 or "userdata" == _type_1 then -- 298
					row = _obj_0.row -- 298
				end -- 298
			end -- 298
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 298
				local searchPath = getSearchPath(file) -- 299
				if "tl" == lang or "lua" == lang then -- 300
					if CheckTIC80Code(content) then -- 301
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 302
					end -- 301
					local infered = teal.inferAsync(content, line, row, searchPath) -- 303
					if (infered ~= nil) then -- 304
						updateInferedDesc(infered) -- 305
						return { -- 306
							success = true, -- 306
							infered = infered -- 306
						} -- 306
					end -- 304
				elseif "yue" == lang then -- 307
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 308
					if not luaCodes then -- 309
						return { -- 309
							success = false -- 309
						} -- 309
					end -- 309
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 310
					if (infered ~= nil) then -- 311
						local col -- 312
						file, row, col = infered.file, infered.row, infered.col -- 312
						if file == "" and row > 0 and col > 0 then -- 313
							infered.row = lineMap[row] or 0 -- 314
							infered.col = 0 -- 315
						end -- 313
						updateInferedDesc(infered) -- 316
						return { -- 317
							success = true, -- 317
							infered = infered -- 317
						} -- 317
					end -- 311
				end -- 300
			end -- 298
		end -- 298
	end -- 298
	return { -- 297
		success = false -- 297
	} -- 297
end) -- 297
local _anon_func_0 = function(doc) -- 368
	local _accum_0 = { } -- 368
	local _len_0 = 1 -- 368
	local _list_0 = doc.params -- 368
	for _index_0 = 1, #_list_0 do -- 368
		local param = _list_0[_index_0] -- 368
		_accum_0[_len_0] = param.name -- 368
		_len_0 = _len_0 + 1 -- 368
	end -- 368
	return _accum_0 -- 368
end -- 368
local getParamDocs -- 319
getParamDocs = function(signatures) -- 319
	do -- 320
		local codes = Content:loadAsync(signatures[1].file) -- 320
		if codes then -- 320
			local comments = { } -- 321
			local params = { } -- 322
			local line = 0 -- 323
			local docs = { } -- 324
			local returnType = nil -- 325
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 326
				line = line + 1 -- 327
				local needBreak = true -- 328
				for i, _des_0 in ipairs(signatures) do -- 329
					local row = _des_0.row -- 329
					if line >= row and not (docs[i] ~= nil) then -- 330
						if #comments > 0 or #params > 0 or returnType then -- 331
							docs[i] = { -- 333
								doc = table.concat(comments, "  \n"), -- 333
								returnType = returnType -- 334
							} -- 332
							if #params > 0 then -- 336
								docs[i].params = params -- 336
							end -- 336
						else -- 338
							docs[i] = false -- 338
						end -- 331
					end -- 330
					if not docs[i] then -- 339
						needBreak = false -- 339
					end -- 339
				end -- 329
				if needBreak then -- 340
					break -- 340
				end -- 340
				local result = lineCode:match("%s*%-%- (.+)") -- 341
				if result then -- 341
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 342
					if not name then -- 343
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 344
					end -- 343
					if name then -- 345
						local pname = name -- 346
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 347
							pname = pname .. "?" -- 347
						end -- 347
						params[#params + 1] = { -- 349
							name = tostring(pname) .. ": " .. tostring(typ), -- 349
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 350
						} -- 348
					else -- 353
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 353
						if typ then -- 353
							if returnType then -- 354
								returnType = returnType .. ", " .. typ -- 355
							else -- 357
								returnType = typ -- 357
							end -- 354
							result = result:gsub("@return", "**return:**") -- 358
						end -- 353
						comments[#comments + 1] = result -- 359
					end -- 345
				elseif #comments > 0 then -- 360
					comments = { } -- 361
					params = { } -- 362
					returnType = nil -- 363
				end -- 341
			end -- 326
			local results = { } -- 364
			for _index_0 = 1, #docs do -- 365
				local doc = docs[_index_0] -- 365
				if not doc then -- 366
					goto _continue_0 -- 366
				end -- 366
				if doc.params then -- 367
					doc.desc = "function(" .. tostring(table.concat(_anon_func_0(doc), ', ')) .. ")" -- 368
				else -- 370
					doc.desc = "function()" -- 370
				end -- 367
				if doc.returnType then -- 371
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 372
					doc.returnType = nil -- 373
				end -- 371
				results[#results + 1] = doc -- 374
				::_continue_0:: -- 366
			end -- 365
			if #results > 0 then -- 375
				return results -- 375
			else -- 375
				return nil -- 375
			end -- 375
		end -- 320
	end -- 320
	return nil -- 319
end -- 319
HttpServer:postSchedule("/signature", function(req) -- 377
	do -- 378
		local _type_0 = type(req) -- 378
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 378
		if _tab_0 then -- 378
			local lang -- 378
			do -- 378
				local _obj_0 = req.body -- 378
				local _type_1 = type(_obj_0) -- 378
				if "table" == _type_1 or "userdata" == _type_1 then -- 378
					lang = _obj_0.lang -- 378
				end -- 378
			end -- 378
			local file -- 378
			do -- 378
				local _obj_0 = req.body -- 378
				local _type_1 = type(_obj_0) -- 378
				if "table" == _type_1 or "userdata" == _type_1 then -- 378
					file = _obj_0.file -- 378
				end -- 378
			end -- 378
			local content -- 378
			do -- 378
				local _obj_0 = req.body -- 378
				local _type_1 = type(_obj_0) -- 378
				if "table" == _type_1 or "userdata" == _type_1 then -- 378
					content = _obj_0.content -- 378
				end -- 378
			end -- 378
			local line -- 378
			do -- 378
				local _obj_0 = req.body -- 378
				local _type_1 = type(_obj_0) -- 378
				if "table" == _type_1 or "userdata" == _type_1 then -- 378
					line = _obj_0.line -- 378
				end -- 378
			end -- 378
			local row -- 378
			do -- 378
				local _obj_0 = req.body -- 378
				local _type_1 = type(_obj_0) -- 378
				if "table" == _type_1 or "userdata" == _type_1 then -- 378
					row = _obj_0.row -- 378
				end -- 378
			end -- 378
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 378
				local searchPath = getSearchPath(file) -- 379
				if "tl" == lang or "lua" == lang then -- 380
					if CheckTIC80Code(content) then -- 381
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 382
					end -- 381
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 383
					if signatures then -- 383
						signatures = getParamDocs(signatures) -- 384
						if signatures then -- 384
							return { -- 385
								success = true, -- 385
								signatures = signatures -- 385
							} -- 385
						end -- 384
					end -- 383
				elseif "yue" == lang then -- 386
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 387
					if not luaCodes then -- 388
						return { -- 388
							success = false -- 388
						} -- 388
					end -- 388
					do -- 389
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 389
						if chainOp then -- 389
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 390
							if withVar then -- 390
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 391
							end -- 390
						end -- 389
					end -- 389
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 392
					if signatures then -- 392
						signatures = getParamDocs(signatures) -- 393
						if signatures then -- 393
							return { -- 394
								success = true, -- 394
								signatures = signatures -- 394
							} -- 394
						end -- 393
					else -- 395
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 395
						if signatures then -- 395
							signatures = getParamDocs(signatures) -- 396
							if signatures then -- 396
								return { -- 397
									success = true, -- 397
									signatures = signatures -- 397
								} -- 397
							end -- 396
						end -- 395
					end -- 392
				end -- 380
			end -- 378
		end -- 378
	end -- 378
	return { -- 377
		success = false -- 377
	} -- 377
end) -- 377
local luaKeywords = { -- 400
	'and', -- 400
	'break', -- 401
	'do', -- 402
	'else', -- 403
	'elseif', -- 404
	'end', -- 405
	'false', -- 406
	'for', -- 407
	'function', -- 408
	'goto', -- 409
	'if', -- 410
	'in', -- 411
	'local', -- 412
	'nil', -- 413
	'not', -- 414
	'or', -- 415
	'repeat', -- 416
	'return', -- 417
	'then', -- 418
	'true', -- 419
	'until', -- 420
	'while' -- 421
} -- 399
local tealKeywords = { -- 425
	'record', -- 425
	'as', -- 426
	'is', -- 427
	'type', -- 428
	'embed', -- 429
	'enum', -- 430
	'global', -- 431
	'any', -- 432
	'boolean', -- 433
	'integer', -- 434
	'number', -- 435
	'string', -- 436
	'thread' -- 437
} -- 424
local yueKeywords = { -- 441
	"and", -- 441
	"break", -- 442
	"do", -- 443
	"else", -- 444
	"elseif", -- 445
	"false", -- 446
	"for", -- 447
	"goto", -- 448
	"if", -- 449
	"in", -- 450
	"local", -- 451
	"nil", -- 452
	"not", -- 453
	"or", -- 454
	"repeat", -- 455
	"return", -- 456
	"then", -- 457
	"true", -- 458
	"until", -- 459
	"while", -- 460
	"as", -- 461
	"class", -- 462
	"continue", -- 463
	"export", -- 464
	"extends", -- 465
	"from", -- 466
	"global", -- 467
	"import", -- 468
	"macro", -- 469
	"switch", -- 470
	"try", -- 471
	"unless", -- 472
	"using", -- 473
	"when", -- 474
	"with" -- 475
} -- 440
local _anon_func_1 = function(f) -- 511
	local _val_0 = Path:getExt(f) -- 511
	return "ttf" == _val_0 or "otf" == _val_0 -- 511
end -- 511
local _anon_func_2 = function(suggestions) -- 537
	local _tbl_0 = { } -- 537
	for _index_0 = 1, #suggestions do -- 537
		local item = suggestions[_index_0] -- 537
		_tbl_0[item[1] .. item[2]] = item -- 537
	end -- 537
	return _tbl_0 -- 537
end -- 537
HttpServer:postSchedule("/complete", function(req) -- 478
	do -- 479
		local _type_0 = type(req) -- 479
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 479
		if _tab_0 then -- 479
			local lang -- 479
			do -- 479
				local _obj_0 = req.body -- 479
				local _type_1 = type(_obj_0) -- 479
				if "table" == _type_1 or "userdata" == _type_1 then -- 479
					lang = _obj_0.lang -- 479
				end -- 479
			end -- 479
			local file -- 479
			do -- 479
				local _obj_0 = req.body -- 479
				local _type_1 = type(_obj_0) -- 479
				if "table" == _type_1 or "userdata" == _type_1 then -- 479
					file = _obj_0.file -- 479
				end -- 479
			end -- 479
			local content -- 479
			do -- 479
				local _obj_0 = req.body -- 479
				local _type_1 = type(_obj_0) -- 479
				if "table" == _type_1 or "userdata" == _type_1 then -- 479
					content = _obj_0.content -- 479
				end -- 479
			end -- 479
			local line -- 479
			do -- 479
				local _obj_0 = req.body -- 479
				local _type_1 = type(_obj_0) -- 479
				if "table" == _type_1 or "userdata" == _type_1 then -- 479
					line = _obj_0.line -- 479
				end -- 479
			end -- 479
			local row -- 479
			do -- 479
				local _obj_0 = req.body -- 479
				local _type_1 = type(_obj_0) -- 479
				if "table" == _type_1 or "userdata" == _type_1 then -- 479
					row = _obj_0.row -- 479
				end -- 479
			end -- 479
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 479
				local searchPath = getSearchPath(file) -- 480
				repeat -- 481
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 482
					if lang == "yue" then -- 483
						if not item then -- 484
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 484
						end -- 484
						if not item then -- 485
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 485
						end -- 485
					end -- 483
					local searchType = nil -- 486
					if not item then -- 487
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 488
						if lang == "yue" then -- 489
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 490
						end -- 489
						if (item ~= nil) then -- 491
							searchType = "Image" -- 491
						end -- 491
					end -- 487
					if not item then -- 492
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 493
						if lang == "yue" then -- 494
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 495
						end -- 494
						if (item ~= nil) then -- 496
							searchType = "Font" -- 496
						end -- 496
					end -- 492
					if not item then -- 497
						break -- 497
					end -- 497
					local searchPaths = Content.searchPaths -- 498
					local _list_0 = getSearchFolders(file) -- 499
					for _index_0 = 1, #_list_0 do -- 499
						local folder = _list_0[_index_0] -- 499
						searchPaths[#searchPaths + 1] = folder -- 500
					end -- 499
					if searchType then -- 501
						searchPaths[#searchPaths + 1] = Content.assetPath -- 501
					end -- 501
					local tokens -- 502
					do -- 502
						local _accum_0 = { } -- 502
						local _len_0 = 1 -- 502
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 502
							_accum_0[_len_0] = mod -- 502
							_len_0 = _len_0 + 1 -- 502
						end -- 502
						tokens = _accum_0 -- 502
					end -- 502
					local suggestions = { } -- 503
					for _index_0 = 1, #searchPaths do -- 504
						local path = searchPaths[_index_0] -- 504
						local sPath = Path(path, table.unpack(tokens)) -- 505
						if not Content:exist(sPath) then -- 506
							goto _continue_0 -- 506
						end -- 506
						if searchType == "Font" then -- 507
							local fontPath = Path(sPath, "Font") -- 508
							if Content:exist(fontPath) then -- 509
								local _list_1 = Content:getFiles(fontPath) -- 510
								for _index_1 = 1, #_list_1 do -- 510
									local f = _list_1[_index_1] -- 510
									if _anon_func_1(f) then -- 511
										if "." == f:sub(1, 1) then -- 512
											goto _continue_1 -- 512
										end -- 512
										suggestions[#suggestions + 1] = { -- 513
											Path:getName(f), -- 513
											"font", -- 513
											"field" -- 513
										} -- 513
									end -- 511
									::_continue_1:: -- 511
								end -- 510
							end -- 509
						end -- 507
						local _list_1 = Content:getFiles(sPath) -- 514
						for _index_1 = 1, #_list_1 do -- 514
							local f = _list_1[_index_1] -- 514
							if "Image" == searchType then -- 515
								do -- 516
									local _exp_0 = Path:getExt(f) -- 516
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 516
										if "." == f:sub(1, 1) then -- 517
											goto _continue_2 -- 517
										end -- 517
										suggestions[#suggestions + 1] = { -- 518
											f, -- 518
											"image", -- 518
											"field" -- 518
										} -- 518
									end -- 516
								end -- 516
								goto _continue_2 -- 519
							elseif "Font" == searchType then -- 520
								do -- 521
									local _exp_0 = Path:getExt(f) -- 521
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 521
										if "." == f:sub(1, 1) then -- 522
											goto _continue_2 -- 522
										end -- 522
										suggestions[#suggestions + 1] = { -- 523
											f, -- 523
											"font", -- 523
											"field" -- 523
										} -- 523
									end -- 521
								end -- 521
								goto _continue_2 -- 524
							end -- 515
							local _exp_0 = Path:getExt(f) -- 525
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 525
								local name = Path:getName(f) -- 526
								if "d" == Path:getExt(name) then -- 527
									goto _continue_2 -- 527
								end -- 527
								if "." == name:sub(1, 1) then -- 528
									goto _continue_2 -- 528
								end -- 528
								suggestions[#suggestions + 1] = { -- 529
									name, -- 529
									"module", -- 529
									"field" -- 529
								} -- 529
							end -- 525
							::_continue_2:: -- 515
						end -- 514
						local _list_2 = Content:getDirs(sPath) -- 530
						for _index_1 = 1, #_list_2 do -- 530
							local dir = _list_2[_index_1] -- 530
							if "." == dir:sub(1, 1) then -- 531
								goto _continue_3 -- 531
							end -- 531
							suggestions[#suggestions + 1] = { -- 532
								dir, -- 532
								"folder", -- 532
								"variable" -- 532
							} -- 532
							::_continue_3:: -- 531
						end -- 530
						::_continue_0:: -- 505
					end -- 504
					if item == "" and not searchType then -- 533
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 534
						for _index_0 = 1, #_list_1 do -- 534
							local _des_0 = _list_1[_index_0] -- 534
							local name = _des_0[1] -- 534
							suggestions[#suggestions + 1] = { -- 535
								name, -- 535
								"dora module", -- 535
								"function" -- 535
							} -- 535
						end -- 534
					end -- 533
					if #suggestions > 0 then -- 536
						do -- 537
							local _accum_0 = { } -- 537
							local _len_0 = 1 -- 537
							for _, v in pairs(_anon_func_2(suggestions)) do -- 537
								_accum_0[_len_0] = v -- 537
								_len_0 = _len_0 + 1 -- 537
							end -- 537
							suggestions = _accum_0 -- 537
						end -- 537
						return { -- 538
							success = true, -- 538
							suggestions = suggestions -- 538
						} -- 538
					else -- 540
						return { -- 540
							success = false -- 540
						} -- 540
					end -- 536
				until true -- 481
				if "tl" == lang or "lua" == lang then -- 542
					do -- 543
						local isTIC80 = CheckTIC80Code(content) -- 543
						if isTIC80 then -- 543
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 544
						end -- 543
					end -- 543
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 545
					if not line:match("[%.:]$") then -- 546
						local checkSet -- 547
						do -- 547
							local _tbl_0 = { } -- 547
							for _index_0 = 1, #suggestions do -- 547
								local _des_0 = suggestions[_index_0] -- 547
								local name = _des_0[1] -- 547
								_tbl_0[name] = true -- 547
							end -- 547
							checkSet = _tbl_0 -- 547
						end -- 547
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 548
						for _index_0 = 1, #_list_0 do -- 548
							local item = _list_0[_index_0] -- 548
							if not checkSet[item[1]] then -- 549
								suggestions[#suggestions + 1] = item -- 549
							end -- 549
						end -- 548
						for _index_0 = 1, #luaKeywords do -- 550
							local word = luaKeywords[_index_0] -- 550
							suggestions[#suggestions + 1] = { -- 551
								word, -- 551
								"keyword", -- 551
								"keyword" -- 551
							} -- 551
						end -- 550
						if lang == "tl" then -- 552
							for _index_0 = 1, #tealKeywords do -- 553
								local word = tealKeywords[_index_0] -- 553
								suggestions[#suggestions + 1] = { -- 554
									word, -- 554
									"keyword", -- 554
									"keyword" -- 554
								} -- 554
							end -- 553
						end -- 552
					end -- 546
					if #suggestions > 0 then -- 555
						return { -- 556
							success = true, -- 556
							suggestions = suggestions -- 556
						} -- 556
					end -- 555
				elseif "yue" == lang then -- 557
					local suggestions = { } -- 558
					local gotGlobals = false -- 559
					do -- 560
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 560
						if luaCodes then -- 560
							gotGlobals = true -- 561
							do -- 562
								local chainOp = line:match("[^%w_]([%.\\])$") -- 562
								if chainOp then -- 562
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 563
									if not withVar then -- 564
										return { -- 564
											success = false -- 564
										} -- 564
									end -- 564
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 565
								elseif line:match("^([%.\\])$") then -- 566
									return { -- 567
										success = false -- 567
									} -- 567
								end -- 562
							end -- 562
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 568
							for _index_0 = 1, #_list_0 do -- 568
								local item = _list_0[_index_0] -- 568
								suggestions[#suggestions + 1] = item -- 568
							end -- 568
							if #suggestions == 0 then -- 569
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 570
								for _index_0 = 1, #_list_1 do -- 570
									local item = _list_1[_index_0] -- 570
									suggestions[#suggestions + 1] = item -- 570
								end -- 570
							end -- 569
						end -- 560
					end -- 560
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 571
						local checkSet -- 572
						do -- 572
							local _tbl_0 = { } -- 572
							for _index_0 = 1, #suggestions do -- 572
								local _des_0 = suggestions[_index_0] -- 572
								local name = _des_0[1] -- 572
								_tbl_0[name] = true -- 572
							end -- 572
							checkSet = _tbl_0 -- 572
						end -- 572
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 573
						for _index_0 = 1, #_list_0 do -- 573
							local item = _list_0[_index_0] -- 573
							if not checkSet[item[1]] then -- 574
								suggestions[#suggestions + 1] = item -- 574
							end -- 574
						end -- 573
						if not gotGlobals then -- 575
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 576
							for _index_0 = 1, #_list_1 do -- 576
								local item = _list_1[_index_0] -- 576
								if not checkSet[item[1]] then -- 577
									suggestions[#suggestions + 1] = item -- 577
								end -- 577
							end -- 576
						end -- 575
						for _index_0 = 1, #yueKeywords do -- 578
							local word = yueKeywords[_index_0] -- 578
							if not checkSet[word] then -- 579
								suggestions[#suggestions + 1] = { -- 580
									word, -- 580
									"keyword", -- 580
									"keyword" -- 580
								} -- 580
							end -- 579
						end -- 578
					end -- 571
					if #suggestions > 0 then -- 581
						return { -- 582
							success = true, -- 582
							suggestions = suggestions -- 582
						} -- 582
					end -- 581
				elseif "xml" == lang then -- 583
					local items = xml.complete(content) -- 584
					if #items > 0 then -- 585
						local suggestions -- 586
						do -- 586
							local _accum_0 = { } -- 586
							local _len_0 = 1 -- 586
							for _index_0 = 1, #items do -- 586
								local _des_0 = items[_index_0] -- 586
								local label, insertText = _des_0[1], _des_0[2] -- 586
								_accum_0[_len_0] = { -- 587
									label, -- 587
									insertText, -- 587
									"field" -- 587
								} -- 587
								_len_0 = _len_0 + 1 -- 587
							end -- 586
							suggestions = _accum_0 -- 586
						end -- 586
						return { -- 588
							success = true, -- 588
							suggestions = suggestions -- 588
						} -- 588
					end -- 585
				end -- 542
			end -- 479
		end -- 479
	end -- 479
	return { -- 478
		success = false -- 478
	} -- 478
end) -- 478
HttpServer:upload("/upload", function(req, filename) -- 592
	do -- 593
		local _type_0 = type(req) -- 593
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 593
		if _tab_0 then -- 593
			local path -- 593
			do -- 593
				local _obj_0 = req.params -- 593
				local _type_1 = type(_obj_0) -- 593
				if "table" == _type_1 or "userdata" == _type_1 then -- 593
					path = _obj_0.path -- 593
				end -- 593
			end -- 593
			if path ~= nil then -- 593
				local uploadPath = Path(Content.writablePath, ".upload") -- 594
				if not Content:exist(uploadPath) then -- 595
					Content:mkdir(uploadPath) -- 596
				end -- 595
				local targetPath = Path(uploadPath, filename) -- 597
				Content:mkdir(Path:getPath(targetPath)) -- 598
				return targetPath -- 599
			end -- 593
		end -- 593
	end -- 593
	return nil -- 592
end, function(req, file) -- 600
	do -- 601
		local _type_0 = type(req) -- 601
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 601
		if _tab_0 then -- 601
			local path -- 601
			do -- 601
				local _obj_0 = req.params -- 601
				local _type_1 = type(_obj_0) -- 601
				if "table" == _type_1 or "userdata" == _type_1 then -- 601
					path = _obj_0.path -- 601
				end -- 601
			end -- 601
			if path ~= nil then -- 601
				path = Path(Content.writablePath, path) -- 602
				if Content:exist(path) then -- 603
					local uploadPath = Path(Content.writablePath, ".upload") -- 604
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 605
					Content:mkdir(Path:getPath(targetPath)) -- 606
					if Content:move(file, targetPath) then -- 607
						return true -- 608
					end -- 607
				end -- 603
			end -- 601
		end -- 601
	end -- 601
	return false -- 600
end) -- 590
HttpServer:post("/list", function(req) -- 611
	do -- 612
		local _type_0 = type(req) -- 612
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 612
		if _tab_0 then -- 612
			local path -- 612
			do -- 612
				local _obj_0 = req.body -- 612
				local _type_1 = type(_obj_0) -- 612
				if "table" == _type_1 or "userdata" == _type_1 then -- 612
					path = _obj_0.path -- 612
				end -- 612
			end -- 612
			if path ~= nil then -- 612
				if Content:exist(path) then -- 613
					local files = { } -- 614
					local visitAssets -- 615
					visitAssets = function(path, folder) -- 615
						local dirs = Content:getDirs(path) -- 616
						for _index_0 = 1, #dirs do -- 617
							local dir = dirs[_index_0] -- 617
							if dir:match("^%.") then -- 618
								goto _continue_0 -- 618
							end -- 618
							local current -- 619
							if folder == "" then -- 619
								current = dir -- 620
							else -- 622
								current = Path(folder, dir) -- 622
							end -- 619
							files[#files + 1] = current -- 623
							visitAssets(Path(path, dir), current) -- 624
							::_continue_0:: -- 618
						end -- 617
						local fs = Content:getFiles(path) -- 625
						for _index_0 = 1, #fs do -- 626
							local f = fs[_index_0] -- 626
							if f:match("^%.") then -- 627
								goto _continue_1 -- 627
							end -- 627
							if folder == "" then -- 628
								files[#files + 1] = f -- 629
							else -- 631
								files[#files + 1] = Path(folder, f) -- 631
							end -- 628
							::_continue_1:: -- 627
						end -- 626
					end -- 615
					visitAssets(path, "") -- 632
					if #files == 0 then -- 633
						files = nil -- 633
					end -- 633
					return { -- 634
						success = true, -- 634
						files = files -- 634
					} -- 634
				end -- 613
			end -- 612
		end -- 612
	end -- 612
	return { -- 611
		success = false -- 611
	} -- 611
end) -- 611
HttpServer:post("/info", function() -- 636
	local Entry = require("Script.Dev.Entry") -- 637
	local webProfiler, drawerWidth -- 638
	do -- 638
		local _obj_0 = Entry.getConfig() -- 638
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 638
	end -- 638
	local engineDev = Entry.getEngineDev() -- 639
	Entry.connectWebIDE() -- 640
	return { -- 642
		platform = App.platform, -- 642
		locale = App.locale, -- 643
		version = App.version, -- 644
		engineDev = engineDev, -- 645
		webProfiler = webProfiler, -- 646
		drawerWidth = drawerWidth -- 647
	} -- 641
end) -- 636
local ensureLLMConfigTable -- 649
ensureLLMConfigTable = function() -- 649
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
	]]) -- 650
end -- 649
HttpServer:post("/llm/list", function() -- 663
	ensureLLMConfigTable() -- 664
	local rows = DB:query("\n		select id, name, url, model, api_key, active\n		from LLMConfig\n		order by id asc") -- 665
	local items -- 669
	if rows and #rows > 0 then -- 669
		local _accum_0 = { } -- 670
		local _len_0 = 1 -- 670
		for _index_0 = 1, #rows do -- 670
			local _des_0 = rows[_index_0] -- 670
			local id, name, url, model, key, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6] -- 670
			_accum_0[_len_0] = { -- 671
				id = id, -- 671
				name = name, -- 671
				url = url, -- 671
				model = model, -- 671
				key = key, -- 671
				active = active ~= 0 -- 671
			} -- 671
			_len_0 = _len_0 + 1 -- 671
		end -- 670
		items = _accum_0 -- 669
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
			local body = req.body -- 676
			if body ~= nil then -- 676
				local name, url, model, key, active = body.name, body.url, body.model, body.key, body.active -- 677
				local now = os.time() -- 678
				if name == nil or url == nil or model == nil or key == nil then -- 679
					return { -- 680
						success = false, -- 680
						message = "invalid" -- 680
					} -- 680
				end -- 679
				if active then -- 681
					active = 1 -- 681
				else -- 681
					active = 0 -- 681
				end -- 681
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?\n			)", { -- 688
					tostring(name), -- 688
					tostring(url), -- 689
					tostring(model), -- 690
					tostring(key), -- 691
					active, -- 692
					now, -- 693
					now -- 694
				}) -- 682
				return { -- 696
					success = affected >= 0 -- 696
				} -- 696
			end -- 676
		end -- 676
	end -- 676
	return { -- 674
		success = false, -- 674
		message = "invalid" -- 674
	} -- 674
end) -- 674
HttpServer:post("/llm/update", function(req) -- 698
	ensureLLMConfigTable() -- 699
	do -- 700
		local _type_0 = type(req) -- 700
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 700
		if _tab_0 then -- 700
			local body = req.body -- 700
			if body ~= nil then -- 700
				local id, name, url, model, key, active = body.id, body.name, body.url, body.model, body.key, body.active -- 701
				local now = os.time() -- 702
				id = tonumber(id) -- 703
				if id == nil then -- 704
					return { -- 705
						success = false, -- 705
						message = "invalid" -- 705
					} -- 705
				end -- 704
				if active then -- 706
					active = 1 -- 706
				else -- 706
					active = 0 -- 706
				end -- 706
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, active = ?, updated_at = ?\n			where id = ?", { -- 711
					tostring(name), -- 711
					tostring(url), -- 712
					tostring(model), -- 713
					tostring(key), -- 714
					active, -- 715
					now, -- 716
					id -- 717
				}) -- 707
				return { -- 719
					success = affected >= 0 -- 719
				} -- 719
			end -- 700
		end -- 700
	end -- 700
	return { -- 698
		success = false, -- 698
		message = "invalid" -- 698
	} -- 698
end) -- 698
HttpServer:post("/llm/delete", function(req) -- 721
	ensureLLMConfigTable() -- 722
	do -- 723
		local _type_0 = type(req) -- 723
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 723
		if _tab_0 then -- 723
			local id -- 723
			do -- 723
				local _obj_0 = req.body -- 723
				local _type_1 = type(_obj_0) -- 723
				if "table" == _type_1 or "userdata" == _type_1 then -- 723
					id = _obj_0.id -- 723
				end -- 723
			end -- 723
			if id ~= nil then -- 723
				id = tonumber(id) -- 724
				if id == nil then -- 725
					return { -- 726
						success = false, -- 726
						message = "invalid" -- 726
					} -- 726
				end -- 725
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 727
					id -- 727
				}) -- 727
				return { -- 728
					success = affected >= 0 -- 728
				} -- 728
			end -- 723
		end -- 723
	end -- 723
	return { -- 721
		success = false, -- 721
		message = "invalid" -- 721
	} -- 721
end) -- 721
HttpServer:post("/new", function(req) -- 730
	do -- 731
		local _type_0 = type(req) -- 731
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 731
		if _tab_0 then -- 731
			local path -- 731
			do -- 731
				local _obj_0 = req.body -- 731
				local _type_1 = type(_obj_0) -- 731
				if "table" == _type_1 or "userdata" == _type_1 then -- 731
					path = _obj_0.path -- 731
				end -- 731
			end -- 731
			local content -- 731
			do -- 731
				local _obj_0 = req.body -- 731
				local _type_1 = type(_obj_0) -- 731
				if "table" == _type_1 or "userdata" == _type_1 then -- 731
					content = _obj_0.content -- 731
				end -- 731
			end -- 731
			local folder -- 731
			do -- 731
				local _obj_0 = req.body -- 731
				local _type_1 = type(_obj_0) -- 731
				if "table" == _type_1 or "userdata" == _type_1 then -- 731
					folder = _obj_0.folder -- 731
				end -- 731
			end -- 731
			if path ~= nil and content ~= nil and folder ~= nil then -- 731
				if Content:exist(path) then -- 732
					return { -- 733
						success = false, -- 733
						message = "TargetExisted" -- 733
					} -- 733
				end -- 732
				local parent = Path:getPath(path) -- 734
				local files = Content:getFiles(parent) -- 735
				if folder then -- 736
					local name = Path:getFilename(path):lower() -- 737
					for _index_0 = 1, #files do -- 738
						local file = files[_index_0] -- 738
						if name == Path:getFilename(file):lower() then -- 739
							return { -- 740
								success = false, -- 740
								message = "TargetExisted" -- 740
							} -- 740
						end -- 739
					end -- 738
					if Content:mkdir(path) then -- 741
						return { -- 742
							success = true -- 742
						} -- 742
					end -- 741
				else -- 744
					local name = Path:getName(path):lower() -- 744
					for _index_0 = 1, #files do -- 745
						local file = files[_index_0] -- 745
						if name == Path:getName(file):lower() then -- 746
							local ext = Path:getExt(file) -- 747
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 748
								goto _continue_0 -- 749
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 750
								goto _continue_0 -- 751
							end -- 748
							return { -- 752
								success = false, -- 752
								message = "SourceExisted" -- 752
							} -- 752
						end -- 746
						::_continue_0:: -- 746
					end -- 745
					if Content:save(path, content) then -- 753
						return { -- 754
							success = true -- 754
						} -- 754
					end -- 753
				end -- 736
			end -- 731
		end -- 731
	end -- 731
	return { -- 730
		success = false, -- 730
		message = "Failed" -- 730
	} -- 730
end) -- 730
HttpServer:post("/delete", function(req) -- 756
	do -- 757
		local _type_0 = type(req) -- 757
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 757
		if _tab_0 then -- 757
			local path -- 757
			do -- 757
				local _obj_0 = req.body -- 757
				local _type_1 = type(_obj_0) -- 757
				if "table" == _type_1 or "userdata" == _type_1 then -- 757
					path = _obj_0.path -- 757
				end -- 757
			end -- 757
			if path ~= nil then -- 757
				if Content:exist(path) then -- 758
					local parent = Path:getPath(path) -- 759
					local files = Content:getFiles(parent) -- 760
					local name = Path:getName(path):lower() -- 761
					local ext = Path:getExt(path) -- 762
					for _index_0 = 1, #files do -- 763
						local file = files[_index_0] -- 763
						if name == Path:getName(file):lower() then -- 764
							local _exp_0 = Path:getExt(file) -- 765
							if "tl" == _exp_0 then -- 765
								if ("vs" == ext) then -- 765
									Content:remove(Path(parent, file)) -- 766
								end -- 765
							elseif "lua" == _exp_0 then -- 767
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 767
									Content:remove(Path(parent, file)) -- 768
								end -- 767
							end -- 765
						end -- 764
					end -- 763
					if Content:remove(path) then -- 769
						return { -- 770
							success = true -- 770
						} -- 770
					end -- 769
				end -- 758
			end -- 757
		end -- 757
	end -- 757
	return { -- 756
		success = false -- 756
	} -- 756
end) -- 756
HttpServer:post("/rename", function(req) -- 772
	do -- 773
		local _type_0 = type(req) -- 773
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 773
		if _tab_0 then -- 773
			local old -- 773
			do -- 773
				local _obj_0 = req.body -- 773
				local _type_1 = type(_obj_0) -- 773
				if "table" == _type_1 or "userdata" == _type_1 then -- 773
					old = _obj_0.old -- 773
				end -- 773
			end -- 773
			local new -- 773
			do -- 773
				local _obj_0 = req.body -- 773
				local _type_1 = type(_obj_0) -- 773
				if "table" == _type_1 or "userdata" == _type_1 then -- 773
					new = _obj_0.new -- 773
				end -- 773
			end -- 773
			if old ~= nil and new ~= nil then -- 773
				if Content:exist(old) and not Content:exist(new) then -- 774
					local parent = Path:getPath(new) -- 775
					local files = Content:getFiles(parent) -- 776
					if Content:isdir(old) then -- 777
						local name = Path:getFilename(new):lower() -- 778
						for _index_0 = 1, #files do -- 779
							local file = files[_index_0] -- 779
							if name == Path:getFilename(file):lower() then -- 780
								return { -- 781
									success = false -- 781
								} -- 781
							end -- 780
						end -- 779
					else -- 783
						local name = Path:getName(new):lower() -- 783
						local ext = Path:getExt(new) -- 784
						for _index_0 = 1, #files do -- 785
							local file = files[_index_0] -- 785
							if name == Path:getName(file):lower() then -- 786
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 787
									goto _continue_0 -- 788
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 789
									goto _continue_0 -- 790
								end -- 787
								return { -- 791
									success = false -- 791
								} -- 791
							end -- 786
							::_continue_0:: -- 786
						end -- 785
					end -- 777
					if Content:move(old, new) then -- 792
						local newParent = Path:getPath(new) -- 793
						parent = Path:getPath(old) -- 794
						files = Content:getFiles(parent) -- 795
						local newName = Path:getName(new) -- 796
						local oldName = Path:getName(old) -- 797
						local name = oldName:lower() -- 798
						local ext = Path:getExt(old) -- 799
						for _index_0 = 1, #files do -- 800
							local file = files[_index_0] -- 800
							if name == Path:getName(file):lower() then -- 801
								local _exp_0 = Path:getExt(file) -- 802
								if "tl" == _exp_0 then -- 802
									if ("vs" == ext) then -- 802
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 803
									end -- 802
								elseif "lua" == _exp_0 then -- 804
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 804
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 805
									end -- 804
								end -- 802
							end -- 801
						end -- 800
						return { -- 806
							success = true -- 806
						} -- 806
					end -- 792
				end -- 774
			end -- 773
		end -- 773
	end -- 773
	return { -- 772
		success = false -- 772
	} -- 772
end) -- 772
HttpServer:post("/exist", function(req) -- 808
	do -- 809
		local _type_0 = type(req) -- 809
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 809
		if _tab_0 then -- 809
			local file -- 809
			do -- 809
				local _obj_0 = req.body -- 809
				local _type_1 = type(_obj_0) -- 809
				if "table" == _type_1 or "userdata" == _type_1 then -- 809
					file = _obj_0.file -- 809
				end -- 809
			end -- 809
			if file ~= nil then -- 809
				do -- 810
					local projFile = req.body.projFile -- 810
					if projFile then -- 810
						local projDir = getProjectDirFromFile(projFile) -- 811
						if projDir then -- 811
							local scriptDir = Path(projDir, "Script") -- 812
							local searchPaths = Content.searchPaths -- 813
							if Content:exist(scriptDir) then -- 814
								Content:addSearchPath(scriptDir) -- 814
							end -- 814
							if Content:exist(projDir) then -- 815
								Content:addSearchPath(projDir) -- 815
							end -- 815
							local _ <close> = setmetatable({ }, { -- 816
								__close = function() -- 816
									Content.searchPaths = searchPaths -- 816
								end -- 816
							}) -- 816
							return { -- 817
								success = Content:exist(file) -- 817
							} -- 817
						end -- 811
					end -- 810
				end -- 810
				return { -- 818
					success = Content:exist(file) -- 818
				} -- 818
			end -- 809
		end -- 809
	end -- 809
	return { -- 808
		success = false -- 808
	} -- 808
end) -- 808
HttpServer:postSchedule("/read", function(req) -- 820
	do -- 821
		local _type_0 = type(req) -- 821
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 821
		if _tab_0 then -- 821
			local path -- 821
			do -- 821
				local _obj_0 = req.body -- 821
				local _type_1 = type(_obj_0) -- 821
				if "table" == _type_1 or "userdata" == _type_1 then -- 821
					path = _obj_0.path -- 821
				end -- 821
			end -- 821
			if path ~= nil then -- 821
				local readFile -- 822
				readFile = function() -- 822
					if Content:exist(path) then -- 823
						local content = Content:loadAsync(path) -- 824
						if content then -- 824
							return { -- 825
								content = content, -- 825
								success = true -- 825
							} -- 825
						end -- 824
					end -- 823
					return nil -- 822
				end -- 822
				do -- 826
					local projFile = req.body.projFile -- 826
					if projFile then -- 826
						local projDir = getProjectDirFromFile(projFile) -- 827
						if projDir then -- 827
							local scriptDir = Path(projDir, "Script") -- 828
							local searchPaths = Content.searchPaths -- 829
							if Content:exist(scriptDir) then -- 830
								Content:addSearchPath(scriptDir) -- 830
							end -- 830
							if Content:exist(projDir) then -- 831
								Content:addSearchPath(projDir) -- 831
							end -- 831
							local _ <close> = setmetatable({ }, { -- 832
								__close = function() -- 832
									Content.searchPaths = searchPaths -- 832
								end -- 832
							}) -- 832
							local result = readFile() -- 833
							if result then -- 833
								return result -- 833
							end -- 833
						end -- 827
					end -- 826
				end -- 826
				local result = readFile() -- 834
				if result then -- 834
					return result -- 834
				end -- 834
			end -- 821
		end -- 821
	end -- 821
	return { -- 820
		success = false -- 820
	} -- 820
end) -- 820
HttpServer:get("/read-sync", function(req) -- 836
	do -- 837
		local _type_0 = type(req) -- 837
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 837
		if _tab_0 then -- 837
			local params = req.params -- 837
			if params ~= nil then -- 837
				local path = params.path -- 838
				local exts -- 839
				if params.exts then -- 839
					local _accum_0 = { } -- 840
					local _len_0 = 1 -- 840
					for ext in params.exts:gmatch("[^|]*") do -- 840
						_accum_0[_len_0] = ext -- 841
						_len_0 = _len_0 + 1 -- 841
					end -- 840
					exts = _accum_0 -- 839
				else -- 842
					exts = { -- 842
						"" -- 842
					} -- 842
				end -- 839
				local readFile -- 843
				readFile = function() -- 843
					for _index_0 = 1, #exts do -- 844
						local ext = exts[_index_0] -- 844
						local targetPath = path .. ext -- 845
						if Content:exist(targetPath) then -- 846
							local content = Content:load(targetPath) -- 847
							if content then -- 847
								return { -- 848
									content = content, -- 848
									success = true, -- 848
									fullPath = Content:getFullPath(targetPath) -- 848
								} -- 848
							end -- 847
						end -- 846
					end -- 844
					return nil -- 843
				end -- 843
				local searchPaths = Content.searchPaths -- 849
				local _ <close> = setmetatable({ }, { -- 850
					__close = function() -- 850
						Content.searchPaths = searchPaths -- 850
					end -- 850
				}) -- 850
				do -- 851
					local projFile = req.params.projFile -- 851
					if projFile then -- 851
						local projDir = getProjectDirFromFile(projFile) -- 852
						if projDir then -- 852
							local scriptDir = Path(projDir, "Script") -- 853
							if Content:exist(scriptDir) then -- 854
								Content:addSearchPath(scriptDir) -- 854
							end -- 854
							if Content:exist(projDir) then -- 855
								Content:addSearchPath(projDir) -- 855
							end -- 855
						else -- 857
							projDir = Path:getPath(projFile) -- 857
							if Content:exist(projDir) then -- 858
								Content:addSearchPath(projDir) -- 858
							end -- 858
						end -- 852
					end -- 851
				end -- 851
				local result = readFile() -- 859
				if result then -- 859
					return result -- 859
				end -- 859
			end -- 837
		end -- 837
	end -- 837
	return { -- 836
		success = false -- 836
	} -- 836
end) -- 836
local compileFileAsync -- 861
compileFileAsync = function(inputFile, sourceCodes) -- 861
	local file = inputFile -- 862
	local searchPath -- 863
	do -- 863
		local dir = getProjectDirFromFile(inputFile) -- 863
		if dir then -- 863
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 864
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 865
		else -- 867
			file = Path:getRelative(inputFile, Content.writablePath) -- 867
			if file:sub(1, 2) == ".." then -- 868
				file = Path:getRelative(inputFile, Content.assetPath) -- 869
			end -- 868
			searchPath = "" -- 870
		end -- 863
	end -- 863
	local outputFile = Path:replaceExt(inputFile, "lua") -- 871
	local yueext = yue.options.extension -- 872
	local resultCodes = nil -- 873
	do -- 874
		local _exp_0 = Path:getExt(inputFile) -- 874
		if yueext == _exp_0 then -- 874
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 875
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 876
				if not codes then -- 877
					return -- 877
				end -- 877
				local extraGlobal -- 878
				if isTIC80 then -- 878
					extraGlobal = tic80APIs -- 878
				else -- 878
					extraGlobal = nil -- 878
				end -- 878
				local success = LintYueGlobals(codes, globals, true, extraGlobal) -- 879
				if not success then -- 880
					return -- 880
				end -- 880
				if codes == "" then -- 881
					resultCodes = "" -- 882
					return nil -- 883
				end -- 881
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 884
				return resultCodes -- 885
			end, function(success) -- 876
				if not success then -- 886
					Content:remove(outputFile) -- 887
					if resultCodes == nil then -- 888
						resultCodes = false -- 889
					end -- 888
				end -- 886
			end) -- 876
		elseif "tl" == _exp_0 then -- 890
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 891
			if isTIC80 then -- 892
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 893
			end -- 892
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 894
			if codes then -- 894
				if isTIC80 then -- 895
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 896
				end -- 895
				resultCodes = codes -- 897
				Content:saveAsync(outputFile, codes) -- 898
			else -- 900
				Content:remove(outputFile) -- 900
				resultCodes = false -- 901
			end -- 894
		elseif "xml" == _exp_0 then -- 902
			local codes = xml.tolua(sourceCodes) -- 903
			if codes then -- 903
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 904
				Content:saveAsync(outputFile, resultCodes) -- 905
			else -- 907
				Content:remove(outputFile) -- 907
				resultCodes = false -- 908
			end -- 903
		end -- 874
	end -- 874
	wait(function() -- 909
		return resultCodes ~= nil -- 909
	end) -- 909
	if resultCodes then -- 910
		return resultCodes -- 910
	end -- 910
	return nil -- 861
end -- 861
HttpServer:postSchedule("/write", function(req) -- 912
	do -- 913
		local _type_0 = type(req) -- 913
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 913
		if _tab_0 then -- 913
			local path -- 913
			do -- 913
				local _obj_0 = req.body -- 913
				local _type_1 = type(_obj_0) -- 913
				if "table" == _type_1 or "userdata" == _type_1 then -- 913
					path = _obj_0.path -- 913
				end -- 913
			end -- 913
			local content -- 913
			do -- 913
				local _obj_0 = req.body -- 913
				local _type_1 = type(_obj_0) -- 913
				if "table" == _type_1 or "userdata" == _type_1 then -- 913
					content = _obj_0.content -- 913
				end -- 913
			end -- 913
			if path ~= nil and content ~= nil then -- 913
				if Content:saveAsync(path, content) then -- 914
					do -- 915
						local _exp_0 = Path:getExt(path) -- 915
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 915
							if '' == Path:getExt(Path:getName(path)) then -- 916
								local resultCodes = compileFileAsync(path, content) -- 917
								return { -- 918
									success = true, -- 918
									resultCodes = resultCodes -- 918
								} -- 918
							end -- 916
						end -- 915
					end -- 915
					return { -- 919
						success = true -- 919
					} -- 919
				end -- 914
			end -- 913
		end -- 913
	end -- 913
	return { -- 912
		success = false -- 912
	} -- 912
end) -- 912
HttpServer:postSchedule("/build", function(req) -- 921
	do -- 922
		local _type_0 = type(req) -- 922
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 922
		if _tab_0 then -- 922
			local path -- 922
			do -- 922
				local _obj_0 = req.body -- 922
				local _type_1 = type(_obj_0) -- 922
				if "table" == _type_1 or "userdata" == _type_1 then -- 922
					path = _obj_0.path -- 922
				end -- 922
			end -- 922
			if path ~= nil then -- 922
				local _exp_0 = Path:getExt(path) -- 923
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 923
					if '' == Path:getExt(Path:getName(path)) then -- 924
						local content = Content:loadAsync(path) -- 925
						if content then -- 925
							local resultCodes = compileFileAsync(path, content) -- 926
							if resultCodes then -- 926
								return { -- 927
									success = true, -- 927
									resultCodes = resultCodes -- 927
								} -- 927
							end -- 926
						end -- 925
					end -- 924
				end -- 923
			end -- 922
		end -- 922
	end -- 922
	return { -- 921
		success = false -- 921
	} -- 921
end) -- 921
local extentionLevels = { -- 930
	vs = 2, -- 930
	bl = 2, -- 931
	ts = 1, -- 932
	tsx = 1, -- 933
	tl = 1, -- 934
	yue = 1, -- 935
	xml = 1, -- 936
	lua = 0 -- 937
} -- 929
HttpServer:post("/assets", function() -- 939
	local Entry = require("Script.Dev.Entry") -- 942
	local engineDev = Entry.getEngineDev() -- 943
	local visitAssets -- 944
	visitAssets = function(path, tag) -- 944
		local isWorkspace = tag == "Workspace" -- 945
		local builtin -- 946
		if tag == "Builtin" then -- 946
			builtin = true -- 946
		else -- 946
			builtin = nil -- 946
		end -- 946
		local children = nil -- 947
		local dirs = Content:getDirs(path) -- 948
		for _index_0 = 1, #dirs do -- 949
			local dir = dirs[_index_0] -- 949
			if isWorkspace then -- 950
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 951
					goto _continue_0 -- 952
				end -- 951
			elseif dir == ".git" then -- 953
				goto _continue_0 -- 954
			end -- 950
			if not children then -- 955
				children = { } -- 955
			end -- 955
			children[#children + 1] = visitAssets(Path(path, dir)) -- 956
			::_continue_0:: -- 950
		end -- 949
		local files = Content:getFiles(path) -- 957
		local names = { } -- 958
		for _index_0 = 1, #files do -- 959
			local file = files[_index_0] -- 959
			if file:match("^%.") then -- 960
				goto _continue_1 -- 960
			end -- 960
			local name = Path:getName(file) -- 961
			local ext = names[name] -- 962
			if ext then -- 962
				local lv1 -- 963
				do -- 963
					local _exp_0 = extentionLevels[ext] -- 963
					if _exp_0 ~= nil then -- 963
						lv1 = _exp_0 -- 963
					else -- 963
						lv1 = -1 -- 963
					end -- 963
				end -- 963
				ext = Path:getExt(file) -- 964
				local lv2 -- 965
				do -- 965
					local _exp_0 = extentionLevels[ext] -- 965
					if _exp_0 ~= nil then -- 965
						lv2 = _exp_0 -- 965
					else -- 965
						lv2 = -1 -- 965
					end -- 965
				end -- 965
				if lv2 > lv1 then -- 966
					names[name] = ext -- 967
				elseif lv2 == lv1 then -- 968
					names[name .. '.' .. ext] = "" -- 969
				end -- 966
			else -- 971
				ext = Path:getExt(file) -- 971
				if not extentionLevels[ext] then -- 972
					names[file] = "" -- 973
				else -- 975
					names[name] = ext -- 975
				end -- 972
			end -- 962
			::_continue_1:: -- 960
		end -- 959
		do -- 976
			local _accum_0 = { } -- 976
			local _len_0 = 1 -- 976
			for name, ext in pairs(names) do -- 976
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 976
				_len_0 = _len_0 + 1 -- 976
			end -- 976
			files = _accum_0 -- 976
		end -- 976
		for _index_0 = 1, #files do -- 977
			local file = files[_index_0] -- 977
			if not children then -- 978
				children = { } -- 978
			end -- 978
			children[#children + 1] = { -- 980
				key = Path(path, file), -- 980
				dir = false, -- 981
				title = file, -- 982
				builtin = builtin -- 983
			} -- 979
		end -- 977
		if children then -- 985
			table.sort(children, function(a, b) -- 986
				if a.dir == b.dir then -- 987
					return a.title < b.title -- 988
				else -- 990
					return a.dir -- 990
				end -- 987
			end) -- 986
		end -- 985
		if isWorkspace and children then -- 991
			return children -- 992
		else -- 994
			return { -- 995
				key = path, -- 995
				dir = true, -- 996
				title = Path:getFilename(path), -- 997
				builtin = builtin, -- 998
				children = children -- 999
			} -- 994
		end -- 991
	end -- 944
	local zh = (App.locale:match("^zh") ~= nil) -- 1001
	return { -- 1003
		key = Content.writablePath, -- 1003
		dir = true, -- 1004
		root = true, -- 1005
		title = "Assets", -- 1006
		children = (function() -- 1008
			local _tab_0 = { -- 1008
				{ -- 1009
					key = Path(Content.assetPath), -- 1009
					dir = true, -- 1010
					builtin = true, -- 1011
					title = zh and "内置资源" or "Built-in", -- 1012
					children = { -- 1014
						(function() -- 1014
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1014
							_with_0.title = zh and "说明文档" or "Readme" -- 1015
							return _with_0 -- 1014
						end)(), -- 1014
						(function() -- 1016
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1016
							_with_0.title = zh and "接口文档" or "API Doc" -- 1017
							return _with_0 -- 1016
						end)(), -- 1016
						(function() -- 1018
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1018
							_with_0.title = zh and "开发工具" or "Tools" -- 1019
							return _with_0 -- 1018
						end)(), -- 1018
						(function() -- 1020
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1020
							_with_0.title = zh and "字体" or "Font" -- 1021
							return _with_0 -- 1020
						end)(), -- 1020
						(function() -- 1022
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1022
							_with_0.title = zh and "程序库" or "Lib" -- 1023
							if engineDev then -- 1024
								local _list_0 = _with_0.children -- 1025
								for _index_0 = 1, #_list_0 do -- 1025
									local child = _list_0[_index_0] -- 1025
									if not (child.title == "Dora") then -- 1026
										goto _continue_0 -- 1026
									end -- 1026
									local title = zh and "zh-Hans" or "en" -- 1027
									do -- 1028
										local _accum_0 = { } -- 1028
										local _len_0 = 1 -- 1028
										local _list_1 = child.children -- 1028
										for _index_1 = 1, #_list_1 do -- 1028
											local c = _list_1[_index_1] -- 1028
											if c.title ~= title then -- 1028
												_accum_0[_len_0] = c -- 1028
												_len_0 = _len_0 + 1 -- 1028
											end -- 1028
										end -- 1028
										child.children = _accum_0 -- 1028
									end -- 1028
									break -- 1029
									::_continue_0:: -- 1026
								end -- 1025
							else -- 1031
								local _accum_0 = { } -- 1031
								local _len_0 = 1 -- 1031
								local _list_0 = _with_0.children -- 1031
								for _index_0 = 1, #_list_0 do -- 1031
									local child = _list_0[_index_0] -- 1031
									if child.title ~= "Dora" then -- 1031
										_accum_0[_len_0] = child -- 1031
										_len_0 = _len_0 + 1 -- 1031
									end -- 1031
								end -- 1031
								_with_0.children = _accum_0 -- 1031
							end -- 1024
							return _with_0 -- 1022
						end)(), -- 1022
						(function() -- 1032
							if engineDev then -- 1032
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1033
								local _obj_0 = _with_0.children -- 1034
								_obj_0[#_obj_0 + 1] = { -- 1035
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1035
									dir = false, -- 1036
									builtin = true, -- 1037
									title = "init.yue" -- 1038
								} -- 1034
								return _with_0 -- 1033
							end -- 1032
						end)() -- 1032
					} -- 1013
				} -- 1008
			} -- 1042
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1042
			local _idx_0 = #_tab_0 + 1 -- 1042
			for _index_0 = 1, #_obj_0 do -- 1042
				local _value_0 = _obj_0[_index_0] -- 1042
				_tab_0[_idx_0] = _value_0 -- 1042
				_idx_0 = _idx_0 + 1 -- 1042
			end -- 1042
			return _tab_0 -- 1008
		end)() -- 1007
	} -- 1002
end) -- 939
HttpServer:postSchedule("/run", function(req) -- 1046
	do -- 1047
		local _type_0 = type(req) -- 1047
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1047
		if _tab_0 then -- 1047
			local file -- 1047
			do -- 1047
				local _obj_0 = req.body -- 1047
				local _type_1 = type(_obj_0) -- 1047
				if "table" == _type_1 or "userdata" == _type_1 then -- 1047
					file = _obj_0.file -- 1047
				end -- 1047
			end -- 1047
			local asProj -- 1047
			do -- 1047
				local _obj_0 = req.body -- 1047
				local _type_1 = type(_obj_0) -- 1047
				if "table" == _type_1 or "userdata" == _type_1 then -- 1047
					asProj = _obj_0.asProj -- 1047
				end -- 1047
			end -- 1047
			if file ~= nil and asProj ~= nil then -- 1047
				if not Content:isAbsolutePath(file) then -- 1048
					local devFile = Path(Content.writablePath, file) -- 1049
					if Content:exist(devFile) then -- 1050
						file = devFile -- 1050
					end -- 1050
				end -- 1048
				local Entry = require("Script.Dev.Entry") -- 1051
				local workDir -- 1052
				if asProj then -- 1053
					workDir = getProjectDirFromFile(file) -- 1054
					if workDir then -- 1054
						Entry.allClear() -- 1055
						local target = Path(workDir, "init") -- 1056
						local success, err = Entry.enterEntryAsync({ -- 1057
							entryName = "Project", -- 1057
							fileName = target -- 1057
						}) -- 1057
						target = Path:getName(Path:getPath(target)) -- 1058
						return { -- 1059
							success = success, -- 1059
							target = target, -- 1059
							err = err -- 1059
						} -- 1059
					end -- 1054
				else -- 1061
					workDir = getProjectDirFromFile(file) -- 1061
				end -- 1053
				Entry.allClear() -- 1062
				file = Path:replaceExt(file, "") -- 1063
				local success, err = Entry.enterEntryAsync({ -- 1065
					entryName = Path:getName(file), -- 1065
					fileName = file, -- 1066
					workDir = workDir -- 1067
				}) -- 1064
				return { -- 1068
					success = success, -- 1068
					err = err -- 1068
				} -- 1068
			end -- 1047
		end -- 1047
	end -- 1047
	return { -- 1046
		success = false -- 1046
	} -- 1046
end) -- 1046
HttpServer:postSchedule("/stop", function() -- 1070
	local Entry = require("Script.Dev.Entry") -- 1071
	return { -- 1072
		success = Entry.stop() -- 1072
	} -- 1072
end) -- 1070
local minifyAsync -- 1074
minifyAsync = function(sourcePath, minifyPath) -- 1074
	if not Content:exist(sourcePath) then -- 1075
		return -- 1075
	end -- 1075
	local Entry = require("Script.Dev.Entry") -- 1076
	local errors = { } -- 1077
	local files = Entry.getAllFiles(sourcePath, { -- 1078
		"lua" -- 1078
	}, true) -- 1078
	do -- 1079
		local _accum_0 = { } -- 1079
		local _len_0 = 1 -- 1079
		for _index_0 = 1, #files do -- 1079
			local file = files[_index_0] -- 1079
			if file:sub(1, 1) ~= '.' then -- 1079
				_accum_0[_len_0] = file -- 1079
				_len_0 = _len_0 + 1 -- 1079
			end -- 1079
		end -- 1079
		files = _accum_0 -- 1079
	end -- 1079
	local paths -- 1080
	do -- 1080
		local _tbl_0 = { } -- 1080
		for _index_0 = 1, #files do -- 1080
			local file = files[_index_0] -- 1080
			_tbl_0[Path:getPath(file)] = true -- 1080
		end -- 1080
		paths = _tbl_0 -- 1080
	end -- 1080
	for path in pairs(paths) do -- 1081
		Content:mkdir(Path(minifyPath, path)) -- 1081
	end -- 1081
	local _ <close> = setmetatable({ }, { -- 1082
		__close = function() -- 1082
			package.loaded["luaminify.FormatMini"] = nil -- 1083
			package.loaded["luaminify.ParseLua"] = nil -- 1084
			package.loaded["luaminify.Scope"] = nil -- 1085
			package.loaded["luaminify.Util"] = nil -- 1086
		end -- 1082
	}) -- 1082
	local FormatMini -- 1087
	do -- 1087
		local _obj_0 = require("luaminify") -- 1087
		FormatMini = _obj_0.FormatMini -- 1087
	end -- 1087
	local fileCount = #files -- 1088
	local count = 0 -- 1089
	for _index_0 = 1, #files do -- 1090
		local file = files[_index_0] -- 1090
		thread(function() -- 1091
			local _ <close> = setmetatable({ }, { -- 1092
				__close = function() -- 1092
					count = count + 1 -- 1092
				end -- 1092
			}) -- 1092
			local input = Path(sourcePath, file) -- 1093
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1094
			if Content:exist(input) then -- 1095
				local sourceCodes = Content:loadAsync(input) -- 1096
				local res, err = FormatMini(sourceCodes) -- 1097
				if res then -- 1098
					Content:saveAsync(output, res) -- 1099
					return print("Minify " .. tostring(file)) -- 1100
				else -- 1102
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1102
				end -- 1098
			else -- 1104
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1104
			end -- 1095
		end) -- 1091
		sleep() -- 1105
	end -- 1090
	wait(function() -- 1106
		return count == fileCount -- 1106
	end) -- 1106
	if #errors > 0 then -- 1107
		print(table.concat(errors, '\n')) -- 1108
	end -- 1107
	print("Obfuscation done.") -- 1109
	return files -- 1110
end -- 1074
local zipping = false -- 1112
HttpServer:postSchedule("/zip", function(req) -- 1114
	do -- 1115
		local _type_0 = type(req) -- 1115
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1115
		if _tab_0 then -- 1115
			local path -- 1115
			do -- 1115
				local _obj_0 = req.body -- 1115
				local _type_1 = type(_obj_0) -- 1115
				if "table" == _type_1 or "userdata" == _type_1 then -- 1115
					path = _obj_0.path -- 1115
				end -- 1115
			end -- 1115
			local zipFile -- 1115
			do -- 1115
				local _obj_0 = req.body -- 1115
				local _type_1 = type(_obj_0) -- 1115
				if "table" == _type_1 or "userdata" == _type_1 then -- 1115
					zipFile = _obj_0.zipFile -- 1115
				end -- 1115
			end -- 1115
			local obfuscated -- 1115
			do -- 1115
				local _obj_0 = req.body -- 1115
				local _type_1 = type(_obj_0) -- 1115
				if "table" == _type_1 or "userdata" == _type_1 then -- 1115
					obfuscated = _obj_0.obfuscated -- 1115
				end -- 1115
			end -- 1115
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1115
				if zipping then -- 1116
					goto failed -- 1116
				end -- 1116
				zipping = true -- 1117
				local _ <close> = setmetatable({ }, { -- 1118
					__close = function() -- 1118
						zipping = false -- 1118
					end -- 1118
				}) -- 1118
				if not Content:exist(path) then -- 1119
					goto failed -- 1119
				end -- 1119
				Content:mkdir(Path:getPath(zipFile)) -- 1120
				if obfuscated then -- 1121
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1122
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1123
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1124
					Content:remove(scriptPath) -- 1125
					Content:remove(obfuscatedPath) -- 1126
					Content:remove(tempPath) -- 1127
					Content:mkdir(scriptPath) -- 1128
					Content:mkdir(obfuscatedPath) -- 1129
					Content:mkdir(tempPath) -- 1130
					if not Content:copyAsync(path, tempPath) then -- 1131
						goto failed -- 1131
					end -- 1131
					local Entry = require("Script.Dev.Entry") -- 1132
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1133
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1134
						"tl", -- 1134
						"yue", -- 1134
						"lua", -- 1134
						"ts", -- 1134
						"tsx", -- 1134
						"vs", -- 1134
						"bl", -- 1134
						"xml", -- 1134
						"wa", -- 1134
						"mod" -- 1134
					}, true) -- 1134
					for _index_0 = 1, #scriptFiles do -- 1135
						local file = scriptFiles[_index_0] -- 1135
						Content:remove(Path(tempPath, file)) -- 1136
					end -- 1135
					for _index_0 = 1, #luaFiles do -- 1137
						local file = luaFiles[_index_0] -- 1137
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1138
					end -- 1137
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1139
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1140
					end) then -- 1139
						goto failed -- 1139
					end -- 1139
					return { -- 1141
						success = true -- 1141
					} -- 1141
				else -- 1143
					return { -- 1143
						success = Content:zipAsync(path, zipFile, function(file) -- 1143
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1144
						end) -- 1143
					} -- 1143
				end -- 1121
			end -- 1115
		end -- 1115
	end -- 1115
	::failed:: -- 1145
	return { -- 1114
		success = false -- 1114
	} -- 1114
end) -- 1114
HttpServer:postSchedule("/unzip", function(req) -- 1147
	do -- 1148
		local _type_0 = type(req) -- 1148
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1148
		if _tab_0 then -- 1148
			local zipFile -- 1148
			do -- 1148
				local _obj_0 = req.body -- 1148
				local _type_1 = type(_obj_0) -- 1148
				if "table" == _type_1 or "userdata" == _type_1 then -- 1148
					zipFile = _obj_0.zipFile -- 1148
				end -- 1148
			end -- 1148
			local path -- 1148
			do -- 1148
				local _obj_0 = req.body -- 1148
				local _type_1 = type(_obj_0) -- 1148
				if "table" == _type_1 or "userdata" == _type_1 then -- 1148
					path = _obj_0.path -- 1148
				end -- 1148
			end -- 1148
			if zipFile ~= nil and path ~= nil then -- 1148
				return { -- 1149
					success = Content:unzipAsync(zipFile, path, function(file) -- 1149
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1150
					end) -- 1149
				} -- 1149
			end -- 1148
		end -- 1148
	end -- 1148
	return { -- 1147
		success = false -- 1147
	} -- 1147
end) -- 1147
HttpServer:post("/editing-info", function(req) -- 1152
	local Entry = require("Script.Dev.Entry") -- 1153
	local config = Entry.getConfig() -- 1154
	local _type_0 = type(req) -- 1155
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1155
	local _match_0 = false -- 1155
	if _tab_0 then -- 1155
		local editingInfo -- 1155
		do -- 1155
			local _obj_0 = req.body -- 1155
			local _type_1 = type(_obj_0) -- 1155
			if "table" == _type_1 or "userdata" == _type_1 then -- 1155
				editingInfo = _obj_0.editingInfo -- 1155
			end -- 1155
		end -- 1155
		if editingInfo ~= nil then -- 1155
			_match_0 = true -- 1155
			config.editingInfo = editingInfo -- 1156
			return { -- 1157
				success = true -- 1157
			} -- 1157
		end -- 1155
	end -- 1155
	if not _match_0 then -- 1155
		if not (config.editingInfo ~= nil) then -- 1159
			local folder -- 1160
			if App.locale:match('^zh') then -- 1160
				folder = 'zh-Hans' -- 1160
			else -- 1160
				folder = 'en' -- 1160
			end -- 1160
			config.editingInfo = json.encode({ -- 1162
				index = 0, -- 1162
				files = { -- 1164
					{ -- 1165
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1165
						title = "welcome.md" -- 1166
					} -- 1164
				} -- 1163
			}) -- 1161
		end -- 1159
		return { -- 1170
			success = true, -- 1170
			editingInfo = config.editingInfo -- 1170
		} -- 1170
	end -- 1155
end) -- 1152
HttpServer:post("/command", function(req) -- 1172
	do -- 1173
		local _type_0 = type(req) -- 1173
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1173
		if _tab_0 then -- 1173
			local code -- 1173
			do -- 1173
				local _obj_0 = req.body -- 1173
				local _type_1 = type(_obj_0) -- 1173
				if "table" == _type_1 or "userdata" == _type_1 then -- 1173
					code = _obj_0.code -- 1173
				end -- 1173
			end -- 1173
			local log -- 1173
			do -- 1173
				local _obj_0 = req.body -- 1173
				local _type_1 = type(_obj_0) -- 1173
				if "table" == _type_1 or "userdata" == _type_1 then -- 1173
					log = _obj_0.log -- 1173
				end -- 1173
			end -- 1173
			if code ~= nil and log ~= nil then -- 1173
				emit("AppCommand", code, log) -- 1174
				return { -- 1175
					success = true -- 1175
				} -- 1175
			end -- 1173
		end -- 1173
	end -- 1173
	return { -- 1172
		success = false -- 1172
	} -- 1172
end) -- 1172
HttpServer:post("/log/save", function() -- 1177
	local folder = ".download" -- 1178
	local fullLogFile = "dora_full_logs.txt" -- 1179
	local fullFolder = Path(Content.writablePath, folder) -- 1180
	Content:mkdir(fullFolder) -- 1181
	local logPath = Path(fullFolder, fullLogFile) -- 1182
	if App:saveLog(logPath) then -- 1183
		return { -- 1184
			success = true, -- 1184
			path = Path(folder, fullLogFile) -- 1184
		} -- 1184
	end -- 1183
	return { -- 1177
		success = false -- 1177
	} -- 1177
end) -- 1177
HttpServer:post("/yarn/check", function(req) -- 1186
	local yarncompile = require("yarncompile") -- 1187
	do -- 1188
		local _type_0 = type(req) -- 1188
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1188
		if _tab_0 then -- 1188
			local code -- 1188
			do -- 1188
				local _obj_0 = req.body -- 1188
				local _type_1 = type(_obj_0) -- 1188
				if "table" == _type_1 or "userdata" == _type_1 then -- 1188
					code = _obj_0.code -- 1188
				end -- 1188
			end -- 1188
			if code ~= nil then -- 1188
				local jsonObject = json.decode(code) -- 1189
				if jsonObject then -- 1189
					local errors = { } -- 1190
					local _list_0 = jsonObject.nodes -- 1191
					for _index_0 = 1, #_list_0 do -- 1191
						local node = _list_0[_index_0] -- 1191
						local title, body = node.title, node.body -- 1192
						local luaCode, err = yarncompile(body) -- 1193
						if not luaCode then -- 1193
							errors[#errors + 1] = title .. ":" .. err -- 1194
						end -- 1193
					end -- 1191
					return { -- 1195
						success = true, -- 1195
						syntaxError = table.concat(errors, "\n\n") -- 1195
					} -- 1195
				end -- 1189
			end -- 1188
		end -- 1188
	end -- 1188
	return { -- 1186
		success = false -- 1186
	} -- 1186
end) -- 1186
HttpServer:post("/yarn/check-file", function(req) -- 1197
	local yarncompile = require("yarncompile") -- 1198
	do -- 1199
		local _type_0 = type(req) -- 1199
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1199
		if _tab_0 then -- 1199
			local code -- 1199
			do -- 1199
				local _obj_0 = req.body -- 1199
				local _type_1 = type(_obj_0) -- 1199
				if "table" == _type_1 or "userdata" == _type_1 then -- 1199
					code = _obj_0.code -- 1199
				end -- 1199
			end -- 1199
			if code ~= nil then -- 1199
				local res, _, err = yarncompile(code, true) -- 1200
				if not res then -- 1200
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1201
					return { -- 1202
						success = false, -- 1202
						message = message, -- 1202
						line = line, -- 1202
						column = column, -- 1202
						node = node -- 1202
					} -- 1202
				end -- 1200
			end -- 1199
		end -- 1199
	end -- 1199
	return { -- 1197
		success = true -- 1197
	} -- 1197
end) -- 1197
local getWaProjectDirFromFile -- 1204
getWaProjectDirFromFile = function(file) -- 1204
	local writablePath = Content.writablePath -- 1205
	local parent, current -- 1206
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1206
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1207
	else -- 1209
		parent, current = nil, nil -- 1209
	end -- 1206
	if not current then -- 1210
		return nil -- 1210
	end -- 1210
	repeat -- 1211
		current = Path:getPath(current) -- 1212
		if current == "" then -- 1213
			break -- 1213
		end -- 1213
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1214
		for _index_0 = 1, #_list_0 do -- 1214
			local f = _list_0[_index_0] -- 1214
			if Path:getFilename(f):lower() == "wa.mod" then -- 1215
				return Path(parent, current, Path:getPath(f)) -- 1216
			end -- 1215
		end -- 1214
	until false -- 1211
	return nil -- 1218
end -- 1204
HttpServer:postSchedule("/wa/build", function(req) -- 1220
	do -- 1221
		local _type_0 = type(req) -- 1221
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1221
		if _tab_0 then -- 1221
			local path -- 1221
			do -- 1221
				local _obj_0 = req.body -- 1221
				local _type_1 = type(_obj_0) -- 1221
				if "table" == _type_1 or "userdata" == _type_1 then -- 1221
					path = _obj_0.path -- 1221
				end -- 1221
			end -- 1221
			if path ~= nil then -- 1221
				local projDir = getWaProjectDirFromFile(path) -- 1222
				if projDir then -- 1222
					local message = Wasm:buildWaAsync(projDir) -- 1223
					if message == "" then -- 1224
						return { -- 1225
							success = true -- 1225
						} -- 1225
					else -- 1227
						return { -- 1227
							success = false, -- 1227
							message = message -- 1227
						} -- 1227
					end -- 1224
				else -- 1229
					return { -- 1229
						success = false, -- 1229
						message = 'Wa file needs a project' -- 1229
					} -- 1229
				end -- 1222
			end -- 1221
		end -- 1221
	end -- 1221
	return { -- 1230
		success = false, -- 1230
		message = 'failed to build' -- 1230
	} -- 1230
end) -- 1220
HttpServer:postSchedule("/wa/format", function(req) -- 1232
	do -- 1233
		local _type_0 = type(req) -- 1233
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1233
		if _tab_0 then -- 1233
			local file -- 1233
			do -- 1233
				local _obj_0 = req.body -- 1233
				local _type_1 = type(_obj_0) -- 1233
				if "table" == _type_1 or "userdata" == _type_1 then -- 1233
					file = _obj_0.file -- 1233
				end -- 1233
			end -- 1233
			if file ~= nil then -- 1233
				local code = Wasm:formatWaAsync(file) -- 1234
				if code == "" then -- 1235
					return { -- 1236
						success = false -- 1236
					} -- 1236
				else -- 1238
					return { -- 1238
						success = true, -- 1238
						code = code -- 1238
					} -- 1238
				end -- 1235
			end -- 1233
		end -- 1233
	end -- 1233
	return { -- 1239
		success = false -- 1239
	} -- 1239
end) -- 1232
HttpServer:postSchedule("/wa/create", function(req) -- 1241
	do -- 1242
		local _type_0 = type(req) -- 1242
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1242
		if _tab_0 then -- 1242
			local path -- 1242
			do -- 1242
				local _obj_0 = req.body -- 1242
				local _type_1 = type(_obj_0) -- 1242
				if "table" == _type_1 or "userdata" == _type_1 then -- 1242
					path = _obj_0.path -- 1242
				end -- 1242
			end -- 1242
			if path ~= nil then -- 1242
				if not Content:exist(Path:getPath(path)) then -- 1243
					return { -- 1244
						success = false, -- 1244
						message = "target path not existed" -- 1244
					} -- 1244
				end -- 1243
				if Content:exist(path) then -- 1245
					return { -- 1246
						success = false, -- 1246
						message = "target project folder existed" -- 1246
					} -- 1246
				end -- 1245
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1247
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1248
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1249
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1250
					return { -- 1253
						success = false, -- 1253
						message = "missing template project" -- 1253
					} -- 1253
				end -- 1250
				if not Content:mkdir(path) then -- 1254
					return { -- 1255
						success = false, -- 1255
						message = "failed to create project folder" -- 1255
					} -- 1255
				end -- 1254
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1256
					Content:remove(path) -- 1257
					return { -- 1258
						success = false, -- 1258
						message = "failed to copy template" -- 1258
					} -- 1258
				end -- 1256
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1259
					Content:remove(path) -- 1260
					return { -- 1261
						success = false, -- 1261
						message = "failed to copy template" -- 1261
					} -- 1261
				end -- 1259
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1262
					Content:remove(path) -- 1263
					return { -- 1264
						success = false, -- 1264
						message = "failed to copy template" -- 1264
					} -- 1264
				end -- 1262
				return { -- 1265
					success = true -- 1265
				} -- 1265
			end -- 1242
		end -- 1242
	end -- 1242
	return { -- 1241
		success = false, -- 1241
		message = "invalid call" -- 1241
	} -- 1241
end) -- 1241
local _anon_func_3 = function(path) -- 1274
	local _val_0 = Path:getExt(path) -- 1274
	return "ts" == _val_0 or "tsx" == _val_0 -- 1274
end -- 1274
local _anon_func_4 = function(f) -- 1304
	local _val_0 = Path:getExt(f) -- 1304
	return "ts" == _val_0 or "tsx" == _val_0 -- 1304
end -- 1304
HttpServer:postSchedule("/ts/build", function(req) -- 1267
	do -- 1268
		local _type_0 = type(req) -- 1268
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1268
		if _tab_0 then -- 1268
			local path -- 1268
			do -- 1268
				local _obj_0 = req.body -- 1268
				local _type_1 = type(_obj_0) -- 1268
				if "table" == _type_1 or "userdata" == _type_1 then -- 1268
					path = _obj_0.path -- 1268
				end -- 1268
			end -- 1268
			if path ~= nil then -- 1268
				if HttpServer.wsConnectionCount == 0 then -- 1269
					return { -- 1270
						success = false, -- 1270
						message = "Web IDE not connected" -- 1270
					} -- 1270
				end -- 1269
				if not Content:exist(path) then -- 1271
					return { -- 1272
						success = false, -- 1272
						message = "path not existed" -- 1272
					} -- 1272
				end -- 1271
				if not Content:isdir(path) then -- 1273
					if not (_anon_func_3(path)) then -- 1274
						return { -- 1275
							success = false, -- 1275
							message = "expecting a TypeScript file" -- 1275
						} -- 1275
					end -- 1274
					local messages = { } -- 1276
					local content = Content:load(path) -- 1277
					if not content then -- 1278
						return { -- 1279
							success = false, -- 1279
							message = "failed to read file" -- 1279
						} -- 1279
					end -- 1278
					emit("AppWS", "Send", json.encode({ -- 1280
						name = "UpdateTSCode", -- 1280
						file = path, -- 1280
						content = content -- 1280
					})) -- 1280
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1281
						local done = false -- 1282
						do -- 1283
							local _with_0 = Node() -- 1283
							_with_0:gslot("AppWS", function(eventType, msg) -- 1284
								if eventType == "Receive" then -- 1285
									_with_0:removeFromParent() -- 1286
									local res = json.decode(msg) -- 1287
									if res then -- 1287
										if res.name == "TranspileTS" then -- 1288
											if res.success then -- 1289
												local luaFile = Path:replaceExt(path, "lua") -- 1290
												Content:save(luaFile, res.luaCode) -- 1291
												messages[#messages + 1] = { -- 1292
													success = true, -- 1292
													file = path -- 1292
												} -- 1292
											else -- 1294
												messages[#messages + 1] = { -- 1294
													success = false, -- 1294
													file = path, -- 1294
													message = res.message -- 1294
												} -- 1294
											end -- 1289
											done = true -- 1295
										end -- 1288
									end -- 1287
								end -- 1285
							end) -- 1284
						end -- 1283
						emit("AppWS", "Send", json.encode({ -- 1296
							name = "TranspileTS", -- 1296
							file = path, -- 1296
							content = content -- 1296
						})) -- 1296
						wait(function() -- 1297
							return done -- 1297
						end) -- 1297
					end -- 1281
					return { -- 1298
						success = true, -- 1298
						messages = messages -- 1298
					} -- 1298
				else -- 1300
					local files = Content:getAllFiles(path) -- 1300
					local fileData = { } -- 1301
					local messages = { } -- 1302
					for _index_0 = 1, #files do -- 1303
						local f = files[_index_0] -- 1303
						if not (_anon_func_4(f)) then -- 1304
							goto _continue_0 -- 1304
						end -- 1304
						local file = Path(path, f) -- 1305
						local content = Content:load(file) -- 1306
						if content then -- 1306
							fileData[file] = content -- 1307
							emit("AppWS", "Send", json.encode({ -- 1308
								name = "UpdateTSCode", -- 1308
								file = file, -- 1308
								content = content -- 1308
							})) -- 1308
						else -- 1310
							messages[#messages + 1] = { -- 1310
								success = false, -- 1310
								file = file, -- 1310
								message = "failed to read file" -- 1310
							} -- 1310
						end -- 1306
						::_continue_0:: -- 1304
					end -- 1303
					for file, content in pairs(fileData) do -- 1311
						if "d" == Path:getExt(Path:getName(file)) then -- 1312
							goto _continue_1 -- 1312
						end -- 1312
						local done = false -- 1313
						do -- 1314
							local _with_0 = Node() -- 1314
							_with_0:gslot("AppWS", function(eventType, msg) -- 1315
								if eventType == "Receive" then -- 1316
									_with_0:removeFromParent() -- 1317
									local res = json.decode(msg) -- 1318
									if res then -- 1318
										if res.name == "TranspileTS" then -- 1319
											if res.success then -- 1320
												local luaFile = Path:replaceExt(file, "lua") -- 1321
												Content:save(luaFile, res.luaCode) -- 1322
												messages[#messages + 1] = { -- 1323
													success = true, -- 1323
													file = file -- 1323
												} -- 1323
											else -- 1325
												messages[#messages + 1] = { -- 1325
													success = false, -- 1325
													file = file, -- 1325
													message = res.message -- 1325
												} -- 1325
											end -- 1320
											done = true -- 1326
										end -- 1319
									end -- 1318
								end -- 1316
							end) -- 1315
						end -- 1314
						emit("AppWS", "Send", json.encode({ -- 1327
							name = "TranspileTS", -- 1327
							file = file, -- 1327
							content = content -- 1327
						})) -- 1327
						wait(function() -- 1328
							return done -- 1328
						end) -- 1328
						::_continue_1:: -- 1312
					end -- 1311
					return { -- 1329
						success = true, -- 1329
						messages = messages -- 1329
					} -- 1329
				end -- 1273
			end -- 1268
		end -- 1268
	end -- 1268
	return { -- 1267
		success = false -- 1267
	} -- 1267
end) -- 1267
HttpServer:post("/download", function(req) -- 1331
	do -- 1332
		local _type_0 = type(req) -- 1332
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1332
		if _tab_0 then -- 1332
			local url -- 1332
			do -- 1332
				local _obj_0 = req.body -- 1332
				local _type_1 = type(_obj_0) -- 1332
				if "table" == _type_1 or "userdata" == _type_1 then -- 1332
					url = _obj_0.url -- 1332
				end -- 1332
			end -- 1332
			local target -- 1332
			do -- 1332
				local _obj_0 = req.body -- 1332
				local _type_1 = type(_obj_0) -- 1332
				if "table" == _type_1 or "userdata" == _type_1 then -- 1332
					target = _obj_0.target -- 1332
				end -- 1332
			end -- 1332
			if url ~= nil and target ~= nil then -- 1332
				local Entry = require("Script.Dev.Entry") -- 1333
				Entry.downloadFile(url, target) -- 1334
				return { -- 1335
					success = true -- 1335
				} -- 1335
			end -- 1332
		end -- 1332
	end -- 1332
	return { -- 1331
		success = false -- 1331
	} -- 1331
end) -- 1331
local status = { } -- 1337
_module_0 = status -- 1338
thread(function() -- 1340
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1341
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1342
	if Content:exist(doraWeb) then -- 1343
		local needReload -- 1344
		if Content:exist(doraReady) then -- 1344
			needReload = App.version ~= Content:load(doraReady) -- 1345
		else -- 1346
			needReload = true -- 1346
		end -- 1344
		if needReload then -- 1347
			Content:remove(Path(Content.appPath, ".www")) -- 1348
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1349
			Content:save(doraReady, App.version) -- 1353
			print("Dora Dora is ready!") -- 1354
		end -- 1347
	end -- 1343
	if HttpServer:start(8866) then -- 1355
		local localIP = HttpServer.localIP -- 1356
		if localIP == "" then -- 1357
			localIP = "localhost" -- 1357
		end -- 1357
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1358
		return HttpServer:startWS(8868) -- 1359
	else -- 1361
		status.url = nil -- 1361
		return print("8866 Port not available!") -- 1362
	end -- 1355
end) -- 1340
return _module_0 -- 1
