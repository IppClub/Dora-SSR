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
local Node = Dora.Node -- 1
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
		end -- 30
	until false -- 27
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
	return "" -- 36
end -- 36
local getSearchFolders -- 40
getSearchFolders = function(file) -- 40
	do -- 41
		local dir = getProjectDirFromFile(file) -- 41
		if dir then -- 41
			return { -- 43
				Path(dir, "Script"), -- 43
				dir -- 44
			} -- 42
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
		end -- 75
	end -- 74
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
			end -- 85
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
					end -- 99
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
					end -- 103
				end -- 103
				_accum_0[_len_0] = item -- 108
				_len_0 = _len_0 + 1 -- 97
				::_continue_0:: -- 97
			end -- 96
			info = _accum_0 -- 96
		end -- 96
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
		end -- 121
		local _list_0 = res.info -- 127
		for _index_0 = 1, #_list_0 do -- 127
			local item = _list_0[_index_0] -- 127
			item[3] = lineMap[item[3]] or 0 -- 128
			item[4] = 0 -- 129
			info[#info + 1] = item -- 130
		end -- 127
		return false, info -- 131
	end -- 117
	return true, info -- 132
end -- 114
local getCompiledYueLine -- 134
getCompiledYueLine = function(content, line, row, file, lax) -- 134
	local luaCodes = yueCheck(file, content, lax) -- 135
	if not luaCodes then -- 136
		return nil -- 136
	end -- 136
	local current = 1 -- 137
	local lastLine = 1 -- 138
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 139
	local targetRow = nil -- 140
	local lineMap = { } -- 141
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 142
		local num = lineCode:match("--%s*(%d+)%s*$") -- 143
		if num then -- 144
			lastLine = tonumber(num) -- 144
		end -- 144
		lineMap[current] = lastLine -- 145
		if row <= lastLine and not targetRow then -- 146
			targetRow = current -- 147
			break -- 148
		end -- 146
		current = current + 1 -- 149
	end -- 142
	targetRow = current -- 150
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
				end -- 157
			end -- 157
			local content -- 157
			do -- 157
				local _obj_0 = req.body -- 157
				local _type_1 = type(_obj_0) -- 157
				if "table" == _type_1 or "userdata" == _type_1 then -- 157
					content = _obj_0.content -- 157
				end -- 157
			end -- 157
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
							end -- 185
							info = _accum_0 -- 185
						end -- 185
						return { -- 187
							success = false, -- 187
							info = info -- 187
						} -- 187
					end -- 178
				end -- 159
			end -- 157
		end -- 157
	end -- 157
	return { -- 156
		success = true -- 156
	} -- 156
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
		end -- 196
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
				end -- 210
			end -- 210
			local file -- 210
			do -- 210
				local _obj_0 = req.body -- 210
				local _type_1 = type(_obj_0) -- 210
				if "table" == _type_1 or "userdata" == _type_1 then -- 210
					file = _obj_0.file -- 210
				end -- 210
			end -- 210
			local content -- 210
			do -- 210
				local _obj_0 = req.body -- 210
				local _type_1 = type(_obj_0) -- 210
				if "table" == _type_1 or "userdata" == _type_1 then -- 210
					content = _obj_0.content -- 210
				end -- 210
			end -- 210
			local line -- 210
			do -- 210
				local _obj_0 = req.body -- 210
				local _type_1 = type(_obj_0) -- 210
				if "table" == _type_1 or "userdata" == _type_1 then -- 210
					line = _obj_0.line -- 210
				end -- 210
			end -- 210
			local row -- 210
			do -- 210
				local _obj_0 = req.body -- 210
				local _type_1 = type(_obj_0) -- 210
				if "table" == _type_1 or "userdata" == _type_1 then -- 210
					row = _obj_0.row -- 210
				end -- 210
			end -- 210
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
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 218
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
				end -- 212
			end -- 210
		end -- 210
	end -- 210
	return { -- 209
		success = false -- 209
	} -- 209
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
				end -- 239
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
			end -- 236
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
			end -- 275
			if #results > 0 then -- 285
				return results -- 285
			else -- 285
				return nil -- 285
			end -- 285
		end -- 230
	end -- 230
	return nil -- 229
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
				end -- 288
			end -- 288
			local file -- 288
			do -- 288
				local _obj_0 = req.body -- 288
				local _type_1 = type(_obj_0) -- 288
				if "table" == _type_1 or "userdata" == _type_1 then -- 288
					file = _obj_0.file -- 288
				end -- 288
			end -- 288
			local content -- 288
			do -- 288
				local _obj_0 = req.body -- 288
				local _type_1 = type(_obj_0) -- 288
				if "table" == _type_1 or "userdata" == _type_1 then -- 288
					content = _obj_0.content -- 288
				end -- 288
			end -- 288
			local line -- 288
			do -- 288
				local _obj_0 = req.body -- 288
				local _type_1 = type(_obj_0) -- 288
				if "table" == _type_1 or "userdata" == _type_1 then -- 288
					line = _obj_0.line -- 288
				end -- 288
			end -- 288
			local row -- 288
			do -- 288
				local _obj_0 = req.body -- 288
				local _type_1 = type(_obj_0) -- 288
				if "table" == _type_1 or "userdata" == _type_1 then -- 288
					row = _obj_0.row -- 288
				end -- 288
			end -- 288
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
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 295
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
				end -- 290
			end -- 288
		end -- 288
	end -- 288
	return { -- 287
		success = false -- 287
	} -- 287
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
				end -- 387
			end -- 387
			local file -- 387
			do -- 387
				local _obj_0 = req.body -- 387
				local _type_1 = type(_obj_0) -- 387
				if "table" == _type_1 or "userdata" == _type_1 then -- 387
					file = _obj_0.file -- 387
				end -- 387
			end -- 387
			local content -- 387
			do -- 387
				local _obj_0 = req.body -- 387
				local _type_1 = type(_obj_0) -- 387
				if "table" == _type_1 or "userdata" == _type_1 then -- 387
					content = _obj_0.content -- 387
				end -- 387
			end -- 387
			local line -- 387
			do -- 387
				local _obj_0 = req.body -- 387
				local _type_1 = type(_obj_0) -- 387
				if "table" == _type_1 or "userdata" == _type_1 then -- 387
					line = _obj_0.line -- 387
				end -- 387
			end -- 387
			local row -- 387
			do -- 387
				local _obj_0 = req.body -- 387
				local _type_1 = type(_obj_0) -- 387
				if "table" == _type_1 or "userdata" == _type_1 then -- 387
					row = _obj_0.row -- 387
				end -- 387
			end -- 387
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
					end -- 407
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
								end -- 418
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
									end -- 424
								end -- 424
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
									end -- 429
								end -- 429
								goto _continue_2 -- 432
							end -- 423
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
							end -- 433
							::_continue_2:: -- 423
						end -- 422
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
						end -- 438
						::_continue_0:: -- 413
					end -- 412
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
						end -- 442
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
				until true -- 389
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
						end -- 454
						for _index_0 = 1, #luaKeywords do -- 456
							local word = luaKeywords[_index_0] -- 456
							suggestions[#suggestions + 1] = { -- 457
								word, -- 457
								"keyword", -- 457
								"keyword" -- 457
							} -- 457
						end -- 456
						if lang == "tl" then -- 458
							for _index_0 = 1, #tealKeywords do -- 459
								local word = tealKeywords[_index_0] -- 459
								suggestions[#suggestions + 1] = { -- 460
									word, -- 460
									"keyword", -- 460
									"keyword" -- 460
								} -- 460
							end -- 459
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
						end -- 479
						if not gotGlobals then -- 481
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 482
							for _index_0 = 1, #_list_1 do -- 482
								local item = _list_1[_index_0] -- 482
								if not checkSet[item[1]] then -- 483
									suggestions[#suggestions + 1] = item -- 483
								end -- 483
							end -- 482
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
						end -- 484
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
							end -- 492
							suggestions = _accum_0 -- 492
						end -- 492
						return { -- 494
							success = true, -- 494
							suggestions = suggestions -- 494
						} -- 494
					end -- 491
				end -- 450
			end -- 387
		end -- 387
	end -- 387
	return { -- 386
		success = false -- 386
	} -- 386
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
				end -- 499
			end -- 499
			if path ~= nil then -- 499
				local uploadPath = Path(Content.writablePath, ".upload") -- 500
				if not Content:exist(uploadPath) then -- 501
					Content:mkdir(uploadPath) -- 502
				end -- 501
				local targetPath = Path(uploadPath, filename) -- 503
				Content:mkdir(Path:getPath(targetPath)) -- 504
				return targetPath -- 505
			end -- 499
		end -- 499
	end -- 499
	return nil -- 498
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
				end -- 507
			end -- 507
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
		end -- 507
	end -- 507
	return false -- 506
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
				end -- 518
			end -- 518
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
						end -- 523
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
						end -- 532
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
		end -- 518
	end -- 518
	return { -- 517
		success = false -- 517
	} -- 517
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
	} -- 547
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
				end -- 556
			end -- 556
			local content -- 556
			do -- 556
				local _obj_0 = req.body -- 556
				local _type_1 = type(_obj_0) -- 556
				if "table" == _type_1 or "userdata" == _type_1 then -- 556
					content = _obj_0.content -- 556
				end -- 556
			end -- 556
			local folder -- 556
			do -- 556
				local _obj_0 = req.body -- 556
				local _type_1 = type(_obj_0) -- 556
				if "table" == _type_1 or "userdata" == _type_1 then -- 556
					folder = _obj_0.folder -- 556
				end -- 556
			end -- 556
			if path ~= nil and content ~= nil and folder ~= nil then -- 556
				if Content:exist(path) then -- 557
					return { -- 558
						success = false, -- 558
						message = "TargetExisted" -- 558
					} -- 558
				end -- 557
				local parent = Path:getPath(path) -- 559
				local files = Content:getFiles(parent) -- 560
				if folder then -- 561
					local name = Path:getFilename(path):lower() -- 562
					for _index_0 = 1, #files do -- 563
						local file = files[_index_0] -- 563
						if name == Path:getFilename(file):lower() then -- 564
							return { -- 565
								success = false, -- 565
								message = "TargetExisted" -- 565
							} -- 565
						end -- 564
					end -- 563
					if Content:mkdir(path) then -- 566
						return { -- 567
							success = true -- 567
						} -- 567
					end -- 566
				else -- 569
					local name = Path:getName(path):lower() -- 569
					for _index_0 = 1, #files do -- 570
						local file = files[_index_0] -- 570
						if name == Path:getName(file):lower() then -- 571
							local ext = Path:getExt(file) -- 572
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 573
								goto _continue_0 -- 574
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 575
								goto _continue_0 -- 576
							end -- 573
							return { -- 577
								success = false, -- 577
								message = "SourceExisted" -- 577
							} -- 577
						end -- 571
						::_continue_0:: -- 571
					end -- 570
					if Content:save(path, content) then -- 578
						return { -- 579
							success = true -- 579
						} -- 579
					end -- 578
				end -- 561
			end -- 556
		end -- 556
	end -- 556
	return { -- 555
		success = false, -- 555
		message = "Failed" -- 555
	} -- 555
end) -- 555
HttpServer:post("/delete", function(req) -- 581
	do -- 582
		local _type_0 = type(req) -- 582
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 582
		if _tab_0 then -- 582
			local path -- 582
			do -- 582
				local _obj_0 = req.body -- 582
				local _type_1 = type(_obj_0) -- 582
				if "table" == _type_1 or "userdata" == _type_1 then -- 582
					path = _obj_0.path -- 582
				end -- 582
			end -- 582
			if path ~= nil then -- 582
				if Content:exist(path) then -- 583
					local parent = Path:getPath(path) -- 584
					local files = Content:getFiles(parent) -- 585
					local name = Path:getName(path):lower() -- 586
					local ext = Path:getExt(path) -- 587
					for _index_0 = 1, #files do -- 588
						local file = files[_index_0] -- 588
						if name == Path:getName(file):lower() then -- 589
							local _exp_0 = Path:getExt(file) -- 590
							if "tl" == _exp_0 then -- 590
								if ("vs" == ext) then -- 590
									Content:remove(Path(parent, file)) -- 591
								end -- 590
							elseif "lua" == _exp_0 then -- 592
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 592
									Content:remove(Path(parent, file)) -- 593
								end -- 592
							end -- 590
						end -- 589
					end -- 588
					if Content:remove(path) then -- 594
						return { -- 595
							success = true -- 595
						} -- 595
					end -- 594
				end -- 583
			end -- 582
		end -- 582
	end -- 582
	return { -- 581
		success = false -- 581
	} -- 581
end) -- 581
HttpServer:post("/rename", function(req) -- 597
	do -- 598
		local _type_0 = type(req) -- 598
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 598
		if _tab_0 then -- 598
			local old -- 598
			do -- 598
				local _obj_0 = req.body -- 598
				local _type_1 = type(_obj_0) -- 598
				if "table" == _type_1 or "userdata" == _type_1 then -- 598
					old = _obj_0.old -- 598
				end -- 598
			end -- 598
			local new -- 598
			do -- 598
				local _obj_0 = req.body -- 598
				local _type_1 = type(_obj_0) -- 598
				if "table" == _type_1 or "userdata" == _type_1 then -- 598
					new = _obj_0.new -- 598
				end -- 598
			end -- 598
			if old ~= nil and new ~= nil then -- 598
				if Content:exist(old) and not Content:exist(new) then -- 599
					local parent = Path:getPath(new) -- 600
					local files = Content:getFiles(parent) -- 601
					if Content:isdir(old) then -- 602
						local name = Path:getFilename(new):lower() -- 603
						for _index_0 = 1, #files do -- 604
							local file = files[_index_0] -- 604
							if name == Path:getFilename(file):lower() then -- 605
								return { -- 606
									success = false -- 606
								} -- 606
							end -- 605
						end -- 604
					else -- 608
						local name = Path:getName(new):lower() -- 608
						local ext = Path:getExt(new) -- 609
						for _index_0 = 1, #files do -- 610
							local file = files[_index_0] -- 610
							if name == Path:getName(file):lower() then -- 611
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 612
									goto _continue_0 -- 613
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 614
									goto _continue_0 -- 615
								end -- 612
								return { -- 616
									success = false -- 616
								} -- 616
							end -- 611
							::_continue_0:: -- 611
						end -- 610
					end -- 602
					if Content:move(old, new) then -- 617
						local newParent = Path:getPath(new) -- 618
						parent = Path:getPath(old) -- 619
						files = Content:getFiles(parent) -- 620
						local newName = Path:getName(new) -- 621
						local oldName = Path:getName(old) -- 622
						local name = oldName:lower() -- 623
						local ext = Path:getExt(old) -- 624
						for _index_0 = 1, #files do -- 625
							local file = files[_index_0] -- 625
							if name == Path:getName(file):lower() then -- 626
								local _exp_0 = Path:getExt(file) -- 627
								if "tl" == _exp_0 then -- 627
									if ("vs" == ext) then -- 627
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 628
									end -- 627
								elseif "lua" == _exp_0 then -- 629
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 629
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 630
									end -- 629
								end -- 627
							end -- 626
						end -- 625
						return { -- 631
							success = true -- 631
						} -- 631
					end -- 617
				end -- 599
			end -- 598
		end -- 598
	end -- 598
	return { -- 597
		success = false -- 597
	} -- 597
end) -- 597
HttpServer:post("/exist", function(req) -- 633
	do -- 634
		local _type_0 = type(req) -- 634
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 634
		if _tab_0 then -- 634
			local file -- 634
			do -- 634
				local _obj_0 = req.body -- 634
				local _type_1 = type(_obj_0) -- 634
				if "table" == _type_1 or "userdata" == _type_1 then -- 634
					file = _obj_0.file -- 634
				end -- 634
			end -- 634
			if file ~= nil then -- 634
				do -- 635
					local projFile = req.body.projFile -- 635
					if projFile then -- 635
						local projDir = getProjectDirFromFile(projFile) -- 636
						if projDir then -- 636
							local scriptDir = Path(projDir, "Script") -- 637
							local searchPaths = Content.searchPaths -- 638
							if Content:exist(scriptDir) then -- 639
								Content:addSearchPath(scriptDir) -- 639
							end -- 639
							if Content:exist(projDir) then -- 640
								Content:addSearchPath(projDir) -- 640
							end -- 640
							local _ <close> = setmetatable({ }, { -- 641
								__close = function() -- 641
									Content.searchPaths = searchPaths -- 641
								end -- 641
							}) -- 641
							return { -- 642
								success = Content:exist(file) -- 642
							} -- 642
						end -- 636
					end -- 635
				end -- 635
				return { -- 643
					success = Content:exist(file) -- 643
				} -- 643
			end -- 634
		end -- 634
	end -- 634
	return { -- 633
		success = false -- 633
	} -- 633
end) -- 633
HttpServer:postSchedule("/read", function(req) -- 645
	do -- 646
		local _type_0 = type(req) -- 646
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 646
		if _tab_0 then -- 646
			local path -- 646
			do -- 646
				local _obj_0 = req.body -- 646
				local _type_1 = type(_obj_0) -- 646
				if "table" == _type_1 or "userdata" == _type_1 then -- 646
					path = _obj_0.path -- 646
				end -- 646
			end -- 646
			if path ~= nil then -- 646
				local readFile -- 647
				readFile = function() -- 647
					if Content:exist(path) then -- 648
						local content = Content:loadAsync(path) -- 649
						if content then -- 649
							return { -- 650
								content = content, -- 650
								success = true -- 650
							} -- 650
						end -- 649
					end -- 648
					return nil -- 647
				end -- 647
				do -- 651
					local projFile = req.body.projFile -- 651
					if projFile then -- 651
						local projDir = getProjectDirFromFile(projFile) -- 652
						if projDir then -- 652
							local scriptDir = Path(projDir, "Script") -- 653
							local searchPaths = Content.searchPaths -- 654
							if Content:exist(scriptDir) then -- 655
								Content:addSearchPath(scriptDir) -- 655
							end -- 655
							if Content:exist(projDir) then -- 656
								Content:addSearchPath(projDir) -- 656
							end -- 656
							local _ <close> = setmetatable({ }, { -- 657
								__close = function() -- 657
									Content.searchPaths = searchPaths -- 657
								end -- 657
							}) -- 657
							local result = readFile() -- 658
							if result then -- 658
								return result -- 658
							end -- 658
						end -- 652
					end -- 651
				end -- 651
				local result = readFile() -- 659
				if result then -- 659
					return result -- 659
				end -- 659
			end -- 646
		end -- 646
	end -- 646
	return { -- 645
		success = false -- 645
	} -- 645
end) -- 645
HttpServer:post("/read-sync", function(req) -- 661
	do -- 662
		local _type_0 = type(req) -- 662
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 662
		if _tab_0 then -- 662
			local path -- 662
			do -- 662
				local _obj_0 = req.body -- 662
				local _type_1 = type(_obj_0) -- 662
				if "table" == _type_1 or "userdata" == _type_1 then -- 662
					path = _obj_0.path -- 662
				end -- 662
			end -- 662
			local exts -- 662
			do -- 662
				local _obj_0 = req.body -- 662
				local _type_1 = type(_obj_0) -- 662
				if "table" == _type_1 or "userdata" == _type_1 then -- 662
					exts = _obj_0.exts -- 662
				end -- 662
			end -- 662
			if path ~= nil and exts ~= nil then -- 662
				local readFile -- 663
				readFile = function() -- 663
					for _index_0 = 1, #exts do -- 664
						local ext = exts[_index_0] -- 664
						local targetPath = path .. ext -- 665
						if Content:exist(targetPath) then -- 666
							local content = Content:load(targetPath) -- 667
							if content then -- 667
								return { -- 668
									content = content, -- 668
									success = true, -- 668
									fullPath = Content:getFullPath(targetPath) -- 668
								} -- 668
							end -- 667
						end -- 666
					end -- 664
					return nil -- 663
				end -- 663
				local searchPaths = Content.searchPaths -- 669
				local _ <close> = setmetatable({ }, { -- 670
					__close = function() -- 670
						Content.searchPaths = searchPaths -- 670
					end -- 670
				}) -- 670
				do -- 671
					local projFile = req.body.projFile -- 671
					if projFile then -- 671
						local projDir = getProjectDirFromFile(projFile) -- 672
						if projDir then -- 672
							local scriptDir = Path(projDir, "Script") -- 673
							if Content:exist(scriptDir) then -- 674
								Content:addSearchPath(scriptDir) -- 674
							end -- 674
							if Content:exist(projDir) then -- 675
								Content:addSearchPath(projDir) -- 675
							end -- 675
						else -- 677
							projDir = Path:getPath(projFile) -- 677
							if Content:exist(projDir) then -- 678
								Content:addSearchPath(projDir) -- 678
							end -- 678
						end -- 672
					end -- 671
				end -- 671
				local result = readFile() -- 679
				if result then -- 679
					return result -- 679
				end -- 679
			end -- 662
		end -- 662
	end -- 662
	return { -- 661
		success = false -- 661
	} -- 661
end) -- 661
local compileFileAsync -- 681
compileFileAsync = function(inputFile, sourceCodes) -- 681
	local file = inputFile -- 682
	local searchPath -- 683
	do -- 683
		local dir = getProjectDirFromFile(inputFile) -- 683
		if dir then -- 683
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 684
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 685
		else -- 687
			file = Path:getRelative(inputFile, Content.writablePath) -- 687
			if file:sub(1, 2) == ".." then -- 688
				file = Path:getRelative(inputFile, Content.assetPath) -- 689
			end -- 688
			searchPath = "" -- 690
		end -- 683
	end -- 683
	local outputFile = Path:replaceExt(inputFile, "lua") -- 691
	local yueext = yue.options.extension -- 692
	local resultCodes = nil -- 693
	do -- 694
		local _exp_0 = Path:getExt(inputFile) -- 694
		if yueext == _exp_0 then -- 694
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 695
				if not codes then -- 696
					return -- 696
				end -- 696
				local success, result = LintYueGlobals(codes, globals) -- 697
				if not success then -- 698
					return -- 698
				end -- 698
				if codes == "" then -- 699
					resultCodes = "" -- 700
					return nil -- 701
				end -- 699
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 702
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 703
				codes = codes:gsub("^\n*", "") -- 704
				if not (result == "") then -- 705
					result = result .. "\n" -- 705
				end -- 705
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 706
				return resultCodes -- 707
			end, function(success) -- 695
				if not success then -- 708
					Content:remove(outputFile) -- 709
					if resultCodes == nil then -- 710
						resultCodes = false -- 711
					end -- 710
				end -- 708
			end) -- 695
		elseif "tl" == _exp_0 then -- 712
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 713
			if codes then -- 713
				resultCodes = codes -- 714
				Content:saveAsync(outputFile, codes) -- 715
			else -- 717
				Content:remove(outputFile) -- 717
				resultCodes = false -- 718
			end -- 713
		elseif "xml" == _exp_0 then -- 719
			local codes = xml.tolua(sourceCodes) -- 720
			if codes then -- 720
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 721
				Content:saveAsync(outputFile, resultCodes) -- 722
			else -- 724
				Content:remove(outputFile) -- 724
				resultCodes = false -- 725
			end -- 720
		end -- 694
	end -- 694
	wait(function() -- 726
		return resultCodes ~= nil -- 726
	end) -- 726
	if resultCodes then -- 727
		return resultCodes -- 727
	end -- 727
	return nil -- 681
end -- 681
HttpServer:postSchedule("/write", function(req) -- 729
	do -- 730
		local _type_0 = type(req) -- 730
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 730
		if _tab_0 then -- 730
			local path -- 730
			do -- 730
				local _obj_0 = req.body -- 730
				local _type_1 = type(_obj_0) -- 730
				if "table" == _type_1 or "userdata" == _type_1 then -- 730
					path = _obj_0.path -- 730
				end -- 730
			end -- 730
			local content -- 730
			do -- 730
				local _obj_0 = req.body -- 730
				local _type_1 = type(_obj_0) -- 730
				if "table" == _type_1 or "userdata" == _type_1 then -- 730
					content = _obj_0.content -- 730
				end -- 730
			end -- 730
			if path ~= nil and content ~= nil then -- 730
				if Content:saveAsync(path, content) then -- 731
					do -- 732
						local _exp_0 = Path:getExt(path) -- 732
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 732
							if '' == Path:getExt(Path:getName(path)) then -- 733
								local resultCodes = compileFileAsync(path, content) -- 734
								return { -- 735
									success = true, -- 735
									resultCodes = resultCodes -- 735
								} -- 735
							end -- 733
						end -- 732
					end -- 732
					return { -- 736
						success = true -- 736
					} -- 736
				end -- 731
			end -- 730
		end -- 730
	end -- 730
	return { -- 729
		success = false -- 729
	} -- 729
end) -- 729
HttpServer:postSchedule("/build", function(req) -- 738
	do -- 739
		local _type_0 = type(req) -- 739
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 739
		if _tab_0 then -- 739
			local path -- 739
			do -- 739
				local _obj_0 = req.body -- 739
				local _type_1 = type(_obj_0) -- 739
				if "table" == _type_1 or "userdata" == _type_1 then -- 739
					path = _obj_0.path -- 739
				end -- 739
			end -- 739
			if path ~= nil then -- 739
				local _exp_0 = Path:getExt(path) -- 740
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 740
					if '' == Path:getExt(Path:getName(path)) then -- 741
						local content = Content:loadAsync(path) -- 742
						if content then -- 742
							local resultCodes = compileFileAsync(path, content) -- 743
							if resultCodes then -- 743
								return { -- 744
									success = true, -- 744
									resultCodes = resultCodes -- 744
								} -- 744
							end -- 743
						end -- 742
					end -- 741
				end -- 740
			end -- 739
		end -- 739
	end -- 739
	return { -- 738
		success = false -- 738
	} -- 738
end) -- 738
local extentionLevels = { -- 747
	vs = 2, -- 747
	bl = 2, -- 748
	ts = 1, -- 749
	tsx = 1, -- 750
	tl = 1, -- 751
	yue = 1, -- 752
	xml = 1, -- 753
	lua = 0 -- 754
} -- 746
HttpServer:post("/assets", function() -- 756
	local Entry = require("Script.Dev.Entry") -- 759
	local engineDev = Entry.getEngineDev() -- 760
	local visitAssets -- 761
	visitAssets = function(path, tag) -- 761
		local isWorkspace = tag == "Workspace" -- 762
		local builtin -- 763
		if tag == "Builtin" then -- 763
			builtin = true -- 763
		else -- 763
			builtin = nil -- 763
		end -- 763
		local children = nil -- 764
		local dirs = Content:getDirs(path) -- 765
		for _index_0 = 1, #dirs do -- 766
			local dir = dirs[_index_0] -- 766
			if isWorkspace then -- 767
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 768
					goto _continue_0 -- 769
				end -- 768
			elseif dir == ".git" then -- 770
				goto _continue_0 -- 771
			end -- 767
			if not children then -- 772
				children = { } -- 772
			end -- 772
			children[#children + 1] = visitAssets(Path(path, dir)) -- 773
			::_continue_0:: -- 767
		end -- 766
		local files = Content:getFiles(path) -- 774
		local names = { } -- 775
		for _index_0 = 1, #files do -- 776
			local file = files[_index_0] -- 776
			if file:match("^%.") then -- 777
				goto _continue_1 -- 777
			end -- 777
			local name = Path:getName(file) -- 778
			local ext = names[name] -- 779
			if ext then -- 779
				local lv1 -- 780
				do -- 780
					local _exp_0 = extentionLevels[ext] -- 780
					if _exp_0 ~= nil then -- 780
						lv1 = _exp_0 -- 780
					else -- 780
						lv1 = -1 -- 780
					end -- 780
				end -- 780
				ext = Path:getExt(file) -- 781
				local lv2 -- 782
				do -- 782
					local _exp_0 = extentionLevels[ext] -- 782
					if _exp_0 ~= nil then -- 782
						lv2 = _exp_0 -- 782
					else -- 782
						lv2 = -1 -- 782
					end -- 782
				end -- 782
				if lv2 > lv1 then -- 783
					names[name] = ext -- 784
				elseif lv2 == lv1 then -- 785
					names[name .. '.' .. ext] = "" -- 786
				end -- 783
			else -- 788
				ext = Path:getExt(file) -- 788
				if not extentionLevels[ext] then -- 789
					names[file] = "" -- 790
				else -- 792
					names[name] = ext -- 792
				end -- 789
			end -- 779
			::_continue_1:: -- 777
		end -- 776
		do -- 793
			local _accum_0 = { } -- 793
			local _len_0 = 1 -- 793
			for name, ext in pairs(names) do -- 793
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 793
				_len_0 = _len_0 + 1 -- 793
			end -- 793
			files = _accum_0 -- 793
		end -- 793
		for _index_0 = 1, #files do -- 794
			local file = files[_index_0] -- 794
			if not children then -- 795
				children = { } -- 795
			end -- 795
			children[#children + 1] = { -- 797
				key = Path(path, file), -- 797
				dir = false, -- 798
				title = file, -- 799
				builtin = builtin -- 800
			} -- 796
		end -- 794
		if children then -- 802
			table.sort(children, function(a, b) -- 803
				if a.dir == b.dir then -- 804
					return a.title < b.title -- 805
				else -- 807
					return a.dir -- 807
				end -- 804
			end) -- 803
		end -- 802
		if isWorkspace and children then -- 808
			return children -- 809
		else -- 811
			return { -- 812
				key = path, -- 812
				dir = true, -- 813
				title = Path:getFilename(path), -- 814
				builtin = builtin, -- 815
				children = children -- 816
			} -- 811
		end -- 808
	end -- 761
	local zh = (App.locale:match("^zh") ~= nil) -- 818
	return { -- 820
		key = Content.writablePath, -- 820
		dir = true, -- 821
		root = true, -- 822
		title = "Assets", -- 823
		children = (function() -- 825
			local _tab_0 = { -- 825
				{ -- 826
					key = Path(Content.assetPath), -- 826
					dir = true, -- 827
					builtin = true, -- 828
					title = zh and "内置资源" or "Built-in", -- 829
					children = { -- 831
						(function() -- 831
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 831
							_with_0.title = zh and "说明文档" or "Readme" -- 832
							return _with_0 -- 831
						end)(), -- 831
						(function() -- 833
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 833
							_with_0.title = zh and "接口文档" or "API Doc" -- 834
							return _with_0 -- 833
						end)(), -- 833
						(function() -- 835
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 835
							_with_0.title = zh and "开发工具" or "Tools" -- 836
							return _with_0 -- 835
						end)(), -- 835
						(function() -- 837
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 837
							_with_0.title = zh and "字体" or "Font" -- 838
							return _with_0 -- 837
						end)(), -- 837
						(function() -- 839
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 839
							_with_0.title = zh and "程序库" or "Lib" -- 840
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
								end -- 842
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
							return _with_0 -- 839
						end)(), -- 839
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
					} -- 830
				} -- 825
			} -- 859
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 859
			local _idx_0 = #_tab_0 + 1 -- 859
			for _index_0 = 1, #_obj_0 do -- 859
				local _value_0 = _obj_0[_index_0] -- 859
				_tab_0[_idx_0] = _value_0 -- 859
				_idx_0 = _idx_0 + 1 -- 859
			end -- 859
			return _tab_0 -- 825
		end)() -- 824
	} -- 819
end) -- 756
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
				end -- 864
			end -- 864
			local asProj -- 864
			do -- 864
				local _obj_0 = req.body -- 864
				local _type_1 = type(_obj_0) -- 864
				if "table" == _type_1 or "userdata" == _type_1 then -- 864
					asProj = _obj_0.asProj -- 864
				end -- 864
			end -- 864
			if file ~= nil and asProj ~= nil then -- 864
				if not Content:isAbsolutePath(file) then -- 865
					local devFile = Path(Content.writablePath, file) -- 866
					if Content:exist(devFile) then -- 867
						file = devFile -- 867
					end -- 867
				end -- 865
				local Entry = require("Script.Dev.Entry") -- 868
				local workDir -- 869
				if asProj then -- 870
					workDir = getProjectDirFromFile(file) -- 871
					if workDir then -- 871
						Entry.allClear() -- 872
						local target = Path(workDir, "init") -- 873
						local success, err = Entry.enterEntryAsync({ -- 874
							entryName = "Project", -- 874
							fileName = target -- 874
						}) -- 874
						target = Path:getName(Path:getPath(target)) -- 875
						return { -- 876
							success = success, -- 876
							target = target, -- 876
							err = err -- 876
						} -- 876
					end -- 871
				else -- 878
					workDir = getProjectDirFromFile(file) -- 878
				end -- 870
				Entry.allClear() -- 879
				file = Path:replaceExt(file, "") -- 880
				local success, err = Entry.enterEntryAsync({ -- 882
					entryName = Path:getName(file), -- 882
					fileName = file, -- 883
					workDir = workDir -- 884
				}) -- 881
				return { -- 885
					success = success, -- 885
					err = err -- 885
				} -- 885
			end -- 864
		end -- 864
	end -- 864
	return { -- 863
		success = false -- 863
	} -- 863
end) -- 863
HttpServer:postSchedule("/stop", function() -- 887
	local Entry = require("Script.Dev.Entry") -- 888
	return { -- 889
		success = Entry.stop() -- 889
	} -- 889
end) -- 887
local minifyAsync -- 891
minifyAsync = function(sourcePath, minifyPath) -- 891
	if not Content:exist(sourcePath) then -- 892
		return -- 892
	end -- 892
	local Entry = require("Script.Dev.Entry") -- 893
	local errors = { } -- 894
	local files = Entry.getAllFiles(sourcePath, { -- 895
		"lua" -- 895
	}, true) -- 895
	do -- 896
		local _accum_0 = { } -- 896
		local _len_0 = 1 -- 896
		for _index_0 = 1, #files do -- 896
			local file = files[_index_0] -- 896
			if file:sub(1, 1) ~= '.' then -- 896
				_accum_0[_len_0] = file -- 896
				_len_0 = _len_0 + 1 -- 896
			end -- 896
		end -- 896
		files = _accum_0 -- 896
	end -- 896
	local paths -- 897
	do -- 897
		local _tbl_0 = { } -- 897
		for _index_0 = 1, #files do -- 897
			local file = files[_index_0] -- 897
			_tbl_0[Path:getPath(file)] = true -- 897
		end -- 897
		paths = _tbl_0 -- 897
	end -- 897
	for path in pairs(paths) do -- 898
		Content:mkdir(Path(minifyPath, path)) -- 898
	end -- 898
	local _ <close> = setmetatable({ }, { -- 899
		__close = function() -- 899
			package.loaded["luaminify.FormatMini"] = nil -- 900
			package.loaded["luaminify.ParseLua"] = nil -- 901
			package.loaded["luaminify.Scope"] = nil -- 902
			package.loaded["luaminify.Util"] = nil -- 903
		end -- 899
	}) -- 899
	local FormatMini -- 904
	do -- 904
		local _obj_0 = require("luaminify") -- 904
		FormatMini = _obj_0.FormatMini -- 904
	end -- 904
	local fileCount = #files -- 905
	local count = 0 -- 906
	for _index_0 = 1, #files do -- 907
		local file = files[_index_0] -- 907
		thread(function() -- 908
			local _ <close> = setmetatable({ }, { -- 909
				__close = function() -- 909
					count = count + 1 -- 909
				end -- 909
			}) -- 909
			local input = Path(sourcePath, file) -- 910
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 911
			if Content:exist(input) then -- 912
				local sourceCodes = Content:loadAsync(input) -- 913
				local res, err = FormatMini(sourceCodes) -- 914
				if res then -- 915
					Content:saveAsync(output, res) -- 916
					return print("Minify " .. tostring(file)) -- 917
				else -- 919
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 919
				end -- 915
			else -- 921
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 921
			end -- 912
		end) -- 908
		sleep() -- 922
	end -- 907
	wait(function() -- 923
		return count == fileCount -- 923
	end) -- 923
	if #errors > 0 then -- 924
		print(table.concat(errors, '\n')) -- 925
	end -- 924
	print("Obfuscation done.") -- 926
	return files -- 927
end -- 891
local zipping = false -- 929
HttpServer:postSchedule("/zip", function(req) -- 931
	do -- 932
		local _type_0 = type(req) -- 932
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 932
		if _tab_0 then -- 932
			local path -- 932
			do -- 932
				local _obj_0 = req.body -- 932
				local _type_1 = type(_obj_0) -- 932
				if "table" == _type_1 or "userdata" == _type_1 then -- 932
					path = _obj_0.path -- 932
				end -- 932
			end -- 932
			local zipFile -- 932
			do -- 932
				local _obj_0 = req.body -- 932
				local _type_1 = type(_obj_0) -- 932
				if "table" == _type_1 or "userdata" == _type_1 then -- 932
					zipFile = _obj_0.zipFile -- 932
				end -- 932
			end -- 932
			local obfuscated -- 932
			do -- 932
				local _obj_0 = req.body -- 932
				local _type_1 = type(_obj_0) -- 932
				if "table" == _type_1 or "userdata" == _type_1 then -- 932
					obfuscated = _obj_0.obfuscated -- 932
				end -- 932
			end -- 932
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 932
				if zipping then -- 933
					goto failed -- 933
				end -- 933
				zipping = true -- 934
				local _ <close> = setmetatable({ }, { -- 935
					__close = function() -- 935
						zipping = false -- 935
					end -- 935
				}) -- 935
				if not Content:exist(path) then -- 936
					goto failed -- 936
				end -- 936
				Content:mkdir(Path:getPath(zipFile)) -- 937
				if obfuscated then -- 938
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 939
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 940
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 941
					Content:remove(scriptPath) -- 942
					Content:remove(obfuscatedPath) -- 943
					Content:remove(tempPath) -- 944
					Content:mkdir(scriptPath) -- 945
					Content:mkdir(obfuscatedPath) -- 946
					Content:mkdir(tempPath) -- 947
					if not Content:copyAsync(path, tempPath) then -- 948
						goto failed -- 948
					end -- 948
					local Entry = require("Script.Dev.Entry") -- 949
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 950
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 951
						"tl", -- 951
						"yue", -- 951
						"lua", -- 951
						"ts", -- 951
						"tsx", -- 951
						"vs", -- 951
						"bl", -- 951
						"xml", -- 951
						"wa", -- 951
						"mod" -- 951
					}, true) -- 951
					for _index_0 = 1, #scriptFiles do -- 952
						local file = scriptFiles[_index_0] -- 952
						Content:remove(Path(tempPath, file)) -- 953
					end -- 952
					for _index_0 = 1, #luaFiles do -- 954
						local file = luaFiles[_index_0] -- 954
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 955
					end -- 954
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 956
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 957
					end) then -- 956
						goto failed -- 956
					end -- 956
					return { -- 958
						success = true -- 958
					} -- 958
				else -- 960
					return { -- 960
						success = Content:zipAsync(path, zipFile, function(file) -- 960
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 961
						end) -- 960
					} -- 960
				end -- 938
			end -- 932
		end -- 932
	end -- 932
	::failed:: -- 962
	return { -- 931
		success = false -- 931
	} -- 931
end) -- 931
HttpServer:postSchedule("/unzip", function(req) -- 964
	do -- 965
		local _type_0 = type(req) -- 965
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 965
		if _tab_0 then -- 965
			local zipFile -- 965
			do -- 965
				local _obj_0 = req.body -- 965
				local _type_1 = type(_obj_0) -- 965
				if "table" == _type_1 or "userdata" == _type_1 then -- 965
					zipFile = _obj_0.zipFile -- 965
				end -- 965
			end -- 965
			local path -- 965
			do -- 965
				local _obj_0 = req.body -- 965
				local _type_1 = type(_obj_0) -- 965
				if "table" == _type_1 or "userdata" == _type_1 then -- 965
					path = _obj_0.path -- 965
				end -- 965
			end -- 965
			if zipFile ~= nil and path ~= nil then -- 965
				return { -- 966
					success = Content:unzipAsync(zipFile, path, function(file) -- 966
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 967
					end) -- 966
				} -- 966
			end -- 965
		end -- 965
	end -- 965
	return { -- 964
		success = false -- 964
	} -- 964
end) -- 964
HttpServer:post("/editing-info", function(req) -- 969
	local Entry = require("Script.Dev.Entry") -- 970
	local config = Entry.getConfig() -- 971
	local _type_0 = type(req) -- 972
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 972
	local _match_0 = false -- 972
	if _tab_0 then -- 972
		local editingInfo -- 972
		do -- 972
			local _obj_0 = req.body -- 972
			local _type_1 = type(_obj_0) -- 972
			if "table" == _type_1 or "userdata" == _type_1 then -- 972
				editingInfo = _obj_0.editingInfo -- 972
			end -- 972
		end -- 972
		if editingInfo ~= nil then -- 972
			_match_0 = true -- 972
			config.editingInfo = editingInfo -- 973
			return { -- 974
				success = true -- 974
			} -- 974
		end -- 972
	end -- 972
	if not _match_0 then -- 972
		if not (config.editingInfo ~= nil) then -- 976
			local folder -- 977
			if App.locale:match('^zh') then -- 977
				folder = 'zh-Hans' -- 977
			else -- 977
				folder = 'en' -- 977
			end -- 977
			config.editingInfo = json.encode({ -- 979
				index = 0, -- 979
				files = { -- 981
					{ -- 982
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 982
						title = "welcome.md" -- 983
					} -- 981
				} -- 980
			}) -- 978
		end -- 976
		return { -- 987
			success = true, -- 987
			editingInfo = config.editingInfo -- 987
		} -- 987
	end -- 972
end) -- 969
HttpServer:post("/command", function(req) -- 989
	do -- 990
		local _type_0 = type(req) -- 990
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 990
		if _tab_0 then -- 990
			local code -- 990
			do -- 990
				local _obj_0 = req.body -- 990
				local _type_1 = type(_obj_0) -- 990
				if "table" == _type_1 or "userdata" == _type_1 then -- 990
					code = _obj_0.code -- 990
				end -- 990
			end -- 990
			local log -- 990
			do -- 990
				local _obj_0 = req.body -- 990
				local _type_1 = type(_obj_0) -- 990
				if "table" == _type_1 or "userdata" == _type_1 then -- 990
					log = _obj_0.log -- 990
				end -- 990
			end -- 990
			if code ~= nil and log ~= nil then -- 990
				emit("AppCommand", code, log) -- 991
				return { -- 992
					success = true -- 992
				} -- 992
			end -- 990
		end -- 990
	end -- 990
	return { -- 989
		success = false -- 989
	} -- 989
end) -- 989
HttpServer:post("/log/save", function() -- 994
	local folder = ".download" -- 995
	local fullLogFile = "dora_full_logs.txt" -- 996
	local fullFolder = Path(Content.writablePath, folder) -- 997
	Content:mkdir(fullFolder) -- 998
	local logPath = Path(fullFolder, fullLogFile) -- 999
	if App:saveLog(logPath) then -- 1000
		return { -- 1001
			success = true, -- 1001
			path = Path(folder, fullLogFile) -- 1001
		} -- 1001
	end -- 1000
	return { -- 994
		success = false -- 994
	} -- 994
end) -- 994
HttpServer:post("/yarn/check", function(req) -- 1003
	local yarncompile = require("yarncompile") -- 1004
	do -- 1005
		local _type_0 = type(req) -- 1005
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1005
		if _tab_0 then -- 1005
			local code -- 1005
			do -- 1005
				local _obj_0 = req.body -- 1005
				local _type_1 = type(_obj_0) -- 1005
				if "table" == _type_1 or "userdata" == _type_1 then -- 1005
					code = _obj_0.code -- 1005
				end -- 1005
			end -- 1005
			if code ~= nil then -- 1005
				local jsonObject = json.decode(code) -- 1006
				if jsonObject then -- 1006
					local errors = { } -- 1007
					local _list_0 = jsonObject.nodes -- 1008
					for _index_0 = 1, #_list_0 do -- 1008
						local node = _list_0[_index_0] -- 1008
						local title, body = node.title, node.body -- 1009
						local luaCode, err = yarncompile(body) -- 1010
						if not luaCode then -- 1010
							errors[#errors + 1] = title .. ":" .. err -- 1011
						end -- 1010
					end -- 1008
					return { -- 1012
						success = true, -- 1012
						syntaxError = table.concat(errors, "\n\n") -- 1012
					} -- 1012
				end -- 1006
			end -- 1005
		end -- 1005
	end -- 1005
	return { -- 1003
		success = false -- 1003
	} -- 1003
end) -- 1003
HttpServer:post("/yarn/check-file", function(req) -- 1014
	local yarncompile = require("yarncompile") -- 1015
	do -- 1016
		local _type_0 = type(req) -- 1016
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1016
		if _tab_0 then -- 1016
			local code -- 1016
			do -- 1016
				local _obj_0 = req.body -- 1016
				local _type_1 = type(_obj_0) -- 1016
				if "table" == _type_1 or "userdata" == _type_1 then -- 1016
					code = _obj_0.code -- 1016
				end -- 1016
			end -- 1016
			if code ~= nil then -- 1016
				local res, _, err = yarncompile(code, true) -- 1017
				if not res then -- 1017
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1018
					return { -- 1019
						success = false, -- 1019
						message = message, -- 1019
						line = line, -- 1019
						column = column, -- 1019
						node = node -- 1019
					} -- 1019
				end -- 1017
			end -- 1016
		end -- 1016
	end -- 1016
	return { -- 1014
		success = true -- 1014
	} -- 1014
end) -- 1014
local getWaProjectDirFromFile -- 1021
getWaProjectDirFromFile = function(file) -- 1021
	local writablePath = Content.writablePath -- 1022
	local parent, current -- 1023
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1023
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1024
	else -- 1026
		parent, current = nil, nil -- 1026
	end -- 1023
	if not current then -- 1027
		return nil -- 1027
	end -- 1027
	repeat -- 1028
		current = Path:getPath(current) -- 1029
		if current == "" then -- 1030
			break -- 1030
		end -- 1030
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1031
		for _index_0 = 1, #_list_0 do -- 1031
			local f = _list_0[_index_0] -- 1031
			if Path:getFilename(f):lower() == "wa.mod" then -- 1032
				return Path(parent, current, Path:getPath(f)) -- 1033
			end -- 1032
		end -- 1031
	until false -- 1028
	return nil -- 1035
end -- 1021
HttpServer:postSchedule("/wa/build", function(req) -- 1037
	do -- 1038
		local _type_0 = type(req) -- 1038
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1038
		if _tab_0 then -- 1038
			local path -- 1038
			do -- 1038
				local _obj_0 = req.body -- 1038
				local _type_1 = type(_obj_0) -- 1038
				if "table" == _type_1 or "userdata" == _type_1 then -- 1038
					path = _obj_0.path -- 1038
				end -- 1038
			end -- 1038
			if path ~= nil then -- 1038
				local projDir = getWaProjectDirFromFile(path) -- 1039
				if projDir then -- 1039
					local message = Wasm:buildWaAsync(projDir) -- 1040
					if message == "" then -- 1041
						return { -- 1042
							success = true -- 1042
						} -- 1042
					else -- 1044
						return { -- 1044
							success = false, -- 1044
							message = message -- 1044
						} -- 1044
					end -- 1041
				else -- 1046
					return { -- 1046
						success = false, -- 1046
						message = 'Wa file needs a project' -- 1046
					} -- 1046
				end -- 1039
			end -- 1038
		end -- 1038
	end -- 1038
	return { -- 1047
		success = false, -- 1047
		message = 'failed to build' -- 1047
	} -- 1047
end) -- 1037
HttpServer:postSchedule("/wa/format", function(req) -- 1049
	do -- 1050
		local _type_0 = type(req) -- 1050
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1050
		if _tab_0 then -- 1050
			local file -- 1050
			do -- 1050
				local _obj_0 = req.body -- 1050
				local _type_1 = type(_obj_0) -- 1050
				if "table" == _type_1 or "userdata" == _type_1 then -- 1050
					file = _obj_0.file -- 1050
				end -- 1050
			end -- 1050
			if file ~= nil then -- 1050
				local code = Wasm:formatWaAsync(file) -- 1051
				if code == "" then -- 1052
					return { -- 1053
						success = false -- 1053
					} -- 1053
				else -- 1055
					return { -- 1055
						success = true, -- 1055
						code = code -- 1055
					} -- 1055
				end -- 1052
			end -- 1050
		end -- 1050
	end -- 1050
	return { -- 1056
		success = false -- 1056
	} -- 1056
end) -- 1049
HttpServer:postSchedule("/wa/create", function(req) -- 1058
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
				if not Content:exist(Path:getPath(path)) then -- 1060
					return { -- 1061
						success = false, -- 1061
						message = "target path not existed" -- 1061
					} -- 1061
				end -- 1060
				if Content:exist(path) then -- 1062
					return { -- 1063
						success = false, -- 1063
						message = "target project folder existed" -- 1063
					} -- 1063
				end -- 1062
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1064
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1065
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1066
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1067
					return { -- 1070
						success = false, -- 1070
						message = "missing template project" -- 1070
					} -- 1070
				end -- 1067
				if not Content:mkdir(path) then -- 1071
					return { -- 1072
						success = false, -- 1072
						message = "failed to create project folder" -- 1072
					} -- 1072
				end -- 1071
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1073
					Content:remove(path) -- 1074
					return { -- 1075
						success = false, -- 1075
						message = "failed to copy template" -- 1075
					} -- 1075
				end -- 1073
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1076
					Content:remove(path) -- 1077
					return { -- 1078
						success = false, -- 1078
						message = "failed to copy template" -- 1078
					} -- 1078
				end -- 1076
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1079
					Content:remove(path) -- 1080
					return { -- 1081
						success = false, -- 1081
						message = "failed to copy template" -- 1081
					} -- 1081
				end -- 1079
				return { -- 1082
					success = true -- 1082
				} -- 1082
			end -- 1059
		end -- 1059
	end -- 1059
	return { -- 1058
		success = false, -- 1058
		message = "invalid call" -- 1058
	} -- 1058
end) -- 1058
local _anon_func_3 = function(Path, path) -- 1091
	local _val_0 = Path:getExt(path) -- 1091
	return "ts" == _val_0 or "tsx" == _val_0 -- 1091
end -- 1091
local _anon_func_4 = function(Path, f) -- 1121
	local _val_0 = Path:getExt(f) -- 1121
	return "ts" == _val_0 or "tsx" == _val_0 -- 1121
end -- 1121
HttpServer:postSchedule("/ts/build", function(req) -- 1084
	do -- 1085
		local _type_0 = type(req) -- 1085
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1085
		if _tab_0 then -- 1085
			local path -- 1085
			do -- 1085
				local _obj_0 = req.body -- 1085
				local _type_1 = type(_obj_0) -- 1085
				if "table" == _type_1 or "userdata" == _type_1 then -- 1085
					path = _obj_0.path -- 1085
				end -- 1085
			end -- 1085
			if path ~= nil then -- 1085
				if HttpServer.wsConnectionCount == 0 then -- 1086
					return { -- 1087
						success = false, -- 1087
						message = "Web IDE not connected" -- 1087
					} -- 1087
				end -- 1086
				if not Content:exist(path) then -- 1088
					return { -- 1089
						success = false, -- 1089
						message = "path not existed" -- 1089
					} -- 1089
				end -- 1088
				if not Content:isdir(path) then -- 1090
					if not (_anon_func_3(Path, path)) then -- 1091
						return { -- 1092
							success = false, -- 1092
							message = "expecting a TypeScript file" -- 1092
						} -- 1092
					end -- 1091
					local messages = { } -- 1093
					local content = Content:load(path) -- 1094
					if not content then -- 1095
						return { -- 1096
							success = false, -- 1096
							message = "failed to read file" -- 1096
						} -- 1096
					end -- 1095
					emit("AppWS", "Send", json.encode({ -- 1097
						name = "UpdateTSCode", -- 1097
						file = path, -- 1097
						content = content -- 1097
					})) -- 1097
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1098
						local done = false -- 1099
						do -- 1100
							local _with_0 = Node() -- 1100
							_with_0:gslot("AppWS", function(eventType, msg) -- 1101
								if eventType == "Receive" then -- 1102
									_with_0:removeFromParent() -- 1103
									local res = json.decode(msg) -- 1104
									if res then -- 1104
										if res.name == "TranspileTS" then -- 1105
											if res.success then -- 1106
												local luaFile = Path:replaceExt(path, "lua") -- 1107
												Content:save(luaFile, res.luaCode) -- 1108
												messages[#messages + 1] = { -- 1109
													success = true, -- 1109
													file = path -- 1109
												} -- 1109
											else -- 1111
												messages[#messages + 1] = { -- 1111
													success = false, -- 1111
													file = path, -- 1111
													message = res.message -- 1111
												} -- 1111
											end -- 1106
											done = true -- 1112
										end -- 1105
									end -- 1104
								end -- 1102
							end) -- 1101
						end -- 1100
						emit("AppWS", "Send", json.encode({ -- 1113
							name = "TranspileTS", -- 1113
							file = path, -- 1113
							content = content -- 1113
						})) -- 1113
						wait(function() -- 1114
							return done -- 1114
						end) -- 1114
					end -- 1098
					return { -- 1115
						success = true, -- 1115
						messages = messages -- 1115
					} -- 1115
				else -- 1117
					local files = Content:getAllFiles(path) -- 1117
					local fileData = { } -- 1118
					local messages = { } -- 1119
					for _index_0 = 1, #files do -- 1120
						local f = files[_index_0] -- 1120
						if not (_anon_func_4(Path, f)) then -- 1121
							goto _continue_0 -- 1121
						end -- 1121
						local file = Path(path, f) -- 1122
						local content = Content:load(file) -- 1123
						if content then -- 1123
							fileData[file] = content -- 1124
							emit("AppWS", "Send", json.encode({ -- 1125
								name = "UpdateTSCode", -- 1125
								file = file, -- 1125
								content = content -- 1125
							})) -- 1125
						else -- 1127
							messages[#messages + 1] = { -- 1127
								success = false, -- 1127
								file = file, -- 1127
								message = "failed to read file" -- 1127
							} -- 1127
						end -- 1123
						::_continue_0:: -- 1121
					end -- 1120
					for file, content in pairs(fileData) do -- 1128
						if "d" == Path:getExt(Path:getName(file)) then -- 1129
							goto _continue_1 -- 1129
						end -- 1129
						local done = false -- 1130
						do -- 1131
							local _with_0 = Node() -- 1131
							_with_0:gslot("AppWS", function(eventType, msg) -- 1132
								if eventType == "Receive" then -- 1133
									_with_0:removeFromParent() -- 1134
									local res = json.decode(msg) -- 1135
									if res then -- 1135
										if res.name == "TranspileTS" then -- 1136
											if res.success then -- 1137
												local luaFile = Path:replaceExt(file, "lua") -- 1138
												Content:save(luaFile, res.luaCode) -- 1139
												messages[#messages + 1] = { -- 1140
													success = true, -- 1140
													file = file -- 1140
												} -- 1140
											else -- 1142
												messages[#messages + 1] = { -- 1142
													success = false, -- 1142
													file = file, -- 1142
													message = res.message -- 1142
												} -- 1142
											end -- 1137
											done = true -- 1143
										end -- 1136
									end -- 1135
								end -- 1133
							end) -- 1132
						end -- 1131
						emit("AppWS", "Send", json.encode({ -- 1144
							name = "TranspileTS", -- 1144
							file = file, -- 1144
							content = content -- 1144
						})) -- 1144
						wait(function() -- 1145
							return done -- 1145
						end) -- 1145
						::_continue_1:: -- 1129
					end -- 1128
					return { -- 1146
						success = true, -- 1146
						messages = messages -- 1146
					} -- 1146
				end -- 1090
			end -- 1085
		end -- 1085
	end -- 1085
	return { -- 1084
		success = false -- 1084
	} -- 1084
end) -- 1084
HttpServer:post("/download", function(req) -- 1148
	do -- 1149
		local _type_0 = type(req) -- 1149
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1149
		if _tab_0 then -- 1149
			local url -- 1149
			do -- 1149
				local _obj_0 = req.body -- 1149
				local _type_1 = type(_obj_0) -- 1149
				if "table" == _type_1 or "userdata" == _type_1 then -- 1149
					url = _obj_0.url -- 1149
				end -- 1149
			end -- 1149
			local target -- 1149
			do -- 1149
				local _obj_0 = req.body -- 1149
				local _type_1 = type(_obj_0) -- 1149
				if "table" == _type_1 or "userdata" == _type_1 then -- 1149
					target = _obj_0.target -- 1149
				end -- 1149
			end -- 1149
			if url ~= nil and target ~= nil then -- 1149
				local Entry = require("Script.Dev.Entry") -- 1150
				Entry.downloadFile(url, target) -- 1151
				return { -- 1152
					success = true -- 1152
				} -- 1152
			end -- 1149
		end -- 1149
	end -- 1149
	return { -- 1148
		success = false -- 1148
	} -- 1148
end) -- 1148
local status = { } -- 1154
_module_0 = status -- 1155
thread(function() -- 1157
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1158
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1159
	if Content:exist(doraWeb) then -- 1160
		local needReload -- 1161
		if Content:exist(doraReady) then -- 1161
			needReload = App.version ~= Content:load(doraReady) -- 1162
		else -- 1163
			needReload = true -- 1163
		end -- 1161
		if needReload then -- 1164
			Content:remove(Path(Content.appPath, ".www")) -- 1165
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1166
			Content:save(doraReady, App.version) -- 1170
			print("Dora Dora is ready!") -- 1171
		end -- 1164
	end -- 1160
	if HttpServer:start(8866) then -- 1172
		local localIP = HttpServer.localIP -- 1173
		if localIP == "" then -- 1174
			localIP = "localhost" -- 1174
		end -- 1174
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1175
		return HttpServer:startWS(8868) -- 1176
	else -- 1178
		status.url = nil -- 1178
		return print("8866 Port not available!") -- 1179
	end -- 1172
end) -- 1157
return _module_0 -- 1
