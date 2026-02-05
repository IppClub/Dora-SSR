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
			created_at INTEGER,
			updated_at INTEGER
		);
	]]) -- 650
end -- 649
HttpServer:post("/llm/list", function() -- 662
	ensureLLMConfigTable() -- 663
	local rows = DB:query("\n		select id, name, url, model, api_key\n		from LLMConfig\n		order by id asc") -- 664
	local items -- 668
	if rows and #rows > 0 then -- 668
		local _accum_0 = { } -- 669
		local _len_0 = 1 -- 669
		for _index_0 = 1, #rows do -- 669
			local _des_0 = rows[_index_0] -- 669
			local id, name, url, model, key = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 669
			_accum_0[_len_0] = { -- 670
				id = id, -- 670
				name = name, -- 670
				url = url, -- 670
				model = model, -- 670
				key = key -- 670
			} -- 670
			_len_0 = _len_0 + 1 -- 670
		end -- 669
		items = _accum_0 -- 669
	end -- 668
	return { -- 671
		success = true, -- 671
		items = items -- 671
	} -- 671
end) -- 662
HttpServer:post("/llm/create", function(req) -- 673
	ensureLLMConfigTable() -- 674
	do -- 675
		local _type_0 = type(req) -- 675
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 675
		if _tab_0 then -- 675
			local name -- 675
			do -- 675
				local _obj_0 = req.body -- 675
				local _type_1 = type(_obj_0) -- 675
				if "table" == _type_1 or "userdata" == _type_1 then -- 675
					name = _obj_0.name -- 675
				end -- 675
			end -- 675
			local url -- 675
			do -- 675
				local _obj_0 = req.body -- 675
				local _type_1 = type(_obj_0) -- 675
				if "table" == _type_1 or "userdata" == _type_1 then -- 675
					url = _obj_0.url -- 675
				end -- 675
			end -- 675
			local model -- 675
			do -- 675
				local _obj_0 = req.body -- 675
				local _type_1 = type(_obj_0) -- 675
				if "table" == _type_1 or "userdata" == _type_1 then -- 675
					model = _obj_0.model -- 675
				end -- 675
			end -- 675
			local key -- 675
			do -- 675
				local _obj_0 = req.body -- 675
				local _type_1 = type(_obj_0) -- 675
				if "table" == _type_1 or "userdata" == _type_1 then -- 675
					key = _obj_0.key -- 675
				end -- 675
			end -- 675
			if name ~= nil and url ~= nil and model ~= nil and key ~= nil then -- 675
				local now = os.time() -- 676
				if name == nil or url == nil or model == nil or key == nil then -- 677
					return { -- 678
						success = false, -- 678
						message = "invalid" -- 678
					} -- 678
				end -- 677
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?\n			)", { -- 685
					tostring(name), -- 685
					tostring(url), -- 686
					tostring(model), -- 687
					tostring(key), -- 688
					now, -- 689
					now -- 690
				}) -- 679
				return { -- 692
					success = affected >= 0 -- 692
				} -- 692
			end -- 675
		end -- 675
	end -- 675
	return { -- 673
		success = false, -- 673
		message = "invalid" -- 673
	} -- 673
end) -- 673
HttpServer:post("/llm/update", function(req) -- 694
	ensureLLMConfigTable() -- 695
	do -- 696
		local _type_0 = type(req) -- 696
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 696
		if _tab_0 then -- 696
			local id -- 696
			do -- 696
				local _obj_0 = req.body -- 696
				local _type_1 = type(_obj_0) -- 696
				if "table" == _type_1 or "userdata" == _type_1 then -- 696
					id = _obj_0.id -- 696
				end -- 696
			end -- 696
			local name -- 696
			do -- 696
				local _obj_0 = req.body -- 696
				local _type_1 = type(_obj_0) -- 696
				if "table" == _type_1 or "userdata" == _type_1 then -- 696
					name = _obj_0.name -- 696
				end -- 696
			end -- 696
			local url -- 696
			do -- 696
				local _obj_0 = req.body -- 696
				local _type_1 = type(_obj_0) -- 696
				if "table" == _type_1 or "userdata" == _type_1 then -- 696
					url = _obj_0.url -- 696
				end -- 696
			end -- 696
			local model -- 696
			do -- 696
				local _obj_0 = req.body -- 696
				local _type_1 = type(_obj_0) -- 696
				if "table" == _type_1 or "userdata" == _type_1 then -- 696
					model = _obj_0.model -- 696
				end -- 696
			end -- 696
			local key -- 696
			do -- 696
				local _obj_0 = req.body -- 696
				local _type_1 = type(_obj_0) -- 696
				if "table" == _type_1 or "userdata" == _type_1 then -- 696
					key = _obj_0.key -- 696
				end -- 696
			end -- 696
			if id ~= nil and name ~= nil and url ~= nil and model ~= nil and key ~= nil then -- 696
				local now = os.time() -- 697
				id = tonumber(id) -- 698
				if id == nil then -- 699
					return { -- 700
						success = false, -- 700
						message = "invalid" -- 700
					} -- 700
				end -- 699
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, updated_at = ?\n			where id = ?", { -- 705
					tostring(name), -- 705
					tostring(url), -- 706
					tostring(model), -- 707
					tostring(key), -- 708
					now, -- 709
					id -- 710
				}) -- 701
				return { -- 712
					success = affected >= 0 -- 712
				} -- 712
			end -- 696
		end -- 696
	end -- 696
	return { -- 694
		success = false, -- 694
		message = "invalid" -- 694
	} -- 694
end) -- 694
HttpServer:post("/llm/delete", function(req) -- 714
	ensureLLMConfigTable() -- 715
	do -- 716
		local _type_0 = type(req) -- 716
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 716
		if _tab_0 then -- 716
			local id -- 716
			do -- 716
				local _obj_0 = req.body -- 716
				local _type_1 = type(_obj_0) -- 716
				if "table" == _type_1 or "userdata" == _type_1 then -- 716
					id = _obj_0.id -- 716
				end -- 716
			end -- 716
			if id ~= nil then -- 716
				id = tonumber(id) -- 717
				if id == nil then -- 718
					return { -- 719
						success = false, -- 719
						message = "invalid" -- 719
					} -- 719
				end -- 718
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 720
					id -- 720
				}) -- 720
				return { -- 721
					success = affected >= 0 -- 721
				} -- 721
			end -- 716
		end -- 716
	end -- 716
	return { -- 714
		success = false, -- 714
		message = "invalid" -- 714
	} -- 714
end) -- 714
HttpServer:post("/new", function(req) -- 723
	do -- 724
		local _type_0 = type(req) -- 724
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 724
		if _tab_0 then -- 724
			local path -- 724
			do -- 724
				local _obj_0 = req.body -- 724
				local _type_1 = type(_obj_0) -- 724
				if "table" == _type_1 or "userdata" == _type_1 then -- 724
					path = _obj_0.path -- 724
				end -- 724
			end -- 724
			local content -- 724
			do -- 724
				local _obj_0 = req.body -- 724
				local _type_1 = type(_obj_0) -- 724
				if "table" == _type_1 or "userdata" == _type_1 then -- 724
					content = _obj_0.content -- 724
				end -- 724
			end -- 724
			local folder -- 724
			do -- 724
				local _obj_0 = req.body -- 724
				local _type_1 = type(_obj_0) -- 724
				if "table" == _type_1 or "userdata" == _type_1 then -- 724
					folder = _obj_0.folder -- 724
				end -- 724
			end -- 724
			if path ~= nil and content ~= nil and folder ~= nil then -- 724
				if Content:exist(path) then -- 725
					return { -- 726
						success = false, -- 726
						message = "TargetExisted" -- 726
					} -- 726
				end -- 725
				local parent = Path:getPath(path) -- 727
				local files = Content:getFiles(parent) -- 728
				if folder then -- 729
					local name = Path:getFilename(path):lower() -- 730
					for _index_0 = 1, #files do -- 731
						local file = files[_index_0] -- 731
						if name == Path:getFilename(file):lower() then -- 732
							return { -- 733
								success = false, -- 733
								message = "TargetExisted" -- 733
							} -- 733
						end -- 732
					end -- 731
					if Content:mkdir(path) then -- 734
						return { -- 735
							success = true -- 735
						} -- 735
					end -- 734
				else -- 737
					local name = Path:getName(path):lower() -- 737
					for _index_0 = 1, #files do -- 738
						local file = files[_index_0] -- 738
						if name == Path:getName(file):lower() then -- 739
							local ext = Path:getExt(file) -- 740
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 741
								goto _continue_0 -- 742
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 743
								goto _continue_0 -- 744
							end -- 741
							return { -- 745
								success = false, -- 745
								message = "SourceExisted" -- 745
							} -- 745
						end -- 739
						::_continue_0:: -- 739
					end -- 738
					if Content:save(path, content) then -- 746
						return { -- 747
							success = true -- 747
						} -- 747
					end -- 746
				end -- 729
			end -- 724
		end -- 724
	end -- 724
	return { -- 723
		success = false, -- 723
		message = "Failed" -- 723
	} -- 723
end) -- 723
HttpServer:post("/delete", function(req) -- 749
	do -- 750
		local _type_0 = type(req) -- 750
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 750
		if _tab_0 then -- 750
			local path -- 750
			do -- 750
				local _obj_0 = req.body -- 750
				local _type_1 = type(_obj_0) -- 750
				if "table" == _type_1 or "userdata" == _type_1 then -- 750
					path = _obj_0.path -- 750
				end -- 750
			end -- 750
			if path ~= nil then -- 750
				if Content:exist(path) then -- 751
					local parent = Path:getPath(path) -- 752
					local files = Content:getFiles(parent) -- 753
					local name = Path:getName(path):lower() -- 754
					local ext = Path:getExt(path) -- 755
					for _index_0 = 1, #files do -- 756
						local file = files[_index_0] -- 756
						if name == Path:getName(file):lower() then -- 757
							local _exp_0 = Path:getExt(file) -- 758
							if "tl" == _exp_0 then -- 758
								if ("vs" == ext) then -- 758
									Content:remove(Path(parent, file)) -- 759
								end -- 758
							elseif "lua" == _exp_0 then -- 760
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 760
									Content:remove(Path(parent, file)) -- 761
								end -- 760
							end -- 758
						end -- 757
					end -- 756
					if Content:remove(path) then -- 762
						return { -- 763
							success = true -- 763
						} -- 763
					end -- 762
				end -- 751
			end -- 750
		end -- 750
	end -- 750
	return { -- 749
		success = false -- 749
	} -- 749
end) -- 749
HttpServer:post("/rename", function(req) -- 765
	do -- 766
		local _type_0 = type(req) -- 766
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 766
		if _tab_0 then -- 766
			local old -- 766
			do -- 766
				local _obj_0 = req.body -- 766
				local _type_1 = type(_obj_0) -- 766
				if "table" == _type_1 or "userdata" == _type_1 then -- 766
					old = _obj_0.old -- 766
				end -- 766
			end -- 766
			local new -- 766
			do -- 766
				local _obj_0 = req.body -- 766
				local _type_1 = type(_obj_0) -- 766
				if "table" == _type_1 or "userdata" == _type_1 then -- 766
					new = _obj_0.new -- 766
				end -- 766
			end -- 766
			if old ~= nil and new ~= nil then -- 766
				if Content:exist(old) and not Content:exist(new) then -- 767
					local parent = Path:getPath(new) -- 768
					local files = Content:getFiles(parent) -- 769
					if Content:isdir(old) then -- 770
						local name = Path:getFilename(new):lower() -- 771
						for _index_0 = 1, #files do -- 772
							local file = files[_index_0] -- 772
							if name == Path:getFilename(file):lower() then -- 773
								return { -- 774
									success = false -- 774
								} -- 774
							end -- 773
						end -- 772
					else -- 776
						local name = Path:getName(new):lower() -- 776
						local ext = Path:getExt(new) -- 777
						for _index_0 = 1, #files do -- 778
							local file = files[_index_0] -- 778
							if name == Path:getName(file):lower() then -- 779
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 780
									goto _continue_0 -- 781
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 782
									goto _continue_0 -- 783
								end -- 780
								return { -- 784
									success = false -- 784
								} -- 784
							end -- 779
							::_continue_0:: -- 779
						end -- 778
					end -- 770
					if Content:move(old, new) then -- 785
						local newParent = Path:getPath(new) -- 786
						parent = Path:getPath(old) -- 787
						files = Content:getFiles(parent) -- 788
						local newName = Path:getName(new) -- 789
						local oldName = Path:getName(old) -- 790
						local name = oldName:lower() -- 791
						local ext = Path:getExt(old) -- 792
						for _index_0 = 1, #files do -- 793
							local file = files[_index_0] -- 793
							if name == Path:getName(file):lower() then -- 794
								local _exp_0 = Path:getExt(file) -- 795
								if "tl" == _exp_0 then -- 795
									if ("vs" == ext) then -- 795
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 796
									end -- 795
								elseif "lua" == _exp_0 then -- 797
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 797
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 798
									end -- 797
								end -- 795
							end -- 794
						end -- 793
						return { -- 799
							success = true -- 799
						} -- 799
					end -- 785
				end -- 767
			end -- 766
		end -- 766
	end -- 766
	return { -- 765
		success = false -- 765
	} -- 765
end) -- 765
HttpServer:post("/exist", function(req) -- 801
	do -- 802
		local _type_0 = type(req) -- 802
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 802
		if _tab_0 then -- 802
			local file -- 802
			do -- 802
				local _obj_0 = req.body -- 802
				local _type_1 = type(_obj_0) -- 802
				if "table" == _type_1 or "userdata" == _type_1 then -- 802
					file = _obj_0.file -- 802
				end -- 802
			end -- 802
			if file ~= nil then -- 802
				do -- 803
					local projFile = req.body.projFile -- 803
					if projFile then -- 803
						local projDir = getProjectDirFromFile(projFile) -- 804
						if projDir then -- 804
							local scriptDir = Path(projDir, "Script") -- 805
							local searchPaths = Content.searchPaths -- 806
							if Content:exist(scriptDir) then -- 807
								Content:addSearchPath(scriptDir) -- 807
							end -- 807
							if Content:exist(projDir) then -- 808
								Content:addSearchPath(projDir) -- 808
							end -- 808
							local _ <close> = setmetatable({ }, { -- 809
								__close = function() -- 809
									Content.searchPaths = searchPaths -- 809
								end -- 809
							}) -- 809
							return { -- 810
								success = Content:exist(file) -- 810
							} -- 810
						end -- 804
					end -- 803
				end -- 803
				return { -- 811
					success = Content:exist(file) -- 811
				} -- 811
			end -- 802
		end -- 802
	end -- 802
	return { -- 801
		success = false -- 801
	} -- 801
end) -- 801
HttpServer:postSchedule("/read", function(req) -- 813
	do -- 814
		local _type_0 = type(req) -- 814
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 814
		if _tab_0 then -- 814
			local path -- 814
			do -- 814
				local _obj_0 = req.body -- 814
				local _type_1 = type(_obj_0) -- 814
				if "table" == _type_1 or "userdata" == _type_1 then -- 814
					path = _obj_0.path -- 814
				end -- 814
			end -- 814
			if path ~= nil then -- 814
				local readFile -- 815
				readFile = function() -- 815
					if Content:exist(path) then -- 816
						local content = Content:loadAsync(path) -- 817
						if content then -- 817
							return { -- 818
								content = content, -- 818
								success = true -- 818
							} -- 818
						end -- 817
					end -- 816
					return nil -- 815
				end -- 815
				do -- 819
					local projFile = req.body.projFile -- 819
					if projFile then -- 819
						local projDir = getProjectDirFromFile(projFile) -- 820
						if projDir then -- 820
							local scriptDir = Path(projDir, "Script") -- 821
							local searchPaths = Content.searchPaths -- 822
							if Content:exist(scriptDir) then -- 823
								Content:addSearchPath(scriptDir) -- 823
							end -- 823
							if Content:exist(projDir) then -- 824
								Content:addSearchPath(projDir) -- 824
							end -- 824
							local _ <close> = setmetatable({ }, { -- 825
								__close = function() -- 825
									Content.searchPaths = searchPaths -- 825
								end -- 825
							}) -- 825
							local result = readFile() -- 826
							if result then -- 826
								return result -- 826
							end -- 826
						end -- 820
					end -- 819
				end -- 819
				local result = readFile() -- 827
				if result then -- 827
					return result -- 827
				end -- 827
			end -- 814
		end -- 814
	end -- 814
	return { -- 813
		success = false -- 813
	} -- 813
end) -- 813
HttpServer:get("/read-sync", function(req) -- 829
	do -- 830
		local _type_0 = type(req) -- 830
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 830
		if _tab_0 then -- 830
			local params = req.params -- 830
			if params ~= nil then -- 830
				local path = params.path -- 831
				local exts -- 832
				if params.exts then -- 832
					local _accum_0 = { } -- 833
					local _len_0 = 1 -- 833
					for ext in params.exts:gmatch("[^|]*") do -- 833
						_accum_0[_len_0] = ext -- 834
						_len_0 = _len_0 + 1 -- 834
					end -- 833
					exts = _accum_0 -- 833
				else -- 835
					exts = { -- 835
						"" -- 835
					} -- 835
				end -- 832
				local readFile -- 836
				readFile = function() -- 836
					for _index_0 = 1, #exts do -- 837
						local ext = exts[_index_0] -- 837
						local targetPath = path .. ext -- 838
						if Content:exist(targetPath) then -- 839
							local content = Content:load(targetPath) -- 840
							if content then -- 840
								return { -- 841
									content = content, -- 841
									success = true, -- 841
									fullPath = Content:getFullPath(targetPath) -- 841
								} -- 841
							end -- 840
						end -- 839
					end -- 837
					return nil -- 836
				end -- 836
				local searchPaths = Content.searchPaths -- 842
				local _ <close> = setmetatable({ }, { -- 843
					__close = function() -- 843
						Content.searchPaths = searchPaths -- 843
					end -- 843
				}) -- 843
				do -- 844
					local projFile = req.params.projFile -- 844
					if projFile then -- 844
						local projDir = getProjectDirFromFile(projFile) -- 845
						if projDir then -- 845
							local scriptDir = Path(projDir, "Script") -- 846
							if Content:exist(scriptDir) then -- 847
								Content:addSearchPath(scriptDir) -- 847
							end -- 847
							if Content:exist(projDir) then -- 848
								Content:addSearchPath(projDir) -- 848
							end -- 848
						else -- 850
							projDir = Path:getPath(projFile) -- 850
							if Content:exist(projDir) then -- 851
								Content:addSearchPath(projDir) -- 851
							end -- 851
						end -- 845
					end -- 844
				end -- 844
				local result = readFile() -- 852
				if result then -- 852
					return result -- 852
				end -- 852
			end -- 830
		end -- 830
	end -- 830
	return { -- 829
		success = false -- 829
	} -- 829
end) -- 829
local compileFileAsync -- 854
compileFileAsync = function(inputFile, sourceCodes) -- 854
	local file = inputFile -- 855
	local searchPath -- 856
	do -- 856
		local dir = getProjectDirFromFile(inputFile) -- 856
		if dir then -- 856
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 857
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 858
		else -- 860
			file = Path:getRelative(inputFile, Content.writablePath) -- 860
			if file:sub(1, 2) == ".." then -- 861
				file = Path:getRelative(inputFile, Content.assetPath) -- 862
			end -- 861
			searchPath = "" -- 863
		end -- 856
	end -- 856
	local outputFile = Path:replaceExt(inputFile, "lua") -- 864
	local yueext = yue.options.extension -- 865
	local resultCodes = nil -- 866
	do -- 867
		local _exp_0 = Path:getExt(inputFile) -- 867
		if yueext == _exp_0 then -- 867
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 868
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 869
				if not codes then -- 870
					return -- 870
				end -- 870
				local extraGlobal -- 871
				if isTIC80 then -- 871
					extraGlobal = tic80APIs -- 871
				else -- 871
					extraGlobal = nil -- 871
				end -- 871
				local success = LintYueGlobals(codes, globals, true, extraGlobal) -- 872
				if not success then -- 873
					return -- 873
				end -- 873
				if codes == "" then -- 874
					resultCodes = "" -- 875
					return nil -- 876
				end -- 874
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 877
				return resultCodes -- 878
			end, function(success) -- 869
				if not success then -- 879
					Content:remove(outputFile) -- 880
					if resultCodes == nil then -- 881
						resultCodes = false -- 882
					end -- 881
				end -- 879
			end) -- 869
		elseif "tl" == _exp_0 then -- 883
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 884
			if isTIC80 then -- 885
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 886
			end -- 885
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 887
			if codes then -- 887
				if isTIC80 then -- 888
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 889
				end -- 888
				resultCodes = codes -- 890
				Content:saveAsync(outputFile, codes) -- 891
			else -- 893
				Content:remove(outputFile) -- 893
				resultCodes = false -- 894
			end -- 887
		elseif "xml" == _exp_0 then -- 895
			local codes = xml.tolua(sourceCodes) -- 896
			if codes then -- 896
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 897
				Content:saveAsync(outputFile, resultCodes) -- 898
			else -- 900
				Content:remove(outputFile) -- 900
				resultCodes = false -- 901
			end -- 896
		end -- 867
	end -- 867
	wait(function() -- 902
		return resultCodes ~= nil -- 902
	end) -- 902
	if resultCodes then -- 903
		return resultCodes -- 903
	end -- 903
	return nil -- 854
end -- 854
HttpServer:postSchedule("/write", function(req) -- 905
	do -- 906
		local _type_0 = type(req) -- 906
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 906
		if _tab_0 then -- 906
			local path -- 906
			do -- 906
				local _obj_0 = req.body -- 906
				local _type_1 = type(_obj_0) -- 906
				if "table" == _type_1 or "userdata" == _type_1 then -- 906
					path = _obj_0.path -- 906
				end -- 906
			end -- 906
			local content -- 906
			do -- 906
				local _obj_0 = req.body -- 906
				local _type_1 = type(_obj_0) -- 906
				if "table" == _type_1 or "userdata" == _type_1 then -- 906
					content = _obj_0.content -- 906
				end -- 906
			end -- 906
			if path ~= nil and content ~= nil then -- 906
				if Content:saveAsync(path, content) then -- 907
					do -- 908
						local _exp_0 = Path:getExt(path) -- 908
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 908
							if '' == Path:getExt(Path:getName(path)) then -- 909
								local resultCodes = compileFileAsync(path, content) -- 910
								return { -- 911
									success = true, -- 911
									resultCodes = resultCodes -- 911
								} -- 911
							end -- 909
						end -- 908
					end -- 908
					return { -- 912
						success = true -- 912
					} -- 912
				end -- 907
			end -- 906
		end -- 906
	end -- 906
	return { -- 905
		success = false -- 905
	} -- 905
end) -- 905
HttpServer:postSchedule("/build", function(req) -- 914
	do -- 915
		local _type_0 = type(req) -- 915
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 915
		if _tab_0 then -- 915
			local path -- 915
			do -- 915
				local _obj_0 = req.body -- 915
				local _type_1 = type(_obj_0) -- 915
				if "table" == _type_1 or "userdata" == _type_1 then -- 915
					path = _obj_0.path -- 915
				end -- 915
			end -- 915
			if path ~= nil then -- 915
				local _exp_0 = Path:getExt(path) -- 916
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 916
					if '' == Path:getExt(Path:getName(path)) then -- 917
						local content = Content:loadAsync(path) -- 918
						if content then -- 918
							local resultCodes = compileFileAsync(path, content) -- 919
							if resultCodes then -- 919
								return { -- 920
									success = true, -- 920
									resultCodes = resultCodes -- 920
								} -- 920
							end -- 919
						end -- 918
					end -- 917
				end -- 916
			end -- 915
		end -- 915
	end -- 915
	return { -- 914
		success = false -- 914
	} -- 914
end) -- 914
local extentionLevels = { -- 923
	vs = 2, -- 923
	bl = 2, -- 924
	ts = 1, -- 925
	tsx = 1, -- 926
	tl = 1, -- 927
	yue = 1, -- 928
	xml = 1, -- 929
	lua = 0 -- 930
} -- 922
HttpServer:post("/assets", function() -- 932
	local Entry = require("Script.Dev.Entry") -- 935
	local engineDev = Entry.getEngineDev() -- 936
	local visitAssets -- 937
	visitAssets = function(path, tag) -- 937
		local isWorkspace = tag == "Workspace" -- 938
		local builtin -- 939
		if tag == "Builtin" then -- 939
			builtin = true -- 939
		else -- 939
			builtin = nil -- 939
		end -- 939
		local children = nil -- 940
		local dirs = Content:getDirs(path) -- 941
		for _index_0 = 1, #dirs do -- 942
			local dir = dirs[_index_0] -- 942
			if isWorkspace then -- 943
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 944
					goto _continue_0 -- 945
				end -- 944
			elseif dir == ".git" then -- 946
				goto _continue_0 -- 947
			end -- 943
			if not children then -- 948
				children = { } -- 948
			end -- 948
			children[#children + 1] = visitAssets(Path(path, dir)) -- 949
			::_continue_0:: -- 943
		end -- 942
		local files = Content:getFiles(path) -- 950
		local names = { } -- 951
		for _index_0 = 1, #files do -- 952
			local file = files[_index_0] -- 952
			if file:match("^%.") then -- 953
				goto _continue_1 -- 953
			end -- 953
			local name = Path:getName(file) -- 954
			local ext = names[name] -- 955
			if ext then -- 955
				local lv1 -- 956
				do -- 956
					local _exp_0 = extentionLevels[ext] -- 956
					if _exp_0 ~= nil then -- 956
						lv1 = _exp_0 -- 956
					else -- 956
						lv1 = -1 -- 956
					end -- 956
				end -- 956
				ext = Path:getExt(file) -- 957
				local lv2 -- 958
				do -- 958
					local _exp_0 = extentionLevels[ext] -- 958
					if _exp_0 ~= nil then -- 958
						lv2 = _exp_0 -- 958
					else -- 958
						lv2 = -1 -- 958
					end -- 958
				end -- 958
				if lv2 > lv1 then -- 959
					names[name] = ext -- 960
				elseif lv2 == lv1 then -- 961
					names[name .. '.' .. ext] = "" -- 962
				end -- 959
			else -- 964
				ext = Path:getExt(file) -- 964
				if not extentionLevels[ext] then -- 965
					names[file] = "" -- 966
				else -- 968
					names[name] = ext -- 968
				end -- 965
			end -- 955
			::_continue_1:: -- 953
		end -- 952
		do -- 969
			local _accum_0 = { } -- 969
			local _len_0 = 1 -- 969
			for name, ext in pairs(names) do -- 969
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 969
				_len_0 = _len_0 + 1 -- 969
			end -- 969
			files = _accum_0 -- 969
		end -- 969
		for _index_0 = 1, #files do -- 970
			local file = files[_index_0] -- 970
			if not children then -- 971
				children = { } -- 971
			end -- 971
			children[#children + 1] = { -- 973
				key = Path(path, file), -- 973
				dir = false, -- 974
				title = file, -- 975
				builtin = builtin -- 976
			} -- 972
		end -- 970
		if children then -- 978
			table.sort(children, function(a, b) -- 979
				if a.dir == b.dir then -- 980
					return a.title < b.title -- 981
				else -- 983
					return a.dir -- 983
				end -- 980
			end) -- 979
		end -- 978
		if isWorkspace and children then -- 984
			return children -- 985
		else -- 987
			return { -- 988
				key = path, -- 988
				dir = true, -- 989
				title = Path:getFilename(path), -- 990
				builtin = builtin, -- 991
				children = children -- 992
			} -- 987
		end -- 984
	end -- 937
	local zh = (App.locale:match("^zh") ~= nil) -- 994
	return { -- 996
		key = Content.writablePath, -- 996
		dir = true, -- 997
		root = true, -- 998
		title = "Assets", -- 999
		children = (function() -- 1001
			local _tab_0 = { -- 1001
				{ -- 1002
					key = Path(Content.assetPath), -- 1002
					dir = true, -- 1003
					builtin = true, -- 1004
					title = zh and "内置资源" or "Built-in", -- 1005
					children = { -- 1007
						(function() -- 1007
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1007
							_with_0.title = zh and "说明文档" or "Readme" -- 1008
							return _with_0 -- 1007
						end)(), -- 1007
						(function() -- 1009
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1009
							_with_0.title = zh and "接口文档" or "API Doc" -- 1010
							return _with_0 -- 1009
						end)(), -- 1009
						(function() -- 1011
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1011
							_with_0.title = zh and "开发工具" or "Tools" -- 1012
							return _with_0 -- 1011
						end)(), -- 1011
						(function() -- 1013
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1013
							_with_0.title = zh and "字体" or "Font" -- 1014
							return _with_0 -- 1013
						end)(), -- 1013
						(function() -- 1015
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1015
							_with_0.title = zh and "程序库" or "Lib" -- 1016
							if engineDev then -- 1017
								local _list_0 = _with_0.children -- 1018
								for _index_0 = 1, #_list_0 do -- 1018
									local child = _list_0[_index_0] -- 1018
									if not (child.title == "Dora") then -- 1019
										goto _continue_0 -- 1019
									end -- 1019
									local title = zh and "zh-Hans" or "en" -- 1020
									do -- 1021
										local _accum_0 = { } -- 1021
										local _len_0 = 1 -- 1021
										local _list_1 = child.children -- 1021
										for _index_1 = 1, #_list_1 do -- 1021
											local c = _list_1[_index_1] -- 1021
											if c.title ~= title then -- 1021
												_accum_0[_len_0] = c -- 1021
												_len_0 = _len_0 + 1 -- 1021
											end -- 1021
										end -- 1021
										child.children = _accum_0 -- 1021
									end -- 1021
									break -- 1022
									::_continue_0:: -- 1019
								end -- 1018
							else -- 1024
								local _accum_0 = { } -- 1024
								local _len_0 = 1 -- 1024
								local _list_0 = _with_0.children -- 1024
								for _index_0 = 1, #_list_0 do -- 1024
									local child = _list_0[_index_0] -- 1024
									if child.title ~= "Dora" then -- 1024
										_accum_0[_len_0] = child -- 1024
										_len_0 = _len_0 + 1 -- 1024
									end -- 1024
								end -- 1024
								_with_0.children = _accum_0 -- 1024
							end -- 1017
							return _with_0 -- 1015
						end)(), -- 1015
						(function() -- 1025
							if engineDev then -- 1025
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1026
								local _obj_0 = _with_0.children -- 1027
								_obj_0[#_obj_0 + 1] = { -- 1028
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1028
									dir = false, -- 1029
									builtin = true, -- 1030
									title = "init.yue" -- 1031
								} -- 1027
								return _with_0 -- 1026
							end -- 1025
						end)() -- 1025
					} -- 1006
				} -- 1001
			} -- 1035
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1035
			local _idx_0 = #_tab_0 + 1 -- 1035
			for _index_0 = 1, #_obj_0 do -- 1035
				local _value_0 = _obj_0[_index_0] -- 1035
				_tab_0[_idx_0] = _value_0 -- 1035
				_idx_0 = _idx_0 + 1 -- 1035
			end -- 1035
			return _tab_0 -- 1001
		end)() -- 1000
	} -- 995
end) -- 932
HttpServer:postSchedule("/run", function(req) -- 1039
	do -- 1040
		local _type_0 = type(req) -- 1040
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1040
		if _tab_0 then -- 1040
			local file -- 1040
			do -- 1040
				local _obj_0 = req.body -- 1040
				local _type_1 = type(_obj_0) -- 1040
				if "table" == _type_1 or "userdata" == _type_1 then -- 1040
					file = _obj_0.file -- 1040
				end -- 1040
			end -- 1040
			local asProj -- 1040
			do -- 1040
				local _obj_0 = req.body -- 1040
				local _type_1 = type(_obj_0) -- 1040
				if "table" == _type_1 or "userdata" == _type_1 then -- 1040
					asProj = _obj_0.asProj -- 1040
				end -- 1040
			end -- 1040
			if file ~= nil and asProj ~= nil then -- 1040
				if not Content:isAbsolutePath(file) then -- 1041
					local devFile = Path(Content.writablePath, file) -- 1042
					if Content:exist(devFile) then -- 1043
						file = devFile -- 1043
					end -- 1043
				end -- 1041
				local Entry = require("Script.Dev.Entry") -- 1044
				local workDir -- 1045
				if asProj then -- 1046
					workDir = getProjectDirFromFile(file) -- 1047
					if workDir then -- 1047
						Entry.allClear() -- 1048
						local target = Path(workDir, "init") -- 1049
						local success, err = Entry.enterEntryAsync({ -- 1050
							entryName = "Project", -- 1050
							fileName = target -- 1050
						}) -- 1050
						target = Path:getName(Path:getPath(target)) -- 1051
						return { -- 1052
							success = success, -- 1052
							target = target, -- 1052
							err = err -- 1052
						} -- 1052
					end -- 1047
				else -- 1054
					workDir = getProjectDirFromFile(file) -- 1054
				end -- 1046
				Entry.allClear() -- 1055
				file = Path:replaceExt(file, "") -- 1056
				local success, err = Entry.enterEntryAsync({ -- 1058
					entryName = Path:getName(file), -- 1058
					fileName = file, -- 1059
					workDir = workDir -- 1060
				}) -- 1057
				return { -- 1061
					success = success, -- 1061
					err = err -- 1061
				} -- 1061
			end -- 1040
		end -- 1040
	end -- 1040
	return { -- 1039
		success = false -- 1039
	} -- 1039
end) -- 1039
HttpServer:postSchedule("/stop", function() -- 1063
	local Entry = require("Script.Dev.Entry") -- 1064
	return { -- 1065
		success = Entry.stop() -- 1065
	} -- 1065
end) -- 1063
local minifyAsync -- 1067
minifyAsync = function(sourcePath, minifyPath) -- 1067
	if not Content:exist(sourcePath) then -- 1068
		return -- 1068
	end -- 1068
	local Entry = require("Script.Dev.Entry") -- 1069
	local errors = { } -- 1070
	local files = Entry.getAllFiles(sourcePath, { -- 1071
		"lua" -- 1071
	}, true) -- 1071
	do -- 1072
		local _accum_0 = { } -- 1072
		local _len_0 = 1 -- 1072
		for _index_0 = 1, #files do -- 1072
			local file = files[_index_0] -- 1072
			if file:sub(1, 1) ~= '.' then -- 1072
				_accum_0[_len_0] = file -- 1072
				_len_0 = _len_0 + 1 -- 1072
			end -- 1072
		end -- 1072
		files = _accum_0 -- 1072
	end -- 1072
	local paths -- 1073
	do -- 1073
		local _tbl_0 = { } -- 1073
		for _index_0 = 1, #files do -- 1073
			local file = files[_index_0] -- 1073
			_tbl_0[Path:getPath(file)] = true -- 1073
		end -- 1073
		paths = _tbl_0 -- 1073
	end -- 1073
	for path in pairs(paths) do -- 1074
		Content:mkdir(Path(minifyPath, path)) -- 1074
	end -- 1074
	local _ <close> = setmetatable({ }, { -- 1075
		__close = function() -- 1075
			package.loaded["luaminify.FormatMini"] = nil -- 1076
			package.loaded["luaminify.ParseLua"] = nil -- 1077
			package.loaded["luaminify.Scope"] = nil -- 1078
			package.loaded["luaminify.Util"] = nil -- 1079
		end -- 1075
	}) -- 1075
	local FormatMini -- 1080
	do -- 1080
		local _obj_0 = require("luaminify") -- 1080
		FormatMini = _obj_0.FormatMini -- 1080
	end -- 1080
	local fileCount = #files -- 1081
	local count = 0 -- 1082
	for _index_0 = 1, #files do -- 1083
		local file = files[_index_0] -- 1083
		thread(function() -- 1084
			local _ <close> = setmetatable({ }, { -- 1085
				__close = function() -- 1085
					count = count + 1 -- 1085
				end -- 1085
			}) -- 1085
			local input = Path(sourcePath, file) -- 1086
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1087
			if Content:exist(input) then -- 1088
				local sourceCodes = Content:loadAsync(input) -- 1089
				local res, err = FormatMini(sourceCodes) -- 1090
				if res then -- 1091
					Content:saveAsync(output, res) -- 1092
					return print("Minify " .. tostring(file)) -- 1093
				else -- 1095
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1095
				end -- 1091
			else -- 1097
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1097
			end -- 1088
		end) -- 1084
		sleep() -- 1098
	end -- 1083
	wait(function() -- 1099
		return count == fileCount -- 1099
	end) -- 1099
	if #errors > 0 then -- 1100
		print(table.concat(errors, '\n')) -- 1101
	end -- 1100
	print("Obfuscation done.") -- 1102
	return files -- 1103
end -- 1067
local zipping = false -- 1105
HttpServer:postSchedule("/zip", function(req) -- 1107
	do -- 1108
		local _type_0 = type(req) -- 1108
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1108
		if _tab_0 then -- 1108
			local path -- 1108
			do -- 1108
				local _obj_0 = req.body -- 1108
				local _type_1 = type(_obj_0) -- 1108
				if "table" == _type_1 or "userdata" == _type_1 then -- 1108
					path = _obj_0.path -- 1108
				end -- 1108
			end -- 1108
			local zipFile -- 1108
			do -- 1108
				local _obj_0 = req.body -- 1108
				local _type_1 = type(_obj_0) -- 1108
				if "table" == _type_1 or "userdata" == _type_1 then -- 1108
					zipFile = _obj_0.zipFile -- 1108
				end -- 1108
			end -- 1108
			local obfuscated -- 1108
			do -- 1108
				local _obj_0 = req.body -- 1108
				local _type_1 = type(_obj_0) -- 1108
				if "table" == _type_1 or "userdata" == _type_1 then -- 1108
					obfuscated = _obj_0.obfuscated -- 1108
				end -- 1108
			end -- 1108
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1108
				if zipping then -- 1109
					goto failed -- 1109
				end -- 1109
				zipping = true -- 1110
				local _ <close> = setmetatable({ }, { -- 1111
					__close = function() -- 1111
						zipping = false -- 1111
					end -- 1111
				}) -- 1111
				if not Content:exist(path) then -- 1112
					goto failed -- 1112
				end -- 1112
				Content:mkdir(Path:getPath(zipFile)) -- 1113
				if obfuscated then -- 1114
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1115
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1116
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1117
					Content:remove(scriptPath) -- 1118
					Content:remove(obfuscatedPath) -- 1119
					Content:remove(tempPath) -- 1120
					Content:mkdir(scriptPath) -- 1121
					Content:mkdir(obfuscatedPath) -- 1122
					Content:mkdir(tempPath) -- 1123
					if not Content:copyAsync(path, tempPath) then -- 1124
						goto failed -- 1124
					end -- 1124
					local Entry = require("Script.Dev.Entry") -- 1125
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1126
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1127
						"tl", -- 1127
						"yue", -- 1127
						"lua", -- 1127
						"ts", -- 1127
						"tsx", -- 1127
						"vs", -- 1127
						"bl", -- 1127
						"xml", -- 1127
						"wa", -- 1127
						"mod" -- 1127
					}, true) -- 1127
					for _index_0 = 1, #scriptFiles do -- 1128
						local file = scriptFiles[_index_0] -- 1128
						Content:remove(Path(tempPath, file)) -- 1129
					end -- 1128
					for _index_0 = 1, #luaFiles do -- 1130
						local file = luaFiles[_index_0] -- 1130
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1131
					end -- 1130
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1132
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1133
					end) then -- 1132
						goto failed -- 1132
					end -- 1132
					return { -- 1134
						success = true -- 1134
					} -- 1134
				else -- 1136
					return { -- 1136
						success = Content:zipAsync(path, zipFile, function(file) -- 1136
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1137
						end) -- 1136
					} -- 1136
				end -- 1114
			end -- 1108
		end -- 1108
	end -- 1108
	::failed:: -- 1138
	return { -- 1107
		success = false -- 1107
	} -- 1107
end) -- 1107
HttpServer:postSchedule("/unzip", function(req) -- 1140
	do -- 1141
		local _type_0 = type(req) -- 1141
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1141
		if _tab_0 then -- 1141
			local zipFile -- 1141
			do -- 1141
				local _obj_0 = req.body -- 1141
				local _type_1 = type(_obj_0) -- 1141
				if "table" == _type_1 or "userdata" == _type_1 then -- 1141
					zipFile = _obj_0.zipFile -- 1141
				end -- 1141
			end -- 1141
			local path -- 1141
			do -- 1141
				local _obj_0 = req.body -- 1141
				local _type_1 = type(_obj_0) -- 1141
				if "table" == _type_1 or "userdata" == _type_1 then -- 1141
					path = _obj_0.path -- 1141
				end -- 1141
			end -- 1141
			if zipFile ~= nil and path ~= nil then -- 1141
				return { -- 1142
					success = Content:unzipAsync(zipFile, path, function(file) -- 1142
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1143
					end) -- 1142
				} -- 1142
			end -- 1141
		end -- 1141
	end -- 1141
	return { -- 1140
		success = false -- 1140
	} -- 1140
end) -- 1140
HttpServer:post("/editing-info", function(req) -- 1145
	local Entry = require("Script.Dev.Entry") -- 1146
	local config = Entry.getConfig() -- 1147
	local _type_0 = type(req) -- 1148
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1148
	local _match_0 = false -- 1148
	if _tab_0 then -- 1148
		local editingInfo -- 1148
		do -- 1148
			local _obj_0 = req.body -- 1148
			local _type_1 = type(_obj_0) -- 1148
			if "table" == _type_1 or "userdata" == _type_1 then -- 1148
				editingInfo = _obj_0.editingInfo -- 1148
			end -- 1148
		end -- 1148
		if editingInfo ~= nil then -- 1148
			_match_0 = true -- 1148
			config.editingInfo = editingInfo -- 1149
			return { -- 1150
				success = true -- 1150
			} -- 1150
		end -- 1148
	end -- 1148
	if not _match_0 then -- 1148
		if not (config.editingInfo ~= nil) then -- 1152
			local folder -- 1153
			if App.locale:match('^zh') then -- 1153
				folder = 'zh-Hans' -- 1153
			else -- 1153
				folder = 'en' -- 1153
			end -- 1153
			config.editingInfo = json.encode({ -- 1155
				index = 0, -- 1155
				files = { -- 1157
					{ -- 1158
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1158
						title = "welcome.md" -- 1159
					} -- 1157
				} -- 1156
			}) -- 1154
		end -- 1152
		return { -- 1163
			success = true, -- 1163
			editingInfo = config.editingInfo -- 1163
		} -- 1163
	end -- 1148
end) -- 1145
HttpServer:post("/command", function(req) -- 1165
	do -- 1166
		local _type_0 = type(req) -- 1166
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1166
		if _tab_0 then -- 1166
			local code -- 1166
			do -- 1166
				local _obj_0 = req.body -- 1166
				local _type_1 = type(_obj_0) -- 1166
				if "table" == _type_1 or "userdata" == _type_1 then -- 1166
					code = _obj_0.code -- 1166
				end -- 1166
			end -- 1166
			local log -- 1166
			do -- 1166
				local _obj_0 = req.body -- 1166
				local _type_1 = type(_obj_0) -- 1166
				if "table" == _type_1 or "userdata" == _type_1 then -- 1166
					log = _obj_0.log -- 1166
				end -- 1166
			end -- 1166
			if code ~= nil and log ~= nil then -- 1166
				emit("AppCommand", code, log) -- 1167
				return { -- 1168
					success = true -- 1168
				} -- 1168
			end -- 1166
		end -- 1166
	end -- 1166
	return { -- 1165
		success = false -- 1165
	} -- 1165
end) -- 1165
HttpServer:post("/log/save", function() -- 1170
	local folder = ".download" -- 1171
	local fullLogFile = "dora_full_logs.txt" -- 1172
	local fullFolder = Path(Content.writablePath, folder) -- 1173
	Content:mkdir(fullFolder) -- 1174
	local logPath = Path(fullFolder, fullLogFile) -- 1175
	if App:saveLog(logPath) then -- 1176
		return { -- 1177
			success = true, -- 1177
			path = Path(folder, fullLogFile) -- 1177
		} -- 1177
	end -- 1176
	return { -- 1170
		success = false -- 1170
	} -- 1170
end) -- 1170
HttpServer:post("/yarn/check", function(req) -- 1179
	local yarncompile = require("yarncompile") -- 1180
	do -- 1181
		local _type_0 = type(req) -- 1181
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1181
		if _tab_0 then -- 1181
			local code -- 1181
			do -- 1181
				local _obj_0 = req.body -- 1181
				local _type_1 = type(_obj_0) -- 1181
				if "table" == _type_1 or "userdata" == _type_1 then -- 1181
					code = _obj_0.code -- 1181
				end -- 1181
			end -- 1181
			if code ~= nil then -- 1181
				local jsonObject = json.decode(code) -- 1182
				if jsonObject then -- 1182
					local errors = { } -- 1183
					local _list_0 = jsonObject.nodes -- 1184
					for _index_0 = 1, #_list_0 do -- 1184
						local node = _list_0[_index_0] -- 1184
						local title, body = node.title, node.body -- 1185
						local luaCode, err = yarncompile(body) -- 1186
						if not luaCode then -- 1186
							errors[#errors + 1] = title .. ":" .. err -- 1187
						end -- 1186
					end -- 1184
					return { -- 1188
						success = true, -- 1188
						syntaxError = table.concat(errors, "\n\n") -- 1188
					} -- 1188
				end -- 1182
			end -- 1181
		end -- 1181
	end -- 1181
	return { -- 1179
		success = false -- 1179
	} -- 1179
end) -- 1179
HttpServer:post("/yarn/check-file", function(req) -- 1190
	local yarncompile = require("yarncompile") -- 1191
	do -- 1192
		local _type_0 = type(req) -- 1192
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1192
		if _tab_0 then -- 1192
			local code -- 1192
			do -- 1192
				local _obj_0 = req.body -- 1192
				local _type_1 = type(_obj_0) -- 1192
				if "table" == _type_1 or "userdata" == _type_1 then -- 1192
					code = _obj_0.code -- 1192
				end -- 1192
			end -- 1192
			if code ~= nil then -- 1192
				local res, _, err = yarncompile(code, true) -- 1193
				if not res then -- 1193
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1194
					return { -- 1195
						success = false, -- 1195
						message = message, -- 1195
						line = line, -- 1195
						column = column, -- 1195
						node = node -- 1195
					} -- 1195
				end -- 1193
			end -- 1192
		end -- 1192
	end -- 1192
	return { -- 1190
		success = true -- 1190
	} -- 1190
end) -- 1190
local getWaProjectDirFromFile -- 1197
getWaProjectDirFromFile = function(file) -- 1197
	local writablePath = Content.writablePath -- 1198
	local parent, current -- 1199
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1199
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1200
	else -- 1202
		parent, current = nil, nil -- 1202
	end -- 1199
	if not current then -- 1203
		return nil -- 1203
	end -- 1203
	repeat -- 1204
		current = Path:getPath(current) -- 1205
		if current == "" then -- 1206
			break -- 1206
		end -- 1206
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1207
		for _index_0 = 1, #_list_0 do -- 1207
			local f = _list_0[_index_0] -- 1207
			if Path:getFilename(f):lower() == "wa.mod" then -- 1208
				return Path(parent, current, Path:getPath(f)) -- 1209
			end -- 1208
		end -- 1207
	until false -- 1204
	return nil -- 1211
end -- 1197
HttpServer:postSchedule("/wa/build", function(req) -- 1213
	do -- 1214
		local _type_0 = type(req) -- 1214
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1214
		if _tab_0 then -- 1214
			local path -- 1214
			do -- 1214
				local _obj_0 = req.body -- 1214
				local _type_1 = type(_obj_0) -- 1214
				if "table" == _type_1 or "userdata" == _type_1 then -- 1214
					path = _obj_0.path -- 1214
				end -- 1214
			end -- 1214
			if path ~= nil then -- 1214
				local projDir = getWaProjectDirFromFile(path) -- 1215
				if projDir then -- 1215
					local message = Wasm:buildWaAsync(projDir) -- 1216
					if message == "" then -- 1217
						return { -- 1218
							success = true -- 1218
						} -- 1218
					else -- 1220
						return { -- 1220
							success = false, -- 1220
							message = message -- 1220
						} -- 1220
					end -- 1217
				else -- 1222
					return { -- 1222
						success = false, -- 1222
						message = 'Wa file needs a project' -- 1222
					} -- 1222
				end -- 1215
			end -- 1214
		end -- 1214
	end -- 1214
	return { -- 1223
		success = false, -- 1223
		message = 'failed to build' -- 1223
	} -- 1223
end) -- 1213
HttpServer:postSchedule("/wa/format", function(req) -- 1225
	do -- 1226
		local _type_0 = type(req) -- 1226
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1226
		if _tab_0 then -- 1226
			local file -- 1226
			do -- 1226
				local _obj_0 = req.body -- 1226
				local _type_1 = type(_obj_0) -- 1226
				if "table" == _type_1 or "userdata" == _type_1 then -- 1226
					file = _obj_0.file -- 1226
				end -- 1226
			end -- 1226
			if file ~= nil then -- 1226
				local code = Wasm:formatWaAsync(file) -- 1227
				if code == "" then -- 1228
					return { -- 1229
						success = false -- 1229
					} -- 1229
				else -- 1231
					return { -- 1231
						success = true, -- 1231
						code = code -- 1231
					} -- 1231
				end -- 1228
			end -- 1226
		end -- 1226
	end -- 1226
	return { -- 1232
		success = false -- 1232
	} -- 1232
end) -- 1225
HttpServer:postSchedule("/wa/create", function(req) -- 1234
	do -- 1235
		local _type_0 = type(req) -- 1235
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1235
		if _tab_0 then -- 1235
			local path -- 1235
			do -- 1235
				local _obj_0 = req.body -- 1235
				local _type_1 = type(_obj_0) -- 1235
				if "table" == _type_1 or "userdata" == _type_1 then -- 1235
					path = _obj_0.path -- 1235
				end -- 1235
			end -- 1235
			if path ~= nil then -- 1235
				if not Content:exist(Path:getPath(path)) then -- 1236
					return { -- 1237
						success = false, -- 1237
						message = "target path not existed" -- 1237
					} -- 1237
				end -- 1236
				if Content:exist(path) then -- 1238
					return { -- 1239
						success = false, -- 1239
						message = "target project folder existed" -- 1239
					} -- 1239
				end -- 1238
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1240
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1241
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1242
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1243
					return { -- 1246
						success = false, -- 1246
						message = "missing template project" -- 1246
					} -- 1246
				end -- 1243
				if not Content:mkdir(path) then -- 1247
					return { -- 1248
						success = false, -- 1248
						message = "failed to create project folder" -- 1248
					} -- 1248
				end -- 1247
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1249
					Content:remove(path) -- 1250
					return { -- 1251
						success = false, -- 1251
						message = "failed to copy template" -- 1251
					} -- 1251
				end -- 1249
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1252
					Content:remove(path) -- 1253
					return { -- 1254
						success = false, -- 1254
						message = "failed to copy template" -- 1254
					} -- 1254
				end -- 1252
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1255
					Content:remove(path) -- 1256
					return { -- 1257
						success = false, -- 1257
						message = "failed to copy template" -- 1257
					} -- 1257
				end -- 1255
				return { -- 1258
					success = true -- 1258
				} -- 1258
			end -- 1235
		end -- 1235
	end -- 1235
	return { -- 1234
		success = false, -- 1234
		message = "invalid call" -- 1234
	} -- 1234
end) -- 1234
local _anon_func_3 = function(path) -- 1267
	local _val_0 = Path:getExt(path) -- 1267
	return "ts" == _val_0 or "tsx" == _val_0 -- 1267
end -- 1267
local _anon_func_4 = function(f) -- 1297
	local _val_0 = Path:getExt(f) -- 1297
	return "ts" == _val_0 or "tsx" == _val_0 -- 1297
end -- 1297
HttpServer:postSchedule("/ts/build", function(req) -- 1260
	do -- 1261
		local _type_0 = type(req) -- 1261
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1261
		if _tab_0 then -- 1261
			local path -- 1261
			do -- 1261
				local _obj_0 = req.body -- 1261
				local _type_1 = type(_obj_0) -- 1261
				if "table" == _type_1 or "userdata" == _type_1 then -- 1261
					path = _obj_0.path -- 1261
				end -- 1261
			end -- 1261
			if path ~= nil then -- 1261
				if HttpServer.wsConnectionCount == 0 then -- 1262
					return { -- 1263
						success = false, -- 1263
						message = "Web IDE not connected" -- 1263
					} -- 1263
				end -- 1262
				if not Content:exist(path) then -- 1264
					return { -- 1265
						success = false, -- 1265
						message = "path not existed" -- 1265
					} -- 1265
				end -- 1264
				if not Content:isdir(path) then -- 1266
					if not (_anon_func_3(path)) then -- 1267
						return { -- 1268
							success = false, -- 1268
							message = "expecting a TypeScript file" -- 1268
						} -- 1268
					end -- 1267
					local messages = { } -- 1269
					local content = Content:load(path) -- 1270
					if not content then -- 1271
						return { -- 1272
							success = false, -- 1272
							message = "failed to read file" -- 1272
						} -- 1272
					end -- 1271
					emit("AppWS", "Send", json.encode({ -- 1273
						name = "UpdateTSCode", -- 1273
						file = path, -- 1273
						content = content -- 1273
					})) -- 1273
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1274
						local done = false -- 1275
						do -- 1276
							local _with_0 = Node() -- 1276
							_with_0:gslot("AppWS", function(eventType, msg) -- 1277
								if eventType == "Receive" then -- 1278
									_with_0:removeFromParent() -- 1279
									local res = json.decode(msg) -- 1280
									if res then -- 1280
										if res.name == "TranspileTS" then -- 1281
											if res.success then -- 1282
												local luaFile = Path:replaceExt(path, "lua") -- 1283
												Content:save(luaFile, res.luaCode) -- 1284
												messages[#messages + 1] = { -- 1285
													success = true, -- 1285
													file = path -- 1285
												} -- 1285
											else -- 1287
												messages[#messages + 1] = { -- 1287
													success = false, -- 1287
													file = path, -- 1287
													message = res.message -- 1287
												} -- 1287
											end -- 1282
											done = true -- 1288
										end -- 1281
									end -- 1280
								end -- 1278
							end) -- 1277
						end -- 1276
						emit("AppWS", "Send", json.encode({ -- 1289
							name = "TranspileTS", -- 1289
							file = path, -- 1289
							content = content -- 1289
						})) -- 1289
						wait(function() -- 1290
							return done -- 1290
						end) -- 1290
					end -- 1274
					return { -- 1291
						success = true, -- 1291
						messages = messages -- 1291
					} -- 1291
				else -- 1293
					local files = Content:getAllFiles(path) -- 1293
					local fileData = { } -- 1294
					local messages = { } -- 1295
					for _index_0 = 1, #files do -- 1296
						local f = files[_index_0] -- 1296
						if not (_anon_func_4(f)) then -- 1297
							goto _continue_0 -- 1297
						end -- 1297
						local file = Path(path, f) -- 1298
						local content = Content:load(file) -- 1299
						if content then -- 1299
							fileData[file] = content -- 1300
							emit("AppWS", "Send", json.encode({ -- 1301
								name = "UpdateTSCode", -- 1301
								file = file, -- 1301
								content = content -- 1301
							})) -- 1301
						else -- 1303
							messages[#messages + 1] = { -- 1303
								success = false, -- 1303
								file = file, -- 1303
								message = "failed to read file" -- 1303
							} -- 1303
						end -- 1299
						::_continue_0:: -- 1297
					end -- 1296
					for file, content in pairs(fileData) do -- 1304
						if "d" == Path:getExt(Path:getName(file)) then -- 1305
							goto _continue_1 -- 1305
						end -- 1305
						local done = false -- 1306
						do -- 1307
							local _with_0 = Node() -- 1307
							_with_0:gslot("AppWS", function(eventType, msg) -- 1308
								if eventType == "Receive" then -- 1309
									_with_0:removeFromParent() -- 1310
									local res = json.decode(msg) -- 1311
									if res then -- 1311
										if res.name == "TranspileTS" then -- 1312
											if res.success then -- 1313
												local luaFile = Path:replaceExt(file, "lua") -- 1314
												Content:save(luaFile, res.luaCode) -- 1315
												messages[#messages + 1] = { -- 1316
													success = true, -- 1316
													file = file -- 1316
												} -- 1316
											else -- 1318
												messages[#messages + 1] = { -- 1318
													success = false, -- 1318
													file = file, -- 1318
													message = res.message -- 1318
												} -- 1318
											end -- 1313
											done = true -- 1319
										end -- 1312
									end -- 1311
								end -- 1309
							end) -- 1308
						end -- 1307
						emit("AppWS", "Send", json.encode({ -- 1320
							name = "TranspileTS", -- 1320
							file = file, -- 1320
							content = content -- 1320
						})) -- 1320
						wait(function() -- 1321
							return done -- 1321
						end) -- 1321
						::_continue_1:: -- 1305
					end -- 1304
					return { -- 1322
						success = true, -- 1322
						messages = messages -- 1322
					} -- 1322
				end -- 1266
			end -- 1261
		end -- 1261
	end -- 1261
	return { -- 1260
		success = false -- 1260
	} -- 1260
end) -- 1260
HttpServer:post("/download", function(req) -- 1324
	do -- 1325
		local _type_0 = type(req) -- 1325
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1325
		if _tab_0 then -- 1325
			local url -- 1325
			do -- 1325
				local _obj_0 = req.body -- 1325
				local _type_1 = type(_obj_0) -- 1325
				if "table" == _type_1 or "userdata" == _type_1 then -- 1325
					url = _obj_0.url -- 1325
				end -- 1325
			end -- 1325
			local target -- 1325
			do -- 1325
				local _obj_0 = req.body -- 1325
				local _type_1 = type(_obj_0) -- 1325
				if "table" == _type_1 or "userdata" == _type_1 then -- 1325
					target = _obj_0.target -- 1325
				end -- 1325
			end -- 1325
			if url ~= nil and target ~= nil then -- 1325
				local Entry = require("Script.Dev.Entry") -- 1326
				Entry.downloadFile(url, target) -- 1327
				return { -- 1328
					success = true -- 1328
				} -- 1328
			end -- 1325
		end -- 1325
	end -- 1325
	return { -- 1324
		success = false -- 1324
	} -- 1324
end) -- 1324
local status = { } -- 1330
_module_0 = status -- 1331
thread(function() -- 1333
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1334
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1335
	if Content:exist(doraWeb) then -- 1336
		local needReload -- 1337
		if Content:exist(doraReady) then -- 1337
			needReload = App.version ~= Content:load(doraReady) -- 1338
		else -- 1339
			needReload = true -- 1339
		end -- 1337
		if needReload then -- 1340
			Content:remove(Path(Content.appPath, ".www")) -- 1341
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1342
			Content:save(doraReady, App.version) -- 1346
			print("Dora Dora is ready!") -- 1347
		end -- 1340
	end -- 1336
	if HttpServer:start(8866) then -- 1348
		local localIP = HttpServer.localIP -- 1349
		if localIP == "" then -- 1350
			localIP = "localhost" -- 1350
		end -- 1350
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1351
		return HttpServer:startWS(8868) -- 1352
	else -- 1354
		status.url = nil -- 1354
		return print("8866 Port not available!") -- 1355
	end -- 1348
end) -- 1333
return _module_0 -- 1
