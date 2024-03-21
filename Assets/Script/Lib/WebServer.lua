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
HttpServer:stop() -- 3
HttpServer.wwwPath = Path(Content.writablePath, ".www") -- 5
local LintYueGlobals -- 7
do -- 7
	local _obj_0 = require("Utils") -- 7
	LintYueGlobals = _obj_0.LintYueGlobals -- 7
end -- 7
local getProjectDirFromFile -- 9
getProjectDirFromFile = function(file) -- 9
	local writablePath = Content.writablePath -- 10
	if writablePath ~= file:sub(1, #writablePath) then -- 11
		return nil -- 11
	end -- 11
	local current = Path:getRelative(file, writablePath) -- 12
	repeat -- 13
		current = Path:getPath(current) -- 14
		if current == "" then -- 15
			break -- 15
		end -- 15
		local _list_0 = Content:getFiles(Path(writablePath, current)) -- 16
		for _index_0 = 1, #_list_0 do -- 16
			local f = _list_0[_index_0] -- 16
			if Path:getName(f):lower() == "init" then -- 17
				return Path(current, Path:getPath(f)) -- 18
			end -- 17
		end -- 18
	until false -- 19
	return nil -- 20
end -- 9
local getSearchPath -- 22
getSearchPath = function(file) -- 22
	do -- 23
		local dir = getProjectDirFromFile(file) -- 23
		if dir then -- 23
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 24
		end -- 23
	end -- 23
	return "" -- 24
end -- 22
local getSearchFolders -- 26
getSearchFolders = function(file) -- 26
	do -- 27
		local dir = getProjectDirFromFile(file) -- 27
		if dir then -- 27
			return { -- 29
				Path(dir, "Script"), -- 29
				dir -- 30
			} -- 30
		end -- 27
	end -- 27
	return { } -- 26
end -- 26
local disabledCheckForLua = { -- 33
	"incompatible number of returns", -- 33
	"unknown variable", -- 34
	"cannot index key", -- 35
	"module not found", -- 36
	"don't know how to resolve a dynamic require", -- 37
	"ContainerItem", -- 38
	"cannot resolve a type", -- 39
	"invalid key", -- 40
	"inconsistent index type", -- 41
	"cannot use operator '#'", -- 42
	"attempting ipairs loop", -- 43
	"expects record or nominal", -- 44
	"variable is not being assigned a value", -- 45
	"<unknown type>", -- 46
	"<invalid type>", -- 47
	"using the '#' operator on this map will always return 0", -- 48
	"can't match a record to a map with non%-string keys", -- 49
	"redeclaration of variable" -- 50
} -- 32
local yueCheck -- 52
yueCheck = function(file, content) -- 52
	local searchPath = getSearchPath(file) -- 53
	local checkResult, luaCodes = yue.checkAsync(content, searchPath) -- 54
	local info = { } -- 55
	local globals = { } -- 56
	for _index_0 = 1, #checkResult do -- 57
		local _des_0 = checkResult[_index_0] -- 57
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 57
		if "error" == t then -- 58
			info[#info + 1] = { -- 59
				"syntax", -- 59
				file, -- 59
				line, -- 59
				col, -- 59
				msg -- 59
			} -- 59
		elseif "global" == t then -- 60
			globals[#globals + 1] = { -- 61
				msg, -- 61
				line, -- 61
				col -- 61
			} -- 61
		end -- 61
	end -- 61
	if luaCodes then -- 62
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 63
		if success then -- 64
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 65
			if not (lintResult == "") then -- 66
				lintResult = lintResult .. "\n" -- 66
			end -- 66
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 67
		else -- 68
			for _index_0 = 1, #lintResult do -- 68
				local _des_0 = lintResult[_index_0] -- 68
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 68
				info[#info + 1] = { -- 69
					"syntax", -- 69
					file, -- 69
					line, -- 69
					col, -- 69
					"invalid global variable" -- 69
				} -- 69
			end -- 69
		end -- 64
	end -- 62
	return luaCodes, info -- 70
end -- 52
local luaCheck -- 72
luaCheck = function(file, content) -- 72
	local res, err = load(content, "check") -- 73
	if not res then -- 74
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 75
		return { -- 76
			success = false, -- 76
			info = { -- 76
				{ -- 76
					"syntax", -- 76
					file, -- 76
					tonumber(line), -- 76
					0, -- 76
					msg -- 76
				} -- 76
			} -- 76
		} -- 76
	end -- 74
	local success, info = teal.checkAsync(content, file, true, "") -- 77
	if info then -- 78
		do -- 79
			local _accum_0 = { } -- 79
			local _len_0 = 1 -- 79
			for _index_0 = 1, #info do -- 79
				local item = info[_index_0] -- 79
				local useCheck = true -- 80
				for _index_1 = 1, #disabledCheckForLua do -- 81
					local check = disabledCheckForLua[_index_1] -- 81
					if not item[5]:match("unused") and item[5]:match(check) then -- 82
						useCheck = false -- 83
					end -- 82
				end -- 83
				if not useCheck then -- 84
					goto _continue_0 -- 84
				end -- 84
				do -- 85
					local _exp_0 = item[1] -- 85
					if "type" == _exp_0 then -- 86
						item[1] = "warning" -- 87
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 88
						goto _continue_0 -- 89
					end -- 89
				end -- 89
				_accum_0[_len_0] = item -- 90
				_len_0 = _len_0 + 1 -- 90
				::_continue_0:: -- 80
			end -- 90
			info = _accum_0 -- 79
		end -- 90
		if #info == 0 then -- 91
			info = nil -- 92
			success = true -- 93
		end -- 91
	end -- 78
	return { -- 94
		success = success, -- 94
		info = info -- 94
	} -- 94
end -- 72
local luaCheckWithLineInfo -- 96
luaCheckWithLineInfo = function(file, luaCodes) -- 96
	local res = luaCheck(file, luaCodes) -- 97
	local info = { } -- 98
	if not res.success then -- 99
		local current = 1 -- 100
		local lastLine = 1 -- 101
		local lineMap = { } -- 102
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 103
			local num = lineCode:match("--%s*(%d+)%s*$") -- 104
			if num then -- 105
				lastLine = tonumber(num) -- 106
			end -- 105
			lineMap[current] = lastLine -- 107
			current = current + 1 -- 108
		end -- 108
		local _list_0 = res.info -- 109
		for _index_0 = 1, #_list_0 do -- 109
			local item = _list_0[_index_0] -- 109
			item[3] = lineMap[item[3]] or 0 -- 110
			item[4] = 0 -- 111
			info[#info + 1] = item -- 112
		end -- 112
		return false, info -- 113
	end -- 99
	return true, info -- 114
end -- 96
local getCompiledYueLine -- 116
getCompiledYueLine = function(content, line, row, file) -- 116
	local luaCodes, info = yueCheck(file, content) -- 117
	if not luaCodes then -- 118
		return nil -- 118
	end -- 118
	local current = 1 -- 119
	local lastLine = 1 -- 120
	local targetLine = nil -- 121
	local targetRow = nil -- 122
	local lineMap = { } -- 123
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 124
		local num = lineCode:match("--%s*(%d+)%s*$") -- 125
		if num then -- 126
			lastLine = tonumber(num) -- 126
		end -- 126
		lineMap[current] = lastLine -- 127
		if row == lastLine and not targetLine then -- 128
			targetRow = current -- 129
			targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 130
			if targetLine then -- 131
				break -- 131
			end -- 131
		end -- 128
		current = current + 1 -- 132
	end -- 132
	if targetLine and targetRow then -- 133
		return luaCodes, targetLine, targetRow, lineMap -- 134
	else -- 136
		return nil -- 136
	end -- 133
end -- 116
HttpServer:postSchedule("/check", function(req) -- 138
	do -- 139
		local _type_0 = type(req) -- 139
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 139
		if _tab_0 then -- 139
			local file -- 139
			do -- 139
				local _obj_0 = req.body -- 139
				local _type_1 = type(_obj_0) -- 139
				if "table" == _type_1 or "userdata" == _type_1 then -- 139
					file = _obj_0.file -- 139
				end -- 169
			end -- 169
			local content -- 139
			do -- 139
				local _obj_0 = req.body -- 139
				local _type_1 = type(_obj_0) -- 139
				if "table" == _type_1 or "userdata" == _type_1 then -- 139
					content = _obj_0.content -- 139
				end -- 169
			end -- 169
			if file ~= nil and content ~= nil then -- 139
				local ext = Path:getExt(file) -- 140
				if "tl" == ext then -- 141
					local searchPath = getSearchPath(file) -- 142
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 143
					return { -- 144
						success = success, -- 144
						info = info -- 144
					} -- 144
				elseif "lua" == ext then -- 145
					return luaCheck(file, content) -- 146
				elseif "yue" == ext then -- 147
					local luaCodes, info = yueCheck(file, content) -- 148
					local success = false -- 149
					if luaCodes then -- 150
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 151
						do -- 152
							local _tab_1 = { } -- 152
							local _idx_0 = #_tab_1 + 1 -- 152
							for _index_0 = 1, #info do -- 152
								local _value_0 = info[_index_0] -- 152
								_tab_1[_idx_0] = _value_0 -- 152
								_idx_0 = _idx_0 + 1 -- 152
							end -- 152
							local _idx_1 = #_tab_1 + 1 -- 152
							for _index_0 = 1, #luaInfo do -- 152
								local _value_0 = luaInfo[_index_0] -- 152
								_tab_1[_idx_1] = _value_0 -- 152
								_idx_1 = _idx_1 + 1 -- 152
							end -- 152
							info = _tab_1 -- 152
						end -- 152
						success = success and luaSuccess -- 153
					end -- 150
					if #info > 0 then -- 154
						return { -- 155
							success = success, -- 155
							info = info -- 155
						} -- 155
					else -- 157
						return { -- 157
							success = success -- 157
						} -- 157
					end -- 154
				elseif "xml" == ext then -- 158
					local success, result = xml.check(content) -- 159
					if success then -- 160
						local info -- 161
						success, info = luaCheckWithLineInfo(file, result) -- 161
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
					else -- 167
						local info -- 167
						do -- 167
							local _accum_0 = { } -- 167
							local _len_0 = 1 -- 167
							for _index_0 = 1, #result do -- 167
								local _des_0 = result[_index_0] -- 167
								local row, err = _des_0[1], _des_0[2] -- 167
								_accum_0[_len_0] = { -- 168
									"syntax", -- 168
									file, -- 168
									row, -- 168
									0, -- 168
									err -- 168
								} -- 168
								_len_0 = _len_0 + 1 -- 168
							end -- 168
							info = _accum_0 -- 167
						end -- 168
						return { -- 169
							success = false, -- 169
							info = info -- 169
						} -- 169
					end -- 160
				end -- 169
			end -- 139
		end -- 169
	end -- 169
	return { -- 138
		success = true -- 138
	} -- 169
end) -- 138
local updateInferedDesc -- 171
updateInferedDesc = function(infered) -- 171
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 172
		return -- 172
	end -- 172
	local key, row = infered.key, infered.row -- 173
	local codes = Content:loadAsync(key) -- 174
	if codes then -- 174
		local comments = { } -- 175
		local line = 0 -- 176
		local skipping = false -- 177
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 178
			line = line + 1 -- 179
			if line >= row then -- 180
				break -- 180
			end -- 180
			if lineCode:match("^%s*%-%- @") then -- 181
				skipping = true -- 182
				goto _continue_0 -- 183
			end -- 181
			local result = lineCode:match("^%s*%-%- (.+)") -- 184
			if result then -- 184
				if not skipping then -- 185
					comments[#comments + 1] = result -- 185
				end -- 185
			elseif #comments > 0 then -- 186
				comments = { } -- 187
				skipping = false -- 188
			end -- 184
			::_continue_0:: -- 179
		end -- 188
		infered.doc = table.concat(comments, "\n") -- 189
	end -- 174
end -- 171
HttpServer:postSchedule("/infer", function(req) -- 191
	do -- 192
		local _type_0 = type(req) -- 192
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 192
		if _tab_0 then -- 192
			local lang -- 192
			do -- 192
				local _obj_0 = req.body -- 192
				local _type_1 = type(_obj_0) -- 192
				if "table" == _type_1 or "userdata" == _type_1 then -- 192
					lang = _obj_0.lang -- 192
				end -- 209
			end -- 209
			local file -- 192
			do -- 192
				local _obj_0 = req.body -- 192
				local _type_1 = type(_obj_0) -- 192
				if "table" == _type_1 or "userdata" == _type_1 then -- 192
					file = _obj_0.file -- 192
				end -- 209
			end -- 209
			local content -- 192
			do -- 192
				local _obj_0 = req.body -- 192
				local _type_1 = type(_obj_0) -- 192
				if "table" == _type_1 or "userdata" == _type_1 then -- 192
					content = _obj_0.content -- 192
				end -- 209
			end -- 209
			local line -- 192
			do -- 192
				local _obj_0 = req.body -- 192
				local _type_1 = type(_obj_0) -- 192
				if "table" == _type_1 or "userdata" == _type_1 then -- 192
					line = _obj_0.line -- 192
				end -- 209
			end -- 209
			local row -- 192
			do -- 192
				local _obj_0 = req.body -- 192
				local _type_1 = type(_obj_0) -- 192
				if "table" == _type_1 or "userdata" == _type_1 then -- 192
					row = _obj_0.row -- 192
				end -- 209
			end -- 209
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 192
				local searchPath = getSearchPath(file) -- 193
				if "tl" == lang or "lua" == lang then -- 194
					local infered = teal.inferAsync(content, line, row, searchPath) -- 195
					if (infered ~= nil) then -- 196
						updateInferedDesc(infered) -- 197
						return { -- 198
							success = true, -- 198
							infered = infered -- 198
						} -- 198
					end -- 196
				elseif "yue" == lang then -- 199
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file) -- 200
					if not luaCodes then -- 201
						return { -- 201
							success = false -- 201
						} -- 201
					end -- 201
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 202
					if (infered ~= nil) then -- 203
						local col -- 204
						file, row, col = infered.file, infered.row, infered.col -- 204
						if file == "" and row > 0 and col > 0 then -- 205
							infered.row = lineMap[row] or 0 -- 206
							infered.col = 0 -- 207
						end -- 205
						updateInferedDesc(infered) -- 208
						return { -- 209
							success = true, -- 209
							infered = infered -- 209
						} -- 209
					end -- 203
				end -- 209
			end -- 192
		end -- 209
	end -- 209
	return { -- 191
		success = false -- 191
	} -- 209
end) -- 191
local _anon_func_0 = function(doc) -- 260
	local _accum_0 = { } -- 260
	local _len_0 = 1 -- 260
	local _list_0 = doc.params -- 260
	for _index_0 = 1, #_list_0 do -- 260
		local param = _list_0[_index_0] -- 260
		_accum_0[_len_0] = param.name -- 260
		_len_0 = _len_0 + 1 -- 260
	end -- 260
	return _accum_0 -- 260
end -- 260
local getParamDocs -- 211
getParamDocs = function(signatures) -- 211
	do -- 212
		local codes = Content:loadAsync(signatures[1].file) -- 212
		if codes then -- 212
			local comments = { } -- 213
			local params = { } -- 214
			local line = 0 -- 215
			local docs = { } -- 216
			local returnType = nil -- 217
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 218
				line = line + 1 -- 219
				local needBreak = true -- 220
				for i, _des_0 in ipairs(signatures) do -- 221
					local row = _des_0.row -- 221
					if line >= row and not (docs[i] ~= nil) then -- 222
						if #comments > 0 or #params > 0 or returnType then -- 223
							docs[i] = { -- 225
								doc = table.concat(comments, "  \n"), -- 225
								returnType = returnType -- 226
							} -- 224
							if #params > 0 then -- 228
								docs[i].params = params -- 228
							end -- 228
						else -- 230
							docs[i] = false -- 230
						end -- 223
					end -- 222
					if not docs[i] then -- 231
						needBreak = false -- 231
					end -- 231
				end -- 231
				if needBreak then -- 232
					break -- 232
				end -- 232
				local result = lineCode:match("%s*%-%- (.+)") -- 233
				if result then -- 233
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 234
					if not name then -- 235
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 236
					end -- 235
					if name then -- 237
						local pname = name -- 238
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 239
							pname = pname .. "?" -- 239
						end -- 239
						params[#params + 1] = { -- 241
							name = tostring(pname) .. ": " .. tostring(typ), -- 241
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 242
						} -- 240
					else -- 245
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 245
						if typ then -- 245
							if returnType then -- 246
								returnType = returnType .. ", " .. typ -- 247
							else -- 249
								returnType = typ -- 249
							end -- 246
							result = result:gsub("@return", "**return:**") -- 250
						end -- 245
						comments[#comments + 1] = result -- 251
					end -- 237
				elseif #comments > 0 then -- 252
					comments = { } -- 253
					params = { } -- 254
					returnType = nil -- 255
				end -- 233
			end -- 255
			local results = { } -- 256
			for _index_0 = 1, #docs do -- 257
				local doc = docs[_index_0] -- 257
				if not doc then -- 258
					goto _continue_0 -- 258
				end -- 258
				if doc.params then -- 259
					doc.desc = "function(" .. tostring(table.concat(_anon_func_0(doc), ', ')) .. ")" -- 260
				else -- 262
					doc.desc = "function()" -- 262
				end -- 259
				if doc.returnType then -- 263
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 264
					doc.returnType = nil -- 265
				end -- 263
				results[#results + 1] = doc -- 266
				::_continue_0:: -- 258
			end -- 266
			if #results > 0 then -- 267
				return results -- 267
			else -- 267
				return nil -- 267
			end -- 267
		end -- 212
	end -- 212
	return nil -- 267
end -- 211
HttpServer:postSchedule("/signature", function(req) -- 269
	do -- 270
		local _type_0 = type(req) -- 270
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 270
		if _tab_0 then -- 270
			local lang -- 270
			do -- 270
				local _obj_0 = req.body -- 270
				local _type_1 = type(_obj_0) -- 270
				if "table" == _type_1 or "userdata" == _type_1 then -- 270
					lang = _obj_0.lang -- 270
				end -- 287
			end -- 287
			local file -- 270
			do -- 270
				local _obj_0 = req.body -- 270
				local _type_1 = type(_obj_0) -- 270
				if "table" == _type_1 or "userdata" == _type_1 then -- 270
					file = _obj_0.file -- 270
				end -- 287
			end -- 287
			local content -- 270
			do -- 270
				local _obj_0 = req.body -- 270
				local _type_1 = type(_obj_0) -- 270
				if "table" == _type_1 or "userdata" == _type_1 then -- 270
					content = _obj_0.content -- 270
				end -- 287
			end -- 287
			local line -- 270
			do -- 270
				local _obj_0 = req.body -- 270
				local _type_1 = type(_obj_0) -- 270
				if "table" == _type_1 or "userdata" == _type_1 then -- 270
					line = _obj_0.line -- 270
				end -- 287
			end -- 287
			local row -- 270
			do -- 270
				local _obj_0 = req.body -- 270
				local _type_1 = type(_obj_0) -- 270
				if "table" == _type_1 or "userdata" == _type_1 then -- 270
					row = _obj_0.row -- 270
				end -- 287
			end -- 287
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 270
				local searchPath = getSearchPath(file) -- 271
				if "tl" == lang or "lua" == lang then -- 272
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 273
					if signatures then -- 273
						signatures = getParamDocs(signatures) -- 274
						if signatures then -- 274
							return { -- 275
								success = true, -- 275
								signatures = signatures -- 275
							} -- 275
						end -- 274
					end -- 273
				elseif "yue" == lang then -- 276
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file) -- 277
					if not luaCodes then -- 278
						return { -- 278
							success = false -- 278
						} -- 278
					end -- 278
					do -- 279
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 279
						if chainOp then -- 279
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 280
							targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 281
						end -- 279
					end -- 279
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 282
					if signatures then -- 282
						signatures = getParamDocs(signatures) -- 283
						if signatures then -- 283
							return { -- 284
								success = true, -- 284
								signatures = signatures -- 284
							} -- 284
						end -- 283
					else -- 285
						signatures = teal.getSignatureAsync(luaCodes, "dora." .. tostring(targetLine), targetRow, searchPath) -- 285
						if signatures then -- 285
							signatures = getParamDocs(signatures) -- 286
							if signatures then -- 286
								return { -- 287
									success = true, -- 287
									signatures = signatures -- 287
								} -- 287
							end -- 286
						end -- 285
					end -- 282
				end -- 287
			end -- 270
		end -- 287
	end -- 287
	return { -- 269
		success = false -- 269
	} -- 287
end) -- 269
local luaKeywords = { -- 290
	'and', -- 290
	'break', -- 291
	'do', -- 292
	'else', -- 293
	'elseif', -- 294
	'end', -- 295
	'false', -- 296
	'for', -- 297
	'function', -- 298
	'goto', -- 299
	'if', -- 300
	'in', -- 301
	'local', -- 302
	'nil', -- 303
	'not', -- 304
	'or', -- 305
	'repeat', -- 306
	'return', -- 307
	'then', -- 308
	'true', -- 309
	'until', -- 310
	'while' -- 311
} -- 289
local tealKeywords = { -- 315
	'record', -- 315
	'as', -- 316
	'is', -- 317
	'type', -- 318
	'embed', -- 319
	'enum', -- 320
	'global', -- 321
	'any', -- 322
	'boolean', -- 323
	'integer', -- 324
	'number', -- 325
	'string', -- 326
	'thread' -- 327
} -- 314
local yueKeywords = { -- 331
	"and", -- 331
	"break", -- 332
	"do", -- 333
	"else", -- 334
	"elseif", -- 335
	"false", -- 336
	"for", -- 337
	"goto", -- 338
	"if", -- 339
	"in", -- 340
	"local", -- 341
	"nil", -- 342
	"not", -- 343
	"or", -- 344
	"repeat", -- 345
	"return", -- 346
	"then", -- 347
	"true", -- 348
	"until", -- 349
	"while", -- 350
	"as", -- 351
	"class", -- 352
	"continue", -- 353
	"export", -- 354
	"extends", -- 355
	"from", -- 356
	"global", -- 357
	"import", -- 358
	"macro", -- 359
	"switch", -- 360
	"try", -- 361
	"unless", -- 362
	"using", -- 363
	"when", -- 364
	"with" -- 365
} -- 330
local _anon_func_1 = function(Path, f) -- 401
	local _val_0 = Path:getExt(f) -- 401
	return "ttf" == _val_0 or "otf" == _val_0 -- 401
end -- 401
local _anon_func_2 = function(suggestions) -- 427
	local _tbl_0 = { } -- 427
	for _index_0 = 1, #suggestions do -- 427
		local item = suggestions[_index_0] -- 427
		_tbl_0[item[1] .. item[2]] = item -- 427
	end -- 427
	return _tbl_0 -- 427
end -- 427
HttpServer:postSchedule("/complete", function(req) -- 368
	do -- 369
		local _type_0 = type(req) -- 369
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 369
		if _tab_0 then -- 369
			local lang -- 369
			do -- 369
				local _obj_0 = req.body -- 369
				local _type_1 = type(_obj_0) -- 369
				if "table" == _type_1 or "userdata" == _type_1 then -- 369
					lang = _obj_0.lang -- 369
				end -- 476
			end -- 476
			local file -- 369
			do -- 369
				local _obj_0 = req.body -- 369
				local _type_1 = type(_obj_0) -- 369
				if "table" == _type_1 or "userdata" == _type_1 then -- 369
					file = _obj_0.file -- 369
				end -- 476
			end -- 476
			local content -- 369
			do -- 369
				local _obj_0 = req.body -- 369
				local _type_1 = type(_obj_0) -- 369
				if "table" == _type_1 or "userdata" == _type_1 then -- 369
					content = _obj_0.content -- 369
				end -- 476
			end -- 476
			local line -- 369
			do -- 369
				local _obj_0 = req.body -- 369
				local _type_1 = type(_obj_0) -- 369
				if "table" == _type_1 or "userdata" == _type_1 then -- 369
					line = _obj_0.line -- 369
				end -- 476
			end -- 476
			local row -- 369
			do -- 369
				local _obj_0 = req.body -- 369
				local _type_1 = type(_obj_0) -- 369
				if "table" == _type_1 or "userdata" == _type_1 then -- 369
					row = _obj_0.row -- 369
				end -- 476
			end -- 476
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 369
				local searchPath = getSearchPath(file) -- 370
				repeat -- 371
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 372
					if lang == "yue" then -- 373
						if not item then -- 374
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 374
						end -- 374
						if not item then -- 375
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 375
						end -- 375
					end -- 373
					local searchType = nil -- 376
					if not item then -- 377
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 378
						if lang == "yue" then -- 379
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 380
						end -- 379
						if (item ~= nil) then -- 381
							searchType = "Image" -- 381
						end -- 381
					end -- 377
					if not item then -- 382
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 383
						if lang == "yue" then -- 384
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 385
						end -- 384
						if (item ~= nil) then -- 386
							searchType = "Font" -- 386
						end -- 386
					end -- 382
					if not item then -- 387
						break -- 387
					end -- 387
					local searchPaths = Content.searchPaths -- 388
					local _list_0 = getSearchFolders(file) -- 389
					for _index_0 = 1, #_list_0 do -- 389
						local folder = _list_0[_index_0] -- 389
						searchPaths[#searchPaths + 1] = folder -- 390
					end -- 390
					if searchType then -- 391
						searchPaths[#searchPaths + 1] = Content.assetPath -- 391
					end -- 391
					local tokens -- 392
					do -- 392
						local _accum_0 = { } -- 392
						local _len_0 = 1 -- 392
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 392
							_accum_0[_len_0] = mod -- 392
							_len_0 = _len_0 + 1 -- 392
						end -- 392
						tokens = _accum_0 -- 392
					end -- 392
					local suggestions = { } -- 393
					for _index_0 = 1, #searchPaths do -- 394
						local path = searchPaths[_index_0] -- 394
						local sPath = Path(path, table.unpack(tokens)) -- 395
						if not Content:exist(sPath) then -- 396
							goto _continue_0 -- 396
						end -- 396
						if searchType == "Font" then -- 397
							local fontPath = Path(sPath, "Font") -- 398
							if Content:exist(fontPath) then -- 399
								local _list_1 = Content:getFiles(fontPath) -- 400
								for _index_1 = 1, #_list_1 do -- 400
									local f = _list_1[_index_1] -- 400
									if _anon_func_1(Path, f) then -- 401
										if "." == f:sub(1, 1) then -- 402
											goto _continue_1 -- 402
										end -- 402
										suggestions[#suggestions + 1] = { -- 403
											Path:getName(f), -- 403
											"font", -- 403
											"field" -- 403
										} -- 403
									end -- 401
									::_continue_1:: -- 401
								end -- 403
							end -- 399
						end -- 397
						local _list_1 = Content:getFiles(sPath) -- 404
						for _index_1 = 1, #_list_1 do -- 404
							local f = _list_1[_index_1] -- 404
							if "Image" == searchType then -- 405
								do -- 406
									local _exp_0 = Path:getExt(f) -- 406
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 406
										if "." == f:sub(1, 1) then -- 407
											goto _continue_2 -- 407
										end -- 407
										suggestions[#suggestions + 1] = { -- 408
											f, -- 408
											"image", -- 408
											"field" -- 408
										} -- 408
									end -- 408
								end -- 408
								goto _continue_2 -- 409
							elseif "Font" == searchType then -- 410
								do -- 411
									local _exp_0 = Path:getExt(f) -- 411
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 411
										if "." == f:sub(1, 1) then -- 412
											goto _continue_2 -- 412
										end -- 412
										suggestions[#suggestions + 1] = { -- 413
											f, -- 413
											"font", -- 413
											"field" -- 413
										} -- 413
									end -- 413
								end -- 413
								goto _continue_2 -- 414
							end -- 414
							local _exp_0 = Path:getExt(f) -- 415
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 415
								local name = Path:getName(f) -- 416
								if "d" == Path:getExt(name) then -- 417
									goto _continue_2 -- 417
								end -- 417
								if "." == name:sub(1, 1) then -- 418
									goto _continue_2 -- 418
								end -- 418
								suggestions[#suggestions + 1] = { -- 419
									name, -- 419
									"module", -- 419
									"field" -- 419
								} -- 419
							end -- 419
							::_continue_2:: -- 405
						end -- 419
						local _list_2 = Content:getDirs(sPath) -- 420
						for _index_1 = 1, #_list_2 do -- 420
							local dir = _list_2[_index_1] -- 420
							if "." == dir:sub(1, 1) then -- 421
								goto _continue_3 -- 421
							end -- 421
							suggestions[#suggestions + 1] = { -- 422
								dir, -- 422
								"folder", -- 422
								"variable" -- 422
							} -- 422
							::_continue_3:: -- 421
						end -- 422
						::_continue_0:: -- 395
					end -- 422
					if item == "" and not searchType then -- 423
						local _list_1 = teal.completeAsync("", "dora.", 1, searchPath) -- 424
						for _index_0 = 1, #_list_1 do -- 424
							local _des_0 = _list_1[_index_0] -- 424
							local name = _des_0[1] -- 424
							suggestions[#suggestions + 1] = { -- 425
								name, -- 425
								"dora module", -- 425
								"function" -- 425
							} -- 425
						end -- 425
					end -- 423
					if #suggestions > 0 then -- 426
						do -- 427
							local _accum_0 = { } -- 427
							local _len_0 = 1 -- 427
							for _, v in pairs(_anon_func_2(suggestions)) do -- 427
								_accum_0[_len_0] = v -- 427
								_len_0 = _len_0 + 1 -- 427
							end -- 427
							suggestions = _accum_0 -- 427
						end -- 427
						return { -- 428
							success = true, -- 428
							suggestions = suggestions -- 428
						} -- 428
					else -- 430
						return { -- 430
							success = false -- 430
						} -- 430
					end -- 426
				until true -- 431
				if "tl" == lang or "lua" == lang then -- 432
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 433
					if not line:match("[%.:][%w_]+[%.:]?$") and not line:match("[%w_]+[%.:]$") then -- 434
						local checkSet -- 435
						do -- 435
							local _tbl_0 = { } -- 435
							for _index_0 = 1, #suggestions do -- 435
								local _des_0 = suggestions[_index_0] -- 435
								local name = _des_0[1] -- 435
								_tbl_0[name] = true -- 435
							end -- 435
							checkSet = _tbl_0 -- 435
						end -- 435
						local _list_0 = teal.completeAsync("", "dora.", 1, searchPath) -- 436
						for _index_0 = 1, #_list_0 do -- 436
							local item = _list_0[_index_0] -- 436
							if not checkSet[item[1]] then -- 437
								suggestions[#suggestions + 1] = item -- 437
							end -- 437
						end -- 437
						for _index_0 = 1, #luaKeywords do -- 438
							local word = luaKeywords[_index_0] -- 438
							suggestions[#suggestions + 1] = { -- 439
								word, -- 439
								"keyword", -- 439
								"keyword" -- 439
							} -- 439
						end -- 439
						if lang == "tl" then -- 440
							for _index_0 = 1, #tealKeywords do -- 441
								local word = tealKeywords[_index_0] -- 441
								suggestions[#suggestions + 1] = { -- 442
									word, -- 442
									"keyword", -- 442
									"keyword" -- 442
								} -- 442
							end -- 442
						end -- 440
					end -- 434
					if #suggestions > 0 then -- 443
						return { -- 444
							success = true, -- 444
							suggestions = suggestions -- 444
						} -- 444
					end -- 443
				elseif "yue" == lang then -- 445
					local suggestions = { } -- 446
					local gotGlobals = false -- 447
					do -- 448
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file) -- 448
						if luaCodes then -- 448
							gotGlobals = true -- 449
							do -- 450
								local chainOp = line:match("[^%w_]([%.\\])$") -- 450
								if chainOp then -- 450
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 451
									if not withVar then -- 452
										return { -- 452
											success = false -- 452
										} -- 452
									end -- 452
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 453
								elseif line:match("^([%.\\])$") then -- 454
									return { -- 455
										success = false -- 455
									} -- 455
								end -- 450
							end -- 450
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 456
							for _index_0 = 1, #_list_0 do -- 456
								local item = _list_0[_index_0] -- 456
								suggestions[#suggestions + 1] = item -- 456
							end -- 456
							if #suggestions == 0 then -- 457
								local _list_1 = teal.completeAsync(luaCodes, "dora." .. tostring(targetLine), targetRow, searchPath) -- 458
								for _index_0 = 1, #_list_1 do -- 458
									local item = _list_1[_index_0] -- 458
									suggestions[#suggestions + 1] = item -- 458
								end -- 458
							end -- 457
						end -- 448
					end -- 448
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 459
						local checkSet -- 460
						do -- 460
							local _tbl_0 = { } -- 460
							for _index_0 = 1, #suggestions do -- 460
								local _des_0 = suggestions[_index_0] -- 460
								local name = _des_0[1] -- 460
								_tbl_0[name] = true -- 460
							end -- 460
							checkSet = _tbl_0 -- 460
						end -- 460
						local _list_0 = teal.completeAsync("", "dora.", 1, searchPath) -- 461
						for _index_0 = 1, #_list_0 do -- 461
							local item = _list_0[_index_0] -- 461
							if not checkSet[item[1]] then -- 462
								suggestions[#suggestions + 1] = item -- 462
							end -- 462
						end -- 462
						if not gotGlobals then -- 463
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 464
							for _index_0 = 1, #_list_1 do -- 464
								local item = _list_1[_index_0] -- 464
								if not checkSet[item[1]] then -- 465
									suggestions[#suggestions + 1] = item -- 465
								end -- 465
							end -- 465
						end -- 463
						for _index_0 = 1, #yueKeywords do -- 466
							local word = yueKeywords[_index_0] -- 466
							if not checkSet[word] then -- 467
								suggestions[#suggestions + 1] = { -- 468
									word, -- 468
									"keyword", -- 468
									"keyword" -- 468
								} -- 468
							end -- 467
						end -- 468
					end -- 459
					if #suggestions > 0 then -- 469
						return { -- 470
							success = true, -- 470
							suggestions = suggestions -- 470
						} -- 470
					end -- 469
				elseif "xml" == lang then -- 471
					local items = xml.complete(content) -- 472
					if #items > 0 then -- 473
						local suggestions -- 474
						do -- 474
							local _accum_0 = { } -- 474
							local _len_0 = 1 -- 474
							for _index_0 = 1, #items do -- 474
								local _des_0 = items[_index_0] -- 474
								local label, insertText = _des_0[1], _des_0[2] -- 474
								_accum_0[_len_0] = { -- 475
									label, -- 475
									insertText, -- 475
									"field" -- 475
								} -- 475
								_len_0 = _len_0 + 1 -- 475
							end -- 475
							suggestions = _accum_0 -- 474
						end -- 475
						return { -- 476
							success = true, -- 476
							suggestions = suggestions -- 476
						} -- 476
					end -- 473
				end -- 476
			end -- 369
		end -- 476
	end -- 476
	return { -- 368
		success = false -- 368
	} -- 476
end) -- 368
HttpServer:upload("/upload", function(req, filename) -- 480
	do -- 481
		local _type_0 = type(req) -- 481
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 481
		if _tab_0 then -- 481
			local path -- 481
			do -- 481
				local _obj_0 = req.params -- 481
				local _type_1 = type(_obj_0) -- 481
				if "table" == _type_1 or "userdata" == _type_1 then -- 481
					path = _obj_0.path -- 481
				end -- 487
			end -- 487
			if path ~= nil then -- 481
				local uploadPath = Path(Content.writablePath, ".upload") -- 482
				if not Content:exist(uploadPath) then -- 483
					Content:mkdir(uploadPath) -- 484
				end -- 483
				local targetPath = Path(uploadPath, filename) -- 485
				Content:mkdir(Path:getPath(targetPath)) -- 486
				return targetPath -- 487
			end -- 481
		end -- 487
	end -- 487
	return nil -- 487
end, function(req, file) -- 488
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
				end -- 494
			end -- 494
			if path ~= nil then -- 489
				local uploadPath = Path(Content.writablePath, ".upload") -- 490
				local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 491
				Content:mkdir(Path:getPath(targetPath)) -- 492
				if Content:move(file, targetPath) then -- 493
					return true -- 494
				end -- 493
			end -- 489
		end -- 494
	end -- 494
	return false -- 494
end) -- 478
HttpServer:post("/list", function(req) -- 497
	do -- 498
		local _type_0 = type(req) -- 498
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 498
		if _tab_0 then -- 498
			local path -- 498
			do -- 498
				local _obj_0 = req.body -- 498
				local _type_1 = type(_obj_0) -- 498
				if "table" == _type_1 or "userdata" == _type_1 then -- 498
					path = _obj_0.path -- 498
				end -- 520
			end -- 520
			if path ~= nil then -- 498
				if Content:exist(path) then -- 499
					local files = { } -- 500
					local visitAssets -- 501
					visitAssets = function(path, folder) -- 501
						local dirs = Content:getDirs(path) -- 502
						for _index_0 = 1, #dirs do -- 503
							local dir = dirs[_index_0] -- 503
							if dir:match("^%.") then -- 504
								goto _continue_0 -- 504
							end -- 504
							local current -- 505
							if folder == "" then -- 505
								current = dir -- 506
							else -- 508
								current = Path(folder, dir) -- 508
							end -- 505
							files[#files + 1] = current -- 509
							visitAssets(Path(path, dir), current) -- 510
							::_continue_0:: -- 504
						end -- 510
						local fs = Content:getFiles(path) -- 511
						for _index_0 = 1, #fs do -- 512
							local f = fs[_index_0] -- 512
							if f:match("^%.") then -- 513
								goto _continue_1 -- 513
							end -- 513
							if folder == "" then -- 514
								files[#files + 1] = f -- 515
							else -- 517
								files[#files + 1] = Path(folder, f) -- 517
							end -- 514
							::_continue_1:: -- 513
						end -- 517
					end -- 501
					visitAssets(path, "") -- 518
					if #files == 0 then -- 519
						files = nil -- 519
					end -- 519
					return { -- 520
						success = true, -- 520
						files = files -- 520
					} -- 520
				end -- 499
			end -- 498
		end -- 520
	end -- 520
	return { -- 497
		success = false -- 497
	} -- 520
end) -- 497
HttpServer:post("/info", function() -- 522
	return { -- 523
		platform = App.platform, -- 523
		locale = App.locale, -- 524
		version = App.version -- 525
	} -- 525
end) -- 522
HttpServer:post("/new", function(req) -- 527
	do -- 528
		local _type_0 = type(req) -- 528
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 528
		if _tab_0 then -- 528
			local path -- 528
			do -- 528
				local _obj_0 = req.body -- 528
				local _type_1 = type(_obj_0) -- 528
				if "table" == _type_1 or "userdata" == _type_1 then -- 528
					path = _obj_0.path -- 528
				end -- 540
			end -- 540
			local content -- 528
			do -- 528
				local _obj_0 = req.body -- 528
				local _type_1 = type(_obj_0) -- 528
				if "table" == _type_1 or "userdata" == _type_1 then -- 528
					content = _obj_0.content -- 528
				end -- 540
			end -- 540
			if path ~= nil and content ~= nil then -- 528
				if not Content:exist(path) then -- 529
					local parent = Path:getPath(path) -- 530
					local files = Content:getFiles(parent) -- 531
					local name = Path:getName(path):lower() -- 532
					for _index_0 = 1, #files do -- 533
						local file = files[_index_0] -- 533
						if name == Path:getName(file):lower() then -- 534
							return { -- 535
								success = false -- 535
							} -- 535
						end -- 534
					end -- 535
					if "" == Path:getExt(path) then -- 536
						if Content:mkdir(path) then -- 537
							return { -- 538
								success = true -- 538
							} -- 538
						end -- 537
					elseif Content:save(path, content) then -- 539
						return { -- 540
							success = true -- 540
						} -- 540
					end -- 536
				end -- 529
			end -- 528
		end -- 540
	end -- 540
	return { -- 527
		success = false -- 527
	} -- 540
end) -- 527
HttpServer:post("/delete", function(req) -- 542
	do -- 543
		local _type_0 = type(req) -- 543
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 543
		if _tab_0 then -- 543
			local path -- 543
			do -- 543
				local _obj_0 = req.body -- 543
				local _type_1 = type(_obj_0) -- 543
				if "table" == _type_1 or "userdata" == _type_1 then -- 543
					path = _obj_0.path -- 543
				end -- 556
			end -- 556
			if path ~= nil then -- 543
				if Content:exist(path) then -- 544
					local parent = Path:getPath(path) -- 545
					local files = Content:getFiles(parent) -- 546
					local name = Path:getName(path):lower() -- 547
					local ext = Path:getExt(path) -- 548
					for _index_0 = 1, #files do -- 549
						local file = files[_index_0] -- 549
						if name == Path:getName(file):lower() then -- 550
							local _exp_0 = Path:getExt(file) -- 551
							if "tl" == _exp_0 then -- 551
								if ("vs" == ext) then -- 551
									Content:remove(Path(parent, file)) -- 552
								end -- 551
							elseif "lua" == _exp_0 then -- 553
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 553
									Content:remove(Path(parent, file)) -- 554
								end -- 553
							end -- 554
						end -- 550
					end -- 554
					if Content:remove(path) then -- 555
						return { -- 556
							success = true -- 556
						} -- 556
					end -- 555
				end -- 544
			end -- 543
		end -- 556
	end -- 556
	return { -- 542
		success = false -- 542
	} -- 556
end) -- 542
HttpServer:post("/rename", function(req) -- 558
	do -- 559
		local _type_0 = type(req) -- 559
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 559
		if _tab_0 then -- 559
			local old -- 559
			do -- 559
				local _obj_0 = req.body -- 559
				local _type_1 = type(_obj_0) -- 559
				if "table" == _type_1 or "userdata" == _type_1 then -- 559
					old = _obj_0.old -- 559
				end -- 581
			end -- 581
			local new -- 559
			do -- 559
				local _obj_0 = req.body -- 559
				local _type_1 = type(_obj_0) -- 559
				if "table" == _type_1 or "userdata" == _type_1 then -- 559
					new = _obj_0.new -- 559
				end -- 581
			end -- 581
			if old ~= nil and new ~= nil then -- 559
				if Content:exist(old) and not Content:exist(new) then -- 560
					local parent = Path:getPath(new) -- 561
					local files = Content:getFiles(parent) -- 562
					local name = Path:getName(new):lower() -- 563
					for _index_0 = 1, #files do -- 564
						local file = files[_index_0] -- 564
						if name == Path:getName(file):lower() then -- 565
							return { -- 566
								success = false -- 566
							} -- 566
						end -- 565
					end -- 566
					if Content:move(old, new) then -- 567
						local newParent = Path:getPath(new) -- 568
						parent = Path:getPath(old) -- 569
						files = Content:getFiles(parent) -- 570
						local newName = Path:getName(new) -- 571
						local oldName = Path:getName(old) -- 572
						name = oldName:lower() -- 573
						local ext = Path:getExt(old) -- 574
						for _index_0 = 1, #files do -- 575
							local file = files[_index_0] -- 575
							if name == Path:getName(file):lower() then -- 576
								local _exp_0 = Path:getExt(file) -- 577
								if "tl" == _exp_0 then -- 577
									if ("vs" == ext) then -- 577
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 578
									end -- 577
								elseif "lua" == _exp_0 then -- 579
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 579
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 580
									end -- 579
								end -- 580
							end -- 576
						end -- 580
						return { -- 581
							success = true -- 581
						} -- 581
					end -- 567
				end -- 560
			end -- 559
		end -- 581
	end -- 581
	return { -- 558
		success = false -- 558
	} -- 581
end) -- 558
HttpServer:postSchedule("/read", function(req) -- 583
	do -- 584
		local _type_0 = type(req) -- 584
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 584
		if _tab_0 then -- 584
			local path -- 584
			do -- 584
				local _obj_0 = req.body -- 584
				local _type_1 = type(_obj_0) -- 584
				if "table" == _type_1 or "userdata" == _type_1 then -- 584
					path = _obj_0.path -- 584
				end -- 587
			end -- 587
			if path ~= nil then -- 584
				if Content:exist(path) then -- 585
					local content = Content:loadAsync(path) -- 586
					if content then -- 586
						return { -- 587
							content = content, -- 587
							success = true -- 587
						} -- 587
					end -- 586
				end -- 585
			end -- 584
		end -- 587
	end -- 587
	return { -- 583
		success = false -- 583
	} -- 587
end) -- 583
local compileFileAsync -- 589
compileFileAsync = function(inputFile, sourceCodes) -- 589
	local file = Path:getFilename(inputFile) -- 590
	local searchPath -- 591
	do -- 591
		local dir = getProjectDirFromFile(inputFile) -- 591
		if dir then -- 591
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 592
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 593
		else -- 594
			searchPath = "" -- 594
		end -- 591
	end -- 591
	local outputFile = Path:replaceExt(inputFile, "lua") -- 595
	local yueext = yue.options.extension -- 596
	local resultCodes = nil -- 597
	do -- 598
		local _exp_0 = Path:getExt(inputFile) -- 598
		if yueext == _exp_0 then -- 598
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 599
				if not codes then -- 600
					return -- 600
				end -- 600
				local success, result = LintYueGlobals(codes, globals) -- 601
				if not success then -- 602
					return -- 602
				end -- 602
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 603
				codes = codes:gsub("^\n*", "") -- 604
				if not (result == "") then -- 605
					result = result .. "\n" -- 605
				end -- 605
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 606
				return resultCodes -- 607
			end, function(success) -- 599
				if not success then -- 608
					Content:remove(outputFile) -- 609
					resultCodes = false -- 610
				end -- 608
			end) -- 599
		elseif "tl" == _exp_0 then -- 611
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 612
			if codes then -- 612
				resultCodes = codes -- 613
				Content:saveAsync(outputFile, codes) -- 614
			else -- 616
				Content:remove(outputFile) -- 616
				resultCodes = false -- 617
			end -- 612
		elseif "xml" == _exp_0 then -- 618
			local codes = xml.tolua(sourceCodes) -- 619
			if codes then -- 619
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 620
				Content:saveAsync(outputFile, resultCodes) -- 621
			else -- 623
				Content:remove(outputFile) -- 623
				resultCodes = false -- 624
			end -- 619
		end -- 624
	end -- 624
	wait(function() -- 625
		return resultCodes ~= nil -- 625
	end) -- 625
	if resultCodes then -- 626
		return resultCodes -- 626
	end -- 626
	return nil -- 626
end -- 589
HttpServer:postSchedule("/write", function(req) -- 628
	do -- 629
		local _type_0 = type(req) -- 629
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 629
		if _tab_0 then -- 629
			local path -- 629
			do -- 629
				local _obj_0 = req.body -- 629
				local _type_1 = type(_obj_0) -- 629
				if "table" == _type_1 or "userdata" == _type_1 then -- 629
					path = _obj_0.path -- 629
				end -- 635
			end -- 635
			local content -- 629
			do -- 629
				local _obj_0 = req.body -- 629
				local _type_1 = type(_obj_0) -- 629
				if "table" == _type_1 or "userdata" == _type_1 then -- 629
					content = _obj_0.content -- 629
				end -- 635
			end -- 635
			if path ~= nil and content ~= nil then -- 629
				if Content:saveAsync(path, content) then -- 630
					do -- 631
						local _exp_0 = Path:getExt(path) -- 631
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 631
							if '' == Path:getExt(Path:getName(path)) then -- 632
								local resultCodes = compileFileAsync(path, content) -- 633
								return { -- 634
									success = true, -- 634
									resultCodes = resultCodes -- 634
								} -- 634
							end -- 632
						end -- 634
					end -- 634
					return { -- 635
						success = true -- 635
					} -- 635
				end -- 630
			end -- 629
		end -- 635
	end -- 635
	return { -- 628
		success = false -- 628
	} -- 635
end) -- 628
local extentionLevels = { -- 638
	vs = 2, -- 638
	ts = 1, -- 639
	tsx = 1, -- 640
	tl = 1, -- 641
	yue = 1, -- 642
	xml = 1, -- 643
	lua = 0 -- 644
} -- 637
local _anon_func_4 = function(Content, Path, visitAssets, zh) -- 709
	local _with_0 = visitAssets(Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")) -- 708
	_with_0.title = zh and "说明文档" or "Readme" -- 709
	return _with_0 -- 708
end -- 708
local _anon_func_5 = function(Content, Path, visitAssets, zh) -- 711
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")) -- 710
	_with_0.title = zh and "接口文档" or "API Doc" -- 711
	return _with_0 -- 710
end -- 710
local _anon_func_6 = function(Content, Path, visitAssets, zh) -- 713
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Example")) -- 712
	_with_0.title = zh and "代码示例" or "Example" -- 713
	return _with_0 -- 712
end -- 712
local _anon_func_7 = function(Content, Path, visitAssets, zh) -- 715
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Test")) -- 714
	_with_0.title = zh and "功能测试" or "Test" -- 715
	return _with_0 -- 714
end -- 714
local _anon_func_3 = function(Content, Path, pairs, visitAssets, zh) -- 720
	local _tab_0 = { -- 703
		{ -- 704
			key = Path(Content.assetPath), -- 704
			dir = true, -- 705
			title = zh and "内置资源" or "Built-in", -- 706
			children = { -- 708
				_anon_func_4(Content, Path, visitAssets, zh), -- 708
				_anon_func_5(Content, Path, visitAssets, zh), -- 710
				_anon_func_6(Content, Path, visitAssets, zh), -- 712
				_anon_func_7(Content, Path, visitAssets, zh), -- 714
				visitAssets(Path(Content.assetPath, "Image")), -- 716
				visitAssets(Path(Content.assetPath, "Spine")), -- 717
				visitAssets(Path(Content.assetPath, "Font")) -- 718
			} -- 707
		} -- 703
	} -- 721
	local _obj_0 = visitAssets(Content.writablePath, true) -- 721
	local _idx_0 = #_tab_0 + 1 -- 721
	for _index_0 = 1, #_obj_0 do -- 721
		local _value_0 = _obj_0[_index_0] -- 721
		_tab_0[_idx_0] = _value_0 -- 721
		_idx_0 = _idx_0 + 1 -- 721
	end -- 721
	return _tab_0 -- 720
end -- 703
HttpServer:post("/assets", function() -- 646
	local visitAssets -- 647
	visitAssets = function(path, root) -- 647
		local children = nil -- 648
		local dirs = Content:getDirs(path) -- 649
		for _index_0 = 1, #dirs do -- 650
			local dir = dirs[_index_0] -- 650
			if root then -- 651
				if ".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir then -- 651
					goto _continue_0 -- 652
				end -- 652
			elseif dir == ".git" then -- 653
				goto _continue_0 -- 654
			end -- 651
			if not children then -- 655
				children = { } -- 655
			end -- 655
			children[#children + 1] = visitAssets(Path(path, dir)) -- 656
			::_continue_0:: -- 651
		end -- 656
		local files = Content:getFiles(path) -- 657
		local names = { } -- 658
		for _index_0 = 1, #files do -- 659
			local file = files[_index_0] -- 659
			if file:match("^%.") then -- 660
				goto _continue_1 -- 660
			end -- 660
			local name = Path:getName(file) -- 661
			local ext = names[name] -- 662
			if ext then -- 662
				local lv1 -- 663
				do -- 663
					local _exp_0 = extentionLevels[ext] -- 663
					if _exp_0 ~= nil then -- 663
						lv1 = _exp_0 -- 663
					else -- 663
						lv1 = -1 -- 663
					end -- 663
				end -- 663
				ext = Path:getExt(file) -- 664
				local lv2 -- 665
				do -- 665
					local _exp_0 = extentionLevels[ext] -- 665
					if _exp_0 ~= nil then -- 665
						lv2 = _exp_0 -- 665
					else -- 665
						lv2 = -1 -- 665
					end -- 665
				end -- 665
				if lv2 > lv1 then -- 666
					names[name] = ext -- 666
				end -- 666
			else -- 668
				ext = Path:getExt(file) -- 668
				if not extentionLevels[ext] then -- 669
					names[file] = "" -- 670
				else -- 672
					names[name] = ext -- 672
				end -- 669
			end -- 662
			::_continue_1:: -- 660
		end -- 672
		do -- 673
			local _accum_0 = { } -- 673
			local _len_0 = 1 -- 673
			for name, ext in pairs(names) do -- 673
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 673
				_len_0 = _len_0 + 1 -- 673
			end -- 673
			files = _accum_0 -- 673
		end -- 673
		for _index_0 = 1, #files do -- 674
			local file = files[_index_0] -- 674
			if not children then -- 675
				children = { } -- 675
			end -- 675
			children[#children + 1] = { -- 677
				key = Path(path, file), -- 677
				dir = false, -- 678
				title = file -- 679
			} -- 676
		end -- 680
		if children then -- 681
			table.sort(children, function(a, b) -- 682
				if a.dir == b.dir then -- 683
					return a.title < b.title -- 684
				else -- 686
					return a.dir -- 686
				end -- 683
			end) -- 682
		end -- 681
		local title = Path:getFilename(path) -- 687
		if title == "" then -- 688
			return children -- 689
		else -- 691
			return { -- 692
				key = path, -- 692
				dir = true, -- 693
				title = title, -- 694
				children = children -- 695
			} -- 696
		end -- 688
	end -- 647
	local zh = (App.locale:match("^zh") ~= nil) -- 697
	return { -- 699
		key = Content.writablePath, -- 699
		dir = true, -- 700
		title = "Assets", -- 701
		children = _anon_func_3(Content, Path, pairs, visitAssets, zh) -- 702
	} -- 723
end) -- 646
HttpServer:postSchedule("/run", function(req) -- 725
	do -- 726
		local _type_0 = type(req) -- 726
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 726
		if _tab_0 then -- 726
			local file -- 726
			do -- 726
				local _obj_0 = req.body -- 726
				local _type_1 = type(_obj_0) -- 726
				if "table" == _type_1 or "userdata" == _type_1 then -- 726
					file = _obj_0.file -- 726
				end -- 738
			end -- 738
			local asProj -- 726
			do -- 726
				local _obj_0 = req.body -- 726
				local _type_1 = type(_obj_0) -- 726
				if "table" == _type_1 or "userdata" == _type_1 then -- 726
					asProj = _obj_0.asProj -- 726
				end -- 738
			end -- 738
			if file ~= nil and asProj ~= nil then -- 726
				local Entry = require("Dev.Entry") -- 727
				if asProj then -- 728
					local proj = getProjectDirFromFile(file) -- 729
					if proj then -- 729
						Entry.allClear() -- 730
						local target = Path(proj, "init") -- 731
						local success, err = Entry.enterEntryAsync({ -- 732
							"Project", -- 732
							target -- 732
						}) -- 732
						target = Path:getName(Path:getPath(target)) -- 733
						return { -- 734
							success = success, -- 734
							target = target, -- 734
							err = err -- 734
						} -- 734
					end -- 729
				end -- 728
				Entry.allClear() -- 735
				file = Path:replaceExt(file, "") -- 736
				local success, err = Entry.enterEntryAsync({ -- 737
					Path:getName(file), -- 737
					file -- 737
				}) -- 737
				return { -- 738
					success = success, -- 738
					err = err -- 738
				} -- 738
			end -- 726
		end -- 738
	end -- 738
	return { -- 725
		success = false -- 725
	} -- 738
end) -- 725
HttpServer:postSchedule("/stop", function() -- 740
	local Entry = require("Dev.Entry") -- 741
	return { -- 742
		success = Entry.stop() -- 742
	} -- 742
end) -- 740
HttpServer:postSchedule("/zip", function(req) -- 744
	do -- 745
		local _type_0 = type(req) -- 745
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 745
		if _tab_0 then -- 745
			local path -- 745
			do -- 745
				local _obj_0 = req.body -- 745
				local _type_1 = type(_obj_0) -- 745
				if "table" == _type_1 or "userdata" == _type_1 then -- 745
					path = _obj_0.path -- 745
				end -- 748
			end -- 748
			local zipFile -- 745
			do -- 745
				local _obj_0 = req.body -- 745
				local _type_1 = type(_obj_0) -- 745
				if "table" == _type_1 or "userdata" == _type_1 then -- 745
					zipFile = _obj_0.zipFile -- 745
				end -- 748
			end -- 748
			if path ~= nil and zipFile ~= nil then -- 745
				Content:mkdir(Path:getPath(zipFile)) -- 746
				return { -- 747
					success = Content:zipAsync(path, zipFile, function(file) -- 747
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 748
					end) -- 747
				} -- 748
			end -- 745
		end -- 748
	end -- 748
	return { -- 744
		success = false -- 744
	} -- 748
end) -- 744
HttpServer:postSchedule("/unzip", function(req) -- 750
	do -- 751
		local _type_0 = type(req) -- 751
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 751
		if _tab_0 then -- 751
			local zipFile -- 751
			do -- 751
				local _obj_0 = req.body -- 751
				local _type_1 = type(_obj_0) -- 751
				if "table" == _type_1 or "userdata" == _type_1 then -- 751
					zipFile = _obj_0.zipFile -- 751
				end -- 753
			end -- 753
			local path -- 751
			do -- 751
				local _obj_0 = req.body -- 751
				local _type_1 = type(_obj_0) -- 751
				if "table" == _type_1 or "userdata" == _type_1 then -- 751
					path = _obj_0.path -- 751
				end -- 753
			end -- 753
			if zipFile ~= nil and path ~= nil then -- 751
				return { -- 752
					success = Content:unzipAsync(zipFile, path, function(file) -- 752
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 753
					end) -- 752
				} -- 753
			end -- 751
		end -- 753
	end -- 753
	return { -- 754
		success = false -- 754
	} -- 754
end) -- 750
HttpServer:post("/editingInfo", function(req) -- 756
	local Entry = require("Dev.Entry") -- 757
	local config = Entry.getConfig() -- 758
	local _type_0 = type(req) -- 759
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 759
	local _match_0 = false -- 759
	if _tab_0 then -- 759
		local editingInfo -- 759
		do -- 759
			local _obj_0 = req.body -- 759
			local _type_1 = type(_obj_0) -- 759
			if "table" == _type_1 or "userdata" == _type_1 then -- 759
				editingInfo = _obj_0.editingInfo -- 759
			end -- 761
		end -- 761
		if editingInfo ~= nil then -- 759
			_match_0 = true -- 759
			config.editingInfo = editingInfo -- 760
			return { -- 761
				success = true -- 761
			} -- 761
		end -- 759
	end -- 759
	if not _match_0 then -- 759
		if not (config.editingInfo ~= nil) then -- 763
			local json = require("json") -- 764
			local folder -- 765
			if App.locale:match('^zh') then -- 765
				folder = 'zh-Hans' -- 765
			else -- 765
				folder = 'en' -- 765
			end -- 765
			config.editingInfo = json.dump({ -- 767
				index = 0, -- 767
				files = { -- 769
					{ -- 770
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 770
						title = "welcome.md" -- 771
					} -- 769
				} -- 768
			}) -- 766
		end -- 763
		return { -- 775
			success = true, -- 775
			editingInfo = config.editingInfo -- 775
		} -- 775
	end -- 775
end) -- 756
HttpServer:post("/command", function(req) -- 777
	do -- 778
		local _type_0 = type(req) -- 778
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 778
		if _tab_0 then -- 778
			local code -- 778
			do -- 778
				local _obj_0 = req.body -- 778
				local _type_1 = type(_obj_0) -- 778
				if "table" == _type_1 or "userdata" == _type_1 then -- 778
					code = _obj_0.code -- 778
				end -- 780
			end -- 780
			if code ~= nil then -- 778
				emit("AppCommand", code) -- 779
				return { -- 780
					success = true -- 780
				} -- 780
			end -- 778
		end -- 780
	end -- 780
	return { -- 777
		success = false -- 777
	} -- 780
end) -- 777
HttpServer:post("/exist", function(req) -- 782
	do -- 783
		local _type_0 = type(req) -- 783
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 783
		if _tab_0 then -- 783
			local file -- 783
			do -- 783
				local _obj_0 = req.body -- 783
				local _type_1 = type(_obj_0) -- 783
				if "table" == _type_1 or "userdata" == _type_1 then -- 783
					file = _obj_0.file -- 783
				end -- 784
			end -- 784
			if file ~= nil then -- 783
				return { -- 784
					success = Content:exist(file) -- 784
				} -- 784
			end -- 783
		end -- 784
	end -- 784
	return { -- 782
		success = false -- 782
	} -- 784
end) -- 782
local status = { -- 786
	url = nil -- 786
} -- 786
_module_0 = status -- 787
thread(function() -- 789
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 790
	local doraReady = Path(Content.writablePath, ".www", "dora-ready") -- 791
	if Content:exist(doraWeb) then -- 792
		local needReload -- 793
		if Content:exist(doraReady) then -- 793
			needReload = App.version ~= Content:load(doraReady) -- 794
		else -- 795
			needReload = true -- 795
		end -- 793
		if needReload then -- 796
			Content:remove(Path(Content.writablePath, ".www")) -- 797
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.writablePath, ".www")) -- 798
			Content:save(doraReady, App.version) -- 802
			print("Dora Dora is ready!") -- 803
		end -- 796
		if HttpServer:start(8866) then -- 804
			local localIP = HttpServer.localIP -- 805
			if localIP == "" then -- 806
				localIP = "localhost" -- 806
			end -- 806
			status.url = "http://" .. tostring(localIP) .. ":8866" -- 807
			return HttpServer:startWS(8868) -- 808
		else -- 810
			status.url = nil -- 810
			return print("8866 Port not available!") -- 811
		end -- 804
	end -- 792
end) -- 789
return _module_0 -- 811
