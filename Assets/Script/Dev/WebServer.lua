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
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(luaCodes) -- 86
		else -- 87
			for _index_0 = 1, #lintResult do -- 87
				local _des_0 = lintResult[_index_0] -- 87
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 87
				if isTIC80 and tic80APIs[name] then -- 88
					goto _continue_0 -- 88
				end -- 88
				info[#info + 1] = { -- 89
					"syntax", -- 89
					file, -- 89
					line, -- 89
					col, -- 89
					"invalid global variable" -- 89
				} -- 89
				::_continue_0:: -- 88
			end -- 87
		end -- 85
	end -- 83
	return luaCodes, info -- 90
end -- 70
local luaCheck -- 92
luaCheck = function(file, content) -- 92
	local res, err = load(content, "check") -- 93
	if not res then -- 94
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 95
		return { -- 96
			success = false, -- 96
			info = { -- 96
				{ -- 96
					"syntax", -- 96
					file, -- 96
					tonumber(line), -- 96
					0, -- 96
					msg -- 96
				} -- 96
			} -- 96
		} -- 96
	end -- 94
	local success, info = teal.checkAsync(content, file, true, "") -- 97
	if info then -- 98
		do -- 99
			local _accum_0 = { } -- 99
			local _len_0 = 1 -- 99
			for _index_0 = 1, #info do -- 99
				local item = info[_index_0] -- 99
				local useCheck = true -- 100
				if not item[5]:match("unused") then -- 101
					for _index_1 = 1, #disabledCheckForLua do -- 102
						local check = disabledCheckForLua[_index_1] -- 102
						if item[5]:match(check) then -- 103
							useCheck = false -- 104
						end -- 103
					end -- 102
				end -- 101
				if not useCheck then -- 105
					goto _continue_0 -- 105
				end -- 105
				do -- 106
					local _exp_0 = item[1] -- 106
					if "type" == _exp_0 then -- 107
						item[1] = "warning" -- 108
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 109
						goto _continue_0 -- 110
					end -- 106
				end -- 106
				_accum_0[_len_0] = item -- 111
				_len_0 = _len_0 + 1 -- 100
				::_continue_0:: -- 100
			end -- 99
			info = _accum_0 -- 99
		end -- 99
		if #info == 0 then -- 112
			info = nil -- 113
			success = true -- 114
		end -- 112
	end -- 98
	return { -- 115
		success = success, -- 115
		info = info -- 115
	} -- 115
end -- 92
local luaCheckWithLineInfo -- 117
luaCheckWithLineInfo = function(file, luaCodes) -- 117
	local res = luaCheck(file, luaCodes) -- 118
	local info = { } -- 119
	if not res.success then -- 120
		local current = 1 -- 121
		local lastLine = 1 -- 122
		local lineMap = { } -- 123
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 124
			local num = lineCode:match("--%s*(%d+)%s*$") -- 125
			if num then -- 126
				lastLine = tonumber(num) -- 127
			end -- 126
			lineMap[current] = lastLine -- 128
			current = current + 1 -- 129
		end -- 124
		local _list_0 = res.info -- 130
		for _index_0 = 1, #_list_0 do -- 130
			local item = _list_0[_index_0] -- 130
			item[3] = lineMap[item[3]] or 0 -- 131
			item[4] = 0 -- 132
			info[#info + 1] = item -- 133
		end -- 130
		return false, info -- 134
	end -- 120
	return true, info -- 135
end -- 117
local getCompiledYueLine -- 137
getCompiledYueLine = function(content, line, row, file, lax) -- 137
	local luaCodes = yueCheck(file, content, lax) -- 138
	if not luaCodes then -- 139
		return nil -- 139
	end -- 139
	local current = 1 -- 140
	local lastLine = 1 -- 141
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 142
	local targetRow = nil -- 143
	local lineMap = { } -- 144
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 145
		local num = lineCode:match("--%s*(%d+)%s*$") -- 146
		if num then -- 147
			lastLine = tonumber(num) -- 147
		end -- 147
		lineMap[current] = lastLine -- 148
		if row <= lastLine and not targetRow then -- 149
			targetRow = current -- 150
			break -- 151
		end -- 149
		current = current + 1 -- 152
	end -- 145
	targetRow = current -- 153
	if targetLine and targetRow then -- 154
		return luaCodes, targetLine, targetRow, lineMap -- 155
	else -- 157
		return nil -- 157
	end -- 154
end -- 137
HttpServer:postSchedule("/check", function(req) -- 159
	do -- 160
		local _type_0 = type(req) -- 160
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 160
		if _tab_0 then -- 160
			local file -- 160
			do -- 160
				local _obj_0 = req.body -- 160
				local _type_1 = type(_obj_0) -- 160
				if "table" == _type_1 or "userdata" == _type_1 then -- 160
					file = _obj_0.file -- 160
				end -- 160
			end -- 160
			local content -- 160
			do -- 160
				local _obj_0 = req.body -- 160
				local _type_1 = type(_obj_0) -- 160
				if "table" == _type_1 or "userdata" == _type_1 then -- 160
					content = _obj_0.content -- 160
				end -- 160
			end -- 160
			if file ~= nil and content ~= nil then -- 160
				local ext = Path:getExt(file) -- 161
				if "tl" == ext then -- 162
					local searchPath = getSearchPath(file) -- 163
					do -- 164
						local isTIC80 = CheckTIC80Code(content) -- 164
						if isTIC80 then -- 164
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 165
						end -- 164
					end -- 164
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 166
					return { -- 167
						success = success, -- 167
						info = info -- 167
					} -- 167
				elseif "lua" == ext then -- 168
					do -- 169
						local isTIC80 = CheckTIC80Code(content) -- 169
						if isTIC80 then -- 169
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 170
						end -- 169
					end -- 169
					return luaCheck(file, content) -- 171
				elseif "yue" == ext then -- 172
					local luaCodes, info = yueCheck(file, content, false) -- 173
					local success = false -- 174
					if luaCodes then -- 175
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 176
						do -- 177
							local _tab_1 = { } -- 177
							local _idx_0 = #_tab_1 + 1 -- 177
							for _index_0 = 1, #info do -- 177
								local _value_0 = info[_index_0] -- 177
								_tab_1[_idx_0] = _value_0 -- 177
								_idx_0 = _idx_0 + 1 -- 177
							end -- 177
							local _idx_1 = #_tab_1 + 1 -- 177
							for _index_0 = 1, #luaInfo do -- 177
								local _value_0 = luaInfo[_index_0] -- 177
								_tab_1[_idx_1] = _value_0 -- 177
								_idx_1 = _idx_1 + 1 -- 177
							end -- 177
							info = _tab_1 -- 177
						end -- 177
						success = success and luaSuccess -- 178
					end -- 175
					if #info > 0 then -- 179
						return { -- 180
							success = success, -- 180
							info = info -- 180
						} -- 180
					else -- 182
						return { -- 182
							success = success -- 182
						} -- 182
					end -- 179
				elseif "xml" == ext then -- 183
					local success, result = xml.check(content) -- 184
					if success then -- 185
						local info -- 186
						success, info = luaCheckWithLineInfo(file, result) -- 186
						if #info > 0 then -- 187
							return { -- 188
								success = success, -- 188
								info = info -- 188
							} -- 188
						else -- 190
							return { -- 190
								success = success -- 190
							} -- 190
						end -- 187
					else -- 192
						local info -- 192
						do -- 192
							local _accum_0 = { } -- 192
							local _len_0 = 1 -- 192
							for _index_0 = 1, #result do -- 192
								local _des_0 = result[_index_0] -- 192
								local row, err = _des_0[1], _des_0[2] -- 192
								_accum_0[_len_0] = { -- 193
									"syntax", -- 193
									file, -- 193
									row, -- 193
									0, -- 193
									err -- 193
								} -- 193
								_len_0 = _len_0 + 1 -- 193
							end -- 192
							info = _accum_0 -- 192
						end -- 192
						return { -- 194
							success = false, -- 194
							info = info -- 194
						} -- 194
					end -- 185
				end -- 162
			end -- 160
		end -- 160
	end -- 160
	return { -- 159
		success = true -- 159
	} -- 159
end) -- 159
local updateInferedDesc -- 196
updateInferedDesc = function(infered) -- 196
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 197
		return -- 197
	end -- 197
	local key, row = infered.key, infered.row -- 198
	local codes = Content:loadAsync(key) -- 199
	if codes then -- 199
		local comments = { } -- 200
		local line = 0 -- 201
		local skipping = false -- 202
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 203
			line = line + 1 -- 204
			if line >= row then -- 205
				break -- 205
			end -- 205
			if lineCode:match("^%s*%-%- @") then -- 206
				skipping = true -- 207
				goto _continue_0 -- 208
			end -- 206
			local result = lineCode:match("^%s*%-%- (.+)") -- 209
			if result then -- 209
				if not skipping then -- 210
					comments[#comments + 1] = result -- 210
				end -- 210
			elseif #comments > 0 then -- 211
				comments = { } -- 212
				skipping = false -- 213
			end -- 209
			::_continue_0:: -- 204
		end -- 203
		infered.doc = table.concat(comments, "\n") -- 214
	end -- 199
end -- 196
HttpServer:postSchedule("/infer", function(req) -- 216
	do -- 217
		local _type_0 = type(req) -- 217
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 217
		if _tab_0 then -- 217
			local lang -- 217
			do -- 217
				local _obj_0 = req.body -- 217
				local _type_1 = type(_obj_0) -- 217
				if "table" == _type_1 or "userdata" == _type_1 then -- 217
					lang = _obj_0.lang -- 217
				end -- 217
			end -- 217
			local file -- 217
			do -- 217
				local _obj_0 = req.body -- 217
				local _type_1 = type(_obj_0) -- 217
				if "table" == _type_1 or "userdata" == _type_1 then -- 217
					file = _obj_0.file -- 217
				end -- 217
			end -- 217
			local content -- 217
			do -- 217
				local _obj_0 = req.body -- 217
				local _type_1 = type(_obj_0) -- 217
				if "table" == _type_1 or "userdata" == _type_1 then -- 217
					content = _obj_0.content -- 217
				end -- 217
			end -- 217
			local line -- 217
			do -- 217
				local _obj_0 = req.body -- 217
				local _type_1 = type(_obj_0) -- 217
				if "table" == _type_1 or "userdata" == _type_1 then -- 217
					line = _obj_0.line -- 217
				end -- 217
			end -- 217
			local row -- 217
			do -- 217
				local _obj_0 = req.body -- 217
				local _type_1 = type(_obj_0) -- 217
				if "table" == _type_1 or "userdata" == _type_1 then -- 217
					row = _obj_0.row -- 217
				end -- 217
			end -- 217
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 217
				local searchPath = getSearchPath(file) -- 218
				if "tl" == lang or "lua" == lang then -- 219
					if CheckTIC80Code(content) then -- 220
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 221
					end -- 220
					local infered = teal.inferAsync(content, line, row, searchPath) -- 222
					if (infered ~= nil) then -- 223
						updateInferedDesc(infered) -- 224
						return { -- 225
							success = true, -- 225
							infered = infered -- 225
						} -- 225
					end -- 223
				elseif "yue" == lang then -- 226
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 227
					if not luaCodes then -- 228
						return { -- 228
							success = false -- 228
						} -- 228
					end -- 228
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 229
					if (infered ~= nil) then -- 230
						local col -- 231
						file, row, col = infered.file, infered.row, infered.col -- 231
						if file == "" and row > 0 and col > 0 then -- 232
							infered.row = lineMap[row] or 0 -- 233
							infered.col = 0 -- 234
						end -- 232
						updateInferedDesc(infered) -- 235
						return { -- 236
							success = true, -- 236
							infered = infered -- 236
						} -- 236
					end -- 230
				end -- 219
			end -- 217
		end -- 217
	end -- 217
	return { -- 216
		success = false -- 216
	} -- 216
end) -- 216
local _anon_func_0 = function(doc) -- 287
	local _accum_0 = { } -- 287
	local _len_0 = 1 -- 287
	local _list_0 = doc.params -- 287
	for _index_0 = 1, #_list_0 do -- 287
		local param = _list_0[_index_0] -- 287
		_accum_0[_len_0] = param.name -- 287
		_len_0 = _len_0 + 1 -- 287
	end -- 287
	return _accum_0 -- 287
end -- 287
local getParamDocs -- 238
getParamDocs = function(signatures) -- 238
	do -- 239
		local codes = Content:loadAsync(signatures[1].file) -- 239
		if codes then -- 239
			local comments = { } -- 240
			local params = { } -- 241
			local line = 0 -- 242
			local docs = { } -- 243
			local returnType = nil -- 244
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 245
				line = line + 1 -- 246
				local needBreak = true -- 247
				for i, _des_0 in ipairs(signatures) do -- 248
					local row = _des_0.row -- 248
					if line >= row and not (docs[i] ~= nil) then -- 249
						if #comments > 0 or #params > 0 or returnType then -- 250
							docs[i] = { -- 252
								doc = table.concat(comments, "  \n"), -- 252
								returnType = returnType -- 253
							} -- 251
							if #params > 0 then -- 255
								docs[i].params = params -- 255
							end -- 255
						else -- 257
							docs[i] = false -- 257
						end -- 250
					end -- 249
					if not docs[i] then -- 258
						needBreak = false -- 258
					end -- 258
				end -- 248
				if needBreak then -- 259
					break -- 259
				end -- 259
				local result = lineCode:match("%s*%-%- (.+)") -- 260
				if result then -- 260
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 261
					if not name then -- 262
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 263
					end -- 262
					if name then -- 264
						local pname = name -- 265
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 266
							pname = pname .. "?" -- 266
						end -- 266
						params[#params + 1] = { -- 268
							name = tostring(pname) .. ": " .. tostring(typ), -- 268
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 269
						} -- 267
					else -- 272
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 272
						if typ then -- 272
							if returnType then -- 273
								returnType = returnType .. ", " .. typ -- 274
							else -- 276
								returnType = typ -- 276
							end -- 273
							result = result:gsub("@return", "**return:**") -- 277
						end -- 272
						comments[#comments + 1] = result -- 278
					end -- 264
				elseif #comments > 0 then -- 279
					comments = { } -- 280
					params = { } -- 281
					returnType = nil -- 282
				end -- 260
			end -- 245
			local results = { } -- 283
			for _index_0 = 1, #docs do -- 284
				local doc = docs[_index_0] -- 284
				if not doc then -- 285
					goto _continue_0 -- 285
				end -- 285
				if doc.params then -- 286
					doc.desc = "function(" .. tostring(table.concat(_anon_func_0(doc), ', ')) .. ")" -- 287
				else -- 289
					doc.desc = "function()" -- 289
				end -- 286
				if doc.returnType then -- 290
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 291
					doc.returnType = nil -- 292
				end -- 290
				results[#results + 1] = doc -- 293
				::_continue_0:: -- 285
			end -- 284
			if #results > 0 then -- 294
				return results -- 294
			else -- 294
				return nil -- 294
			end -- 294
		end -- 239
	end -- 239
	return nil -- 238
end -- 238
HttpServer:postSchedule("/signature", function(req) -- 296
	do -- 297
		local _type_0 = type(req) -- 297
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 297
		if _tab_0 then -- 297
			local lang -- 297
			do -- 297
				local _obj_0 = req.body -- 297
				local _type_1 = type(_obj_0) -- 297
				if "table" == _type_1 or "userdata" == _type_1 then -- 297
					lang = _obj_0.lang -- 297
				end -- 297
			end -- 297
			local file -- 297
			do -- 297
				local _obj_0 = req.body -- 297
				local _type_1 = type(_obj_0) -- 297
				if "table" == _type_1 or "userdata" == _type_1 then -- 297
					file = _obj_0.file -- 297
				end -- 297
			end -- 297
			local content -- 297
			do -- 297
				local _obj_0 = req.body -- 297
				local _type_1 = type(_obj_0) -- 297
				if "table" == _type_1 or "userdata" == _type_1 then -- 297
					content = _obj_0.content -- 297
				end -- 297
			end -- 297
			local line -- 297
			do -- 297
				local _obj_0 = req.body -- 297
				local _type_1 = type(_obj_0) -- 297
				if "table" == _type_1 or "userdata" == _type_1 then -- 297
					line = _obj_0.line -- 297
				end -- 297
			end -- 297
			local row -- 297
			do -- 297
				local _obj_0 = req.body -- 297
				local _type_1 = type(_obj_0) -- 297
				if "table" == _type_1 or "userdata" == _type_1 then -- 297
					row = _obj_0.row -- 297
				end -- 297
			end -- 297
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 297
				local searchPath = getSearchPath(file) -- 298
				if "tl" == lang or "lua" == lang then -- 299
					if CheckTIC80Code(content) then -- 300
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 301
					end -- 300
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 302
					if signatures then -- 302
						signatures = getParamDocs(signatures) -- 303
						if signatures then -- 303
							return { -- 304
								success = true, -- 304
								signatures = signatures -- 304
							} -- 304
						end -- 303
					end -- 302
				elseif "yue" == lang then -- 305
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 306
					if not luaCodes then -- 307
						return { -- 307
							success = false -- 307
						} -- 307
					end -- 307
					do -- 308
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 308
						if chainOp then -- 308
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 309
							if withVar then -- 309
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 310
							end -- 309
						end -- 308
					end -- 308
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 311
					if signatures then -- 311
						signatures = getParamDocs(signatures) -- 312
						if signatures then -- 312
							return { -- 313
								success = true, -- 313
								signatures = signatures -- 313
							} -- 313
						end -- 312
					else -- 314
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 314
						if signatures then -- 314
							signatures = getParamDocs(signatures) -- 315
							if signatures then -- 315
								return { -- 316
									success = true, -- 316
									signatures = signatures -- 316
								} -- 316
							end -- 315
						end -- 314
					end -- 311
				end -- 299
			end -- 297
		end -- 297
	end -- 297
	return { -- 296
		success = false -- 296
	} -- 296
end) -- 296
local luaKeywords = { -- 319
	'and', -- 319
	'break', -- 320
	'do', -- 321
	'else', -- 322
	'elseif', -- 323
	'end', -- 324
	'false', -- 325
	'for', -- 326
	'function', -- 327
	'goto', -- 328
	'if', -- 329
	'in', -- 330
	'local', -- 331
	'nil', -- 332
	'not', -- 333
	'or', -- 334
	'repeat', -- 335
	'return', -- 336
	'then', -- 337
	'true', -- 338
	'until', -- 339
	'while' -- 340
} -- 318
local tealKeywords = { -- 344
	'record', -- 344
	'as', -- 345
	'is', -- 346
	'type', -- 347
	'embed', -- 348
	'enum', -- 349
	'global', -- 350
	'any', -- 351
	'boolean', -- 352
	'integer', -- 353
	'number', -- 354
	'string', -- 355
	'thread' -- 356
} -- 343
local yueKeywords = { -- 360
	"and", -- 360
	"break", -- 361
	"do", -- 362
	"else", -- 363
	"elseif", -- 364
	"false", -- 365
	"for", -- 366
	"goto", -- 367
	"if", -- 368
	"in", -- 369
	"local", -- 370
	"nil", -- 371
	"not", -- 372
	"or", -- 373
	"repeat", -- 374
	"return", -- 375
	"then", -- 376
	"true", -- 377
	"until", -- 378
	"while", -- 379
	"as", -- 380
	"class", -- 381
	"continue", -- 382
	"export", -- 383
	"extends", -- 384
	"from", -- 385
	"global", -- 386
	"import", -- 387
	"macro", -- 388
	"switch", -- 389
	"try", -- 390
	"unless", -- 391
	"using", -- 392
	"when", -- 393
	"with" -- 394
} -- 359
local _anon_func_1 = function(f) -- 430
	local _val_0 = Path:getExt(f) -- 430
	return "ttf" == _val_0 or "otf" == _val_0 -- 430
end -- 430
local _anon_func_2 = function(suggestions) -- 456
	local _tbl_0 = { } -- 456
	for _index_0 = 1, #suggestions do -- 456
		local item = suggestions[_index_0] -- 456
		_tbl_0[item[1] .. item[2]] = item -- 456
	end -- 456
	return _tbl_0 -- 456
end -- 456
HttpServer:postSchedule("/complete", function(req) -- 397
	do -- 398
		local _type_0 = type(req) -- 398
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 398
		if _tab_0 then -- 398
			local lang -- 398
			do -- 398
				local _obj_0 = req.body -- 398
				local _type_1 = type(_obj_0) -- 398
				if "table" == _type_1 or "userdata" == _type_1 then -- 398
					lang = _obj_0.lang -- 398
				end -- 398
			end -- 398
			local file -- 398
			do -- 398
				local _obj_0 = req.body -- 398
				local _type_1 = type(_obj_0) -- 398
				if "table" == _type_1 or "userdata" == _type_1 then -- 398
					file = _obj_0.file -- 398
				end -- 398
			end -- 398
			local content -- 398
			do -- 398
				local _obj_0 = req.body -- 398
				local _type_1 = type(_obj_0) -- 398
				if "table" == _type_1 or "userdata" == _type_1 then -- 398
					content = _obj_0.content -- 398
				end -- 398
			end -- 398
			local line -- 398
			do -- 398
				local _obj_0 = req.body -- 398
				local _type_1 = type(_obj_0) -- 398
				if "table" == _type_1 or "userdata" == _type_1 then -- 398
					line = _obj_0.line -- 398
				end -- 398
			end -- 398
			local row -- 398
			do -- 398
				local _obj_0 = req.body -- 398
				local _type_1 = type(_obj_0) -- 398
				if "table" == _type_1 or "userdata" == _type_1 then -- 398
					row = _obj_0.row -- 398
				end -- 398
			end -- 398
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 398
				local searchPath = getSearchPath(file) -- 399
				repeat -- 400
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 401
					if lang == "yue" then -- 402
						if not item then -- 403
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 403
						end -- 403
						if not item then -- 404
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 404
						end -- 404
					end -- 402
					local searchType = nil -- 405
					if not item then -- 406
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 407
						if lang == "yue" then -- 408
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 409
						end -- 408
						if (item ~= nil) then -- 410
							searchType = "Image" -- 410
						end -- 410
					end -- 406
					if not item then -- 411
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 412
						if lang == "yue" then -- 413
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 414
						end -- 413
						if (item ~= nil) then -- 415
							searchType = "Font" -- 415
						end -- 415
					end -- 411
					if not item then -- 416
						break -- 416
					end -- 416
					local searchPaths = Content.searchPaths -- 417
					local _list_0 = getSearchFolders(file) -- 418
					for _index_0 = 1, #_list_0 do -- 418
						local folder = _list_0[_index_0] -- 418
						searchPaths[#searchPaths + 1] = folder -- 419
					end -- 418
					if searchType then -- 420
						searchPaths[#searchPaths + 1] = Content.assetPath -- 420
					end -- 420
					local tokens -- 421
					do -- 421
						local _accum_0 = { } -- 421
						local _len_0 = 1 -- 421
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 421
							_accum_0[_len_0] = mod -- 421
							_len_0 = _len_0 + 1 -- 421
						end -- 421
						tokens = _accum_0 -- 421
					end -- 421
					local suggestions = { } -- 422
					for _index_0 = 1, #searchPaths do -- 423
						local path = searchPaths[_index_0] -- 423
						local sPath = Path(path, table.unpack(tokens)) -- 424
						if not Content:exist(sPath) then -- 425
							goto _continue_0 -- 425
						end -- 425
						if searchType == "Font" then -- 426
							local fontPath = Path(sPath, "Font") -- 427
							if Content:exist(fontPath) then -- 428
								local _list_1 = Content:getFiles(fontPath) -- 429
								for _index_1 = 1, #_list_1 do -- 429
									local f = _list_1[_index_1] -- 429
									if _anon_func_1(f) then -- 430
										if "." == f:sub(1, 1) then -- 431
											goto _continue_1 -- 431
										end -- 431
										suggestions[#suggestions + 1] = { -- 432
											Path:getName(f), -- 432
											"font", -- 432
											"field" -- 432
										} -- 432
									end -- 430
									::_continue_1:: -- 430
								end -- 429
							end -- 428
						end -- 426
						local _list_1 = Content:getFiles(sPath) -- 433
						for _index_1 = 1, #_list_1 do -- 433
							local f = _list_1[_index_1] -- 433
							if "Image" == searchType then -- 434
								do -- 435
									local _exp_0 = Path:getExt(f) -- 435
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 435
										if "." == f:sub(1, 1) then -- 436
											goto _continue_2 -- 436
										end -- 436
										suggestions[#suggestions + 1] = { -- 437
											f, -- 437
											"image", -- 437
											"field" -- 437
										} -- 437
									end -- 435
								end -- 435
								goto _continue_2 -- 438
							elseif "Font" == searchType then -- 439
								do -- 440
									local _exp_0 = Path:getExt(f) -- 440
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 440
										if "." == f:sub(1, 1) then -- 441
											goto _continue_2 -- 441
										end -- 441
										suggestions[#suggestions + 1] = { -- 442
											f, -- 442
											"font", -- 442
											"field" -- 442
										} -- 442
									end -- 440
								end -- 440
								goto _continue_2 -- 443
							end -- 434
							local _exp_0 = Path:getExt(f) -- 444
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 444
								local name = Path:getName(f) -- 445
								if "d" == Path:getExt(name) then -- 446
									goto _continue_2 -- 446
								end -- 446
								if "." == name:sub(1, 1) then -- 447
									goto _continue_2 -- 447
								end -- 447
								suggestions[#suggestions + 1] = { -- 448
									name, -- 448
									"module", -- 448
									"field" -- 448
								} -- 448
							end -- 444
							::_continue_2:: -- 434
						end -- 433
						local _list_2 = Content:getDirs(sPath) -- 449
						for _index_1 = 1, #_list_2 do -- 449
							local dir = _list_2[_index_1] -- 449
							if "." == dir:sub(1, 1) then -- 450
								goto _continue_3 -- 450
							end -- 450
							suggestions[#suggestions + 1] = { -- 451
								dir, -- 451
								"folder", -- 451
								"variable" -- 451
							} -- 451
							::_continue_3:: -- 450
						end -- 449
						::_continue_0:: -- 424
					end -- 423
					if item == "" and not searchType then -- 452
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 453
						for _index_0 = 1, #_list_1 do -- 453
							local _des_0 = _list_1[_index_0] -- 453
							local name = _des_0[1] -- 453
							suggestions[#suggestions + 1] = { -- 454
								name, -- 454
								"dora module", -- 454
								"function" -- 454
							} -- 454
						end -- 453
					end -- 452
					if #suggestions > 0 then -- 455
						do -- 456
							local _accum_0 = { } -- 456
							local _len_0 = 1 -- 456
							for _, v in pairs(_anon_func_2(suggestions)) do -- 456
								_accum_0[_len_0] = v -- 456
								_len_0 = _len_0 + 1 -- 456
							end -- 456
							suggestions = _accum_0 -- 456
						end -- 456
						return { -- 457
							success = true, -- 457
							suggestions = suggestions -- 457
						} -- 457
					else -- 459
						return { -- 459
							success = false -- 459
						} -- 459
					end -- 455
				until true -- 400
				if "tl" == lang or "lua" == lang then -- 461
					do -- 462
						local isTIC80 = CheckTIC80Code(content) -- 462
						if isTIC80 then -- 462
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 463
						end -- 462
					end -- 462
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 464
					if not line:match("[%.:]$") then -- 465
						local checkSet -- 466
						do -- 466
							local _tbl_0 = { } -- 466
							for _index_0 = 1, #suggestions do -- 466
								local _des_0 = suggestions[_index_0] -- 466
								local name = _des_0[1] -- 466
								_tbl_0[name] = true -- 466
							end -- 466
							checkSet = _tbl_0 -- 466
						end -- 466
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 467
						for _index_0 = 1, #_list_0 do -- 467
							local item = _list_0[_index_0] -- 467
							if not checkSet[item[1]] then -- 468
								suggestions[#suggestions + 1] = item -- 468
							end -- 468
						end -- 467
						for _index_0 = 1, #luaKeywords do -- 469
							local word = luaKeywords[_index_0] -- 469
							suggestions[#suggestions + 1] = { -- 470
								word, -- 470
								"keyword", -- 470
								"keyword" -- 470
							} -- 470
						end -- 469
						if lang == "tl" then -- 471
							for _index_0 = 1, #tealKeywords do -- 472
								local word = tealKeywords[_index_0] -- 472
								suggestions[#suggestions + 1] = { -- 473
									word, -- 473
									"keyword", -- 473
									"keyword" -- 473
								} -- 473
							end -- 472
						end -- 471
					end -- 465
					if #suggestions > 0 then -- 474
						return { -- 475
							success = true, -- 475
							suggestions = suggestions -- 475
						} -- 475
					end -- 474
				elseif "yue" == lang then -- 476
					local suggestions = { } -- 477
					local gotGlobals = false -- 478
					do -- 479
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 479
						if luaCodes then -- 479
							gotGlobals = true -- 480
							do -- 481
								local chainOp = line:match("[^%w_]([%.\\])$") -- 481
								if chainOp then -- 481
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 482
									if not withVar then -- 483
										return { -- 483
											success = false -- 483
										} -- 483
									end -- 483
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 484
								elseif line:match("^([%.\\])$") then -- 485
									return { -- 486
										success = false -- 486
									} -- 486
								end -- 481
							end -- 481
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 487
							for _index_0 = 1, #_list_0 do -- 487
								local item = _list_0[_index_0] -- 487
								suggestions[#suggestions + 1] = item -- 487
							end -- 487
							if #suggestions == 0 then -- 488
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 489
								for _index_0 = 1, #_list_1 do -- 489
									local item = _list_1[_index_0] -- 489
									suggestions[#suggestions + 1] = item -- 489
								end -- 489
							end -- 488
						end -- 479
					end -- 479
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 490
						local checkSet -- 491
						do -- 491
							local _tbl_0 = { } -- 491
							for _index_0 = 1, #suggestions do -- 491
								local _des_0 = suggestions[_index_0] -- 491
								local name = _des_0[1] -- 491
								_tbl_0[name] = true -- 491
							end -- 491
							checkSet = _tbl_0 -- 491
						end -- 491
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 492
						for _index_0 = 1, #_list_0 do -- 492
							local item = _list_0[_index_0] -- 492
							if not checkSet[item[1]] then -- 493
								suggestions[#suggestions + 1] = item -- 493
							end -- 493
						end -- 492
						if not gotGlobals then -- 494
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 495
							for _index_0 = 1, #_list_1 do -- 495
								local item = _list_1[_index_0] -- 495
								if not checkSet[item[1]] then -- 496
									suggestions[#suggestions + 1] = item -- 496
								end -- 496
							end -- 495
						end -- 494
						for _index_0 = 1, #yueKeywords do -- 497
							local word = yueKeywords[_index_0] -- 497
							if not checkSet[word] then -- 498
								suggestions[#suggestions + 1] = { -- 499
									word, -- 499
									"keyword", -- 499
									"keyword" -- 499
								} -- 499
							end -- 498
						end -- 497
					end -- 490
					if #suggestions > 0 then -- 500
						return { -- 501
							success = true, -- 501
							suggestions = suggestions -- 501
						} -- 501
					end -- 500
				elseif "xml" == lang then -- 502
					local items = xml.complete(content) -- 503
					if #items > 0 then -- 504
						local suggestions -- 505
						do -- 505
							local _accum_0 = { } -- 505
							local _len_0 = 1 -- 505
							for _index_0 = 1, #items do -- 505
								local _des_0 = items[_index_0] -- 505
								local label, insertText = _des_0[1], _des_0[2] -- 505
								_accum_0[_len_0] = { -- 506
									label, -- 506
									insertText, -- 506
									"field" -- 506
								} -- 506
								_len_0 = _len_0 + 1 -- 506
							end -- 505
							suggestions = _accum_0 -- 505
						end -- 505
						return { -- 507
							success = true, -- 507
							suggestions = suggestions -- 507
						} -- 507
					end -- 504
				end -- 461
			end -- 398
		end -- 398
	end -- 398
	return { -- 397
		success = false -- 397
	} -- 397
end) -- 397
HttpServer:upload("/upload", function(req, filename) -- 511
	do -- 512
		local _type_0 = type(req) -- 512
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 512
		if _tab_0 then -- 512
			local path -- 512
			do -- 512
				local _obj_0 = req.params -- 512
				local _type_1 = type(_obj_0) -- 512
				if "table" == _type_1 or "userdata" == _type_1 then -- 512
					path = _obj_0.path -- 512
				end -- 512
			end -- 512
			if path ~= nil then -- 512
				local uploadPath = Path(Content.writablePath, ".upload") -- 513
				if not Content:exist(uploadPath) then -- 514
					Content:mkdir(uploadPath) -- 515
				end -- 514
				local targetPath = Path(uploadPath, filename) -- 516
				Content:mkdir(Path:getPath(targetPath)) -- 517
				return targetPath -- 518
			end -- 512
		end -- 512
	end -- 512
	return nil -- 511
end, function(req, file) -- 519
	do -- 520
		local _type_0 = type(req) -- 520
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 520
		if _tab_0 then -- 520
			local path -- 520
			do -- 520
				local _obj_0 = req.params -- 520
				local _type_1 = type(_obj_0) -- 520
				if "table" == _type_1 or "userdata" == _type_1 then -- 520
					path = _obj_0.path -- 520
				end -- 520
			end -- 520
			if path ~= nil then -- 520
				path = Path(Content.writablePath, path) -- 521
				if Content:exist(path) then -- 522
					local uploadPath = Path(Content.writablePath, ".upload") -- 523
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 524
					Content:mkdir(Path:getPath(targetPath)) -- 525
					if Content:move(file, targetPath) then -- 526
						return true -- 527
					end -- 526
				end -- 522
			end -- 520
		end -- 520
	end -- 520
	return false -- 519
end) -- 509
HttpServer:post("/list", function(req) -- 530
	do -- 531
		local _type_0 = type(req) -- 531
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 531
		if _tab_0 then -- 531
			local path -- 531
			do -- 531
				local _obj_0 = req.body -- 531
				local _type_1 = type(_obj_0) -- 531
				if "table" == _type_1 or "userdata" == _type_1 then -- 531
					path = _obj_0.path -- 531
				end -- 531
			end -- 531
			if path ~= nil then -- 531
				if Content:exist(path) then -- 532
					local files = { } -- 533
					local visitAssets -- 534
					visitAssets = function(path, folder) -- 534
						local dirs = Content:getDirs(path) -- 535
						for _index_0 = 1, #dirs do -- 536
							local dir = dirs[_index_0] -- 536
							if dir:match("^%.") then -- 537
								goto _continue_0 -- 537
							end -- 537
							local current -- 538
							if folder == "" then -- 538
								current = dir -- 539
							else -- 541
								current = Path(folder, dir) -- 541
							end -- 538
							files[#files + 1] = current -- 542
							visitAssets(Path(path, dir), current) -- 543
							::_continue_0:: -- 537
						end -- 536
						local fs = Content:getFiles(path) -- 544
						for _index_0 = 1, #fs do -- 545
							local f = fs[_index_0] -- 545
							if f:match("^%.") then -- 546
								goto _continue_1 -- 546
							end -- 546
							if folder == "" then -- 547
								files[#files + 1] = f -- 548
							else -- 550
								files[#files + 1] = Path(folder, f) -- 550
							end -- 547
							::_continue_1:: -- 546
						end -- 545
					end -- 534
					visitAssets(path, "") -- 551
					if #files == 0 then -- 552
						files = nil -- 552
					end -- 552
					return { -- 553
						success = true, -- 553
						files = files -- 553
					} -- 553
				end -- 532
			end -- 531
		end -- 531
	end -- 531
	return { -- 530
		success = false -- 530
	} -- 530
end) -- 530
HttpServer:post("/info", function() -- 555
	local Entry = require("Script.Dev.Entry") -- 556
	local webProfiler, drawerWidth -- 557
	do -- 557
		local _obj_0 = Entry.getConfig() -- 557
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 557
	end -- 557
	local engineDev = Entry.getEngineDev() -- 558
	Entry.connectWebIDE() -- 559
	return { -- 561
		platform = App.platform, -- 561
		locale = App.locale, -- 562
		version = App.version, -- 563
		engineDev = engineDev, -- 564
		webProfiler = webProfiler, -- 565
		drawerWidth = drawerWidth -- 566
	} -- 560
end) -- 555
HttpServer:post("/new", function(req) -- 568
	do -- 569
		local _type_0 = type(req) -- 569
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 569
		if _tab_0 then -- 569
			local path -- 569
			do -- 569
				local _obj_0 = req.body -- 569
				local _type_1 = type(_obj_0) -- 569
				if "table" == _type_1 or "userdata" == _type_1 then -- 569
					path = _obj_0.path -- 569
				end -- 569
			end -- 569
			local content -- 569
			do -- 569
				local _obj_0 = req.body -- 569
				local _type_1 = type(_obj_0) -- 569
				if "table" == _type_1 or "userdata" == _type_1 then -- 569
					content = _obj_0.content -- 569
				end -- 569
			end -- 569
			local folder -- 569
			do -- 569
				local _obj_0 = req.body -- 569
				local _type_1 = type(_obj_0) -- 569
				if "table" == _type_1 or "userdata" == _type_1 then -- 569
					folder = _obj_0.folder -- 569
				end -- 569
			end -- 569
			if path ~= nil and content ~= nil and folder ~= nil then -- 569
				if Content:exist(path) then -- 570
					return { -- 571
						success = false, -- 571
						message = "TargetExisted" -- 571
					} -- 571
				end -- 570
				local parent = Path:getPath(path) -- 572
				local files = Content:getFiles(parent) -- 573
				if folder then -- 574
					local name = Path:getFilename(path):lower() -- 575
					for _index_0 = 1, #files do -- 576
						local file = files[_index_0] -- 576
						if name == Path:getFilename(file):lower() then -- 577
							return { -- 578
								success = false, -- 578
								message = "TargetExisted" -- 578
							} -- 578
						end -- 577
					end -- 576
					if Content:mkdir(path) then -- 579
						return { -- 580
							success = true -- 580
						} -- 580
					end -- 579
				else -- 582
					local name = Path:getName(path):lower() -- 582
					for _index_0 = 1, #files do -- 583
						local file = files[_index_0] -- 583
						if name == Path:getName(file):lower() then -- 584
							local ext = Path:getExt(file) -- 585
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 586
								goto _continue_0 -- 587
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 588
								goto _continue_0 -- 589
							end -- 586
							return { -- 590
								success = false, -- 590
								message = "SourceExisted" -- 590
							} -- 590
						end -- 584
						::_continue_0:: -- 584
					end -- 583
					if Content:save(path, content) then -- 591
						return { -- 592
							success = true -- 592
						} -- 592
					end -- 591
				end -- 574
			end -- 569
		end -- 569
	end -- 569
	return { -- 568
		success = false, -- 568
		message = "Failed" -- 568
	} -- 568
end) -- 568
HttpServer:post("/delete", function(req) -- 594
	do -- 595
		local _type_0 = type(req) -- 595
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 595
		if _tab_0 then -- 595
			local path -- 595
			do -- 595
				local _obj_0 = req.body -- 595
				local _type_1 = type(_obj_0) -- 595
				if "table" == _type_1 or "userdata" == _type_1 then -- 595
					path = _obj_0.path -- 595
				end -- 595
			end -- 595
			if path ~= nil then -- 595
				if Content:exist(path) then -- 596
					local parent = Path:getPath(path) -- 597
					local files = Content:getFiles(parent) -- 598
					local name = Path:getName(path):lower() -- 599
					local ext = Path:getExt(path) -- 600
					for _index_0 = 1, #files do -- 601
						local file = files[_index_0] -- 601
						if name == Path:getName(file):lower() then -- 602
							local _exp_0 = Path:getExt(file) -- 603
							if "tl" == _exp_0 then -- 603
								if ("vs" == ext) then -- 603
									Content:remove(Path(parent, file)) -- 604
								end -- 603
							elseif "lua" == _exp_0 then -- 605
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 605
									Content:remove(Path(parent, file)) -- 606
								end -- 605
							end -- 603
						end -- 602
					end -- 601
					if Content:remove(path) then -- 607
						return { -- 608
							success = true -- 608
						} -- 608
					end -- 607
				end -- 596
			end -- 595
		end -- 595
	end -- 595
	return { -- 594
		success = false -- 594
	} -- 594
end) -- 594
HttpServer:post("/rename", function(req) -- 610
	do -- 611
		local _type_0 = type(req) -- 611
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 611
		if _tab_0 then -- 611
			local old -- 611
			do -- 611
				local _obj_0 = req.body -- 611
				local _type_1 = type(_obj_0) -- 611
				if "table" == _type_1 or "userdata" == _type_1 then -- 611
					old = _obj_0.old -- 611
				end -- 611
			end -- 611
			local new -- 611
			do -- 611
				local _obj_0 = req.body -- 611
				local _type_1 = type(_obj_0) -- 611
				if "table" == _type_1 or "userdata" == _type_1 then -- 611
					new = _obj_0.new -- 611
				end -- 611
			end -- 611
			if old ~= nil and new ~= nil then -- 611
				if Content:exist(old) and not Content:exist(new) then -- 612
					local parent = Path:getPath(new) -- 613
					local files = Content:getFiles(parent) -- 614
					if Content:isdir(old) then -- 615
						local name = Path:getFilename(new):lower() -- 616
						for _index_0 = 1, #files do -- 617
							local file = files[_index_0] -- 617
							if name == Path:getFilename(file):lower() then -- 618
								return { -- 619
									success = false -- 619
								} -- 619
							end -- 618
						end -- 617
					else -- 621
						local name = Path:getName(new):lower() -- 621
						local ext = Path:getExt(new) -- 622
						for _index_0 = 1, #files do -- 623
							local file = files[_index_0] -- 623
							if name == Path:getName(file):lower() then -- 624
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 625
									goto _continue_0 -- 626
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 627
									goto _continue_0 -- 628
								end -- 625
								return { -- 629
									success = false -- 629
								} -- 629
							end -- 624
							::_continue_0:: -- 624
						end -- 623
					end -- 615
					if Content:move(old, new) then -- 630
						local newParent = Path:getPath(new) -- 631
						parent = Path:getPath(old) -- 632
						files = Content:getFiles(parent) -- 633
						local newName = Path:getName(new) -- 634
						local oldName = Path:getName(old) -- 635
						local name = oldName:lower() -- 636
						local ext = Path:getExt(old) -- 637
						for _index_0 = 1, #files do -- 638
							local file = files[_index_0] -- 638
							if name == Path:getName(file):lower() then -- 639
								local _exp_0 = Path:getExt(file) -- 640
								if "tl" == _exp_0 then -- 640
									if ("vs" == ext) then -- 640
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 641
									end -- 640
								elseif "lua" == _exp_0 then -- 642
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 642
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 643
									end -- 642
								end -- 640
							end -- 639
						end -- 638
						return { -- 644
							success = true -- 644
						} -- 644
					end -- 630
				end -- 612
			end -- 611
		end -- 611
	end -- 611
	return { -- 610
		success = false -- 610
	} -- 610
end) -- 610
HttpServer:post("/exist", function(req) -- 646
	do -- 647
		local _type_0 = type(req) -- 647
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 647
		if _tab_0 then -- 647
			local file -- 647
			do -- 647
				local _obj_0 = req.body -- 647
				local _type_1 = type(_obj_0) -- 647
				if "table" == _type_1 or "userdata" == _type_1 then -- 647
					file = _obj_0.file -- 647
				end -- 647
			end -- 647
			if file ~= nil then -- 647
				do -- 648
					local projFile = req.body.projFile -- 648
					if projFile then -- 648
						local projDir = getProjectDirFromFile(projFile) -- 649
						if projDir then -- 649
							local scriptDir = Path(projDir, "Script") -- 650
							local searchPaths = Content.searchPaths -- 651
							if Content:exist(scriptDir) then -- 652
								Content:addSearchPath(scriptDir) -- 652
							end -- 652
							if Content:exist(projDir) then -- 653
								Content:addSearchPath(projDir) -- 653
							end -- 653
							local _ <close> = setmetatable({ }, { -- 654
								__close = function() -- 654
									Content.searchPaths = searchPaths -- 654
								end -- 654
							}) -- 654
							return { -- 655
								success = Content:exist(file) -- 655
							} -- 655
						end -- 649
					end -- 648
				end -- 648
				return { -- 656
					success = Content:exist(file) -- 656
				} -- 656
			end -- 647
		end -- 647
	end -- 647
	return { -- 646
		success = false -- 646
	} -- 646
end) -- 646
HttpServer:postSchedule("/read", function(req) -- 658
	do -- 659
		local _type_0 = type(req) -- 659
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 659
		if _tab_0 then -- 659
			local path -- 659
			do -- 659
				local _obj_0 = req.body -- 659
				local _type_1 = type(_obj_0) -- 659
				if "table" == _type_1 or "userdata" == _type_1 then -- 659
					path = _obj_0.path -- 659
				end -- 659
			end -- 659
			if path ~= nil then -- 659
				local readFile -- 660
				readFile = function() -- 660
					if Content:exist(path) then -- 661
						local content = Content:loadAsync(path) -- 662
						if content then -- 662
							return { -- 663
								content = content, -- 663
								success = true -- 663
							} -- 663
						end -- 662
					end -- 661
					return nil -- 660
				end -- 660
				do -- 664
					local projFile = req.body.projFile -- 664
					if projFile then -- 664
						local projDir = getProjectDirFromFile(projFile) -- 665
						if projDir then -- 665
							local scriptDir = Path(projDir, "Script") -- 666
							local searchPaths = Content.searchPaths -- 667
							if Content:exist(scriptDir) then -- 668
								Content:addSearchPath(scriptDir) -- 668
							end -- 668
							if Content:exist(projDir) then -- 669
								Content:addSearchPath(projDir) -- 669
							end -- 669
							local _ <close> = setmetatable({ }, { -- 670
								__close = function() -- 670
									Content.searchPaths = searchPaths -- 670
								end -- 670
							}) -- 670
							local result = readFile() -- 671
							if result then -- 671
								return result -- 671
							end -- 671
						end -- 665
					end -- 664
				end -- 664
				local result = readFile() -- 672
				if result then -- 672
					return result -- 672
				end -- 672
			end -- 659
		end -- 659
	end -- 659
	return { -- 658
		success = false -- 658
	} -- 658
end) -- 658
HttpServer:post("/read-sync", function(req) -- 674
	do -- 675
		local _type_0 = type(req) -- 675
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 675
		if _tab_0 then -- 675
			local path -- 675
			do -- 675
				local _obj_0 = req.body -- 675
				local _type_1 = type(_obj_0) -- 675
				if "table" == _type_1 or "userdata" == _type_1 then -- 675
					path = _obj_0.path -- 675
				end -- 675
			end -- 675
			local exts -- 675
			do -- 675
				local _obj_0 = req.body -- 675
				local _type_1 = type(_obj_0) -- 675
				if "table" == _type_1 or "userdata" == _type_1 then -- 675
					exts = _obj_0.exts -- 675
				end -- 675
			end -- 675
			if path ~= nil and exts ~= nil then -- 675
				local readFile -- 676
				readFile = function() -- 676
					for _index_0 = 1, #exts do -- 677
						local ext = exts[_index_0] -- 677
						local targetPath = path .. ext -- 678
						if Content:exist(targetPath) then -- 679
							local content = Content:load(targetPath) -- 680
							if content then -- 680
								return { -- 681
									content = content, -- 681
									success = true, -- 681
									fullPath = Content:getFullPath(targetPath) -- 681
								} -- 681
							end -- 680
						end -- 679
					end -- 677
					return nil -- 676
				end -- 676
				local searchPaths = Content.searchPaths -- 682
				local _ <close> = setmetatable({ }, { -- 683
					__close = function() -- 683
						Content.searchPaths = searchPaths -- 683
					end -- 683
				}) -- 683
				do -- 684
					local projFile = req.body.projFile -- 684
					if projFile then -- 684
						local projDir = getProjectDirFromFile(projFile) -- 685
						if projDir then -- 685
							local scriptDir = Path(projDir, "Script") -- 686
							if Content:exist(scriptDir) then -- 687
								Content:addSearchPath(scriptDir) -- 687
							end -- 687
							if Content:exist(projDir) then -- 688
								Content:addSearchPath(projDir) -- 688
							end -- 688
						else -- 690
							projDir = Path:getPath(projFile) -- 690
							if Content:exist(projDir) then -- 691
								Content:addSearchPath(projDir) -- 691
							end -- 691
						end -- 685
					end -- 684
				end -- 684
				local result = readFile() -- 692
				if result then -- 692
					return result -- 692
				end -- 692
			end -- 675
		end -- 675
	end -- 675
	return { -- 674
		success = false -- 674
	} -- 674
end) -- 674
local compileFileAsync -- 694
compileFileAsync = function(inputFile, sourceCodes) -- 694
	local file = inputFile -- 695
	local searchPath -- 696
	do -- 696
		local dir = getProjectDirFromFile(inputFile) -- 696
		if dir then -- 696
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 697
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 698
		else -- 700
			file = Path:getRelative(inputFile, Content.writablePath) -- 700
			if file:sub(1, 2) == ".." then -- 701
				file = Path:getRelative(inputFile, Content.assetPath) -- 702
			end -- 701
			searchPath = "" -- 703
		end -- 696
	end -- 696
	local outputFile = Path:replaceExt(inputFile, "lua") -- 704
	local yueext = yue.options.extension -- 705
	local resultCodes = nil -- 706
	do -- 707
		local _exp_0 = Path:getExt(inputFile) -- 707
		if yueext == _exp_0 then -- 707
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 708
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 709
				if not codes then -- 710
					return -- 710
				end -- 710
				local extraGlobal -- 711
				if isTIC80 then -- 711
					extraGlobal = tic80APIs -- 711
				else -- 711
					extraGlobal = nil -- 711
				end -- 711
				local success = LintYueGlobals(codes, globals, true, extraGlobal) -- 712
				if not success then -- 713
					return -- 713
				end -- 713
				if codes == "" then -- 714
					resultCodes = "" -- 715
					return nil -- 716
				end -- 714
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 717
				return resultCodes -- 718
			end, function(success) -- 709
				if not success then -- 719
					Content:remove(outputFile) -- 720
					if resultCodes == nil then -- 721
						resultCodes = false -- 722
					end -- 721
				end -- 719
			end) -- 709
		elseif "tl" == _exp_0 then -- 723
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 724
			if isTIC80 then -- 725
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 726
			end -- 725
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 727
			if codes then -- 727
				if isTIC80 then -- 728
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 729
				end -- 728
				resultCodes = codes -- 730
				Content:saveAsync(outputFile, codes) -- 731
			else -- 733
				Content:remove(outputFile) -- 733
				resultCodes = false -- 734
			end -- 727
		elseif "xml" == _exp_0 then -- 735
			local codes = xml.tolua(sourceCodes) -- 736
			if codes then -- 736
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 737
				Content:saveAsync(outputFile, resultCodes) -- 738
			else -- 740
				Content:remove(outputFile) -- 740
				resultCodes = false -- 741
			end -- 736
		end -- 707
	end -- 707
	wait(function() -- 742
		return resultCodes ~= nil -- 742
	end) -- 742
	if resultCodes then -- 743
		return resultCodes -- 743
	end -- 743
	return nil -- 694
end -- 694
HttpServer:postSchedule("/write", function(req) -- 745
	do -- 746
		local _type_0 = type(req) -- 746
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 746
		if _tab_0 then -- 746
			local path -- 746
			do -- 746
				local _obj_0 = req.body -- 746
				local _type_1 = type(_obj_0) -- 746
				if "table" == _type_1 or "userdata" == _type_1 then -- 746
					path = _obj_0.path -- 746
				end -- 746
			end -- 746
			local content -- 746
			do -- 746
				local _obj_0 = req.body -- 746
				local _type_1 = type(_obj_0) -- 746
				if "table" == _type_1 or "userdata" == _type_1 then -- 746
					content = _obj_0.content -- 746
				end -- 746
			end -- 746
			if path ~= nil and content ~= nil then -- 746
				if Content:saveAsync(path, content) then -- 747
					do -- 748
						local _exp_0 = Path:getExt(path) -- 748
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 748
							if '' == Path:getExt(Path:getName(path)) then -- 749
								local resultCodes = compileFileAsync(path, content) -- 750
								return { -- 751
									success = true, -- 751
									resultCodes = resultCodes -- 751
								} -- 751
							end -- 749
						end -- 748
					end -- 748
					return { -- 752
						success = true -- 752
					} -- 752
				end -- 747
			end -- 746
		end -- 746
	end -- 746
	return { -- 745
		success = false -- 745
	} -- 745
end) -- 745
HttpServer:postSchedule("/build", function(req) -- 754
	do -- 755
		local _type_0 = type(req) -- 755
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 755
		if _tab_0 then -- 755
			local path -- 755
			do -- 755
				local _obj_0 = req.body -- 755
				local _type_1 = type(_obj_0) -- 755
				if "table" == _type_1 or "userdata" == _type_1 then -- 755
					path = _obj_0.path -- 755
				end -- 755
			end -- 755
			if path ~= nil then -- 755
				local _exp_0 = Path:getExt(path) -- 756
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 756
					if '' == Path:getExt(Path:getName(path)) then -- 757
						local content = Content:loadAsync(path) -- 758
						if content then -- 758
							local resultCodes = compileFileAsync(path, content) -- 759
							if resultCodes then -- 759
								return { -- 760
									success = true, -- 760
									resultCodes = resultCodes -- 760
								} -- 760
							end -- 759
						end -- 758
					end -- 757
				end -- 756
			end -- 755
		end -- 755
	end -- 755
	return { -- 754
		success = false -- 754
	} -- 754
end) -- 754
local extentionLevels = { -- 763
	vs = 2, -- 763
	bl = 2, -- 764
	ts = 1, -- 765
	tsx = 1, -- 766
	tl = 1, -- 767
	yue = 1, -- 768
	xml = 1, -- 769
	lua = 0 -- 770
} -- 762
HttpServer:post("/assets", function() -- 772
	local Entry = require("Script.Dev.Entry") -- 775
	local engineDev = Entry.getEngineDev() -- 776
	local visitAssets -- 777
	visitAssets = function(path, tag) -- 777
		local isWorkspace = tag == "Workspace" -- 778
		local builtin -- 779
		if tag == "Builtin" then -- 779
			builtin = true -- 779
		else -- 779
			builtin = nil -- 779
		end -- 779
		local children = nil -- 780
		local dirs = Content:getDirs(path) -- 781
		for _index_0 = 1, #dirs do -- 782
			local dir = dirs[_index_0] -- 782
			if isWorkspace then -- 783
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 784
					goto _continue_0 -- 785
				end -- 784
			elseif dir == ".git" then -- 786
				goto _continue_0 -- 787
			end -- 783
			if not children then -- 788
				children = { } -- 788
			end -- 788
			children[#children + 1] = visitAssets(Path(path, dir)) -- 789
			::_continue_0:: -- 783
		end -- 782
		local files = Content:getFiles(path) -- 790
		local names = { } -- 791
		for _index_0 = 1, #files do -- 792
			local file = files[_index_0] -- 792
			if file:match("^%.") then -- 793
				goto _continue_1 -- 793
			end -- 793
			local name = Path:getName(file) -- 794
			local ext = names[name] -- 795
			if ext then -- 795
				local lv1 -- 796
				do -- 796
					local _exp_0 = extentionLevels[ext] -- 796
					if _exp_0 ~= nil then -- 796
						lv1 = _exp_0 -- 796
					else -- 796
						lv1 = -1 -- 796
					end -- 796
				end -- 796
				ext = Path:getExt(file) -- 797
				local lv2 -- 798
				do -- 798
					local _exp_0 = extentionLevels[ext] -- 798
					if _exp_0 ~= nil then -- 798
						lv2 = _exp_0 -- 798
					else -- 798
						lv2 = -1 -- 798
					end -- 798
				end -- 798
				if lv2 > lv1 then -- 799
					names[name] = ext -- 800
				elseif lv2 == lv1 then -- 801
					names[name .. '.' .. ext] = "" -- 802
				end -- 799
			else -- 804
				ext = Path:getExt(file) -- 804
				if not extentionLevels[ext] then -- 805
					names[file] = "" -- 806
				else -- 808
					names[name] = ext -- 808
				end -- 805
			end -- 795
			::_continue_1:: -- 793
		end -- 792
		do -- 809
			local _accum_0 = { } -- 809
			local _len_0 = 1 -- 809
			for name, ext in pairs(names) do -- 809
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 809
				_len_0 = _len_0 + 1 -- 809
			end -- 809
			files = _accum_0 -- 809
		end -- 809
		for _index_0 = 1, #files do -- 810
			local file = files[_index_0] -- 810
			if not children then -- 811
				children = { } -- 811
			end -- 811
			children[#children + 1] = { -- 813
				key = Path(path, file), -- 813
				dir = false, -- 814
				title = file, -- 815
				builtin = builtin -- 816
			} -- 812
		end -- 810
		if children then -- 818
			table.sort(children, function(a, b) -- 819
				if a.dir == b.dir then -- 820
					return a.title < b.title -- 821
				else -- 823
					return a.dir -- 823
				end -- 820
			end) -- 819
		end -- 818
		if isWorkspace and children then -- 824
			return children -- 825
		else -- 827
			return { -- 828
				key = path, -- 828
				dir = true, -- 829
				title = Path:getFilename(path), -- 830
				builtin = builtin, -- 831
				children = children -- 832
			} -- 827
		end -- 824
	end -- 777
	local zh = (App.locale:match("^zh") ~= nil) -- 834
	return { -- 836
		key = Content.writablePath, -- 836
		dir = true, -- 837
		root = true, -- 838
		title = "Assets", -- 839
		children = (function() -- 841
			local _tab_0 = { -- 841
				{ -- 842
					key = Path(Content.assetPath), -- 842
					dir = true, -- 843
					builtin = true, -- 844
					title = zh and "内置资源" or "Built-in", -- 845
					children = { -- 847
						(function() -- 847
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 847
							_with_0.title = zh and "说明文档" or "Readme" -- 848
							return _with_0 -- 847
						end)(), -- 847
						(function() -- 849
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 849
							_with_0.title = zh and "接口文档" or "API Doc" -- 850
							return _with_0 -- 849
						end)(), -- 849
						(function() -- 851
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 851
							_with_0.title = zh and "开发工具" or "Tools" -- 852
							return _with_0 -- 851
						end)(), -- 851
						(function() -- 853
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 853
							_with_0.title = zh and "字体" or "Font" -- 854
							return _with_0 -- 853
						end)(), -- 853
						(function() -- 855
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 855
							_with_0.title = zh and "程序库" or "Lib" -- 856
							if engineDev then -- 857
								local _list_0 = _with_0.children -- 858
								for _index_0 = 1, #_list_0 do -- 858
									local child = _list_0[_index_0] -- 858
									if not (child.title == "Dora") then -- 859
										goto _continue_0 -- 859
									end -- 859
									local title = zh and "zh-Hans" or "en" -- 860
									do -- 861
										local _accum_0 = { } -- 861
										local _len_0 = 1 -- 861
										local _list_1 = child.children -- 861
										for _index_1 = 1, #_list_1 do -- 861
											local c = _list_1[_index_1] -- 861
											if c.title ~= title then -- 861
												_accum_0[_len_0] = c -- 861
												_len_0 = _len_0 + 1 -- 861
											end -- 861
										end -- 861
										child.children = _accum_0 -- 861
									end -- 861
									break -- 862
									::_continue_0:: -- 859
								end -- 858
							else -- 864
								local _accum_0 = { } -- 864
								local _len_0 = 1 -- 864
								local _list_0 = _with_0.children -- 864
								for _index_0 = 1, #_list_0 do -- 864
									local child = _list_0[_index_0] -- 864
									if child.title ~= "Dora" then -- 864
										_accum_0[_len_0] = child -- 864
										_len_0 = _len_0 + 1 -- 864
									end -- 864
								end -- 864
								_with_0.children = _accum_0 -- 864
							end -- 857
							return _with_0 -- 855
						end)(), -- 855
						(function() -- 865
							if engineDev then -- 865
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 866
								local _obj_0 = _with_0.children -- 867
								_obj_0[#_obj_0 + 1] = { -- 868
									key = Path(Content.assetPath, "Script", "init.yue"), -- 868
									dir = false, -- 869
									builtin = true, -- 870
									title = "init.yue" -- 871
								} -- 867
								return _with_0 -- 866
							end -- 865
						end)() -- 865
					} -- 846
				} -- 841
			} -- 875
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 875
			local _idx_0 = #_tab_0 + 1 -- 875
			for _index_0 = 1, #_obj_0 do -- 875
				local _value_0 = _obj_0[_index_0] -- 875
				_tab_0[_idx_0] = _value_0 -- 875
				_idx_0 = _idx_0 + 1 -- 875
			end -- 875
			return _tab_0 -- 841
		end)() -- 840
	} -- 835
end) -- 772
HttpServer:postSchedule("/run", function(req) -- 879
	do -- 880
		local _type_0 = type(req) -- 880
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 880
		if _tab_0 then -- 880
			local file -- 880
			do -- 880
				local _obj_0 = req.body -- 880
				local _type_1 = type(_obj_0) -- 880
				if "table" == _type_1 or "userdata" == _type_1 then -- 880
					file = _obj_0.file -- 880
				end -- 880
			end -- 880
			local asProj -- 880
			do -- 880
				local _obj_0 = req.body -- 880
				local _type_1 = type(_obj_0) -- 880
				if "table" == _type_1 or "userdata" == _type_1 then -- 880
					asProj = _obj_0.asProj -- 880
				end -- 880
			end -- 880
			if file ~= nil and asProj ~= nil then -- 880
				if not Content:isAbsolutePath(file) then -- 881
					local devFile = Path(Content.writablePath, file) -- 882
					if Content:exist(devFile) then -- 883
						file = devFile -- 883
					end -- 883
				end -- 881
				local Entry = require("Script.Dev.Entry") -- 884
				local workDir -- 885
				if asProj then -- 886
					workDir = getProjectDirFromFile(file) -- 887
					if workDir then -- 887
						Entry.allClear() -- 888
						local target = Path(workDir, "init") -- 889
						local success, err = Entry.enterEntryAsync({ -- 890
							entryName = "Project", -- 890
							fileName = target -- 890
						}) -- 890
						target = Path:getName(Path:getPath(target)) -- 891
						return { -- 892
							success = success, -- 892
							target = target, -- 892
							err = err -- 892
						} -- 892
					end -- 887
				else -- 894
					workDir = getProjectDirFromFile(file) -- 894
				end -- 886
				Entry.allClear() -- 895
				file = Path:replaceExt(file, "") -- 896
				local success, err = Entry.enterEntryAsync({ -- 898
					entryName = Path:getName(file), -- 898
					fileName = file, -- 899
					workDir = workDir -- 900
				}) -- 897
				return { -- 901
					success = success, -- 901
					err = err -- 901
				} -- 901
			end -- 880
		end -- 880
	end -- 880
	return { -- 879
		success = false -- 879
	} -- 879
end) -- 879
HttpServer:postSchedule("/stop", function() -- 903
	local Entry = require("Script.Dev.Entry") -- 904
	return { -- 905
		success = Entry.stop() -- 905
	} -- 905
end) -- 903
local minifyAsync -- 907
minifyAsync = function(sourcePath, minifyPath) -- 907
	if not Content:exist(sourcePath) then -- 908
		return -- 908
	end -- 908
	local Entry = require("Script.Dev.Entry") -- 909
	local errors = { } -- 910
	local files = Entry.getAllFiles(sourcePath, { -- 911
		"lua" -- 911
	}, true) -- 911
	do -- 912
		local _accum_0 = { } -- 912
		local _len_0 = 1 -- 912
		for _index_0 = 1, #files do -- 912
			local file = files[_index_0] -- 912
			if file:sub(1, 1) ~= '.' then -- 912
				_accum_0[_len_0] = file -- 912
				_len_0 = _len_0 + 1 -- 912
			end -- 912
		end -- 912
		files = _accum_0 -- 912
	end -- 912
	local paths -- 913
	do -- 913
		local _tbl_0 = { } -- 913
		for _index_0 = 1, #files do -- 913
			local file = files[_index_0] -- 913
			_tbl_0[Path:getPath(file)] = true -- 913
		end -- 913
		paths = _tbl_0 -- 913
	end -- 913
	for path in pairs(paths) do -- 914
		Content:mkdir(Path(minifyPath, path)) -- 914
	end -- 914
	local _ <close> = setmetatable({ }, { -- 915
		__close = function() -- 915
			package.loaded["luaminify.FormatMini"] = nil -- 916
			package.loaded["luaminify.ParseLua"] = nil -- 917
			package.loaded["luaminify.Scope"] = nil -- 918
			package.loaded["luaminify.Util"] = nil -- 919
		end -- 915
	}) -- 915
	local FormatMini -- 920
	do -- 920
		local _obj_0 = require("luaminify") -- 920
		FormatMini = _obj_0.FormatMini -- 920
	end -- 920
	local fileCount = #files -- 921
	local count = 0 -- 922
	for _index_0 = 1, #files do -- 923
		local file = files[_index_0] -- 923
		thread(function() -- 924
			local _ <close> = setmetatable({ }, { -- 925
				__close = function() -- 925
					count = count + 1 -- 925
				end -- 925
			}) -- 925
			local input = Path(sourcePath, file) -- 926
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 927
			if Content:exist(input) then -- 928
				local sourceCodes = Content:loadAsync(input) -- 929
				local res, err = FormatMini(sourceCodes) -- 930
				if res then -- 931
					Content:saveAsync(output, res) -- 932
					return print("Minify " .. tostring(file)) -- 933
				else -- 935
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 935
				end -- 931
			else -- 937
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 937
			end -- 928
		end) -- 924
		sleep() -- 938
	end -- 923
	wait(function() -- 939
		return count == fileCount -- 939
	end) -- 939
	if #errors > 0 then -- 940
		print(table.concat(errors, '\n')) -- 941
	end -- 940
	print("Obfuscation done.") -- 942
	return files -- 943
end -- 907
local zipping = false -- 945
HttpServer:postSchedule("/zip", function(req) -- 947
	do -- 948
		local _type_0 = type(req) -- 948
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 948
		if _tab_0 then -- 948
			local path -- 948
			do -- 948
				local _obj_0 = req.body -- 948
				local _type_1 = type(_obj_0) -- 948
				if "table" == _type_1 or "userdata" == _type_1 then -- 948
					path = _obj_0.path -- 948
				end -- 948
			end -- 948
			local zipFile -- 948
			do -- 948
				local _obj_0 = req.body -- 948
				local _type_1 = type(_obj_0) -- 948
				if "table" == _type_1 or "userdata" == _type_1 then -- 948
					zipFile = _obj_0.zipFile -- 948
				end -- 948
			end -- 948
			local obfuscated -- 948
			do -- 948
				local _obj_0 = req.body -- 948
				local _type_1 = type(_obj_0) -- 948
				if "table" == _type_1 or "userdata" == _type_1 then -- 948
					obfuscated = _obj_0.obfuscated -- 948
				end -- 948
			end -- 948
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 948
				if zipping then -- 949
					goto failed -- 949
				end -- 949
				zipping = true -- 950
				local _ <close> = setmetatable({ }, { -- 951
					__close = function() -- 951
						zipping = false -- 951
					end -- 951
				}) -- 951
				if not Content:exist(path) then -- 952
					goto failed -- 952
				end -- 952
				Content:mkdir(Path:getPath(zipFile)) -- 953
				if obfuscated then -- 954
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 955
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 956
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 957
					Content:remove(scriptPath) -- 958
					Content:remove(obfuscatedPath) -- 959
					Content:remove(tempPath) -- 960
					Content:mkdir(scriptPath) -- 961
					Content:mkdir(obfuscatedPath) -- 962
					Content:mkdir(tempPath) -- 963
					if not Content:copyAsync(path, tempPath) then -- 964
						goto failed -- 964
					end -- 964
					local Entry = require("Script.Dev.Entry") -- 965
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 966
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 967
						"tl", -- 967
						"yue", -- 967
						"lua", -- 967
						"ts", -- 967
						"tsx", -- 967
						"vs", -- 967
						"bl", -- 967
						"xml", -- 967
						"wa", -- 967
						"mod" -- 967
					}, true) -- 967
					for _index_0 = 1, #scriptFiles do -- 968
						local file = scriptFiles[_index_0] -- 968
						Content:remove(Path(tempPath, file)) -- 969
					end -- 968
					for _index_0 = 1, #luaFiles do -- 970
						local file = luaFiles[_index_0] -- 970
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 971
					end -- 970
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 972
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 973
					end) then -- 972
						goto failed -- 972
					end -- 972
					return { -- 974
						success = true -- 974
					} -- 974
				else -- 976
					return { -- 976
						success = Content:zipAsync(path, zipFile, function(file) -- 976
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 977
						end) -- 976
					} -- 976
				end -- 954
			end -- 948
		end -- 948
	end -- 948
	::failed:: -- 978
	return { -- 947
		success = false -- 947
	} -- 947
end) -- 947
HttpServer:postSchedule("/unzip", function(req) -- 980
	do -- 981
		local _type_0 = type(req) -- 981
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 981
		if _tab_0 then -- 981
			local zipFile -- 981
			do -- 981
				local _obj_0 = req.body -- 981
				local _type_1 = type(_obj_0) -- 981
				if "table" == _type_1 or "userdata" == _type_1 then -- 981
					zipFile = _obj_0.zipFile -- 981
				end -- 981
			end -- 981
			local path -- 981
			do -- 981
				local _obj_0 = req.body -- 981
				local _type_1 = type(_obj_0) -- 981
				if "table" == _type_1 or "userdata" == _type_1 then -- 981
					path = _obj_0.path -- 981
				end -- 981
			end -- 981
			if zipFile ~= nil and path ~= nil then -- 981
				return { -- 982
					success = Content:unzipAsync(zipFile, path, function(file) -- 982
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 983
					end) -- 982
				} -- 982
			end -- 981
		end -- 981
	end -- 981
	return { -- 980
		success = false -- 980
	} -- 980
end) -- 980
HttpServer:post("/editing-info", function(req) -- 985
	local Entry = require("Script.Dev.Entry") -- 986
	local config = Entry.getConfig() -- 987
	local _type_0 = type(req) -- 988
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 988
	local _match_0 = false -- 988
	if _tab_0 then -- 988
		local editingInfo -- 988
		do -- 988
			local _obj_0 = req.body -- 988
			local _type_1 = type(_obj_0) -- 988
			if "table" == _type_1 or "userdata" == _type_1 then -- 988
				editingInfo = _obj_0.editingInfo -- 988
			end -- 988
		end -- 988
		if editingInfo ~= nil then -- 988
			_match_0 = true -- 988
			config.editingInfo = editingInfo -- 989
			return { -- 990
				success = true -- 990
			} -- 990
		end -- 988
	end -- 988
	if not _match_0 then -- 988
		if not (config.editingInfo ~= nil) then -- 992
			local folder -- 993
			if App.locale:match('^zh') then -- 993
				folder = 'zh-Hans' -- 993
			else -- 993
				folder = 'en' -- 993
			end -- 993
			config.editingInfo = json.encode({ -- 995
				index = 0, -- 995
				files = { -- 997
					{ -- 998
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 998
						title = "welcome.md" -- 999
					} -- 997
				} -- 996
			}) -- 994
		end -- 992
		return { -- 1003
			success = true, -- 1003
			editingInfo = config.editingInfo -- 1003
		} -- 1003
	end -- 988
end) -- 985
HttpServer:post("/command", function(req) -- 1005
	do -- 1006
		local _type_0 = type(req) -- 1006
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1006
		if _tab_0 then -- 1006
			local code -- 1006
			do -- 1006
				local _obj_0 = req.body -- 1006
				local _type_1 = type(_obj_0) -- 1006
				if "table" == _type_1 or "userdata" == _type_1 then -- 1006
					code = _obj_0.code -- 1006
				end -- 1006
			end -- 1006
			local log -- 1006
			do -- 1006
				local _obj_0 = req.body -- 1006
				local _type_1 = type(_obj_0) -- 1006
				if "table" == _type_1 or "userdata" == _type_1 then -- 1006
					log = _obj_0.log -- 1006
				end -- 1006
			end -- 1006
			if code ~= nil and log ~= nil then -- 1006
				emit("AppCommand", code, log) -- 1007
				return { -- 1008
					success = true -- 1008
				} -- 1008
			end -- 1006
		end -- 1006
	end -- 1006
	return { -- 1005
		success = false -- 1005
	} -- 1005
end) -- 1005
HttpServer:post("/log/save", function() -- 1010
	local folder = ".download" -- 1011
	local fullLogFile = "dora_full_logs.txt" -- 1012
	local fullFolder = Path(Content.writablePath, folder) -- 1013
	Content:mkdir(fullFolder) -- 1014
	local logPath = Path(fullFolder, fullLogFile) -- 1015
	if App:saveLog(logPath) then -- 1016
		return { -- 1017
			success = true, -- 1017
			path = Path(folder, fullLogFile) -- 1017
		} -- 1017
	end -- 1016
	return { -- 1010
		success = false -- 1010
	} -- 1010
end) -- 1010
HttpServer:post("/yarn/check", function(req) -- 1019
	local yarncompile = require("yarncompile") -- 1020
	do -- 1021
		local _type_0 = type(req) -- 1021
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1021
		if _tab_0 then -- 1021
			local code -- 1021
			do -- 1021
				local _obj_0 = req.body -- 1021
				local _type_1 = type(_obj_0) -- 1021
				if "table" == _type_1 or "userdata" == _type_1 then -- 1021
					code = _obj_0.code -- 1021
				end -- 1021
			end -- 1021
			if code ~= nil then -- 1021
				local jsonObject = json.decode(code) -- 1022
				if jsonObject then -- 1022
					local errors = { } -- 1023
					local _list_0 = jsonObject.nodes -- 1024
					for _index_0 = 1, #_list_0 do -- 1024
						local node = _list_0[_index_0] -- 1024
						local title, body = node.title, node.body -- 1025
						local luaCode, err = yarncompile(body) -- 1026
						if not luaCode then -- 1026
							errors[#errors + 1] = title .. ":" .. err -- 1027
						end -- 1026
					end -- 1024
					return { -- 1028
						success = true, -- 1028
						syntaxError = table.concat(errors, "\n\n") -- 1028
					} -- 1028
				end -- 1022
			end -- 1021
		end -- 1021
	end -- 1021
	return { -- 1019
		success = false -- 1019
	} -- 1019
end) -- 1019
HttpServer:post("/yarn/check-file", function(req) -- 1030
	local yarncompile = require("yarncompile") -- 1031
	do -- 1032
		local _type_0 = type(req) -- 1032
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1032
		if _tab_0 then -- 1032
			local code -- 1032
			do -- 1032
				local _obj_0 = req.body -- 1032
				local _type_1 = type(_obj_0) -- 1032
				if "table" == _type_1 or "userdata" == _type_1 then -- 1032
					code = _obj_0.code -- 1032
				end -- 1032
			end -- 1032
			if code ~= nil then -- 1032
				local res, _, err = yarncompile(code, true) -- 1033
				if not res then -- 1033
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1034
					return { -- 1035
						success = false, -- 1035
						message = message, -- 1035
						line = line, -- 1035
						column = column, -- 1035
						node = node -- 1035
					} -- 1035
				end -- 1033
			end -- 1032
		end -- 1032
	end -- 1032
	return { -- 1030
		success = true -- 1030
	} -- 1030
end) -- 1030
local getWaProjectDirFromFile -- 1037
getWaProjectDirFromFile = function(file) -- 1037
	local writablePath = Content.writablePath -- 1038
	local parent, current -- 1039
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1039
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1040
	else -- 1042
		parent, current = nil, nil -- 1042
	end -- 1039
	if not current then -- 1043
		return nil -- 1043
	end -- 1043
	repeat -- 1044
		current = Path:getPath(current) -- 1045
		if current == "" then -- 1046
			break -- 1046
		end -- 1046
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1047
		for _index_0 = 1, #_list_0 do -- 1047
			local f = _list_0[_index_0] -- 1047
			if Path:getFilename(f):lower() == "wa.mod" then -- 1048
				return Path(parent, current, Path:getPath(f)) -- 1049
			end -- 1048
		end -- 1047
	until false -- 1044
	return nil -- 1051
end -- 1037
HttpServer:postSchedule("/wa/build", function(req) -- 1053
	do -- 1054
		local _type_0 = type(req) -- 1054
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1054
		if _tab_0 then -- 1054
			local path -- 1054
			do -- 1054
				local _obj_0 = req.body -- 1054
				local _type_1 = type(_obj_0) -- 1054
				if "table" == _type_1 or "userdata" == _type_1 then -- 1054
					path = _obj_0.path -- 1054
				end -- 1054
			end -- 1054
			if path ~= nil then -- 1054
				local projDir = getWaProjectDirFromFile(path) -- 1055
				if projDir then -- 1055
					local message = Wasm:buildWaAsync(projDir) -- 1056
					if message == "" then -- 1057
						return { -- 1058
							success = true -- 1058
						} -- 1058
					else -- 1060
						return { -- 1060
							success = false, -- 1060
							message = message -- 1060
						} -- 1060
					end -- 1057
				else -- 1062
					return { -- 1062
						success = false, -- 1062
						message = 'Wa file needs a project' -- 1062
					} -- 1062
				end -- 1055
			end -- 1054
		end -- 1054
	end -- 1054
	return { -- 1063
		success = false, -- 1063
		message = 'failed to build' -- 1063
	} -- 1063
end) -- 1053
HttpServer:postSchedule("/wa/format", function(req) -- 1065
	do -- 1066
		local _type_0 = type(req) -- 1066
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1066
		if _tab_0 then -- 1066
			local file -- 1066
			do -- 1066
				local _obj_0 = req.body -- 1066
				local _type_1 = type(_obj_0) -- 1066
				if "table" == _type_1 or "userdata" == _type_1 then -- 1066
					file = _obj_0.file -- 1066
				end -- 1066
			end -- 1066
			if file ~= nil then -- 1066
				local code = Wasm:formatWaAsync(file) -- 1067
				if code == "" then -- 1068
					return { -- 1069
						success = false -- 1069
					} -- 1069
				else -- 1071
					return { -- 1071
						success = true, -- 1071
						code = code -- 1071
					} -- 1071
				end -- 1068
			end -- 1066
		end -- 1066
	end -- 1066
	return { -- 1072
		success = false -- 1072
	} -- 1072
end) -- 1065
HttpServer:postSchedule("/wa/create", function(req) -- 1074
	do -- 1075
		local _type_0 = type(req) -- 1075
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1075
		if _tab_0 then -- 1075
			local path -- 1075
			do -- 1075
				local _obj_0 = req.body -- 1075
				local _type_1 = type(_obj_0) -- 1075
				if "table" == _type_1 or "userdata" == _type_1 then -- 1075
					path = _obj_0.path -- 1075
				end -- 1075
			end -- 1075
			if path ~= nil then -- 1075
				if not Content:exist(Path:getPath(path)) then -- 1076
					return { -- 1077
						success = false, -- 1077
						message = "target path not existed" -- 1077
					} -- 1077
				end -- 1076
				if Content:exist(path) then -- 1078
					return { -- 1079
						success = false, -- 1079
						message = "target project folder existed" -- 1079
					} -- 1079
				end -- 1078
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1080
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1081
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1082
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1083
					return { -- 1086
						success = false, -- 1086
						message = "missing template project" -- 1086
					} -- 1086
				end -- 1083
				if not Content:mkdir(path) then -- 1087
					return { -- 1088
						success = false, -- 1088
						message = "failed to create project folder" -- 1088
					} -- 1088
				end -- 1087
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1089
					Content:remove(path) -- 1090
					return { -- 1091
						success = false, -- 1091
						message = "failed to copy template" -- 1091
					} -- 1091
				end -- 1089
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1092
					Content:remove(path) -- 1093
					return { -- 1094
						success = false, -- 1094
						message = "failed to copy template" -- 1094
					} -- 1094
				end -- 1092
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1095
					Content:remove(path) -- 1096
					return { -- 1097
						success = false, -- 1097
						message = "failed to copy template" -- 1097
					} -- 1097
				end -- 1095
				return { -- 1098
					success = true -- 1098
				} -- 1098
			end -- 1075
		end -- 1075
	end -- 1075
	return { -- 1074
		success = false, -- 1074
		message = "invalid call" -- 1074
	} -- 1074
end) -- 1074
local _anon_func_3 = function(path) -- 1107
	local _val_0 = Path:getExt(path) -- 1107
	return "ts" == _val_0 or "tsx" == _val_0 -- 1107
end -- 1107
local _anon_func_4 = function(f) -- 1137
	local _val_0 = Path:getExt(f) -- 1137
	return "ts" == _val_0 or "tsx" == _val_0 -- 1137
end -- 1137
HttpServer:postSchedule("/ts/build", function(req) -- 1100
	do -- 1101
		local _type_0 = type(req) -- 1101
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1101
		if _tab_0 then -- 1101
			local path -- 1101
			do -- 1101
				local _obj_0 = req.body -- 1101
				local _type_1 = type(_obj_0) -- 1101
				if "table" == _type_1 or "userdata" == _type_1 then -- 1101
					path = _obj_0.path -- 1101
				end -- 1101
			end -- 1101
			if path ~= nil then -- 1101
				if HttpServer.wsConnectionCount == 0 then -- 1102
					return { -- 1103
						success = false, -- 1103
						message = "Web IDE not connected" -- 1103
					} -- 1103
				end -- 1102
				if not Content:exist(path) then -- 1104
					return { -- 1105
						success = false, -- 1105
						message = "path not existed" -- 1105
					} -- 1105
				end -- 1104
				if not Content:isdir(path) then -- 1106
					if not (_anon_func_3(path)) then -- 1107
						return { -- 1108
							success = false, -- 1108
							message = "expecting a TypeScript file" -- 1108
						} -- 1108
					end -- 1107
					local messages = { } -- 1109
					local content = Content:load(path) -- 1110
					if not content then -- 1111
						return { -- 1112
							success = false, -- 1112
							message = "failed to read file" -- 1112
						} -- 1112
					end -- 1111
					emit("AppWS", "Send", json.encode({ -- 1113
						name = "UpdateTSCode", -- 1113
						file = path, -- 1113
						content = content -- 1113
					})) -- 1113
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1114
						local done = false -- 1115
						do -- 1116
							local _with_0 = Node() -- 1116
							_with_0:gslot("AppWS", function(eventType, msg) -- 1117
								if eventType == "Receive" then -- 1118
									_with_0:removeFromParent() -- 1119
									local res = json.decode(msg) -- 1120
									if res then -- 1120
										if res.name == "TranspileTS" then -- 1121
											if res.success then -- 1122
												local luaFile = Path:replaceExt(path, "lua") -- 1123
												Content:save(luaFile, res.luaCode) -- 1124
												messages[#messages + 1] = { -- 1125
													success = true, -- 1125
													file = path -- 1125
												} -- 1125
											else -- 1127
												messages[#messages + 1] = { -- 1127
													success = false, -- 1127
													file = path, -- 1127
													message = res.message -- 1127
												} -- 1127
											end -- 1122
											done = true -- 1128
										end -- 1121
									end -- 1120
								end -- 1118
							end) -- 1117
						end -- 1116
						emit("AppWS", "Send", json.encode({ -- 1129
							name = "TranspileTS", -- 1129
							file = path, -- 1129
							content = content -- 1129
						})) -- 1129
						wait(function() -- 1130
							return done -- 1130
						end) -- 1130
					end -- 1114
					return { -- 1131
						success = true, -- 1131
						messages = messages -- 1131
					} -- 1131
				else -- 1133
					local files = Content:getAllFiles(path) -- 1133
					local fileData = { } -- 1134
					local messages = { } -- 1135
					for _index_0 = 1, #files do -- 1136
						local f = files[_index_0] -- 1136
						if not (_anon_func_4(f)) then -- 1137
							goto _continue_0 -- 1137
						end -- 1137
						local file = Path(path, f) -- 1138
						local content = Content:load(file) -- 1139
						if content then -- 1139
							fileData[file] = content -- 1140
							emit("AppWS", "Send", json.encode({ -- 1141
								name = "UpdateTSCode", -- 1141
								file = file, -- 1141
								content = content -- 1141
							})) -- 1141
						else -- 1143
							messages[#messages + 1] = { -- 1143
								success = false, -- 1143
								file = file, -- 1143
								message = "failed to read file" -- 1143
							} -- 1143
						end -- 1139
						::_continue_0:: -- 1137
					end -- 1136
					for file, content in pairs(fileData) do -- 1144
						if "d" == Path:getExt(Path:getName(file)) then -- 1145
							goto _continue_1 -- 1145
						end -- 1145
						local done = false -- 1146
						do -- 1147
							local _with_0 = Node() -- 1147
							_with_0:gslot("AppWS", function(eventType, msg) -- 1148
								if eventType == "Receive" then -- 1149
									_with_0:removeFromParent() -- 1150
									local res = json.decode(msg) -- 1151
									if res then -- 1151
										if res.name == "TranspileTS" then -- 1152
											if res.success then -- 1153
												local luaFile = Path:replaceExt(file, "lua") -- 1154
												Content:save(luaFile, res.luaCode) -- 1155
												messages[#messages + 1] = { -- 1156
													success = true, -- 1156
													file = file -- 1156
												} -- 1156
											else -- 1158
												messages[#messages + 1] = { -- 1158
													success = false, -- 1158
													file = file, -- 1158
													message = res.message -- 1158
												} -- 1158
											end -- 1153
											done = true -- 1159
										end -- 1152
									end -- 1151
								end -- 1149
							end) -- 1148
						end -- 1147
						emit("AppWS", "Send", json.encode({ -- 1160
							name = "TranspileTS", -- 1160
							file = file, -- 1160
							content = content -- 1160
						})) -- 1160
						wait(function() -- 1161
							return done -- 1161
						end) -- 1161
						::_continue_1:: -- 1145
					end -- 1144
					return { -- 1162
						success = true, -- 1162
						messages = messages -- 1162
					} -- 1162
				end -- 1106
			end -- 1101
		end -- 1101
	end -- 1101
	return { -- 1100
		success = false -- 1100
	} -- 1100
end) -- 1100
HttpServer:post("/download", function(req) -- 1164
	do -- 1165
		local _type_0 = type(req) -- 1165
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1165
		if _tab_0 then -- 1165
			local url -- 1165
			do -- 1165
				local _obj_0 = req.body -- 1165
				local _type_1 = type(_obj_0) -- 1165
				if "table" == _type_1 or "userdata" == _type_1 then -- 1165
					url = _obj_0.url -- 1165
				end -- 1165
			end -- 1165
			local target -- 1165
			do -- 1165
				local _obj_0 = req.body -- 1165
				local _type_1 = type(_obj_0) -- 1165
				if "table" == _type_1 or "userdata" == _type_1 then -- 1165
					target = _obj_0.target -- 1165
				end -- 1165
			end -- 1165
			if url ~= nil and target ~= nil then -- 1165
				local Entry = require("Script.Dev.Entry") -- 1166
				Entry.downloadFile(url, target) -- 1167
				return { -- 1168
					success = true -- 1168
				} -- 1168
			end -- 1165
		end -- 1165
	end -- 1165
	return { -- 1164
		success = false -- 1164
	} -- 1164
end) -- 1164
local status = { } -- 1170
_module_0 = status -- 1171
thread(function() -- 1173
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1174
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1175
	if Content:exist(doraWeb) then -- 1176
		local needReload -- 1177
		if Content:exist(doraReady) then -- 1177
			needReload = App.version ~= Content:load(doraReady) -- 1178
		else -- 1179
			needReload = true -- 1179
		end -- 1177
		if needReload then -- 1180
			Content:remove(Path(Content.appPath, ".www")) -- 1181
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1182
			Content:save(doraReady, App.version) -- 1186
			print("Dora Dora is ready!") -- 1187
		end -- 1180
	end -- 1176
	if HttpServer:start(8866) then -- 1188
		local localIP = HttpServer.localIP -- 1189
		if localIP == "" then -- 1190
			localIP = "localhost" -- 1190
		end -- 1190
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1191
		return HttpServer:startWS(8868) -- 1192
	else -- 1194
		status.url = nil -- 1194
		return print("8866 Port not available!") -- 1195
	end -- 1188
end) -- 1173
return _module_0 -- 1
