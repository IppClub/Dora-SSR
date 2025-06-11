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
local Wasm = Dora.Wasm -- 1
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
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 19
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 20
	elseif (".." ~= Path:getRelative(file, assetPath):sub(1, 2)) and assetPath == file:sub(1, #assetPath) then -- 21
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
yueCheck = function(file, content, lax) -- 69
	local searchPath = getSearchPath(file) -- 70
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 71
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
				_len_0 = _len_0 + 1 -- 97
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
getCompiledYueLine = function(content, line, row, file, lax) -- 134
	local luaCodes, _info = yueCheck(file, content, lax) -- 135
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
		if row <= lastLine and not targetLine then -- 146
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
					local luaCodes, info = yueCheck(file, content, false) -- 166
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
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, false) -- 218
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
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, false) -- 295
					if not luaCodes then -- 296
						return { -- 296
							success = false -- 296
						} -- 296
					end -- 296
					do -- 297
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 297
						if chainOp then -- 297
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 298
							if withVar then -- 298
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 299
							end -- 298
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
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 466
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
				path = Path(Content.writablePath, path) -- 508
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
	Entry.connectWebIDE() -- 546
	return { -- 548
		platform = App.platform, -- 548
		locale = App.locale, -- 549
		version = App.version, -- 550
		engineDev = engineDev, -- 551
		webProfiler = webProfiler, -- 552
		drawerWidth = drawerWidth -- 553
	} -- 553
end) -- 542
HttpServer:post("/new", function(req) -- 555
	do -- 556
		local _type_0 = type(req) -- 556
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 556
		if _tab_0 then -- 556
			local path -- 556
			do -- 556
				local _obj_0 = req.body -- 556
				local _type_1 = type(_obj_0) -- 556
				if "table" == _type_1 or "userdata" == _type_1 then -- 556
					path = _obj_0.path -- 556
				end -- 578
			end -- 578
			local content -- 556
			do -- 556
				local _obj_0 = req.body -- 556
				local _type_1 = type(_obj_0) -- 556
				if "table" == _type_1 or "userdata" == _type_1 then -- 556
					content = _obj_0.content -- 556
				end -- 578
			end -- 578
			local folder -- 556
			do -- 556
				local _obj_0 = req.body -- 556
				local _type_1 = type(_obj_0) -- 556
				if "table" == _type_1 or "userdata" == _type_1 then -- 556
					folder = _obj_0.folder -- 556
				end -- 578
			end -- 578
			if path ~= nil and content ~= nil and folder ~= nil then -- 556
				if not Content:exist(path) then -- 557
					local parent = Path:getPath(path) -- 558
					local files = Content:getFiles(parent) -- 559
					if folder then -- 560
						local name = Path:getFilename(path):lower() -- 561
						for _index_0 = 1, #files do -- 562
							local file = files[_index_0] -- 562
							if name == Path:getFilename(file):lower() then -- 563
								return { -- 564
									success = false -- 564
								} -- 564
							end -- 563
						end -- 564
						if Content:mkdir(path) then -- 565
							return { -- 566
								success = true -- 566
							} -- 566
						end -- 565
					else -- 568
						local name = Path:getName(path):lower() -- 568
						for _index_0 = 1, #files do -- 569
							local file = files[_index_0] -- 569
							if name == Path:getName(file):lower() then -- 570
								local ext = Path:getExt(file) -- 571
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 572
									goto _continue_0 -- 573
								elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 574
									goto _continue_0 -- 575
								end -- 572
								return { -- 576
									success = false -- 576
								} -- 576
							end -- 570
							::_continue_0:: -- 570
						end -- 576
						if Content:save(path, content) then -- 577
							return { -- 578
								success = true -- 578
							} -- 578
						end -- 577
					end -- 560
				end -- 557
			end -- 556
		end -- 578
	end -- 578
	return { -- 555
		success = false -- 555
	} -- 578
end) -- 555
HttpServer:post("/delete", function(req) -- 580
	do -- 581
		local _type_0 = type(req) -- 581
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 581
		if _tab_0 then -- 581
			local path -- 581
			do -- 581
				local _obj_0 = req.body -- 581
				local _type_1 = type(_obj_0) -- 581
				if "table" == _type_1 or "userdata" == _type_1 then -- 581
					path = _obj_0.path -- 581
				end -- 594
			end -- 594
			if path ~= nil then -- 581
				if Content:exist(path) then -- 582
					local parent = Path:getPath(path) -- 583
					local files = Content:getFiles(parent) -- 584
					local name = Path:getName(path):lower() -- 585
					local ext = Path:getExt(path) -- 586
					for _index_0 = 1, #files do -- 587
						local file = files[_index_0] -- 587
						if name == Path:getName(file):lower() then -- 588
							local _exp_0 = Path:getExt(file) -- 589
							if "tl" == _exp_0 then -- 589
								if ("vs" == ext) then -- 589
									Content:remove(Path(parent, file)) -- 590
								end -- 589
							elseif "lua" == _exp_0 then -- 591
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 591
									Content:remove(Path(parent, file)) -- 592
								end -- 591
							end -- 592
						end -- 588
					end -- 592
					if Content:remove(path) then -- 593
						return { -- 594
							success = true -- 594
						} -- 594
					end -- 593
				end -- 582
			end -- 581
		end -- 594
	end -- 594
	return { -- 580
		success = false -- 580
	} -- 594
end) -- 580
HttpServer:post("/rename", function(req) -- 596
	do -- 597
		local _type_0 = type(req) -- 597
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 597
		if _tab_0 then -- 597
			local old -- 597
			do -- 597
				local _obj_0 = req.body -- 597
				local _type_1 = type(_obj_0) -- 597
				if "table" == _type_1 or "userdata" == _type_1 then -- 597
					old = _obj_0.old -- 597
				end -- 630
			end -- 630
			local new -- 597
			do -- 597
				local _obj_0 = req.body -- 597
				local _type_1 = type(_obj_0) -- 597
				if "table" == _type_1 or "userdata" == _type_1 then -- 597
					new = _obj_0.new -- 597
				end -- 630
			end -- 630
			if old ~= nil and new ~= nil then -- 597
				if Content:exist(old) and not Content:exist(new) then -- 598
					local parent = Path:getPath(new) -- 599
					local files = Content:getFiles(parent) -- 600
					if Content:isdir(old) then -- 601
						local name = Path:getFilename(new):lower() -- 602
						for _index_0 = 1, #files do -- 603
							local file = files[_index_0] -- 603
							if name == Path:getFilename(file):lower() then -- 604
								return { -- 605
									success = false -- 605
								} -- 605
							end -- 604
						end -- 605
					else -- 607
						local name = Path:getName(new):lower() -- 607
						local ext = Path:getExt(new) -- 608
						for _index_0 = 1, #files do -- 609
							local file = files[_index_0] -- 609
							if name == Path:getName(file):lower() then -- 610
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 611
									goto _continue_0 -- 612
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 613
									goto _continue_0 -- 614
								end -- 611
								return { -- 615
									success = false -- 615
								} -- 615
							end -- 610
							::_continue_0:: -- 610
						end -- 615
					end -- 601
					if Content:move(old, new) then -- 616
						local newParent = Path:getPath(new) -- 617
						parent = Path:getPath(old) -- 618
						files = Content:getFiles(parent) -- 619
						local newName = Path:getName(new) -- 620
						local oldName = Path:getName(old) -- 621
						local name = oldName:lower() -- 622
						local ext = Path:getExt(old) -- 623
						for _index_0 = 1, #files do -- 624
							local file = files[_index_0] -- 624
							if name == Path:getName(file):lower() then -- 625
								local _exp_0 = Path:getExt(file) -- 626
								if "tl" == _exp_0 then -- 626
									if ("vs" == ext) then -- 626
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 627
									end -- 626
								elseif "lua" == _exp_0 then -- 628
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 628
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 629
									end -- 628
								end -- 629
							end -- 625
						end -- 629
						return { -- 630
							success = true -- 630
						} -- 630
					end -- 616
				end -- 598
			end -- 597
		end -- 630
	end -- 630
	return { -- 596
		success = false -- 596
	} -- 630
end) -- 596
HttpServer:post("/exist", function(req) -- 632
	do -- 633
		local _type_0 = type(req) -- 633
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 633
		if _tab_0 then -- 633
			local file -- 633
			do -- 633
				local _obj_0 = req.body -- 633
				local _type_1 = type(_obj_0) -- 633
				if "table" == _type_1 or "userdata" == _type_1 then -- 633
					file = _obj_0.file -- 633
				end -- 642
			end -- 642
			if file ~= nil then -- 633
				do -- 634
					local projFile = req.body.projFile -- 634
					if projFile then -- 634
						local projDir = getProjectDirFromFile(projFile) -- 635
						if projDir then -- 635
							local scriptDir = Path(projDir, "Script") -- 636
							local searchPaths = Content.searchPaths -- 637
							if Content:exist(scriptDir) then -- 638
								Content:addSearchPath(scriptDir) -- 638
							end -- 638
							if Content:exist(projDir) then -- 639
								Content:addSearchPath(projDir) -- 639
							end -- 639
							local _ <close> = setmetatable({ }, { -- 640
								__close = function() -- 640
									Content.searchPaths = searchPaths -- 640
								end -- 640
							}) -- 640
							return { -- 641
								success = Content:exist(file) -- 641
							} -- 641
						end -- 635
					end -- 634
				end -- 634
				return { -- 642
					success = Content:exist(file) -- 642
				} -- 642
			end -- 633
		end -- 642
	end -- 642
	return { -- 632
		success = false -- 632
	} -- 642
end) -- 632
HttpServer:postSchedule("/read", function(req) -- 644
	do -- 645
		local _type_0 = type(req) -- 645
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 645
		if _tab_0 then -- 645
			local path -- 645
			do -- 645
				local _obj_0 = req.body -- 645
				local _type_1 = type(_obj_0) -- 645
				if "table" == _type_1 or "userdata" == _type_1 then -- 645
					path = _obj_0.path -- 645
				end -- 658
			end -- 658
			if path ~= nil then -- 645
				local readFile -- 646
				readFile = function() -- 646
					if Content:exist(path) then -- 647
						local content = Content:loadAsync(path) -- 648
						if content then -- 648
							return { -- 649
								content = content, -- 649
								success = true -- 649
							} -- 649
						end -- 648
					end -- 647
					return nil -- 649
				end -- 646
				do -- 650
					local projFile = req.body.projFile -- 650
					if projFile then -- 650
						local projDir = getProjectDirFromFile(projFile) -- 651
						if projDir then -- 651
							local scriptDir = Path(projDir, "Script") -- 652
							local searchPaths = Content.searchPaths -- 653
							if Content:exist(scriptDir) then -- 654
								Content:addSearchPath(scriptDir) -- 654
							end -- 654
							if Content:exist(projDir) then -- 655
								Content:addSearchPath(projDir) -- 655
							end -- 655
							local _ <close> = setmetatable({ }, { -- 656
								__close = function() -- 656
									Content.searchPaths = searchPaths -- 656
								end -- 656
							}) -- 656
							local result = readFile() -- 657
							if result then -- 657
								return result -- 657
							end -- 657
						end -- 651
					end -- 650
				end -- 650
				local result = readFile() -- 658
				if result then -- 658
					return result -- 658
				end -- 658
			end -- 645
		end -- 658
	end -- 658
	return { -- 644
		success = false -- 644
	} -- 658
end) -- 644
HttpServer:post("/read-sync", function(req) -- 660
	do -- 661
		local _type_0 = type(req) -- 661
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 661
		if _tab_0 then -- 661
			local path -- 661
			do -- 661
				local _obj_0 = req.body -- 661
				local _type_1 = type(_obj_0) -- 661
				if "table" == _type_1 or "userdata" == _type_1 then -- 661
					path = _obj_0.path -- 661
				end -- 676
			end -- 676
			local exts -- 661
			do -- 661
				local _obj_0 = req.body -- 661
				local _type_1 = type(_obj_0) -- 661
				if "table" == _type_1 or "userdata" == _type_1 then -- 661
					exts = _obj_0.exts -- 661
				end -- 676
			end -- 676
			if path ~= nil and exts ~= nil then -- 661
				local readFile -- 662
				readFile = function() -- 662
					for _index_0 = 1, #exts do -- 663
						local ext = exts[_index_0] -- 663
						local targetPath = path .. ext -- 664
						if Content:exist(targetPath) then -- 665
							local content = Content:load(targetPath) -- 666
							if content then -- 666
								return { -- 667
									content = content, -- 667
									success = true, -- 667
									fullPath = Content:getFullPath(targetPath) -- 667
								} -- 667
							end -- 666
						end -- 665
					end -- 667
					return nil -- 667
				end -- 662
				do -- 668
					local projFile = req.body.projFile -- 668
					if projFile then -- 668
						local projDir = getProjectDirFromFile(projFile) -- 669
						if projDir then -- 669
							local scriptDir = Path(projDir, "Script") -- 670
							local searchPaths = Content.searchPaths -- 671
							if Content:exist(scriptDir) then -- 672
								Content:addSearchPath(scriptDir) -- 672
							end -- 672
							if Content:exist(projDir) then -- 673
								Content:addSearchPath(projDir) -- 673
							end -- 673
							local _ <close> = setmetatable({ }, { -- 674
								__close = function() -- 674
									Content.searchPaths = searchPaths -- 674
								end -- 674
							}) -- 674
							local result = readFile() -- 675
							if result then -- 675
								return result -- 675
							end -- 675
						end -- 669
					end -- 668
				end -- 668
				local result = readFile() -- 676
				if result then -- 676
					return result -- 676
				end -- 676
			end -- 661
		end -- 676
	end -- 676
	return { -- 660
		success = false -- 660
	} -- 676
end) -- 660
local compileFileAsync -- 678
compileFileAsync = function(inputFile, sourceCodes) -- 678
	local file = inputFile -- 679
	local searchPath -- 680
	do -- 680
		local dir = getProjectDirFromFile(inputFile) -- 680
		if dir then -- 680
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 681
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 682
		else -- 684
			file = Path:getRelative(inputFile, Content.writablePath) -- 684
			if file:sub(1, 2) == ".." then -- 685
				file = Path:getRelative(inputFile, Content.assetPath) -- 686
			end -- 685
			searchPath = "" -- 687
		end -- 680
	end -- 680
	local outputFile = Path:replaceExt(inputFile, "lua") -- 688
	local yueext = yue.options.extension -- 689
	local resultCodes = nil -- 690
	do -- 691
		local _exp_0 = Path:getExt(inputFile) -- 691
		if yueext == _exp_0 then -- 691
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 692
				if not codes then -- 693
					return -- 693
				end -- 693
				local success, result = LintYueGlobals(codes, globals) -- 694
				if not success then -- 695
					return -- 695
				end -- 695
				if codes == "" then -- 696
					resultCodes = "" -- 697
					return nil -- 698
				end -- 696
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 699
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 700
				codes = codes:gsub("^\n*", "") -- 701
				if not (result == "") then -- 702
					result = result .. "\n" -- 702
				end -- 702
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 703
				return resultCodes -- 704
			end, function(success) -- 692
				if not success then -- 705
					Content:remove(outputFile) -- 706
					if resultCodes == nil then -- 707
						resultCodes = false -- 708
					end -- 707
				end -- 705
			end) -- 692
		elseif "tl" == _exp_0 then -- 709
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 710
			if codes then -- 710
				resultCodes = codes -- 711
				Content:saveAsync(outputFile, codes) -- 712
			else -- 714
				Content:remove(outputFile) -- 714
				resultCodes = false -- 715
			end -- 710
		elseif "xml" == _exp_0 then -- 716
			local codes = xml.tolua(sourceCodes) -- 717
			if codes then -- 717
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 718
				Content:saveAsync(outputFile, resultCodes) -- 719
			else -- 721
				Content:remove(outputFile) -- 721
				resultCodes = false -- 722
			end -- 717
		end -- 722
	end -- 722
	wait(function() -- 723
		return resultCodes ~= nil -- 723
	end) -- 723
	if resultCodes then -- 724
		return resultCodes -- 724
	end -- 724
	return nil -- 724
end -- 678
HttpServer:postSchedule("/write", function(req) -- 726
	do -- 727
		local _type_0 = type(req) -- 727
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 727
		if _tab_0 then -- 727
			local path -- 727
			do -- 727
				local _obj_0 = req.body -- 727
				local _type_1 = type(_obj_0) -- 727
				if "table" == _type_1 or "userdata" == _type_1 then -- 727
					path = _obj_0.path -- 727
				end -- 733
			end -- 733
			local content -- 727
			do -- 727
				local _obj_0 = req.body -- 727
				local _type_1 = type(_obj_0) -- 727
				if "table" == _type_1 or "userdata" == _type_1 then -- 727
					content = _obj_0.content -- 727
				end -- 733
			end -- 733
			if path ~= nil and content ~= nil then -- 727
				if Content:saveAsync(path, content) then -- 728
					do -- 729
						local _exp_0 = Path:getExt(path) -- 729
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 729
							if '' == Path:getExt(Path:getName(path)) then -- 730
								local resultCodes = compileFileAsync(path, content) -- 731
								return { -- 732
									success = true, -- 732
									resultCodes = resultCodes -- 732
								} -- 732
							end -- 730
						end -- 732
					end -- 732
					return { -- 733
						success = true -- 733
					} -- 733
				end -- 728
			end -- 727
		end -- 733
	end -- 733
	return { -- 726
		success = false -- 726
	} -- 733
end) -- 726
HttpServer:postSchedule("/build", function(req) -- 735
	do -- 736
		local _type_0 = type(req) -- 736
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 736
		if _tab_0 then -- 736
			local path -- 736
			do -- 736
				local _obj_0 = req.body -- 736
				local _type_1 = type(_obj_0) -- 736
				if "table" == _type_1 or "userdata" == _type_1 then -- 736
					path = _obj_0.path -- 736
				end -- 741
			end -- 741
			if path ~= nil then -- 736
				local _exp_0 = Path:getExt(path) -- 737
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 737
					if '' == Path:getExt(Path:getName(path)) then -- 738
						local content = Content:loadAsync(path) -- 739
						if content then -- 739
							local resultCodes = compileFileAsync(path, content) -- 740
							if resultCodes then -- 740
								return { -- 741
									success = true, -- 741
									resultCodes = resultCodes -- 741
								} -- 741
							end -- 740
						end -- 739
					end -- 738
				end -- 741
			end -- 736
		end -- 741
	end -- 741
	return { -- 735
		success = false -- 735
	} -- 741
end) -- 735
local extentionLevels = { -- 744
	vs = 2, -- 744
	bl = 2, -- 745
	ts = 1, -- 746
	tsx = 1, -- 747
	tl = 1, -- 748
	yue = 1, -- 749
	xml = 1, -- 750
	lua = 0 -- 751
} -- 743
HttpServer:post("/assets", function() -- 753
	local Entry = require("Script.Dev.Entry") -- 756
	local engineDev = Entry.getEngineDev() -- 757
	local visitAssets -- 758
	visitAssets = function(path, tag) -- 758
		local isWorkspace = tag == "Workspace" -- 759
		local builtin -- 760
		if tag == "Builtin" then -- 760
			builtin = true -- 760
		else -- 760
			builtin = nil -- 760
		end -- 760
		local children = nil -- 761
		local dirs = Content:getDirs(path) -- 762
		for _index_0 = 1, #dirs do -- 763
			local dir = dirs[_index_0] -- 763
			if isWorkspace then -- 764
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 765
					goto _continue_0 -- 766
				end -- 765
			elseif dir == ".git" then -- 767
				goto _continue_0 -- 768
			end -- 764
			if not children then -- 769
				children = { } -- 769
			end -- 769
			children[#children + 1] = visitAssets(Path(path, dir)) -- 770
			::_continue_0:: -- 764
		end -- 770
		local files = Content:getFiles(path) -- 771
		local names = { } -- 772
		for _index_0 = 1, #files do -- 773
			local file = files[_index_0] -- 773
			if file:match("^%.") then -- 774
				goto _continue_1 -- 774
			end -- 774
			local name = Path:getName(file) -- 775
			local ext = names[name] -- 776
			if ext then -- 776
				local lv1 -- 777
				do -- 777
					local _exp_0 = extentionLevels[ext] -- 777
					if _exp_0 ~= nil then -- 777
						lv1 = _exp_0 -- 777
					else -- 777
						lv1 = -1 -- 777
					end -- 777
				end -- 777
				ext = Path:getExt(file) -- 778
				local lv2 -- 779
				do -- 779
					local _exp_0 = extentionLevels[ext] -- 779
					if _exp_0 ~= nil then -- 779
						lv2 = _exp_0 -- 779
					else -- 779
						lv2 = -1 -- 779
					end -- 779
				end -- 779
				if lv2 > lv1 then -- 780
					names[name] = ext -- 781
				elseif lv2 == lv1 then -- 782
					names[name .. '.' .. ext] = "" -- 783
				end -- 780
			else -- 785
				ext = Path:getExt(file) -- 785
				if not extentionLevels[ext] then -- 786
					names[file] = "" -- 787
				else -- 789
					names[name] = ext -- 789
				end -- 786
			end -- 776
			::_continue_1:: -- 774
		end -- 789
		do -- 790
			local _accum_0 = { } -- 790
			local _len_0 = 1 -- 790
			for name, ext in pairs(names) do -- 790
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 790
				_len_0 = _len_0 + 1 -- 790
			end -- 790
			files = _accum_0 -- 790
		end -- 790
		for _index_0 = 1, #files do -- 791
			local file = files[_index_0] -- 791
			if not children then -- 792
				children = { } -- 792
			end -- 792
			children[#children + 1] = { -- 794
				key = Path(path, file), -- 794
				dir = false, -- 795
				title = file, -- 796
				builtin = builtin -- 797
			} -- 793
		end -- 798
		if children then -- 799
			table.sort(children, function(a, b) -- 800
				if a.dir == b.dir then -- 801
					return a.title < b.title -- 802
				else -- 804
					return a.dir -- 804
				end -- 801
			end) -- 800
		end -- 799
		if isWorkspace and children then -- 805
			return children -- 806
		else -- 808
			return { -- 809
				key = path, -- 809
				dir = true, -- 810
				title = Path:getFilename(path), -- 811
				builtin = builtin, -- 812
				children = children -- 813
			} -- 814
		end -- 805
	end -- 758
	local zh = (App.locale:match("^zh") ~= nil) -- 815
	return { -- 817
		key = Content.writablePath, -- 817
		dir = true, -- 818
		root = true, -- 819
		title = "Assets", -- 820
		children = (function() -- 822
			local _tab_0 = { -- 822
				{ -- 823
					key = Path(Content.assetPath), -- 823
					dir = true, -- 824
					builtin = true, -- 825
					title = zh and "内置资源" or "Built-in", -- 826
					children = { -- 828
						(function() -- 828
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 828
							_with_0.title = zh and "说明文档" or "Readme" -- 829
							return _with_0 -- 828
						end)(), -- 828
						(function() -- 830
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 830
							_with_0.title = zh and "接口文档" or "API Doc" -- 831
							return _with_0 -- 830
						end)(), -- 830
						(function() -- 832
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 832
							_with_0.title = zh and "开发工具" or "Tools" -- 833
							return _with_0 -- 832
						end)(), -- 832
						(function() -- 834
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Example")), "Builtin") -- 834
							_with_0.title = zh and "代码示例" or "Example" -- 835
							return _with_0 -- 834
						end)(), -- 834
						(function() -- 836
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Game")), "Builtin") -- 836
							_with_0.title = zh and "游戏演示" or "Demo Game" -- 837
							return _with_0 -- 836
						end)(), -- 836
						(function() -- 838
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Test")), "Builtin") -- 838
							_with_0.title = zh and "功能测试" or "Test" -- 839
							return _with_0 -- 838
						end)(), -- 838
						visitAssets((Path(Content.assetPath, "Image")), "Builtin"), -- 840
						visitAssets((Path(Content.assetPath, "Spine")), "Builtin"), -- 841
						visitAssets((Path(Content.assetPath, "Font")), "Builtin"), -- 842
						(function() -- 843
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 843
							if engineDev then -- 844
								local _list_0 = _with_0.children -- 845
								for _index_0 = 1, #_list_0 do -- 845
									local child = _list_0[_index_0] -- 845
									if not (child.title == "Dora") then -- 846
										goto _continue_0 -- 846
									end -- 846
									local title = zh and "zh-Hans" or "en" -- 847
									do -- 848
										local _accum_0 = { } -- 848
										local _len_0 = 1 -- 848
										local _list_1 = child.children -- 848
										for _index_1 = 1, #_list_1 do -- 848
											local c = _list_1[_index_1] -- 848
											if c.title ~= title then -- 848
												_accum_0[_len_0] = c -- 848
												_len_0 = _len_0 + 1 -- 848
											end -- 848
										end -- 848
										child.children = _accum_0 -- 848
									end -- 848
									break -- 849
									::_continue_0:: -- 846
								end -- 849
							else -- 851
								local _accum_0 = { } -- 851
								local _len_0 = 1 -- 851
								local _list_0 = _with_0.children -- 851
								for _index_0 = 1, #_list_0 do -- 851
									local child = _list_0[_index_0] -- 851
									if child.title ~= "Dora" then -- 851
										_accum_0[_len_0] = child -- 851
										_len_0 = _len_0 + 1 -- 851
									end -- 851
								end -- 851
								_with_0.children = _accum_0 -- 851
							end -- 844
							return _with_0 -- 843
						end)(), -- 843
						(function() -- 852
							if engineDev then -- 852
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 853
								local _obj_0 = _with_0.children -- 854
								_obj_0[#_obj_0 + 1] = { -- 855
									key = Path(Content.assetPath, "Script", "init.yue"), -- 855
									dir = false, -- 856
									builtin = true, -- 857
									title = "init.yue" -- 858
								} -- 854
								return _with_0 -- 853
							end -- 852
						end)() -- 852
					} -- 827
				} -- 822
			} -- 862
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 862
			local _idx_0 = #_tab_0 + 1 -- 862
			for _index_0 = 1, #_obj_0 do -- 862
				local _value_0 = _obj_0[_index_0] -- 862
				_tab_0[_idx_0] = _value_0 -- 862
				_idx_0 = _idx_0 + 1 -- 862
			end -- 862
			return _tab_0 -- 861
		end)() -- 821
	} -- 864
end) -- 753
HttpServer:postSchedule("/run", function(req) -- 866
	do -- 867
		local _type_0 = type(req) -- 867
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 867
		if _tab_0 then -- 867
			local file -- 867
			do -- 867
				local _obj_0 = req.body -- 867
				local _type_1 = type(_obj_0) -- 867
				if "table" == _type_1 or "userdata" == _type_1 then -- 867
					file = _obj_0.file -- 867
				end -- 882
			end -- 882
			local asProj -- 867
			do -- 867
				local _obj_0 = req.body -- 867
				local _type_1 = type(_obj_0) -- 867
				if "table" == _type_1 or "userdata" == _type_1 then -- 867
					asProj = _obj_0.asProj -- 867
				end -- 882
			end -- 882
			if file ~= nil and asProj ~= nil then -- 867
				if not Content:isAbsolutePath(file) then -- 868
					local devFile = Path(Content.writablePath, file) -- 869
					if Content:exist(devFile) then -- 870
						file = devFile -- 870
					end -- 870
				end -- 868
				local Entry = require("Script.Dev.Entry") -- 871
				if asProj then -- 872
					local proj = getProjectDirFromFile(file) -- 873
					if proj then -- 873
						Entry.allClear() -- 874
						local target = Path(proj, "init") -- 875
						local success, err = Entry.enterEntryAsync({ -- 876
							"Project", -- 876
							target -- 876
						}) -- 876
						target = Path:getName(Path:getPath(target)) -- 877
						return { -- 878
							success = success, -- 878
							target = target, -- 878
							err = err -- 878
						} -- 878
					end -- 873
				end -- 872
				Entry.allClear() -- 879
				file = Path:replaceExt(file, "") -- 880
				local success, err = Entry.enterEntryAsync({ -- 881
					Path:getName(file), -- 881
					file -- 881
				}) -- 881
				return { -- 882
					success = success, -- 882
					err = err -- 882
				} -- 882
			end -- 867
		end -- 882
	end -- 882
	return { -- 866
		success = false -- 866
	} -- 882
end) -- 866
HttpServer:postSchedule("/stop", function() -- 884
	local Entry = require("Script.Dev.Entry") -- 885
	return { -- 886
		success = Entry.stop() -- 886
	} -- 886
end) -- 884
local minifyAsync -- 888
minifyAsync = function(sourcePath, minifyPath) -- 888
	if not Content:exist(sourcePath) then -- 889
		return -- 889
	end -- 889
	local Entry = require("Script.Dev.Entry") -- 890
	local errors = { } -- 891
	local files = Entry.getAllFiles(sourcePath, { -- 892
		"lua" -- 892
	}, true) -- 892
	do -- 893
		local _accum_0 = { } -- 893
		local _len_0 = 1 -- 893
		for _index_0 = 1, #files do -- 893
			local file = files[_index_0] -- 893
			if file:sub(1, 1) ~= '.' then -- 893
				_accum_0[_len_0] = file -- 893
				_len_0 = _len_0 + 1 -- 893
			end -- 893
		end -- 893
		files = _accum_0 -- 893
	end -- 893
	local paths -- 894
	do -- 894
		local _tbl_0 = { } -- 894
		for _index_0 = 1, #files do -- 894
			local file = files[_index_0] -- 894
			_tbl_0[Path:getPath(file)] = true -- 894
		end -- 894
		paths = _tbl_0 -- 894
	end -- 894
	for path in pairs(paths) do -- 895
		Content:mkdir(Path(minifyPath, path)) -- 895
	end -- 895
	local _ <close> = setmetatable({ }, { -- 896
		__close = function() -- 896
			package.loaded["luaminify.FormatMini"] = nil -- 897
			package.loaded["luaminify.ParseLua"] = nil -- 898
			package.loaded["luaminify.Scope"] = nil -- 899
			package.loaded["luaminify.Util"] = nil -- 900
		end -- 896
	}) -- 896
	local FormatMini -- 901
	do -- 901
		local _obj_0 = require("luaminify") -- 901
		FormatMini = _obj_0.FormatMini -- 901
	end -- 901
	local fileCount = #files -- 902
	local count = 0 -- 903
	for _index_0 = 1, #files do -- 904
		local file = files[_index_0] -- 904
		thread(function() -- 905
			local _ <close> = setmetatable({ }, { -- 906
				__close = function() -- 906
					count = count + 1 -- 906
				end -- 906
			}) -- 906
			local input = Path(sourcePath, file) -- 907
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 908
			if Content:exist(input) then -- 909
				local sourceCodes = Content:loadAsync(input) -- 910
				local res, err = FormatMini(sourceCodes) -- 911
				if res then -- 912
					Content:saveAsync(output, res) -- 913
					return print("Minify " .. tostring(file)) -- 914
				else -- 916
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 916
				end -- 912
			else -- 918
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 918
			end -- 909
		end) -- 905
		sleep() -- 919
	end -- 919
	wait(function() -- 920
		return count == fileCount -- 920
	end) -- 920
	if #errors > 0 then -- 921
		print(table.concat(errors, '\n')) -- 922
	end -- 921
	print("Obfuscation done.") -- 923
	return files -- 924
end -- 888
local zipping = false -- 926
HttpServer:postSchedule("/zip", function(req) -- 928
	do -- 929
		local _type_0 = type(req) -- 929
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 929
		if _tab_0 then -- 929
			local path -- 929
			do -- 929
				local _obj_0 = req.body -- 929
				local _type_1 = type(_obj_0) -- 929
				if "table" == _type_1 or "userdata" == _type_1 then -- 929
					path = _obj_0.path -- 929
				end -- 958
			end -- 958
			local zipFile -- 929
			do -- 929
				local _obj_0 = req.body -- 929
				local _type_1 = type(_obj_0) -- 929
				if "table" == _type_1 or "userdata" == _type_1 then -- 929
					zipFile = _obj_0.zipFile -- 929
				end -- 958
			end -- 958
			local obfuscated -- 929
			do -- 929
				local _obj_0 = req.body -- 929
				local _type_1 = type(_obj_0) -- 929
				if "table" == _type_1 or "userdata" == _type_1 then -- 929
					obfuscated = _obj_0.obfuscated -- 929
				end -- 958
			end -- 958
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 929
				if zipping then -- 930
					goto failed -- 930
				end -- 930
				zipping = true -- 931
				local _ <close> = setmetatable({ }, { -- 932
					__close = function() -- 932
						zipping = false -- 932
					end -- 932
				}) -- 932
				if not Content:exist(path) then -- 933
					goto failed -- 933
				end -- 933
				Content:mkdir(Path:getPath(zipFile)) -- 934
				if obfuscated then -- 935
					local scriptPath = Path(Content.appPath, ".download", ".script") -- 936
					local obfuscatedPath = Path(Content.appPath, ".download", ".obfuscated") -- 937
					local tempPath = Path(Content.appPath, ".download", ".temp") -- 938
					Content:remove(scriptPath) -- 939
					Content:remove(obfuscatedPath) -- 940
					Content:remove(tempPath) -- 941
					Content:mkdir(scriptPath) -- 942
					Content:mkdir(obfuscatedPath) -- 943
					Content:mkdir(tempPath) -- 944
					if not Content:copyAsync(path, tempPath) then -- 945
						goto failed -- 945
					end -- 945
					local Entry = require("Script.Dev.Entry") -- 946
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 947
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 948
						"tl", -- 948
						"yue", -- 948
						"lua", -- 948
						"ts", -- 948
						"tsx", -- 948
						"vs", -- 948
						"bl", -- 948
						"xml", -- 948
						"wa", -- 948
						"mod" -- 948
					}, true) -- 948
					for _index_0 = 1, #scriptFiles do -- 949
						local file = scriptFiles[_index_0] -- 949
						Content:remove(Path(tempPath, file)) -- 950
					end -- 950
					for _index_0 = 1, #luaFiles do -- 951
						local file = luaFiles[_index_0] -- 951
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 952
					end -- 952
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 953
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 954
					end) then -- 953
						goto failed -- 953
					end -- 953
					return { -- 955
						success = true -- 955
					} -- 955
				else -- 957
					return { -- 957
						success = Content:zipAsync(path, zipFile, function(file) -- 957
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 958
						end) -- 957
					} -- 958
				end -- 935
			end -- 929
		end -- 958
	end -- 958
	::failed:: -- 959
	return { -- 928
		success = false -- 928
	} -- 959
end) -- 928
HttpServer:postSchedule("/unzip", function(req) -- 961
	do -- 962
		local _type_0 = type(req) -- 962
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 962
		if _tab_0 then -- 962
			local zipFile -- 962
			do -- 962
				local _obj_0 = req.body -- 962
				local _type_1 = type(_obj_0) -- 962
				if "table" == _type_1 or "userdata" == _type_1 then -- 962
					zipFile = _obj_0.zipFile -- 962
				end -- 964
			end -- 964
			local path -- 962
			do -- 962
				local _obj_0 = req.body -- 962
				local _type_1 = type(_obj_0) -- 962
				if "table" == _type_1 or "userdata" == _type_1 then -- 962
					path = _obj_0.path -- 962
				end -- 964
			end -- 964
			if zipFile ~= nil and path ~= nil then -- 962
				return { -- 963
					success = Content:unzipAsync(zipFile, path, function(file) -- 963
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 964
					end) -- 963
				} -- 964
			end -- 962
		end -- 964
	end -- 964
	return { -- 961
		success = false -- 961
	} -- 964
end) -- 961
HttpServer:post("/editingInfo", function(req) -- 966
	local Entry = require("Script.Dev.Entry") -- 967
	local config = Entry.getConfig() -- 968
	local _type_0 = type(req) -- 969
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 969
	local _match_0 = false -- 969
	if _tab_0 then -- 969
		local editingInfo -- 969
		do -- 969
			local _obj_0 = req.body -- 969
			local _type_1 = type(_obj_0) -- 969
			if "table" == _type_1 or "userdata" == _type_1 then -- 969
				editingInfo = _obj_0.editingInfo -- 969
			end -- 971
		end -- 971
		if editingInfo ~= nil then -- 969
			_match_0 = true -- 969
			config.editingInfo = editingInfo -- 970
			return { -- 971
				success = true -- 971
			} -- 971
		end -- 969
	end -- 969
	if not _match_0 then -- 969
		if not (config.editingInfo ~= nil) then -- 973
			local folder -- 974
			if App.locale:match('^zh') then -- 974
				folder = 'zh-Hans' -- 974
			else -- 974
				folder = 'en' -- 974
			end -- 974
			config.editingInfo = json.dump({ -- 976
				index = 0, -- 976
				files = { -- 978
					{ -- 979
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 979
						title = "welcome.md" -- 980
					} -- 978
				} -- 977
			}) -- 975
		end -- 973
		return { -- 984
			success = true, -- 984
			editingInfo = config.editingInfo -- 984
		} -- 984
	end -- 984
end) -- 966
HttpServer:post("/command", function(req) -- 986
	do -- 987
		local _type_0 = type(req) -- 987
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 987
		if _tab_0 then -- 987
			local code -- 987
			do -- 987
				local _obj_0 = req.body -- 987
				local _type_1 = type(_obj_0) -- 987
				if "table" == _type_1 or "userdata" == _type_1 then -- 987
					code = _obj_0.code -- 987
				end -- 989
			end -- 989
			local log -- 987
			do -- 987
				local _obj_0 = req.body -- 987
				local _type_1 = type(_obj_0) -- 987
				if "table" == _type_1 or "userdata" == _type_1 then -- 987
					log = _obj_0.log -- 987
				end -- 989
			end -- 989
			if code ~= nil and log ~= nil then -- 987
				emit("AppCommand", code, log) -- 988
				return { -- 989
					success = true -- 989
				} -- 989
			end -- 987
		end -- 989
	end -- 989
	return { -- 986
		success = false -- 986
	} -- 989
end) -- 986
HttpServer:post("/saveLog", function() -- 991
	local folder = ".download" -- 992
	local fullLogFile = "dora_full_logs.txt" -- 993
	local fullFolder = Path(Content.appPath, folder) -- 994
	Content:mkdir(fullFolder) -- 995
	local logPath = Path(fullFolder, fullLogFile) -- 996
	if App:saveLog(logPath) then -- 997
		return { -- 998
			success = true, -- 998
			path = Path(folder, fullLogFile) -- 998
		} -- 998
	end -- 997
	return { -- 991
		success = false -- 991
	} -- 998
end) -- 991
HttpServer:post("/checkYarn", function(req) -- 1000
	local yarncompile = require("yarncompile") -- 1001
	do -- 1002
		local _type_0 = type(req) -- 1002
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1002
		if _tab_0 then -- 1002
			local code -- 1002
			do -- 1002
				local _obj_0 = req.body -- 1002
				local _type_1 = type(_obj_0) -- 1002
				if "table" == _type_1 or "userdata" == _type_1 then -- 1002
					code = _obj_0.code -- 1002
				end -- 1009
			end -- 1009
			if code ~= nil then -- 1002
				local jsonObject = json.load(code) -- 1003
				if jsonObject then -- 1003
					local errors = { } -- 1004
					local _list_0 = jsonObject.nodes -- 1005
					for _index_0 = 1, #_list_0 do -- 1005
						local node = _list_0[_index_0] -- 1005
						local title, body = node.title, node.body -- 1006
						local luaCode, err = yarncompile(body) -- 1007
						if not luaCode then -- 1007
							errors[#errors + 1] = title .. ":" .. err -- 1008
						end -- 1007
					end -- 1008
					return { -- 1009
						success = true, -- 1009
						syntaxError = table.concat(errors, "\n\n") -- 1009
					} -- 1009
				end -- 1003
			end -- 1002
		end -- 1009
	end -- 1009
	return { -- 1000
		success = false -- 1000
	} -- 1009
end) -- 1000
local getWaProjectDirFromFile -- 1011
getWaProjectDirFromFile = function(file) -- 1011
	local writablePath = Content.writablePath -- 1012
	local parent, current -- 1013
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1013
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1014
	else -- 1016
		parent, current = nil, nil -- 1016
	end -- 1013
	if not current then -- 1017
		return nil -- 1017
	end -- 1017
	repeat -- 1018
		current = Path:getPath(current) -- 1019
		if current == "" then -- 1020
			break -- 1020
		end -- 1020
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1021
		for _index_0 = 1, #_list_0 do -- 1021
			local f = _list_0[_index_0] -- 1021
			if Path:getFilename(f):lower() == "wa.mod" then -- 1022
				return Path(parent, current, Path:getPath(f)) -- 1023
			end -- 1022
		end -- 1023
	until false -- 1024
	return nil -- 1025
end -- 1011
HttpServer:postSchedule("/buildWa", function(req) -- 1027
	do -- 1028
		local _type_0 = type(req) -- 1028
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1028
		if _tab_0 then -- 1028
			local path -- 1028
			do -- 1028
				local _obj_0 = req.body -- 1028
				local _type_1 = type(_obj_0) -- 1028
				if "table" == _type_1 or "userdata" == _type_1 then -- 1028
					path = _obj_0.path -- 1028
				end -- 1036
			end -- 1036
			if path ~= nil then -- 1028
				local projDir = getWaProjectDirFromFile(path) -- 1029
				if projDir then -- 1029
					local message = Wasm:buildWaAsync(projDir) -- 1030
					if message == "" then -- 1031
						return { -- 1032
							success = true -- 1032
						} -- 1032
					else -- 1034
						return { -- 1034
							success = false, -- 1034
							message = message -- 1034
						} -- 1034
					end -- 1031
				else -- 1036
					return { -- 1036
						success = false, -- 1036
						message = 'Wa file needs a project' -- 1036
					} -- 1036
				end -- 1029
			end -- 1028
		end -- 1036
	end -- 1036
	return { -- 1037
		success = false, -- 1037
		message = 'failed to build' -- 1037
	} -- 1037
end) -- 1027
HttpServer:postSchedule("/formatWa", function(req) -- 1039
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
				end -- 1045
			end -- 1045
			if file ~= nil then -- 1040
				local code = Wasm:formatWaAsync(file) -- 1041
				if code == "" then -- 1042
					return { -- 1043
						success = false -- 1043
					} -- 1043
				else -- 1045
					return { -- 1045
						success = true, -- 1045
						code = code -- 1045
					} -- 1045
				end -- 1042
			end -- 1040
		end -- 1045
	end -- 1045
	return { -- 1046
		success = false -- 1046
	} -- 1046
end) -- 1039
HttpServer:postSchedule("/createWa", function(req) -- 1048
	do -- 1049
		local _type_0 = type(req) -- 1049
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1049
		if _tab_0 then -- 1049
			local path -- 1049
			do -- 1049
				local _obj_0 = req.body -- 1049
				local _type_1 = type(_obj_0) -- 1049
				if "table" == _type_1 or "userdata" == _type_1 then -- 1049
					path = _obj_0.path -- 1049
				end -- 1072
			end -- 1072
			if path ~= nil then -- 1049
				if not Content:exist(Path:getPath(path)) then -- 1050
					return { -- 1051
						success = false, -- 1051
						message = "target path not existed" -- 1051
					} -- 1051
				end -- 1050
				if Content:exist(path) then -- 1052
					return { -- 1053
						success = false, -- 1053
						message = "target project folder existed" -- 1053
					} -- 1053
				end -- 1052
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1054
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1055
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1056
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1057
					return { -- 1060
						success = false, -- 1060
						message = "missing template project" -- 1060
					} -- 1060
				end -- 1057
				if not Content:mkdir(path) then -- 1061
					return { -- 1062
						success = false, -- 1062
						message = "failed to create project folder" -- 1062
					} -- 1062
				end -- 1061
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1063
					Content:remove(path) -- 1064
					return { -- 1065
						success = false, -- 1065
						message = "failed to copy template" -- 1065
					} -- 1065
				end -- 1063
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1066
					Content:remove(path) -- 1067
					return { -- 1068
						success = false, -- 1068
						message = "failed to copy template" -- 1068
					} -- 1068
				end -- 1066
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1069
					Content:remove(path) -- 1070
					return { -- 1071
						success = false, -- 1071
						message = "failed to copy template" -- 1071
					} -- 1071
				end -- 1069
				return { -- 1072
					success = true -- 1072
				} -- 1072
			end -- 1049
		end -- 1072
	end -- 1072
	return { -- 1048
		success = false, -- 1048
		message = "invalid call" -- 1048
	} -- 1072
end) -- 1048
local status = { } -- 1074
_module_0 = status -- 1075
thread(function() -- 1077
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1078
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1079
	if Content:exist(doraWeb) then -- 1080
		local needReload -- 1081
		if Content:exist(doraReady) then -- 1081
			needReload = App.version ~= Content:load(doraReady) -- 1082
		else -- 1083
			needReload = true -- 1083
		end -- 1081
		if needReload then -- 1084
			Content:remove(Path(Content.appPath, ".www")) -- 1085
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1086
			Content:save(doraReady, App.version) -- 1090
			print("Dora Dora is ready!") -- 1091
		end -- 1084
	end -- 1080
	if HttpServer:start(8866) then -- 1092
		local localIP = HttpServer.localIP -- 1093
		if localIP == "" then -- 1094
			localIP = "localhost" -- 1094
		end -- 1094
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1095
		return HttpServer:startWS(8868) -- 1096
	else -- 1098
		status.url = nil -- 1098
		return print("8866 Port not available!") -- 1099
	end -- 1092
end) -- 1077
return _module_0 -- 1099
