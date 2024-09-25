-- [yue]: Script/Dev/WebServer.yue
local HttpServer = Dora.HttpServer -- 1
local Path = Dora.Path -- 1
local Content = Dora.Content -- 1
local yue = Dora.yue -- 1
local tostring = _G.tostring -- 1
local load = _G.load -- 1
local tonumber = _G.tonumber -- 1
local teal = Dora.teal -- 1
local type = _G.type -- 1
local xml = Dora.xml -- 1
local table = _G.table -- 1
local ipairs = _G.ipairs -- 1
local pairs = _G.pairs -- 1
local App = Dora.App -- 1
local setmetatable = _G.setmetatable -- 1
local wait = Dora.wait -- 1
local package = _G.package -- 1
local thread = Dora.thread -- 1
local print = _G.print -- 1
local sleep = Dora.sleep -- 1
local json = Dora.json -- 1
local emit = Dora.emit -- 1
local _module_0 = nil -- 1
HttpServer:stop() -- 11
HttpServer.wwwPath = Path(Content.writablePath, ".www") -- 13
local LintYueGlobals -- 15
do -- 15
	local _obj_0 = require("Utils") -- 15
	LintYueGlobals = _obj_0.LintYueGlobals -- 15
end -- 15
local getProjectDirFromFile -- 17
getProjectDirFromFile = function(file) -- 17
	local writablePath, assetPath -- 18
	do -- 18
		local _obj_0 = Content -- 18
		writablePath, assetPath = _obj_0.writablePath, _obj_0.assetPath -- 18
	end -- 18
	local parent, current -- 19
	if writablePath == file:sub(1, #writablePath) then -- 19
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 20
	elseif assetPath == file:sub(1, #assetPath) then -- 21
		local dir = Path(assetPath, "Script") -- 22
		parent, current = dir, Path:getRelative(file, dir) -- 23
	else -- 25
		parent, current = nil, nil -- 25
	end -- 19
	if not current then -- 26
		return nil -- 26
	end -- 26
	repeat -- 27
		current = Path:getPath(current) -- 28
		if current == "" then -- 29
			break -- 29
		end -- 29
		local _list_0 = Content:getFiles(Path(parent, current)) -- 30
		for _index_0 = 1, #_list_0 do -- 30
			local f = _list_0[_index_0] -- 30
			if Path:getName(f):lower() == "init" then -- 31
				return Path(parent, current, Path:getPath(f)) -- 32
			end -- 31
		end -- 32
	until false -- 33
	return nil -- 34
end -- 17
local getSearchPath -- 36
getSearchPath = function(file) -- 36
	do -- 37
		local dir = getProjectDirFromFile(file) -- 37
		if dir then -- 37
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 38
		end -- 37
	end -- 37
	return "" -- 38
end -- 36
local getSearchFolders -- 40
getSearchFolders = function(file) -- 40
	do -- 41
		local dir = getProjectDirFromFile(file) -- 41
		if dir then -- 41
			return { -- 43
				Path(dir, "Script"), -- 43
				dir -- 44
			} -- 44
		end -- 41
	end -- 41
	return { } -- 40
end -- 40
local disabledCheckForLua = { -- 47
	"incompatible number of returns", -- 47
	"unknown", -- 48
	"cannot index", -- 49
	"module not found", -- 50
	"don't know how to resolve", -- 51
	"ContainerItem", -- 52
	"cannot resolve a type", -- 53
	"invalid key", -- 54
	"inconsistent index type", -- 55
	"cannot use operator", -- 56
	"attempting ipairs loop", -- 57
	"expects record or nominal", -- 58
	"variable is not being assigned", -- 59
	"<invalid type>", -- 60
	"<any type>", -- 61
	"using the '#' operator", -- 62
	"can't match a record", -- 63
	"redeclaration of variable", -- 64
	"cannot apply pairs", -- 65
	"not a function", -- 66
	"to%-be%-closed" -- 67
} -- 46
local yueCheck -- 69
yueCheck = function(file, content) -- 69
	local searchPath = getSearchPath(file) -- 70
	local checkResult, luaCodes = yue.checkAsync(content, searchPath) -- 71
	local info = { } -- 72
	local globals = { } -- 73
	for _index_0 = 1, #checkResult do -- 74
		local _des_0 = checkResult[_index_0] -- 74
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 74
		if "error" == t then -- 75
			info[#info + 1] = { -- 76
				"syntax", -- 76
				file, -- 76
				line, -- 76
				col, -- 76
				msg -- 76
			} -- 76
		elseif "global" == t then -- 77
			globals[#globals + 1] = { -- 78
				msg, -- 78
				line, -- 78
				col -- 78
			} -- 78
		end -- 78
	end -- 78
	if luaCodes then -- 79
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 80
		if success then -- 81
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 82
			if not (lintResult == "") then -- 83
				lintResult = lintResult .. "\n" -- 83
			end -- 83
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 84
		else -- 85
			for _index_0 = 1, #lintResult do -- 85
				local _des_0 = lintResult[_index_0] -- 85
				local _name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 85
				info[#info + 1] = { -- 86
					"syntax", -- 86
					file, -- 86
					line, -- 86
					col, -- 86
					"invalid global variable" -- 86
				} -- 86
			end -- 86
		end -- 81
	end -- 79
	return luaCodes, info -- 87
end -- 69
local luaCheck -- 89
luaCheck = function(file, content) -- 89
	local res, err = load(content, "check") -- 90
	if not res then -- 91
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 92
		return { -- 93
			success = false, -- 93
			info = { -- 93
				{ -- 93
					"syntax", -- 93
					file, -- 93
					tonumber(line), -- 93
					0, -- 93
					msg -- 93
				} -- 93
			} -- 93
		} -- 93
	end -- 91
	local success, info = teal.checkAsync(content, file, true, "") -- 94
	if info then -- 95
		do -- 96
			local _accum_0 = { } -- 96
			local _len_0 = 1 -- 96
			for _index_0 = 1, #info do -- 96
				local item = info[_index_0] -- 96
				local useCheck = true -- 97
				if not item[5]:match("unused") then -- 98
					for _index_1 = 1, #disabledCheckForLua do -- 99
						local check = disabledCheckForLua[_index_1] -- 99
						if item[5]:match(check) then -- 100
							useCheck = false -- 101
						end -- 100
					end -- 101
				end -- 98
				if not useCheck then -- 102
					goto _continue_0 -- 102
				end -- 102
				do -- 103
					local _exp_0 = item[1] -- 103
					if "type" == _exp_0 then -- 104
						item[1] = "warning" -- 105
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 106
						goto _continue_0 -- 107
					end -- 107
				end -- 107
				_accum_0[_len_0] = item -- 108
				_len_0 = _len_0 + 1 -- 108
				::_continue_0:: -- 97
			end -- 108
			info = _accum_0 -- 96
		end -- 108
		if #info == 0 then -- 109
			info = nil -- 110
			success = true -- 111
		end -- 109
	end -- 95
	return { -- 112
		success = success, -- 112
		info = info -- 112
	} -- 112
end -- 89
local luaCheckWithLineInfo -- 114
luaCheckWithLineInfo = function(file, luaCodes) -- 114
	local res = luaCheck(file, luaCodes) -- 115
	local info = { } -- 116
	if not res.success then -- 117
		local current = 1 -- 118
		local lastLine = 1 -- 119
		local lineMap = { } -- 120
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 121
			local num = lineCode:match("--%s*(%d+)%s*$") -- 122
			if num then -- 123
				lastLine = tonumber(num) -- 124
			end -- 123
			lineMap[current] = lastLine -- 125
			current = current + 1 -- 126
		end -- 126
		local _list_0 = res.info -- 127
		for _index_0 = 1, #_list_0 do -- 127
			local item = _list_0[_index_0] -- 127
			item[3] = lineMap[item[3]] or 0 -- 128
			item[4] = 0 -- 129
			info[#info + 1] = item -- 130
		end -- 130
		return false, info -- 131
	end -- 117
	return true, info -- 132
end -- 114
local getCompiledYueLine -- 134
getCompiledYueLine = function(content, line, row, file) -- 134
	local luaCodes, _info = yueCheck(file, content) -- 135
	if not luaCodes then -- 136
		return nil -- 136
	end -- 136
	local current = 1 -- 137
	local lastLine = 1 -- 138
	local targetLine = nil -- 139
	local targetRow = nil -- 140
	local lineMap = { } -- 141
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 142
		local num = lineCode:match("--%s*(%d+)%s*$") -- 143
		if num then -- 144
			lastLine = tonumber(num) -- 144
		end -- 144
		lineMap[current] = lastLine -- 145
		if row == lastLine and not targetLine then -- 146
			targetRow = current -- 147
			targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 148
			if targetLine then -- 149
				break -- 149
			end -- 149
		end -- 146
		current = current + 1 -- 150
	end -- 150
	if targetLine and targetRow then -- 151
		return luaCodes, targetLine, targetRow, lineMap -- 152
	else -- 154
		return nil -- 154
	end -- 151
end -- 134
HttpServer:postSchedule("/check", function(req) -- 156
	do -- 157
		local _type_0 = type(req) -- 157
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 157
		if _tab_0 then -- 157
			local file -- 157
			do -- 157
				local _obj_0 = req.body -- 157
				local _type_1 = type(_obj_0) -- 157
				if "table" == _type_1 or "userdata" == _type_1 then -- 157
					file = _obj_0.file -- 157
				end -- 187
			end -- 187
			local content -- 157
			do -- 157
				local _obj_0 = req.body -- 157
				local _type_1 = type(_obj_0) -- 157
				if "table" == _type_1 or "userdata" == _type_1 then -- 157
					content = _obj_0.content -- 157
				end -- 187
			end -- 187
			if file ~= nil and content ~= nil then -- 157
				local ext = Path:getExt(file) -- 158
				if "tl" == ext then -- 159
					local searchPath = getSearchPath(file) -- 160
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 161
					return { -- 162
						success = success, -- 162
						info = info -- 162
					} -- 162
				elseif "lua" == ext then -- 163
					return luaCheck(file, content) -- 164
				elseif "yue" == ext then -- 165
					local luaCodes, info = yueCheck(file, content) -- 166
					local success = false -- 167
					if luaCodes then -- 168
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 169
						do -- 170
							local _tab_1 = { } -- 170
							local _idx_0 = #_tab_1 + 1 -- 170
							for _index_0 = 1, #info do -- 170
								local _value_0 = info[_index_0] -- 170
								_tab_1[_idx_0] = _value_0 -- 170
								_idx_0 = _idx_0 + 1 -- 170
							end -- 170
							local _idx_1 = #_tab_1 + 1 -- 170
							for _index_0 = 1, #luaInfo do -- 170
								local _value_0 = luaInfo[_index_0] -- 170
								_tab_1[_idx_1] = _value_0 -- 170
								_idx_1 = _idx_1 + 1 -- 170
							end -- 170
							info = _tab_1 -- 170
						end -- 170
						success = success and luaSuccess -- 171
					end -- 168
					if #info > 0 then -- 172
						return { -- 173
							success = success, -- 173
							info = info -- 173
						} -- 173
					else -- 175
						return { -- 175
							success = success -- 175
						} -- 175
					end -- 172
				elseif "xml" == ext then -- 176
					local success, result = xml.check(content) -- 177
					if success then -- 178
						local info -- 179
						success, info = luaCheckWithLineInfo(file, result) -- 179
						if #info > 0 then -- 180
							return { -- 181
								success = success, -- 181
								info = info -- 181
							} -- 181
						else -- 183
							return { -- 183
								success = success -- 183
							} -- 183
						end -- 180
					else -- 185
						local info -- 185
						do -- 185
							local _accum_0 = { } -- 185
							local _len_0 = 1 -- 185
							for _index_0 = 1, #result do -- 185
								local _des_0 = result[_index_0] -- 185
								local row, err = _des_0[1], _des_0[2] -- 185
								_accum_0[_len_0] = { -- 186
									"syntax", -- 186
									file, -- 186
									row, -- 186
									0, -- 186
									err -- 186
								} -- 186
								_len_0 = _len_0 + 1 -- 186
							end -- 186
							info = _accum_0 -- 185
						end -- 186
						return { -- 187
							success = false, -- 187
							info = info -- 187
						} -- 187
					end -- 178
				end -- 187
			end -- 157
		end -- 187
	end -- 187
	return { -- 156
		success = true -- 156
	} -- 187
end) -- 156
local updateInferedDesc -- 189
updateInferedDesc = function(infered) -- 189
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 190
		return -- 190
	end -- 190
	local key, row = infered.key, infered.row -- 191
	local codes = Content:loadAsync(key) -- 192
	if codes then -- 192
		local comments = { } -- 193
		local line = 0 -- 194
		local skipping = false -- 195
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 196
			line = line + 1 -- 197
			if line >= row then -- 198
				break -- 198
			end -- 198
			if lineCode:match("^%s*%-%- @") then -- 199
				skipping = true -- 200
				goto _continue_0 -- 201
			end -- 199
			local result = lineCode:match("^%s*%-%- (.+)") -- 202
			if result then -- 202
				if not skipping then -- 203
					comments[#comments + 1] = result -- 203
				end -- 203
			elseif #comments > 0 then -- 204
				comments = { } -- 205
				skipping = false -- 206
			end -- 202
			::_continue_0:: -- 197
		end -- 206
		infered.doc = table.concat(comments, "\n") -- 207
	end -- 192
end -- 189
HttpServer:postSchedule("/infer", function(req) -- 209
	do -- 210
		local _type_0 = type(req) -- 210
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 210
		if _tab_0 then -- 210
			local lang -- 210
			do -- 210
				local _obj_0 = req.body -- 210
				local _type_1 = type(_obj_0) -- 210
				if "table" == _type_1 or "userdata" == _type_1 then -- 210
					lang = _obj_0.lang -- 210
				end -- 227
			end -- 227
			local file -- 210
			do -- 210
				local _obj_0 = req.body -- 210
				local _type_1 = type(_obj_0) -- 210
				if "table" == _type_1 or "userdata" == _type_1 then -- 210
					file = _obj_0.file -- 210
				end -- 227
			end -- 227
			local content -- 210
			do -- 210
				local _obj_0 = req.body -- 210
				local _type_1 = type(_obj_0) -- 210
				if "table" == _type_1 or "userdata" == _type_1 then -- 210
					content = _obj_0.content -- 210
				end -- 227
			end -- 227
			local line -- 210
			do -- 210
				local _obj_0 = req.body -- 210
				local _type_1 = type(_obj_0) -- 210
				if "table" == _type_1 or "userdata" == _type_1 then -- 210
					line = _obj_0.line -- 210
				end -- 227
			end -- 227
			local row -- 210
			do -- 210
				local _obj_0 = req.body -- 210
				local _type_1 = type(_obj_0) -- 210
				if "table" == _type_1 or "userdata" == _type_1 then -- 210
					row = _obj_0.row -- 210
				end -- 227
			end -- 227
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 210
				local searchPath = getSearchPath(file) -- 211
				if "tl" == lang or "lua" == lang then -- 212
					local infered = teal.inferAsync(content, line, row, searchPath) -- 213
					if (infered ~= nil) then -- 214
						updateInferedDesc(infered) -- 215
						return { -- 216
							success = true, -- 216
							infered = infered -- 216
						} -- 216
					end -- 214
				elseif "yue" == lang then -- 217
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file) -- 218
					if not luaCodes then -- 219
						return { -- 219
							success = false -- 219
						} -- 219
					end -- 219
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 220
					if (infered ~= nil) then -- 221
						local col -- 222
						file, row, col = infered.file, infered.row, infered.col -- 222
						if file == "" and row > 0 and col > 0 then -- 223
							infered.row = lineMap[row] or 0 -- 224
							infered.col = 0 -- 225
						end -- 223
						updateInferedDesc(infered) -- 226
						return { -- 227
							success = true, -- 227
							infered = infered -- 227
						} -- 227
					end -- 221
				end -- 227
			end -- 210
		end -- 227
	end -- 227
	return { -- 209
		success = false -- 209
	} -- 227
end) -- 209
local _anon_func_0 = function(doc) -- 278
	local _accum_0 = { } -- 278
	local _len_0 = 1 -- 278
	local _list_0 = doc.params -- 278
	for _index_0 = 1, #_list_0 do -- 278
		local param = _list_0[_index_0] -- 278
		_accum_0[_len_0] = param.name -- 278
		_len_0 = _len_0 + 1 -- 278
	end -- 278
	return _accum_0 -- 278
end -- 278
local getParamDocs -- 229
getParamDocs = function(signatures) -- 229
	do -- 230
		local codes = Content:loadAsync(signatures[1].file) -- 230
		if codes then -- 230
			local comments = { } -- 231
			local params = { } -- 232
			local line = 0 -- 233
			local docs = { } -- 234
			local returnType = nil -- 235
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 236
				line = line + 1 -- 237
				local needBreak = true -- 238
				for i, _des_0 in ipairs(signatures) do -- 239
					local row = _des_0.row -- 239
					if line >= row and not (docs[i] ~= nil) then -- 240
						if #comments > 0 or #params > 0 or returnType then -- 241
							docs[i] = { -- 243
								doc = table.concat(comments, "  \n"), -- 243
								returnType = returnType -- 244
							} -- 242
							if #params > 0 then -- 246
								docs[i].params = params -- 246
							end -- 246
						else -- 248
							docs[i] = false -- 248
						end -- 241
					end -- 240
					if not docs[i] then -- 249
						needBreak = false -- 249
					end -- 249
				end -- 249
				if needBreak then -- 250
					break -- 250
				end -- 250
				local result = lineCode:match("%s*%-%- (.+)") -- 251
				if result then -- 251
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 252
					if not name then -- 253
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 254
					end -- 253
					if name then -- 255
						local pname = name -- 256
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 257
							pname = pname .. "?" -- 257
						end -- 257
						params[#params + 1] = { -- 259
							name = tostring(pname) .. ": " .. tostring(typ), -- 259
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 260
						} -- 258
					else -- 263
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 263
						if typ then -- 263
							if returnType then -- 264
								returnType = returnType .. ", " .. typ -- 265
							else -- 267
								returnType = typ -- 267
							end -- 264
							result = result:gsub("@return", "**return:**") -- 268
						end -- 263
						comments[#comments + 1] = result -- 269
					end -- 255
				elseif #comments > 0 then -- 270
					comments = { } -- 271
					params = { } -- 272
					returnType = nil -- 273
				end -- 251
			end -- 273
			local results = { } -- 274
			for _index_0 = 1, #docs do -- 275
				local doc = docs[_index_0] -- 275
				if not doc then -- 276
					goto _continue_0 -- 276
				end -- 276
				if doc.params then -- 277
					doc.desc = "function(" .. tostring(table.concat(_anon_func_0(doc), ', ')) .. ")" -- 278
				else -- 280
					doc.desc = "function()" -- 280
				end -- 277
				if doc.returnType then -- 281
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 282
					doc.returnType = nil -- 283
				end -- 281
				results[#results + 1] = doc -- 284
				::_continue_0:: -- 276
			end -- 284
			if #results > 0 then -- 285
				return results -- 285
			else -- 285
				return nil -- 285
			end -- 285
		end -- 230
	end -- 230
	return nil -- 285
end -- 229
HttpServer:postSchedule("/signature", function(req) -- 287
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
				end -- 305
			end -- 305
			local file -- 288
			do -- 288
				local _obj_0 = req.body -- 288
				local _type_1 = type(_obj_0) -- 288
				if "table" == _type_1 or "userdata" == _type_1 then -- 288
					file = _obj_0.file -- 288
				end -- 305
			end -- 305
			local content -- 288
			do -- 288
				local _obj_0 = req.body -- 288
				local _type_1 = type(_obj_0) -- 288
				if "table" == _type_1 or "userdata" == _type_1 then -- 288
					content = _obj_0.content -- 288
				end -- 305
			end -- 305
			local line -- 288
			do -- 288
				local _obj_0 = req.body -- 288
				local _type_1 = type(_obj_0) -- 288
				if "table" == _type_1 or "userdata" == _type_1 then -- 288
					line = _obj_0.line -- 288
				end -- 305
			end -- 305
			local row -- 288
			do -- 288
				local _obj_0 = req.body -- 288
				local _type_1 = type(_obj_0) -- 288
				if "table" == _type_1 or "userdata" == _type_1 then -- 288
					row = _obj_0.row -- 288
				end -- 305
			end -- 305
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 288
				local searchPath = getSearchPath(file) -- 289
				if "tl" == lang or "lua" == lang then -- 290
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 291
					if signatures then -- 291
						signatures = getParamDocs(signatures) -- 292
						if signatures then -- 292
							return { -- 293
								success = true, -- 293
								signatures = signatures -- 293
							} -- 293
						end -- 292
					end -- 291
				elseif "yue" == lang then -- 294
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file) -- 295
					if not luaCodes then -- 296
						return { -- 296
							success = false -- 296
						} -- 296
					end -- 296
					do -- 297
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 297
						if chainOp then -- 297
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 298
							targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 299
						end -- 297
					end -- 297
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 300
					if signatures then -- 300
						signatures = getParamDocs(signatures) -- 301
						if signatures then -- 301
							return { -- 302
								success = true, -- 302
								signatures = signatures -- 302
							} -- 302
						end -- 301
					else -- 303
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 303
						if signatures then -- 303
							signatures = getParamDocs(signatures) -- 304
							if signatures then -- 304
								return { -- 305
									success = true, -- 305
									signatures = signatures -- 305
								} -- 305
							end -- 304
						end -- 303
					end -- 300
				end -- 305
			end -- 288
		end -- 305
	end -- 305
	return { -- 287
		success = false -- 287
	} -- 305
end) -- 287
local luaKeywords = { -- 308
	'and', -- 308
	'break', -- 309
	'do', -- 310
	'else', -- 311
	'elseif', -- 312
	'end', -- 313
	'false', -- 314
	'for', -- 315
	'function', -- 316
	'goto', -- 317
	'if', -- 318
	'in', -- 319
	'local', -- 320
	'nil', -- 321
	'not', -- 322
	'or', -- 323
	'repeat', -- 324
	'return', -- 325
	'then', -- 326
	'true', -- 327
	'until', -- 328
	'while' -- 329
} -- 307
local tealKeywords = { -- 333
	'record', -- 333
	'as', -- 334
	'is', -- 335
	'type', -- 336
	'embed', -- 337
	'enum', -- 338
	'global', -- 339
	'any', -- 340
	'boolean', -- 341
	'integer', -- 342
	'number', -- 343
	'string', -- 344
	'thread' -- 345
} -- 332
local yueKeywords = { -- 349
	"and", -- 349
	"break", -- 350
	"do", -- 351
	"else", -- 352
	"elseif", -- 353
	"false", -- 354
	"for", -- 355
	"goto", -- 356
	"if", -- 357
	"in", -- 358
	"local", -- 359
	"nil", -- 360
	"not", -- 361
	"or", -- 362
	"repeat", -- 363
	"return", -- 364
	"then", -- 365
	"true", -- 366
	"until", -- 367
	"while", -- 368
	"as", -- 369
	"class", -- 370
	"continue", -- 371
	"export", -- 372
	"extends", -- 373
	"from", -- 374
	"global", -- 375
	"import", -- 376
	"macro", -- 377
	"switch", -- 378
	"try", -- 379
	"unless", -- 380
	"using", -- 381
	"when", -- 382
	"with" -- 383
} -- 348
local _anon_func_1 = function(Path, f) -- 419
	local _val_0 = Path:getExt(f) -- 419
	return "ttf" == _val_0 or "otf" == _val_0 -- 419
end -- 419
local _anon_func_2 = function(suggestions) -- 445
	local _tbl_0 = { } -- 445
	for _index_0 = 1, #suggestions do -- 445
		local item = suggestions[_index_0] -- 445
		_tbl_0[item[1] .. item[2]] = item -- 445
	end -- 445
	return _tbl_0 -- 445
end -- 445
HttpServer:postSchedule("/complete", function(req) -- 386
	do -- 387
		local _type_0 = type(req) -- 387
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 387
		if _tab_0 then -- 387
			local lang -- 387
			do -- 387
				local _obj_0 = req.body -- 387
				local _type_1 = type(_obj_0) -- 387
				if "table" == _type_1 or "userdata" == _type_1 then -- 387
					lang = _obj_0.lang -- 387
				end -- 494
			end -- 494
			local file -- 387
			do -- 387
				local _obj_0 = req.body -- 387
				local _type_1 = type(_obj_0) -- 387
				if "table" == _type_1 or "userdata" == _type_1 then -- 387
					file = _obj_0.file -- 387
				end -- 494
			end -- 494
			local content -- 387
			do -- 387
				local _obj_0 = req.body -- 387
				local _type_1 = type(_obj_0) -- 387
				if "table" == _type_1 or "userdata" == _type_1 then -- 387
					content = _obj_0.content -- 387
				end -- 494
			end -- 494
			local line -- 387
			do -- 387
				local _obj_0 = req.body -- 387
				local _type_1 = type(_obj_0) -- 387
				if "table" == _type_1 or "userdata" == _type_1 then -- 387
					line = _obj_0.line -- 387
				end -- 494
			end -- 494
			local row -- 387
			do -- 387
				local _obj_0 = req.body -- 387
				local _type_1 = type(_obj_0) -- 387
				if "table" == _type_1 or "userdata" == _type_1 then -- 387
					row = _obj_0.row -- 387
				end -- 494
			end -- 494
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 387
				local searchPath = getSearchPath(file) -- 388
				repeat -- 389
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 390
					if lang == "yue" then -- 391
						if not item then -- 392
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 392
						end -- 392
						if not item then -- 393
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 393
						end -- 393
					end -- 391
					local searchType = nil -- 394
					if not item then -- 395
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 396
						if lang == "yue" then -- 397
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 398
						end -- 397
						if (item ~= nil) then -- 399
							searchType = "Image" -- 399
						end -- 399
					end -- 395
					if not item then -- 400
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 401
						if lang == "yue" then -- 402
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 403
						end -- 402
						if (item ~= nil) then -- 404
							searchType = "Font" -- 404
						end -- 404
					end -- 400
					if not item then -- 405
						break -- 405
					end -- 405
					local searchPaths = Content.searchPaths -- 406
					local _list_0 = getSearchFolders(file) -- 407
					for _index_0 = 1, #_list_0 do -- 407
						local folder = _list_0[_index_0] -- 407
						searchPaths[#searchPaths + 1] = folder -- 408
					end -- 408
					if searchType then -- 409
						searchPaths[#searchPaths + 1] = Content.assetPath -- 409
					end -- 409
					local tokens -- 410
					do -- 410
						local _accum_0 = { } -- 410
						local _len_0 = 1 -- 410
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 410
							_accum_0[_len_0] = mod -- 410
							_len_0 = _len_0 + 1 -- 410
						end -- 410
						tokens = _accum_0 -- 410
					end -- 410
					local suggestions = { } -- 411
					for _index_0 = 1, #searchPaths do -- 412
						local path = searchPaths[_index_0] -- 412
						local sPath = Path(path, table.unpack(tokens)) -- 413
						if not Content:exist(sPath) then -- 414
							goto _continue_0 -- 414
						end -- 414
						if searchType == "Font" then -- 415
							local fontPath = Path(sPath, "Font") -- 416
							if Content:exist(fontPath) then -- 417
								local _list_1 = Content:getFiles(fontPath) -- 418
								for _index_1 = 1, #_list_1 do -- 418
									local f = _list_1[_index_1] -- 418
									if _anon_func_1(Path, f) then -- 419
										if "." == f:sub(1, 1) then -- 420
											goto _continue_1 -- 420
										end -- 420
										suggestions[#suggestions + 1] = { -- 421
											Path:getName(f), -- 421
											"font", -- 421
											"field" -- 421
										} -- 421
									end -- 419
									::_continue_1:: -- 419
								end -- 421
							end -- 417
						end -- 415
						local _list_1 = Content:getFiles(sPath) -- 422
						for _index_1 = 1, #_list_1 do -- 422
							local f = _list_1[_index_1] -- 422
							if "Image" == searchType then -- 423
								do -- 424
									local _exp_0 = Path:getExt(f) -- 424
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 424
										if "." == f:sub(1, 1) then -- 425
											goto _continue_2 -- 425
										end -- 425
										suggestions[#suggestions + 1] = { -- 426
											f, -- 426
											"image", -- 426
											"field" -- 426
										} -- 426
									end -- 426
								end -- 426
								goto _continue_2 -- 427
							elseif "Font" == searchType then -- 428
								do -- 429
									local _exp_0 = Path:getExt(f) -- 429
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 429
										if "." == f:sub(1, 1) then -- 430
											goto _continue_2 -- 430
										end -- 430
										suggestions[#suggestions + 1] = { -- 431
											f, -- 431
											"font", -- 431
											"field" -- 431
										} -- 431
									end -- 431
								end -- 431
								goto _continue_2 -- 432
							end -- 432
							local _exp_0 = Path:getExt(f) -- 433
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 433
								local name = Path:getName(f) -- 434
								if "d" == Path:getExt(name) then -- 435
									goto _continue_2 -- 435
								end -- 435
								if "." == name:sub(1, 1) then -- 436
									goto _continue_2 -- 436
								end -- 436
								suggestions[#suggestions + 1] = { -- 437
									name, -- 437
									"module", -- 437
									"field" -- 437
								} -- 437
							end -- 437
							::_continue_2:: -- 423
						end -- 437
						local _list_2 = Content:getDirs(sPath) -- 438
						for _index_1 = 1, #_list_2 do -- 438
							local dir = _list_2[_index_1] -- 438
							if "." == dir:sub(1, 1) then -- 439
								goto _continue_3 -- 439
							end -- 439
							suggestions[#suggestions + 1] = { -- 440
								dir, -- 440
								"folder", -- 440
								"variable" -- 440
							} -- 440
							::_continue_3:: -- 439
						end -- 440
						::_continue_0:: -- 413
					end -- 440
					if item == "" and not searchType then -- 441
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 442
						for _index_0 = 1, #_list_1 do -- 442
							local _des_0 = _list_1[_index_0] -- 442
							local name = _des_0[1] -- 442
							suggestions[#suggestions + 1] = { -- 443
								name, -- 443
								"dora module", -- 443
								"function" -- 443
							} -- 443
						end -- 443
					end -- 441
					if #suggestions > 0 then -- 444
						do -- 445
							local _accum_0 = { } -- 445
							local _len_0 = 1 -- 445
							for _, v in pairs(_anon_func_2(suggestions)) do -- 445
								_accum_0[_len_0] = v -- 445
								_len_0 = _len_0 + 1 -- 445
							end -- 445
							suggestions = _accum_0 -- 445
						end -- 445
						return { -- 446
							success = true, -- 446
							suggestions = suggestions -- 446
						} -- 446
					else -- 448
						return { -- 448
							success = false -- 448
						} -- 448
					end -- 444
				until true -- 449
				if "tl" == lang or "lua" == lang then -- 450
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 451
					if not line:match("[%.:]$") then -- 452
						local checkSet -- 453
						do -- 453
							local _tbl_0 = { } -- 453
							for _index_0 = 1, #suggestions do -- 453
								local _des_0 = suggestions[_index_0] -- 453
								local name = _des_0[1] -- 453
								_tbl_0[name] = true -- 453
							end -- 453
							checkSet = _tbl_0 -- 453
						end -- 453
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 454
						for _index_0 = 1, #_list_0 do -- 454
							local item = _list_0[_index_0] -- 454
							if not checkSet[item[1]] then -- 455
								suggestions[#suggestions + 1] = item -- 455
							end -- 455
						end -- 455
						for _index_0 = 1, #luaKeywords do -- 456
							local word = luaKeywords[_index_0] -- 456
							suggestions[#suggestions + 1] = { -- 457
								word, -- 457
								"keyword", -- 457
								"keyword" -- 457
							} -- 457
						end -- 457
						if lang == "tl" then -- 458
							for _index_0 = 1, #tealKeywords do -- 459
								local word = tealKeywords[_index_0] -- 459
								suggestions[#suggestions + 1] = { -- 460
									word, -- 460
									"keyword", -- 460
									"keyword" -- 460
								} -- 460
							end -- 460
						end -- 458
					end -- 452
					if #suggestions > 0 then -- 461
						return { -- 462
							success = true, -- 462
							suggestions = suggestions -- 462
						} -- 462
					end -- 461
				elseif "yue" == lang then -- 463
					local suggestions = { } -- 464
					local gotGlobals = false -- 465
					do -- 466
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file) -- 466
						if luaCodes then -- 466
							gotGlobals = true -- 467
							do -- 468
								local chainOp = line:match("[^%w_]([%.\\])$") -- 468
								if chainOp then -- 468
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 469
									if not withVar then -- 470
										return { -- 470
											success = false -- 470
										} -- 470
									end -- 470
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 471
								elseif line:match("^([%.\\])$") then -- 472
									return { -- 473
										success = false -- 473
									} -- 473
								end -- 468
							end -- 468
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 474
							for _index_0 = 1, #_list_0 do -- 474
								local item = _list_0[_index_0] -- 474
								suggestions[#suggestions + 1] = item -- 474
							end -- 474
							if #suggestions == 0 then -- 475
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 476
								for _index_0 = 1, #_list_1 do -- 476
									local item = _list_1[_index_0] -- 476
									suggestions[#suggestions + 1] = item -- 476
								end -- 476
							end -- 475
						end -- 466
					end -- 466
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 477
						local checkSet -- 478
						do -- 478
							local _tbl_0 = { } -- 478
							for _index_0 = 1, #suggestions do -- 478
								local _des_0 = suggestions[_index_0] -- 478
								local name = _des_0[1] -- 478
								_tbl_0[name] = true -- 478
							end -- 478
							checkSet = _tbl_0 -- 478
						end -- 478
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 479
						for _index_0 = 1, #_list_0 do -- 479
							local item = _list_0[_index_0] -- 479
							if not checkSet[item[1]] then -- 480
								suggestions[#suggestions + 1] = item -- 480
							end -- 480
						end -- 480
						if not gotGlobals then -- 481
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 482
							for _index_0 = 1, #_list_1 do -- 482
								local item = _list_1[_index_0] -- 482
								if not checkSet[item[1]] then -- 483
									suggestions[#suggestions + 1] = item -- 483
								end -- 483
							end -- 483
						end -- 481
						for _index_0 = 1, #yueKeywords do -- 484
							local word = yueKeywords[_index_0] -- 484
							if not checkSet[word] then -- 485
								suggestions[#suggestions + 1] = { -- 486
									word, -- 486
									"keyword", -- 486
									"keyword" -- 486
								} -- 486
							end -- 485
						end -- 486
					end -- 477
					if #suggestions > 0 then -- 487
						return { -- 488
							success = true, -- 488
							suggestions = suggestions -- 488
						} -- 488
					end -- 487
				elseif "xml" == lang then -- 489
					local items = xml.complete(content) -- 490
					if #items > 0 then -- 491
						local suggestions -- 492
						do -- 492
							local _accum_0 = { } -- 492
							local _len_0 = 1 -- 492
							for _index_0 = 1, #items do -- 492
								local _des_0 = items[_index_0] -- 492
								local label, insertText = _des_0[1], _des_0[2] -- 492
								_accum_0[_len_0] = { -- 493
									label, -- 493
									insertText, -- 493
									"field" -- 493
								} -- 493
								_len_0 = _len_0 + 1 -- 493
							end -- 493
							suggestions = _accum_0 -- 492
						end -- 493
						return { -- 494
							success = true, -- 494
							suggestions = suggestions -- 494
						} -- 494
					end -- 491
				end -- 494
			end -- 387
		end -- 494
	end -- 494
	return { -- 386
		success = false -- 386
	} -- 494
end) -- 386
HttpServer:upload("/upload", function(req, filename) -- 498
	do -- 499
		local _type_0 = type(req) -- 499
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 499
		if _tab_0 then -- 499
			local path -- 499
			do -- 499
				local _obj_0 = req.params -- 499
				local _type_1 = type(_obj_0) -- 499
				if "table" == _type_1 or "userdata" == _type_1 then -- 499
					path = _obj_0.path -- 499
				end -- 505
			end -- 505
			if path ~= nil then -- 499
				local uploadPath = Path(Content.writablePath, ".upload") -- 500
				if not Content:exist(uploadPath) then -- 501
					Content:mkdir(uploadPath) -- 502
				end -- 501
				local targetPath = Path(uploadPath, filename) -- 503
				Content:mkdir(Path:getPath(targetPath)) -- 504
				return targetPath -- 505
			end -- 499
		end -- 505
	end -- 505
	return nil -- 505
end, function(req, file) -- 506
	do -- 507
		local _type_0 = type(req) -- 507
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 507
		if _tab_0 then -- 507
			local path -- 507
			do -- 507
				local _obj_0 = req.params -- 507
				local _type_1 = type(_obj_0) -- 507
				if "table" == _type_1 or "userdata" == _type_1 then -- 507
					path = _obj_0.path -- 507
				end -- 514
			end -- 514
			if path ~= nil then -- 507
				path = Path(Content.writablePath, path) -- 508
				if Content:exist(path) then -- 509
					local uploadPath = Path(Content.writablePath, ".upload") -- 510
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 511
					Content:mkdir(Path:getPath(targetPath)) -- 512
					if Content:move(file, targetPath) then -- 513
						return true -- 514
					end -- 513
				end -- 509
			end -- 507
		end -- 514
	end -- 514
	return false -- 514
end) -- 496
HttpServer:post("/list", function(req) -- 517
	do -- 518
		local _type_0 = type(req) -- 518
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 518
		if _tab_0 then -- 518
			local path -- 518
			do -- 518
				local _obj_0 = req.body -- 518
				local _type_1 = type(_obj_0) -- 518
				if "table" == _type_1 or "userdata" == _type_1 then -- 518
					path = _obj_0.path -- 518
				end -- 540
			end -- 540
			if path ~= nil then -- 518
				if Content:exist(path) then -- 519
					local files = { } -- 520
					local visitAssets -- 521
					visitAssets = function(path, folder) -- 521
						local dirs = Content:getDirs(path) -- 522
						for _index_0 = 1, #dirs do -- 523
							local dir = dirs[_index_0] -- 523
							if dir:match("^%.") then -- 524
								goto _continue_0 -- 524
							end -- 524
							local current -- 525
							if folder == "" then -- 525
								current = dir -- 526
							else -- 528
								current = Path(folder, dir) -- 528
							end -- 525
							files[#files + 1] = current -- 529
							visitAssets(Path(path, dir), current) -- 530
							::_continue_0:: -- 524
						end -- 530
						local fs = Content:getFiles(path) -- 531
						for _index_0 = 1, #fs do -- 532
							local f = fs[_index_0] -- 532
							if f:match("^%.") then -- 533
								goto _continue_1 -- 533
							end -- 533
							if folder == "" then -- 534
								files[#files + 1] = f -- 535
							else -- 537
								files[#files + 1] = Path(folder, f) -- 537
							end -- 534
							::_continue_1:: -- 533
						end -- 537
					end -- 521
					visitAssets(path, "") -- 538
					if #files == 0 then -- 539
						files = nil -- 539
					end -- 539
					return { -- 540
						success = true, -- 540
						files = files -- 540
					} -- 540
				end -- 519
			end -- 518
		end -- 540
	end -- 540
	return { -- 517
		success = false -- 517
	} -- 540
end) -- 517
HttpServer:post("/info", function() -- 542
	local Entry = require("Script.Dev.Entry") -- 543
	local webProfiler, drawerWidth -- 544
	do -- 544
		local _obj_0 = Entry.getConfig() -- 544
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 544
	end -- 544
	local engineDev = Entry.getEngineDev() -- 545
	return { -- 547
		platform = App.platform, -- 547
		locale = App.locale, -- 548
		version = App.version, -- 549
		engineDev = engineDev, -- 550
		webProfiler = webProfiler, -- 551
		drawerWidth = drawerWidth -- 552
	} -- 552
end) -- 542
HttpServer:post("/new", function(req) -- 554
	do -- 555
		local _type_0 = type(req) -- 555
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 555
		if _tab_0 then -- 555
			local path -- 555
			do -- 555
				local _obj_0 = req.body -- 555
				local _type_1 = type(_obj_0) -- 555
				if "table" == _type_1 or "userdata" == _type_1 then -- 555
					path = _obj_0.path -- 555
				end -- 574
			end -- 574
			local content -- 555
			do -- 555
				local _obj_0 = req.body -- 555
				local _type_1 = type(_obj_0) -- 555
				if "table" == _type_1 or "userdata" == _type_1 then -- 555
					content = _obj_0.content -- 555
				end -- 574
			end -- 574
			local folder -- 555
			do -- 555
				local _obj_0 = req.body -- 555
				local _type_1 = type(_obj_0) -- 555
				if "table" == _type_1 or "userdata" == _type_1 then -- 555
					folder = _obj_0.folder -- 555
				end -- 574
			end -- 574
			if path ~= nil and content ~= nil and folder ~= nil then -- 555
				if not Content:exist(path) then -- 556
					local parent = Path:getPath(path) -- 557
					local files = Content:getFiles(parent) -- 558
					if folder then -- 559
						local name = Path:getFilename(path):lower() -- 560
						for _index_0 = 1, #files do -- 561
							local file = files[_index_0] -- 561
							if name == Path:getFilename(file):lower() then -- 562
								return { -- 563
									success = false -- 563
								} -- 563
							end -- 562
						end -- 563
						if Content:mkdir(path) then -- 564
							return { -- 565
								success = true -- 565
							} -- 565
						end -- 564
					else -- 567
						local name = Path:getName(path):lower() -- 567
						for _index_0 = 1, #files do -- 568
							local file = files[_index_0] -- 568
							if name == Path:getName(file):lower() then -- 569
								if ("d" == Path:getExt(name)) and (Path:getExt(file) ~= Path:getExt(path)) then -- 570
									goto _continue_0 -- 571
								end -- 570
								return { -- 572
									success = false -- 572
								} -- 572
							end -- 569
							::_continue_0:: -- 569
						end -- 572
						if Content:save(path, content) then -- 573
							return { -- 574
								success = true -- 574
							} -- 574
						end -- 573
					end -- 559
				end -- 556
			end -- 555
		end -- 574
	end -- 574
	return { -- 554
		success = false -- 554
	} -- 574
end) -- 554
HttpServer:post("/delete", function(req) -- 576
	do -- 577
		local _type_0 = type(req) -- 577
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 577
		if _tab_0 then -- 577
			local path -- 577
			do -- 577
				local _obj_0 = req.body -- 577
				local _type_1 = type(_obj_0) -- 577
				if "table" == _type_1 or "userdata" == _type_1 then -- 577
					path = _obj_0.path -- 577
				end -- 590
			end -- 590
			if path ~= nil then -- 577
				if Content:exist(path) then -- 578
					local parent = Path:getPath(path) -- 579
					local files = Content:getFiles(parent) -- 580
					local name = Path:getName(path):lower() -- 581
					local ext = Path:getExt(path) -- 582
					for _index_0 = 1, #files do -- 583
						local file = files[_index_0] -- 583
						if name == Path:getName(file):lower() then -- 584
							local _exp_0 = Path:getExt(file) -- 585
							if "tl" == _exp_0 then -- 585
								if ("vs" == ext) then -- 585
									Content:remove(Path(parent, file)) -- 586
								end -- 585
							elseif "lua" == _exp_0 then -- 587
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 587
									Content:remove(Path(parent, file)) -- 588
								end -- 587
							end -- 588
						end -- 584
					end -- 588
					if Content:remove(path) then -- 589
						return { -- 590
							success = true -- 590
						} -- 590
					end -- 589
				end -- 578
			end -- 577
		end -- 590
	end -- 590
	return { -- 576
		success = false -- 576
	} -- 590
end) -- 576
HttpServer:post("/rename", function(req) -- 592
	do -- 593
		local _type_0 = type(req) -- 593
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 593
		if _tab_0 then -- 593
			local old -- 593
			do -- 593
				local _obj_0 = req.body -- 593
				local _type_1 = type(_obj_0) -- 593
				if "table" == _type_1 or "userdata" == _type_1 then -- 593
					old = _obj_0.old -- 593
				end -- 623
			end -- 623
			local new -- 593
			do -- 593
				local _obj_0 = req.body -- 593
				local _type_1 = type(_obj_0) -- 593
				if "table" == _type_1 or "userdata" == _type_1 then -- 593
					new = _obj_0.new -- 593
				end -- 623
			end -- 623
			if old ~= nil and new ~= nil then -- 593
				if Content:exist(old) and not Content:exist(new) then -- 594
					local parent = Path:getPath(new) -- 595
					local files = Content:getFiles(parent) -- 596
					if Content:isdir(old) then -- 597
						local name = Path:getFilename(new):lower() -- 598
						for _index_0 = 1, #files do -- 599
							local file = files[_index_0] -- 599
							if name == Path:getFilename(file):lower() then -- 600
								return { -- 601
									success = false -- 601
								} -- 601
							end -- 600
						end -- 601
					else -- 603
						local name = Path:getName(new):lower() -- 603
						for _index_0 = 1, #files do -- 604
							local file = files[_index_0] -- 604
							if name == Path:getName(file):lower() then -- 605
								if ("d" == Path:getExt(name)) and (Path:getExt(file) ~= Path:getExt(new)) then -- 606
									goto _continue_0 -- 607
								end -- 606
								return { -- 608
									success = false -- 608
								} -- 608
							end -- 605
							::_continue_0:: -- 605
						end -- 608
					end -- 597
					if Content:move(old, new) then -- 609
						local newParent = Path:getPath(new) -- 610
						parent = Path:getPath(old) -- 611
						files = Content:getFiles(parent) -- 612
						local newName = Path:getName(new) -- 613
						local oldName = Path:getName(old) -- 614
						local name = oldName:lower() -- 615
						local ext = Path:getExt(old) -- 616
						for _index_0 = 1, #files do -- 617
							local file = files[_index_0] -- 617
							if name == Path:getName(file):lower() then -- 618
								local _exp_0 = Path:getExt(file) -- 619
								if "tl" == _exp_0 then -- 619
									if ("vs" == ext) then -- 619
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 620
									end -- 619
								elseif "lua" == _exp_0 then -- 621
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 621
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 622
									end -- 621
								end -- 622
							end -- 618
						end -- 622
						return { -- 623
							success = true -- 623
						} -- 623
					end -- 609
				end -- 594
			end -- 593
		end -- 623
	end -- 623
	return { -- 592
		success = false -- 592
	} -- 623
end) -- 592
HttpServer:post("/exist", function(req) -- 625
	do -- 626
		local _type_0 = type(req) -- 626
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 626
		if _tab_0 then -- 626
			local file -- 626
			do -- 626
				local _obj_0 = req.body -- 626
				local _type_1 = type(_obj_0) -- 626
				if "table" == _type_1 or "userdata" == _type_1 then -- 626
					file = _obj_0.file -- 626
				end -- 635
			end -- 635
			if file ~= nil then -- 626
				do -- 627
					local projFile = req.body.projFile -- 627
					if projFile then -- 627
						local projDir = getProjectDirFromFile(projFile) -- 628
						if projDir then -- 628
							local scriptDir = Path(projDir, "Script") -- 629
							local searchPaths = Content.searchPaths -- 630
							if Content:exist(scriptDir) then -- 631
								Content:addSearchPath(scriptDir) -- 631
							end -- 631
							if Content:exist(projDir) then -- 632
								Content:addSearchPath(projDir) -- 632
							end -- 632
							local _ <close> = setmetatable({ }, { -- 633
								__close = function() -- 633
									Content.searchPaths = searchPaths -- 633
								end -- 633
							}) -- 633
							return { -- 634
								success = Content:exist(file) -- 634
							} -- 634
						end -- 628
					end -- 627
				end -- 627
				return { -- 635
					success = Content:exist(file) -- 635
				} -- 635
			end -- 626
		end -- 635
	end -- 635
	return { -- 625
		success = false -- 625
	} -- 635
end) -- 625
HttpServer:postSchedule("/read", function(req) -- 637
	do -- 638
		local _type_0 = type(req) -- 638
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 638
		if _tab_0 then -- 638
			local path -- 638
			do -- 638
				local _obj_0 = req.body -- 638
				local _type_1 = type(_obj_0) -- 638
				if "table" == _type_1 or "userdata" == _type_1 then -- 638
					path = _obj_0.path -- 638
				end -- 651
			end -- 651
			if path ~= nil then -- 638
				local readFile -- 639
				readFile = function() -- 639
					if Content:exist(path) then -- 640
						local content = Content:loadAsync(path) -- 641
						if content then -- 641
							return { -- 642
								content = content, -- 642
								success = true -- 642
							} -- 642
						end -- 641
					end -- 640
					return nil -- 642
				end -- 639
				do -- 643
					local projFile = req.body.projFile -- 643
					if projFile then -- 643
						local projDir = getProjectDirFromFile(projFile) -- 644
						if projDir then -- 644
							local scriptDir = Path(projDir, "Script") -- 645
							local searchPaths = Content.searchPaths -- 646
							if Content:exist(scriptDir) then -- 647
								Content:addSearchPath(scriptDir) -- 647
							end -- 647
							if Content:exist(projDir) then -- 648
								Content:addSearchPath(projDir) -- 648
							end -- 648
							local _ <close> = setmetatable({ }, { -- 649
								__close = function() -- 649
									Content.searchPaths = searchPaths -- 649
								end -- 649
							}) -- 649
							local result = readFile() -- 650
							if result then -- 650
								return result -- 650
							end -- 650
						end -- 644
					end -- 643
				end -- 643
				local result = readFile() -- 651
				if result then -- 651
					return result -- 651
				end -- 651
			end -- 638
		end -- 651
	end -- 651
	return { -- 637
		success = false -- 637
	} -- 651
end) -- 637
HttpServer:post("/read-sync", function(req) -- 653
	do -- 654
		local _type_0 = type(req) -- 654
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 654
		if _tab_0 then -- 654
			local path -- 654
			do -- 654
				local _obj_0 = req.body -- 654
				local _type_1 = type(_obj_0) -- 654
				if "table" == _type_1 or "userdata" == _type_1 then -- 654
					path = _obj_0.path -- 654
				end -- 669
			end -- 669
			local exts -- 654
			do -- 654
				local _obj_0 = req.body -- 654
				local _type_1 = type(_obj_0) -- 654
				if "table" == _type_1 or "userdata" == _type_1 then -- 654
					exts = _obj_0.exts -- 654
				end -- 669
			end -- 669
			if path ~= nil and exts ~= nil then -- 654
				local readFile -- 655
				readFile = function() -- 655
					for _index_0 = 1, #exts do -- 656
						local ext = exts[_index_0] -- 656
						local targetPath = path .. ext -- 657
						if Content:exist(targetPath) then -- 658
							local content = Content:load(targetPath) -- 659
							if content then -- 659
								return { -- 660
									content = content, -- 660
									success = true, -- 660
									fullPath = Content:getFullPath(targetPath) -- 660
								} -- 660
							end -- 659
						end -- 658
					end -- 660
					return nil -- 660
				end -- 655
				do -- 661
					local projFile = req.body.projFile -- 661
					if projFile then -- 661
						local projDir = getProjectDirFromFile(projFile) -- 662
						if projDir then -- 662
							local scriptDir = Path(projDir, "Script") -- 663
							local searchPaths = Content.searchPaths -- 664
							if Content:exist(scriptDir) then -- 665
								Content:addSearchPath(scriptDir) -- 665
							end -- 665
							if Content:exist(projDir) then -- 666
								Content:addSearchPath(projDir) -- 666
							end -- 666
							local _ <close> = setmetatable({ }, { -- 667
								__close = function() -- 667
									Content.searchPaths = searchPaths -- 667
								end -- 667
							}) -- 667
							local result = readFile() -- 668
							if result then -- 668
								return result -- 668
							end -- 668
						end -- 662
					end -- 661
				end -- 661
				local result = readFile() -- 669
				if result then -- 669
					return result -- 669
				end -- 669
			end -- 654
		end -- 669
	end -- 669
	return { -- 653
		success = false -- 653
	} -- 669
end) -- 653
local compileFileAsync -- 671
compileFileAsync = function(inputFile, sourceCodes) -- 671
	local file = inputFile -- 672
	local searchPath -- 673
	do -- 673
		local dir = getProjectDirFromFile(inputFile) -- 673
		if dir then -- 673
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 674
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 675
		else -- 677
			file = Path:getRelative(inputFile, Path(Content.writablePath)) -- 677
			if file:sub(1, 2) == ".." then -- 678
				file = Path:getRelative(inputFile, Path(Content.assetPath)) -- 679
			end -- 678
			searchPath = "" -- 680
		end -- 673
	end -- 673
	local outputFile = Path:replaceExt(inputFile, "lua") -- 681
	local yueext = yue.options.extension -- 682
	local resultCodes = nil -- 683
	do -- 684
		local _exp_0 = Path:getExt(inputFile) -- 684
		if yueext == _exp_0 then -- 684
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 685
				if not codes then -- 686
					return -- 686
				end -- 686
				local success, result = LintYueGlobals(codes, globals) -- 687
				if not success then -- 688
					return -- 688
				end -- 688
				if codes == "" then -- 689
					resultCodes = "" -- 690
					return nil -- 691
				end -- 689
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 692
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 693
				codes = codes:gsub("^\n*", "") -- 694
				if not (result == "") then -- 695
					result = result .. "\n" -- 695
				end -- 695
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 696
				return resultCodes -- 697
			end, function(success) -- 685
				if not success then -- 698
					Content:remove(outputFile) -- 699
					if resultCodes == nil then -- 700
						resultCodes = false -- 701
					end -- 700
				end -- 698
			end) -- 685
		elseif "tl" == _exp_0 then -- 702
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 703
			if codes then -- 703
				resultCodes = codes -- 704
				Content:saveAsync(outputFile, codes) -- 705
			else -- 707
				Content:remove(outputFile) -- 707
				resultCodes = false -- 708
			end -- 703
		elseif "xml" == _exp_0 then -- 709
			local codes = xml.tolua(sourceCodes) -- 710
			if codes then -- 710
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 711
				Content:saveAsync(outputFile, resultCodes) -- 712
			else -- 714
				Content:remove(outputFile) -- 714
				resultCodes = false -- 715
			end -- 710
		end -- 715
	end -- 715
	wait(function() -- 716
		return resultCodes ~= nil -- 716
	end) -- 716
	if resultCodes then -- 717
		return resultCodes -- 717
	end -- 717
	return nil -- 717
end -- 671
HttpServer:postSchedule("/write", function(req) -- 719
	do -- 720
		local _type_0 = type(req) -- 720
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 720
		if _tab_0 then -- 720
			local path -- 720
			do -- 720
				local _obj_0 = req.body -- 720
				local _type_1 = type(_obj_0) -- 720
				if "table" == _type_1 or "userdata" == _type_1 then -- 720
					path = _obj_0.path -- 720
				end -- 726
			end -- 726
			local content -- 720
			do -- 720
				local _obj_0 = req.body -- 720
				local _type_1 = type(_obj_0) -- 720
				if "table" == _type_1 or "userdata" == _type_1 then -- 720
					content = _obj_0.content -- 720
				end -- 726
			end -- 726
			if path ~= nil and content ~= nil then -- 720
				if Content:saveAsync(path, content) then -- 721
					do -- 722
						local _exp_0 = Path:getExt(path) -- 722
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 722
							if '' == Path:getExt(Path:getName(path)) then -- 723
								local resultCodes = compileFileAsync(path, content) -- 724
								return { -- 725
									success = true, -- 725
									resultCodes = resultCodes -- 725
								} -- 725
							end -- 723
						end -- 725
					end -- 725
					return { -- 726
						success = true -- 726
					} -- 726
				end -- 721
			end -- 720
		end -- 726
	end -- 726
	return { -- 719
		success = false -- 719
	} -- 726
end) -- 719
HttpServer:postSchedule("/build", function(req) -- 728
	do -- 729
		local _type_0 = type(req) -- 729
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 729
		if _tab_0 then -- 729
			local path -- 729
			do -- 729
				local _obj_0 = req.body -- 729
				local _type_1 = type(_obj_0) -- 729
				if "table" == _type_1 or "userdata" == _type_1 then -- 729
					path = _obj_0.path -- 729
				end -- 734
			end -- 734
			if path ~= nil then -- 729
				local _exp_0 = Path:getExt(path) -- 730
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 730
					if '' == Path:getExt(Path:getName(path)) then -- 731
						local content = Content:loadAsync(path) -- 732
						if content then -- 732
							local resultCodes = compileFileAsync(path, content) -- 733
							if resultCodes then -- 733
								return { -- 734
									success = true, -- 734
									resultCodes = resultCodes -- 734
								} -- 734
							end -- 733
						end -- 732
					end -- 731
				end -- 734
			end -- 729
		end -- 734
	end -- 734
	return { -- 728
		success = false -- 728
	} -- 734
end) -- 728
local extentionLevels = { -- 737
	vs = 2, -- 737
	ts = 1, -- 738
	tsx = 1, -- 739
	tl = 1, -- 740
	yue = 1, -- 741
	xml = 1, -- 742
	lua = 0 -- 743
} -- 736
local _anon_func_4 = function(Content, Path, visitAssets, zh) -- 812
	local _with_0 = visitAssets(Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")) -- 811
	_with_0.title = zh and "说明文档" or "Readme" -- 812
	return _with_0 -- 811
end -- 811
local _anon_func_5 = function(Content, Path, visitAssets, zh) -- 814
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")) -- 813
	_with_0.title = zh and "接口文档" or "API Doc" -- 814
	return _with_0 -- 813
end -- 813
local _anon_func_6 = function(Content, Path, visitAssets, zh) -- 816
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Tools")) -- 815
	_with_0.title = zh and "开发工具" or "Tools" -- 816
	return _with_0 -- 815
end -- 815
local _anon_func_7 = function(Content, Path, visitAssets, zh) -- 818
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Example")) -- 817
	_with_0.title = zh and "代码示例" or "Example" -- 818
	return _with_0 -- 817
end -- 817
local _anon_func_8 = function(Content, Path, visitAssets, zh) -- 820
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Game")) -- 819
	_with_0.title = zh and "游戏演示" or "Demo Game" -- 820
	return _with_0 -- 819
end -- 819
local _anon_func_9 = function(Content, Path, visitAssets, zh) -- 822
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Test")) -- 821
	_with_0.title = zh and "功能测试" or "Test" -- 822
	return _with_0 -- 821
end -- 821
local _anon_func_10 = function(Content, Path, engineDev, visitAssets, zh) -- 834
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib")) -- 826
	if engineDev then -- 827
		local _list_0 = _with_0.children -- 828
		for _index_0 = 1, #_list_0 do -- 828
			local child = _list_0[_index_0] -- 828
			if not (child.title == "Dora") then -- 829
				goto _continue_0 -- 829
			end -- 829
			local title = zh and "zh-Hans" or "en" -- 830
			do -- 831
				local _accum_0 = { } -- 831
				local _len_0 = 1 -- 831
				local _list_1 = child.children -- 831
				for _index_1 = 1, #_list_1 do -- 831
					local c = _list_1[_index_1] -- 831
					if c.title ~= title then -- 831
						_accum_0[_len_0] = c -- 831
						_len_0 = _len_0 + 1 -- 831
					end -- 831
				end -- 831
				child.children = _accum_0 -- 831
			end -- 831
			break -- 832
			::_continue_0:: -- 829
		end -- 832
	else -- 834
		local _accum_0 = { } -- 834
		local _len_0 = 1 -- 834
		local _list_0 = _with_0.children -- 834
		for _index_0 = 1, #_list_0 do -- 834
			local child = _list_0[_index_0] -- 834
			if child.title ~= "Dora" then -- 834
				_accum_0[_len_0] = child -- 834
				_len_0 = _len_0 + 1 -- 834
			end -- 834
		end -- 834
		_with_0.children = _accum_0 -- 834
	end -- 827
	return _with_0 -- 826
end -- 826
local _anon_func_11 = function(Content, Path, engineDev, visitAssets) -- 835
	if engineDev then -- 835
		local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Dev")) -- 836
		local _obj_0 = _with_0.children -- 837
		_obj_0[#_obj_0 + 1] = { -- 838
			key = Path(Content.assetPath, "Script", "init.yue"), -- 838
			dir = false, -- 839
			title = "init.yue" -- 840
		} -- 837
		return _with_0 -- 836
	end -- 835
end -- 835
local _anon_func_3 = function(Content, Path, engineDev, visitAssets, zh) -- 843
	local _tab_0 = { -- 806
		{ -- 807
			key = Path(Content.assetPath), -- 807
			dir = true, -- 808
			title = zh and "内置资源" or "Built-in", -- 809
			children = { -- 811
				_anon_func_4(Content, Path, visitAssets, zh), -- 811
				_anon_func_5(Content, Path, visitAssets, zh), -- 813
				_anon_func_6(Content, Path, visitAssets, zh), -- 815
				_anon_func_7(Content, Path, visitAssets, zh), -- 817
				_anon_func_8(Content, Path, visitAssets, zh), -- 819
				_anon_func_9(Content, Path, visitAssets, zh), -- 821
				visitAssets(Path(Content.assetPath, "Image")), -- 823
				visitAssets(Path(Content.assetPath, "Spine")), -- 824
				visitAssets(Path(Content.assetPath, "Font")), -- 825
				_anon_func_10(Content, Path, engineDev, visitAssets, zh), -- 826
				_anon_func_11(Content, Path, engineDev, visitAssets) -- 835
			} -- 810
		} -- 806
	} -- 844
	local _obj_0 = visitAssets(Content.writablePath, true) -- 844
	local _idx_0 = #_tab_0 + 1 -- 844
	for _index_0 = 1, #_obj_0 do -- 844
		local _value_0 = _obj_0[_index_0] -- 844
		_tab_0[_idx_0] = _value_0 -- 844
		_idx_0 = _idx_0 + 1 -- 844
	end -- 844
	return _tab_0 -- 843
end -- 806
HttpServer:post("/assets", function() -- 745
	local Entry = require("Script.Dev.Entry") -- 746
	local engineDev = Entry.getEngineDev() -- 747
	local visitAssets -- 748
	visitAssets = function(path, root) -- 748
		local children = nil -- 749
		local dirs = Content:getDirs(path) -- 750
		for _index_0 = 1, #dirs do -- 751
			local dir = dirs[_index_0] -- 751
			if root then -- 752
				if ".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir then -- 752
					goto _continue_0 -- 753
				end -- 753
			elseif dir == ".git" then -- 754
				goto _continue_0 -- 755
			end -- 752
			if not children then -- 756
				children = { } -- 756
			end -- 756
			children[#children + 1] = visitAssets(Path(path, dir)) -- 757
			::_continue_0:: -- 752
		end -- 757
		local files = Content:getFiles(path) -- 758
		local names = { } -- 759
		for _index_0 = 1, #files do -- 760
			local file = files[_index_0] -- 760
			if file:match("^%.") then -- 761
				goto _continue_1 -- 761
			end -- 761
			local name = Path:getName(file) -- 762
			local ext = names[name] -- 763
			if ext then -- 763
				local lv1 -- 764
				do -- 764
					local _exp_0 = extentionLevels[ext] -- 764
					if _exp_0 ~= nil then -- 764
						lv1 = _exp_0 -- 764
					else -- 764
						lv1 = -1 -- 764
					end -- 764
				end -- 764
				ext = Path:getExt(file) -- 765
				local lv2 -- 766
				do -- 766
					local _exp_0 = extentionLevels[ext] -- 766
					if _exp_0 ~= nil then -- 766
						lv2 = _exp_0 -- 766
					else -- 766
						lv2 = -1 -- 766
					end -- 766
				end -- 766
				if lv2 > lv1 then -- 767
					names[name] = ext -- 768
				elseif lv2 == lv1 then -- 769
					names[name .. '.' .. ext] = "" -- 770
				end -- 767
			else -- 772
				ext = Path:getExt(file) -- 772
				if not extentionLevels[ext] then -- 773
					names[file] = "" -- 774
				else -- 776
					names[name] = ext -- 776
				end -- 773
			end -- 763
			::_continue_1:: -- 761
		end -- 776
		do -- 777
			local _accum_0 = { } -- 777
			local _len_0 = 1 -- 777
			for name, ext in pairs(names) do -- 777
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 777
				_len_0 = _len_0 + 1 -- 777
			end -- 777
			files = _accum_0 -- 777
		end -- 777
		for _index_0 = 1, #files do -- 778
			local file = files[_index_0] -- 778
			if not children then -- 779
				children = { } -- 779
			end -- 779
			children[#children + 1] = { -- 781
				key = Path(path, file), -- 781
				dir = false, -- 782
				title = file -- 783
			} -- 780
		end -- 784
		if children then -- 785
			table.sort(children, function(a, b) -- 786
				if a.dir == b.dir then -- 787
					return a.title < b.title -- 788
				else -- 790
					return a.dir -- 790
				end -- 787
			end) -- 786
		end -- 785
		if root then -- 791
			return children -- 792
		else -- 794
			return { -- 795
				key = path, -- 795
				dir = true, -- 796
				title = Path:getFilename(path), -- 797
				children = children -- 798
			} -- 799
		end -- 791
	end -- 748
	local zh = (App.locale:match("^zh") ~= nil) -- 800
	return { -- 802
		key = Content.writablePath, -- 802
		dir = true, -- 803
		title = "Assets", -- 804
		children = _anon_func_3(Content, Path, engineDev, visitAssets, zh) -- 805
	} -- 846
end) -- 745
HttpServer:postSchedule("/run", function(req) -- 848
	do -- 849
		local _type_0 = type(req) -- 849
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 849
		if _tab_0 then -- 849
			local file -- 849
			do -- 849
				local _obj_0 = req.body -- 849
				local _type_1 = type(_obj_0) -- 849
				if "table" == _type_1 or "userdata" == _type_1 then -- 849
					file = _obj_0.file -- 849
				end -- 864
			end -- 864
			local asProj -- 849
			do -- 849
				local _obj_0 = req.body -- 849
				local _type_1 = type(_obj_0) -- 849
				if "table" == _type_1 or "userdata" == _type_1 then -- 849
					asProj = _obj_0.asProj -- 849
				end -- 864
			end -- 864
			if file ~= nil and asProj ~= nil then -- 849
				if not Content:isAbsolutePath(file) then -- 850
					local devFile = Path(Content.writablePath, file) -- 851
					if Content:exist(devFile) then -- 852
						file = devFile -- 852
					end -- 852
				end -- 850
				local Entry = require("Script.Dev.Entry") -- 853
				if asProj then -- 854
					local proj = getProjectDirFromFile(file) -- 855
					if proj then -- 855
						Entry.allClear() -- 856
						local target = Path(proj, "init") -- 857
						local success, err = Entry.enterEntryAsync({ -- 858
							"Project", -- 858
							target -- 858
						}) -- 858
						target = Path:getName(Path:getPath(target)) -- 859
						return { -- 860
							success = success, -- 860
							target = target, -- 860
							err = err -- 860
						} -- 860
					end -- 855
				end -- 854
				Entry.allClear() -- 861
				file = Path:replaceExt(file, "") -- 862
				local success, err = Entry.enterEntryAsync({ -- 863
					Path:getName(file), -- 863
					file -- 863
				}) -- 863
				return { -- 864
					success = success, -- 864
					err = err -- 864
				} -- 864
			end -- 849
		end -- 864
	end -- 864
	return { -- 848
		success = false -- 848
	} -- 864
end) -- 848
HttpServer:postSchedule("/stop", function() -- 866
	local Entry = require("Script.Dev.Entry") -- 867
	return { -- 868
		success = Entry.stop() -- 868
	} -- 868
end) -- 866
local minifyAsync -- 870
minifyAsync = function(sourcePath, minifyPath) -- 870
	if not Content:exist(sourcePath) then -- 871
		return -- 871
	end -- 871
	local Entry = require("Script.Dev.Entry") -- 872
	local errors = { } -- 873
	local files = Entry.getAllFiles(sourcePath, { -- 874
		"lua" -- 874
	}, true) -- 874
	do -- 875
		local _accum_0 = { } -- 875
		local _len_0 = 1 -- 875
		for _index_0 = 1, #files do -- 875
			local file = files[_index_0] -- 875
			if file:sub(1, 1) ~= '.' then -- 875
				_accum_0[_len_0] = file -- 875
				_len_0 = _len_0 + 1 -- 875
			end -- 875
		end -- 875
		files = _accum_0 -- 875
	end -- 875
	local paths -- 876
	do -- 876
		local _tbl_0 = { } -- 876
		for _index_0 = 1, #files do -- 876
			local file = files[_index_0] -- 876
			_tbl_0[Path:getPath(file)] = true -- 876
		end -- 876
		paths = _tbl_0 -- 876
	end -- 876
	for path in pairs(paths) do -- 877
		Content:mkdir(Path(minifyPath, path)) -- 877
	end -- 877
	local _ <close> = setmetatable({ }, { -- 878
		__close = function() -- 878
			package.loaded["luaminify.FormatMini"] = nil -- 879
			package.loaded["luaminify.ParseLua"] = nil -- 880
			package.loaded["luaminify.Scope"] = nil -- 881
			package.loaded["luaminify.Util"] = nil -- 882
		end -- 878
	}) -- 878
	local FormatMini -- 883
	do -- 883
		local _obj_0 = require("luaminify") -- 883
		FormatMini = _obj_0.FormatMini -- 883
	end -- 883
	local fileCount = #files -- 884
	local count = 0 -- 885
	for _index_0 = 1, #files do -- 886
		local file = files[_index_0] -- 886
		thread(function() -- 887
			local _ <close> = setmetatable({ }, { -- 888
				__close = function() -- 888
					count = count + 1 -- 888
				end -- 888
			}) -- 888
			local input = Path(sourcePath, file) -- 889
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 890
			if Content:exist(input) then -- 891
				local sourceCodes = Content:loadAsync(input) -- 892
				local res, err = FormatMini(sourceCodes) -- 893
				if res then -- 894
					Content:saveAsync(output, res) -- 895
					return print("Minify " .. tostring(file)) -- 896
				else -- 898
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 898
				end -- 894
			else -- 900
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 900
			end -- 891
		end) -- 887
		sleep() -- 901
	end -- 901
	wait(function() -- 902
		return count == fileCount -- 902
	end) -- 902
	if #errors > 0 then -- 903
		print(table.concat(errors, '\n')) -- 904
	end -- 903
	print("Obfuscation done.") -- 905
	return files -- 906
end -- 870
local zipping = false -- 908
HttpServer:postSchedule("/zip", function(req) -- 910
	do -- 911
		local _type_0 = type(req) -- 911
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 911
		if _tab_0 then -- 911
			local path -- 911
			do -- 911
				local _obj_0 = req.body -- 911
				local _type_1 = type(_obj_0) -- 911
				if "table" == _type_1 or "userdata" == _type_1 then -- 911
					path = _obj_0.path -- 911
				end -- 940
			end -- 940
			local zipFile -- 911
			do -- 911
				local _obj_0 = req.body -- 911
				local _type_1 = type(_obj_0) -- 911
				if "table" == _type_1 or "userdata" == _type_1 then -- 911
					zipFile = _obj_0.zipFile -- 911
				end -- 940
			end -- 940
			local obfuscated -- 911
			do -- 911
				local _obj_0 = req.body -- 911
				local _type_1 = type(_obj_0) -- 911
				if "table" == _type_1 or "userdata" == _type_1 then -- 911
					obfuscated = _obj_0.obfuscated -- 911
				end -- 940
			end -- 940
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 911
				if zipping then -- 912
					goto failed -- 912
				end -- 912
				zipping = true -- 913
				local _ <close> = setmetatable({ }, { -- 914
					__close = function() -- 914
						zipping = false -- 914
					end -- 914
				}) -- 914
				if not Content:exist(path) then -- 915
					goto failed -- 915
				end -- 915
				Content:mkdir(Path:getPath(zipFile)) -- 916
				if obfuscated then -- 917
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 918
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 919
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 920
					Content:remove(scriptPath) -- 921
					Content:remove(obfuscatedPath) -- 922
					Content:remove(tempPath) -- 923
					Content:mkdir(scriptPath) -- 924
					Content:mkdir(obfuscatedPath) -- 925
					Content:mkdir(tempPath) -- 926
					if not Content:copyAsync(path, tempPath) then -- 927
						goto failed -- 927
					end -- 927
					local Entry = require("Script.Dev.Entry") -- 928
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 929
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 930
						"tl", -- 930
						"yue", -- 930
						"lua", -- 930
						"ts", -- 930
						"tsx", -- 930
						"vs", -- 930
						"xml" -- 930
					}, true) -- 930
					for _index_0 = 1, #scriptFiles do -- 931
						local file = scriptFiles[_index_0] -- 931
						Content:remove(Path(tempPath, file)) -- 932
					end -- 932
					for _index_0 = 1, #luaFiles do -- 933
						local file = luaFiles[_index_0] -- 933
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 934
					end -- 934
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 935
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 936
					end) then -- 935
						goto failed -- 935
					end -- 935
					return { -- 937
						success = true -- 937
					} -- 937
				else -- 939
					return { -- 939
						success = Content:zipAsync(path, zipFile, function(file) -- 939
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 940
						end) -- 939
					} -- 940
				end -- 917
			end -- 911
		end -- 940
	end -- 940
	::failed:: -- 941
	return { -- 910
		success = false -- 910
	} -- 941
end) -- 910
HttpServer:postSchedule("/unzip", function(req) -- 943
	do -- 944
		local _type_0 = type(req) -- 944
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 944
		if _tab_0 then -- 944
			local zipFile -- 944
			do -- 944
				local _obj_0 = req.body -- 944
				local _type_1 = type(_obj_0) -- 944
				if "table" == _type_1 or "userdata" == _type_1 then -- 944
					zipFile = _obj_0.zipFile -- 944
				end -- 946
			end -- 946
			local path -- 944
			do -- 944
				local _obj_0 = req.body -- 944
				local _type_1 = type(_obj_0) -- 944
				if "table" == _type_1 or "userdata" == _type_1 then -- 944
					path = _obj_0.path -- 944
				end -- 946
			end -- 946
			if zipFile ~= nil and path ~= nil then -- 944
				return { -- 945
					success = Content:unzipAsync(zipFile, path, function(file) -- 945
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 946
					end) -- 945
				} -- 946
			end -- 944
		end -- 946
	end -- 946
	return { -- 943
		success = false -- 943
	} -- 946
end) -- 943
HttpServer:post("/editingInfo", function(req) -- 948
	local Entry = require("Script.Dev.Entry") -- 949
	local config = Entry.getConfig() -- 950
	local _type_0 = type(req) -- 951
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 951
	local _match_0 = false -- 951
	if _tab_0 then -- 951
		local editingInfo -- 951
		do -- 951
			local _obj_0 = req.body -- 951
			local _type_1 = type(_obj_0) -- 951
			if "table" == _type_1 or "userdata" == _type_1 then -- 951
				editingInfo = _obj_0.editingInfo -- 951
			end -- 953
		end -- 953
		if editingInfo ~= nil then -- 951
			_match_0 = true -- 951
			config.editingInfo = editingInfo -- 952
			return { -- 953
				success = true -- 953
			} -- 953
		end -- 951
	end -- 951
	if not _match_0 then -- 951
		if not (config.editingInfo ~= nil) then -- 955
			local folder -- 956
			if App.locale:match('^zh') then -- 956
				folder = 'zh-Hans' -- 956
			else -- 956
				folder = 'en' -- 956
			end -- 956
			config.editingInfo = json.dump({ -- 958
				index = 0, -- 958
				files = { -- 960
					{ -- 961
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 961
						title = "welcome.md" -- 962
					} -- 960
				} -- 959
			}) -- 957
		end -- 955
		return { -- 966
			success = true, -- 966
			editingInfo = config.editingInfo -- 966
		} -- 966
	end -- 966
end) -- 948
HttpServer:post("/command", function(req) -- 968
	do -- 969
		local _type_0 = type(req) -- 969
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 969
		if _tab_0 then -- 969
			local code -- 969
			do -- 969
				local _obj_0 = req.body -- 969
				local _type_1 = type(_obj_0) -- 969
				if "table" == _type_1 or "userdata" == _type_1 then -- 969
					code = _obj_0.code -- 969
				end -- 971
			end -- 971
			local log -- 969
			do -- 969
				local _obj_0 = req.body -- 969
				local _type_1 = type(_obj_0) -- 969
				if "table" == _type_1 or "userdata" == _type_1 then -- 969
					log = _obj_0.log -- 969
				end -- 971
			end -- 971
			if code ~= nil and log ~= nil then -- 969
				emit("AppCommand", code, log) -- 970
				return { -- 971
					success = true -- 971
				} -- 971
			end -- 969
		end -- 971
	end -- 971
	return { -- 968
		success = false -- 968
	} -- 971
end) -- 968
HttpServer:post("/saveLog", function() -- 973
	local folder = ".download" -- 974
	local fullLogFile = "dora_full_logs.txt" -- 975
	local fullFolder = Path(Content.writablePath, folder) -- 976
	Content:mkdir(fullFolder) -- 977
	local logPath = Path(fullFolder, fullLogFile) -- 978
	if App:saveLog(logPath) then -- 979
		return { -- 980
			success = true, -- 980
			path = Path(folder, fullLogFile) -- 980
		} -- 980
	end -- 979
	return { -- 973
		success = false -- 973
	} -- 980
end) -- 973
local status = { } -- 982
_module_0 = status -- 983
thread(function() -- 985
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 986
	local doraReady = Path(Content.writablePath, ".www", "dora-ready") -- 987
	if Content:exist(doraWeb) then -- 988
		local needReload -- 989
		if Content:exist(doraReady) then -- 989
			needReload = App.version ~= Content:load(doraReady) -- 990
		else -- 991
			needReload = true -- 991
		end -- 989
		if needReload then -- 992
			Content:remove(Path(Content.writablePath, ".www")) -- 993
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.writablePath, ".www")) -- 994
			Content:save(doraReady, App.version) -- 998
			print("Dora Dora is ready!") -- 999
		end -- 992
	end -- 988
	if HttpServer:start(8866) then -- 1000
		local localIP = HttpServer.localIP -- 1001
		if localIP == "" then -- 1002
			localIP = "localhost" -- 1002
		end -- 1002
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1003
		return HttpServer:startWS(8868) -- 1004
	else -- 1006
		status.url = nil -- 1006
		return print("8866 Port not available!") -- 1007
	end -- 1000
end) -- 985
return _module_0 -- 1007
