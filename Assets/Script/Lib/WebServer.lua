-- [yue]: Script/Lib/WebServer.yue
local HttpServer = dora.HttpServer -- 1
local Path = dora.Path -- 1
local Content = dora.Content -- 1
local yue = dora.yue -- 1
local tostring = _G.tostring -- 1
local load = _G.load -- 1
local tonumber = _G.tonumber -- 1
local teal = dora.teal -- 1
local type = _G.type -- 1
local xml = dora.xml -- 1
local table = _G.table -- 1
local ipairs = _G.ipairs -- 1
local pairs = _G.pairs -- 1
local App = dora.App -- 1
local wait = dora.wait -- 1
local emit = dora.emit -- 1
local thread = dora.thread -- 1
local print = _G.print -- 1
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
	local writablePath = Content.writablePath -- 18
	if writablePath ~= file:sub(1, #writablePath) then -- 19
		return nil -- 19
	end -- 19
	local current = Path:getRelative(file, writablePath) -- 20
	repeat -- 21
		current = Path:getPath(current) -- 22
		if current == "" then -- 23
			break -- 23
		end -- 23
		local _list_0 = Content:getFiles(Path(writablePath, current)) -- 24
		for _index_0 = 1, #_list_0 do -- 24
			local f = _list_0[_index_0] -- 24
			if Path:getName(f):lower() == "init" then -- 25
				return Path(current, Path:getPath(f)) -- 26
			end -- 25
		end -- 26
	until false -- 27
	return nil -- 28
end -- 17
local getSearchPath -- 30
getSearchPath = function(file) -- 30
	do -- 31
		local dir = getProjectDirFromFile(file) -- 31
		if dir then -- 31
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 32
		end -- 31
	end -- 31
	return "" -- 32
end -- 30
local getSearchFolders -- 34
getSearchFolders = function(file) -- 34
	do -- 35
		local dir = getProjectDirFromFile(file) -- 35
		if dir then -- 35
			return { -- 37
				Path(dir, "Script"), -- 37
				dir -- 38
			} -- 38
		end -- 35
	end -- 35
	return { } -- 34
end -- 34
local disabledCheckForLua = { -- 41
	"incompatible number of returns", -- 41
	"unknown variable", -- 42
	"cannot index key", -- 43
	"module not found", -- 44
	"don't know how to resolve a dynamic require", -- 45
	"ContainerItem", -- 46
	"cannot resolve a type", -- 47
	"invalid key", -- 48
	"inconsistent index type", -- 49
	"cannot use operator '#'", -- 50
	"attempting ipairs loop", -- 51
	"expects record or nominal", -- 52
	"variable is not being assigned a value", -- 53
	"<unknown type>", -- 54
	"<invalid type>", -- 55
	"using the '#' operator on this map will always return 0", -- 56
	"can't match a record to a map with non%-string keys", -- 57
	"redeclaration of variable" -- 58
} -- 40
local yueCheck -- 60
yueCheck = function(file, content) -- 60
	local searchPath = getSearchPath(file) -- 61
	local checkResult, luaCodes = yue.checkAsync(content, searchPath) -- 62
	local info = { } -- 63
	local globals = { } -- 64
	for _index_0 = 1, #checkResult do -- 65
		local _des_0 = checkResult[_index_0] -- 65
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 65
		if "error" == t then -- 66
			info[#info + 1] = { -- 67
				"syntax", -- 67
				file, -- 67
				line, -- 67
				col, -- 67
				msg -- 67
			} -- 67
		elseif "global" == t then -- 68
			globals[#globals + 1] = { -- 69
				msg, -- 69
				line, -- 69
				col -- 69
			} -- 69
		end -- 69
	end -- 69
	if luaCodes then -- 70
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 71
		if success then -- 72
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 73
			if not (lintResult == "") then -- 74
				lintResult = lintResult .. "\n" -- 74
			end -- 74
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 75
		else -- 76
			for _index_0 = 1, #lintResult do -- 76
				local _des_0 = lintResult[_index_0] -- 76
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 76
				info[#info + 1] = { -- 77
					"syntax", -- 77
					file, -- 77
					line, -- 77
					col, -- 77
					"invalid global variable" -- 77
				} -- 77
			end -- 77
		end -- 72
	end -- 70
	return luaCodes, info -- 78
end -- 60
local luaCheck -- 80
luaCheck = function(file, content) -- 80
	local res, err = load(content, "check") -- 81
	if not res then -- 82
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 83
		return { -- 84
			success = false, -- 84
			info = { -- 84
				{ -- 84
					"syntax", -- 84
					file, -- 84
					tonumber(line), -- 84
					0, -- 84
					msg -- 84
				} -- 84
			} -- 84
		} -- 84
	end -- 82
	local success, info = teal.checkAsync(content, file, true, "") -- 85
	if info then -- 86
		do -- 87
			local _accum_0 = { } -- 87
			local _len_0 = 1 -- 87
			for _index_0 = 1, #info do -- 87
				local item = info[_index_0] -- 87
				local useCheck = true -- 88
				for _index_1 = 1, #disabledCheckForLua do -- 89
					local check = disabledCheckForLua[_index_1] -- 89
					if not item[5]:match("unused") and item[5]:match(check) then -- 90
						useCheck = false -- 91
					end -- 90
				end -- 91
				if not useCheck then -- 92
					goto _continue_0 -- 92
				end -- 92
				do -- 93
					local _exp_0 = item[1] -- 93
					if "type" == _exp_0 then -- 94
						item[1] = "warning" -- 95
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 96
						goto _continue_0 -- 97
					end -- 97
				end -- 97
				_accum_0[_len_0] = item -- 98
				_len_0 = _len_0 + 1 -- 98
				::_continue_0:: -- 88
			end -- 98
			info = _accum_0 -- 87
		end -- 98
		if #info == 0 then -- 99
			info = nil -- 100
			success = true -- 101
		end -- 99
	end -- 86
	return { -- 102
		success = success, -- 102
		info = info -- 102
	} -- 102
end -- 80
local luaCheckWithLineInfo -- 104
luaCheckWithLineInfo = function(file, luaCodes) -- 104
	local res = luaCheck(file, luaCodes) -- 105
	local info = { } -- 106
	if not res.success then -- 107
		local current = 1 -- 108
		local lastLine = 1 -- 109
		local lineMap = { } -- 110
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 111
			local num = lineCode:match("--%s*(%d+)%s*$") -- 112
			if num then -- 113
				lastLine = tonumber(num) -- 114
			end -- 113
			lineMap[current] = lastLine -- 115
			current = current + 1 -- 116
		end -- 116
		local _list_0 = res.info -- 117
		for _index_0 = 1, #_list_0 do -- 117
			local item = _list_0[_index_0] -- 117
			item[3] = lineMap[item[3]] or 0 -- 118
			item[4] = 0 -- 119
			info[#info + 1] = item -- 120
		end -- 120
		return false, info -- 121
	end -- 107
	return true, info -- 122
end -- 104
local getCompiledYueLine -- 124
getCompiledYueLine = function(content, line, row, file) -- 124
	local luaCodes, info = yueCheck(file, content) -- 125
	if not luaCodes then -- 126
		return nil -- 126
	end -- 126
	local current = 1 -- 127
	local lastLine = 1 -- 128
	local targetLine = nil -- 129
	local targetRow = nil -- 130
	local lineMap = { } -- 131
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 132
		local num = lineCode:match("--%s*(%d+)%s*$") -- 133
		if num then -- 134
			lastLine = tonumber(num) -- 134
		end -- 134
		lineMap[current] = lastLine -- 135
		if row == lastLine and not targetLine then -- 136
			targetRow = current -- 137
			targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 138
			if targetLine then -- 139
				break -- 139
			end -- 139
		end -- 136
		current = current + 1 -- 140
	end -- 140
	if targetLine and targetRow then -- 141
		return luaCodes, targetLine, targetRow, lineMap -- 142
	else -- 144
		return nil -- 144
	end -- 141
end -- 124
HttpServer:postSchedule("/check", function(req) -- 146
	do -- 147
		local _type_0 = type(req) -- 147
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 147
		if _tab_0 then -- 147
			local file -- 147
			do -- 147
				local _obj_0 = req.body -- 147
				local _type_1 = type(_obj_0) -- 147
				if "table" == _type_1 or "userdata" == _type_1 then -- 147
					file = _obj_0.file -- 147
				end -- 177
			end -- 177
			local content -- 147
			do -- 147
				local _obj_0 = req.body -- 147
				local _type_1 = type(_obj_0) -- 147
				if "table" == _type_1 or "userdata" == _type_1 then -- 147
					content = _obj_0.content -- 147
				end -- 177
			end -- 177
			if file ~= nil and content ~= nil then -- 147
				local ext = Path:getExt(file) -- 148
				if "tl" == ext then -- 149
					local searchPath = getSearchPath(file) -- 150
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 151
					return { -- 152
						success = success, -- 152
						info = info -- 152
					} -- 152
				elseif "lua" == ext then -- 153
					return luaCheck(file, content) -- 154
				elseif "yue" == ext then -- 155
					local luaCodes, info = yueCheck(file, content) -- 156
					local success = false -- 157
					if luaCodes then -- 158
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 159
						do -- 160
							local _tab_1 = { } -- 160
							local _idx_0 = #_tab_1 + 1 -- 160
							for _index_0 = 1, #info do -- 160
								local _value_0 = info[_index_0] -- 160
								_tab_1[_idx_0] = _value_0 -- 160
								_idx_0 = _idx_0 + 1 -- 160
							end -- 160
							local _idx_1 = #_tab_1 + 1 -- 160
							for _index_0 = 1, #luaInfo do -- 160
								local _value_0 = luaInfo[_index_0] -- 160
								_tab_1[_idx_1] = _value_0 -- 160
								_idx_1 = _idx_1 + 1 -- 160
							end -- 160
							info = _tab_1 -- 160
						end -- 160
						success = success and luaSuccess -- 161
					end -- 158
					if #info > 0 then -- 162
						return { -- 163
							success = success, -- 163
							info = info -- 163
						} -- 163
					else -- 165
						return { -- 165
							success = success -- 165
						} -- 165
					end -- 162
				elseif "xml" == ext then -- 166
					local success, result = xml.check(content) -- 167
					if success then -- 168
						local info -- 169
						success, info = luaCheckWithLineInfo(file, result) -- 169
						if #info > 0 then -- 170
							return { -- 171
								success = success, -- 171
								info = info -- 171
							} -- 171
						else -- 173
							return { -- 173
								success = success -- 173
							} -- 173
						end -- 170
					else -- 175
						local info -- 175
						do -- 175
							local _accum_0 = { } -- 175
							local _len_0 = 1 -- 175
							for _index_0 = 1, #result do -- 175
								local _des_0 = result[_index_0] -- 175
								local row, err = _des_0[1], _des_0[2] -- 175
								_accum_0[_len_0] = { -- 176
									"syntax", -- 176
									file, -- 176
									row, -- 176
									0, -- 176
									err -- 176
								} -- 176
								_len_0 = _len_0 + 1 -- 176
							end -- 176
							info = _accum_0 -- 175
						end -- 176
						return { -- 177
							success = false, -- 177
							info = info -- 177
						} -- 177
					end -- 168
				end -- 177
			end -- 147
		end -- 177
	end -- 177
	return { -- 146
		success = true -- 146
	} -- 177
end) -- 146
local updateInferedDesc -- 179
updateInferedDesc = function(infered) -- 179
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 180
		return -- 180
	end -- 180
	local key, row = infered.key, infered.row -- 181
	local codes = Content:loadAsync(key) -- 182
	if codes then -- 182
		local comments = { } -- 183
		local line = 0 -- 184
		local skipping = false -- 185
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 186
			line = line + 1 -- 187
			if line >= row then -- 188
				break -- 188
			end -- 188
			if lineCode:match("^%s*%-%- @") then -- 189
				skipping = true -- 190
				goto _continue_0 -- 191
			end -- 189
			local result = lineCode:match("^%s*%-%- (.+)") -- 192
			if result then -- 192
				if not skipping then -- 193
					comments[#comments + 1] = result -- 193
				end -- 193
			elseif #comments > 0 then -- 194
				comments = { } -- 195
				skipping = false -- 196
			end -- 192
			::_continue_0:: -- 187
		end -- 196
		infered.doc = table.concat(comments, "\n") -- 197
	end -- 182
end -- 179
HttpServer:postSchedule("/infer", function(req) -- 199
	do -- 200
		local _type_0 = type(req) -- 200
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 200
		if _tab_0 then -- 200
			local lang -- 200
			do -- 200
				local _obj_0 = req.body -- 200
				local _type_1 = type(_obj_0) -- 200
				if "table" == _type_1 or "userdata" == _type_1 then -- 200
					lang = _obj_0.lang -- 200
				end -- 217
			end -- 217
			local file -- 200
			do -- 200
				local _obj_0 = req.body -- 200
				local _type_1 = type(_obj_0) -- 200
				if "table" == _type_1 or "userdata" == _type_1 then -- 200
					file = _obj_0.file -- 200
				end -- 217
			end -- 217
			local content -- 200
			do -- 200
				local _obj_0 = req.body -- 200
				local _type_1 = type(_obj_0) -- 200
				if "table" == _type_1 or "userdata" == _type_1 then -- 200
					content = _obj_0.content -- 200
				end -- 217
			end -- 217
			local line -- 200
			do -- 200
				local _obj_0 = req.body -- 200
				local _type_1 = type(_obj_0) -- 200
				if "table" == _type_1 or "userdata" == _type_1 then -- 200
					line = _obj_0.line -- 200
				end -- 217
			end -- 217
			local row -- 200
			do -- 200
				local _obj_0 = req.body -- 200
				local _type_1 = type(_obj_0) -- 200
				if "table" == _type_1 or "userdata" == _type_1 then -- 200
					row = _obj_0.row -- 200
				end -- 217
			end -- 217
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 200
				local searchPath = getSearchPath(file) -- 201
				if "tl" == lang or "lua" == lang then -- 202
					local infered = teal.inferAsync(content, line, row, searchPath) -- 203
					if (infered ~= nil) then -- 204
						updateInferedDesc(infered) -- 205
						return { -- 206
							success = true, -- 206
							infered = infered -- 206
						} -- 206
					end -- 204
				elseif "yue" == lang then -- 207
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file) -- 208
					if not luaCodes then -- 209
						return { -- 209
							success = false -- 209
						} -- 209
					end -- 209
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 210
					if (infered ~= nil) then -- 211
						local col -- 212
						file, row, col = infered.file, infered.row, infered.col -- 212
						if file == "" and row > 0 and col > 0 then -- 213
							infered.row = lineMap[row] or 0 -- 214
							infered.col = 0 -- 215
						end -- 213
						updateInferedDesc(infered) -- 216
						return { -- 217
							success = true, -- 217
							infered = infered -- 217
						} -- 217
					end -- 211
				end -- 217
			end -- 200
		end -- 217
	end -- 217
	return { -- 199
		success = false -- 199
	} -- 217
end) -- 199
local _anon_func_0 = function(doc) -- 268
	local _accum_0 = { } -- 268
	local _len_0 = 1 -- 268
	local _list_0 = doc.params -- 268
	for _index_0 = 1, #_list_0 do -- 268
		local param = _list_0[_index_0] -- 268
		_accum_0[_len_0] = param.name -- 268
		_len_0 = _len_0 + 1 -- 268
	end -- 268
	return _accum_0 -- 268
end -- 268
local getParamDocs -- 219
getParamDocs = function(signatures) -- 219
	do -- 220
		local codes = Content:loadAsync(signatures[1].file) -- 220
		if codes then -- 220
			local comments = { } -- 221
			local params = { } -- 222
			local line = 0 -- 223
			local docs = { } -- 224
			local returnType = nil -- 225
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 226
				line = line + 1 -- 227
				local needBreak = true -- 228
				for i, _des_0 in ipairs(signatures) do -- 229
					local row = _des_0.row -- 229
					if line >= row and not (docs[i] ~= nil) then -- 230
						if #comments > 0 or #params > 0 or returnType then -- 231
							docs[i] = { -- 233
								doc = table.concat(comments, "  \n"), -- 233
								returnType = returnType -- 234
							} -- 232
							if #params > 0 then -- 236
								docs[i].params = params -- 236
							end -- 236
						else -- 238
							docs[i] = false -- 238
						end -- 231
					end -- 230
					if not docs[i] then -- 239
						needBreak = false -- 239
					end -- 239
				end -- 239
				if needBreak then -- 240
					break -- 240
				end -- 240
				local result = lineCode:match("%s*%-%- (.+)") -- 241
				if result then -- 241
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 242
					if not name then -- 243
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 244
					end -- 243
					if name then -- 245
						local pname = name -- 246
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 247
							pname = pname .. "?" -- 247
						end -- 247
						params[#params + 1] = { -- 249
							name = tostring(pname) .. ": " .. tostring(typ), -- 249
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 250
						} -- 248
					else -- 253
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 253
						if typ then -- 253
							if returnType then -- 254
								returnType = returnType .. ", " .. typ -- 255
							else -- 257
								returnType = typ -- 257
							end -- 254
							result = result:gsub("@return", "**return:**") -- 258
						end -- 253
						comments[#comments + 1] = result -- 259
					end -- 245
				elseif #comments > 0 then -- 260
					comments = { } -- 261
					params = { } -- 262
					returnType = nil -- 263
				end -- 241
			end -- 263
			local results = { } -- 264
			for _index_0 = 1, #docs do -- 265
				local doc = docs[_index_0] -- 265
				if not doc then -- 266
					goto _continue_0 -- 266
				end -- 266
				if doc.params then -- 267
					doc.desc = "function(" .. tostring(table.concat(_anon_func_0(doc), ', ')) .. ")" -- 268
				else -- 270
					doc.desc = "function()" -- 270
				end -- 267
				if doc.returnType then -- 271
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 272
					doc.returnType = nil -- 273
				end -- 271
				results[#results + 1] = doc -- 274
				::_continue_0:: -- 266
			end -- 274
			if #results > 0 then -- 275
				return results -- 275
			else -- 275
				return nil -- 275
			end -- 275
		end -- 220
	end -- 220
	return nil -- 275
end -- 219
HttpServer:postSchedule("/signature", function(req) -- 277
	do -- 278
		local _type_0 = type(req) -- 278
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 278
		if _tab_0 then -- 278
			local lang -- 278
			do -- 278
				local _obj_0 = req.body -- 278
				local _type_1 = type(_obj_0) -- 278
				if "table" == _type_1 or "userdata" == _type_1 then -- 278
					lang = _obj_0.lang -- 278
				end -- 295
			end -- 295
			local file -- 278
			do -- 278
				local _obj_0 = req.body -- 278
				local _type_1 = type(_obj_0) -- 278
				if "table" == _type_1 or "userdata" == _type_1 then -- 278
					file = _obj_0.file -- 278
				end -- 295
			end -- 295
			local content -- 278
			do -- 278
				local _obj_0 = req.body -- 278
				local _type_1 = type(_obj_0) -- 278
				if "table" == _type_1 or "userdata" == _type_1 then -- 278
					content = _obj_0.content -- 278
				end -- 295
			end -- 295
			local line -- 278
			do -- 278
				local _obj_0 = req.body -- 278
				local _type_1 = type(_obj_0) -- 278
				if "table" == _type_1 or "userdata" == _type_1 then -- 278
					line = _obj_0.line -- 278
				end -- 295
			end -- 295
			local row -- 278
			do -- 278
				local _obj_0 = req.body -- 278
				local _type_1 = type(_obj_0) -- 278
				if "table" == _type_1 or "userdata" == _type_1 then -- 278
					row = _obj_0.row -- 278
				end -- 295
			end -- 295
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 278
				local searchPath = getSearchPath(file) -- 279
				if "tl" == lang or "lua" == lang then -- 280
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 281
					if signatures then -- 281
						signatures = getParamDocs(signatures) -- 282
						if signatures then -- 282
							return { -- 283
								success = true, -- 283
								signatures = signatures -- 283
							} -- 283
						end -- 282
					end -- 281
				elseif "yue" == lang then -- 284
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file) -- 285
					if not luaCodes then -- 286
						return { -- 286
							success = false -- 286
						} -- 286
					end -- 286
					do -- 287
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 287
						if chainOp then -- 287
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 288
							targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 289
						end -- 287
					end -- 287
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 290
					if signatures then -- 290
						signatures = getParamDocs(signatures) -- 291
						if signatures then -- 291
							return { -- 292
								success = true, -- 292
								signatures = signatures -- 292
							} -- 292
						end -- 291
					else -- 293
						signatures = teal.getSignatureAsync(luaCodes, "dora." .. tostring(targetLine), targetRow, searchPath) -- 293
						if signatures then -- 293
							signatures = getParamDocs(signatures) -- 294
							if signatures then -- 294
								return { -- 295
									success = true, -- 295
									signatures = signatures -- 295
								} -- 295
							end -- 294
						end -- 293
					end -- 290
				end -- 295
			end -- 278
		end -- 295
	end -- 295
	return { -- 277
		success = false -- 277
	} -- 295
end) -- 277
local luaKeywords = { -- 298
	'and', -- 298
	'break', -- 299
	'do', -- 300
	'else', -- 301
	'elseif', -- 302
	'end', -- 303
	'false', -- 304
	'for', -- 305
	'function', -- 306
	'goto', -- 307
	'if', -- 308
	'in', -- 309
	'local', -- 310
	'nil', -- 311
	'not', -- 312
	'or', -- 313
	'repeat', -- 314
	'return', -- 315
	'then', -- 316
	'true', -- 317
	'until', -- 318
	'while' -- 319
} -- 297
local tealKeywords = { -- 323
	'record', -- 323
	'as', -- 324
	'is', -- 325
	'type', -- 326
	'embed', -- 327
	'enum', -- 328
	'global', -- 329
	'any', -- 330
	'boolean', -- 331
	'integer', -- 332
	'number', -- 333
	'string', -- 334
	'thread' -- 335
} -- 322
local yueKeywords = { -- 339
	"and", -- 339
	"break", -- 340
	"do", -- 341
	"else", -- 342
	"elseif", -- 343
	"false", -- 344
	"for", -- 345
	"goto", -- 346
	"if", -- 347
	"in", -- 348
	"local", -- 349
	"nil", -- 350
	"not", -- 351
	"or", -- 352
	"repeat", -- 353
	"return", -- 354
	"then", -- 355
	"true", -- 356
	"until", -- 357
	"while", -- 358
	"as", -- 359
	"class", -- 360
	"continue", -- 361
	"export", -- 362
	"extends", -- 363
	"from", -- 364
	"global", -- 365
	"import", -- 366
	"macro", -- 367
	"switch", -- 368
	"try", -- 369
	"unless", -- 370
	"using", -- 371
	"when", -- 372
	"with" -- 373
} -- 338
local _anon_func_1 = function(Path, f) -- 409
	local _val_0 = Path:getExt(f) -- 409
	return "ttf" == _val_0 or "otf" == _val_0 -- 409
end -- 409
local _anon_func_2 = function(suggestions) -- 435
	local _tbl_0 = { } -- 435
	for _index_0 = 1, #suggestions do -- 435
		local item = suggestions[_index_0] -- 435
		_tbl_0[item[1] .. item[2]] = item -- 435
	end -- 435
	return _tbl_0 -- 435
end -- 435
HttpServer:postSchedule("/complete", function(req) -- 376
	do -- 377
		local _type_0 = type(req) -- 377
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 377
		if _tab_0 then -- 377
			local lang -- 377
			do -- 377
				local _obj_0 = req.body -- 377
				local _type_1 = type(_obj_0) -- 377
				if "table" == _type_1 or "userdata" == _type_1 then -- 377
					lang = _obj_0.lang -- 377
				end -- 484
			end -- 484
			local file -- 377
			do -- 377
				local _obj_0 = req.body -- 377
				local _type_1 = type(_obj_0) -- 377
				if "table" == _type_1 or "userdata" == _type_1 then -- 377
					file = _obj_0.file -- 377
				end -- 484
			end -- 484
			local content -- 377
			do -- 377
				local _obj_0 = req.body -- 377
				local _type_1 = type(_obj_0) -- 377
				if "table" == _type_1 or "userdata" == _type_1 then -- 377
					content = _obj_0.content -- 377
				end -- 484
			end -- 484
			local line -- 377
			do -- 377
				local _obj_0 = req.body -- 377
				local _type_1 = type(_obj_0) -- 377
				if "table" == _type_1 or "userdata" == _type_1 then -- 377
					line = _obj_0.line -- 377
				end -- 484
			end -- 484
			local row -- 377
			do -- 377
				local _obj_0 = req.body -- 377
				local _type_1 = type(_obj_0) -- 377
				if "table" == _type_1 or "userdata" == _type_1 then -- 377
					row = _obj_0.row -- 377
				end -- 484
			end -- 484
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 377
				local searchPath = getSearchPath(file) -- 378
				repeat -- 379
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 380
					if lang == "yue" then -- 381
						if not item then -- 382
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 382
						end -- 382
						if not item then -- 383
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 383
						end -- 383
					end -- 381
					local searchType = nil -- 384
					if not item then -- 385
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 386
						if lang == "yue" then -- 387
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 388
						end -- 387
						if (item ~= nil) then -- 389
							searchType = "Image" -- 389
						end -- 389
					end -- 385
					if not item then -- 390
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 391
						if lang == "yue" then -- 392
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 393
						end -- 392
						if (item ~= nil) then -- 394
							searchType = "Font" -- 394
						end -- 394
					end -- 390
					if not item then -- 395
						break -- 395
					end -- 395
					local searchPaths = Content.searchPaths -- 396
					local _list_0 = getSearchFolders(file) -- 397
					for _index_0 = 1, #_list_0 do -- 397
						local folder = _list_0[_index_0] -- 397
						searchPaths[#searchPaths + 1] = folder -- 398
					end -- 398
					if searchType then -- 399
						searchPaths[#searchPaths + 1] = Content.assetPath -- 399
					end -- 399
					local tokens -- 400
					do -- 400
						local _accum_0 = { } -- 400
						local _len_0 = 1 -- 400
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 400
							_accum_0[_len_0] = mod -- 400
							_len_0 = _len_0 + 1 -- 400
						end -- 400
						tokens = _accum_0 -- 400
					end -- 400
					local suggestions = { } -- 401
					for _index_0 = 1, #searchPaths do -- 402
						local path = searchPaths[_index_0] -- 402
						local sPath = Path(path, table.unpack(tokens)) -- 403
						if not Content:exist(sPath) then -- 404
							goto _continue_0 -- 404
						end -- 404
						if searchType == "Font" then -- 405
							local fontPath = Path(sPath, "Font") -- 406
							if Content:exist(fontPath) then -- 407
								local _list_1 = Content:getFiles(fontPath) -- 408
								for _index_1 = 1, #_list_1 do -- 408
									local f = _list_1[_index_1] -- 408
									if _anon_func_1(Path, f) then -- 409
										if "." == f:sub(1, 1) then -- 410
											goto _continue_1 -- 410
										end -- 410
										suggestions[#suggestions + 1] = { -- 411
											Path:getName(f), -- 411
											"font", -- 411
											"field" -- 411
										} -- 411
									end -- 409
									::_continue_1:: -- 409
								end -- 411
							end -- 407
						end -- 405
						local _list_1 = Content:getFiles(sPath) -- 412
						for _index_1 = 1, #_list_1 do -- 412
							local f = _list_1[_index_1] -- 412
							if "Image" == searchType then -- 413
								do -- 414
									local _exp_0 = Path:getExt(f) -- 414
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 414
										if "." == f:sub(1, 1) then -- 415
											goto _continue_2 -- 415
										end -- 415
										suggestions[#suggestions + 1] = { -- 416
											f, -- 416
											"image", -- 416
											"field" -- 416
										} -- 416
									end -- 416
								end -- 416
								goto _continue_2 -- 417
							elseif "Font" == searchType then -- 418
								do -- 419
									local _exp_0 = Path:getExt(f) -- 419
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 419
										if "." == f:sub(1, 1) then -- 420
											goto _continue_2 -- 420
										end -- 420
										suggestions[#suggestions + 1] = { -- 421
											f, -- 421
											"font", -- 421
											"field" -- 421
										} -- 421
									end -- 421
								end -- 421
								goto _continue_2 -- 422
							end -- 422
							local _exp_0 = Path:getExt(f) -- 423
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 423
								local name = Path:getName(f) -- 424
								if "d" == Path:getExt(name) then -- 425
									goto _continue_2 -- 425
								end -- 425
								if "." == name:sub(1, 1) then -- 426
									goto _continue_2 -- 426
								end -- 426
								suggestions[#suggestions + 1] = { -- 427
									name, -- 427
									"module", -- 427
									"field" -- 427
								} -- 427
							end -- 427
							::_continue_2:: -- 413
						end -- 427
						local _list_2 = Content:getDirs(sPath) -- 428
						for _index_1 = 1, #_list_2 do -- 428
							local dir = _list_2[_index_1] -- 428
							if "." == dir:sub(1, 1) then -- 429
								goto _continue_3 -- 429
							end -- 429
							suggestions[#suggestions + 1] = { -- 430
								dir, -- 430
								"folder", -- 430
								"variable" -- 430
							} -- 430
							::_continue_3:: -- 429
						end -- 430
						::_continue_0:: -- 403
					end -- 430
					if item == "" and not searchType then -- 431
						local _list_1 = teal.completeAsync("", "dora.", 1, searchPath) -- 432
						for _index_0 = 1, #_list_1 do -- 432
							local _des_0 = _list_1[_index_0] -- 432
							local name = _des_0[1] -- 432
							suggestions[#suggestions + 1] = { -- 433
								name, -- 433
								"dora module", -- 433
								"function" -- 433
							} -- 433
						end -- 433
					end -- 431
					if #suggestions > 0 then -- 434
						do -- 435
							local _accum_0 = { } -- 435
							local _len_0 = 1 -- 435
							for _, v in pairs(_anon_func_2(suggestions)) do -- 435
								_accum_0[_len_0] = v -- 435
								_len_0 = _len_0 + 1 -- 435
							end -- 435
							suggestions = _accum_0 -- 435
						end -- 435
						return { -- 436
							success = true, -- 436
							suggestions = suggestions -- 436
						} -- 436
					else -- 438
						return { -- 438
							success = false -- 438
						} -- 438
					end -- 434
				until true -- 439
				if "tl" == lang or "lua" == lang then -- 440
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 441
					if not line:match("[%.:][%w_]+[%.:]?$") and not line:match("[%w_]+[%.:]$") then -- 442
						local checkSet -- 443
						do -- 443
							local _tbl_0 = { } -- 443
							for _index_0 = 1, #suggestions do -- 443
								local _des_0 = suggestions[_index_0] -- 443
								local name = _des_0[1] -- 443
								_tbl_0[name] = true -- 443
							end -- 443
							checkSet = _tbl_0 -- 443
						end -- 443
						local _list_0 = teal.completeAsync("", "dora.", 1, searchPath) -- 444
						for _index_0 = 1, #_list_0 do -- 444
							local item = _list_0[_index_0] -- 444
							if not checkSet[item[1]] then -- 445
								suggestions[#suggestions + 1] = item -- 445
							end -- 445
						end -- 445
						for _index_0 = 1, #luaKeywords do -- 446
							local word = luaKeywords[_index_0] -- 446
							suggestions[#suggestions + 1] = { -- 447
								word, -- 447
								"keyword", -- 447
								"keyword" -- 447
							} -- 447
						end -- 447
						if lang == "tl" then -- 448
							for _index_0 = 1, #tealKeywords do -- 449
								local word = tealKeywords[_index_0] -- 449
								suggestions[#suggestions + 1] = { -- 450
									word, -- 450
									"keyword", -- 450
									"keyword" -- 450
								} -- 450
							end -- 450
						end -- 448
					end -- 442
					if #suggestions > 0 then -- 451
						return { -- 452
							success = true, -- 452
							suggestions = suggestions -- 452
						} -- 452
					end -- 451
				elseif "yue" == lang then -- 453
					local suggestions = { } -- 454
					local gotGlobals = false -- 455
					do -- 456
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file) -- 456
						if luaCodes then -- 456
							gotGlobals = true -- 457
							do -- 458
								local chainOp = line:match("[^%w_]([%.\\])$") -- 458
								if chainOp then -- 458
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 459
									if not withVar then -- 460
										return { -- 460
											success = false -- 460
										} -- 460
									end -- 460
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 461
								elseif line:match("^([%.\\])$") then -- 462
									return { -- 463
										success = false -- 463
									} -- 463
								end -- 458
							end -- 458
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 464
							for _index_0 = 1, #_list_0 do -- 464
								local item = _list_0[_index_0] -- 464
								suggestions[#suggestions + 1] = item -- 464
							end -- 464
							if #suggestions == 0 then -- 465
								local _list_1 = teal.completeAsync(luaCodes, "dora." .. tostring(targetLine), targetRow, searchPath) -- 466
								for _index_0 = 1, #_list_1 do -- 466
									local item = _list_1[_index_0] -- 466
									suggestions[#suggestions + 1] = item -- 466
								end -- 466
							end -- 465
						end -- 456
					end -- 456
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 467
						local checkSet -- 468
						do -- 468
							local _tbl_0 = { } -- 468
							for _index_0 = 1, #suggestions do -- 468
								local _des_0 = suggestions[_index_0] -- 468
								local name = _des_0[1] -- 468
								_tbl_0[name] = true -- 468
							end -- 468
							checkSet = _tbl_0 -- 468
						end -- 468
						local _list_0 = teal.completeAsync("", "dora.", 1, searchPath) -- 469
						for _index_0 = 1, #_list_0 do -- 469
							local item = _list_0[_index_0] -- 469
							if not checkSet[item[1]] then -- 470
								suggestions[#suggestions + 1] = item -- 470
							end -- 470
						end -- 470
						if not gotGlobals then -- 471
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 472
							for _index_0 = 1, #_list_1 do -- 472
								local item = _list_1[_index_0] -- 472
								if not checkSet[item[1]] then -- 473
									suggestions[#suggestions + 1] = item -- 473
								end -- 473
							end -- 473
						end -- 471
						for _index_0 = 1, #yueKeywords do -- 474
							local word = yueKeywords[_index_0] -- 474
							if not checkSet[word] then -- 475
								suggestions[#suggestions + 1] = { -- 476
									word, -- 476
									"keyword", -- 476
									"keyword" -- 476
								} -- 476
							end -- 475
						end -- 476
					end -- 467
					if #suggestions > 0 then -- 477
						return { -- 478
							success = true, -- 478
							suggestions = suggestions -- 478
						} -- 478
					end -- 477
				elseif "xml" == lang then -- 479
					local items = xml.complete(content) -- 480
					if #items > 0 then -- 481
						local suggestions -- 482
						do -- 482
							local _accum_0 = { } -- 482
							local _len_0 = 1 -- 482
							for _index_0 = 1, #items do -- 482
								local _des_0 = items[_index_0] -- 482
								local label, insertText = _des_0[1], _des_0[2] -- 482
								_accum_0[_len_0] = { -- 483
									label, -- 483
									insertText, -- 483
									"field" -- 483
								} -- 483
								_len_0 = _len_0 + 1 -- 483
							end -- 483
							suggestions = _accum_0 -- 482
						end -- 483
						return { -- 484
							success = true, -- 484
							suggestions = suggestions -- 484
						} -- 484
					end -- 481
				end -- 484
			end -- 377
		end -- 484
	end -- 484
	return { -- 376
		success = false -- 376
	} -- 484
end) -- 376
HttpServer:upload("/upload", function(req, filename) -- 488
	do -- 489
		local _type_0 = type(req) -- 489
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 489
		if _tab_0 then -- 489
			local path -- 489
			do -- 489
				local _obj_0 = req.params -- 489
				local _type_1 = type(_obj_0) -- 489
				if "table" == _type_1 or "userdata" == _type_1 then -- 489
					path = _obj_0.path -- 489
				end -- 495
			end -- 495
			if path ~= nil then -- 489
				local uploadPath = Path(Content.writablePath, ".upload") -- 490
				if not Content:exist(uploadPath) then -- 491
					Content:mkdir(uploadPath) -- 492
				end -- 491
				local targetPath = Path(uploadPath, filename) -- 493
				Content:mkdir(Path:getPath(targetPath)) -- 494
				return targetPath -- 495
			end -- 489
		end -- 495
	end -- 495
	return nil -- 495
end, function(req, file) -- 496
	do -- 497
		local _type_0 = type(req) -- 497
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 497
		if _tab_0 then -- 497
			local path -- 497
			do -- 497
				local _obj_0 = req.params -- 497
				local _type_1 = type(_obj_0) -- 497
				if "table" == _type_1 or "userdata" == _type_1 then -- 497
					path = _obj_0.path -- 497
				end -- 504
			end -- 504
			if path ~= nil then -- 497
				path = Content:getFullPath(path) -- 498
				if Content:exist(path) then -- 499
					local uploadPath = Path(Content.writablePath, ".upload") -- 500
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 501
					Content:mkdir(Path:getPath(targetPath)) -- 502
					if Content:move(file, targetPath) then -- 503
						return true -- 504
					end -- 503
				end -- 499
			end -- 497
		end -- 504
	end -- 504
	return false -- 504
end) -- 486
HttpServer:post("/list", function(req) -- 507
	do -- 508
		local _type_0 = type(req) -- 508
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 508
		if _tab_0 then -- 508
			local path -- 508
			do -- 508
				local _obj_0 = req.body -- 508
				local _type_1 = type(_obj_0) -- 508
				if "table" == _type_1 or "userdata" == _type_1 then -- 508
					path = _obj_0.path -- 508
				end -- 530
			end -- 530
			if path ~= nil then -- 508
				if Content:exist(path) then -- 509
					local files = { } -- 510
					local visitAssets -- 511
					visitAssets = function(path, folder) -- 511
						local dirs = Content:getDirs(path) -- 512
						for _index_0 = 1, #dirs do -- 513
							local dir = dirs[_index_0] -- 513
							if dir:match("^%.") then -- 514
								goto _continue_0 -- 514
							end -- 514
							local current -- 515
							if folder == "" then -- 515
								current = dir -- 516
							else -- 518
								current = Path(folder, dir) -- 518
							end -- 515
							files[#files + 1] = current -- 519
							visitAssets(Path(path, dir), current) -- 520
							::_continue_0:: -- 514
						end -- 520
						local fs = Content:getFiles(path) -- 521
						for _index_0 = 1, #fs do -- 522
							local f = fs[_index_0] -- 522
							if f:match("^%.") then -- 523
								goto _continue_1 -- 523
							end -- 523
							if folder == "" then -- 524
								files[#files + 1] = f -- 525
							else -- 527
								files[#files + 1] = Path(folder, f) -- 527
							end -- 524
							::_continue_1:: -- 523
						end -- 527
					end -- 511
					visitAssets(path, "") -- 528
					if #files == 0 then -- 529
						files = nil -- 529
					end -- 529
					return { -- 530
						success = true, -- 530
						files = files -- 530
					} -- 530
				end -- 509
			end -- 508
		end -- 530
	end -- 530
	return { -- 507
		success = false -- 507
	} -- 530
end) -- 507
HttpServer:post("/info", function() -- 532
	return { -- 533
		platform = App.platform, -- 533
		locale = App.locale, -- 534
		version = App.version -- 535
	} -- 535
end) -- 532
HttpServer:post("/new", function(req) -- 537
	do -- 538
		local _type_0 = type(req) -- 538
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 538
		if _tab_0 then -- 538
			local path -- 538
			do -- 538
				local _obj_0 = req.body -- 538
				local _type_1 = type(_obj_0) -- 538
				if "table" == _type_1 or "userdata" == _type_1 then -- 538
					path = _obj_0.path -- 538
				end -- 550
			end -- 550
			local content -- 538
			do -- 538
				local _obj_0 = req.body -- 538
				local _type_1 = type(_obj_0) -- 538
				if "table" == _type_1 or "userdata" == _type_1 then -- 538
					content = _obj_0.content -- 538
				end -- 550
			end -- 550
			if path ~= nil and content ~= nil then -- 538
				if not Content:exist(path) then -- 539
					local parent = Path:getPath(path) -- 540
					local files = Content:getFiles(parent) -- 541
					local name = Path:getName(path):lower() -- 542
					for _index_0 = 1, #files do -- 543
						local file = files[_index_0] -- 543
						if name == Path:getName(file):lower() then -- 544
							return { -- 545
								success = false -- 545
							} -- 545
						end -- 544
					end -- 545
					if "" == Path:getExt(path) then -- 546
						if Content:mkdir(path) then -- 547
							return { -- 548
								success = true -- 548
							} -- 548
						end -- 547
					elseif Content:save(path, content) then -- 549
						return { -- 550
							success = true -- 550
						} -- 550
					end -- 546
				end -- 539
			end -- 538
		end -- 550
	end -- 550
	return { -- 537
		success = false -- 537
	} -- 550
end) -- 537
HttpServer:post("/delete", function(req) -- 552
	do -- 553
		local _type_0 = type(req) -- 553
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 553
		if _tab_0 then -- 553
			local path -- 553
			do -- 553
				local _obj_0 = req.body -- 553
				local _type_1 = type(_obj_0) -- 553
				if "table" == _type_1 or "userdata" == _type_1 then -- 553
					path = _obj_0.path -- 553
				end -- 566
			end -- 566
			if path ~= nil then -- 553
				if Content:exist(path) then -- 554
					local parent = Path:getPath(path) -- 555
					local files = Content:getFiles(parent) -- 556
					local name = Path:getName(path):lower() -- 557
					local ext = Path:getExt(path) -- 558
					for _index_0 = 1, #files do -- 559
						local file = files[_index_0] -- 559
						if name == Path:getName(file):lower() then -- 560
							local _exp_0 = Path:getExt(file) -- 561
							if "tl" == _exp_0 then -- 561
								if ("vs" == ext) then -- 561
									Content:remove(Path(parent, file)) -- 562
								end -- 561
							elseif "lua" == _exp_0 then -- 563
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 563
									Content:remove(Path(parent, file)) -- 564
								end -- 563
							end -- 564
						end -- 560
					end -- 564
					if Content:remove(path) then -- 565
						return { -- 566
							success = true -- 566
						} -- 566
					end -- 565
				end -- 554
			end -- 553
		end -- 566
	end -- 566
	return { -- 552
		success = false -- 552
	} -- 566
end) -- 552
HttpServer:post("/rename", function(req) -- 568
	do -- 569
		local _type_0 = type(req) -- 569
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 569
		if _tab_0 then -- 569
			local old -- 569
			do -- 569
				local _obj_0 = req.body -- 569
				local _type_1 = type(_obj_0) -- 569
				if "table" == _type_1 or "userdata" == _type_1 then -- 569
					old = _obj_0.old -- 569
				end -- 591
			end -- 591
			local new -- 569
			do -- 569
				local _obj_0 = req.body -- 569
				local _type_1 = type(_obj_0) -- 569
				if "table" == _type_1 or "userdata" == _type_1 then -- 569
					new = _obj_0.new -- 569
				end -- 591
			end -- 591
			if old ~= nil and new ~= nil then -- 569
				if Content:exist(old) and not Content:exist(new) then -- 570
					local parent = Path:getPath(new) -- 571
					local files = Content:getFiles(parent) -- 572
					local name = Path:getName(new):lower() -- 573
					for _index_0 = 1, #files do -- 574
						local file = files[_index_0] -- 574
						if name == Path:getName(file):lower() then -- 575
							return { -- 576
								success = false -- 576
							} -- 576
						end -- 575
					end -- 576
					if Content:move(old, new) then -- 577
						local newParent = Path:getPath(new) -- 578
						parent = Path:getPath(old) -- 579
						files = Content:getFiles(parent) -- 580
						local newName = Path:getName(new) -- 581
						local oldName = Path:getName(old) -- 582
						name = oldName:lower() -- 583
						local ext = Path:getExt(old) -- 584
						for _index_0 = 1, #files do -- 585
							local file = files[_index_0] -- 585
							if name == Path:getName(file):lower() then -- 586
								local _exp_0 = Path:getExt(file) -- 587
								if "tl" == _exp_0 then -- 587
									if ("vs" == ext) then -- 587
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 588
									end -- 587
								elseif "lua" == _exp_0 then -- 589
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 589
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 590
									end -- 589
								end -- 590
							end -- 586
						end -- 590
						return { -- 591
							success = true -- 591
						} -- 591
					end -- 577
				end -- 570
			end -- 569
		end -- 591
	end -- 591
	return { -- 568
		success = false -- 568
	} -- 591
end) -- 568
HttpServer:postSchedule("/read", function(req) -- 593
	do -- 594
		local _type_0 = type(req) -- 594
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 594
		if _tab_0 then -- 594
			local path -- 594
			do -- 594
				local _obj_0 = req.body -- 594
				local _type_1 = type(_obj_0) -- 594
				if "table" == _type_1 or "userdata" == _type_1 then -- 594
					path = _obj_0.path -- 594
				end -- 597
			end -- 597
			if path ~= nil then -- 594
				if Content:exist(path) then -- 595
					local content = Content:loadAsync(path) -- 596
					if content then -- 596
						return { -- 597
							content = content, -- 597
							success = true -- 597
						} -- 597
					end -- 596
				end -- 595
			end -- 594
		end -- 597
	end -- 597
	return { -- 593
		success = false -- 593
	} -- 597
end) -- 593
local compileFileAsync -- 599
compileFileAsync = function(inputFile, sourceCodes) -- 599
	local file = Path:getFilename(inputFile) -- 600
	local searchPath -- 601
	do -- 601
		local dir = getProjectDirFromFile(inputFile) -- 601
		if dir then -- 601
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 602
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 603
		else -- 604
			searchPath = "" -- 604
		end -- 601
	end -- 601
	local outputFile = Path:replaceExt(inputFile, "lua") -- 605
	local yueext = yue.options.extension -- 606
	local resultCodes = nil -- 607
	do -- 608
		local _exp_0 = Path:getExt(inputFile) -- 608
		if yueext == _exp_0 then -- 608
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 609
				if not codes then -- 610
					return -- 610
				end -- 610
				local success, result = LintYueGlobals(codes, globals) -- 611
				if not success then -- 612
					return -- 612
				end -- 612
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 613
				codes = codes:gsub("^\n*", "") -- 614
				if not (result == "") then -- 615
					result = result .. "\n" -- 615
				end -- 615
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 616
				return resultCodes -- 617
			end, function(success) -- 609
				if not success then -- 618
					Content:remove(outputFile) -- 619
					resultCodes = false -- 620
				end -- 618
			end) -- 609
		elseif "tl" == _exp_0 then -- 621
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 622
			if codes then -- 622
				resultCodes = codes -- 623
				Content:saveAsync(outputFile, codes) -- 624
			else -- 626
				Content:remove(outputFile) -- 626
				resultCodes = false -- 627
			end -- 622
		elseif "xml" == _exp_0 then -- 628
			local codes = xml.tolua(sourceCodes) -- 629
			if codes then -- 629
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 630
				Content:saveAsync(outputFile, resultCodes) -- 631
			else -- 633
				Content:remove(outputFile) -- 633
				resultCodes = false -- 634
			end -- 629
		end -- 634
	end -- 634
	wait(function() -- 635
		return resultCodes ~= nil -- 635
	end) -- 635
	if resultCodes then -- 636
		return resultCodes -- 636
	end -- 636
	return nil -- 636
end -- 599
HttpServer:postSchedule("/write", function(req) -- 638
	do -- 639
		local _type_0 = type(req) -- 639
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 639
		if _tab_0 then -- 639
			local path -- 639
			do -- 639
				local _obj_0 = req.body -- 639
				local _type_1 = type(_obj_0) -- 639
				if "table" == _type_1 or "userdata" == _type_1 then -- 639
					path = _obj_0.path -- 639
				end -- 645
			end -- 645
			local content -- 639
			do -- 639
				local _obj_0 = req.body -- 639
				local _type_1 = type(_obj_0) -- 639
				if "table" == _type_1 or "userdata" == _type_1 then -- 639
					content = _obj_0.content -- 639
				end -- 645
			end -- 645
			if path ~= nil and content ~= nil then -- 639
				if Content:saveAsync(path, content) then -- 640
					do -- 641
						local _exp_0 = Path:getExt(path) -- 641
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 641
							if '' == Path:getExt(Path:getName(path)) then -- 642
								local resultCodes = compileFileAsync(path, content) -- 643
								return { -- 644
									success = true, -- 644
									resultCodes = resultCodes -- 644
								} -- 644
							end -- 642
						end -- 644
					end -- 644
					return { -- 645
						success = true -- 645
					} -- 645
				end -- 640
			end -- 639
		end -- 645
	end -- 645
	return { -- 638
		success = false -- 638
	} -- 645
end) -- 638
local extentionLevels = { -- 648
	vs = 2, -- 648
	ts = 1, -- 649
	tsx = 1, -- 650
	tl = 1, -- 651
	yue = 1, -- 652
	xml = 1, -- 653
	lua = 0 -- 654
} -- 647
local _anon_func_4 = function(Content, Path, visitAssets, zh) -- 719
	local _with_0 = visitAssets(Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")) -- 718
	_with_0.title = zh and "说明文档" or "Readme" -- 719
	return _with_0 -- 718
end -- 718
local _anon_func_5 = function(Content, Path, visitAssets, zh) -- 721
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")) -- 720
	_with_0.title = zh and "接口文档" or "API Doc" -- 721
	return _with_0 -- 720
end -- 720
local _anon_func_6 = function(Content, Path, visitAssets, zh) -- 723
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Example")) -- 722
	_with_0.title = zh and "代码示例" or "Example" -- 723
	return _with_0 -- 722
end -- 722
local _anon_func_7 = function(Content, Path, visitAssets, zh) -- 725
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Test")) -- 724
	_with_0.title = zh and "功能测试" or "Test" -- 725
	return _with_0 -- 724
end -- 724
local _anon_func_3 = function(Content, Path, pairs, visitAssets, zh) -- 730
	local _tab_0 = { -- 713
		{ -- 714
			key = Path(Content.assetPath), -- 714
			dir = true, -- 715
			title = zh and "内置资源" or "Built-in", -- 716
			children = { -- 718
				_anon_func_4(Content, Path, visitAssets, zh), -- 718
				_anon_func_5(Content, Path, visitAssets, zh), -- 720
				_anon_func_6(Content, Path, visitAssets, zh), -- 722
				_anon_func_7(Content, Path, visitAssets, zh), -- 724
				visitAssets(Path(Content.assetPath, "Image")), -- 726
				visitAssets(Path(Content.assetPath, "Spine")), -- 727
				visitAssets(Path(Content.assetPath, "Font")) -- 728
			} -- 717
		} -- 713
	} -- 731
	local _obj_0 = visitAssets(Content.writablePath, true) -- 731
	local _idx_0 = #_tab_0 + 1 -- 731
	for _index_0 = 1, #_obj_0 do -- 731
		local _value_0 = _obj_0[_index_0] -- 731
		_tab_0[_idx_0] = _value_0 -- 731
		_idx_0 = _idx_0 + 1 -- 731
	end -- 731
	return _tab_0 -- 730
end -- 713
HttpServer:post("/assets", function() -- 656
	local visitAssets -- 657
	visitAssets = function(path, root) -- 657
		local children = nil -- 658
		local dirs = Content:getDirs(path) -- 659
		for _index_0 = 1, #dirs do -- 660
			local dir = dirs[_index_0] -- 660
			if root then -- 661
				if ".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir then -- 661
					goto _continue_0 -- 662
				end -- 662
			elseif dir == ".git" then -- 663
				goto _continue_0 -- 664
			end -- 661
			if not children then -- 665
				children = { } -- 665
			end -- 665
			children[#children + 1] = visitAssets(Path(path, dir)) -- 666
			::_continue_0:: -- 661
		end -- 666
		local files = Content:getFiles(path) -- 667
		local names = { } -- 668
		for _index_0 = 1, #files do -- 669
			local file = files[_index_0] -- 669
			if file:match("^%.") then -- 670
				goto _continue_1 -- 670
			end -- 670
			local name = Path:getName(file) -- 671
			local ext = names[name] -- 672
			if ext then -- 672
				local lv1 -- 673
				do -- 673
					local _exp_0 = extentionLevels[ext] -- 673
					if _exp_0 ~= nil then -- 673
						lv1 = _exp_0 -- 673
					else -- 673
						lv1 = -1 -- 673
					end -- 673
				end -- 673
				ext = Path:getExt(file) -- 674
				local lv2 -- 675
				do -- 675
					local _exp_0 = extentionLevels[ext] -- 675
					if _exp_0 ~= nil then -- 675
						lv2 = _exp_0 -- 675
					else -- 675
						lv2 = -1 -- 675
					end -- 675
				end -- 675
				if lv2 > lv1 then -- 676
					names[name] = ext -- 676
				end -- 676
			else -- 678
				ext = Path:getExt(file) -- 678
				if not extentionLevels[ext] then -- 679
					names[file] = "" -- 680
				else -- 682
					names[name] = ext -- 682
				end -- 679
			end -- 672
			::_continue_1:: -- 670
		end -- 682
		do -- 683
			local _accum_0 = { } -- 683
			local _len_0 = 1 -- 683
			for name, ext in pairs(names) do -- 683
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 683
				_len_0 = _len_0 + 1 -- 683
			end -- 683
			files = _accum_0 -- 683
		end -- 683
		for _index_0 = 1, #files do -- 684
			local file = files[_index_0] -- 684
			if not children then -- 685
				children = { } -- 685
			end -- 685
			children[#children + 1] = { -- 687
				key = Path(path, file), -- 687
				dir = false, -- 688
				title = file -- 689
			} -- 686
		end -- 690
		if children then -- 691
			table.sort(children, function(a, b) -- 692
				if a.dir == b.dir then -- 693
					return a.title < b.title -- 694
				else -- 696
					return a.dir -- 696
				end -- 693
			end) -- 692
		end -- 691
		local title = Path:getFilename(path) -- 697
		if title == "" then -- 698
			return children -- 699
		else -- 701
			return { -- 702
				key = path, -- 702
				dir = true, -- 703
				title = title, -- 704
				children = children -- 705
			} -- 706
		end -- 698
	end -- 657
	local zh = (App.locale:match("^zh") ~= nil) -- 707
	return { -- 709
		key = Content.writablePath, -- 709
		dir = true, -- 710
		title = "Assets", -- 711
		children = _anon_func_3(Content, Path, pairs, visitAssets, zh) -- 712
	} -- 733
end) -- 656
HttpServer:postSchedule("/run", function(req) -- 735
	do -- 736
		local _type_0 = type(req) -- 736
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 736
		if _tab_0 then -- 736
			local file -- 736
			do -- 736
				local _obj_0 = req.body -- 736
				local _type_1 = type(_obj_0) -- 736
				if "table" == _type_1 or "userdata" == _type_1 then -- 736
					file = _obj_0.file -- 736
				end -- 748
			end -- 748
			local asProj -- 736
			do -- 736
				local _obj_0 = req.body -- 736
				local _type_1 = type(_obj_0) -- 736
				if "table" == _type_1 or "userdata" == _type_1 then -- 736
					asProj = _obj_0.asProj -- 736
				end -- 748
			end -- 748
			if file ~= nil and asProj ~= nil then -- 736
				local Entry = require("Dev.Entry") -- 737
				if asProj then -- 738
					local proj = getProjectDirFromFile(file) -- 739
					if proj then -- 739
						Entry.allClear() -- 740
						local target = Path(proj, "init") -- 741
						local success, err = Entry.enterEntryAsync({ -- 742
							"Project", -- 742
							target -- 742
						}) -- 742
						target = Path:getName(Path:getPath(target)) -- 743
						return { -- 744
							success = success, -- 744
							target = target, -- 744
							err = err -- 744
						} -- 744
					end -- 739
				end -- 738
				Entry.allClear() -- 745
				file = Path:replaceExt(file, "") -- 746
				local success, err = Entry.enterEntryAsync({ -- 747
					Path:getName(file), -- 747
					file -- 747
				}) -- 747
				return { -- 748
					success = success, -- 748
					err = err -- 748
				} -- 748
			end -- 736
		end -- 748
	end -- 748
	return { -- 735
		success = false -- 735
	} -- 748
end) -- 735
HttpServer:postSchedule("/stop", function() -- 750
	local Entry = require("Dev.Entry") -- 751
	return { -- 752
		success = Entry.stop() -- 752
	} -- 752
end) -- 750
HttpServer:postSchedule("/zip", function(req) -- 754
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
				end -- 758
			end -- 758
			local zipFile -- 755
			do -- 755
				local _obj_0 = req.body -- 755
				local _type_1 = type(_obj_0) -- 755
				if "table" == _type_1 or "userdata" == _type_1 then -- 755
					zipFile = _obj_0.zipFile -- 755
				end -- 758
			end -- 758
			if path ~= nil and zipFile ~= nil then -- 755
				Content:mkdir(Path:getPath(zipFile)) -- 756
				return { -- 757
					success = Content:zipAsync(path, zipFile, function(file) -- 757
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 758
					end) -- 757
				} -- 758
			end -- 755
		end -- 758
	end -- 758
	return { -- 754
		success = false -- 754
	} -- 758
end) -- 754
HttpServer:postSchedule("/unzip", function(req) -- 760
	do -- 761
		local _type_0 = type(req) -- 761
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 761
		if _tab_0 then -- 761
			local zipFile -- 761
			do -- 761
				local _obj_0 = req.body -- 761
				local _type_1 = type(_obj_0) -- 761
				if "table" == _type_1 or "userdata" == _type_1 then -- 761
					zipFile = _obj_0.zipFile -- 761
				end -- 763
			end -- 763
			local path -- 761
			do -- 761
				local _obj_0 = req.body -- 761
				local _type_1 = type(_obj_0) -- 761
				if "table" == _type_1 or "userdata" == _type_1 then -- 761
					path = _obj_0.path -- 761
				end -- 763
			end -- 763
			if zipFile ~= nil and path ~= nil then -- 761
				return { -- 762
					success = Content:unzipAsync(zipFile, path, function(file) -- 762
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 763
					end) -- 762
				} -- 763
			end -- 761
		end -- 763
	end -- 763
	return { -- 764
		success = false -- 764
	} -- 764
end) -- 760
HttpServer:post("/editingInfo", function(req) -- 766
	local Entry = require("Dev.Entry") -- 767
	local config = Entry.getConfig() -- 768
	local _type_0 = type(req) -- 769
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 769
	local _match_0 = false -- 769
	if _tab_0 then -- 769
		local editingInfo -- 769
		do -- 769
			local _obj_0 = req.body -- 769
			local _type_1 = type(_obj_0) -- 769
			if "table" == _type_1 or "userdata" == _type_1 then -- 769
				editingInfo = _obj_0.editingInfo -- 769
			end -- 771
		end -- 771
		if editingInfo ~= nil then -- 769
			_match_0 = true -- 769
			config.editingInfo = editingInfo -- 770
			return { -- 771
				success = true -- 771
			} -- 771
		end -- 769
	end -- 769
	if not _match_0 then -- 769
		if not (config.editingInfo ~= nil) then -- 773
			local json = require("json") -- 774
			local folder -- 775
			if App.locale:match('^zh') then -- 775
				folder = 'zh-Hans' -- 775
			else -- 775
				folder = 'en' -- 775
			end -- 775
			config.editingInfo = json.dump({ -- 777
				index = 0, -- 777
				files = { -- 779
					{ -- 780
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 780
						title = "welcome.md" -- 781
					} -- 779
				} -- 778
			}) -- 776
		end -- 773
		return { -- 785
			success = true, -- 785
			editingInfo = config.editingInfo -- 785
		} -- 785
	end -- 785
end) -- 766
HttpServer:post("/command", function(req) -- 787
	do -- 788
		local _type_0 = type(req) -- 788
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 788
		if _tab_0 then -- 788
			local code -- 788
			do -- 788
				local _obj_0 = req.body -- 788
				local _type_1 = type(_obj_0) -- 788
				if "table" == _type_1 or "userdata" == _type_1 then -- 788
					code = _obj_0.code -- 788
				end -- 790
			end -- 790
			if code ~= nil then -- 788
				emit("AppCommand", code) -- 789
				return { -- 790
					success = true -- 790
				} -- 790
			end -- 788
		end -- 790
	end -- 790
	return { -- 787
		success = false -- 787
	} -- 790
end) -- 787
HttpServer:post("/exist", function(req) -- 792
	do -- 793
		local _type_0 = type(req) -- 793
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 793
		if _tab_0 then -- 793
			local file -- 793
			do -- 793
				local _obj_0 = req.body -- 793
				local _type_1 = type(_obj_0) -- 793
				if "table" == _type_1 or "userdata" == _type_1 then -- 793
					file = _obj_0.file -- 793
				end -- 794
			end -- 794
			if file ~= nil then -- 793
				return { -- 794
					success = Content:exist(file) -- 794
				} -- 794
			end -- 793
		end -- 794
	end -- 794
	return { -- 792
		success = false -- 792
	} -- 794
end) -- 792
local status = { -- 796
	url = nil -- 796
} -- 796
_module_0 = status -- 797
thread(function() -- 799
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 800
	local doraReady = Path(Content.writablePath, ".www", "dora-ready") -- 801
	if Content:exist(doraWeb) then -- 802
		local needReload -- 803
		if Content:exist(doraReady) then -- 803
			needReload = App.version ~= Content:load(doraReady) -- 804
		else -- 805
			needReload = true -- 805
		end -- 803
		if needReload then -- 806
			Content:remove(Path(Content.writablePath, ".www")) -- 807
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.writablePath, ".www")) -- 808
			Content:save(doraReady, App.version) -- 812
			print("Dora Dora is ready!") -- 813
		end -- 806
		if HttpServer:start(8866) then -- 814
			local localIP = HttpServer.localIP -- 815
			if localIP == "" then -- 816
				localIP = "localhost" -- 816
			end -- 816
			status.url = "http://" .. tostring(localIP) .. ":8866" -- 817
			return HttpServer:startWS(8868) -- 818
		else -- 820
			status.url = nil -- 820
			return print("8866 Port not available!") -- 821
		end -- 814
	end -- 802
end) -- 799
return _module_0 -- 821
