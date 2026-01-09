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
local LintYueGlobals, CheckTIC80Code -- 15
do -- 15
	local _obj_0 = require("Utils") -- 15
	LintYueGlobals, CheckTIC80Code = _obj_0.LintYueGlobals, _obj_0.CheckTIC80Code -- 15
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
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 70
	if isTIC80 then -- 71
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 72
	end -- 71
	local searchPath = getSearchPath(file) -- 73
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 74
	local info = { } -- 75
	local globals = { } -- 76
	for _index_0 = 1, #checkResult do -- 77
		local _des_0 = checkResult[_index_0] -- 77
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 77
		if "error" == t then -- 78
			info[#info + 1] = { -- 79
				"syntax", -- 79
				file, -- 79
				line, -- 79
				col, -- 79
				msg -- 79
			} -- 79
		elseif "global" == t then -- 80
			globals[#globals + 1] = { -- 81
				msg, -- 81
				line, -- 81
				col -- 81
			} -- 81
		end -- 78
	end -- 77
	if luaCodes then -- 82
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 83
		if success then -- 84
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 85
			if not (lintResult == "") then -- 86
				lintResult = lintResult .. "\n" -- 86
			end -- 86
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 87
		else -- 88
			for _index_0 = 1, #lintResult do -- 88
				local _des_0 = lintResult[_index_0] -- 88
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 88
				if isTIC80 and tic80APIs[name] then -- 89
					goto _continue_0 -- 89
				end -- 89
				info[#info + 1] = { -- 90
					"syntax", -- 90
					file, -- 90
					line, -- 90
					col, -- 90
					"invalid global variable" -- 90
				} -- 90
				::_continue_0:: -- 89
			end -- 88
		end -- 84
	end -- 82
	return luaCodes, info -- 91
end -- 69
local luaCheck -- 93
luaCheck = function(file, content) -- 93
	local res, err = load(content, "check") -- 94
	if not res then -- 95
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 96
		return { -- 97
			success = false, -- 97
			info = { -- 97
				{ -- 97
					"syntax", -- 97
					file, -- 97
					tonumber(line), -- 97
					0, -- 97
					msg -- 97
				} -- 97
			} -- 97
		} -- 97
	end -- 95
	local success, info = teal.checkAsync(content, file, true, "") -- 98
	if info then -- 99
		do -- 100
			local _accum_0 = { } -- 100
			local _len_0 = 1 -- 100
			for _index_0 = 1, #info do -- 100
				local item = info[_index_0] -- 100
				local useCheck = true -- 101
				if not item[5]:match("unused") then -- 102
					for _index_1 = 1, #disabledCheckForLua do -- 103
						local check = disabledCheckForLua[_index_1] -- 103
						if item[5]:match(check) then -- 104
							useCheck = false -- 105
						end -- 104
					end -- 103
				end -- 102
				if not useCheck then -- 106
					goto _continue_0 -- 106
				end -- 106
				do -- 107
					local _exp_0 = item[1] -- 107
					if "type" == _exp_0 then -- 108
						item[1] = "warning" -- 109
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 110
						goto _continue_0 -- 111
					end -- 107
				end -- 107
				_accum_0[_len_0] = item -- 112
				_len_0 = _len_0 + 1 -- 101
				::_continue_0:: -- 101
			end -- 100
			info = _accum_0 -- 100
		end -- 100
		if #info == 0 then -- 113
			info = nil -- 114
			success = true -- 115
		end -- 113
	end -- 99
	return { -- 116
		success = success, -- 116
		info = info -- 116
	} -- 116
end -- 93
local luaCheckWithLineInfo -- 118
luaCheckWithLineInfo = function(file, luaCodes) -- 118
	local res = luaCheck(file, luaCodes) -- 119
	local info = { } -- 120
	if not res.success then -- 121
		local current = 1 -- 122
		local lastLine = 1 -- 123
		local lineMap = { } -- 124
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 125
			local num = lineCode:match("--%s*(%d+)%s*$") -- 126
			if num then -- 127
				lastLine = tonumber(num) -- 128
			end -- 127
			lineMap[current] = lastLine -- 129
			current = current + 1 -- 130
		end -- 125
		local _list_0 = res.info -- 131
		for _index_0 = 1, #_list_0 do -- 131
			local item = _list_0[_index_0] -- 131
			item[3] = lineMap[item[3]] or 0 -- 132
			item[4] = 0 -- 133
			info[#info + 1] = item -- 134
		end -- 131
		return false, info -- 135
	end -- 121
	return true, info -- 136
end -- 118
local getCompiledYueLine -- 138
getCompiledYueLine = function(content, line, row, file, lax) -- 138
	local luaCodes = yueCheck(file, content, lax) -- 139
	if not luaCodes then -- 140
		return nil -- 140
	end -- 140
	local current = 1 -- 141
	local lastLine = 1 -- 142
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 143
	local targetRow = nil -- 144
	local lineMap = { } -- 145
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 146
		local num = lineCode:match("--%s*(%d+)%s*$") -- 147
		if num then -- 148
			lastLine = tonumber(num) -- 148
		end -- 148
		lineMap[current] = lastLine -- 149
		if row <= lastLine and not targetRow then -- 150
			targetRow = current -- 151
			break -- 152
		end -- 150
		current = current + 1 -- 153
	end -- 146
	targetRow = current -- 154
	if targetLine and targetRow then -- 155
		return luaCodes, targetLine, targetRow, lineMap -- 156
	else -- 158
		return nil -- 158
	end -- 155
end -- 138
HttpServer:postSchedule("/check", function(req) -- 160
	do -- 161
		local _type_0 = type(req) -- 161
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 161
		if _tab_0 then -- 161
			local file -- 161
			do -- 161
				local _obj_0 = req.body -- 161
				local _type_1 = type(_obj_0) -- 161
				if "table" == _type_1 or "userdata" == _type_1 then -- 161
					file = _obj_0.file -- 161
				end -- 161
			end -- 161
			local content -- 161
			do -- 161
				local _obj_0 = req.body -- 161
				local _type_1 = type(_obj_0) -- 161
				if "table" == _type_1 or "userdata" == _type_1 then -- 161
					content = _obj_0.content -- 161
				end -- 161
			end -- 161
			if file ~= nil and content ~= nil then -- 161
				local ext = Path:getExt(file) -- 162
				if "tl" == ext then -- 163
					local searchPath = getSearchPath(file) -- 164
					do -- 165
						local isTIC80 = CheckTIC80Code(content) -- 165
						if isTIC80 then -- 165
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 166
						end -- 165
					end -- 165
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 167
					return { -- 168
						success = success, -- 168
						info = info -- 168
					} -- 168
				elseif "lua" == ext then -- 169
					do -- 170
						local isTIC80 = CheckTIC80Code(content) -- 170
						if isTIC80 then -- 170
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 171
						end -- 170
					end -- 170
					return luaCheck(file, content) -- 172
				elseif "yue" == ext then -- 173
					local luaCodes, info = yueCheck(file, content, false) -- 174
					local success = false -- 175
					if luaCodes then -- 176
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 177
						do -- 178
							local _tab_1 = { } -- 178
							local _idx_0 = #_tab_1 + 1 -- 178
							for _index_0 = 1, #info do -- 178
								local _value_0 = info[_index_0] -- 178
								_tab_1[_idx_0] = _value_0 -- 178
								_idx_0 = _idx_0 + 1 -- 178
							end -- 178
							local _idx_1 = #_tab_1 + 1 -- 178
							for _index_0 = 1, #luaInfo do -- 178
								local _value_0 = luaInfo[_index_0] -- 178
								_tab_1[_idx_1] = _value_0 -- 178
								_idx_1 = _idx_1 + 1 -- 178
							end -- 178
							info = _tab_1 -- 178
						end -- 178
						success = success and luaSuccess -- 179
					end -- 176
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
				elseif "xml" == ext then -- 184
					local success, result = xml.check(content) -- 185
					if success then -- 186
						local info -- 187
						success, info = luaCheckWithLineInfo(file, result) -- 187
						if #info > 0 then -- 188
							return { -- 189
								success = success, -- 189
								info = info -- 189
							} -- 189
						else -- 191
							return { -- 191
								success = success -- 191
							} -- 191
						end -- 188
					else -- 193
						local info -- 193
						do -- 193
							local _accum_0 = { } -- 193
							local _len_0 = 1 -- 193
							for _index_0 = 1, #result do -- 193
								local _des_0 = result[_index_0] -- 193
								local row, err = _des_0[1], _des_0[2] -- 193
								_accum_0[_len_0] = { -- 194
									"syntax", -- 194
									file, -- 194
									row, -- 194
									0, -- 194
									err -- 194
								} -- 194
								_len_0 = _len_0 + 1 -- 194
							end -- 193
							info = _accum_0 -- 193
						end -- 193
						return { -- 195
							success = false, -- 195
							info = info -- 195
						} -- 195
					end -- 186
				end -- 163
			end -- 161
		end -- 161
	end -- 161
	return { -- 160
		success = true -- 160
	} -- 160
end) -- 160
local updateInferedDesc -- 197
updateInferedDesc = function(infered) -- 197
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 198
		return -- 198
	end -- 198
	local key, row = infered.key, infered.row -- 199
	local codes = Content:loadAsync(key) -- 200
	if codes then -- 200
		local comments = { } -- 201
		local line = 0 -- 202
		local skipping = false -- 203
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 204
			line = line + 1 -- 205
			if line >= row then -- 206
				break -- 206
			end -- 206
			if lineCode:match("^%s*%-%- @") then -- 207
				skipping = true -- 208
				goto _continue_0 -- 209
			end -- 207
			local result = lineCode:match("^%s*%-%- (.+)") -- 210
			if result then -- 210
				if not skipping then -- 211
					comments[#comments + 1] = result -- 211
				end -- 211
			elseif #comments > 0 then -- 212
				comments = { } -- 213
				skipping = false -- 214
			end -- 210
			::_continue_0:: -- 205
		end -- 204
		infered.doc = table.concat(comments, "\n") -- 215
	end -- 200
end -- 197
HttpServer:postSchedule("/infer", function(req) -- 217
	do -- 218
		local _type_0 = type(req) -- 218
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 218
		if _tab_0 then -- 218
			local lang -- 218
			do -- 218
				local _obj_0 = req.body -- 218
				local _type_1 = type(_obj_0) -- 218
				if "table" == _type_1 or "userdata" == _type_1 then -- 218
					lang = _obj_0.lang -- 218
				end -- 218
			end -- 218
			local file -- 218
			do -- 218
				local _obj_0 = req.body -- 218
				local _type_1 = type(_obj_0) -- 218
				if "table" == _type_1 or "userdata" == _type_1 then -- 218
					file = _obj_0.file -- 218
				end -- 218
			end -- 218
			local content -- 218
			do -- 218
				local _obj_0 = req.body -- 218
				local _type_1 = type(_obj_0) -- 218
				if "table" == _type_1 or "userdata" == _type_1 then -- 218
					content = _obj_0.content -- 218
				end -- 218
			end -- 218
			local line -- 218
			do -- 218
				local _obj_0 = req.body -- 218
				local _type_1 = type(_obj_0) -- 218
				if "table" == _type_1 or "userdata" == _type_1 then -- 218
					line = _obj_0.line -- 218
				end -- 218
			end -- 218
			local row -- 218
			do -- 218
				local _obj_0 = req.body -- 218
				local _type_1 = type(_obj_0) -- 218
				if "table" == _type_1 or "userdata" == _type_1 then -- 218
					row = _obj_0.row -- 218
				end -- 218
			end -- 218
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 218
				local searchPath = getSearchPath(file) -- 219
				if "tl" == lang or "lua" == lang then -- 220
					if CheckTIC80Code(content) then -- 221
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 222
					end -- 221
					local infered = teal.inferAsync(content, line, row, searchPath) -- 223
					if (infered ~= nil) then -- 224
						updateInferedDesc(infered) -- 225
						return { -- 226
							success = true, -- 226
							infered = infered -- 226
						} -- 226
					end -- 224
				elseif "yue" == lang then -- 227
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 228
					if not luaCodes then -- 229
						return { -- 229
							success = false -- 229
						} -- 229
					end -- 229
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 230
					if (infered ~= nil) then -- 231
						local col -- 232
						file, row, col = infered.file, infered.row, infered.col -- 232
						if file == "" and row > 0 and col > 0 then -- 233
							infered.row = lineMap[row] or 0 -- 234
							infered.col = 0 -- 235
						end -- 233
						updateInferedDesc(infered) -- 236
						return { -- 237
							success = true, -- 237
							infered = infered -- 237
						} -- 237
					end -- 231
				end -- 220
			end -- 218
		end -- 218
	end -- 218
	return { -- 217
		success = false -- 217
	} -- 217
end) -- 217
local _anon_func_0 = function(doc) -- 288
	local _accum_0 = { } -- 288
	local _len_0 = 1 -- 288
	local _list_0 = doc.params -- 288
	for _index_0 = 1, #_list_0 do -- 288
		local param = _list_0[_index_0] -- 288
		_accum_0[_len_0] = param.name -- 288
		_len_0 = _len_0 + 1 -- 288
	end -- 288
	return _accum_0 -- 288
end -- 288
local getParamDocs -- 239
getParamDocs = function(signatures) -- 239
	do -- 240
		local codes = Content:loadAsync(signatures[1].file) -- 240
		if codes then -- 240
			local comments = { } -- 241
			local params = { } -- 242
			local line = 0 -- 243
			local docs = { } -- 244
			local returnType = nil -- 245
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 246
				line = line + 1 -- 247
				local needBreak = true -- 248
				for i, _des_0 in ipairs(signatures) do -- 249
					local row = _des_0.row -- 249
					if line >= row and not (docs[i] ~= nil) then -- 250
						if #comments > 0 or #params > 0 or returnType then -- 251
							docs[i] = { -- 253
								doc = table.concat(comments, "  \n"), -- 253
								returnType = returnType -- 254
							} -- 252
							if #params > 0 then -- 256
								docs[i].params = params -- 256
							end -- 256
						else -- 258
							docs[i] = false -- 258
						end -- 251
					end -- 250
					if not docs[i] then -- 259
						needBreak = false -- 259
					end -- 259
				end -- 249
				if needBreak then -- 260
					break -- 260
				end -- 260
				local result = lineCode:match("%s*%-%- (.+)") -- 261
				if result then -- 261
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 262
					if not name then -- 263
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 264
					end -- 263
					if name then -- 265
						local pname = name -- 266
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 267
							pname = pname .. "?" -- 267
						end -- 267
						params[#params + 1] = { -- 269
							name = tostring(pname) .. ": " .. tostring(typ), -- 269
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 270
						} -- 268
					else -- 273
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 273
						if typ then -- 273
							if returnType then -- 274
								returnType = returnType .. ", " .. typ -- 275
							else -- 277
								returnType = typ -- 277
							end -- 274
							result = result:gsub("@return", "**return:**") -- 278
						end -- 273
						comments[#comments + 1] = result -- 279
					end -- 265
				elseif #comments > 0 then -- 280
					comments = { } -- 281
					params = { } -- 282
					returnType = nil -- 283
				end -- 261
			end -- 246
			local results = { } -- 284
			for _index_0 = 1, #docs do -- 285
				local doc = docs[_index_0] -- 285
				if not doc then -- 286
					goto _continue_0 -- 286
				end -- 286
				if doc.params then -- 287
					doc.desc = "function(" .. tostring(table.concat(_anon_func_0(doc), ', ')) .. ")" -- 288
				else -- 290
					doc.desc = "function()" -- 290
				end -- 287
				if doc.returnType then -- 291
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 292
					doc.returnType = nil -- 293
				end -- 291
				results[#results + 1] = doc -- 294
				::_continue_0:: -- 286
			end -- 285
			if #results > 0 then -- 295
				return results -- 295
			else -- 295
				return nil -- 295
			end -- 295
		end -- 240
	end -- 240
	return nil -- 239
end -- 239
HttpServer:postSchedule("/signature", function(req) -- 297
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
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 303
					if signatures then -- 303
						signatures = getParamDocs(signatures) -- 304
						if signatures then -- 304
							return { -- 305
								success = true, -- 305
								signatures = signatures -- 305
							} -- 305
						end -- 304
					end -- 303
				elseif "yue" == lang then -- 306
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 307
					if not luaCodes then -- 308
						return { -- 308
							success = false -- 308
						} -- 308
					end -- 308
					do -- 309
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 309
						if chainOp then -- 309
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 310
							if withVar then -- 310
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 311
							end -- 310
						end -- 309
					end -- 309
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 312
					if signatures then -- 312
						signatures = getParamDocs(signatures) -- 313
						if signatures then -- 313
							return { -- 314
								success = true, -- 314
								signatures = signatures -- 314
							} -- 314
						end -- 313
					else -- 315
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 315
						if signatures then -- 315
							signatures = getParamDocs(signatures) -- 316
							if signatures then -- 316
								return { -- 317
									success = true, -- 317
									signatures = signatures -- 317
								} -- 317
							end -- 316
						end -- 315
					end -- 312
				end -- 300
			end -- 298
		end -- 298
	end -- 298
	return { -- 297
		success = false -- 297
	} -- 297
end) -- 297
local luaKeywords = { -- 320
	'and', -- 320
	'break', -- 321
	'do', -- 322
	'else', -- 323
	'elseif', -- 324
	'end', -- 325
	'false', -- 326
	'for', -- 327
	'function', -- 328
	'goto', -- 329
	'if', -- 330
	'in', -- 331
	'local', -- 332
	'nil', -- 333
	'not', -- 334
	'or', -- 335
	'repeat', -- 336
	'return', -- 337
	'then', -- 338
	'true', -- 339
	'until', -- 340
	'while' -- 341
} -- 319
local tealKeywords = { -- 345
	'record', -- 345
	'as', -- 346
	'is', -- 347
	'type', -- 348
	'embed', -- 349
	'enum', -- 350
	'global', -- 351
	'any', -- 352
	'boolean', -- 353
	'integer', -- 354
	'number', -- 355
	'string', -- 356
	'thread' -- 357
} -- 344
local yueKeywords = { -- 361
	"and", -- 361
	"break", -- 362
	"do", -- 363
	"else", -- 364
	"elseif", -- 365
	"false", -- 366
	"for", -- 367
	"goto", -- 368
	"if", -- 369
	"in", -- 370
	"local", -- 371
	"nil", -- 372
	"not", -- 373
	"or", -- 374
	"repeat", -- 375
	"return", -- 376
	"then", -- 377
	"true", -- 378
	"until", -- 379
	"while", -- 380
	"as", -- 381
	"class", -- 382
	"continue", -- 383
	"export", -- 384
	"extends", -- 385
	"from", -- 386
	"global", -- 387
	"import", -- 388
	"macro", -- 389
	"switch", -- 390
	"try", -- 391
	"unless", -- 392
	"using", -- 393
	"when", -- 394
	"with" -- 395
} -- 360
local _anon_func_1 = function(Path, f) -- 431
	local _val_0 = Path:getExt(f) -- 431
	return "ttf" == _val_0 or "otf" == _val_0 -- 431
end -- 431
local _anon_func_2 = function(suggestions) -- 457
	local _tbl_0 = { } -- 457
	for _index_0 = 1, #suggestions do -- 457
		local item = suggestions[_index_0] -- 457
		_tbl_0[item[1] .. item[2]] = item -- 457
	end -- 457
	return _tbl_0 -- 457
end -- 457
HttpServer:postSchedule("/complete", function(req) -- 398
	do -- 399
		local _type_0 = type(req) -- 399
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 399
		if _tab_0 then -- 399
			local lang -- 399
			do -- 399
				local _obj_0 = req.body -- 399
				local _type_1 = type(_obj_0) -- 399
				if "table" == _type_1 or "userdata" == _type_1 then -- 399
					lang = _obj_0.lang -- 399
				end -- 399
			end -- 399
			local file -- 399
			do -- 399
				local _obj_0 = req.body -- 399
				local _type_1 = type(_obj_0) -- 399
				if "table" == _type_1 or "userdata" == _type_1 then -- 399
					file = _obj_0.file -- 399
				end -- 399
			end -- 399
			local content -- 399
			do -- 399
				local _obj_0 = req.body -- 399
				local _type_1 = type(_obj_0) -- 399
				if "table" == _type_1 or "userdata" == _type_1 then -- 399
					content = _obj_0.content -- 399
				end -- 399
			end -- 399
			local line -- 399
			do -- 399
				local _obj_0 = req.body -- 399
				local _type_1 = type(_obj_0) -- 399
				if "table" == _type_1 or "userdata" == _type_1 then -- 399
					line = _obj_0.line -- 399
				end -- 399
			end -- 399
			local row -- 399
			do -- 399
				local _obj_0 = req.body -- 399
				local _type_1 = type(_obj_0) -- 399
				if "table" == _type_1 or "userdata" == _type_1 then -- 399
					row = _obj_0.row -- 399
				end -- 399
			end -- 399
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 399
				local searchPath = getSearchPath(file) -- 400
				repeat -- 401
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 402
					if lang == "yue" then -- 403
						if not item then -- 404
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 404
						end -- 404
						if not item then -- 405
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 405
						end -- 405
					end -- 403
					local searchType = nil -- 406
					if not item then -- 407
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 408
						if lang == "yue" then -- 409
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 410
						end -- 409
						if (item ~= nil) then -- 411
							searchType = "Image" -- 411
						end -- 411
					end -- 407
					if not item then -- 412
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 413
						if lang == "yue" then -- 414
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 415
						end -- 414
						if (item ~= nil) then -- 416
							searchType = "Font" -- 416
						end -- 416
					end -- 412
					if not item then -- 417
						break -- 417
					end -- 417
					local searchPaths = Content.searchPaths -- 418
					local _list_0 = getSearchFolders(file) -- 419
					for _index_0 = 1, #_list_0 do -- 419
						local folder = _list_0[_index_0] -- 419
						searchPaths[#searchPaths + 1] = folder -- 420
					end -- 419
					if searchType then -- 421
						searchPaths[#searchPaths + 1] = Content.assetPath -- 421
					end -- 421
					local tokens -- 422
					do -- 422
						local _accum_0 = { } -- 422
						local _len_0 = 1 -- 422
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 422
							_accum_0[_len_0] = mod -- 422
							_len_0 = _len_0 + 1 -- 422
						end -- 422
						tokens = _accum_0 -- 422
					end -- 422
					local suggestions = { } -- 423
					for _index_0 = 1, #searchPaths do -- 424
						local path = searchPaths[_index_0] -- 424
						local sPath = Path(path, table.unpack(tokens)) -- 425
						if not Content:exist(sPath) then -- 426
							goto _continue_0 -- 426
						end -- 426
						if searchType == "Font" then -- 427
							local fontPath = Path(sPath, "Font") -- 428
							if Content:exist(fontPath) then -- 429
								local _list_1 = Content:getFiles(fontPath) -- 430
								for _index_1 = 1, #_list_1 do -- 430
									local f = _list_1[_index_1] -- 430
									if _anon_func_1(Path, f) then -- 431
										if "." == f:sub(1, 1) then -- 432
											goto _continue_1 -- 432
										end -- 432
										suggestions[#suggestions + 1] = { -- 433
											Path:getName(f), -- 433
											"font", -- 433
											"field" -- 433
										} -- 433
									end -- 431
									::_continue_1:: -- 431
								end -- 430
							end -- 429
						end -- 427
						local _list_1 = Content:getFiles(sPath) -- 434
						for _index_1 = 1, #_list_1 do -- 434
							local f = _list_1[_index_1] -- 434
							if "Image" == searchType then -- 435
								do -- 436
									local _exp_0 = Path:getExt(f) -- 436
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 436
										if "." == f:sub(1, 1) then -- 437
											goto _continue_2 -- 437
										end -- 437
										suggestions[#suggestions + 1] = { -- 438
											f, -- 438
											"image", -- 438
											"field" -- 438
										} -- 438
									end -- 436
								end -- 436
								goto _continue_2 -- 439
							elseif "Font" == searchType then -- 440
								do -- 441
									local _exp_0 = Path:getExt(f) -- 441
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 441
										if "." == f:sub(1, 1) then -- 442
											goto _continue_2 -- 442
										end -- 442
										suggestions[#suggestions + 1] = { -- 443
											f, -- 443
											"font", -- 443
											"field" -- 443
										} -- 443
									end -- 441
								end -- 441
								goto _continue_2 -- 444
							end -- 435
							local _exp_0 = Path:getExt(f) -- 445
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 445
								local name = Path:getName(f) -- 446
								if "d" == Path:getExt(name) then -- 447
									goto _continue_2 -- 447
								end -- 447
								if "." == name:sub(1, 1) then -- 448
									goto _continue_2 -- 448
								end -- 448
								suggestions[#suggestions + 1] = { -- 449
									name, -- 449
									"module", -- 449
									"field" -- 449
								} -- 449
							end -- 445
							::_continue_2:: -- 435
						end -- 434
						local _list_2 = Content:getDirs(sPath) -- 450
						for _index_1 = 1, #_list_2 do -- 450
							local dir = _list_2[_index_1] -- 450
							if "." == dir:sub(1, 1) then -- 451
								goto _continue_3 -- 451
							end -- 451
							suggestions[#suggestions + 1] = { -- 452
								dir, -- 452
								"folder", -- 452
								"variable" -- 452
							} -- 452
							::_continue_3:: -- 451
						end -- 450
						::_continue_0:: -- 425
					end -- 424
					if item == "" and not searchType then -- 453
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 454
						for _index_0 = 1, #_list_1 do -- 454
							local _des_0 = _list_1[_index_0] -- 454
							local name = _des_0[1] -- 454
							suggestions[#suggestions + 1] = { -- 455
								name, -- 455
								"dora module", -- 455
								"function" -- 455
							} -- 455
						end -- 454
					end -- 453
					if #suggestions > 0 then -- 456
						do -- 457
							local _accum_0 = { } -- 457
							local _len_0 = 1 -- 457
							for _, v in pairs(_anon_func_2(suggestions)) do -- 457
								_accum_0[_len_0] = v -- 457
								_len_0 = _len_0 + 1 -- 457
							end -- 457
							suggestions = _accum_0 -- 457
						end -- 457
						return { -- 458
							success = true, -- 458
							suggestions = suggestions -- 458
						} -- 458
					else -- 460
						return { -- 460
							success = false -- 460
						} -- 460
					end -- 456
				until true -- 401
				if "tl" == lang or "lua" == lang then -- 462
					do -- 463
						local isTIC80 = CheckTIC80Code(content) -- 463
						if isTIC80 then -- 463
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 464
						end -- 463
					end -- 463
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 465
					if not line:match("[%.:]$") then -- 466
						local checkSet -- 467
						do -- 467
							local _tbl_0 = { } -- 467
							for _index_0 = 1, #suggestions do -- 467
								local _des_0 = suggestions[_index_0] -- 467
								local name = _des_0[1] -- 467
								_tbl_0[name] = true -- 467
							end -- 467
							checkSet = _tbl_0 -- 467
						end -- 467
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 468
						for _index_0 = 1, #_list_0 do -- 468
							local item = _list_0[_index_0] -- 468
							if not checkSet[item[1]] then -- 469
								suggestions[#suggestions + 1] = item -- 469
							end -- 469
						end -- 468
						for _index_0 = 1, #luaKeywords do -- 470
							local word = luaKeywords[_index_0] -- 470
							suggestions[#suggestions + 1] = { -- 471
								word, -- 471
								"keyword", -- 471
								"keyword" -- 471
							} -- 471
						end -- 470
						if lang == "tl" then -- 472
							for _index_0 = 1, #tealKeywords do -- 473
								local word = tealKeywords[_index_0] -- 473
								suggestions[#suggestions + 1] = { -- 474
									word, -- 474
									"keyword", -- 474
									"keyword" -- 474
								} -- 474
							end -- 473
						end -- 472
					end -- 466
					if #suggestions > 0 then -- 475
						return { -- 476
							success = true, -- 476
							suggestions = suggestions -- 476
						} -- 476
					end -- 475
				elseif "yue" == lang then -- 477
					local suggestions = { } -- 478
					local gotGlobals = false -- 479
					do -- 480
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 480
						if luaCodes then -- 480
							gotGlobals = true -- 481
							do -- 482
								local chainOp = line:match("[^%w_]([%.\\])$") -- 482
								if chainOp then -- 482
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 483
									if not withVar then -- 484
										return { -- 484
											success = false -- 484
										} -- 484
									end -- 484
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 485
								elseif line:match("^([%.\\])$") then -- 486
									return { -- 487
										success = false -- 487
									} -- 487
								end -- 482
							end -- 482
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 488
							for _index_0 = 1, #_list_0 do -- 488
								local item = _list_0[_index_0] -- 488
								suggestions[#suggestions + 1] = item -- 488
							end -- 488
							if #suggestions == 0 then -- 489
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 490
								for _index_0 = 1, #_list_1 do -- 490
									local item = _list_1[_index_0] -- 490
									suggestions[#suggestions + 1] = item -- 490
								end -- 490
							end -- 489
						end -- 480
					end -- 480
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 491
						local checkSet -- 492
						do -- 492
							local _tbl_0 = { } -- 492
							for _index_0 = 1, #suggestions do -- 492
								local _des_0 = suggestions[_index_0] -- 492
								local name = _des_0[1] -- 492
								_tbl_0[name] = true -- 492
							end -- 492
							checkSet = _tbl_0 -- 492
						end -- 492
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 493
						for _index_0 = 1, #_list_0 do -- 493
							local item = _list_0[_index_0] -- 493
							if not checkSet[item[1]] then -- 494
								suggestions[#suggestions + 1] = item -- 494
							end -- 494
						end -- 493
						if not gotGlobals then -- 495
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 496
							for _index_0 = 1, #_list_1 do -- 496
								local item = _list_1[_index_0] -- 496
								if not checkSet[item[1]] then -- 497
									suggestions[#suggestions + 1] = item -- 497
								end -- 497
							end -- 496
						end -- 495
						for _index_0 = 1, #yueKeywords do -- 498
							local word = yueKeywords[_index_0] -- 498
							if not checkSet[word] then -- 499
								suggestions[#suggestions + 1] = { -- 500
									word, -- 500
									"keyword", -- 500
									"keyword" -- 500
								} -- 500
							end -- 499
						end -- 498
					end -- 491
					if #suggestions > 0 then -- 501
						return { -- 502
							success = true, -- 502
							suggestions = suggestions -- 502
						} -- 502
					end -- 501
				elseif "xml" == lang then -- 503
					local items = xml.complete(content) -- 504
					if #items > 0 then -- 505
						local suggestions -- 506
						do -- 506
							local _accum_0 = { } -- 506
							local _len_0 = 1 -- 506
							for _index_0 = 1, #items do -- 506
								local _des_0 = items[_index_0] -- 506
								local label, insertText = _des_0[1], _des_0[2] -- 506
								_accum_0[_len_0] = { -- 507
									label, -- 507
									insertText, -- 507
									"field" -- 507
								} -- 507
								_len_0 = _len_0 + 1 -- 507
							end -- 506
							suggestions = _accum_0 -- 506
						end -- 506
						return { -- 508
							success = true, -- 508
							suggestions = suggestions -- 508
						} -- 508
					end -- 505
				end -- 462
			end -- 399
		end -- 399
	end -- 399
	return { -- 398
		success = false -- 398
	} -- 398
end) -- 398
HttpServer:upload("/upload", function(req, filename) -- 512
	do -- 513
		local _type_0 = type(req) -- 513
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 513
		if _tab_0 then -- 513
			local path -- 513
			do -- 513
				local _obj_0 = req.params -- 513
				local _type_1 = type(_obj_0) -- 513
				if "table" == _type_1 or "userdata" == _type_1 then -- 513
					path = _obj_0.path -- 513
				end -- 513
			end -- 513
			if path ~= nil then -- 513
				local uploadPath = Path(Content.writablePath, ".upload") -- 514
				if not Content:exist(uploadPath) then -- 515
					Content:mkdir(uploadPath) -- 516
				end -- 515
				local targetPath = Path(uploadPath, filename) -- 517
				Content:mkdir(Path:getPath(targetPath)) -- 518
				return targetPath -- 519
			end -- 513
		end -- 513
	end -- 513
	return nil -- 512
end, function(req, file) -- 520
	do -- 521
		local _type_0 = type(req) -- 521
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 521
		if _tab_0 then -- 521
			local path -- 521
			do -- 521
				local _obj_0 = req.params -- 521
				local _type_1 = type(_obj_0) -- 521
				if "table" == _type_1 or "userdata" == _type_1 then -- 521
					path = _obj_0.path -- 521
				end -- 521
			end -- 521
			if path ~= nil then -- 521
				path = Path(Content.writablePath, path) -- 522
				if Content:exist(path) then -- 523
					local uploadPath = Path(Content.writablePath, ".upload") -- 524
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 525
					Content:mkdir(Path:getPath(targetPath)) -- 526
					if Content:move(file, targetPath) then -- 527
						return true -- 528
					end -- 527
				end -- 523
			end -- 521
		end -- 521
	end -- 521
	return false -- 520
end) -- 510
HttpServer:post("/list", function(req) -- 531
	do -- 532
		local _type_0 = type(req) -- 532
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 532
		if _tab_0 then -- 532
			local path -- 532
			do -- 532
				local _obj_0 = req.body -- 532
				local _type_1 = type(_obj_0) -- 532
				if "table" == _type_1 or "userdata" == _type_1 then -- 532
					path = _obj_0.path -- 532
				end -- 532
			end -- 532
			if path ~= nil then -- 532
				if Content:exist(path) then -- 533
					local files = { } -- 534
					local visitAssets -- 535
					visitAssets = function(path, folder) -- 535
						local dirs = Content:getDirs(path) -- 536
						for _index_0 = 1, #dirs do -- 537
							local dir = dirs[_index_0] -- 537
							if dir:match("^%.") then -- 538
								goto _continue_0 -- 538
							end -- 538
							local current -- 539
							if folder == "" then -- 539
								current = dir -- 540
							else -- 542
								current = Path(folder, dir) -- 542
							end -- 539
							files[#files + 1] = current -- 543
							visitAssets(Path(path, dir), current) -- 544
							::_continue_0:: -- 538
						end -- 537
						local fs = Content:getFiles(path) -- 545
						for _index_0 = 1, #fs do -- 546
							local f = fs[_index_0] -- 546
							if f:match("^%.") then -- 547
								goto _continue_1 -- 547
							end -- 547
							if folder == "" then -- 548
								files[#files + 1] = f -- 549
							else -- 551
								files[#files + 1] = Path(folder, f) -- 551
							end -- 548
							::_continue_1:: -- 547
						end -- 546
					end -- 535
					visitAssets(path, "") -- 552
					if #files == 0 then -- 553
						files = nil -- 553
					end -- 553
					return { -- 554
						success = true, -- 554
						files = files -- 554
					} -- 554
				end -- 533
			end -- 532
		end -- 532
	end -- 532
	return { -- 531
		success = false -- 531
	} -- 531
end) -- 531
HttpServer:post("/info", function() -- 556
	local Entry = require("Script.Dev.Entry") -- 557
	local webProfiler, drawerWidth -- 558
	do -- 558
		local _obj_0 = Entry.getConfig() -- 558
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 558
	end -- 558
	local engineDev = Entry.getEngineDev() -- 559
	Entry.connectWebIDE() -- 560
	return { -- 562
		platform = App.platform, -- 562
		locale = App.locale, -- 563
		version = App.version, -- 564
		engineDev = engineDev, -- 565
		webProfiler = webProfiler, -- 566
		drawerWidth = drawerWidth -- 567
	} -- 561
end) -- 556
HttpServer:post("/new", function(req) -- 569
	do -- 570
		local _type_0 = type(req) -- 570
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 570
		if _tab_0 then -- 570
			local path -- 570
			do -- 570
				local _obj_0 = req.body -- 570
				local _type_1 = type(_obj_0) -- 570
				if "table" == _type_1 or "userdata" == _type_1 then -- 570
					path = _obj_0.path -- 570
				end -- 570
			end -- 570
			local content -- 570
			do -- 570
				local _obj_0 = req.body -- 570
				local _type_1 = type(_obj_0) -- 570
				if "table" == _type_1 or "userdata" == _type_1 then -- 570
					content = _obj_0.content -- 570
				end -- 570
			end -- 570
			local folder -- 570
			do -- 570
				local _obj_0 = req.body -- 570
				local _type_1 = type(_obj_0) -- 570
				if "table" == _type_1 or "userdata" == _type_1 then -- 570
					folder = _obj_0.folder -- 570
				end -- 570
			end -- 570
			if path ~= nil and content ~= nil and folder ~= nil then -- 570
				if Content:exist(path) then -- 571
					return { -- 572
						success = false, -- 572
						message = "TargetExisted" -- 572
					} -- 572
				end -- 571
				local parent = Path:getPath(path) -- 573
				local files = Content:getFiles(parent) -- 574
				if folder then -- 575
					local name = Path:getFilename(path):lower() -- 576
					for _index_0 = 1, #files do -- 577
						local file = files[_index_0] -- 577
						if name == Path:getFilename(file):lower() then -- 578
							return { -- 579
								success = false, -- 579
								message = "TargetExisted" -- 579
							} -- 579
						end -- 578
					end -- 577
					if Content:mkdir(path) then -- 580
						return { -- 581
							success = true -- 581
						} -- 581
					end -- 580
				else -- 583
					local name = Path:getName(path):lower() -- 583
					for _index_0 = 1, #files do -- 584
						local file = files[_index_0] -- 584
						if name == Path:getName(file):lower() then -- 585
							local ext = Path:getExt(file) -- 586
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 587
								goto _continue_0 -- 588
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 589
								goto _continue_0 -- 590
							end -- 587
							return { -- 591
								success = false, -- 591
								message = "SourceExisted" -- 591
							} -- 591
						end -- 585
						::_continue_0:: -- 585
					end -- 584
					if Content:save(path, content) then -- 592
						return { -- 593
							success = true -- 593
						} -- 593
					end -- 592
				end -- 575
			end -- 570
		end -- 570
	end -- 570
	return { -- 569
		success = false, -- 569
		message = "Failed" -- 569
	} -- 569
end) -- 569
HttpServer:post("/delete", function(req) -- 595
	do -- 596
		local _type_0 = type(req) -- 596
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 596
		if _tab_0 then -- 596
			local path -- 596
			do -- 596
				local _obj_0 = req.body -- 596
				local _type_1 = type(_obj_0) -- 596
				if "table" == _type_1 or "userdata" == _type_1 then -- 596
					path = _obj_0.path -- 596
				end -- 596
			end -- 596
			if path ~= nil then -- 596
				if Content:exist(path) then -- 597
					local parent = Path:getPath(path) -- 598
					local files = Content:getFiles(parent) -- 599
					local name = Path:getName(path):lower() -- 600
					local ext = Path:getExt(path) -- 601
					for _index_0 = 1, #files do -- 602
						local file = files[_index_0] -- 602
						if name == Path:getName(file):lower() then -- 603
							local _exp_0 = Path:getExt(file) -- 604
							if "tl" == _exp_0 then -- 604
								if ("vs" == ext) then -- 604
									Content:remove(Path(parent, file)) -- 605
								end -- 604
							elseif "lua" == _exp_0 then -- 606
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 606
									Content:remove(Path(parent, file)) -- 607
								end -- 606
							end -- 604
						end -- 603
					end -- 602
					if Content:remove(path) then -- 608
						return { -- 609
							success = true -- 609
						} -- 609
					end -- 608
				end -- 597
			end -- 596
		end -- 596
	end -- 596
	return { -- 595
		success = false -- 595
	} -- 595
end) -- 595
HttpServer:post("/rename", function(req) -- 611
	do -- 612
		local _type_0 = type(req) -- 612
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 612
		if _tab_0 then -- 612
			local old -- 612
			do -- 612
				local _obj_0 = req.body -- 612
				local _type_1 = type(_obj_0) -- 612
				if "table" == _type_1 or "userdata" == _type_1 then -- 612
					old = _obj_0.old -- 612
				end -- 612
			end -- 612
			local new -- 612
			do -- 612
				local _obj_0 = req.body -- 612
				local _type_1 = type(_obj_0) -- 612
				if "table" == _type_1 or "userdata" == _type_1 then -- 612
					new = _obj_0.new -- 612
				end -- 612
			end -- 612
			if old ~= nil and new ~= nil then -- 612
				if Content:exist(old) and not Content:exist(new) then -- 613
					local parent = Path:getPath(new) -- 614
					local files = Content:getFiles(parent) -- 615
					if Content:isdir(old) then -- 616
						local name = Path:getFilename(new):lower() -- 617
						for _index_0 = 1, #files do -- 618
							local file = files[_index_0] -- 618
							if name == Path:getFilename(file):lower() then -- 619
								return { -- 620
									success = false -- 620
								} -- 620
							end -- 619
						end -- 618
					else -- 622
						local name = Path:getName(new):lower() -- 622
						local ext = Path:getExt(new) -- 623
						for _index_0 = 1, #files do -- 624
							local file = files[_index_0] -- 624
							if name == Path:getName(file):lower() then -- 625
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 626
									goto _continue_0 -- 627
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 628
									goto _continue_0 -- 629
								end -- 626
								return { -- 630
									success = false -- 630
								} -- 630
							end -- 625
							::_continue_0:: -- 625
						end -- 624
					end -- 616
					if Content:move(old, new) then -- 631
						local newParent = Path:getPath(new) -- 632
						parent = Path:getPath(old) -- 633
						files = Content:getFiles(parent) -- 634
						local newName = Path:getName(new) -- 635
						local oldName = Path:getName(old) -- 636
						local name = oldName:lower() -- 637
						local ext = Path:getExt(old) -- 638
						for _index_0 = 1, #files do -- 639
							local file = files[_index_0] -- 639
							if name == Path:getName(file):lower() then -- 640
								local _exp_0 = Path:getExt(file) -- 641
								if "tl" == _exp_0 then -- 641
									if ("vs" == ext) then -- 641
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 642
									end -- 641
								elseif "lua" == _exp_0 then -- 643
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 643
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 644
									end -- 643
								end -- 641
							end -- 640
						end -- 639
						return { -- 645
							success = true -- 645
						} -- 645
					end -- 631
				end -- 613
			end -- 612
		end -- 612
	end -- 612
	return { -- 611
		success = false -- 611
	} -- 611
end) -- 611
HttpServer:post("/exist", function(req) -- 647
	do -- 648
		local _type_0 = type(req) -- 648
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 648
		if _tab_0 then -- 648
			local file -- 648
			do -- 648
				local _obj_0 = req.body -- 648
				local _type_1 = type(_obj_0) -- 648
				if "table" == _type_1 or "userdata" == _type_1 then -- 648
					file = _obj_0.file -- 648
				end -- 648
			end -- 648
			if file ~= nil then -- 648
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
							return { -- 656
								success = Content:exist(file) -- 656
							} -- 656
						end -- 650
					end -- 649
				end -- 649
				return { -- 657
					success = Content:exist(file) -- 657
				} -- 657
			end -- 648
		end -- 648
	end -- 648
	return { -- 647
		success = false -- 647
	} -- 647
end) -- 647
HttpServer:postSchedule("/read", function(req) -- 659
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
				end -- 660
			end -- 660
			if path ~= nil then -- 660
				local readFile -- 661
				readFile = function() -- 661
					if Content:exist(path) then -- 662
						local content = Content:loadAsync(path) -- 663
						if content then -- 663
							return { -- 664
								content = content, -- 664
								success = true -- 664
							} -- 664
						end -- 663
					end -- 662
					return nil -- 661
				end -- 661
				do -- 665
					local projFile = req.body.projFile -- 665
					if projFile then -- 665
						local projDir = getProjectDirFromFile(projFile) -- 666
						if projDir then -- 666
							local scriptDir = Path(projDir, "Script") -- 667
							local searchPaths = Content.searchPaths -- 668
							if Content:exist(scriptDir) then -- 669
								Content:addSearchPath(scriptDir) -- 669
							end -- 669
							if Content:exist(projDir) then -- 670
								Content:addSearchPath(projDir) -- 670
							end -- 670
							local _ <close> = setmetatable({ }, { -- 671
								__close = function() -- 671
									Content.searchPaths = searchPaths -- 671
								end -- 671
							}) -- 671
							local result = readFile() -- 672
							if result then -- 672
								return result -- 672
							end -- 672
						end -- 666
					end -- 665
				end -- 665
				local result = readFile() -- 673
				if result then -- 673
					return result -- 673
				end -- 673
			end -- 660
		end -- 660
	end -- 660
	return { -- 659
		success = false -- 659
	} -- 659
end) -- 659
HttpServer:post("/read-sync", function(req) -- 675
	do -- 676
		local _type_0 = type(req) -- 676
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 676
		if _tab_0 then -- 676
			local path -- 676
			do -- 676
				local _obj_0 = req.body -- 676
				local _type_1 = type(_obj_0) -- 676
				if "table" == _type_1 or "userdata" == _type_1 then -- 676
					path = _obj_0.path -- 676
				end -- 676
			end -- 676
			local exts -- 676
			do -- 676
				local _obj_0 = req.body -- 676
				local _type_1 = type(_obj_0) -- 676
				if "table" == _type_1 or "userdata" == _type_1 then -- 676
					exts = _obj_0.exts -- 676
				end -- 676
			end -- 676
			if path ~= nil and exts ~= nil then -- 676
				local readFile -- 677
				readFile = function() -- 677
					for _index_0 = 1, #exts do -- 678
						local ext = exts[_index_0] -- 678
						local targetPath = path .. ext -- 679
						if Content:exist(targetPath) then -- 680
							local content = Content:load(targetPath) -- 681
							if content then -- 681
								return { -- 682
									content = content, -- 682
									success = true, -- 682
									fullPath = Content:getFullPath(targetPath) -- 682
								} -- 682
							end -- 681
						end -- 680
					end -- 678
					return nil -- 677
				end -- 677
				local searchPaths = Content.searchPaths -- 683
				local _ <close> = setmetatable({ }, { -- 684
					__close = function() -- 684
						Content.searchPaths = searchPaths -- 684
					end -- 684
				}) -- 684
				do -- 685
					local projFile = req.body.projFile -- 685
					if projFile then -- 685
						local projDir = getProjectDirFromFile(projFile) -- 686
						if projDir then -- 686
							local scriptDir = Path(projDir, "Script") -- 687
							if Content:exist(scriptDir) then -- 688
								Content:addSearchPath(scriptDir) -- 688
							end -- 688
							if Content:exist(projDir) then -- 689
								Content:addSearchPath(projDir) -- 689
							end -- 689
						else -- 691
							projDir = Path:getPath(projFile) -- 691
							if Content:exist(projDir) then -- 692
								Content:addSearchPath(projDir) -- 692
							end -- 692
						end -- 686
					end -- 685
				end -- 685
				local result = readFile() -- 693
				if result then -- 693
					return result -- 693
				end -- 693
			end -- 676
		end -- 676
	end -- 676
	return { -- 675
		success = false -- 675
	} -- 675
end) -- 675
local compileFileAsync -- 695
compileFileAsync = function(inputFile, sourceCodes) -- 695
	local file = inputFile -- 696
	local searchPath -- 697
	do -- 697
		local dir = getProjectDirFromFile(inputFile) -- 697
		if dir then -- 697
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 698
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 699
		else -- 701
			file = Path:getRelative(inputFile, Content.writablePath) -- 701
			if file:sub(1, 2) == ".." then -- 702
				file = Path:getRelative(inputFile, Content.assetPath) -- 703
			end -- 702
			searchPath = "" -- 704
		end -- 697
	end -- 697
	local outputFile = Path:replaceExt(inputFile, "lua") -- 705
	local yueext = yue.options.extension -- 706
	local resultCodes = nil -- 707
	do -- 708
		local _exp_0 = Path:getExt(inputFile) -- 708
		if yueext == _exp_0 then -- 708
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 709
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 710
				if not codes then -- 711
					return -- 711
				end -- 711
				local extraGlobal -- 712
				if isTIC80 then -- 712
					extraGlobal = tic80APIs -- 712
				else -- 712
					extraGlobal = nil -- 712
				end -- 712
				local success, result = LintYueGlobals(codes, globals, true, extraGlobal) -- 713
				if not success then -- 714
					return -- 714
				end -- 714
				if codes == "" then -- 715
					resultCodes = "" -- 716
					return nil -- 717
				end -- 715
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 718
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 719
				codes = codes:gsub("^\n*", "") -- 720
				if not (result == "") then -- 721
					result = result .. "\n" -- 721
				end -- 721
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 722
				return resultCodes -- 723
			end, function(success) -- 710
				if not success then -- 724
					Content:remove(outputFile) -- 725
					if resultCodes == nil then -- 726
						resultCodes = false -- 727
					end -- 726
				end -- 724
			end) -- 710
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
		end -- 708
	end -- 708
	wait(function() -- 747
		return resultCodes ~= nil -- 747
	end) -- 747
	if resultCodes then -- 748
		return resultCodes -- 748
	end -- 748
	return nil -- 695
end -- 695
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
local _anon_func_3 = function(Path, path) -- 1112
	local _val_0 = Path:getExt(path) -- 1112
	return "ts" == _val_0 or "tsx" == _val_0 -- 1112
end -- 1112
local _anon_func_4 = function(Path, f) -- 1142
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
					if not (_anon_func_3(Path, path)) then -- 1112
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
						if not (_anon_func_4(Path, f)) then -- 1142
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
