-- [yue]: Script/Dev/WebServer.yue
local _module_0 = nil -- 1
local _ENV = Dora -- 9
local HttpServer <const> = HttpServer -- 10
local Path <const> = Path -- 10
local Content <const> = Content -- 10
local require <const> = require -- 10
local yue <const> = yue -- 10
local tostring <const> = tostring -- 10
local load <const> = load -- 10
local tonumber <const> = tonumber -- 10
local teal <const> = teal -- 10
local type <const> = type -- 10
local xml <const> = xml -- 10
local table <const> = table -- 10
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
local LintYueGlobals, CheckTIC80Code -- 16
do -- 16
	local _obj_0 = require("Utils") -- 16
	LintYueGlobals, CheckTIC80Code = _obj_0.LintYueGlobals, _obj_0.CheckTIC80Code -- 16
end -- 16
local getProjectDirFromFile -- 18
getProjectDirFromFile = function(file) -- 18
	local writablePath, assetPath = Content.writablePath, Content.assetPath -- 19
	local parent, current -- 20
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 20
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 21
	elseif (".." ~= Path:getRelative(file, assetPath):sub(1, 2)) and assetPath == file:sub(1, #assetPath) then -- 22
		local dir = Path(assetPath, "Script") -- 23
		parent, current = dir, Path:getRelative(file, dir) -- 24
	else -- 26
		parent, current = nil, nil -- 26
	end -- 20
	if not current then -- 27
		return nil -- 27
	end -- 27
	repeat -- 28
		current = Path:getPath(current) -- 29
		if current == "" then -- 30
			break -- 30
		end -- 30
		local _list_0 = Content:getFiles(Path(parent, current)) -- 31
		for _index_0 = 1, #_list_0 do -- 31
			local f = _list_0[_index_0] -- 31
			if Path:getName(f):lower() == "init" then -- 32
				return Path(parent, current, Path:getPath(f)) -- 33
			end -- 32
		end -- 31
	until false -- 28
	return nil -- 35
end -- 18
local getSearchPath -- 37
getSearchPath = function(file) -- 37
	do -- 38
		local dir = getProjectDirFromFile(file) -- 38
		if dir then -- 38
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 39
		end -- 38
	end -- 38
	return "" -- 37
end -- 37
local getSearchFolders -- 41
getSearchFolders = function(file) -- 41
	do -- 42
		local dir = getProjectDirFromFile(file) -- 42
		if dir then -- 42
			return { -- 44
				Path(dir, "Script"), -- 44
				dir -- 45
			} -- 43
		end -- 42
	end -- 42
	return { } -- 41
end -- 41
local disabledCheckForLua = { -- 48
	"incompatible number of returns", -- 48
	"unknown", -- 49
	"cannot index", -- 50
	"module not found", -- 51
	"don't know how to resolve", -- 52
	"ContainerItem", -- 53
	"cannot resolve a type", -- 54
	"invalid key", -- 55
	"inconsistent index type", -- 56
	"cannot use operator", -- 57
	"attempting ipairs loop", -- 58
	"expects record or nominal", -- 59
	"variable is not being assigned", -- 60
	"<invalid type>", -- 61
	"<any type>", -- 62
	"using the '#' operator", -- 63
	"can't match a record", -- 64
	"redeclaration of variable", -- 65
	"cannot apply pairs", -- 66
	"not a function", -- 67
	"to%-be%-closed" -- 68
} -- 47
local yueCheck -- 70
yueCheck = function(file, content, lax) -- 70
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 71
	if isTIC80 then -- 72
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 73
	end -- 72
	local searchPath = getSearchPath(file) -- 74
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 75
	local info = { } -- 76
	local globals = { } -- 77
	for _index_0 = 1, #checkResult do -- 78
		local _des_0 = checkResult[_index_0] -- 78
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 78
		if "error" == t then -- 79
			info[#info + 1] = { -- 80
				"syntax", -- 80
				file, -- 80
				line, -- 80
				col, -- 80
				msg -- 80
			} -- 80
		elseif "global" == t then -- 81
			globals[#globals + 1] = { -- 82
				msg, -- 82
				line, -- 82
				col -- 82
			} -- 82
		end -- 79
	end -- 78
	if luaCodes then -- 83
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 84
		if success then -- 85
			if lax then -- 86
				luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 87
				if not (lintResult == "") then -- 88
					lintResult = lintResult .. "\n" -- 88
				end -- 88
				luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 89
			else -- 91
				luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(luaCodes) -- 91
			end -- 86
		else -- 92
			for _index_0 = 1, #lintResult do -- 92
				local _des_0 = lintResult[_index_0] -- 92
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 92
				if isTIC80 and tic80APIs[name] then -- 93
					goto _continue_0 -- 93
				end -- 93
				info[#info + 1] = { -- 94
					"syntax", -- 94
					file, -- 94
					line, -- 94
					col, -- 94
					"invalid global variable" -- 94
				} -- 94
				::_continue_0:: -- 93
			end -- 92
		end -- 85
	end -- 83
	return luaCodes, info -- 95
end -- 70
local luaCheck -- 97
luaCheck = function(file, content) -- 97
	local res, err = load(content, "check") -- 98
	if not res then -- 99
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 100
		return { -- 101
			success = false, -- 101
			info = { -- 101
				{ -- 101
					"syntax", -- 101
					file, -- 101
					tonumber(line), -- 101
					0, -- 101
					msg -- 101
				} -- 101
			} -- 101
		} -- 101
	end -- 99
	local success, info = teal.checkAsync(content, file, true, "") -- 102
	if info then -- 103
		do -- 104
			local _accum_0 = { } -- 104
			local _len_0 = 1 -- 104
			for _index_0 = 1, #info do -- 104
				local item = info[_index_0] -- 104
				local useCheck = true -- 105
				if not item[5]:match("unused") then -- 106
					for _index_1 = 1, #disabledCheckForLua do -- 107
						local check = disabledCheckForLua[_index_1] -- 107
						if item[5]:match(check) then -- 108
							useCheck = false -- 109
						end -- 108
					end -- 107
				end -- 106
				if not useCheck then -- 110
					goto _continue_0 -- 110
				end -- 110
				do -- 111
					local _exp_0 = item[1] -- 111
					if "type" == _exp_0 then -- 112
						item[1] = "warning" -- 113
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 114
						goto _continue_0 -- 115
					end -- 111
				end -- 111
				_accum_0[_len_0] = item -- 116
				_len_0 = _len_0 + 1 -- 105
				::_continue_0:: -- 105
			end -- 104
			info = _accum_0 -- 104
		end -- 104
		if #info == 0 then -- 117
			info = nil -- 118
			success = true -- 119
		end -- 117
	end -- 103
	return { -- 120
		success = success, -- 120
		info = info -- 120
	} -- 120
end -- 97
local luaCheckWithLineInfo -- 122
luaCheckWithLineInfo = function(file, luaCodes) -- 122
	local res = luaCheck(file, luaCodes) -- 123
	local info = { } -- 124
	if not res.success then -- 125
		local current = 1 -- 126
		local lastLine = 1 -- 127
		local lineMap = { } -- 128
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 129
			local num = lineCode:match("--%s*(%d+)%s*$") -- 130
			if num then -- 131
				lastLine = tonumber(num) -- 132
			end -- 131
			lineMap[current] = lastLine -- 133
			current = current + 1 -- 134
		end -- 129
		local _list_0 = res.info -- 135
		for _index_0 = 1, #_list_0 do -- 135
			local item = _list_0[_index_0] -- 135
			item[3] = lineMap[item[3]] or 0 -- 136
			item[4] = 0 -- 137
			info[#info + 1] = item -- 138
		end -- 135
		return false, info -- 139
	end -- 125
	return true, info -- 140
end -- 122
local getCompiledYueLine -- 142
getCompiledYueLine = function(content, line, row, file, lax) -- 142
	local luaCodes = yueCheck(file, content, lax) -- 143
	if not luaCodes then -- 144
		return nil -- 144
	end -- 144
	local current = 1 -- 145
	local lastLine = 1 -- 146
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 147
	local targetRow = nil -- 148
	local lineMap = { } -- 149
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 150
		local num = lineCode:match("--%s*(%d+)%s*$") -- 151
		if num then -- 152
			lastLine = tonumber(num) -- 152
		end -- 152
		lineMap[current] = lastLine -- 153
		if row <= lastLine and not targetRow then -- 154
			targetRow = current -- 155
			break -- 156
		end -- 154
		current = current + 1 -- 157
	end -- 150
	targetRow = current -- 158
	if targetLine and targetRow then -- 159
		return luaCodes, targetLine, targetRow, lineMap -- 160
	else -- 162
		return nil -- 162
	end -- 159
end -- 142
HttpServer:postSchedule("/check", function(req) -- 164
	do -- 165
		local _type_0 = type(req) -- 165
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 165
		if _tab_0 then -- 165
			local file -- 165
			do -- 165
				local _obj_0 = req.body -- 165
				local _type_1 = type(_obj_0) -- 165
				if "table" == _type_1 or "userdata" == _type_1 then -- 165
					file = _obj_0.file -- 165
				end -- 165
			end -- 165
			local content -- 165
			do -- 165
				local _obj_0 = req.body -- 165
				local _type_1 = type(_obj_0) -- 165
				if "table" == _type_1 or "userdata" == _type_1 then -- 165
					content = _obj_0.content -- 165
				end -- 165
			end -- 165
			if file ~= nil and content ~= nil then -- 165
				local ext = Path:getExt(file) -- 166
				if "tl" == ext then -- 167
					local searchPath = getSearchPath(file) -- 168
					do -- 169
						local isTIC80 = CheckTIC80Code(content) -- 169
						if isTIC80 then -- 169
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 170
						end -- 169
					end -- 169
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 171
					return { -- 172
						success = success, -- 172
						info = info -- 172
					} -- 172
				elseif "lua" == ext then -- 173
					do -- 174
						local isTIC80 = CheckTIC80Code(content) -- 174
						if isTIC80 then -- 174
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 175
						end -- 174
					end -- 174
					return luaCheck(file, content) -- 176
				elseif "yue" == ext then -- 177
					local luaCodes, info = yueCheck(file, content, false) -- 178
					local success = false -- 179
					if luaCodes then -- 180
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 181
						do -- 182
							local _tab_1 = { } -- 182
							local _idx_0 = #_tab_1 + 1 -- 182
							for _index_0 = 1, #info do -- 182
								local _value_0 = info[_index_0] -- 182
								_tab_1[_idx_0] = _value_0 -- 182
								_idx_0 = _idx_0 + 1 -- 182
							end -- 182
							local _idx_1 = #_tab_1 + 1 -- 182
							for _index_0 = 1, #luaInfo do -- 182
								local _value_0 = luaInfo[_index_0] -- 182
								_tab_1[_idx_1] = _value_0 -- 182
								_idx_1 = _idx_1 + 1 -- 182
							end -- 182
							info = _tab_1 -- 182
						end -- 182
						success = success and luaSuccess -- 183
					end -- 180
					if #info > 0 then -- 184
						return { -- 185
							success = success, -- 185
							info = info -- 185
						} -- 185
					else -- 187
						return { -- 187
							success = success -- 187
						} -- 187
					end -- 184
				elseif "xml" == ext then -- 188
					local success, result = xml.check(content) -- 189
					if success then -- 190
						local info -- 191
						success, info = luaCheckWithLineInfo(file, result) -- 191
						if #info > 0 then -- 192
							return { -- 193
								success = success, -- 193
								info = info -- 193
							} -- 193
						else -- 195
							return { -- 195
								success = success -- 195
							} -- 195
						end -- 192
					else -- 197
						local info -- 197
						do -- 197
							local _accum_0 = { } -- 197
							local _len_0 = 1 -- 197
							for _index_0 = 1, #result do -- 197
								local _des_0 = result[_index_0] -- 197
								local row, err = _des_0[1], _des_0[2] -- 197
								_accum_0[_len_0] = { -- 198
									"syntax", -- 198
									file, -- 198
									row, -- 198
									0, -- 198
									err -- 198
								} -- 198
								_len_0 = _len_0 + 1 -- 198
							end -- 197
							info = _accum_0 -- 197
						end -- 197
						return { -- 199
							success = false, -- 199
							info = info -- 199
						} -- 199
					end -- 190
				end -- 167
			end -- 165
		end -- 165
	end -- 165
	return { -- 164
		success = true -- 164
	} -- 164
end) -- 164
local updateInferedDesc -- 201
updateInferedDesc = function(infered) -- 201
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 202
		return -- 202
	end -- 202
	local key, row = infered.key, infered.row -- 203
	local codes = Content:loadAsync(key) -- 204
	if codes then -- 204
		local comments = { } -- 205
		local line = 0 -- 206
		local skipping = false -- 207
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 208
			line = line + 1 -- 209
			if line >= row then -- 210
				break -- 210
			end -- 210
			if lineCode:match("^%s*%-%- @") then -- 211
				skipping = true -- 212
				goto _continue_0 -- 213
			end -- 211
			local result = lineCode:match("^%s*%-%- (.+)") -- 214
			if result then -- 214
				if not skipping then -- 215
					comments[#comments + 1] = result -- 215
				end -- 215
			elseif #comments > 0 then -- 216
				comments = { } -- 217
				skipping = false -- 218
			end -- 214
			::_continue_0:: -- 209
		end -- 208
		infered.doc = table.concat(comments, "\n") -- 219
	end -- 204
end -- 201
HttpServer:postSchedule("/infer", function(req) -- 221
	do -- 222
		local _type_0 = type(req) -- 222
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 222
		if _tab_0 then -- 222
			local lang -- 222
			do -- 222
				local _obj_0 = req.body -- 222
				local _type_1 = type(_obj_0) -- 222
				if "table" == _type_1 or "userdata" == _type_1 then -- 222
					lang = _obj_0.lang -- 222
				end -- 222
			end -- 222
			local file -- 222
			do -- 222
				local _obj_0 = req.body -- 222
				local _type_1 = type(_obj_0) -- 222
				if "table" == _type_1 or "userdata" == _type_1 then -- 222
					file = _obj_0.file -- 222
				end -- 222
			end -- 222
			local content -- 222
			do -- 222
				local _obj_0 = req.body -- 222
				local _type_1 = type(_obj_0) -- 222
				if "table" == _type_1 or "userdata" == _type_1 then -- 222
					content = _obj_0.content -- 222
				end -- 222
			end -- 222
			local line -- 222
			do -- 222
				local _obj_0 = req.body -- 222
				local _type_1 = type(_obj_0) -- 222
				if "table" == _type_1 or "userdata" == _type_1 then -- 222
					line = _obj_0.line -- 222
				end -- 222
			end -- 222
			local row -- 222
			do -- 222
				local _obj_0 = req.body -- 222
				local _type_1 = type(_obj_0) -- 222
				if "table" == _type_1 or "userdata" == _type_1 then -- 222
					row = _obj_0.row -- 222
				end -- 222
			end -- 222
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 222
				local searchPath = getSearchPath(file) -- 223
				if "tl" == lang or "lua" == lang then -- 224
					if CheckTIC80Code(content) then -- 225
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 226
					end -- 225
					local infered = teal.inferAsync(content, line, row, searchPath) -- 227
					if (infered ~= nil) then -- 228
						updateInferedDesc(infered) -- 229
						return { -- 230
							success = true, -- 230
							infered = infered -- 230
						} -- 230
					end -- 228
				elseif "yue" == lang then -- 231
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 232
					if not luaCodes then -- 233
						return { -- 233
							success = false -- 233
						} -- 233
					end -- 233
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 234
					if (infered ~= nil) then -- 235
						local col -- 236
						file, row, col = infered.file, infered.row, infered.col -- 236
						if file == "" and row > 0 and col > 0 then -- 237
							infered.row = lineMap[row] or 0 -- 238
							infered.col = 0 -- 239
						end -- 237
						updateInferedDesc(infered) -- 240
						return { -- 241
							success = true, -- 241
							infered = infered -- 241
						} -- 241
					end -- 235
				end -- 224
			end -- 222
		end -- 222
	end -- 222
	return { -- 221
		success = false -- 221
	} -- 221
end) -- 221
local _anon_func_0 = function(doc) -- 292
	local _accum_0 = { } -- 292
	local _len_0 = 1 -- 292
	local _list_0 = doc.params -- 292
	for _index_0 = 1, #_list_0 do -- 292
		local param = _list_0[_index_0] -- 292
		_accum_0[_len_0] = param.name -- 292
		_len_0 = _len_0 + 1 -- 292
	end -- 292
	return _accum_0 -- 292
end -- 292
local getParamDocs -- 243
getParamDocs = function(signatures) -- 243
	do -- 244
		local codes = Content:loadAsync(signatures[1].file) -- 244
		if codes then -- 244
			local comments = { } -- 245
			local params = { } -- 246
			local line = 0 -- 247
			local docs = { } -- 248
			local returnType = nil -- 249
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 250
				line = line + 1 -- 251
				local needBreak = true -- 252
				for i, _des_0 in ipairs(signatures) do -- 253
					local row = _des_0.row -- 253
					if line >= row and not (docs[i] ~= nil) then -- 254
						if #comments > 0 or #params > 0 or returnType then -- 255
							docs[i] = { -- 257
								doc = table.concat(comments, "  \n"), -- 257
								returnType = returnType -- 258
							} -- 256
							if #params > 0 then -- 260
								docs[i].params = params -- 260
							end -- 260
						else -- 262
							docs[i] = false -- 262
						end -- 255
					end -- 254
					if not docs[i] then -- 263
						needBreak = false -- 263
					end -- 263
				end -- 253
				if needBreak then -- 264
					break -- 264
				end -- 264
				local result = lineCode:match("%s*%-%- (.+)") -- 265
				if result then -- 265
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 266
					if not name then -- 267
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 268
					end -- 267
					if name then -- 269
						local pname = name -- 270
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 271
							pname = pname .. "?" -- 271
						end -- 271
						params[#params + 1] = { -- 273
							name = tostring(pname) .. ": " .. tostring(typ), -- 273
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 274
						} -- 272
					else -- 277
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 277
						if typ then -- 277
							if returnType then -- 278
								returnType = returnType .. ", " .. typ -- 279
							else -- 281
								returnType = typ -- 281
							end -- 278
							result = result:gsub("@return", "**return:**") -- 282
						end -- 277
						comments[#comments + 1] = result -- 283
					end -- 269
				elseif #comments > 0 then -- 284
					comments = { } -- 285
					params = { } -- 286
					returnType = nil -- 287
				end -- 265
			end -- 250
			local results = { } -- 288
			for _index_0 = 1, #docs do -- 289
				local doc = docs[_index_0] -- 289
				if not doc then -- 290
					goto _continue_0 -- 290
				end -- 290
				if doc.params then -- 291
					doc.desc = "function(" .. tostring(table.concat(_anon_func_0(doc), ', ')) .. ")" -- 292
				else -- 294
					doc.desc = "function()" -- 294
				end -- 291
				if doc.returnType then -- 295
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 296
					doc.returnType = nil -- 297
				end -- 295
				results[#results + 1] = doc -- 298
				::_continue_0:: -- 290
			end -- 289
			if #results > 0 then -- 299
				return results -- 299
			else -- 299
				return nil -- 299
			end -- 299
		end -- 244
	end -- 244
	return nil -- 243
end -- 243
HttpServer:postSchedule("/signature", function(req) -- 301
	do -- 302
		local _type_0 = type(req) -- 302
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 302
		if _tab_0 then -- 302
			local lang -- 302
			do -- 302
				local _obj_0 = req.body -- 302
				local _type_1 = type(_obj_0) -- 302
				if "table" == _type_1 or "userdata" == _type_1 then -- 302
					lang = _obj_0.lang -- 302
				end -- 302
			end -- 302
			local file -- 302
			do -- 302
				local _obj_0 = req.body -- 302
				local _type_1 = type(_obj_0) -- 302
				if "table" == _type_1 or "userdata" == _type_1 then -- 302
					file = _obj_0.file -- 302
				end -- 302
			end -- 302
			local content -- 302
			do -- 302
				local _obj_0 = req.body -- 302
				local _type_1 = type(_obj_0) -- 302
				if "table" == _type_1 or "userdata" == _type_1 then -- 302
					content = _obj_0.content -- 302
				end -- 302
			end -- 302
			local line -- 302
			do -- 302
				local _obj_0 = req.body -- 302
				local _type_1 = type(_obj_0) -- 302
				if "table" == _type_1 or "userdata" == _type_1 then -- 302
					line = _obj_0.line -- 302
				end -- 302
			end -- 302
			local row -- 302
			do -- 302
				local _obj_0 = req.body -- 302
				local _type_1 = type(_obj_0) -- 302
				if "table" == _type_1 or "userdata" == _type_1 then -- 302
					row = _obj_0.row -- 302
				end -- 302
			end -- 302
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 302
				local searchPath = getSearchPath(file) -- 303
				if "tl" == lang or "lua" == lang then -- 304
					if CheckTIC80Code(content) then -- 305
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 306
					end -- 305
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 307
					if signatures then -- 307
						signatures = getParamDocs(signatures) -- 308
						if signatures then -- 308
							return { -- 309
								success = true, -- 309
								signatures = signatures -- 309
							} -- 309
						end -- 308
					end -- 307
				elseif "yue" == lang then -- 310
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 311
					if not luaCodes then -- 312
						return { -- 312
							success = false -- 312
						} -- 312
					end -- 312
					do -- 313
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 313
						if chainOp then -- 313
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 314
							if withVar then -- 314
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 315
							end -- 314
						end -- 313
					end -- 313
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 316
					if signatures then -- 316
						signatures = getParamDocs(signatures) -- 317
						if signatures then -- 317
							return { -- 318
								success = true, -- 318
								signatures = signatures -- 318
							} -- 318
						end -- 317
					else -- 319
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 319
						if signatures then -- 319
							signatures = getParamDocs(signatures) -- 320
							if signatures then -- 320
								return { -- 321
									success = true, -- 321
									signatures = signatures -- 321
								} -- 321
							end -- 320
						end -- 319
					end -- 316
				end -- 304
			end -- 302
		end -- 302
	end -- 302
	return { -- 301
		success = false -- 301
	} -- 301
end) -- 301
local luaKeywords = { -- 324
	'and', -- 324
	'break', -- 325
	'do', -- 326
	'else', -- 327
	'elseif', -- 328
	'end', -- 329
	'false', -- 330
	'for', -- 331
	'function', -- 332
	'goto', -- 333
	'if', -- 334
	'in', -- 335
	'local', -- 336
	'nil', -- 337
	'not', -- 338
	'or', -- 339
	'repeat', -- 340
	'return', -- 341
	'then', -- 342
	'true', -- 343
	'until', -- 344
	'while' -- 345
} -- 323
local tealKeywords = { -- 349
	'record', -- 349
	'as', -- 350
	'is', -- 351
	'type', -- 352
	'embed', -- 353
	'enum', -- 354
	'global', -- 355
	'any', -- 356
	'boolean', -- 357
	'integer', -- 358
	'number', -- 359
	'string', -- 360
	'thread' -- 361
} -- 348
local yueKeywords = { -- 365
	"and", -- 365
	"break", -- 366
	"do", -- 367
	"else", -- 368
	"elseif", -- 369
	"false", -- 370
	"for", -- 371
	"goto", -- 372
	"if", -- 373
	"in", -- 374
	"local", -- 375
	"nil", -- 376
	"not", -- 377
	"or", -- 378
	"repeat", -- 379
	"return", -- 380
	"then", -- 381
	"true", -- 382
	"until", -- 383
	"while", -- 384
	"as", -- 385
	"class", -- 386
	"continue", -- 387
	"export", -- 388
	"extends", -- 389
	"from", -- 390
	"global", -- 391
	"import", -- 392
	"macro", -- 393
	"switch", -- 394
	"try", -- 395
	"unless", -- 396
	"using", -- 397
	"when", -- 398
	"with" -- 399
} -- 364
local _anon_func_1 = function(f) -- 435
	local _val_0 = Path:getExt(f) -- 435
	return "ttf" == _val_0 or "otf" == _val_0 -- 435
end -- 435
local _anon_func_2 = function(suggestions) -- 461
	local _tbl_0 = { } -- 461
	for _index_0 = 1, #suggestions do -- 461
		local item = suggestions[_index_0] -- 461
		_tbl_0[item[1] .. item[2]] = item -- 461
	end -- 461
	return _tbl_0 -- 461
end -- 461
HttpServer:postSchedule("/complete", function(req) -- 402
	do -- 403
		local _type_0 = type(req) -- 403
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 403
		if _tab_0 then -- 403
			local lang -- 403
			do -- 403
				local _obj_0 = req.body -- 403
				local _type_1 = type(_obj_0) -- 403
				if "table" == _type_1 or "userdata" == _type_1 then -- 403
					lang = _obj_0.lang -- 403
				end -- 403
			end -- 403
			local file -- 403
			do -- 403
				local _obj_0 = req.body -- 403
				local _type_1 = type(_obj_0) -- 403
				if "table" == _type_1 or "userdata" == _type_1 then -- 403
					file = _obj_0.file -- 403
				end -- 403
			end -- 403
			local content -- 403
			do -- 403
				local _obj_0 = req.body -- 403
				local _type_1 = type(_obj_0) -- 403
				if "table" == _type_1 or "userdata" == _type_1 then -- 403
					content = _obj_0.content -- 403
				end -- 403
			end -- 403
			local line -- 403
			do -- 403
				local _obj_0 = req.body -- 403
				local _type_1 = type(_obj_0) -- 403
				if "table" == _type_1 or "userdata" == _type_1 then -- 403
					line = _obj_0.line -- 403
				end -- 403
			end -- 403
			local row -- 403
			do -- 403
				local _obj_0 = req.body -- 403
				local _type_1 = type(_obj_0) -- 403
				if "table" == _type_1 or "userdata" == _type_1 then -- 403
					row = _obj_0.row -- 403
				end -- 403
			end -- 403
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 403
				local searchPath = getSearchPath(file) -- 404
				repeat -- 405
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 406
					if lang == "yue" then -- 407
						if not item then -- 408
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 408
						end -- 408
						if not item then -- 409
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 409
						end -- 409
					end -- 407
					local searchType = nil -- 410
					if not item then -- 411
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 412
						if lang == "yue" then -- 413
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 414
						end -- 413
						if (item ~= nil) then -- 415
							searchType = "Image" -- 415
						end -- 415
					end -- 411
					if not item then -- 416
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 417
						if lang == "yue" then -- 418
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 419
						end -- 418
						if (item ~= nil) then -- 420
							searchType = "Font" -- 420
						end -- 420
					end -- 416
					if not item then -- 421
						break -- 421
					end -- 421
					local searchPaths = Content.searchPaths -- 422
					local _list_0 = getSearchFolders(file) -- 423
					for _index_0 = 1, #_list_0 do -- 423
						local folder = _list_0[_index_0] -- 423
						searchPaths[#searchPaths + 1] = folder -- 424
					end -- 423
					if searchType then -- 425
						searchPaths[#searchPaths + 1] = Content.assetPath -- 425
					end -- 425
					local tokens -- 426
					do -- 426
						local _accum_0 = { } -- 426
						local _len_0 = 1 -- 426
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 426
							_accum_0[_len_0] = mod -- 426
							_len_0 = _len_0 + 1 -- 426
						end -- 426
						tokens = _accum_0 -- 426
					end -- 426
					local suggestions = { } -- 427
					for _index_0 = 1, #searchPaths do -- 428
						local path = searchPaths[_index_0] -- 428
						local sPath = Path(path, table.unpack(tokens)) -- 429
						if not Content:exist(sPath) then -- 430
							goto _continue_0 -- 430
						end -- 430
						if searchType == "Font" then -- 431
							local fontPath = Path(sPath, "Font") -- 432
							if Content:exist(fontPath) then -- 433
								local _list_1 = Content:getFiles(fontPath) -- 434
								for _index_1 = 1, #_list_1 do -- 434
									local f = _list_1[_index_1] -- 434
									if _anon_func_1(f) then -- 435
										if "." == f:sub(1, 1) then -- 436
											goto _continue_1 -- 436
										end -- 436
										suggestions[#suggestions + 1] = { -- 437
											Path:getName(f), -- 437
											"font", -- 437
											"field" -- 437
										} -- 437
									end -- 435
									::_continue_1:: -- 435
								end -- 434
							end -- 433
						end -- 431
						local _list_1 = Content:getFiles(sPath) -- 438
						for _index_1 = 1, #_list_1 do -- 438
							local f = _list_1[_index_1] -- 438
							if "Image" == searchType then -- 439
								do -- 440
									local _exp_0 = Path:getExt(f) -- 440
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 440
										if "." == f:sub(1, 1) then -- 441
											goto _continue_2 -- 441
										end -- 441
										suggestions[#suggestions + 1] = { -- 442
											f, -- 442
											"image", -- 442
											"field" -- 442
										} -- 442
									end -- 440
								end -- 440
								goto _continue_2 -- 443
							elseif "Font" == searchType then -- 444
								do -- 445
									local _exp_0 = Path:getExt(f) -- 445
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 445
										if "." == f:sub(1, 1) then -- 446
											goto _continue_2 -- 446
										end -- 446
										suggestions[#suggestions + 1] = { -- 447
											f, -- 447
											"font", -- 447
											"field" -- 447
										} -- 447
									end -- 445
								end -- 445
								goto _continue_2 -- 448
							end -- 439
							local _exp_0 = Path:getExt(f) -- 449
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 449
								local name = Path:getName(f) -- 450
								if "d" == Path:getExt(name) then -- 451
									goto _continue_2 -- 451
								end -- 451
								if "." == name:sub(1, 1) then -- 452
									goto _continue_2 -- 452
								end -- 452
								suggestions[#suggestions + 1] = { -- 453
									name, -- 453
									"module", -- 453
									"field" -- 453
								} -- 453
							end -- 449
							::_continue_2:: -- 439
						end -- 438
						local _list_2 = Content:getDirs(sPath) -- 454
						for _index_1 = 1, #_list_2 do -- 454
							local dir = _list_2[_index_1] -- 454
							if "." == dir:sub(1, 1) then -- 455
								goto _continue_3 -- 455
							end -- 455
							suggestions[#suggestions + 1] = { -- 456
								dir, -- 456
								"folder", -- 456
								"variable" -- 456
							} -- 456
							::_continue_3:: -- 455
						end -- 454
						::_continue_0:: -- 429
					end -- 428
					if item == "" and not searchType then -- 457
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 458
						for _index_0 = 1, #_list_1 do -- 458
							local _des_0 = _list_1[_index_0] -- 458
							local name = _des_0[1] -- 458
							suggestions[#suggestions + 1] = { -- 459
								name, -- 459
								"dora module", -- 459
								"function" -- 459
							} -- 459
						end -- 458
					end -- 457
					if #suggestions > 0 then -- 460
						do -- 461
							local _accum_0 = { } -- 461
							local _len_0 = 1 -- 461
							for _, v in pairs(_anon_func_2(suggestions)) do -- 461
								_accum_0[_len_0] = v -- 461
								_len_0 = _len_0 + 1 -- 461
							end -- 461
							suggestions = _accum_0 -- 461
						end -- 461
						return { -- 462
							success = true, -- 462
							suggestions = suggestions -- 462
						} -- 462
					else -- 464
						return { -- 464
							success = false -- 464
						} -- 464
					end -- 460
				until true -- 405
				if "tl" == lang or "lua" == lang then -- 466
					do -- 467
						local isTIC80 = CheckTIC80Code(content) -- 467
						if isTIC80 then -- 467
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 468
						end -- 467
					end -- 467
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 469
					if not line:match("[%.:]$") then -- 470
						local checkSet -- 471
						do -- 471
							local _tbl_0 = { } -- 471
							for _index_0 = 1, #suggestions do -- 471
								local _des_0 = suggestions[_index_0] -- 471
								local name = _des_0[1] -- 471
								_tbl_0[name] = true -- 471
							end -- 471
							checkSet = _tbl_0 -- 471
						end -- 471
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 472
						for _index_0 = 1, #_list_0 do -- 472
							local item = _list_0[_index_0] -- 472
							if not checkSet[item[1]] then -- 473
								suggestions[#suggestions + 1] = item -- 473
							end -- 473
						end -- 472
						for _index_0 = 1, #luaKeywords do -- 474
							local word = luaKeywords[_index_0] -- 474
							suggestions[#suggestions + 1] = { -- 475
								word, -- 475
								"keyword", -- 475
								"keyword" -- 475
							} -- 475
						end -- 474
						if lang == "tl" then -- 476
							for _index_0 = 1, #tealKeywords do -- 477
								local word = tealKeywords[_index_0] -- 477
								suggestions[#suggestions + 1] = { -- 478
									word, -- 478
									"keyword", -- 478
									"keyword" -- 478
								} -- 478
							end -- 477
						end -- 476
					end -- 470
					if #suggestions > 0 then -- 479
						return { -- 480
							success = true, -- 480
							suggestions = suggestions -- 480
						} -- 480
					end -- 479
				elseif "yue" == lang then -- 481
					local suggestions = { } -- 482
					local gotGlobals = false -- 483
					do -- 484
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 484
						if luaCodes then -- 484
							gotGlobals = true -- 485
							do -- 486
								local chainOp = line:match("[^%w_]([%.\\])$") -- 486
								if chainOp then -- 486
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 487
									if not withVar then -- 488
										return { -- 488
											success = false -- 488
										} -- 488
									end -- 488
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 489
								elseif line:match("^([%.\\])$") then -- 490
									return { -- 491
										success = false -- 491
									} -- 491
								end -- 486
							end -- 486
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 492
							for _index_0 = 1, #_list_0 do -- 492
								local item = _list_0[_index_0] -- 492
								suggestions[#suggestions + 1] = item -- 492
							end -- 492
							if #suggestions == 0 then -- 493
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 494
								for _index_0 = 1, #_list_1 do -- 494
									local item = _list_1[_index_0] -- 494
									suggestions[#suggestions + 1] = item -- 494
								end -- 494
							end -- 493
						end -- 484
					end -- 484
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 495
						local checkSet -- 496
						do -- 496
							local _tbl_0 = { } -- 496
							for _index_0 = 1, #suggestions do -- 496
								local _des_0 = suggestions[_index_0] -- 496
								local name = _des_0[1] -- 496
								_tbl_0[name] = true -- 496
							end -- 496
							checkSet = _tbl_0 -- 496
						end -- 496
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 497
						for _index_0 = 1, #_list_0 do -- 497
							local item = _list_0[_index_0] -- 497
							if not checkSet[item[1]] then -- 498
								suggestions[#suggestions + 1] = item -- 498
							end -- 498
						end -- 497
						if not gotGlobals then -- 499
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 500
							for _index_0 = 1, #_list_1 do -- 500
								local item = _list_1[_index_0] -- 500
								if not checkSet[item[1]] then -- 501
									suggestions[#suggestions + 1] = item -- 501
								end -- 501
							end -- 500
						end -- 499
						for _index_0 = 1, #yueKeywords do -- 502
							local word = yueKeywords[_index_0] -- 502
							if not checkSet[word] then -- 503
								suggestions[#suggestions + 1] = { -- 504
									word, -- 504
									"keyword", -- 504
									"keyword" -- 504
								} -- 504
							end -- 503
						end -- 502
					end -- 495
					if #suggestions > 0 then -- 505
						return { -- 506
							success = true, -- 506
							suggestions = suggestions -- 506
						} -- 506
					end -- 505
				elseif "xml" == lang then -- 507
					local items = xml.complete(content) -- 508
					if #items > 0 then -- 509
						local suggestions -- 510
						do -- 510
							local _accum_0 = { } -- 510
							local _len_0 = 1 -- 510
							for _index_0 = 1, #items do -- 510
								local _des_0 = items[_index_0] -- 510
								local label, insertText = _des_0[1], _des_0[2] -- 510
								_accum_0[_len_0] = { -- 511
									label, -- 511
									insertText, -- 511
									"field" -- 511
								} -- 511
								_len_0 = _len_0 + 1 -- 511
							end -- 510
							suggestions = _accum_0 -- 510
						end -- 510
						return { -- 512
							success = true, -- 512
							suggestions = suggestions -- 512
						} -- 512
					end -- 509
				end -- 466
			end -- 403
		end -- 403
	end -- 403
	return { -- 402
		success = false -- 402
	} -- 402
end) -- 402
HttpServer:upload("/upload", function(req, filename) -- 516
	do -- 517
		local _type_0 = type(req) -- 517
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 517
		if _tab_0 then -- 517
			local path -- 517
			do -- 517
				local _obj_0 = req.params -- 517
				local _type_1 = type(_obj_0) -- 517
				if "table" == _type_1 or "userdata" == _type_1 then -- 517
					path = _obj_0.path -- 517
				end -- 517
			end -- 517
			if path ~= nil then -- 517
				local uploadPath = Path(Content.writablePath, ".upload") -- 518
				if not Content:exist(uploadPath) then -- 519
					Content:mkdir(uploadPath) -- 520
				end -- 519
				local targetPath = Path(uploadPath, filename) -- 521
				Content:mkdir(Path:getPath(targetPath)) -- 522
				return targetPath -- 523
			end -- 517
		end -- 517
	end -- 517
	return nil -- 516
end, function(req, file) -- 524
	do -- 525
		local _type_0 = type(req) -- 525
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 525
		if _tab_0 then -- 525
			local path -- 525
			do -- 525
				local _obj_0 = req.params -- 525
				local _type_1 = type(_obj_0) -- 525
				if "table" == _type_1 or "userdata" == _type_1 then -- 525
					path = _obj_0.path -- 525
				end -- 525
			end -- 525
			if path ~= nil then -- 525
				path = Path(Content.writablePath, path) -- 526
				if Content:exist(path) then -- 527
					local uploadPath = Path(Content.writablePath, ".upload") -- 528
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 529
					Content:mkdir(Path:getPath(targetPath)) -- 530
					if Content:move(file, targetPath) then -- 531
						return true -- 532
					end -- 531
				end -- 527
			end -- 525
		end -- 525
	end -- 525
	return false -- 524
end) -- 514
HttpServer:post("/list", function(req) -- 535
	do -- 536
		local _type_0 = type(req) -- 536
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 536
		if _tab_0 then -- 536
			local path -- 536
			do -- 536
				local _obj_0 = req.body -- 536
				local _type_1 = type(_obj_0) -- 536
				if "table" == _type_1 or "userdata" == _type_1 then -- 536
					path = _obj_0.path -- 536
				end -- 536
			end -- 536
			if path ~= nil then -- 536
				if Content:exist(path) then -- 537
					local files = { } -- 538
					local visitAssets -- 539
					visitAssets = function(path, folder) -- 539
						local dirs = Content:getDirs(path) -- 540
						for _index_0 = 1, #dirs do -- 541
							local dir = dirs[_index_0] -- 541
							if dir:match("^%.") then -- 542
								goto _continue_0 -- 542
							end -- 542
							local current -- 543
							if folder == "" then -- 543
								current = dir -- 544
							else -- 546
								current = Path(folder, dir) -- 546
							end -- 543
							files[#files + 1] = current -- 547
							visitAssets(Path(path, dir), current) -- 548
							::_continue_0:: -- 542
						end -- 541
						local fs = Content:getFiles(path) -- 549
						for _index_0 = 1, #fs do -- 550
							local f = fs[_index_0] -- 550
							if f:match("^%.") then -- 551
								goto _continue_1 -- 551
							end -- 551
							if folder == "" then -- 552
								files[#files + 1] = f -- 553
							else -- 555
								files[#files + 1] = Path(folder, f) -- 555
							end -- 552
							::_continue_1:: -- 551
						end -- 550
					end -- 539
					visitAssets(path, "") -- 556
					if #files == 0 then -- 557
						files = nil -- 557
					end -- 557
					return { -- 558
						success = true, -- 558
						files = files -- 558
					} -- 558
				end -- 537
			end -- 536
		end -- 536
	end -- 536
	return { -- 535
		success = false -- 535
	} -- 535
end) -- 535
HttpServer:post("/info", function() -- 560
	local Entry = require("Script.Dev.Entry") -- 561
	local webProfiler, drawerWidth -- 562
	do -- 562
		local _obj_0 = Entry.getConfig() -- 562
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 562
	end -- 562
	local engineDev = Entry.getEngineDev() -- 563
	Entry.connectWebIDE() -- 564
	return { -- 566
		platform = App.platform, -- 566
		locale = App.locale, -- 567
		version = App.version, -- 568
		engineDev = engineDev, -- 569
		webProfiler = webProfiler, -- 570
		drawerWidth = drawerWidth -- 571
	} -- 565
end) -- 560
HttpServer:post("/new", function(req) -- 573
	do -- 574
		local _type_0 = type(req) -- 574
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 574
		if _tab_0 then -- 574
			local path -- 574
			do -- 574
				local _obj_0 = req.body -- 574
				local _type_1 = type(_obj_0) -- 574
				if "table" == _type_1 or "userdata" == _type_1 then -- 574
					path = _obj_0.path -- 574
				end -- 574
			end -- 574
			local content -- 574
			do -- 574
				local _obj_0 = req.body -- 574
				local _type_1 = type(_obj_0) -- 574
				if "table" == _type_1 or "userdata" == _type_1 then -- 574
					content = _obj_0.content -- 574
				end -- 574
			end -- 574
			local folder -- 574
			do -- 574
				local _obj_0 = req.body -- 574
				local _type_1 = type(_obj_0) -- 574
				if "table" == _type_1 or "userdata" == _type_1 then -- 574
					folder = _obj_0.folder -- 574
				end -- 574
			end -- 574
			if path ~= nil and content ~= nil and folder ~= nil then -- 574
				if Content:exist(path) then -- 575
					return { -- 576
						success = false, -- 576
						message = "TargetExisted" -- 576
					} -- 576
				end -- 575
				local parent = Path:getPath(path) -- 577
				local files = Content:getFiles(parent) -- 578
				if folder then -- 579
					local name = Path:getFilename(path):lower() -- 580
					for _index_0 = 1, #files do -- 581
						local file = files[_index_0] -- 581
						if name == Path:getFilename(file):lower() then -- 582
							return { -- 583
								success = false, -- 583
								message = "TargetExisted" -- 583
							} -- 583
						end -- 582
					end -- 581
					if Content:mkdir(path) then -- 584
						return { -- 585
							success = true -- 585
						} -- 585
					end -- 584
				else -- 587
					local name = Path:getName(path):lower() -- 587
					for _index_0 = 1, #files do -- 588
						local file = files[_index_0] -- 588
						if name == Path:getName(file):lower() then -- 589
							local ext = Path:getExt(file) -- 590
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 591
								goto _continue_0 -- 592
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 593
								goto _continue_0 -- 594
							end -- 591
							return { -- 595
								success = false, -- 595
								message = "SourceExisted" -- 595
							} -- 595
						end -- 589
						::_continue_0:: -- 589
					end -- 588
					if Content:save(path, content) then -- 596
						return { -- 597
							success = true -- 597
						} -- 597
					end -- 596
				end -- 579
			end -- 574
		end -- 574
	end -- 574
	return { -- 573
		success = false, -- 573
		message = "Failed" -- 573
	} -- 573
end) -- 573
HttpServer:post("/delete", function(req) -- 599
	do -- 600
		local _type_0 = type(req) -- 600
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 600
		if _tab_0 then -- 600
			local path -- 600
			do -- 600
				local _obj_0 = req.body -- 600
				local _type_1 = type(_obj_0) -- 600
				if "table" == _type_1 or "userdata" == _type_1 then -- 600
					path = _obj_0.path -- 600
				end -- 600
			end -- 600
			if path ~= nil then -- 600
				if Content:exist(path) then -- 601
					local parent = Path:getPath(path) -- 602
					local files = Content:getFiles(parent) -- 603
					local name = Path:getName(path):lower() -- 604
					local ext = Path:getExt(path) -- 605
					for _index_0 = 1, #files do -- 606
						local file = files[_index_0] -- 606
						if name == Path:getName(file):lower() then -- 607
							local _exp_0 = Path:getExt(file) -- 608
							if "tl" == _exp_0 then -- 608
								if ("vs" == ext) then -- 608
									Content:remove(Path(parent, file)) -- 609
								end -- 608
							elseif "lua" == _exp_0 then -- 610
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 610
									Content:remove(Path(parent, file)) -- 611
								end -- 610
							end -- 608
						end -- 607
					end -- 606
					if Content:remove(path) then -- 612
						return { -- 613
							success = true -- 613
						} -- 613
					end -- 612
				end -- 601
			end -- 600
		end -- 600
	end -- 600
	return { -- 599
		success = false -- 599
	} -- 599
end) -- 599
HttpServer:post("/rename", function(req) -- 615
	do -- 616
		local _type_0 = type(req) -- 616
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 616
		if _tab_0 then -- 616
			local old -- 616
			do -- 616
				local _obj_0 = req.body -- 616
				local _type_1 = type(_obj_0) -- 616
				if "table" == _type_1 or "userdata" == _type_1 then -- 616
					old = _obj_0.old -- 616
				end -- 616
			end -- 616
			local new -- 616
			do -- 616
				local _obj_0 = req.body -- 616
				local _type_1 = type(_obj_0) -- 616
				if "table" == _type_1 or "userdata" == _type_1 then -- 616
					new = _obj_0.new -- 616
				end -- 616
			end -- 616
			if old ~= nil and new ~= nil then -- 616
				if Content:exist(old) and not Content:exist(new) then -- 617
					local parent = Path:getPath(new) -- 618
					local files = Content:getFiles(parent) -- 619
					if Content:isdir(old) then -- 620
						local name = Path:getFilename(new):lower() -- 621
						for _index_0 = 1, #files do -- 622
							local file = files[_index_0] -- 622
							if name == Path:getFilename(file):lower() then -- 623
								return { -- 624
									success = false -- 624
								} -- 624
							end -- 623
						end -- 622
					else -- 626
						local name = Path:getName(new):lower() -- 626
						local ext = Path:getExt(new) -- 627
						for _index_0 = 1, #files do -- 628
							local file = files[_index_0] -- 628
							if name == Path:getName(file):lower() then -- 629
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 630
									goto _continue_0 -- 631
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 632
									goto _continue_0 -- 633
								end -- 630
								return { -- 634
									success = false -- 634
								} -- 634
							end -- 629
							::_continue_0:: -- 629
						end -- 628
					end -- 620
					if Content:move(old, new) then -- 635
						local newParent = Path:getPath(new) -- 636
						parent = Path:getPath(old) -- 637
						files = Content:getFiles(parent) -- 638
						local newName = Path:getName(new) -- 639
						local oldName = Path:getName(old) -- 640
						local name = oldName:lower() -- 641
						local ext = Path:getExt(old) -- 642
						for _index_0 = 1, #files do -- 643
							local file = files[_index_0] -- 643
							if name == Path:getName(file):lower() then -- 644
								local _exp_0 = Path:getExt(file) -- 645
								if "tl" == _exp_0 then -- 645
									if ("vs" == ext) then -- 645
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 646
									end -- 645
								elseif "lua" == _exp_0 then -- 647
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 647
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 648
									end -- 647
								end -- 645
							end -- 644
						end -- 643
						return { -- 649
							success = true -- 649
						} -- 649
					end -- 635
				end -- 617
			end -- 616
		end -- 616
	end -- 616
	return { -- 615
		success = false -- 615
	} -- 615
end) -- 615
HttpServer:post("/exist", function(req) -- 651
	do -- 652
		local _type_0 = type(req) -- 652
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 652
		if _tab_0 then -- 652
			local file -- 652
			do -- 652
				local _obj_0 = req.body -- 652
				local _type_1 = type(_obj_0) -- 652
				if "table" == _type_1 or "userdata" == _type_1 then -- 652
					file = _obj_0.file -- 652
				end -- 652
			end -- 652
			if file ~= nil then -- 652
				do -- 653
					local projFile = req.body.projFile -- 653
					if projFile then -- 653
						local projDir = getProjectDirFromFile(projFile) -- 654
						if projDir then -- 654
							local scriptDir = Path(projDir, "Script") -- 655
							local searchPaths = Content.searchPaths -- 656
							if Content:exist(scriptDir) then -- 657
								Content:addSearchPath(scriptDir) -- 657
							end -- 657
							if Content:exist(projDir) then -- 658
								Content:addSearchPath(projDir) -- 658
							end -- 658
							local _ <close> = setmetatable({ }, { -- 659
								__close = function() -- 659
									Content.searchPaths = searchPaths -- 659
								end -- 659
							}) -- 659
							return { -- 660
								success = Content:exist(file) -- 660
							} -- 660
						end -- 654
					end -- 653
				end -- 653
				return { -- 661
					success = Content:exist(file) -- 661
				} -- 661
			end -- 652
		end -- 652
	end -- 652
	return { -- 651
		success = false -- 651
	} -- 651
end) -- 651
HttpServer:postSchedule("/read", function(req) -- 663
	do -- 664
		local _type_0 = type(req) -- 664
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 664
		if _tab_0 then -- 664
			local path -- 664
			do -- 664
				local _obj_0 = req.body -- 664
				local _type_1 = type(_obj_0) -- 664
				if "table" == _type_1 or "userdata" == _type_1 then -- 664
					path = _obj_0.path -- 664
				end -- 664
			end -- 664
			if path ~= nil then -- 664
				local readFile -- 665
				readFile = function() -- 665
					if Content:exist(path) then -- 666
						local content = Content:loadAsync(path) -- 667
						if content then -- 667
							return { -- 668
								content = content, -- 668
								success = true -- 668
							} -- 668
						end -- 667
					end -- 666
					return nil -- 665
				end -- 665
				do -- 669
					local projFile = req.body.projFile -- 669
					if projFile then -- 669
						local projDir = getProjectDirFromFile(projFile) -- 670
						if projDir then -- 670
							local scriptDir = Path(projDir, "Script") -- 671
							local searchPaths = Content.searchPaths -- 672
							if Content:exist(scriptDir) then -- 673
								Content:addSearchPath(scriptDir) -- 673
							end -- 673
							if Content:exist(projDir) then -- 674
								Content:addSearchPath(projDir) -- 674
							end -- 674
							local _ <close> = setmetatable({ }, { -- 675
								__close = function() -- 675
									Content.searchPaths = searchPaths -- 675
								end -- 675
							}) -- 675
							local result = readFile() -- 676
							if result then -- 676
								return result -- 676
							end -- 676
						end -- 670
					end -- 669
				end -- 669
				local result = readFile() -- 677
				if result then -- 677
					return result -- 677
				end -- 677
			end -- 664
		end -- 664
	end -- 664
	return { -- 663
		success = false -- 663
	} -- 663
end) -- 663
HttpServer:post("/read-sync", function(req) -- 679
	do -- 680
		local _type_0 = type(req) -- 680
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 680
		if _tab_0 then -- 680
			local path -- 680
			do -- 680
				local _obj_0 = req.body -- 680
				local _type_1 = type(_obj_0) -- 680
				if "table" == _type_1 or "userdata" == _type_1 then -- 680
					path = _obj_0.path -- 680
				end -- 680
			end -- 680
			local exts -- 680
			do -- 680
				local _obj_0 = req.body -- 680
				local _type_1 = type(_obj_0) -- 680
				if "table" == _type_1 or "userdata" == _type_1 then -- 680
					exts = _obj_0.exts -- 680
				end -- 680
			end -- 680
			if path ~= nil and exts ~= nil then -- 680
				local readFile -- 681
				readFile = function() -- 681
					for _index_0 = 1, #exts do -- 682
						local ext = exts[_index_0] -- 682
						local targetPath = path .. ext -- 683
						if Content:exist(targetPath) then -- 684
							local content = Content:load(targetPath) -- 685
							if content then -- 685
								return { -- 686
									content = content, -- 686
									success = true, -- 686
									fullPath = Content:getFullPath(targetPath) -- 686
								} -- 686
							end -- 685
						end -- 684
					end -- 682
					return nil -- 681
				end -- 681
				local searchPaths = Content.searchPaths -- 687
				local _ <close> = setmetatable({ }, { -- 688
					__close = function() -- 688
						Content.searchPaths = searchPaths -- 688
					end -- 688
				}) -- 688
				do -- 689
					local projFile = req.body.projFile -- 689
					if projFile then -- 689
						local projDir = getProjectDirFromFile(projFile) -- 690
						if projDir then -- 690
							local scriptDir = Path(projDir, "Script") -- 691
							if Content:exist(scriptDir) then -- 692
								Content:addSearchPath(scriptDir) -- 692
							end -- 692
							if Content:exist(projDir) then -- 693
								Content:addSearchPath(projDir) -- 693
							end -- 693
						else -- 695
							projDir = Path:getPath(projFile) -- 695
							if Content:exist(projDir) then -- 696
								Content:addSearchPath(projDir) -- 696
							end -- 696
						end -- 690
					end -- 689
				end -- 689
				local result = readFile() -- 697
				if result then -- 697
					return result -- 697
				end -- 697
			end -- 680
		end -- 680
	end -- 680
	return { -- 679
		success = false -- 679
	} -- 679
end) -- 679
local compileFileAsync -- 699
compileFileAsync = function(inputFile, sourceCodes) -- 699
	local file = inputFile -- 700
	local searchPath -- 701
	do -- 701
		local dir = getProjectDirFromFile(inputFile) -- 701
		if dir then -- 701
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 702
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 703
		else -- 705
			file = Path:getRelative(inputFile, Content.writablePath) -- 705
			if file:sub(1, 2) == ".." then -- 706
				file = Path:getRelative(inputFile, Content.assetPath) -- 707
			end -- 706
			searchPath = "" -- 708
		end -- 701
	end -- 701
	local outputFile = Path:replaceExt(inputFile, "lua") -- 709
	local yueext = yue.options.extension -- 710
	local resultCodes = nil -- 711
	do -- 712
		local _exp_0 = Path:getExt(inputFile) -- 712
		if yueext == _exp_0 then -- 712
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 713
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 714
				if not codes then -- 715
					return -- 715
				end -- 715
				local extraGlobal -- 716
				if isTIC80 then -- 716
					extraGlobal = tic80APIs -- 716
				else -- 716
					extraGlobal = nil -- 716
				end -- 716
				local success = LintYueGlobals(codes, globals, true, extraGlobal) -- 717
				if not success then -- 718
					return -- 718
				end -- 718
				if codes == "" then -- 719
					resultCodes = "" -- 720
					return nil -- 721
				end -- 719
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 722
				return resultCodes -- 723
			end, function(success) -- 714
				if not success then -- 724
					Content:remove(outputFile) -- 725
					if resultCodes == nil then -- 726
						resultCodes = false -- 727
					end -- 726
				end -- 724
			end) -- 714
		elseif "tl" == _exp_0 then -- 728
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 729
			if isTIC80 then -- 730
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 731
			end -- 730
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 732
			if codes then -- 732
				if isTIC80 then -- 733
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 734
				end -- 733
				resultCodes = codes -- 735
				Content:saveAsync(outputFile, codes) -- 736
			else -- 738
				Content:remove(outputFile) -- 738
				resultCodes = false -- 739
			end -- 732
		elseif "xml" == _exp_0 then -- 740
			local codes = xml.tolua(sourceCodes) -- 741
			if codes then -- 741
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 742
				Content:saveAsync(outputFile, resultCodes) -- 743
			else -- 745
				Content:remove(outputFile) -- 745
				resultCodes = false -- 746
			end -- 741
		end -- 712
	end -- 712
	wait(function() -- 747
		return resultCodes ~= nil -- 747
	end) -- 747
	if resultCodes then -- 748
		return resultCodes -- 748
	end -- 748
	return nil -- 699
end -- 699
HttpServer:postSchedule("/write", function(req) -- 750
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
			local content -- 751
			do -- 751
				local _obj_0 = req.body -- 751
				local _type_1 = type(_obj_0) -- 751
				if "table" == _type_1 or "userdata" == _type_1 then -- 751
					content = _obj_0.content -- 751
				end -- 751
			end -- 751
			if path ~= nil and content ~= nil then -- 751
				if Content:saveAsync(path, content) then -- 752
					do -- 753
						local _exp_0 = Path:getExt(path) -- 753
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 753
							if '' == Path:getExt(Path:getName(path)) then -- 754
								local resultCodes = compileFileAsync(path, content) -- 755
								return { -- 756
									success = true, -- 756
									resultCodes = resultCodes -- 756
								} -- 756
							end -- 754
						end -- 753
					end -- 753
					return { -- 757
						success = true -- 757
					} -- 757
				end -- 752
			end -- 751
		end -- 751
	end -- 751
	return { -- 750
		success = false -- 750
	} -- 750
end) -- 750
HttpServer:postSchedule("/build", function(req) -- 759
	do -- 760
		local _type_0 = type(req) -- 760
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 760
		if _tab_0 then -- 760
			local path -- 760
			do -- 760
				local _obj_0 = req.body -- 760
				local _type_1 = type(_obj_0) -- 760
				if "table" == _type_1 or "userdata" == _type_1 then -- 760
					path = _obj_0.path -- 760
				end -- 760
			end -- 760
			if path ~= nil then -- 760
				local _exp_0 = Path:getExt(path) -- 761
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 761
					if '' == Path:getExt(Path:getName(path)) then -- 762
						local content = Content:loadAsync(path) -- 763
						if content then -- 763
							local resultCodes = compileFileAsync(path, content) -- 764
							if resultCodes then -- 764
								return { -- 765
									success = true, -- 765
									resultCodes = resultCodes -- 765
								} -- 765
							end -- 764
						end -- 763
					end -- 762
				end -- 761
			end -- 760
		end -- 760
	end -- 760
	return { -- 759
		success = false -- 759
	} -- 759
end) -- 759
local extentionLevels = { -- 768
	vs = 2, -- 768
	bl = 2, -- 769
	ts = 1, -- 770
	tsx = 1, -- 771
	tl = 1, -- 772
	yue = 1, -- 773
	xml = 1, -- 774
	lua = 0 -- 775
} -- 767
HttpServer:post("/assets", function() -- 777
	local Entry = require("Script.Dev.Entry") -- 780
	local engineDev = Entry.getEngineDev() -- 781
	local visitAssets -- 782
	visitAssets = function(path, tag) -- 782
		local isWorkspace = tag == "Workspace" -- 783
		local builtin -- 784
		if tag == "Builtin" then -- 784
			builtin = true -- 784
		else -- 784
			builtin = nil -- 784
		end -- 784
		local children = nil -- 785
		local dirs = Content:getDirs(path) -- 786
		for _index_0 = 1, #dirs do -- 787
			local dir = dirs[_index_0] -- 787
			if isWorkspace then -- 788
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 789
					goto _continue_0 -- 790
				end -- 789
			elseif dir == ".git" then -- 791
				goto _continue_0 -- 792
			end -- 788
			if not children then -- 793
				children = { } -- 793
			end -- 793
			children[#children + 1] = visitAssets(Path(path, dir)) -- 794
			::_continue_0:: -- 788
		end -- 787
		local files = Content:getFiles(path) -- 795
		local names = { } -- 796
		for _index_0 = 1, #files do -- 797
			local file = files[_index_0] -- 797
			if file:match("^%.") then -- 798
				goto _continue_1 -- 798
			end -- 798
			local name = Path:getName(file) -- 799
			local ext = names[name] -- 800
			if ext then -- 800
				local lv1 -- 801
				do -- 801
					local _exp_0 = extentionLevels[ext] -- 801
					if _exp_0 ~= nil then -- 801
						lv1 = _exp_0 -- 801
					else -- 801
						lv1 = -1 -- 801
					end -- 801
				end -- 801
				ext = Path:getExt(file) -- 802
				local lv2 -- 803
				do -- 803
					local _exp_0 = extentionLevels[ext] -- 803
					if _exp_0 ~= nil then -- 803
						lv2 = _exp_0 -- 803
					else -- 803
						lv2 = -1 -- 803
					end -- 803
				end -- 803
				if lv2 > lv1 then -- 804
					names[name] = ext -- 805
				elseif lv2 == lv1 then -- 806
					names[name .. '.' .. ext] = "" -- 807
				end -- 804
			else -- 809
				ext = Path:getExt(file) -- 809
				if not extentionLevels[ext] then -- 810
					names[file] = "" -- 811
				else -- 813
					names[name] = ext -- 813
				end -- 810
			end -- 800
			::_continue_1:: -- 798
		end -- 797
		do -- 814
			local _accum_0 = { } -- 814
			local _len_0 = 1 -- 814
			for name, ext in pairs(names) do -- 814
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 814
				_len_0 = _len_0 + 1 -- 814
			end -- 814
			files = _accum_0 -- 814
		end -- 814
		for _index_0 = 1, #files do -- 815
			local file = files[_index_0] -- 815
			if not children then -- 816
				children = { } -- 816
			end -- 816
			children[#children + 1] = { -- 818
				key = Path(path, file), -- 818
				dir = false, -- 819
				title = file, -- 820
				builtin = builtin -- 821
			} -- 817
		end -- 815
		if children then -- 823
			table.sort(children, function(a, b) -- 824
				if a.dir == b.dir then -- 825
					return a.title < b.title -- 826
				else -- 828
					return a.dir -- 828
				end -- 825
			end) -- 824
		end -- 823
		if isWorkspace and children then -- 829
			return children -- 830
		else -- 832
			return { -- 833
				key = path, -- 833
				dir = true, -- 834
				title = Path:getFilename(path), -- 835
				builtin = builtin, -- 836
				children = children -- 837
			} -- 832
		end -- 829
	end -- 782
	local zh = (App.locale:match("^zh") ~= nil) -- 839
	return { -- 841
		key = Content.writablePath, -- 841
		dir = true, -- 842
		root = true, -- 843
		title = "Assets", -- 844
		children = (function() -- 846
			local _tab_0 = { -- 846
				{ -- 847
					key = Path(Content.assetPath), -- 847
					dir = true, -- 848
					builtin = true, -- 849
					title = zh and "内置资源" or "Built-in", -- 850
					children = { -- 852
						(function() -- 852
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 852
							_with_0.title = zh and "说明文档" or "Readme" -- 853
							return _with_0 -- 852
						end)(), -- 852
						(function() -- 854
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 854
							_with_0.title = zh and "接口文档" or "API Doc" -- 855
							return _with_0 -- 854
						end)(), -- 854
						(function() -- 856
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 856
							_with_0.title = zh and "开发工具" or "Tools" -- 857
							return _with_0 -- 856
						end)(), -- 856
						(function() -- 858
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 858
							_with_0.title = zh and "字体" or "Font" -- 859
							return _with_0 -- 858
						end)(), -- 858
						(function() -- 860
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 860
							_with_0.title = zh and "程序库" or "Lib" -- 861
							if engineDev then -- 862
								local _list_0 = _with_0.children -- 863
								for _index_0 = 1, #_list_0 do -- 863
									local child = _list_0[_index_0] -- 863
									if not (child.title == "Dora") then -- 864
										goto _continue_0 -- 864
									end -- 864
									local title = zh and "zh-Hans" or "en" -- 865
									do -- 866
										local _accum_0 = { } -- 866
										local _len_0 = 1 -- 866
										local _list_1 = child.children -- 866
										for _index_1 = 1, #_list_1 do -- 866
											local c = _list_1[_index_1] -- 866
											if c.title ~= title then -- 866
												_accum_0[_len_0] = c -- 866
												_len_0 = _len_0 + 1 -- 866
											end -- 866
										end -- 866
										child.children = _accum_0 -- 866
									end -- 866
									break -- 867
									::_continue_0:: -- 864
								end -- 863
							else -- 869
								local _accum_0 = { } -- 869
								local _len_0 = 1 -- 869
								local _list_0 = _with_0.children -- 869
								for _index_0 = 1, #_list_0 do -- 869
									local child = _list_0[_index_0] -- 869
									if child.title ~= "Dora" then -- 869
										_accum_0[_len_0] = child -- 869
										_len_0 = _len_0 + 1 -- 869
									end -- 869
								end -- 869
								_with_0.children = _accum_0 -- 869
							end -- 862
							return _with_0 -- 860
						end)(), -- 860
						(function() -- 870
							if engineDev then -- 870
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 871
								local _obj_0 = _with_0.children -- 872
								_obj_0[#_obj_0 + 1] = { -- 873
									key = Path(Content.assetPath, "Script", "init.yue"), -- 873
									dir = false, -- 874
									builtin = true, -- 875
									title = "init.yue" -- 876
								} -- 872
								return _with_0 -- 871
							end -- 870
						end)() -- 870
					} -- 851
				} -- 846
			} -- 880
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 880
			local _idx_0 = #_tab_0 + 1 -- 880
			for _index_0 = 1, #_obj_0 do -- 880
				local _value_0 = _obj_0[_index_0] -- 880
				_tab_0[_idx_0] = _value_0 -- 880
				_idx_0 = _idx_0 + 1 -- 880
			end -- 880
			return _tab_0 -- 846
		end)() -- 845
	} -- 840
end) -- 777
HttpServer:postSchedule("/run", function(req) -- 884
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
			local asProj -- 885
			do -- 885
				local _obj_0 = req.body -- 885
				local _type_1 = type(_obj_0) -- 885
				if "table" == _type_1 or "userdata" == _type_1 then -- 885
					asProj = _obj_0.asProj -- 885
				end -- 885
			end -- 885
			if file ~= nil and asProj ~= nil then -- 885
				if not Content:isAbsolutePath(file) then -- 886
					local devFile = Path(Content.writablePath, file) -- 887
					if Content:exist(devFile) then -- 888
						file = devFile -- 888
					end -- 888
				end -- 886
				local Entry = require("Script.Dev.Entry") -- 889
				local workDir -- 890
				if asProj then -- 891
					workDir = getProjectDirFromFile(file) -- 892
					if workDir then -- 892
						Entry.allClear() -- 893
						local target = Path(workDir, "init") -- 894
						local success, err = Entry.enterEntryAsync({ -- 895
							entryName = "Project", -- 895
							fileName = target -- 895
						}) -- 895
						target = Path:getName(Path:getPath(target)) -- 896
						return { -- 897
							success = success, -- 897
							target = target, -- 897
							err = err -- 897
						} -- 897
					end -- 892
				else -- 899
					workDir = getProjectDirFromFile(file) -- 899
				end -- 891
				Entry.allClear() -- 900
				file = Path:replaceExt(file, "") -- 901
				local success, err = Entry.enterEntryAsync({ -- 903
					entryName = Path:getName(file), -- 903
					fileName = file, -- 904
					workDir = workDir -- 905
				}) -- 902
				return { -- 906
					success = success, -- 906
					err = err -- 906
				} -- 906
			end -- 885
		end -- 885
	end -- 885
	return { -- 884
		success = false -- 884
	} -- 884
end) -- 884
HttpServer:postSchedule("/stop", function() -- 908
	local Entry = require("Script.Dev.Entry") -- 909
	return { -- 910
		success = Entry.stop() -- 910
	} -- 910
end) -- 908
local minifyAsync -- 912
minifyAsync = function(sourcePath, minifyPath) -- 912
	if not Content:exist(sourcePath) then -- 913
		return -- 913
	end -- 913
	local Entry = require("Script.Dev.Entry") -- 914
	local errors = { } -- 915
	local files = Entry.getAllFiles(sourcePath, { -- 916
		"lua" -- 916
	}, true) -- 916
	do -- 917
		local _accum_0 = { } -- 917
		local _len_0 = 1 -- 917
		for _index_0 = 1, #files do -- 917
			local file = files[_index_0] -- 917
			if file:sub(1, 1) ~= '.' then -- 917
				_accum_0[_len_0] = file -- 917
				_len_0 = _len_0 + 1 -- 917
			end -- 917
		end -- 917
		files = _accum_0 -- 917
	end -- 917
	local paths -- 918
	do -- 918
		local _tbl_0 = { } -- 918
		for _index_0 = 1, #files do -- 918
			local file = files[_index_0] -- 918
			_tbl_0[Path:getPath(file)] = true -- 918
		end -- 918
		paths = _tbl_0 -- 918
	end -- 918
	for path in pairs(paths) do -- 919
		Content:mkdir(Path(minifyPath, path)) -- 919
	end -- 919
	local _ <close> = setmetatable({ }, { -- 920
		__close = function() -- 920
			package.loaded["luaminify.FormatMini"] = nil -- 921
			package.loaded["luaminify.ParseLua"] = nil -- 922
			package.loaded["luaminify.Scope"] = nil -- 923
			package.loaded["luaminify.Util"] = nil -- 924
		end -- 920
	}) -- 920
	local FormatMini -- 925
	do -- 925
		local _obj_0 = require("luaminify") -- 925
		FormatMini = _obj_0.FormatMini -- 925
	end -- 925
	local fileCount = #files -- 926
	local count = 0 -- 927
	for _index_0 = 1, #files do -- 928
		local file = files[_index_0] -- 928
		thread(function() -- 929
			local _ <close> = setmetatable({ }, { -- 930
				__close = function() -- 930
					count = count + 1 -- 930
				end -- 930
			}) -- 930
			local input = Path(sourcePath, file) -- 931
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 932
			if Content:exist(input) then -- 933
				local sourceCodes = Content:loadAsync(input) -- 934
				local res, err = FormatMini(sourceCodes) -- 935
				if res then -- 936
					Content:saveAsync(output, res) -- 937
					return print("Minify " .. tostring(file)) -- 938
				else -- 940
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 940
				end -- 936
			else -- 942
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 942
			end -- 933
		end) -- 929
		sleep() -- 943
	end -- 928
	wait(function() -- 944
		return count == fileCount -- 944
	end) -- 944
	if #errors > 0 then -- 945
		print(table.concat(errors, '\n')) -- 946
	end -- 945
	print("Obfuscation done.") -- 947
	return files -- 948
end -- 912
local zipping = false -- 950
HttpServer:postSchedule("/zip", function(req) -- 952
	do -- 953
		local _type_0 = type(req) -- 953
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 953
		if _tab_0 then -- 953
			local path -- 953
			do -- 953
				local _obj_0 = req.body -- 953
				local _type_1 = type(_obj_0) -- 953
				if "table" == _type_1 or "userdata" == _type_1 then -- 953
					path = _obj_0.path -- 953
				end -- 953
			end -- 953
			local zipFile -- 953
			do -- 953
				local _obj_0 = req.body -- 953
				local _type_1 = type(_obj_0) -- 953
				if "table" == _type_1 or "userdata" == _type_1 then -- 953
					zipFile = _obj_0.zipFile -- 953
				end -- 953
			end -- 953
			local obfuscated -- 953
			do -- 953
				local _obj_0 = req.body -- 953
				local _type_1 = type(_obj_0) -- 953
				if "table" == _type_1 or "userdata" == _type_1 then -- 953
					obfuscated = _obj_0.obfuscated -- 953
				end -- 953
			end -- 953
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 953
				if zipping then -- 954
					goto failed -- 954
				end -- 954
				zipping = true -- 955
				local _ <close> = setmetatable({ }, { -- 956
					__close = function() -- 956
						zipping = false -- 956
					end -- 956
				}) -- 956
				if not Content:exist(path) then -- 957
					goto failed -- 957
				end -- 957
				Content:mkdir(Path:getPath(zipFile)) -- 958
				if obfuscated then -- 959
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 960
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 961
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 962
					Content:remove(scriptPath) -- 963
					Content:remove(obfuscatedPath) -- 964
					Content:remove(tempPath) -- 965
					Content:mkdir(scriptPath) -- 966
					Content:mkdir(obfuscatedPath) -- 967
					Content:mkdir(tempPath) -- 968
					if not Content:copyAsync(path, tempPath) then -- 969
						goto failed -- 969
					end -- 969
					local Entry = require("Script.Dev.Entry") -- 970
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 971
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 972
						"tl", -- 972
						"yue", -- 972
						"lua", -- 972
						"ts", -- 972
						"tsx", -- 972
						"vs", -- 972
						"bl", -- 972
						"xml", -- 972
						"wa", -- 972
						"mod" -- 972
					}, true) -- 972
					for _index_0 = 1, #scriptFiles do -- 973
						local file = scriptFiles[_index_0] -- 973
						Content:remove(Path(tempPath, file)) -- 974
					end -- 973
					for _index_0 = 1, #luaFiles do -- 975
						local file = luaFiles[_index_0] -- 975
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 976
					end -- 975
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 977
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 978
					end) then -- 977
						goto failed -- 977
					end -- 977
					return { -- 979
						success = true -- 979
					} -- 979
				else -- 981
					return { -- 981
						success = Content:zipAsync(path, zipFile, function(file) -- 981
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 982
						end) -- 981
					} -- 981
				end -- 959
			end -- 953
		end -- 953
	end -- 953
	::failed:: -- 983
	return { -- 952
		success = false -- 952
	} -- 952
end) -- 952
HttpServer:postSchedule("/unzip", function(req) -- 985
	do -- 986
		local _type_0 = type(req) -- 986
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 986
		if _tab_0 then -- 986
			local zipFile -- 986
			do -- 986
				local _obj_0 = req.body -- 986
				local _type_1 = type(_obj_0) -- 986
				if "table" == _type_1 or "userdata" == _type_1 then -- 986
					zipFile = _obj_0.zipFile -- 986
				end -- 986
			end -- 986
			local path -- 986
			do -- 986
				local _obj_0 = req.body -- 986
				local _type_1 = type(_obj_0) -- 986
				if "table" == _type_1 or "userdata" == _type_1 then -- 986
					path = _obj_0.path -- 986
				end -- 986
			end -- 986
			if zipFile ~= nil and path ~= nil then -- 986
				return { -- 987
					success = Content:unzipAsync(zipFile, path, function(file) -- 987
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 988
					end) -- 987
				} -- 987
			end -- 986
		end -- 986
	end -- 986
	return { -- 985
		success = false -- 985
	} -- 985
end) -- 985
HttpServer:post("/editing-info", function(req) -- 990
	local Entry = require("Script.Dev.Entry") -- 991
	local config = Entry.getConfig() -- 992
	local _type_0 = type(req) -- 993
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 993
	local _match_0 = false -- 993
	if _tab_0 then -- 993
		local editingInfo -- 993
		do -- 993
			local _obj_0 = req.body -- 993
			local _type_1 = type(_obj_0) -- 993
			if "table" == _type_1 or "userdata" == _type_1 then -- 993
				editingInfo = _obj_0.editingInfo -- 993
			end -- 993
		end -- 993
		if editingInfo ~= nil then -- 993
			_match_0 = true -- 993
			config.editingInfo = editingInfo -- 994
			return { -- 995
				success = true -- 995
			} -- 995
		end -- 993
	end -- 993
	if not _match_0 then -- 993
		if not (config.editingInfo ~= nil) then -- 997
			local folder -- 998
			if App.locale:match('^zh') then -- 998
				folder = 'zh-Hans' -- 998
			else -- 998
				folder = 'en' -- 998
			end -- 998
			config.editingInfo = json.encode({ -- 1000
				index = 0, -- 1000
				files = { -- 1002
					{ -- 1003
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1003
						title = "welcome.md" -- 1004
					} -- 1002
				} -- 1001
			}) -- 999
		end -- 997
		return { -- 1008
			success = true, -- 1008
			editingInfo = config.editingInfo -- 1008
		} -- 1008
	end -- 993
end) -- 990
HttpServer:post("/command", function(req) -- 1010
	do -- 1011
		local _type_0 = type(req) -- 1011
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1011
		if _tab_0 then -- 1011
			local code -- 1011
			do -- 1011
				local _obj_0 = req.body -- 1011
				local _type_1 = type(_obj_0) -- 1011
				if "table" == _type_1 or "userdata" == _type_1 then -- 1011
					code = _obj_0.code -- 1011
				end -- 1011
			end -- 1011
			local log -- 1011
			do -- 1011
				local _obj_0 = req.body -- 1011
				local _type_1 = type(_obj_0) -- 1011
				if "table" == _type_1 or "userdata" == _type_1 then -- 1011
					log = _obj_0.log -- 1011
				end -- 1011
			end -- 1011
			if code ~= nil and log ~= nil then -- 1011
				emit("AppCommand", code, log) -- 1012
				return { -- 1013
					success = true -- 1013
				} -- 1013
			end -- 1011
		end -- 1011
	end -- 1011
	return { -- 1010
		success = false -- 1010
	} -- 1010
end) -- 1010
HttpServer:post("/log/save", function() -- 1015
	local folder = ".download" -- 1016
	local fullLogFile = "dora_full_logs.txt" -- 1017
	local fullFolder = Path(Content.writablePath, folder) -- 1018
	Content:mkdir(fullFolder) -- 1019
	local logPath = Path(fullFolder, fullLogFile) -- 1020
	if App:saveLog(logPath) then -- 1021
		return { -- 1022
			success = true, -- 1022
			path = Path(folder, fullLogFile) -- 1022
		} -- 1022
	end -- 1021
	return { -- 1015
		success = false -- 1015
	} -- 1015
end) -- 1015
HttpServer:post("/yarn/check", function(req) -- 1024
	local yarncompile = require("yarncompile") -- 1025
	do -- 1026
		local _type_0 = type(req) -- 1026
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1026
		if _tab_0 then -- 1026
			local code -- 1026
			do -- 1026
				local _obj_0 = req.body -- 1026
				local _type_1 = type(_obj_0) -- 1026
				if "table" == _type_1 or "userdata" == _type_1 then -- 1026
					code = _obj_0.code -- 1026
				end -- 1026
			end -- 1026
			if code ~= nil then -- 1026
				local jsonObject = json.decode(code) -- 1027
				if jsonObject then -- 1027
					local errors = { } -- 1028
					local _list_0 = jsonObject.nodes -- 1029
					for _index_0 = 1, #_list_0 do -- 1029
						local node = _list_0[_index_0] -- 1029
						local title, body = node.title, node.body -- 1030
						local luaCode, err = yarncompile(body) -- 1031
						if not luaCode then -- 1031
							errors[#errors + 1] = title .. ":" .. err -- 1032
						end -- 1031
					end -- 1029
					return { -- 1033
						success = true, -- 1033
						syntaxError = table.concat(errors, "\n\n") -- 1033
					} -- 1033
				end -- 1027
			end -- 1026
		end -- 1026
	end -- 1026
	return { -- 1024
		success = false -- 1024
	} -- 1024
end) -- 1024
HttpServer:post("/yarn/check-file", function(req) -- 1035
	local yarncompile = require("yarncompile") -- 1036
	do -- 1037
		local _type_0 = type(req) -- 1037
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1037
		if _tab_0 then -- 1037
			local code -- 1037
			do -- 1037
				local _obj_0 = req.body -- 1037
				local _type_1 = type(_obj_0) -- 1037
				if "table" == _type_1 or "userdata" == _type_1 then -- 1037
					code = _obj_0.code -- 1037
				end -- 1037
			end -- 1037
			if code ~= nil then -- 1037
				local res, _, err = yarncompile(code, true) -- 1038
				if not res then -- 1038
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1039
					return { -- 1040
						success = false, -- 1040
						message = message, -- 1040
						line = line, -- 1040
						column = column, -- 1040
						node = node -- 1040
					} -- 1040
				end -- 1038
			end -- 1037
		end -- 1037
	end -- 1037
	return { -- 1035
		success = true -- 1035
	} -- 1035
end) -- 1035
local getWaProjectDirFromFile -- 1042
getWaProjectDirFromFile = function(file) -- 1042
	local writablePath = Content.writablePath -- 1043
	local parent, current -- 1044
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1044
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1045
	else -- 1047
		parent, current = nil, nil -- 1047
	end -- 1044
	if not current then -- 1048
		return nil -- 1048
	end -- 1048
	repeat -- 1049
		current = Path:getPath(current) -- 1050
		if current == "" then -- 1051
			break -- 1051
		end -- 1051
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1052
		for _index_0 = 1, #_list_0 do -- 1052
			local f = _list_0[_index_0] -- 1052
			if Path:getFilename(f):lower() == "wa.mod" then -- 1053
				return Path(parent, current, Path:getPath(f)) -- 1054
			end -- 1053
		end -- 1052
	until false -- 1049
	return nil -- 1056
end -- 1042
HttpServer:postSchedule("/wa/build", function(req) -- 1058
	do -- 1059
		local _type_0 = type(req) -- 1059
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1059
		if _tab_0 then -- 1059
			local path -- 1059
			do -- 1059
				local _obj_0 = req.body -- 1059
				local _type_1 = type(_obj_0) -- 1059
				if "table" == _type_1 or "userdata" == _type_1 then -- 1059
					path = _obj_0.path -- 1059
				end -- 1059
			end -- 1059
			if path ~= nil then -- 1059
				local projDir = getWaProjectDirFromFile(path) -- 1060
				if projDir then -- 1060
					local message = Wasm:buildWaAsync(projDir) -- 1061
					if message == "" then -- 1062
						return { -- 1063
							success = true -- 1063
						} -- 1063
					else -- 1065
						return { -- 1065
							success = false, -- 1065
							message = message -- 1065
						} -- 1065
					end -- 1062
				else -- 1067
					return { -- 1067
						success = false, -- 1067
						message = 'Wa file needs a project' -- 1067
					} -- 1067
				end -- 1060
			end -- 1059
		end -- 1059
	end -- 1059
	return { -- 1068
		success = false, -- 1068
		message = 'failed to build' -- 1068
	} -- 1068
end) -- 1058
HttpServer:postSchedule("/wa/format", function(req) -- 1070
	do -- 1071
		local _type_0 = type(req) -- 1071
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1071
		if _tab_0 then -- 1071
			local file -- 1071
			do -- 1071
				local _obj_0 = req.body -- 1071
				local _type_1 = type(_obj_0) -- 1071
				if "table" == _type_1 or "userdata" == _type_1 then -- 1071
					file = _obj_0.file -- 1071
				end -- 1071
			end -- 1071
			if file ~= nil then -- 1071
				local code = Wasm:formatWaAsync(file) -- 1072
				if code == "" then -- 1073
					return { -- 1074
						success = false -- 1074
					} -- 1074
				else -- 1076
					return { -- 1076
						success = true, -- 1076
						code = code -- 1076
					} -- 1076
				end -- 1073
			end -- 1071
		end -- 1071
	end -- 1071
	return { -- 1077
		success = false -- 1077
	} -- 1077
end) -- 1070
HttpServer:postSchedule("/wa/create", function(req) -- 1079
	do -- 1080
		local _type_0 = type(req) -- 1080
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1080
		if _tab_0 then -- 1080
			local path -- 1080
			do -- 1080
				local _obj_0 = req.body -- 1080
				local _type_1 = type(_obj_0) -- 1080
				if "table" == _type_1 or "userdata" == _type_1 then -- 1080
					path = _obj_0.path -- 1080
				end -- 1080
			end -- 1080
			if path ~= nil then -- 1080
				if not Content:exist(Path:getPath(path)) then -- 1081
					return { -- 1082
						success = false, -- 1082
						message = "target path not existed" -- 1082
					} -- 1082
				end -- 1081
				if Content:exist(path) then -- 1083
					return { -- 1084
						success = false, -- 1084
						message = "target project folder existed" -- 1084
					} -- 1084
				end -- 1083
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1085
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1086
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1087
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1088
					return { -- 1091
						success = false, -- 1091
						message = "missing template project" -- 1091
					} -- 1091
				end -- 1088
				if not Content:mkdir(path) then -- 1092
					return { -- 1093
						success = false, -- 1093
						message = "failed to create project folder" -- 1093
					} -- 1093
				end -- 1092
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1094
					Content:remove(path) -- 1095
					return { -- 1096
						success = false, -- 1096
						message = "failed to copy template" -- 1096
					} -- 1096
				end -- 1094
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1097
					Content:remove(path) -- 1098
					return { -- 1099
						success = false, -- 1099
						message = "failed to copy template" -- 1099
					} -- 1099
				end -- 1097
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1100
					Content:remove(path) -- 1101
					return { -- 1102
						success = false, -- 1102
						message = "failed to copy template" -- 1102
					} -- 1102
				end -- 1100
				return { -- 1103
					success = true -- 1103
				} -- 1103
			end -- 1080
		end -- 1080
	end -- 1080
	return { -- 1079
		success = false, -- 1079
		message = "invalid call" -- 1079
	} -- 1079
end) -- 1079
local _anon_func_3 = function(path) -- 1112
	local _val_0 = Path:getExt(path) -- 1112
	return "ts" == _val_0 or "tsx" == _val_0 -- 1112
end -- 1112
local _anon_func_4 = function(f) -- 1142
	local _val_0 = Path:getExt(f) -- 1142
	return "ts" == _val_0 or "tsx" == _val_0 -- 1142
end -- 1142
HttpServer:postSchedule("/ts/build", function(req) -- 1105
	do -- 1106
		local _type_0 = type(req) -- 1106
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1106
		if _tab_0 then -- 1106
			local path -- 1106
			do -- 1106
				local _obj_0 = req.body -- 1106
				local _type_1 = type(_obj_0) -- 1106
				if "table" == _type_1 or "userdata" == _type_1 then -- 1106
					path = _obj_0.path -- 1106
				end -- 1106
			end -- 1106
			if path ~= nil then -- 1106
				if HttpServer.wsConnectionCount == 0 then -- 1107
					return { -- 1108
						success = false, -- 1108
						message = "Web IDE not connected" -- 1108
					} -- 1108
				end -- 1107
				if not Content:exist(path) then -- 1109
					return { -- 1110
						success = false, -- 1110
						message = "path not existed" -- 1110
					} -- 1110
				end -- 1109
				if not Content:isdir(path) then -- 1111
					if not (_anon_func_3(path)) then -- 1112
						return { -- 1113
							success = false, -- 1113
							message = "expecting a TypeScript file" -- 1113
						} -- 1113
					end -- 1112
					local messages = { } -- 1114
					local content = Content:load(path) -- 1115
					if not content then -- 1116
						return { -- 1117
							success = false, -- 1117
							message = "failed to read file" -- 1117
						} -- 1117
					end -- 1116
					emit("AppWS", "Send", json.encode({ -- 1118
						name = "UpdateTSCode", -- 1118
						file = path, -- 1118
						content = content -- 1118
					})) -- 1118
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1119
						local done = false -- 1120
						do -- 1121
							local _with_0 = Node() -- 1121
							_with_0:gslot("AppWS", function(eventType, msg) -- 1122
								if eventType == "Receive" then -- 1123
									_with_0:removeFromParent() -- 1124
									local res = json.decode(msg) -- 1125
									if res then -- 1125
										if res.name == "TranspileTS" then -- 1126
											if res.success then -- 1127
												local luaFile = Path:replaceExt(path, "lua") -- 1128
												Content:save(luaFile, res.luaCode) -- 1129
												messages[#messages + 1] = { -- 1130
													success = true, -- 1130
													file = path -- 1130
												} -- 1130
											else -- 1132
												messages[#messages + 1] = { -- 1132
													success = false, -- 1132
													file = path, -- 1132
													message = res.message -- 1132
												} -- 1132
											end -- 1127
											done = true -- 1133
										end -- 1126
									end -- 1125
								end -- 1123
							end) -- 1122
						end -- 1121
						emit("AppWS", "Send", json.encode({ -- 1134
							name = "TranspileTS", -- 1134
							file = path, -- 1134
							content = content -- 1134
						})) -- 1134
						wait(function() -- 1135
							return done -- 1135
						end) -- 1135
					end -- 1119
					return { -- 1136
						success = true, -- 1136
						messages = messages -- 1136
					} -- 1136
				else -- 1138
					local files = Content:getAllFiles(path) -- 1138
					local fileData = { } -- 1139
					local messages = { } -- 1140
					for _index_0 = 1, #files do -- 1141
						local f = files[_index_0] -- 1141
						if not (_anon_func_4(f)) then -- 1142
							goto _continue_0 -- 1142
						end -- 1142
						local file = Path(path, f) -- 1143
						local content = Content:load(file) -- 1144
						if content then -- 1144
							fileData[file] = content -- 1145
							emit("AppWS", "Send", json.encode({ -- 1146
								name = "UpdateTSCode", -- 1146
								file = file, -- 1146
								content = content -- 1146
							})) -- 1146
						else -- 1148
							messages[#messages + 1] = { -- 1148
								success = false, -- 1148
								file = file, -- 1148
								message = "failed to read file" -- 1148
							} -- 1148
						end -- 1144
						::_continue_0:: -- 1142
					end -- 1141
					for file, content in pairs(fileData) do -- 1149
						if "d" == Path:getExt(Path:getName(file)) then -- 1150
							goto _continue_1 -- 1150
						end -- 1150
						local done = false -- 1151
						do -- 1152
							local _with_0 = Node() -- 1152
							_with_0:gslot("AppWS", function(eventType, msg) -- 1153
								if eventType == "Receive" then -- 1154
									_with_0:removeFromParent() -- 1155
									local res = json.decode(msg) -- 1156
									if res then -- 1156
										if res.name == "TranspileTS" then -- 1157
											if res.success then -- 1158
												local luaFile = Path:replaceExt(file, "lua") -- 1159
												Content:save(luaFile, res.luaCode) -- 1160
												messages[#messages + 1] = { -- 1161
													success = true, -- 1161
													file = file -- 1161
												} -- 1161
											else -- 1163
												messages[#messages + 1] = { -- 1163
													success = false, -- 1163
													file = file, -- 1163
													message = res.message -- 1163
												} -- 1163
											end -- 1158
											done = true -- 1164
										end -- 1157
									end -- 1156
								end -- 1154
							end) -- 1153
						end -- 1152
						emit("AppWS", "Send", json.encode({ -- 1165
							name = "TranspileTS", -- 1165
							file = file, -- 1165
							content = content -- 1165
						})) -- 1165
						wait(function() -- 1166
							return done -- 1166
						end) -- 1166
						::_continue_1:: -- 1150
					end -- 1149
					return { -- 1167
						success = true, -- 1167
						messages = messages -- 1167
					} -- 1167
				end -- 1111
			end -- 1106
		end -- 1106
	end -- 1106
	return { -- 1105
		success = false -- 1105
	} -- 1105
end) -- 1105
HttpServer:post("/download", function(req) -- 1169
	do -- 1170
		local _type_0 = type(req) -- 1170
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1170
		if _tab_0 then -- 1170
			local url -- 1170
			do -- 1170
				local _obj_0 = req.body -- 1170
				local _type_1 = type(_obj_0) -- 1170
				if "table" == _type_1 or "userdata" == _type_1 then -- 1170
					url = _obj_0.url -- 1170
				end -- 1170
			end -- 1170
			local target -- 1170
			do -- 1170
				local _obj_0 = req.body -- 1170
				local _type_1 = type(_obj_0) -- 1170
				if "table" == _type_1 or "userdata" == _type_1 then -- 1170
					target = _obj_0.target -- 1170
				end -- 1170
			end -- 1170
			if url ~= nil and target ~= nil then -- 1170
				local Entry = require("Script.Dev.Entry") -- 1171
				Entry.downloadFile(url, target) -- 1172
				return { -- 1173
					success = true -- 1173
				} -- 1173
			end -- 1170
		end -- 1170
	end -- 1170
	return { -- 1169
		success = false -- 1169
	} -- 1169
end) -- 1169
local status = { } -- 1175
_module_0 = status -- 1176
thread(function() -- 1178
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1179
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1180
	if Content:exist(doraWeb) then -- 1181
		local needReload -- 1182
		if Content:exist(doraReady) then -- 1182
			needReload = App.version ~= Content:load(doraReady) -- 1183
		else -- 1184
			needReload = true -- 1184
		end -- 1182
		if needReload then -- 1185
			Content:remove(Path(Content.appPath, ".www")) -- 1186
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1187
			Content:save(doraReady, App.version) -- 1191
			print("Dora Dora is ready!") -- 1192
		end -- 1185
	end -- 1181
	if HttpServer:start(8866) then -- 1193
		local localIP = HttpServer.localIP -- 1194
		if localIP == "" then -- 1195
			localIP = "localhost" -- 1195
		end -- 1195
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1196
		return HttpServer:startWS(8868) -- 1197
	else -- 1199
		status.url = nil -- 1199
		return print("8866 Port not available!") -- 1200
	end -- 1193
end) -- 1178
return _module_0 -- 1
