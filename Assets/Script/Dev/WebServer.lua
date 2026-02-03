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
local genAuthToken -- 22
genAuthToken = function() -- 22
	local parts = { } -- 23
	for _ = 1, 4 do -- 24
		parts[#parts + 1] = string.format("%08x", math.random(0, 0x7fffffff)) -- 25
	end -- 24
	return table.concat(parts) -- 26
end -- 22
HttpServer:post("/auth", function(req) -- 28
	local Entry = require("Script.Dev.Entry") -- 29
	local authCode = Entry.getAuthCode() -- 30
	local now = os.time() -- 31
	if now < authLockedUntil then -- 32
		return { -- 33
			success = false, -- 33
			message = "locked", -- 33
			retryAfter = authLockedUntil - now -- 33
		} -- 33
	end -- 32
	local code = nil -- 34
	do -- 36
		local _type_0 = type(req) -- 36
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 36
		if _tab_0 then -- 36
			do -- 36
				local _obj_0 = req.body -- 36
				local _type_1 = type(_obj_0) -- 36
				if "table" == _type_1 or "userdata" == _type_1 then -- 36
					code = _obj_0.code -- 36
				end -- 36
			end -- 36
			if code ~= nil then -- 36
				code = code -- 37
			end -- 36
		end -- 35
	end -- 35
	if code and tostring(code) == authCode then -- 38
		authFailedCount = 0 -- 39
		local token = genAuthToken() -- 40
		HttpServer.authToken = token -- 41
		return { -- 42
			success = true, -- 42
			token = token -- 42
		} -- 42
	else -- 44
		authFailedCount = authFailedCount + 1 -- 44
		if authFailedCount >= 3 then -- 45
			authFailedCount = 0 -- 46
			authLockedUntil = now + 30 -- 47
			return { -- 48
				success = false, -- 48
				message = "locked", -- 48
				retryAfter = 30 -- 48
			} -- 48
		end -- 45
		return { -- 49
			success = false, -- 49
			message = "invalid code" -- 49
		} -- 49
	end -- 38
end) -- 28
local LintYueGlobals, CheckTIC80Code -- 51
do -- 51
	local _obj_0 = require("Utils") -- 51
	LintYueGlobals, CheckTIC80Code = _obj_0.LintYueGlobals, _obj_0.CheckTIC80Code -- 51
end -- 51
local getProjectDirFromFile -- 53
getProjectDirFromFile = function(file) -- 53
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
HttpServer:post("/new", function(req) -- 608
	do -- 609
		local _type_0 = type(req) -- 609
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 609
		if _tab_0 then -- 609
			local path -- 609
			do -- 609
				local _obj_0 = req.body -- 609
				local _type_1 = type(_obj_0) -- 609
				if "table" == _type_1 or "userdata" == _type_1 then -- 609
					path = _obj_0.path -- 609
				end -- 609
			end -- 609
			local content -- 609
			do -- 609
				local _obj_0 = req.body -- 609
				local _type_1 = type(_obj_0) -- 609
				if "table" == _type_1 or "userdata" == _type_1 then -- 609
					content = _obj_0.content -- 609
				end -- 609
			end -- 609
			local folder -- 609
			do -- 609
				local _obj_0 = req.body -- 609
				local _type_1 = type(_obj_0) -- 609
				if "table" == _type_1 or "userdata" == _type_1 then -- 609
					folder = _obj_0.folder -- 609
				end -- 609
			end -- 609
			if path ~= nil and content ~= nil and folder ~= nil then -- 609
				if Content:exist(path) then -- 610
					return { -- 611
						success = false, -- 611
						message = "TargetExisted" -- 611
					} -- 611
				end -- 610
				local parent = Path:getPath(path) -- 612
				local files = Content:getFiles(parent) -- 613
				if folder then -- 614
					local name = Path:getFilename(path):lower() -- 615
					for _index_0 = 1, #files do -- 616
						local file = files[_index_0] -- 616
						if name == Path:getFilename(file):lower() then -- 617
							return { -- 618
								success = false, -- 618
								message = "TargetExisted" -- 618
							} -- 618
						end -- 617
					end -- 616
					if Content:mkdir(path) then -- 619
						return { -- 620
							success = true -- 620
						} -- 620
					end -- 619
				else -- 622
					local name = Path:getName(path):lower() -- 622
					for _index_0 = 1, #files do -- 623
						local file = files[_index_0] -- 623
						if name == Path:getName(file):lower() then -- 624
							local ext = Path:getExt(file) -- 625
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 626
								goto _continue_0 -- 627
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 628
								goto _continue_0 -- 629
							end -- 626
							return { -- 630
								success = false, -- 630
								message = "SourceExisted" -- 630
							} -- 630
						end -- 624
						::_continue_0:: -- 624
					end -- 623
					if Content:save(path, content) then -- 631
						return { -- 632
							success = true -- 632
						} -- 632
					end -- 631
				end -- 614
			end -- 609
		end -- 609
	end -- 609
	return { -- 608
		success = false, -- 608
		message = "Failed" -- 608
	} -- 608
end) -- 608
HttpServer:post("/delete", function(req) -- 634
	do -- 635
		local _type_0 = type(req) -- 635
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 635
		if _tab_0 then -- 635
			local path -- 635
			do -- 635
				local _obj_0 = req.body -- 635
				local _type_1 = type(_obj_0) -- 635
				if "table" == _type_1 or "userdata" == _type_1 then -- 635
					path = _obj_0.path -- 635
				end -- 635
			end -- 635
			if path ~= nil then -- 635
				if Content:exist(path) then -- 636
					local parent = Path:getPath(path) -- 637
					local files = Content:getFiles(parent) -- 638
					local name = Path:getName(path):lower() -- 639
					local ext = Path:getExt(path) -- 640
					for _index_0 = 1, #files do -- 641
						local file = files[_index_0] -- 641
						if name == Path:getName(file):lower() then -- 642
							local _exp_0 = Path:getExt(file) -- 643
							if "tl" == _exp_0 then -- 643
								if ("vs" == ext) then -- 643
									Content:remove(Path(parent, file)) -- 644
								end -- 643
							elseif "lua" == _exp_0 then -- 645
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 645
									Content:remove(Path(parent, file)) -- 646
								end -- 645
							end -- 643
						end -- 642
					end -- 641
					if Content:remove(path) then -- 647
						return { -- 648
							success = true -- 648
						} -- 648
					end -- 647
				end -- 636
			end -- 635
		end -- 635
	end -- 635
	return { -- 634
		success = false -- 634
	} -- 634
end) -- 634
HttpServer:post("/rename", function(req) -- 650
	do -- 651
		local _type_0 = type(req) -- 651
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 651
		if _tab_0 then -- 651
			local old -- 651
			do -- 651
				local _obj_0 = req.body -- 651
				local _type_1 = type(_obj_0) -- 651
				if "table" == _type_1 or "userdata" == _type_1 then -- 651
					old = _obj_0.old -- 651
				end -- 651
			end -- 651
			local new -- 651
			do -- 651
				local _obj_0 = req.body -- 651
				local _type_1 = type(_obj_0) -- 651
				if "table" == _type_1 or "userdata" == _type_1 then -- 651
					new = _obj_0.new -- 651
				end -- 651
			end -- 651
			if old ~= nil and new ~= nil then -- 651
				if Content:exist(old) and not Content:exist(new) then -- 652
					local parent = Path:getPath(new) -- 653
					local files = Content:getFiles(parent) -- 654
					if Content:isdir(old) then -- 655
						local name = Path:getFilename(new):lower() -- 656
						for _index_0 = 1, #files do -- 657
							local file = files[_index_0] -- 657
							if name == Path:getFilename(file):lower() then -- 658
								return { -- 659
									success = false -- 659
								} -- 659
							end -- 658
						end -- 657
					else -- 661
						local name = Path:getName(new):lower() -- 661
						local ext = Path:getExt(new) -- 662
						for _index_0 = 1, #files do -- 663
							local file = files[_index_0] -- 663
							if name == Path:getName(file):lower() then -- 664
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 665
									goto _continue_0 -- 666
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 667
									goto _continue_0 -- 668
								end -- 665
								return { -- 669
									success = false -- 669
								} -- 669
							end -- 664
							::_continue_0:: -- 664
						end -- 663
					end -- 655
					if Content:move(old, new) then -- 670
						local newParent = Path:getPath(new) -- 671
						parent = Path:getPath(old) -- 672
						files = Content:getFiles(parent) -- 673
						local newName = Path:getName(new) -- 674
						local oldName = Path:getName(old) -- 675
						local name = oldName:lower() -- 676
						local ext = Path:getExt(old) -- 677
						for _index_0 = 1, #files do -- 678
							local file = files[_index_0] -- 678
							if name == Path:getName(file):lower() then -- 679
								local _exp_0 = Path:getExt(file) -- 680
								if "tl" == _exp_0 then -- 680
									if ("vs" == ext) then -- 680
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 681
									end -- 680
								elseif "lua" == _exp_0 then -- 682
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 682
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 683
									end -- 682
								end -- 680
							end -- 679
						end -- 678
						return { -- 684
							success = true -- 684
						} -- 684
					end -- 670
				end -- 652
			end -- 651
		end -- 651
	end -- 651
	return { -- 650
		success = false -- 650
	} -- 650
end) -- 650
HttpServer:post("/exist", function(req) -- 686
	do -- 687
		local _type_0 = type(req) -- 687
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 687
		if _tab_0 then -- 687
			local file -- 687
			do -- 687
				local _obj_0 = req.body -- 687
				local _type_1 = type(_obj_0) -- 687
				if "table" == _type_1 or "userdata" == _type_1 then -- 687
					file = _obj_0.file -- 687
				end -- 687
			end -- 687
			if file ~= nil then -- 687
				do -- 688
					local projFile = req.body.projFile -- 688
					if projFile then -- 688
						local projDir = getProjectDirFromFile(projFile) -- 689
						if projDir then -- 689
							local scriptDir = Path(projDir, "Script") -- 690
							local searchPaths = Content.searchPaths -- 691
							if Content:exist(scriptDir) then -- 692
								Content:addSearchPath(scriptDir) -- 692
							end -- 692
							if Content:exist(projDir) then -- 693
								Content:addSearchPath(projDir) -- 693
							end -- 693
							local _ <close> = setmetatable({ }, { -- 694
								__close = function() -- 694
									Content.searchPaths = searchPaths -- 694
								end -- 694
							}) -- 694
							return { -- 695
								success = Content:exist(file) -- 695
							} -- 695
						end -- 689
					end -- 688
				end -- 688
				return { -- 696
					success = Content:exist(file) -- 696
				} -- 696
			end -- 687
		end -- 687
	end -- 687
	return { -- 686
		success = false -- 686
	} -- 686
end) -- 686
HttpServer:postSchedule("/read", function(req) -- 698
	do -- 699
		local _type_0 = type(req) -- 699
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 699
		if _tab_0 then -- 699
			local path -- 699
			do -- 699
				local _obj_0 = req.body -- 699
				local _type_1 = type(_obj_0) -- 699
				if "table" == _type_1 or "userdata" == _type_1 then -- 699
					path = _obj_0.path -- 699
				end -- 699
			end -- 699
			if path ~= nil then -- 699
				local readFile -- 700
				readFile = function() -- 700
					if Content:exist(path) then -- 701
						local content = Content:loadAsync(path) -- 702
						if content then -- 702
							return { -- 703
								content = content, -- 703
								success = true -- 703
							} -- 703
						end -- 702
					end -- 701
					return nil -- 700
				end -- 700
				do -- 704
					local projFile = req.body.projFile -- 704
					if projFile then -- 704
						local projDir = getProjectDirFromFile(projFile) -- 705
						if projDir then -- 705
							local scriptDir = Path(projDir, "Script") -- 706
							local searchPaths = Content.searchPaths -- 707
							if Content:exist(scriptDir) then -- 708
								Content:addSearchPath(scriptDir) -- 708
							end -- 708
							if Content:exist(projDir) then -- 709
								Content:addSearchPath(projDir) -- 709
							end -- 709
							local _ <close> = setmetatable({ }, { -- 710
								__close = function() -- 710
									Content.searchPaths = searchPaths -- 710
								end -- 710
							}) -- 710
							local result = readFile() -- 711
							if result then -- 711
								return result -- 711
							end -- 711
						end -- 705
					end -- 704
				end -- 704
				local result = readFile() -- 712
				if result then -- 712
					return result -- 712
				end -- 712
			end -- 699
		end -- 699
	end -- 699
	return { -- 698
		success = false -- 698
	} -- 698
end) -- 698
HttpServer:post("/read-sync", function(req) -- 714
	do -- 715
		local _type_0 = type(req) -- 715
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 715
		if _tab_0 then -- 715
			local path -- 715
			do -- 715
				local _obj_0 = req.body -- 715
				local _type_1 = type(_obj_0) -- 715
				if "table" == _type_1 or "userdata" == _type_1 then -- 715
					path = _obj_0.path -- 715
				end -- 715
			end -- 715
			local exts -- 715
			do -- 715
				local _obj_0 = req.body -- 715
				local _type_1 = type(_obj_0) -- 715
				if "table" == _type_1 or "userdata" == _type_1 then -- 715
					exts = _obj_0.exts -- 715
				end -- 715
			end -- 715
			if path ~= nil and exts ~= nil then -- 715
				local readFile -- 716
				readFile = function() -- 716
					for _index_0 = 1, #exts do -- 717
						local ext = exts[_index_0] -- 717
						local targetPath = path .. ext -- 718
						if Content:exist(targetPath) then -- 719
							local content = Content:load(targetPath) -- 720
							if content then -- 720
								return { -- 721
									content = content, -- 721
									success = true, -- 721
									fullPath = Content:getFullPath(targetPath) -- 721
								} -- 721
							end -- 720
						end -- 719
					end -- 717
					return nil -- 716
				end -- 716
				local searchPaths = Content.searchPaths -- 722
				local _ <close> = setmetatable({ }, { -- 723
					__close = function() -- 723
						Content.searchPaths = searchPaths -- 723
					end -- 723
				}) -- 723
				do -- 724
					local projFile = req.body.projFile -- 724
					if projFile then -- 724
						local projDir = getProjectDirFromFile(projFile) -- 725
						if projDir then -- 725
							local scriptDir = Path(projDir, "Script") -- 726
							if Content:exist(scriptDir) then -- 727
								Content:addSearchPath(scriptDir) -- 727
							end -- 727
							if Content:exist(projDir) then -- 728
								Content:addSearchPath(projDir) -- 728
							end -- 728
						else -- 730
							projDir = Path:getPath(projFile) -- 730
							if Content:exist(projDir) then -- 731
								Content:addSearchPath(projDir) -- 731
							end -- 731
						end -- 725
					end -- 724
				end -- 724
				local result = readFile() -- 732
				if result then -- 732
					return result -- 732
				end -- 732
			end -- 715
		end -- 715
	end -- 715
	return { -- 714
		success = false -- 714
	} -- 714
end) -- 714
local compileFileAsync -- 734
compileFileAsync = function(inputFile, sourceCodes) -- 734
	local file = inputFile -- 735
	local searchPath -- 736
	do -- 736
		local dir = getProjectDirFromFile(inputFile) -- 736
		if dir then -- 736
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 737
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 738
		else -- 740
			file = Path:getRelative(inputFile, Content.writablePath) -- 740
			if file:sub(1, 2) == ".." then -- 741
				file = Path:getRelative(inputFile, Content.assetPath) -- 742
			end -- 741
			searchPath = "" -- 743
		end -- 736
	end -- 736
	local outputFile = Path:replaceExt(inputFile, "lua") -- 744
	local yueext = yue.options.extension -- 745
	local resultCodes = nil -- 746
	do -- 747
		local _exp_0 = Path:getExt(inputFile) -- 747
		if yueext == _exp_0 then -- 747
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 748
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 749
				if not codes then -- 750
					return -- 750
				end -- 750
				local extraGlobal -- 751
				if isTIC80 then -- 751
					extraGlobal = tic80APIs -- 751
				else -- 751
					extraGlobal = nil -- 751
				end -- 751
				local success = LintYueGlobals(codes, globals, true, extraGlobal) -- 752
				if not success then -- 753
					return -- 753
				end -- 753
				if codes == "" then -- 754
					resultCodes = "" -- 755
					return nil -- 756
				end -- 754
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 757
				return resultCodes -- 758
			end, function(success) -- 749
				if not success then -- 759
					Content:remove(outputFile) -- 760
					if resultCodes == nil then -- 761
						resultCodes = false -- 762
					end -- 761
				end -- 759
			end) -- 749
		elseif "tl" == _exp_0 then -- 763
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 764
			if isTIC80 then -- 765
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 766
			end -- 765
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 767
			if codes then -- 767
				if isTIC80 then -- 768
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 769
				end -- 768
				resultCodes = codes -- 770
				Content:saveAsync(outputFile, codes) -- 771
			else -- 773
				Content:remove(outputFile) -- 773
				resultCodes = false -- 774
			end -- 767
		elseif "xml" == _exp_0 then -- 775
			local codes = xml.tolua(sourceCodes) -- 776
			if codes then -- 776
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 777
				Content:saveAsync(outputFile, resultCodes) -- 778
			else -- 780
				Content:remove(outputFile) -- 780
				resultCodes = false -- 781
			end -- 776
		end -- 747
	end -- 747
	wait(function() -- 782
		return resultCodes ~= nil -- 782
	end) -- 782
	if resultCodes then -- 783
		return resultCodes -- 783
	end -- 783
	return nil -- 734
end -- 734
HttpServer:postSchedule("/write", function(req) -- 785
	do -- 786
		local _type_0 = type(req) -- 786
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 786
		if _tab_0 then -- 786
			local path -- 786
			do -- 786
				local _obj_0 = req.body -- 786
				local _type_1 = type(_obj_0) -- 786
				if "table" == _type_1 or "userdata" == _type_1 then -- 786
					path = _obj_0.path -- 786
				end -- 786
			end -- 786
			local content -- 786
			do -- 786
				local _obj_0 = req.body -- 786
				local _type_1 = type(_obj_0) -- 786
				if "table" == _type_1 or "userdata" == _type_1 then -- 786
					content = _obj_0.content -- 786
				end -- 786
			end -- 786
			if path ~= nil and content ~= nil then -- 786
				if Content:saveAsync(path, content) then -- 787
					do -- 788
						local _exp_0 = Path:getExt(path) -- 788
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 788
							if '' == Path:getExt(Path:getName(path)) then -- 789
								local resultCodes = compileFileAsync(path, content) -- 790
								return { -- 791
									success = true, -- 791
									resultCodes = resultCodes -- 791
								} -- 791
							end -- 789
						end -- 788
					end -- 788
					return { -- 792
						success = true -- 792
					} -- 792
				end -- 787
			end -- 786
		end -- 786
	end -- 786
	return { -- 785
		success = false -- 785
	} -- 785
end) -- 785
HttpServer:postSchedule("/build", function(req) -- 794
	do -- 795
		local _type_0 = type(req) -- 795
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 795
		if _tab_0 then -- 795
			local path -- 795
			do -- 795
				local _obj_0 = req.body -- 795
				local _type_1 = type(_obj_0) -- 795
				if "table" == _type_1 or "userdata" == _type_1 then -- 795
					path = _obj_0.path -- 795
				end -- 795
			end -- 795
			if path ~= nil then -- 795
				local _exp_0 = Path:getExt(path) -- 796
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 796
					if '' == Path:getExt(Path:getName(path)) then -- 797
						local content = Content:loadAsync(path) -- 798
						if content then -- 798
							local resultCodes = compileFileAsync(path, content) -- 799
							if resultCodes then -- 799
								return { -- 800
									success = true, -- 800
									resultCodes = resultCodes -- 800
								} -- 800
							end -- 799
						end -- 798
					end -- 797
				end -- 796
			end -- 795
		end -- 795
	end -- 795
	return { -- 794
		success = false -- 794
	} -- 794
end) -- 794
local extentionLevels = { -- 803
	vs = 2, -- 803
	bl = 2, -- 804
	ts = 1, -- 805
	tsx = 1, -- 806
	tl = 1, -- 807
	yue = 1, -- 808
	xml = 1, -- 809
	lua = 0 -- 810
} -- 802
HttpServer:post("/assets", function() -- 812
	local Entry = require("Script.Dev.Entry") -- 815
	local engineDev = Entry.getEngineDev() -- 816
	local visitAssets -- 817
	visitAssets = function(path, tag) -- 817
		local isWorkspace = tag == "Workspace" -- 818
		local builtin -- 819
		if tag == "Builtin" then -- 819
			builtin = true -- 819
		else -- 819
			builtin = nil -- 819
		end -- 819
		local children = nil -- 820
		local dirs = Content:getDirs(path) -- 821
		for _index_0 = 1, #dirs do -- 822
			local dir = dirs[_index_0] -- 822
			if isWorkspace then -- 823
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 824
					goto _continue_0 -- 825
				end -- 824
			elseif dir == ".git" then -- 826
				goto _continue_0 -- 827
			end -- 823
			if not children then -- 828
				children = { } -- 828
			end -- 828
			children[#children + 1] = visitAssets(Path(path, dir)) -- 829
			::_continue_0:: -- 823
		end -- 822
		local files = Content:getFiles(path) -- 830
		local names = { } -- 831
		for _index_0 = 1, #files do -- 832
			local file = files[_index_0] -- 832
			if file:match("^%.") then -- 833
				goto _continue_1 -- 833
			end -- 833
			local name = Path:getName(file) -- 834
			local ext = names[name] -- 835
			if ext then -- 835
				local lv1 -- 836
				do -- 836
					local _exp_0 = extentionLevels[ext] -- 836
					if _exp_0 ~= nil then -- 836
						lv1 = _exp_0 -- 836
					else -- 836
						lv1 = -1 -- 836
					end -- 836
				end -- 836
				ext = Path:getExt(file) -- 837
				local lv2 -- 838
				do -- 838
					local _exp_0 = extentionLevels[ext] -- 838
					if _exp_0 ~= nil then -- 838
						lv2 = _exp_0 -- 838
					else -- 838
						lv2 = -1 -- 838
					end -- 838
				end -- 838
				if lv2 > lv1 then -- 839
					names[name] = ext -- 840
				elseif lv2 == lv1 then -- 841
					names[name .. '.' .. ext] = "" -- 842
				end -- 839
			else -- 844
				ext = Path:getExt(file) -- 844
				if not extentionLevels[ext] then -- 845
					names[file] = "" -- 846
				else -- 848
					names[name] = ext -- 848
				end -- 845
			end -- 835
			::_continue_1:: -- 833
		end -- 832
		do -- 849
			local _accum_0 = { } -- 849
			local _len_0 = 1 -- 849
			for name, ext in pairs(names) do -- 849
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 849
				_len_0 = _len_0 + 1 -- 849
			end -- 849
			files = _accum_0 -- 849
		end -- 849
		for _index_0 = 1, #files do -- 850
			local file = files[_index_0] -- 850
			if not children then -- 851
				children = { } -- 851
			end -- 851
			children[#children + 1] = { -- 853
				key = Path(path, file), -- 853
				dir = false, -- 854
				title = file, -- 855
				builtin = builtin -- 856
			} -- 852
		end -- 850
		if children then -- 858
			table.sort(children, function(a, b) -- 859
				if a.dir == b.dir then -- 860
					return a.title < b.title -- 861
				else -- 863
					return a.dir -- 863
				end -- 860
			end) -- 859
		end -- 858
		if isWorkspace and children then -- 864
			return children -- 865
		else -- 867
			return { -- 868
				key = path, -- 868
				dir = true, -- 869
				title = Path:getFilename(path), -- 870
				builtin = builtin, -- 871
				children = children -- 872
			} -- 867
		end -- 864
	end -- 817
	local zh = (App.locale:match("^zh") ~= nil) -- 874
	return { -- 876
		key = Content.writablePath, -- 876
		dir = true, -- 877
		root = true, -- 878
		title = "Assets", -- 879
		children = (function() -- 881
			local _tab_0 = { -- 881
				{ -- 882
					key = Path(Content.assetPath), -- 882
					dir = true, -- 883
					builtin = true, -- 884
					title = zh and "内置资源" or "Built-in", -- 885
					children = { -- 887
						(function() -- 887
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 887
							_with_0.title = zh and "说明文档" or "Readme" -- 888
							return _with_0 -- 887
						end)(), -- 887
						(function() -- 889
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 889
							_with_0.title = zh and "接口文档" or "API Doc" -- 890
							return _with_0 -- 889
						end)(), -- 889
						(function() -- 891
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 891
							_with_0.title = zh and "开发工具" or "Tools" -- 892
							return _with_0 -- 891
						end)(), -- 891
						(function() -- 893
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 893
							_with_0.title = zh and "字体" or "Font" -- 894
							return _with_0 -- 893
						end)(), -- 893
						(function() -- 895
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 895
							_with_0.title = zh and "程序库" or "Lib" -- 896
							if engineDev then -- 897
								local _list_0 = _with_0.children -- 898
								for _index_0 = 1, #_list_0 do -- 898
									local child = _list_0[_index_0] -- 898
									if not (child.title == "Dora") then -- 899
										goto _continue_0 -- 899
									end -- 899
									local title = zh and "zh-Hans" or "en" -- 900
									do -- 901
										local _accum_0 = { } -- 901
										local _len_0 = 1 -- 901
										local _list_1 = child.children -- 901
										for _index_1 = 1, #_list_1 do -- 901
											local c = _list_1[_index_1] -- 901
											if c.title ~= title then -- 901
												_accum_0[_len_0] = c -- 901
												_len_0 = _len_0 + 1 -- 901
											end -- 901
										end -- 901
										child.children = _accum_0 -- 901
									end -- 901
									break -- 902
									::_continue_0:: -- 899
								end -- 898
							else -- 904
								local _accum_0 = { } -- 904
								local _len_0 = 1 -- 904
								local _list_0 = _with_0.children -- 904
								for _index_0 = 1, #_list_0 do -- 904
									local child = _list_0[_index_0] -- 904
									if child.title ~= "Dora" then -- 904
										_accum_0[_len_0] = child -- 904
										_len_0 = _len_0 + 1 -- 904
									end -- 904
								end -- 904
								_with_0.children = _accum_0 -- 904
							end -- 897
							return _with_0 -- 895
						end)(), -- 895
						(function() -- 905
							if engineDev then -- 905
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 906
								local _obj_0 = _with_0.children -- 907
								_obj_0[#_obj_0 + 1] = { -- 908
									key = Path(Content.assetPath, "Script", "init.yue"), -- 908
									dir = false, -- 909
									builtin = true, -- 910
									title = "init.yue" -- 911
								} -- 907
								return _with_0 -- 906
							end -- 905
						end)() -- 905
					} -- 886
				} -- 881
			} -- 915
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 915
			local _idx_0 = #_tab_0 + 1 -- 915
			for _index_0 = 1, #_obj_0 do -- 915
				local _value_0 = _obj_0[_index_0] -- 915
				_tab_0[_idx_0] = _value_0 -- 915
				_idx_0 = _idx_0 + 1 -- 915
			end -- 915
			return _tab_0 -- 881
		end)() -- 880
	} -- 875
end) -- 812
HttpServer:postSchedule("/run", function(req) -- 919
	do -- 920
		local _type_0 = type(req) -- 920
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 920
		if _tab_0 then -- 920
			local file -- 920
			do -- 920
				local _obj_0 = req.body -- 920
				local _type_1 = type(_obj_0) -- 920
				if "table" == _type_1 or "userdata" == _type_1 then -- 920
					file = _obj_0.file -- 920
				end -- 920
			end -- 920
			local asProj -- 920
			do -- 920
				local _obj_0 = req.body -- 920
				local _type_1 = type(_obj_0) -- 920
				if "table" == _type_1 or "userdata" == _type_1 then -- 920
					asProj = _obj_0.asProj -- 920
				end -- 920
			end -- 920
			if file ~= nil and asProj ~= nil then -- 920
				if not Content:isAbsolutePath(file) then -- 921
					local devFile = Path(Content.writablePath, file) -- 922
					if Content:exist(devFile) then -- 923
						file = devFile -- 923
					end -- 923
				end -- 921
				local Entry = require("Script.Dev.Entry") -- 924
				local workDir -- 925
				if asProj then -- 926
					workDir = getProjectDirFromFile(file) -- 927
					if workDir then -- 927
						Entry.allClear() -- 928
						local target = Path(workDir, "init") -- 929
						local success, err = Entry.enterEntryAsync({ -- 930
							entryName = "Project", -- 930
							fileName = target -- 930
						}) -- 930
						target = Path:getName(Path:getPath(target)) -- 931
						return { -- 932
							success = success, -- 932
							target = target, -- 932
							err = err -- 932
						} -- 932
					end -- 927
				else -- 934
					workDir = getProjectDirFromFile(file) -- 934
				end -- 926
				Entry.allClear() -- 935
				file = Path:replaceExt(file, "") -- 936
				local success, err = Entry.enterEntryAsync({ -- 938
					entryName = Path:getName(file), -- 938
					fileName = file, -- 939
					workDir = workDir -- 940
				}) -- 937
				return { -- 941
					success = success, -- 941
					err = err -- 941
				} -- 941
			end -- 920
		end -- 920
	end -- 920
	return { -- 919
		success = false -- 919
	} -- 919
end) -- 919
HttpServer:postSchedule("/stop", function() -- 943
	local Entry = require("Script.Dev.Entry") -- 944
	return { -- 945
		success = Entry.stop() -- 945
	} -- 945
end) -- 943
local minifyAsync -- 947
minifyAsync = function(sourcePath, minifyPath) -- 947
	if not Content:exist(sourcePath) then -- 948
		return -- 948
	end -- 948
	local Entry = require("Script.Dev.Entry") -- 949
	local errors = { } -- 950
	local files = Entry.getAllFiles(sourcePath, { -- 951
		"lua" -- 951
	}, true) -- 951
	do -- 952
		local _accum_0 = { } -- 952
		local _len_0 = 1 -- 952
		for _index_0 = 1, #files do -- 952
			local file = files[_index_0] -- 952
			if file:sub(1, 1) ~= '.' then -- 952
				_accum_0[_len_0] = file -- 952
				_len_0 = _len_0 + 1 -- 952
			end -- 952
		end -- 952
		files = _accum_0 -- 952
	end -- 952
	local paths -- 953
	do -- 953
		local _tbl_0 = { } -- 953
		for _index_0 = 1, #files do -- 953
			local file = files[_index_0] -- 953
			_tbl_0[Path:getPath(file)] = true -- 953
		end -- 953
		paths = _tbl_0 -- 953
	end -- 953
	for path in pairs(paths) do -- 954
		Content:mkdir(Path(minifyPath, path)) -- 954
	end -- 954
	local _ <close> = setmetatable({ }, { -- 955
		__close = function() -- 955
			package.loaded["luaminify.FormatMini"] = nil -- 956
			package.loaded["luaminify.ParseLua"] = nil -- 957
			package.loaded["luaminify.Scope"] = nil -- 958
			package.loaded["luaminify.Util"] = nil -- 959
		end -- 955
	}) -- 955
	local FormatMini -- 960
	do -- 960
		local _obj_0 = require("luaminify") -- 960
		FormatMini = _obj_0.FormatMini -- 960
	end -- 960
	local fileCount = #files -- 961
	local count = 0 -- 962
	for _index_0 = 1, #files do -- 963
		local file = files[_index_0] -- 963
		thread(function() -- 964
			local _ <close> = setmetatable({ }, { -- 965
				__close = function() -- 965
					count = count + 1 -- 965
				end -- 965
			}) -- 965
			local input = Path(sourcePath, file) -- 966
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 967
			if Content:exist(input) then -- 968
				local sourceCodes = Content:loadAsync(input) -- 969
				local res, err = FormatMini(sourceCodes) -- 970
				if res then -- 971
					Content:saveAsync(output, res) -- 972
					return print("Minify " .. tostring(file)) -- 973
				else -- 975
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 975
				end -- 971
			else -- 977
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 977
			end -- 968
		end) -- 964
		sleep() -- 978
	end -- 963
	wait(function() -- 979
		return count == fileCount -- 979
	end) -- 979
	if #errors > 0 then -- 980
		print(table.concat(errors, '\n')) -- 981
	end -- 980
	print("Obfuscation done.") -- 982
	return files -- 983
end -- 947
local zipping = false -- 985
HttpServer:postSchedule("/zip", function(req) -- 987
	do -- 988
		local _type_0 = type(req) -- 988
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 988
		if _tab_0 then -- 988
			local path -- 988
			do -- 988
				local _obj_0 = req.body -- 988
				local _type_1 = type(_obj_0) -- 988
				if "table" == _type_1 or "userdata" == _type_1 then -- 988
					path = _obj_0.path -- 988
				end -- 988
			end -- 988
			local zipFile -- 988
			do -- 988
				local _obj_0 = req.body -- 988
				local _type_1 = type(_obj_0) -- 988
				if "table" == _type_1 or "userdata" == _type_1 then -- 988
					zipFile = _obj_0.zipFile -- 988
				end -- 988
			end -- 988
			local obfuscated -- 988
			do -- 988
				local _obj_0 = req.body -- 988
				local _type_1 = type(_obj_0) -- 988
				if "table" == _type_1 or "userdata" == _type_1 then -- 988
					obfuscated = _obj_0.obfuscated -- 988
				end -- 988
			end -- 988
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 988
				if zipping then -- 989
					goto failed -- 989
				end -- 989
				zipping = true -- 990
				local _ <close> = setmetatable({ }, { -- 991
					__close = function() -- 991
						zipping = false -- 991
					end -- 991
				}) -- 991
				if not Content:exist(path) then -- 992
					goto failed -- 992
				end -- 992
				Content:mkdir(Path:getPath(zipFile)) -- 993
				if obfuscated then -- 994
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 995
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 996
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 997
					Content:remove(scriptPath) -- 998
					Content:remove(obfuscatedPath) -- 999
					Content:remove(tempPath) -- 1000
					Content:mkdir(scriptPath) -- 1001
					Content:mkdir(obfuscatedPath) -- 1002
					Content:mkdir(tempPath) -- 1003
					if not Content:copyAsync(path, tempPath) then -- 1004
						goto failed -- 1004
					end -- 1004
					local Entry = require("Script.Dev.Entry") -- 1005
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1006
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1007
						"tl", -- 1007
						"yue", -- 1007
						"lua", -- 1007
						"ts", -- 1007
						"tsx", -- 1007
						"vs", -- 1007
						"bl", -- 1007
						"xml", -- 1007
						"wa", -- 1007
						"mod" -- 1007
					}, true) -- 1007
					for _index_0 = 1, #scriptFiles do -- 1008
						local file = scriptFiles[_index_0] -- 1008
						Content:remove(Path(tempPath, file)) -- 1009
					end -- 1008
					for _index_0 = 1, #luaFiles do -- 1010
						local file = luaFiles[_index_0] -- 1010
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1011
					end -- 1010
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1012
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1013
					end) then -- 1012
						goto failed -- 1012
					end -- 1012
					return { -- 1014
						success = true -- 1014
					} -- 1014
				else -- 1016
					return { -- 1016
						success = Content:zipAsync(path, zipFile, function(file) -- 1016
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1017
						end) -- 1016
					} -- 1016
				end -- 994
			end -- 988
		end -- 988
	end -- 988
	::failed:: -- 1018
	return { -- 987
		success = false -- 987
	} -- 987
end) -- 987
HttpServer:postSchedule("/unzip", function(req) -- 1020
	do -- 1021
		local _type_0 = type(req) -- 1021
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1021
		if _tab_0 then -- 1021
			local zipFile -- 1021
			do -- 1021
				local _obj_0 = req.body -- 1021
				local _type_1 = type(_obj_0) -- 1021
				if "table" == _type_1 or "userdata" == _type_1 then -- 1021
					zipFile = _obj_0.zipFile -- 1021
				end -- 1021
			end -- 1021
			local path -- 1021
			do -- 1021
				local _obj_0 = req.body -- 1021
				local _type_1 = type(_obj_0) -- 1021
				if "table" == _type_1 or "userdata" == _type_1 then -- 1021
					path = _obj_0.path -- 1021
				end -- 1021
			end -- 1021
			if zipFile ~= nil and path ~= nil then -- 1021
				return { -- 1022
					success = Content:unzipAsync(zipFile, path, function(file) -- 1022
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1023
					end) -- 1022
				} -- 1022
			end -- 1021
		end -- 1021
	end -- 1021
	return { -- 1020
		success = false -- 1020
	} -- 1020
end) -- 1020
HttpServer:post("/editing-info", function(req) -- 1025
	local Entry = require("Script.Dev.Entry") -- 1026
	local config = Entry.getConfig() -- 1027
	local _type_0 = type(req) -- 1028
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1028
	local _match_0 = false -- 1028
	if _tab_0 then -- 1028
		local editingInfo -- 1028
		do -- 1028
			local _obj_0 = req.body -- 1028
			local _type_1 = type(_obj_0) -- 1028
			if "table" == _type_1 or "userdata" == _type_1 then -- 1028
				editingInfo = _obj_0.editingInfo -- 1028
			end -- 1028
		end -- 1028
		if editingInfo ~= nil then -- 1028
			_match_0 = true -- 1028
			config.editingInfo = editingInfo -- 1029
			return { -- 1030
				success = true -- 1030
			} -- 1030
		end -- 1028
	end -- 1028
	if not _match_0 then -- 1028
		if not (config.editingInfo ~= nil) then -- 1032
			local folder -- 1033
			if App.locale:match('^zh') then -- 1033
				folder = 'zh-Hans' -- 1033
			else -- 1033
				folder = 'en' -- 1033
			end -- 1033
			config.editingInfo = json.encode({ -- 1035
				index = 0, -- 1035
				files = { -- 1037
					{ -- 1038
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1038
						title = "welcome.md" -- 1039
					} -- 1037
				} -- 1036
			}) -- 1034
		end -- 1032
		return { -- 1043
			success = true, -- 1043
			editingInfo = config.editingInfo -- 1043
		} -- 1043
	end -- 1028
end) -- 1025
HttpServer:post("/command", function(req) -- 1045
	do -- 1046
		local _type_0 = type(req) -- 1046
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1046
		if _tab_0 then -- 1046
			local code -- 1046
			do -- 1046
				local _obj_0 = req.body -- 1046
				local _type_1 = type(_obj_0) -- 1046
				if "table" == _type_1 or "userdata" == _type_1 then -- 1046
					code = _obj_0.code -- 1046
				end -- 1046
			end -- 1046
			local log -- 1046
			do -- 1046
				local _obj_0 = req.body -- 1046
				local _type_1 = type(_obj_0) -- 1046
				if "table" == _type_1 or "userdata" == _type_1 then -- 1046
					log = _obj_0.log -- 1046
				end -- 1046
			end -- 1046
			if code ~= nil and log ~= nil then -- 1046
				emit("AppCommand", code, log) -- 1047
				return { -- 1048
					success = true -- 1048
				} -- 1048
			end -- 1046
		end -- 1046
	end -- 1046
	return { -- 1045
		success = false -- 1045
	} -- 1045
end) -- 1045
HttpServer:post("/log/save", function() -- 1050
	local folder = ".download" -- 1051
	local fullLogFile = "dora_full_logs.txt" -- 1052
	local fullFolder = Path(Content.writablePath, folder) -- 1053
	Content:mkdir(fullFolder) -- 1054
	local logPath = Path(fullFolder, fullLogFile) -- 1055
	if App:saveLog(logPath) then -- 1056
		return { -- 1057
			success = true, -- 1057
			path = Path(folder, fullLogFile) -- 1057
		} -- 1057
	end -- 1056
	return { -- 1050
		success = false -- 1050
	} -- 1050
end) -- 1050
HttpServer:post("/yarn/check", function(req) -- 1059
	local yarncompile = require("yarncompile") -- 1060
	do -- 1061
		local _type_0 = type(req) -- 1061
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1061
		if _tab_0 then -- 1061
			local code -- 1061
			do -- 1061
				local _obj_0 = req.body -- 1061
				local _type_1 = type(_obj_0) -- 1061
				if "table" == _type_1 or "userdata" == _type_1 then -- 1061
					code = _obj_0.code -- 1061
				end -- 1061
			end -- 1061
			if code ~= nil then -- 1061
				local jsonObject = json.decode(code) -- 1062
				if jsonObject then -- 1062
					local errors = { } -- 1063
					local _list_0 = jsonObject.nodes -- 1064
					for _index_0 = 1, #_list_0 do -- 1064
						local node = _list_0[_index_0] -- 1064
						local title, body = node.title, node.body -- 1065
						local luaCode, err = yarncompile(body) -- 1066
						if not luaCode then -- 1066
							errors[#errors + 1] = title .. ":" .. err -- 1067
						end -- 1066
					end -- 1064
					return { -- 1068
						success = true, -- 1068
						syntaxError = table.concat(errors, "\n\n") -- 1068
					} -- 1068
				end -- 1062
			end -- 1061
		end -- 1061
	end -- 1061
	return { -- 1059
		success = false -- 1059
	} -- 1059
end) -- 1059
HttpServer:post("/yarn/check-file", function(req) -- 1070
	local yarncompile = require("yarncompile") -- 1071
	do -- 1072
		local _type_0 = type(req) -- 1072
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1072
		if _tab_0 then -- 1072
			local code -- 1072
			do -- 1072
				local _obj_0 = req.body -- 1072
				local _type_1 = type(_obj_0) -- 1072
				if "table" == _type_1 or "userdata" == _type_1 then -- 1072
					code = _obj_0.code -- 1072
				end -- 1072
			end -- 1072
			if code ~= nil then -- 1072
				local res, _, err = yarncompile(code, true) -- 1073
				if not res then -- 1073
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1074
					return { -- 1075
						success = false, -- 1075
						message = message, -- 1075
						line = line, -- 1075
						column = column, -- 1075
						node = node -- 1075
					} -- 1075
				end -- 1073
			end -- 1072
		end -- 1072
	end -- 1072
	return { -- 1070
		success = true -- 1070
	} -- 1070
end) -- 1070
local getWaProjectDirFromFile -- 1077
getWaProjectDirFromFile = function(file) -- 1077
	local writablePath = Content.writablePath -- 1078
	local parent, current -- 1079
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1079
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1080
	else -- 1082
		parent, current = nil, nil -- 1082
	end -- 1079
	if not current then -- 1083
		return nil -- 1083
	end -- 1083
	repeat -- 1084
		current = Path:getPath(current) -- 1085
		if current == "" then -- 1086
			break -- 1086
		end -- 1086
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1087
		for _index_0 = 1, #_list_0 do -- 1087
			local f = _list_0[_index_0] -- 1087
			if Path:getFilename(f):lower() == "wa.mod" then -- 1088
				return Path(parent, current, Path:getPath(f)) -- 1089
			end -- 1088
		end -- 1087
	until false -- 1084
	return nil -- 1091
end -- 1077
HttpServer:postSchedule("/wa/build", function(req) -- 1093
	do -- 1094
		local _type_0 = type(req) -- 1094
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1094
		if _tab_0 then -- 1094
			local path -- 1094
			do -- 1094
				local _obj_0 = req.body -- 1094
				local _type_1 = type(_obj_0) -- 1094
				if "table" == _type_1 or "userdata" == _type_1 then -- 1094
					path = _obj_0.path -- 1094
				end -- 1094
			end -- 1094
			if path ~= nil then -- 1094
				local projDir = getWaProjectDirFromFile(path) -- 1095
				if projDir then -- 1095
					local message = Wasm:buildWaAsync(projDir) -- 1096
					if message == "" then -- 1097
						return { -- 1098
							success = true -- 1098
						} -- 1098
					else -- 1100
						return { -- 1100
							success = false, -- 1100
							message = message -- 1100
						} -- 1100
					end -- 1097
				else -- 1102
					return { -- 1102
						success = false, -- 1102
						message = 'Wa file needs a project' -- 1102
					} -- 1102
				end -- 1095
			end -- 1094
		end -- 1094
	end -- 1094
	return { -- 1103
		success = false, -- 1103
		message = 'failed to build' -- 1103
	} -- 1103
end) -- 1093
HttpServer:postSchedule("/wa/format", function(req) -- 1105
	do -- 1106
		local _type_0 = type(req) -- 1106
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1106
		if _tab_0 then -- 1106
			local file -- 1106
			do -- 1106
				local _obj_0 = req.body -- 1106
				local _type_1 = type(_obj_0) -- 1106
				if "table" == _type_1 or "userdata" == _type_1 then -- 1106
					file = _obj_0.file -- 1106
				end -- 1106
			end -- 1106
			if file ~= nil then -- 1106
				local code = Wasm:formatWaAsync(file) -- 1107
				if code == "" then -- 1108
					return { -- 1109
						success = false -- 1109
					} -- 1109
				else -- 1111
					return { -- 1111
						success = true, -- 1111
						code = code -- 1111
					} -- 1111
				end -- 1108
			end -- 1106
		end -- 1106
	end -- 1106
	return { -- 1112
		success = false -- 1112
	} -- 1112
end) -- 1105
HttpServer:postSchedule("/wa/create", function(req) -- 1114
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
			if path ~= nil then -- 1115
				if not Content:exist(Path:getPath(path)) then -- 1116
					return { -- 1117
						success = false, -- 1117
						message = "target path not existed" -- 1117
					} -- 1117
				end -- 1116
				if Content:exist(path) then -- 1118
					return { -- 1119
						success = false, -- 1119
						message = "target project folder existed" -- 1119
					} -- 1119
				end -- 1118
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1120
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1121
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1122
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1123
					return { -- 1126
						success = false, -- 1126
						message = "missing template project" -- 1126
					} -- 1126
				end -- 1123
				if not Content:mkdir(path) then -- 1127
					return { -- 1128
						success = false, -- 1128
						message = "failed to create project folder" -- 1128
					} -- 1128
				end -- 1127
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1129
					Content:remove(path) -- 1130
					return { -- 1131
						success = false, -- 1131
						message = "failed to copy template" -- 1131
					} -- 1131
				end -- 1129
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1132
					Content:remove(path) -- 1133
					return { -- 1134
						success = false, -- 1134
						message = "failed to copy template" -- 1134
					} -- 1134
				end -- 1132
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1135
					Content:remove(path) -- 1136
					return { -- 1137
						success = false, -- 1137
						message = "failed to copy template" -- 1137
					} -- 1137
				end -- 1135
				return { -- 1138
					success = true -- 1138
				} -- 1138
			end -- 1115
		end -- 1115
	end -- 1115
	return { -- 1114
		success = false, -- 1114
		message = "invalid call" -- 1114
	} -- 1114
end) -- 1114
local _anon_func_3 = function(path) -- 1147
	local _val_0 = Path:getExt(path) -- 1147
	return "ts" == _val_0 or "tsx" == _val_0 -- 1147
end -- 1147
local _anon_func_4 = function(f) -- 1177
	local _val_0 = Path:getExt(f) -- 1177
	return "ts" == _val_0 or "tsx" == _val_0 -- 1177
end -- 1177
HttpServer:postSchedule("/ts/build", function(req) -- 1140
	do -- 1141
		local _type_0 = type(req) -- 1141
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1141
		if _tab_0 then -- 1141
			local path -- 1141
			do -- 1141
				local _obj_0 = req.body -- 1141
				local _type_1 = type(_obj_0) -- 1141
				if "table" == _type_1 or "userdata" == _type_1 then -- 1141
					path = _obj_0.path -- 1141
				end -- 1141
			end -- 1141
			if path ~= nil then -- 1141
				if HttpServer.wsConnectionCount == 0 then -- 1142
					return { -- 1143
						success = false, -- 1143
						message = "Web IDE not connected" -- 1143
					} -- 1143
				end -- 1142
				if not Content:exist(path) then -- 1144
					return { -- 1145
						success = false, -- 1145
						message = "path not existed" -- 1145
					} -- 1145
				end -- 1144
				if not Content:isdir(path) then -- 1146
					if not (_anon_func_3(path)) then -- 1147
						return { -- 1148
							success = false, -- 1148
							message = "expecting a TypeScript file" -- 1148
						} -- 1148
					end -- 1147
					local messages = { } -- 1149
					local content = Content:load(path) -- 1150
					if not content then -- 1151
						return { -- 1152
							success = false, -- 1152
							message = "failed to read file" -- 1152
						} -- 1152
					end -- 1151
					emit("AppWS", "Send", json.encode({ -- 1153
						name = "UpdateTSCode", -- 1153
						file = path, -- 1153
						content = content -- 1153
					})) -- 1153
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1154
						local done = false -- 1155
						do -- 1156
							local _with_0 = Node() -- 1156
							_with_0:gslot("AppWS", function(eventType, msg) -- 1157
								if eventType == "Receive" then -- 1158
									_with_0:removeFromParent() -- 1159
									local res = json.decode(msg) -- 1160
									if res then -- 1160
										if res.name == "TranspileTS" then -- 1161
											if res.success then -- 1162
												local luaFile = Path:replaceExt(path, "lua") -- 1163
												Content:save(luaFile, res.luaCode) -- 1164
												messages[#messages + 1] = { -- 1165
													success = true, -- 1165
													file = path -- 1165
												} -- 1165
											else -- 1167
												messages[#messages + 1] = { -- 1167
													success = false, -- 1167
													file = path, -- 1167
													message = res.message -- 1167
												} -- 1167
											end -- 1162
											done = true -- 1168
										end -- 1161
									end -- 1160
								end -- 1158
							end) -- 1157
						end -- 1156
						emit("AppWS", "Send", json.encode({ -- 1169
							name = "TranspileTS", -- 1169
							file = path, -- 1169
							content = content -- 1169
						})) -- 1169
						wait(function() -- 1170
							return done -- 1170
						end) -- 1170
					end -- 1154
					return { -- 1171
						success = true, -- 1171
						messages = messages -- 1171
					} -- 1171
				else -- 1173
					local files = Content:getAllFiles(path) -- 1173
					local fileData = { } -- 1174
					local messages = { } -- 1175
					for _index_0 = 1, #files do -- 1176
						local f = files[_index_0] -- 1176
						if not (_anon_func_4(f)) then -- 1177
							goto _continue_0 -- 1177
						end -- 1177
						local file = Path(path, f) -- 1178
						local content = Content:load(file) -- 1179
						if content then -- 1179
							fileData[file] = content -- 1180
							emit("AppWS", "Send", json.encode({ -- 1181
								name = "UpdateTSCode", -- 1181
								file = file, -- 1181
								content = content -- 1181
							})) -- 1181
						else -- 1183
							messages[#messages + 1] = { -- 1183
								success = false, -- 1183
								file = file, -- 1183
								message = "failed to read file" -- 1183
							} -- 1183
						end -- 1179
						::_continue_0:: -- 1177
					end -- 1176
					for file, content in pairs(fileData) do -- 1184
						if "d" == Path:getExt(Path:getName(file)) then -- 1185
							goto _continue_1 -- 1185
						end -- 1185
						local done = false -- 1186
						do -- 1187
							local _with_0 = Node() -- 1187
							_with_0:gslot("AppWS", function(eventType, msg) -- 1188
								if eventType == "Receive" then -- 1189
									_with_0:removeFromParent() -- 1190
									local res = json.decode(msg) -- 1191
									if res then -- 1191
										if res.name == "TranspileTS" then -- 1192
											if res.success then -- 1193
												local luaFile = Path:replaceExt(file, "lua") -- 1194
												Content:save(luaFile, res.luaCode) -- 1195
												messages[#messages + 1] = { -- 1196
													success = true, -- 1196
													file = file -- 1196
												} -- 1196
											else -- 1198
												messages[#messages + 1] = { -- 1198
													success = false, -- 1198
													file = file, -- 1198
													message = res.message -- 1198
												} -- 1198
											end -- 1193
											done = true -- 1199
										end -- 1192
									end -- 1191
								end -- 1189
							end) -- 1188
						end -- 1187
						emit("AppWS", "Send", json.encode({ -- 1200
							name = "TranspileTS", -- 1200
							file = file, -- 1200
							content = content -- 1200
						})) -- 1200
						wait(function() -- 1201
							return done -- 1201
						end) -- 1201
						::_continue_1:: -- 1185
					end -- 1184
					return { -- 1202
						success = true, -- 1202
						messages = messages -- 1202
					} -- 1202
				end -- 1146
			end -- 1141
		end -- 1141
	end -- 1141
	return { -- 1140
		success = false -- 1140
	} -- 1140
end) -- 1140
HttpServer:post("/download", function(req) -- 1204
	do -- 1205
		local _type_0 = type(req) -- 1205
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1205
		if _tab_0 then -- 1205
			local url -- 1205
			do -- 1205
				local _obj_0 = req.body -- 1205
				local _type_1 = type(_obj_0) -- 1205
				if "table" == _type_1 or "userdata" == _type_1 then -- 1205
					url = _obj_0.url -- 1205
				end -- 1205
			end -- 1205
			local target -- 1205
			do -- 1205
				local _obj_0 = req.body -- 1205
				local _type_1 = type(_obj_0) -- 1205
				if "table" == _type_1 or "userdata" == _type_1 then -- 1205
					target = _obj_0.target -- 1205
				end -- 1205
			end -- 1205
			if url ~= nil and target ~= nil then -- 1205
				local Entry = require("Script.Dev.Entry") -- 1206
				Entry.downloadFile(url, target) -- 1207
				return { -- 1208
					success = true -- 1208
				} -- 1208
			end -- 1205
		end -- 1205
	end -- 1205
	return { -- 1204
		success = false -- 1204
	} -- 1204
end) -- 1204
local status = { } -- 1210
_module_0 = status -- 1211
thread(function() -- 1213
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1214
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1215
	if Content:exist(doraWeb) then -- 1216
		local needReload -- 1217
		if Content:exist(doraReady) then -- 1217
			needReload = App.version ~= Content:load(doraReady) -- 1218
		else -- 1219
			needReload = true -- 1219
		end -- 1217
		if needReload then -- 1220
			Content:remove(Path(Content.appPath, ".www")) -- 1221
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1222
			Content:save(doraReady, App.version) -- 1226
			print("Dora Dora is ready!") -- 1227
		end -- 1220
	end -- 1216
	if HttpServer:start(8866) then -- 1228
		local localIP = HttpServer.localIP -- 1229
		if localIP == "" then -- 1230
			localIP = "localhost" -- 1230
		end -- 1230
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1231
		return HttpServer:startWS(8868) -- 1232
	else -- 1234
		status.url = nil -- 1234
		return print("8866 Port not available!") -- 1235
	end -- 1228
end) -- 1213
return _module_0 -- 1
