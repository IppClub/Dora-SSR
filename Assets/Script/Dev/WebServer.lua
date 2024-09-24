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
local wait = Dora.wait -- 1
local setmetatable = _G.setmetatable -- 1
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
				end -- 637
			end -- 637
			if file ~= nil then -- 626
				do -- 627
					local projFile = req.body.projFile -- 627
					if projFile then -- 627
						do -- 628
							local projDir = getProjectDirFromFile(projFile) -- 628
							if projDir then -- 628
								local scriptDir = Path(projDir, "Script") -- 629
								Content:addSearchPath(scriptDir) -- 630
								Content:addSearchPath(projDir) -- 631
								local result = Content:exist(file) -- 632
								Content:removeSearchPath(projDir) -- 633
								Content:removeSearchPath(scriptDir) -- 634
								return { -- 635
									success = result -- 635
								} -- 635
							end -- 628
						end -- 628
						return { -- 636
							success = false -- 636
						} -- 636
					end -- 627
				end -- 627
				return { -- 637
					success = Content:exist(file) -- 637
				} -- 637
			end -- 626
		end -- 637
	end -- 637
	return { -- 625
		success = false -- 625
	} -- 637
end) -- 625
HttpServer:postSchedule("/read", function(req) -- 639
	do -- 640
		local _type_0 = type(req) -- 640
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 640
		if _tab_0 then -- 640
			local path -- 640
			do -- 640
				local _obj_0 = req.body -- 640
				local _type_1 = type(_obj_0) -- 640
				if "table" == _type_1 or "userdata" == _type_1 then -- 640
					path = _obj_0.path -- 640
				end -- 657
			end -- 657
			if path ~= nil then -- 640
				do -- 641
					local projFile = req.body.projFile -- 641
					if projFile then -- 641
						do -- 642
							local projDir = getProjectDirFromFile(projFile) -- 642
							if projDir then -- 642
								local scriptDir = Path(projDir, "Script") -- 643
								Content:addSearchPath(scriptDir) -- 644
								Content:addSearchPath(projDir) -- 645
								if Content:exist(path) then -- 646
									local content = Content:loadAsync(path) -- 647
									Content:removeSearchPath(projDir) -- 648
									Content:removeSearchPath(scriptDir) -- 649
									if content then -- 650
										return { -- 651
											content = content, -- 651
											success = true -- 651
										} -- 651
									end -- 650
								else -- 653
									Content:removeSearchPath(projDir) -- 653
								end -- 646
							end -- 642
						end -- 642
						return { -- 654
							success = false -- 654
						} -- 654
					end -- 641
				end -- 641
				if Content:exist(path) then -- 655
					local content = Content:loadAsync(path) -- 656
					if content then -- 656
						return { -- 657
							content = content, -- 657
							success = true -- 657
						} -- 657
					end -- 656
				end -- 655
			end -- 640
		end -- 657
	end -- 657
	return { -- 639
		success = false -- 639
	} -- 657
end) -- 639
HttpServer:post("/read-sync", function(req) -- 659
	do -- 660
		local _type_0 = type(req) -- 660
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 660
		if _tab_0 then -- 660
			local path -- 660
			do -- 660
				local _obj_0 = req.body -- 660
				local _type_1 = type(_obj_0) -- 660
				if "table" == _type_1 or "userdata" == _type_1 then -- 660
					path = _obj_0.path -- 660
				end -- 665
			end -- 665
			local exts -- 660
			do -- 660
				local _obj_0 = req.body -- 660
				local _type_1 = type(_obj_0) -- 660
				if "table" == _type_1 or "userdata" == _type_1 then -- 660
					exts = _obj_0.exts -- 660
				end -- 665
			end -- 665
			if path ~= nil and exts ~= nil then -- 660
				for _index_0 = 1, #exts do -- 661
					local ext = exts[_index_0] -- 661
					local targetPath = path .. ext -- 662
					if Content:exist(targetPath) then -- 663
						local content = Content:load(targetPath) -- 664
						if content then -- 664
							return { -- 665
								content = content, -- 665
								success = true, -- 665
								ext = ext -- 665
							} -- 665
						end -- 664
					end -- 663
				end -- 665
			end -- 660
		end -- 665
	end -- 665
	return { -- 659
		success = false -- 659
	} -- 665
end) -- 659
local compileFileAsync -- 667
compileFileAsync = function(inputFile, sourceCodes) -- 667
	local file = inputFile -- 668
	local searchPath -- 669
	do -- 669
		local dir = getProjectDirFromFile(inputFile) -- 669
		if dir then -- 669
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 670
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 671
		else -- 673
			file = Path:getRelative(inputFile, Path(Content.writablePath)) -- 673
			if file:sub(1, 2) == ".." then -- 674
				file = Path:getRelative(inputFile, Path(Content.assetPath)) -- 675
			end -- 674
			searchPath = "" -- 676
		end -- 669
	end -- 669
	local outputFile = Path:replaceExt(inputFile, "lua") -- 677
	local yueext = yue.options.extension -- 678
	local resultCodes = nil -- 679
	do -- 680
		local _exp_0 = Path:getExt(inputFile) -- 680
		if yueext == _exp_0 then -- 680
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 681
				if not codes then -- 682
					return -- 682
				end -- 682
				local success, result = LintYueGlobals(codes, globals) -- 683
				if not success then -- 684
					return -- 684
				end -- 684
				if codes == "" then -- 685
					resultCodes = "" -- 686
					return nil -- 687
				end -- 685
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 688
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 689
				codes = codes:gsub("^\n*", "") -- 690
				if not (result == "") then -- 691
					result = result .. "\n" -- 691
				end -- 691
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 692
				return resultCodes -- 693
			end, function(success) -- 681
				if not success then -- 694
					Content:remove(outputFile) -- 695
					if resultCodes == nil then -- 696
						resultCodes = false -- 697
					end -- 696
				end -- 694
			end) -- 681
		elseif "tl" == _exp_0 then -- 698
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 699
			if codes then -- 699
				resultCodes = codes -- 700
				Content:saveAsync(outputFile, codes) -- 701
			else -- 703
				Content:remove(outputFile) -- 703
				resultCodes = false -- 704
			end -- 699
		elseif "xml" == _exp_0 then -- 705
			local codes = xml.tolua(sourceCodes) -- 706
			if codes then -- 706
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 707
				Content:saveAsync(outputFile, resultCodes) -- 708
			else -- 710
				Content:remove(outputFile) -- 710
				resultCodes = false -- 711
			end -- 706
		end -- 711
	end -- 711
	wait(function() -- 712
		return resultCodes ~= nil -- 712
	end) -- 712
	if resultCodes then -- 713
		return resultCodes -- 713
	end -- 713
	return nil -- 713
end -- 667
HttpServer:postSchedule("/write", function(req) -- 715
	do -- 716
		local _type_0 = type(req) -- 716
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 716
		if _tab_0 then -- 716
			local path -- 716
			do -- 716
				local _obj_0 = req.body -- 716
				local _type_1 = type(_obj_0) -- 716
				if "table" == _type_1 or "userdata" == _type_1 then -- 716
					path = _obj_0.path -- 716
				end -- 722
			end -- 722
			local content -- 716
			do -- 716
				local _obj_0 = req.body -- 716
				local _type_1 = type(_obj_0) -- 716
				if "table" == _type_1 or "userdata" == _type_1 then -- 716
					content = _obj_0.content -- 716
				end -- 722
			end -- 722
			if path ~= nil and content ~= nil then -- 716
				if Content:saveAsync(path, content) then -- 717
					do -- 718
						local _exp_0 = Path:getExt(path) -- 718
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 718
							if '' == Path:getExt(Path:getName(path)) then -- 719
								local resultCodes = compileFileAsync(path, content) -- 720
								return { -- 721
									success = true, -- 721
									resultCodes = resultCodes -- 721
								} -- 721
							end -- 719
						end -- 721
					end -- 721
					return { -- 722
						success = true -- 722
					} -- 722
				end -- 717
			end -- 716
		end -- 722
	end -- 722
	return { -- 715
		success = false -- 715
	} -- 722
end) -- 715
HttpServer:postSchedule("/build", function(req) -- 724
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
				end -- 730
			end -- 730
			if path ~= nil then -- 725
				local _exp_0 = Path:getExt(path) -- 726
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 726
					if '' == Path:getExt(Path:getName(path)) then -- 727
						local content = Content:loadAsync(path) -- 728
						if content then -- 728
							local resultCodes = compileFileAsync(path, content) -- 729
							if resultCodes then -- 729
								return { -- 730
									success = true, -- 730
									resultCodes = resultCodes -- 730
								} -- 730
							end -- 729
						end -- 728
					end -- 727
				end -- 730
			end -- 725
		end -- 730
	end -- 730
	return { -- 724
		success = false -- 724
	} -- 730
end) -- 724
local extentionLevels = { -- 733
	vs = 2, -- 733
	ts = 1, -- 734
	tsx = 1, -- 735
	tl = 1, -- 736
	yue = 1, -- 737
	xml = 1, -- 738
	lua = 0 -- 739
} -- 732
local _anon_func_4 = function(Content, Path, visitAssets, zh) -- 808
	local _with_0 = visitAssets(Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")) -- 807
	_with_0.title = zh and "说明文档" or "Readme" -- 808
	return _with_0 -- 807
end -- 807
local _anon_func_5 = function(Content, Path, visitAssets, zh) -- 810
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")) -- 809
	_with_0.title = zh and "接口文档" or "API Doc" -- 810
	return _with_0 -- 809
end -- 809
local _anon_func_6 = function(Content, Path, visitAssets, zh) -- 812
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Tools")) -- 811
	_with_0.title = zh and "开发工具" or "Tools" -- 812
	return _with_0 -- 811
end -- 811
local _anon_func_7 = function(Content, Path, visitAssets, zh) -- 814
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Example")) -- 813
	_with_0.title = zh and "代码示例" or "Example" -- 814
	return _with_0 -- 813
end -- 813
local _anon_func_8 = function(Content, Path, visitAssets, zh) -- 816
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Game")) -- 815
	_with_0.title = zh and "游戏演示" or "Demo Game" -- 816
	return _with_0 -- 815
end -- 815
local _anon_func_9 = function(Content, Path, visitAssets, zh) -- 818
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Test")) -- 817
	_with_0.title = zh and "功能测试" or "Test" -- 818
	return _with_0 -- 817
end -- 817
local _anon_func_10 = function(Content, Path, engineDev, visitAssets, zh) -- 830
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib")) -- 822
	if engineDev then -- 823
		local _list_0 = _with_0.children -- 824
		for _index_0 = 1, #_list_0 do -- 824
			local child = _list_0[_index_0] -- 824
			if not (child.title == "Dora") then -- 825
				goto _continue_0 -- 825
			end -- 825
			local title = zh and "zh-Hans" or "en" -- 826
			do -- 827
				local _accum_0 = { } -- 827
				local _len_0 = 1 -- 827
				local _list_1 = child.children -- 827
				for _index_1 = 1, #_list_1 do -- 827
					local c = _list_1[_index_1] -- 827
					if c.title ~= title then -- 827
						_accum_0[_len_0] = c -- 827
						_len_0 = _len_0 + 1 -- 827
					end -- 827
				end -- 827
				child.children = _accum_0 -- 827
			end -- 827
			break -- 828
			::_continue_0:: -- 825
		end -- 828
	else -- 830
		local _accum_0 = { } -- 830
		local _len_0 = 1 -- 830
		local _list_0 = _with_0.children -- 830
		for _index_0 = 1, #_list_0 do -- 830
			local child = _list_0[_index_0] -- 830
			if child.title ~= "Dora" then -- 830
				_accum_0[_len_0] = child -- 830
				_len_0 = _len_0 + 1 -- 830
			end -- 830
		end -- 830
		_with_0.children = _accum_0 -- 830
	end -- 823
	return _with_0 -- 822
end -- 822
local _anon_func_11 = function(Content, Path, engineDev, visitAssets) -- 831
	if engineDev then -- 831
		local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Dev")) -- 832
		local _obj_0 = _with_0.children -- 833
		_obj_0[#_obj_0 + 1] = { -- 834
			key = Path(Content.assetPath, "Script", "init.yue"), -- 834
			dir = false, -- 835
			title = "init.yue" -- 836
		} -- 833
		return _with_0 -- 832
	end -- 831
end -- 831
local _anon_func_3 = function(Content, Path, engineDev, visitAssets, zh) -- 839
	local _tab_0 = { -- 802
		{ -- 803
			key = Path(Content.assetPath), -- 803
			dir = true, -- 804
			title = zh and "内置资源" or "Built-in", -- 805
			children = { -- 807
				_anon_func_4(Content, Path, visitAssets, zh), -- 807
				_anon_func_5(Content, Path, visitAssets, zh), -- 809
				_anon_func_6(Content, Path, visitAssets, zh), -- 811
				_anon_func_7(Content, Path, visitAssets, zh), -- 813
				_anon_func_8(Content, Path, visitAssets, zh), -- 815
				_anon_func_9(Content, Path, visitAssets, zh), -- 817
				visitAssets(Path(Content.assetPath, "Image")), -- 819
				visitAssets(Path(Content.assetPath, "Spine")), -- 820
				visitAssets(Path(Content.assetPath, "Font")), -- 821
				_anon_func_10(Content, Path, engineDev, visitAssets, zh), -- 822
				_anon_func_11(Content, Path, engineDev, visitAssets) -- 831
			} -- 806
		} -- 802
	} -- 840
	local _obj_0 = visitAssets(Content.writablePath, true) -- 840
	local _idx_0 = #_tab_0 + 1 -- 840
	for _index_0 = 1, #_obj_0 do -- 840
		local _value_0 = _obj_0[_index_0] -- 840
		_tab_0[_idx_0] = _value_0 -- 840
		_idx_0 = _idx_0 + 1 -- 840
	end -- 840
	return _tab_0 -- 839
end -- 802
HttpServer:post("/assets", function() -- 741
	local Entry = require("Script.Dev.Entry") -- 742
	local engineDev = Entry.getEngineDev() -- 743
	local visitAssets -- 744
	visitAssets = function(path, root) -- 744
		local children = nil -- 745
		local dirs = Content:getDirs(path) -- 746
		for _index_0 = 1, #dirs do -- 747
			local dir = dirs[_index_0] -- 747
			if root then -- 748
				if ".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir then -- 748
					goto _continue_0 -- 749
				end -- 749
			elseif dir == ".git" then -- 750
				goto _continue_0 -- 751
			end -- 748
			if not children then -- 752
				children = { } -- 752
			end -- 752
			children[#children + 1] = visitAssets(Path(path, dir)) -- 753
			::_continue_0:: -- 748
		end -- 753
		local files = Content:getFiles(path) -- 754
		local names = { } -- 755
		for _index_0 = 1, #files do -- 756
			local file = files[_index_0] -- 756
			if file:match("^%.") then -- 757
				goto _continue_1 -- 757
			end -- 757
			local name = Path:getName(file) -- 758
			local ext = names[name] -- 759
			if ext then -- 759
				local lv1 -- 760
				do -- 760
					local _exp_0 = extentionLevels[ext] -- 760
					if _exp_0 ~= nil then -- 760
						lv1 = _exp_0 -- 760
					else -- 760
						lv1 = -1 -- 760
					end -- 760
				end -- 760
				ext = Path:getExt(file) -- 761
				local lv2 -- 762
				do -- 762
					local _exp_0 = extentionLevels[ext] -- 762
					if _exp_0 ~= nil then -- 762
						lv2 = _exp_0 -- 762
					else -- 762
						lv2 = -1 -- 762
					end -- 762
				end -- 762
				if lv2 > lv1 then -- 763
					names[name] = ext -- 764
				elseif lv2 == lv1 then -- 765
					names[name .. '.' .. ext] = "" -- 766
				end -- 763
			else -- 768
				ext = Path:getExt(file) -- 768
				if not extentionLevels[ext] then -- 769
					names[file] = "" -- 770
				else -- 772
					names[name] = ext -- 772
				end -- 769
			end -- 759
			::_continue_1:: -- 757
		end -- 772
		do -- 773
			local _accum_0 = { } -- 773
			local _len_0 = 1 -- 773
			for name, ext in pairs(names) do -- 773
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 773
				_len_0 = _len_0 + 1 -- 773
			end -- 773
			files = _accum_0 -- 773
		end -- 773
		for _index_0 = 1, #files do -- 774
			local file = files[_index_0] -- 774
			if not children then -- 775
				children = { } -- 775
			end -- 775
			children[#children + 1] = { -- 777
				key = Path(path, file), -- 777
				dir = false, -- 778
				title = file -- 779
			} -- 776
		end -- 780
		if children then -- 781
			table.sort(children, function(a, b) -- 782
				if a.dir == b.dir then -- 783
					return a.title < b.title -- 784
				else -- 786
					return a.dir -- 786
				end -- 783
			end) -- 782
		end -- 781
		if root then -- 787
			return children -- 788
		else -- 790
			return { -- 791
				key = path, -- 791
				dir = true, -- 792
				title = Path:getFilename(path), -- 793
				children = children -- 794
			} -- 795
		end -- 787
	end -- 744
	local zh = (App.locale:match("^zh") ~= nil) -- 796
	return { -- 798
		key = Content.writablePath, -- 798
		dir = true, -- 799
		title = "Assets", -- 800
		children = _anon_func_3(Content, Path, engineDev, visitAssets, zh) -- 801
	} -- 842
end) -- 741
HttpServer:postSchedule("/run", function(req) -- 844
	do -- 845
		local _type_0 = type(req) -- 845
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 845
		if _tab_0 then -- 845
			local file -- 845
			do -- 845
				local _obj_0 = req.body -- 845
				local _type_1 = type(_obj_0) -- 845
				if "table" == _type_1 or "userdata" == _type_1 then -- 845
					file = _obj_0.file -- 845
				end -- 860
			end -- 860
			local asProj -- 845
			do -- 845
				local _obj_0 = req.body -- 845
				local _type_1 = type(_obj_0) -- 845
				if "table" == _type_1 or "userdata" == _type_1 then -- 845
					asProj = _obj_0.asProj -- 845
				end -- 860
			end -- 860
			if file ~= nil and asProj ~= nil then -- 845
				if not Content:isAbsolutePath(file) then -- 846
					local devFile = Path(Content.writablePath, file) -- 847
					if Content:exist(devFile) then -- 848
						file = devFile -- 848
					end -- 848
				end -- 846
				local Entry = require("Script.Dev.Entry") -- 849
				if asProj then -- 850
					local proj = getProjectDirFromFile(file) -- 851
					if proj then -- 851
						Entry.allClear() -- 852
						local target = Path(proj, "init") -- 853
						local success, err = Entry.enterEntryAsync({ -- 854
							"Project", -- 854
							target -- 854
						}) -- 854
						target = Path:getName(Path:getPath(target)) -- 855
						return { -- 856
							success = success, -- 856
							target = target, -- 856
							err = err -- 856
						} -- 856
					end -- 851
				end -- 850
				Entry.allClear() -- 857
				file = Path:replaceExt(file, "") -- 858
				local success, err = Entry.enterEntryAsync({ -- 859
					Path:getName(file), -- 859
					file -- 859
				}) -- 859
				return { -- 860
					success = success, -- 860
					err = err -- 860
				} -- 860
			end -- 845
		end -- 860
	end -- 860
	return { -- 844
		success = false -- 844
	} -- 860
end) -- 844
HttpServer:postSchedule("/stop", function() -- 862
	local Entry = require("Script.Dev.Entry") -- 863
	return { -- 864
		success = Entry.stop() -- 864
	} -- 864
end) -- 862
local minifyAsync -- 866
minifyAsync = function(sourcePath, minifyPath) -- 866
	if not Content:exist(sourcePath) then -- 867
		return -- 867
	end -- 867
	local Entry = require("Script.Dev.Entry") -- 868
	local errors = { } -- 869
	local files = Entry.getAllFiles(sourcePath, { -- 870
		"lua" -- 870
	}, true) -- 870
	do -- 871
		local _accum_0 = { } -- 871
		local _len_0 = 1 -- 871
		for _index_0 = 1, #files do -- 871
			local file = files[_index_0] -- 871
			if file:sub(1, 1) ~= '.' then -- 871
				_accum_0[_len_0] = file -- 871
				_len_0 = _len_0 + 1 -- 871
			end -- 871
		end -- 871
		files = _accum_0 -- 871
	end -- 871
	local paths -- 872
	do -- 872
		local _tbl_0 = { } -- 872
		for _index_0 = 1, #files do -- 872
			local file = files[_index_0] -- 872
			_tbl_0[Path:getPath(file)] = true -- 872
		end -- 872
		paths = _tbl_0 -- 872
	end -- 872
	for path in pairs(paths) do -- 873
		Content:mkdir(Path(minifyPath, path)) -- 873
	end -- 873
	local _ <close> = setmetatable({ }, { -- 874
		__close = function() -- 874
			package.loaded["luaminify.FormatMini"] = nil -- 875
			package.loaded["luaminify.ParseLua"] = nil -- 876
			package.loaded["luaminify.Scope"] = nil -- 877
			package.loaded["luaminify.Util"] = nil -- 878
		end -- 874
	}) -- 874
	local FormatMini -- 879
	do -- 879
		local _obj_0 = require("luaminify") -- 879
		FormatMini = _obj_0.FormatMini -- 879
	end -- 879
	local fileCount = #files -- 880
	local count = 0 -- 881
	for _index_0 = 1, #files do -- 882
		local file = files[_index_0] -- 882
		thread(function() -- 883
			local _ <close> = setmetatable({ }, { -- 884
				__close = function() -- 884
					count = count + 1 -- 884
				end -- 884
			}) -- 884
			local input = Path(sourcePath, file) -- 885
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 886
			if Content:exist(input) then -- 887
				local sourceCodes = Content:loadAsync(input) -- 888
				local res, err = FormatMini(sourceCodes) -- 889
				if res then -- 890
					Content:saveAsync(output, res) -- 891
					return print("Minify " .. tostring(file)) -- 892
				else -- 894
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 894
				end -- 890
			else -- 896
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 896
			end -- 887
		end) -- 883
		sleep() -- 897
	end -- 897
	wait(function() -- 898
		return count == fileCount -- 898
	end) -- 898
	if #errors > 0 then -- 899
		print(table.concat(errors, '\n')) -- 900
	end -- 899
	print("Obfuscation done.") -- 901
	return files -- 902
end -- 866
local zipping = false -- 904
HttpServer:postSchedule("/zip", function(req) -- 906
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
				end -- 936
			end -- 936
			local zipFile -- 907
			do -- 907
				local _obj_0 = req.body -- 907
				local _type_1 = type(_obj_0) -- 907
				if "table" == _type_1 or "userdata" == _type_1 then -- 907
					zipFile = _obj_0.zipFile -- 907
				end -- 936
			end -- 936
			local obfuscated -- 907
			do -- 907
				local _obj_0 = req.body -- 907
				local _type_1 = type(_obj_0) -- 907
				if "table" == _type_1 or "userdata" == _type_1 then -- 907
					obfuscated = _obj_0.obfuscated -- 907
				end -- 936
			end -- 936
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 907
				if zipping then -- 908
					goto failed -- 908
				end -- 908
				zipping = true -- 909
				local _ <close> = setmetatable({ }, { -- 910
					__close = function() -- 910
						zipping = false -- 910
					end -- 910
				}) -- 910
				if not Content:exist(path) then -- 911
					goto failed -- 911
				end -- 911
				Content:mkdir(Path:getPath(zipFile)) -- 912
				if obfuscated then -- 913
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 914
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 915
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 916
					Content:remove(scriptPath) -- 917
					Content:remove(obfuscatedPath) -- 918
					Content:remove(tempPath) -- 919
					Content:mkdir(scriptPath) -- 920
					Content:mkdir(obfuscatedPath) -- 921
					Content:mkdir(tempPath) -- 922
					if not Content:copyAsync(path, tempPath) then -- 923
						goto failed -- 923
					end -- 923
					local Entry = require("Script.Dev.Entry") -- 924
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 925
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 926
						"tl", -- 926
						"yue", -- 926
						"lua", -- 926
						"ts", -- 926
						"tsx", -- 926
						"vs", -- 926
						"xml" -- 926
					}, true) -- 926
					for _index_0 = 1, #scriptFiles do -- 927
						local file = scriptFiles[_index_0] -- 927
						Content:remove(Path(tempPath, file)) -- 928
					end -- 928
					for _index_0 = 1, #luaFiles do -- 929
						local file = luaFiles[_index_0] -- 929
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 930
					end -- 930
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 931
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 932
					end) then -- 931
						goto failed -- 931
					end -- 931
					return { -- 933
						success = true -- 933
					} -- 933
				else -- 935
					return { -- 935
						success = Content:zipAsync(path, zipFile, function(file) -- 935
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 936
						end) -- 935
					} -- 936
				end -- 913
			end -- 907
		end -- 936
	end -- 936
	::failed:: -- 937
	return { -- 906
		success = false -- 906
	} -- 937
end) -- 906
HttpServer:postSchedule("/unzip", function(req) -- 939
	do -- 940
		local _type_0 = type(req) -- 940
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 940
		if _tab_0 then -- 940
			local zipFile -- 940
			do -- 940
				local _obj_0 = req.body -- 940
				local _type_1 = type(_obj_0) -- 940
				if "table" == _type_1 or "userdata" == _type_1 then -- 940
					zipFile = _obj_0.zipFile -- 940
				end -- 942
			end -- 942
			local path -- 940
			do -- 940
				local _obj_0 = req.body -- 940
				local _type_1 = type(_obj_0) -- 940
				if "table" == _type_1 or "userdata" == _type_1 then -- 940
					path = _obj_0.path -- 940
				end -- 942
			end -- 942
			if zipFile ~= nil and path ~= nil then -- 940
				return { -- 941
					success = Content:unzipAsync(zipFile, path, function(file) -- 941
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 942
					end) -- 941
				} -- 942
			end -- 940
		end -- 942
	end -- 942
	return { -- 939
		success = false -- 939
	} -- 942
end) -- 939
HttpServer:post("/editingInfo", function(req) -- 944
	local Entry = require("Script.Dev.Entry") -- 945
	local config = Entry.getConfig() -- 946
	local _type_0 = type(req) -- 947
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 947
	local _match_0 = false -- 947
	if _tab_0 then -- 947
		local editingInfo -- 947
		do -- 947
			local _obj_0 = req.body -- 947
			local _type_1 = type(_obj_0) -- 947
			if "table" == _type_1 or "userdata" == _type_1 then -- 947
				editingInfo = _obj_0.editingInfo -- 947
			end -- 949
		end -- 949
		if editingInfo ~= nil then -- 947
			_match_0 = true -- 947
			config.editingInfo = editingInfo -- 948
			return { -- 949
				success = true -- 949
			} -- 949
		end -- 947
	end -- 947
	if not _match_0 then -- 947
		if not (config.editingInfo ~= nil) then -- 951
			local folder -- 952
			if App.locale:match('^zh') then -- 952
				folder = 'zh-Hans' -- 952
			else -- 952
				folder = 'en' -- 952
			end -- 952
			config.editingInfo = json.dump({ -- 954
				index = 0, -- 954
				files = { -- 956
					{ -- 957
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 957
						title = "welcome.md" -- 958
					} -- 956
				} -- 955
			}) -- 953
		end -- 951
		return { -- 962
			success = true, -- 962
			editingInfo = config.editingInfo -- 962
		} -- 962
	end -- 962
end) -- 944
HttpServer:post("/command", function(req) -- 964
	do -- 965
		local _type_0 = type(req) -- 965
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 965
		if _tab_0 then -- 965
			local code -- 965
			do -- 965
				local _obj_0 = req.body -- 965
				local _type_1 = type(_obj_0) -- 965
				if "table" == _type_1 or "userdata" == _type_1 then -- 965
					code = _obj_0.code -- 965
				end -- 967
			end -- 967
			local log -- 965
			do -- 965
				local _obj_0 = req.body -- 965
				local _type_1 = type(_obj_0) -- 965
				if "table" == _type_1 or "userdata" == _type_1 then -- 965
					log = _obj_0.log -- 965
				end -- 967
			end -- 967
			if code ~= nil and log ~= nil then -- 965
				emit("AppCommand", code, log) -- 966
				return { -- 967
					success = true -- 967
				} -- 967
			end -- 965
		end -- 967
	end -- 967
	return { -- 964
		success = false -- 964
	} -- 967
end) -- 964
HttpServer:post("/saveLog", function() -- 969
	local folder = ".download" -- 970
	local fullLogFile = "dora_full_logs.txt" -- 971
	local fullFolder = Path(Content.writablePath, folder) -- 972
	Content:mkdir(fullFolder) -- 973
	local logPath = Path(fullFolder, fullLogFile) -- 974
	if App:saveLog(logPath) then -- 975
		return { -- 976
			success = true, -- 976
			path = Path(folder, fullLogFile) -- 976
		} -- 976
	end -- 975
	return { -- 969
		success = false -- 969
	} -- 976
end) -- 969
local status = { } -- 978
_module_0 = status -- 979
thread(function() -- 981
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 982
	local doraReady = Path(Content.writablePath, ".www", "dora-ready") -- 983
	if Content:exist(doraWeb) then -- 984
		local needReload -- 985
		if Content:exist(doraReady) then -- 985
			needReload = App.version ~= Content:load(doraReady) -- 986
		else -- 987
			needReload = true -- 987
		end -- 985
		if needReload then -- 988
			Content:remove(Path(Content.writablePath, ".www")) -- 989
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.writablePath, ".www")) -- 990
			Content:save(doraReady, App.version) -- 994
			print("Dora Dora is ready!") -- 995
		end -- 988
	end -- 984
	if HttpServer:start(8866) then -- 996
		local localIP = HttpServer.localIP -- 997
		if localIP == "" then -- 998
			localIP = "localhost" -- 998
		end -- 998
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 999
		return HttpServer:startWS(8868) -- 1000
	else -- 1002
		status.url = nil -- 1002
		return print("8866 Port not available!") -- 1003
	end -- 996
end) -- 981
return _module_0 -- 1003
