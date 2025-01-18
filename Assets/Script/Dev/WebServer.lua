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
HttpServer.wwwPath = Path(Content.appPath, ".www") -- 13
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
				local uploadPath = Path(Content.appPath, ".upload") -- 500
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
				path = Path(Content.appPath, path) -- 508
				if Content:exist(path) then -- 509
					local uploadPath = Path(Content.appPath, ".upload") -- 510
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
				end -- 577
			end -- 577
			local content -- 555
			do -- 555
				local _obj_0 = req.body -- 555
				local _type_1 = type(_obj_0) -- 555
				if "table" == _type_1 or "userdata" == _type_1 then -- 555
					content = _obj_0.content -- 555
				end -- 577
			end -- 577
			local folder -- 555
			do -- 555
				local _obj_0 = req.body -- 555
				local _type_1 = type(_obj_0) -- 555
				if "table" == _type_1 or "userdata" == _type_1 then -- 555
					folder = _obj_0.folder -- 555
				end -- 577
			end -- 577
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
								local ext = Path:getExt(file) -- 570
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext or "lua" == ext) then -- 571
									goto _continue_0 -- 572
								elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 573
									goto _continue_0 -- 574
								end -- 571
								return { -- 575
									success = false -- 575
								} -- 575
							end -- 569
							::_continue_0:: -- 569
						end -- 575
						if Content:save(path, content) then -- 576
							return { -- 577
								success = true -- 577
							} -- 577
						end -- 576
					end -- 559
				end -- 556
			end -- 555
		end -- 577
	end -- 577
	return { -- 554
		success = false -- 554
	} -- 577
end) -- 554
HttpServer:post("/delete", function(req) -- 579
	do -- 580
		local _type_0 = type(req) -- 580
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 580
		if _tab_0 then -- 580
			local path -- 580
			do -- 580
				local _obj_0 = req.body -- 580
				local _type_1 = type(_obj_0) -- 580
				if "table" == _type_1 or "userdata" == _type_1 then -- 580
					path = _obj_0.path -- 580
				end -- 593
			end -- 593
			if path ~= nil then -- 580
				if Content:exist(path) then -- 581
					local parent = Path:getPath(path) -- 582
					local files = Content:getFiles(parent) -- 583
					local name = Path:getName(path):lower() -- 584
					local ext = Path:getExt(path) -- 585
					for _index_0 = 1, #files do -- 586
						local file = files[_index_0] -- 586
						if name == Path:getName(file):lower() then -- 587
							local _exp_0 = Path:getExt(file) -- 588
							if "tl" == _exp_0 then -- 588
								if ("vs" == ext) then -- 588
									Content:remove(Path(parent, file)) -- 589
								end -- 588
							elseif "lua" == _exp_0 then -- 590
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 590
									Content:remove(Path(parent, file)) -- 591
								end -- 590
							end -- 591
						end -- 587
					end -- 591
					if Content:remove(path) then -- 592
						return { -- 593
							success = true -- 593
						} -- 593
					end -- 592
				end -- 581
			end -- 580
		end -- 593
	end -- 593
	return { -- 579
		success = false -- 579
	} -- 593
end) -- 579
HttpServer:post("/rename", function(req) -- 595
	do -- 596
		local _type_0 = type(req) -- 596
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 596
		if _tab_0 then -- 596
			local old -- 596
			do -- 596
				local _obj_0 = req.body -- 596
				local _type_1 = type(_obj_0) -- 596
				if "table" == _type_1 or "userdata" == _type_1 then -- 596
					old = _obj_0.old -- 596
				end -- 629
			end -- 629
			local new -- 596
			do -- 596
				local _obj_0 = req.body -- 596
				local _type_1 = type(_obj_0) -- 596
				if "table" == _type_1 or "userdata" == _type_1 then -- 596
					new = _obj_0.new -- 596
				end -- 629
			end -- 629
			if old ~= nil and new ~= nil then -- 596
				if Content:exist(old) and not Content:exist(new) then -- 597
					local parent = Path:getPath(new) -- 598
					local files = Content:getFiles(parent) -- 599
					if Content:isdir(old) then -- 600
						local name = Path:getFilename(new):lower() -- 601
						for _index_0 = 1, #files do -- 602
							local file = files[_index_0] -- 602
							if name == Path:getFilename(file):lower() then -- 603
								return { -- 604
									success = false -- 604
								} -- 604
							end -- 603
						end -- 604
					else -- 606
						local name = Path:getName(new):lower() -- 606
						local ext = Path:getExt(new) -- 607
						for _index_0 = 1, #files do -- 608
							local file = files[_index_0] -- 608
							if name == Path:getName(file):lower() then -- 609
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext or "lua" == ext) then -- 610
									goto _continue_0 -- 611
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 612
									goto _continue_0 -- 613
								end -- 610
								return { -- 614
									success = false -- 614
								} -- 614
							end -- 609
							::_continue_0:: -- 609
						end -- 614
					end -- 600
					if Content:move(old, new) then -- 615
						local newParent = Path:getPath(new) -- 616
						parent = Path:getPath(old) -- 617
						files = Content:getFiles(parent) -- 618
						local newName = Path:getName(new) -- 619
						local oldName = Path:getName(old) -- 620
						local name = oldName:lower() -- 621
						local ext = Path:getExt(old) -- 622
						for _index_0 = 1, #files do -- 623
							local file = files[_index_0] -- 623
							if name == Path:getName(file):lower() then -- 624
								local _exp_0 = Path:getExt(file) -- 625
								if "tl" == _exp_0 then -- 625
									if ("vs" == ext) then -- 625
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 626
									end -- 625
								elseif "lua" == _exp_0 then -- 627
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 627
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 628
									end -- 627
								end -- 628
							end -- 624
						end -- 628
						return { -- 629
							success = true -- 629
						} -- 629
					end -- 615
				end -- 597
			end -- 596
		end -- 629
	end -- 629
	return { -- 595
		success = false -- 595
	} -- 629
end) -- 595
HttpServer:post("/exist", function(req) -- 631
	do -- 632
		local _type_0 = type(req) -- 632
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 632
		if _tab_0 then -- 632
			local file -- 632
			do -- 632
				local _obj_0 = req.body -- 632
				local _type_1 = type(_obj_0) -- 632
				if "table" == _type_1 or "userdata" == _type_1 then -- 632
					file = _obj_0.file -- 632
				end -- 641
			end -- 641
			if file ~= nil then -- 632
				do -- 633
					local projFile = req.body.projFile -- 633
					if projFile then -- 633
						local projDir = getProjectDirFromFile(projFile) -- 634
						if projDir then -- 634
							local scriptDir = Path(projDir, "Script") -- 635
							local searchPaths = Content.searchPaths -- 636
							if Content:exist(scriptDir) then -- 637
								Content:addSearchPath(scriptDir) -- 637
							end -- 637
							if Content:exist(projDir) then -- 638
								Content:addSearchPath(projDir) -- 638
							end -- 638
							local _ <close> = setmetatable({ }, { -- 639
								__close = function() -- 639
									Content.searchPaths = searchPaths -- 639
								end -- 639
							}) -- 639
							return { -- 640
								success = Content:exist(file) -- 640
							} -- 640
						end -- 634
					end -- 633
				end -- 633
				return { -- 641
					success = Content:exist(file) -- 641
				} -- 641
			end -- 632
		end -- 641
	end -- 641
	return { -- 631
		success = false -- 631
	} -- 641
end) -- 631
HttpServer:postSchedule("/read", function(req) -- 643
	do -- 644
		local _type_0 = type(req) -- 644
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 644
		if _tab_0 then -- 644
			local path -- 644
			do -- 644
				local _obj_0 = req.body -- 644
				local _type_1 = type(_obj_0) -- 644
				if "table" == _type_1 or "userdata" == _type_1 then -- 644
					path = _obj_0.path -- 644
				end -- 657
			end -- 657
			if path ~= nil then -- 644
				local readFile -- 645
				readFile = function() -- 645
					if Content:exist(path) then -- 646
						local content = Content:loadAsync(path) -- 647
						if content then -- 647
							return { -- 648
								content = content, -- 648
								success = true -- 648
							} -- 648
						end -- 647
					end -- 646
					return nil -- 648
				end -- 645
				do -- 649
					local projFile = req.body.projFile -- 649
					if projFile then -- 649
						local projDir = getProjectDirFromFile(projFile) -- 650
						if projDir then -- 650
							local scriptDir = Path(projDir, "Script") -- 651
							local searchPaths = Content.searchPaths -- 652
							if Content:exist(scriptDir) then -- 653
								Content:addSearchPath(scriptDir) -- 653
							end -- 653
							if Content:exist(projDir) then -- 654
								Content:addSearchPath(projDir) -- 654
							end -- 654
							local _ <close> = setmetatable({ }, { -- 655
								__close = function() -- 655
									Content.searchPaths = searchPaths -- 655
								end -- 655
							}) -- 655
							local result = readFile() -- 656
							if result then -- 656
								return result -- 656
							end -- 656
						end -- 650
					end -- 649
				end -- 649
				local result = readFile() -- 657
				if result then -- 657
					return result -- 657
				end -- 657
			end -- 644
		end -- 657
	end -- 657
	return { -- 643
		success = false -- 643
	} -- 657
end) -- 643
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
				end -- 675
			end -- 675
			local exts -- 660
			do -- 660
				local _obj_0 = req.body -- 660
				local _type_1 = type(_obj_0) -- 660
				if "table" == _type_1 or "userdata" == _type_1 then -- 660
					exts = _obj_0.exts -- 660
				end -- 675
			end -- 675
			if path ~= nil and exts ~= nil then -- 660
				local readFile -- 661
				readFile = function() -- 661
					for _index_0 = 1, #exts do -- 662
						local ext = exts[_index_0] -- 662
						local targetPath = path .. ext -- 663
						if Content:exist(targetPath) then -- 664
							local content = Content:load(targetPath) -- 665
							if content then -- 665
								return { -- 666
									content = content, -- 666
									success = true, -- 666
									fullPath = Content:getFullPath(targetPath) -- 666
								} -- 666
							end -- 665
						end -- 664
					end -- 666
					return nil -- 666
				end -- 661
				do -- 667
					local projFile = req.body.projFile -- 667
					if projFile then -- 667
						local projDir = getProjectDirFromFile(projFile) -- 668
						if projDir then -- 668
							local scriptDir = Path(projDir, "Script") -- 669
							local searchPaths = Content.searchPaths -- 670
							if Content:exist(scriptDir) then -- 671
								Content:addSearchPath(scriptDir) -- 671
							end -- 671
							if Content:exist(projDir) then -- 672
								Content:addSearchPath(projDir) -- 672
							end -- 672
							local _ <close> = setmetatable({ }, { -- 673
								__close = function() -- 673
									Content.searchPaths = searchPaths -- 673
								end -- 673
							}) -- 673
							local result = readFile() -- 674
							if result then -- 674
								return result -- 674
							end -- 674
						end -- 668
					end -- 667
				end -- 667
				local result = readFile() -- 675
				if result then -- 675
					return result -- 675
				end -- 675
			end -- 660
		end -- 675
	end -- 675
	return { -- 659
		success = false -- 659
	} -- 675
end) -- 659
local compileFileAsync -- 677
compileFileAsync = function(inputFile, sourceCodes) -- 677
	local file = inputFile -- 678
	local searchPath -- 679
	do -- 679
		local dir = getProjectDirFromFile(inputFile) -- 679
		if dir then -- 679
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 680
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 681
		else -- 683
			file = Path:getRelative(inputFile, Path(Content.writablePath)) -- 683
			if file:sub(1, 2) == ".." then -- 684
				file = Path:getRelative(inputFile, Path(Content.assetPath)) -- 685
			end -- 684
			searchPath = "" -- 686
		end -- 679
	end -- 679
	local outputFile = Path:replaceExt(inputFile, "lua") -- 687
	local yueext = yue.options.extension -- 688
	local resultCodes = nil -- 689
	do -- 690
		local _exp_0 = Path:getExt(inputFile) -- 690
		if yueext == _exp_0 then -- 690
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 691
				if not codes then -- 692
					return -- 692
				end -- 692
				local success, result = LintYueGlobals(codes, globals) -- 693
				if not success then -- 694
					return -- 694
				end -- 694
				if codes == "" then -- 695
					resultCodes = "" -- 696
					return nil -- 697
				end -- 695
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 698
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 699
				codes = codes:gsub("^\n*", "") -- 700
				if not (result == "") then -- 701
					result = result .. "\n" -- 701
				end -- 701
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 702
				return resultCodes -- 703
			end, function(success) -- 691
				if not success then -- 704
					Content:remove(outputFile) -- 705
					if resultCodes == nil then -- 706
						resultCodes = false -- 707
					end -- 706
				end -- 704
			end) -- 691
		elseif "tl" == _exp_0 then -- 708
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 709
			if codes then -- 709
				resultCodes = codes -- 710
				Content:saveAsync(outputFile, codes) -- 711
			else -- 713
				Content:remove(outputFile) -- 713
				resultCodes = false -- 714
			end -- 709
		elseif "xml" == _exp_0 then -- 715
			local codes = xml.tolua(sourceCodes) -- 716
			if codes then -- 716
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 717
				Content:saveAsync(outputFile, resultCodes) -- 718
			else -- 720
				Content:remove(outputFile) -- 720
				resultCodes = false -- 721
			end -- 716
		end -- 721
	end -- 721
	wait(function() -- 722
		return resultCodes ~= nil -- 722
	end) -- 722
	if resultCodes then -- 723
		return resultCodes -- 723
	end -- 723
	return nil -- 723
end -- 677
HttpServer:postSchedule("/write", function(req) -- 725
	do -- 726
		local _type_0 = type(req) -- 726
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 726
		if _tab_0 then -- 726
			local path -- 726
			do -- 726
				local _obj_0 = req.body -- 726
				local _type_1 = type(_obj_0) -- 726
				if "table" == _type_1 or "userdata" == _type_1 then -- 726
					path = _obj_0.path -- 726
				end -- 732
			end -- 732
			local content -- 726
			do -- 726
				local _obj_0 = req.body -- 726
				local _type_1 = type(_obj_0) -- 726
				if "table" == _type_1 or "userdata" == _type_1 then -- 726
					content = _obj_0.content -- 726
				end -- 732
			end -- 732
			if path ~= nil and content ~= nil then -- 726
				if Content:saveAsync(path, content) then -- 727
					do -- 728
						local _exp_0 = Path:getExt(path) -- 728
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 728
							if '' == Path:getExt(Path:getName(path)) then -- 729
								local resultCodes = compileFileAsync(path, content) -- 730
								return { -- 731
									success = true, -- 731
									resultCodes = resultCodes -- 731
								} -- 731
							end -- 729
						end -- 731
					end -- 731
					return { -- 732
						success = true -- 732
					} -- 732
				end -- 727
			end -- 726
		end -- 732
	end -- 732
	return { -- 725
		success = false -- 725
	} -- 732
end) -- 725
HttpServer:postSchedule("/build", function(req) -- 734
	do -- 735
		local _type_0 = type(req) -- 735
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 735
		if _tab_0 then -- 735
			local path -- 735
			do -- 735
				local _obj_0 = req.body -- 735
				local _type_1 = type(_obj_0) -- 735
				if "table" == _type_1 or "userdata" == _type_1 then -- 735
					path = _obj_0.path -- 735
				end -- 740
			end -- 740
			if path ~= nil then -- 735
				local _exp_0 = Path:getExt(path) -- 736
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 736
					if '' == Path:getExt(Path:getName(path)) then -- 737
						local content = Content:loadAsync(path) -- 738
						if content then -- 738
							local resultCodes = compileFileAsync(path, content) -- 739
							if resultCodes then -- 739
								return { -- 740
									success = true, -- 740
									resultCodes = resultCodes -- 740
								} -- 740
							end -- 739
						end -- 738
					end -- 737
				end -- 740
			end -- 735
		end -- 740
	end -- 740
	return { -- 734
		success = false -- 734
	} -- 740
end) -- 734
local extentionLevels = { -- 743
	vs = 2, -- 743
	ts = 1, -- 744
	tsx = 1, -- 745
	tl = 1, -- 746
	yue = 1, -- 747
	xml = 1, -- 748
	lua = 0 -- 749
} -- 742
HttpServer:post("/assets", function() -- 751
	local Entry = require("Script.Dev.Entry") -- 754
	local engineDev = Entry.getEngineDev() -- 755
	local visitAssets -- 756
	visitAssets = function(path, tag) -- 756
		local isWorkspace = tag == "Workspace" -- 757
		local builtin -- 758
		if tag == "Builtin" then -- 758
			builtin = true -- 758
		else -- 758
			builtin = nil -- 758
		end -- 758
		local children = nil -- 759
		local dirs = Content:getDirs(path) -- 760
		for _index_0 = 1, #dirs do -- 761
			local dir = dirs[_index_0] -- 761
			if isWorkspace then -- 762
				if ".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir then -- 762
					goto _continue_0 -- 763
				end -- 763
			elseif dir == ".git" then -- 764
				goto _continue_0 -- 765
			end -- 762
			if not children then -- 766
				children = { } -- 766
			end -- 766
			children[#children + 1] = visitAssets(Path(path, dir)) -- 767
			::_continue_0:: -- 762
		end -- 767
		local files = Content:getFiles(path) -- 768
		local names = { } -- 769
		for _index_0 = 1, #files do -- 770
			local file = files[_index_0] -- 770
			if file:match("^%.") then -- 771
				goto _continue_1 -- 771
			end -- 771
			local name = Path:getName(file) -- 772
			local ext = names[name] -- 773
			if ext then -- 773
				local lv1 -- 774
				do -- 774
					local _exp_0 = extentionLevels[ext] -- 774
					if _exp_0 ~= nil then -- 774
						lv1 = _exp_0 -- 774
					else -- 774
						lv1 = -1 -- 774
					end -- 774
				end -- 774
				ext = Path:getExt(file) -- 775
				local lv2 -- 776
				do -- 776
					local _exp_0 = extentionLevels[ext] -- 776
					if _exp_0 ~= nil then -- 776
						lv2 = _exp_0 -- 776
					else -- 776
						lv2 = -1 -- 776
					end -- 776
				end -- 776
				if lv2 > lv1 then -- 777
					names[name] = ext -- 778
				elseif lv2 == lv1 then -- 779
					names[name .. '.' .. ext] = "" -- 780
				end -- 777
			else -- 782
				ext = Path:getExt(file) -- 782
				if not extentionLevels[ext] then -- 783
					names[file] = "" -- 784
				else -- 786
					names[name] = ext -- 786
				end -- 783
			end -- 773
			::_continue_1:: -- 771
		end -- 786
		do -- 787
			local _accum_0 = { } -- 787
			local _len_0 = 1 -- 787
			for name, ext in pairs(names) do -- 787
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 787
				_len_0 = _len_0 + 1 -- 787
			end -- 787
			files = _accum_0 -- 787
		end -- 787
		for _index_0 = 1, #files do -- 788
			local file = files[_index_0] -- 788
			if not children then -- 789
				children = { } -- 789
			end -- 789
			children[#children + 1] = { -- 791
				key = Path(path, file), -- 791
				dir = false, -- 792
				title = file, -- 793
				builtin = builtin -- 794
			} -- 790
		end -- 795
		if children then -- 796
			table.sort(children, function(a, b) -- 797
				if a.dir == b.dir then -- 798
					return a.title < b.title -- 799
				else -- 801
					return a.dir -- 801
				end -- 798
			end) -- 797
		end -- 796
		if isWorkspace and children then -- 802
			return children -- 803
		else -- 805
			return { -- 806
				key = path, -- 806
				dir = true, -- 807
				title = Path:getFilename(path), -- 808
				builtin = builtin, -- 809
				children = children -- 810
			} -- 811
		end -- 802
	end -- 756
	local zh = (App.locale:match("^zh") ~= nil) -- 812
	return { -- 814
		key = Content.writablePath, -- 814
		dir = true, -- 815
		root = true, -- 816
		title = "Assets", -- 817
		children = (function() -- 819
			local _tab_0 = { -- 819
				{ -- 820
					key = Path(Content.assetPath), -- 820
					dir = true, -- 821
					builtin = true, -- 822
					title = zh and "内置资源" or "Built-in", -- 823
					children = { -- 825
						(function() -- 825
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 825
							_with_0.title = zh and "说明文档" or "Readme" -- 826
							return _with_0 -- 825
						end)(), -- 825
						(function() -- 827
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 827
							_with_0.title = zh and "接口文档" or "API Doc" -- 828
							return _with_0 -- 827
						end)(), -- 827
						(function() -- 829
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 829
							_with_0.title = zh and "开发工具" or "Tools" -- 830
							return _with_0 -- 829
						end)(), -- 829
						(function() -- 831
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Example")), "Builtin") -- 831
							_with_0.title = zh and "代码示例" or "Example" -- 832
							return _with_0 -- 831
						end)(), -- 831
						(function() -- 833
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Game")), "Builtin") -- 833
							_with_0.title = zh and "游戏演示" or "Demo Game" -- 834
							return _with_0 -- 833
						end)(), -- 833
						(function() -- 835
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Test")), "Builtin") -- 835
							_with_0.title = zh and "功能测试" or "Test" -- 836
							return _with_0 -- 835
						end)(), -- 835
						visitAssets((Path(Content.assetPath, "Image")), "Builtin"), -- 837
						visitAssets((Path(Content.assetPath, "Spine")), "Builtin"), -- 838
						visitAssets((Path(Content.assetPath, "Font")), "Builtin"), -- 839
						(function() -- 840
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 840
							if engineDev then -- 841
								local _list_0 = _with_0.children -- 842
								for _index_0 = 1, #_list_0 do -- 842
									local child = _list_0[_index_0] -- 842
									if not (child.title == "Dora") then -- 843
										goto _continue_0 -- 843
									end -- 843
									local title = zh and "zh-Hans" or "en" -- 844
									do -- 845
										local _accum_0 = { } -- 845
										local _len_0 = 1 -- 845
										local _list_1 = child.children -- 845
										for _index_1 = 1, #_list_1 do -- 845
											local c = _list_1[_index_1] -- 845
											if c.title ~= title then -- 845
												_accum_0[_len_0] = c -- 845
												_len_0 = _len_0 + 1 -- 845
											end -- 845
										end -- 845
										child.children = _accum_0 -- 845
									end -- 845
									break -- 846
									::_continue_0:: -- 843
								end -- 846
							else -- 848
								local _accum_0 = { } -- 848
								local _len_0 = 1 -- 848
								local _list_0 = _with_0.children -- 848
								for _index_0 = 1, #_list_0 do -- 848
									local child = _list_0[_index_0] -- 848
									if child.title ~= "Dora" then -- 848
										_accum_0[_len_0] = child -- 848
										_len_0 = _len_0 + 1 -- 848
									end -- 848
								end -- 848
								_with_0.children = _accum_0 -- 848
							end -- 841
							return _with_0 -- 840
						end)(), -- 840
						(function() -- 849
							if engineDev then -- 849
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 850
								local _obj_0 = _with_0.children -- 851
								_obj_0[#_obj_0 + 1] = { -- 852
									key = Path(Content.assetPath, "Script", "init.yue"), -- 852
									dir = false, -- 853
									builtin = true, -- 854
									title = "init.yue" -- 855
								} -- 851
								return _with_0 -- 850
							end -- 849
						end)() -- 849
					} -- 824
				} -- 819
			} -- 859
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 859
			local _idx_0 = #_tab_0 + 1 -- 859
			for _index_0 = 1, #_obj_0 do -- 859
				local _value_0 = _obj_0[_index_0] -- 859
				_tab_0[_idx_0] = _value_0 -- 859
				_idx_0 = _idx_0 + 1 -- 859
			end -- 859
			return _tab_0 -- 858
		end)() -- 818
	} -- 861
end) -- 751
HttpServer:postSchedule("/run", function(req) -- 863
	do -- 864
		local _type_0 = type(req) -- 864
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 864
		if _tab_0 then -- 864
			local file -- 864
			do -- 864
				local _obj_0 = req.body -- 864
				local _type_1 = type(_obj_0) -- 864
				if "table" == _type_1 or "userdata" == _type_1 then -- 864
					file = _obj_0.file -- 864
				end -- 879
			end -- 879
			local asProj -- 864
			do -- 864
				local _obj_0 = req.body -- 864
				local _type_1 = type(_obj_0) -- 864
				if "table" == _type_1 or "userdata" == _type_1 then -- 864
					asProj = _obj_0.asProj -- 864
				end -- 879
			end -- 879
			if file ~= nil and asProj ~= nil then -- 864
				if not Content:isAbsolutePath(file) then -- 865
					local devFile = Path(Content.writablePath, file) -- 866
					if Content:exist(devFile) then -- 867
						file = devFile -- 867
					end -- 867
				end -- 865
				local Entry = require("Script.Dev.Entry") -- 868
				if asProj then -- 869
					local proj = getProjectDirFromFile(file) -- 870
					if proj then -- 870
						Entry.allClear() -- 871
						local target = Path(proj, "init") -- 872
						local success, err = Entry.enterEntryAsync({ -- 873
							"Project", -- 873
							target -- 873
						}) -- 873
						target = Path:getName(Path:getPath(target)) -- 874
						return { -- 875
							success = success, -- 875
							target = target, -- 875
							err = err -- 875
						} -- 875
					end -- 870
				end -- 869
				Entry.allClear() -- 876
				file = Path:replaceExt(file, "") -- 877
				local success, err = Entry.enterEntryAsync({ -- 878
					Path:getName(file), -- 878
					file -- 878
				}) -- 878
				return { -- 879
					success = success, -- 879
					err = err -- 879
				} -- 879
			end -- 864
		end -- 879
	end -- 879
	return { -- 863
		success = false -- 863
	} -- 879
end) -- 863
HttpServer:postSchedule("/stop", function() -- 881
	local Entry = require("Script.Dev.Entry") -- 882
	return { -- 883
		success = Entry.stop() -- 883
	} -- 883
end) -- 881
local minifyAsync -- 885
minifyAsync = function(sourcePath, minifyPath) -- 885
	if not Content:exist(sourcePath) then -- 886
		return -- 886
	end -- 886
	local Entry = require("Script.Dev.Entry") -- 887
	local errors = { } -- 888
	local files = Entry.getAllFiles(sourcePath, { -- 889
		"lua" -- 889
	}, true) -- 889
	do -- 890
		local _accum_0 = { } -- 890
		local _len_0 = 1 -- 890
		for _index_0 = 1, #files do -- 890
			local file = files[_index_0] -- 890
			if file:sub(1, 1) ~= '.' then -- 890
				_accum_0[_len_0] = file -- 890
				_len_0 = _len_0 + 1 -- 890
			end -- 890
		end -- 890
		files = _accum_0 -- 890
	end -- 890
	local paths -- 891
	do -- 891
		local _tbl_0 = { } -- 891
		for _index_0 = 1, #files do -- 891
			local file = files[_index_0] -- 891
			_tbl_0[Path:getPath(file)] = true -- 891
		end -- 891
		paths = _tbl_0 -- 891
	end -- 891
	for path in pairs(paths) do -- 892
		Content:mkdir(Path(minifyPath, path)) -- 892
	end -- 892
	local _ <close> = setmetatable({ }, { -- 893
		__close = function() -- 893
			package.loaded["luaminify.FormatMini"] = nil -- 894
			package.loaded["luaminify.ParseLua"] = nil -- 895
			package.loaded["luaminify.Scope"] = nil -- 896
			package.loaded["luaminify.Util"] = nil -- 897
		end -- 893
	}) -- 893
	local FormatMini -- 898
	do -- 898
		local _obj_0 = require("luaminify") -- 898
		FormatMini = _obj_0.FormatMini -- 898
	end -- 898
	local fileCount = #files -- 899
	local count = 0 -- 900
	for _index_0 = 1, #files do -- 901
		local file = files[_index_0] -- 901
		thread(function() -- 902
			local _ <close> = setmetatable({ }, { -- 903
				__close = function() -- 903
					count = count + 1 -- 903
				end -- 903
			}) -- 903
			local input = Path(sourcePath, file) -- 904
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 905
			if Content:exist(input) then -- 906
				local sourceCodes = Content:loadAsync(input) -- 907
				local res, err = FormatMini(sourceCodes) -- 908
				if res then -- 909
					Content:saveAsync(output, res) -- 910
					return print("Minify " .. tostring(file)) -- 911
				else -- 913
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 913
				end -- 909
			else -- 915
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 915
			end -- 906
		end) -- 902
		sleep() -- 916
	end -- 916
	wait(function() -- 917
		return count == fileCount -- 917
	end) -- 917
	if #errors > 0 then -- 918
		print(table.concat(errors, '\n')) -- 919
	end -- 918
	print("Obfuscation done.") -- 920
	return files -- 921
end -- 885
local zipping = false -- 923
HttpServer:postSchedule("/zip", function(req) -- 925
	do -- 926
		local _type_0 = type(req) -- 926
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 926
		if _tab_0 then -- 926
			local path -- 926
			do -- 926
				local _obj_0 = req.body -- 926
				local _type_1 = type(_obj_0) -- 926
				if "table" == _type_1 or "userdata" == _type_1 then -- 926
					path = _obj_0.path -- 926
				end -- 955
			end -- 955
			local zipFile -- 926
			do -- 926
				local _obj_0 = req.body -- 926
				local _type_1 = type(_obj_0) -- 926
				if "table" == _type_1 or "userdata" == _type_1 then -- 926
					zipFile = _obj_0.zipFile -- 926
				end -- 955
			end -- 955
			local obfuscated -- 926
			do -- 926
				local _obj_0 = req.body -- 926
				local _type_1 = type(_obj_0) -- 926
				if "table" == _type_1 or "userdata" == _type_1 then -- 926
					obfuscated = _obj_0.obfuscated -- 926
				end -- 955
			end -- 955
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 926
				if zipping then -- 927
					goto failed -- 927
				end -- 927
				zipping = true -- 928
				local _ <close> = setmetatable({ }, { -- 929
					__close = function() -- 929
						zipping = false -- 929
					end -- 929
				}) -- 929
				if not Content:exist(path) then -- 930
					goto failed -- 930
				end -- 930
				Content:mkdir(Path:getPath(zipFile)) -- 931
				if obfuscated then -- 932
					local scriptPath = Path(Content.appPath, ".download", ".script") -- 933
					local obfuscatedPath = Path(Content.appPath, ".download", ".obfuscated") -- 934
					local tempPath = Path(Content.appPath, ".download", ".temp") -- 935
					Content:remove(scriptPath) -- 936
					Content:remove(obfuscatedPath) -- 937
					Content:remove(tempPath) -- 938
					Content:mkdir(scriptPath) -- 939
					Content:mkdir(obfuscatedPath) -- 940
					Content:mkdir(tempPath) -- 941
					if not Content:copyAsync(path, tempPath) then -- 942
						goto failed -- 942
					end -- 942
					local Entry = require("Script.Dev.Entry") -- 943
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 944
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 945
						"tl", -- 945
						"yue", -- 945
						"lua", -- 945
						"ts", -- 945
						"tsx", -- 945
						"vs", -- 945
						"xml" -- 945
					}, true) -- 945
					for _index_0 = 1, #scriptFiles do -- 946
						local file = scriptFiles[_index_0] -- 946
						Content:remove(Path(tempPath, file)) -- 947
					end -- 947
					for _index_0 = 1, #luaFiles do -- 948
						local file = luaFiles[_index_0] -- 948
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 949
					end -- 949
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 950
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 951
					end) then -- 950
						goto failed -- 950
					end -- 950
					return { -- 952
						success = true -- 952
					} -- 952
				else -- 954
					return { -- 954
						success = Content:zipAsync(path, zipFile, function(file) -- 954
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 955
						end) -- 954
					} -- 955
				end -- 932
			end -- 926
		end -- 955
	end -- 955
	::failed:: -- 956
	return { -- 925
		success = false -- 925
	} -- 956
end) -- 925
HttpServer:postSchedule("/unzip", function(req) -- 958
	do -- 959
		local _type_0 = type(req) -- 959
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 959
		if _tab_0 then -- 959
			local zipFile -- 959
			do -- 959
				local _obj_0 = req.body -- 959
				local _type_1 = type(_obj_0) -- 959
				if "table" == _type_1 or "userdata" == _type_1 then -- 959
					zipFile = _obj_0.zipFile -- 959
				end -- 961
			end -- 961
			local path -- 959
			do -- 959
				local _obj_0 = req.body -- 959
				local _type_1 = type(_obj_0) -- 959
				if "table" == _type_1 or "userdata" == _type_1 then -- 959
					path = _obj_0.path -- 959
				end -- 961
			end -- 961
			if zipFile ~= nil and path ~= nil then -- 959
				return { -- 960
					success = Content:unzipAsync(zipFile, path, function(file) -- 960
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 961
					end) -- 960
				} -- 961
			end -- 959
		end -- 961
	end -- 961
	return { -- 958
		success = false -- 958
	} -- 961
end) -- 958
HttpServer:post("/editingInfo", function(req) -- 963
	local Entry = require("Script.Dev.Entry") -- 964
	local config = Entry.getConfig() -- 965
	local _type_0 = type(req) -- 966
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 966
	local _match_0 = false -- 966
	if _tab_0 then -- 966
		local editingInfo -- 966
		do -- 966
			local _obj_0 = req.body -- 966
			local _type_1 = type(_obj_0) -- 966
			if "table" == _type_1 or "userdata" == _type_1 then -- 966
				editingInfo = _obj_0.editingInfo -- 966
			end -- 968
		end -- 968
		if editingInfo ~= nil then -- 966
			_match_0 = true -- 966
			config.editingInfo = editingInfo -- 967
			return { -- 968
				success = true -- 968
			} -- 968
		end -- 966
	end -- 966
	if not _match_0 then -- 966
		if not (config.editingInfo ~= nil) then -- 970
			local folder -- 971
			if App.locale:match('^zh') then -- 971
				folder = 'zh-Hans' -- 971
			else -- 971
				folder = 'en' -- 971
			end -- 971
			config.editingInfo = json.dump({ -- 973
				index = 0, -- 973
				files = { -- 975
					{ -- 976
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 976
						title = "welcome.md" -- 977
					} -- 975
				} -- 974
			}) -- 972
		end -- 970
		return { -- 981
			success = true, -- 981
			editingInfo = config.editingInfo -- 981
		} -- 981
	end -- 981
end) -- 963
HttpServer:post("/command", function(req) -- 983
	do -- 984
		local _type_0 = type(req) -- 984
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 984
		if _tab_0 then -- 984
			local code -- 984
			do -- 984
				local _obj_0 = req.body -- 984
				local _type_1 = type(_obj_0) -- 984
				if "table" == _type_1 or "userdata" == _type_1 then -- 984
					code = _obj_0.code -- 984
				end -- 986
			end -- 986
			local log -- 984
			do -- 984
				local _obj_0 = req.body -- 984
				local _type_1 = type(_obj_0) -- 984
				if "table" == _type_1 or "userdata" == _type_1 then -- 984
					log = _obj_0.log -- 984
				end -- 986
			end -- 986
			if code ~= nil and log ~= nil then -- 984
				emit("AppCommand", code, log) -- 985
				return { -- 986
					success = true -- 986
				} -- 986
			end -- 984
		end -- 986
	end -- 986
	return { -- 983
		success = false -- 983
	} -- 986
end) -- 983
HttpServer:post("/saveLog", function() -- 988
	local folder = ".download" -- 989
	local fullLogFile = "dora_full_logs.txt" -- 990
	local fullFolder = Path(Content.appPath, folder) -- 991
	Content:mkdir(fullFolder) -- 992
	local logPath = Path(fullFolder, fullLogFile) -- 993
	if App:saveLog(logPath) then -- 994
		return { -- 995
			success = true, -- 995
			path = Path(folder, fullLogFile) -- 995
		} -- 995
	end -- 994
	return { -- 988
		success = false -- 988
	} -- 995
end) -- 988
local status = { } -- 997
_module_0 = status -- 998
thread(function() -- 1000
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1001
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1002
	if Content:exist(doraWeb) then -- 1003
		local needReload -- 1004
		if Content:exist(doraReady) then -- 1004
			needReload = App.version ~= Content:load(doraReady) -- 1005
		else -- 1006
			needReload = true -- 1006
		end -- 1004
		if needReload then -- 1007
			Content:remove(Path(Content.appPath, ".www")) -- 1008
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1009
			Content:save(doraReady, App.version) -- 1013
			print("Dora Dora is ready!") -- 1014
		end -- 1007
	end -- 1003
	if HttpServer:start(8866) then -- 1015
		local localIP = HttpServer.localIP -- 1016
		if localIP == "" then -- 1017
			localIP = "localhost" -- 1017
		end -- 1017
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1018
		return HttpServer:startWS(8868) -- 1019
	else -- 1021
		status.url = nil -- 1021
		return print("8866 Port not available!") -- 1022
	end -- 1015
end) -- 1000
return _module_0 -- 1022
