-- [yue]: Script/Dev/WebServer.yue
local HttpServer = Dora.HttpServer -- 1
local Path = Dora.Path -- 1
local Content = Dora.Content -- 1
local tostring = _G.tostring -- 1
local yue = Dora.yue -- 1
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
local emit = Dora.emit -- 1
local thread = Dora.thread -- 1
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
				return Path(writablePath, current, Path:getPath(f)) -- 26
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
			return tostring(Path(dir, "Script", "?.lua")) .. ";" .. tostring(Path(dir, "?.lua")) -- 32
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
				local _name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 76
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
				if not item[5]:match("unused") then -- 89
					for _index_1 = 1, #disabledCheckForLua do -- 90
						local check = disabledCheckForLua[_index_1] -- 90
						if item[5]:match(check) then -- 91
							useCheck = false -- 92
						end -- 91
					end -- 92
				end -- 89
				if not useCheck then -- 93
					goto _continue_0 -- 93
				end -- 93
				do -- 94
					local _exp_0 = item[1] -- 94
					if "type" == _exp_0 then -- 95
						item[1] = "warning" -- 96
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 97
						goto _continue_0 -- 98
					end -- 98
				end -- 98
				_accum_0[_len_0] = item -- 99
				_len_0 = _len_0 + 1 -- 99
				::_continue_0:: -- 88
			end -- 99
			info = _accum_0 -- 87
		end -- 99
		if #info == 0 then -- 100
			info = nil -- 101
			success = true -- 102
		end -- 100
	end -- 86
	return { -- 103
		success = success, -- 103
		info = info -- 103
	} -- 103
end -- 80
local luaCheckWithLineInfo -- 105
luaCheckWithLineInfo = function(file, luaCodes) -- 105
	local res = luaCheck(file, luaCodes) -- 106
	local info = { } -- 107
	if not res.success then -- 108
		local current = 1 -- 109
		local lastLine = 1 -- 110
		local lineMap = { } -- 111
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 112
			local num = lineCode:match("--%s*(%d+)%s*$") -- 113
			if num then -- 114
				lastLine = tonumber(num) -- 115
			end -- 114
			lineMap[current] = lastLine -- 116
			current = current + 1 -- 117
		end -- 117
		local _list_0 = res.info -- 118
		for _index_0 = 1, #_list_0 do -- 118
			local item = _list_0[_index_0] -- 118
			item[3] = lineMap[item[3]] or 0 -- 119
			item[4] = 0 -- 120
			info[#info + 1] = item -- 121
		end -- 121
		return false, info -- 122
	end -- 108
	return true, info -- 123
end -- 105
local getCompiledYueLine -- 125
getCompiledYueLine = function(content, line, row, file) -- 125
	local luaCodes, _info = yueCheck(file, content) -- 126
	if not luaCodes then -- 127
		return nil -- 127
	end -- 127
	local current = 1 -- 128
	local lastLine = 1 -- 129
	local targetLine = nil -- 130
	local targetRow = nil -- 131
	local lineMap = { } -- 132
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 133
		local num = lineCode:match("--%s*(%d+)%s*$") -- 134
		if num then -- 135
			lastLine = tonumber(num) -- 135
		end -- 135
		lineMap[current] = lastLine -- 136
		if row == lastLine and not targetLine then -- 137
			targetRow = current -- 138
			targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 139
			if targetLine then -- 140
				break -- 140
			end -- 140
		end -- 137
		current = current + 1 -- 141
	end -- 141
	if targetLine and targetRow then -- 142
		return luaCodes, targetLine, targetRow, lineMap -- 143
	else -- 145
		return nil -- 145
	end -- 142
end -- 125
HttpServer:postSchedule("/check", function(req) -- 147
	do -- 148
		local _type_0 = type(req) -- 148
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 148
		if _tab_0 then -- 148
			local file -- 148
			do -- 148
				local _obj_0 = req.body -- 148
				local _type_1 = type(_obj_0) -- 148
				if "table" == _type_1 or "userdata" == _type_1 then -- 148
					file = _obj_0.file -- 148
				end -- 178
			end -- 178
			local content -- 148
			do -- 148
				local _obj_0 = req.body -- 148
				local _type_1 = type(_obj_0) -- 148
				if "table" == _type_1 or "userdata" == _type_1 then -- 148
					content = _obj_0.content -- 148
				end -- 178
			end -- 178
			if file ~= nil and content ~= nil then -- 148
				local ext = Path:getExt(file) -- 149
				if "tl" == ext then -- 150
					local searchPath = getSearchPath(file) -- 151
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 152
					return { -- 153
						success = success, -- 153
						info = info -- 153
					} -- 153
				elseif "lua" == ext then -- 154
					return luaCheck(file, content) -- 155
				elseif "yue" == ext then -- 156
					local luaCodes, info = yueCheck(file, content) -- 157
					local success = false -- 158
					if luaCodes then -- 159
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 160
						do -- 161
							local _tab_1 = { } -- 161
							local _idx_0 = #_tab_1 + 1 -- 161
							for _index_0 = 1, #info do -- 161
								local _value_0 = info[_index_0] -- 161
								_tab_1[_idx_0] = _value_0 -- 161
								_idx_0 = _idx_0 + 1 -- 161
							end -- 161
							local _idx_1 = #_tab_1 + 1 -- 161
							for _index_0 = 1, #luaInfo do -- 161
								local _value_0 = luaInfo[_index_0] -- 161
								_tab_1[_idx_1] = _value_0 -- 161
								_idx_1 = _idx_1 + 1 -- 161
							end -- 161
							info = _tab_1 -- 161
						end -- 161
						success = success and luaSuccess -- 162
					end -- 159
					if #info > 0 then -- 163
						return { -- 164
							success = success, -- 164
							info = info -- 164
						} -- 164
					else -- 166
						return { -- 166
							success = success -- 166
						} -- 166
					end -- 163
				elseif "xml" == ext then -- 167
					local success, result = xml.check(content) -- 168
					if success then -- 169
						local info -- 170
						success, info = luaCheckWithLineInfo(file, result) -- 170
						if #info > 0 then -- 171
							return { -- 172
								success = success, -- 172
								info = info -- 172
							} -- 172
						else -- 174
							return { -- 174
								success = success -- 174
							} -- 174
						end -- 171
					else -- 176
						local info -- 176
						do -- 176
							local _accum_0 = { } -- 176
							local _len_0 = 1 -- 176
							for _index_0 = 1, #result do -- 176
								local _des_0 = result[_index_0] -- 176
								local row, err = _des_0[1], _des_0[2] -- 176
								_accum_0[_len_0] = { -- 177
									"syntax", -- 177
									file, -- 177
									row, -- 177
									0, -- 177
									err -- 177
								} -- 177
								_len_0 = _len_0 + 1 -- 177
							end -- 177
							info = _accum_0 -- 176
						end -- 177
						return { -- 178
							success = false, -- 178
							info = info -- 178
						} -- 178
					end -- 169
				end -- 178
			end -- 148
		end -- 178
	end -- 178
	return { -- 147
		success = true -- 147
	} -- 178
end) -- 147
local updateInferedDesc -- 180
updateInferedDesc = function(infered) -- 180
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 181
		return -- 181
	end -- 181
	local key, row = infered.key, infered.row -- 182
	local codes = Content:loadAsync(key) -- 183
	if codes then -- 183
		local comments = { } -- 184
		local line = 0 -- 185
		local skipping = false -- 186
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 187
			line = line + 1 -- 188
			if line >= row then -- 189
				break -- 189
			end -- 189
			if lineCode:match("^%s*%-%- @") then -- 190
				skipping = true -- 191
				goto _continue_0 -- 192
			end -- 190
			local result = lineCode:match("^%s*%-%- (.+)") -- 193
			if result then -- 193
				if not skipping then -- 194
					comments[#comments + 1] = result -- 194
				end -- 194
			elseif #comments > 0 then -- 195
				comments = { } -- 196
				skipping = false -- 197
			end -- 193
			::_continue_0:: -- 188
		end -- 197
		infered.doc = table.concat(comments, "\n") -- 198
	end -- 183
end -- 180
HttpServer:postSchedule("/infer", function(req) -- 200
	do -- 201
		local _type_0 = type(req) -- 201
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 201
		if _tab_0 then -- 201
			local lang -- 201
			do -- 201
				local _obj_0 = req.body -- 201
				local _type_1 = type(_obj_0) -- 201
				if "table" == _type_1 or "userdata" == _type_1 then -- 201
					lang = _obj_0.lang -- 201
				end -- 218
			end -- 218
			local file -- 201
			do -- 201
				local _obj_0 = req.body -- 201
				local _type_1 = type(_obj_0) -- 201
				if "table" == _type_1 or "userdata" == _type_1 then -- 201
					file = _obj_0.file -- 201
				end -- 218
			end -- 218
			local content -- 201
			do -- 201
				local _obj_0 = req.body -- 201
				local _type_1 = type(_obj_0) -- 201
				if "table" == _type_1 or "userdata" == _type_1 then -- 201
					content = _obj_0.content -- 201
				end -- 218
			end -- 218
			local line -- 201
			do -- 201
				local _obj_0 = req.body -- 201
				local _type_1 = type(_obj_0) -- 201
				if "table" == _type_1 or "userdata" == _type_1 then -- 201
					line = _obj_0.line -- 201
				end -- 218
			end -- 218
			local row -- 201
			do -- 201
				local _obj_0 = req.body -- 201
				local _type_1 = type(_obj_0) -- 201
				if "table" == _type_1 or "userdata" == _type_1 then -- 201
					row = _obj_0.row -- 201
				end -- 218
			end -- 218
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 201
				local searchPath = getSearchPath(file) -- 202
				if "tl" == lang or "lua" == lang then -- 203
					local infered = teal.inferAsync(content, line, row, searchPath) -- 204
					if (infered ~= nil) then -- 205
						updateInferedDesc(infered) -- 206
						return { -- 207
							success = true, -- 207
							infered = infered -- 207
						} -- 207
					end -- 205
				elseif "yue" == lang then -- 208
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file) -- 209
					if not luaCodes then -- 210
						return { -- 210
							success = false -- 210
						} -- 210
					end -- 210
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 211
					if (infered ~= nil) then -- 212
						local col -- 213
						file, row, col = infered.file, infered.row, infered.col -- 213
						if file == "" and row > 0 and col > 0 then -- 214
							infered.row = lineMap[row] or 0 -- 215
							infered.col = 0 -- 216
						end -- 214
						updateInferedDesc(infered) -- 217
						return { -- 218
							success = true, -- 218
							infered = infered -- 218
						} -- 218
					end -- 212
				end -- 218
			end -- 201
		end -- 218
	end -- 218
	return { -- 200
		success = false -- 200
	} -- 218
end) -- 200
local _anon_func_0 = function(doc) -- 269
	local _accum_0 = { } -- 269
	local _len_0 = 1 -- 269
	local _list_0 = doc.params -- 269
	for _index_0 = 1, #_list_0 do -- 269
		local param = _list_0[_index_0] -- 269
		_accum_0[_len_0] = param.name -- 269
		_len_0 = _len_0 + 1 -- 269
	end -- 269
	return _accum_0 -- 269
end -- 269
local getParamDocs -- 220
getParamDocs = function(signatures) -- 220
	do -- 221
		local codes = Content:loadAsync(signatures[1].file) -- 221
		if codes then -- 221
			local comments = { } -- 222
			local params = { } -- 223
			local line = 0 -- 224
			local docs = { } -- 225
			local returnType = nil -- 226
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 227
				line = line + 1 -- 228
				local needBreak = true -- 229
				for i, _des_0 in ipairs(signatures) do -- 230
					local row = _des_0.row -- 230
					if line >= row and not (docs[i] ~= nil) then -- 231
						if #comments > 0 or #params > 0 or returnType then -- 232
							docs[i] = { -- 234
								doc = table.concat(comments, "  \n"), -- 234
								returnType = returnType -- 235
							} -- 233
							if #params > 0 then -- 237
								docs[i].params = params -- 237
							end -- 237
						else -- 239
							docs[i] = false -- 239
						end -- 232
					end -- 231
					if not docs[i] then -- 240
						needBreak = false -- 240
					end -- 240
				end -- 240
				if needBreak then -- 241
					break -- 241
				end -- 241
				local result = lineCode:match("%s*%-%- (.+)") -- 242
				if result then -- 242
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 243
					if not name then -- 244
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 245
					end -- 244
					if name then -- 246
						local pname = name -- 247
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 248
							pname = pname .. "?" -- 248
						end -- 248
						params[#params + 1] = { -- 250
							name = tostring(pname) .. ": " .. tostring(typ), -- 250
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 251
						} -- 249
					else -- 254
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 254
						if typ then -- 254
							if returnType then -- 255
								returnType = returnType .. ", " .. typ -- 256
							else -- 258
								returnType = typ -- 258
							end -- 255
							result = result:gsub("@return", "**return:**") -- 259
						end -- 254
						comments[#comments + 1] = result -- 260
					end -- 246
				elseif #comments > 0 then -- 261
					comments = { } -- 262
					params = { } -- 263
					returnType = nil -- 264
				end -- 242
			end -- 264
			local results = { } -- 265
			for _index_0 = 1, #docs do -- 266
				local doc = docs[_index_0] -- 266
				if not doc then -- 267
					goto _continue_0 -- 267
				end -- 267
				if doc.params then -- 268
					doc.desc = "function(" .. tostring(table.concat(_anon_func_0(doc), ', ')) .. ")" -- 269
				else -- 271
					doc.desc = "function()" -- 271
				end -- 268
				if doc.returnType then -- 272
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 273
					doc.returnType = nil -- 274
				end -- 272
				results[#results + 1] = doc -- 275
				::_continue_0:: -- 267
			end -- 275
			if #results > 0 then -- 276
				return results -- 276
			else -- 276
				return nil -- 276
			end -- 276
		end -- 221
	end -- 221
	return nil -- 276
end -- 220
HttpServer:postSchedule("/signature", function(req) -- 278
	do -- 279
		local _type_0 = type(req) -- 279
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 279
		if _tab_0 then -- 279
			local lang -- 279
			do -- 279
				local _obj_0 = req.body -- 279
				local _type_1 = type(_obj_0) -- 279
				if "table" == _type_1 or "userdata" == _type_1 then -- 279
					lang = _obj_0.lang -- 279
				end -- 296
			end -- 296
			local file -- 279
			do -- 279
				local _obj_0 = req.body -- 279
				local _type_1 = type(_obj_0) -- 279
				if "table" == _type_1 or "userdata" == _type_1 then -- 279
					file = _obj_0.file -- 279
				end -- 296
			end -- 296
			local content -- 279
			do -- 279
				local _obj_0 = req.body -- 279
				local _type_1 = type(_obj_0) -- 279
				if "table" == _type_1 or "userdata" == _type_1 then -- 279
					content = _obj_0.content -- 279
				end -- 296
			end -- 296
			local line -- 279
			do -- 279
				local _obj_0 = req.body -- 279
				local _type_1 = type(_obj_0) -- 279
				if "table" == _type_1 or "userdata" == _type_1 then -- 279
					line = _obj_0.line -- 279
				end -- 296
			end -- 296
			local row -- 279
			do -- 279
				local _obj_0 = req.body -- 279
				local _type_1 = type(_obj_0) -- 279
				if "table" == _type_1 or "userdata" == _type_1 then -- 279
					row = _obj_0.row -- 279
				end -- 296
			end -- 296
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 279
				local searchPath = getSearchPath(file) -- 280
				if "tl" == lang or "lua" == lang then -- 281
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 282
					if signatures then -- 282
						signatures = getParamDocs(signatures) -- 283
						if signatures then -- 283
							return { -- 284
								success = true, -- 284
								signatures = signatures -- 284
							} -- 284
						end -- 283
					end -- 282
				elseif "yue" == lang then -- 285
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file) -- 286
					if not luaCodes then -- 287
						return { -- 287
							success = false -- 287
						} -- 287
					end -- 287
					do -- 288
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 288
						if chainOp then -- 288
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 289
							targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 290
						end -- 288
					end -- 288
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 291
					if signatures then -- 291
						signatures = getParamDocs(signatures) -- 292
						if signatures then -- 292
							return { -- 293
								success = true, -- 293
								signatures = signatures -- 293
							} -- 293
						end -- 292
					else -- 294
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 294
						if signatures then -- 294
							signatures = getParamDocs(signatures) -- 295
							if signatures then -- 295
								return { -- 296
									success = true, -- 296
									signatures = signatures -- 296
								} -- 296
							end -- 295
						end -- 294
					end -- 291
				end -- 296
			end -- 279
		end -- 296
	end -- 296
	return { -- 278
		success = false -- 278
	} -- 296
end) -- 278
local luaKeywords = { -- 299
	'and', -- 299
	'break', -- 300
	'do', -- 301
	'else', -- 302
	'elseif', -- 303
	'end', -- 304
	'false', -- 305
	'for', -- 306
	'function', -- 307
	'goto', -- 308
	'if', -- 309
	'in', -- 310
	'local', -- 311
	'nil', -- 312
	'not', -- 313
	'or', -- 314
	'repeat', -- 315
	'return', -- 316
	'then', -- 317
	'true', -- 318
	'until', -- 319
	'while' -- 320
} -- 298
local tealKeywords = { -- 324
	'record', -- 324
	'as', -- 325
	'is', -- 326
	'type', -- 327
	'embed', -- 328
	'enum', -- 329
	'global', -- 330
	'any', -- 331
	'boolean', -- 332
	'integer', -- 333
	'number', -- 334
	'string', -- 335
	'thread' -- 336
} -- 323
local yueKeywords = { -- 340
	"and", -- 340
	"break", -- 341
	"do", -- 342
	"else", -- 343
	"elseif", -- 344
	"false", -- 345
	"for", -- 346
	"goto", -- 347
	"if", -- 348
	"in", -- 349
	"local", -- 350
	"nil", -- 351
	"not", -- 352
	"or", -- 353
	"repeat", -- 354
	"return", -- 355
	"then", -- 356
	"true", -- 357
	"until", -- 358
	"while", -- 359
	"as", -- 360
	"class", -- 361
	"continue", -- 362
	"export", -- 363
	"extends", -- 364
	"from", -- 365
	"global", -- 366
	"import", -- 367
	"macro", -- 368
	"switch", -- 369
	"try", -- 370
	"unless", -- 371
	"using", -- 372
	"when", -- 373
	"with" -- 374
} -- 339
local _anon_func_1 = function(Path, f) -- 410
	local _val_0 = Path:getExt(f) -- 410
	return "ttf" == _val_0 or "otf" == _val_0 -- 410
end -- 410
local _anon_func_2 = function(suggestions) -- 436
	local _tbl_0 = { } -- 436
	for _index_0 = 1, #suggestions do -- 436
		local item = suggestions[_index_0] -- 436
		_tbl_0[item[1] .. item[2]] = item -- 436
	end -- 436
	return _tbl_0 -- 436
end -- 436
HttpServer:postSchedule("/complete", function(req) -- 377
	do -- 378
		local _type_0 = type(req) -- 378
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 378
		if _tab_0 then -- 378
			local lang -- 378
			do -- 378
				local _obj_0 = req.body -- 378
				local _type_1 = type(_obj_0) -- 378
				if "table" == _type_1 or "userdata" == _type_1 then -- 378
					lang = _obj_0.lang -- 378
				end -- 485
			end -- 485
			local file -- 378
			do -- 378
				local _obj_0 = req.body -- 378
				local _type_1 = type(_obj_0) -- 378
				if "table" == _type_1 or "userdata" == _type_1 then -- 378
					file = _obj_0.file -- 378
				end -- 485
			end -- 485
			local content -- 378
			do -- 378
				local _obj_0 = req.body -- 378
				local _type_1 = type(_obj_0) -- 378
				if "table" == _type_1 or "userdata" == _type_1 then -- 378
					content = _obj_0.content -- 378
				end -- 485
			end -- 485
			local line -- 378
			do -- 378
				local _obj_0 = req.body -- 378
				local _type_1 = type(_obj_0) -- 378
				if "table" == _type_1 or "userdata" == _type_1 then -- 378
					line = _obj_0.line -- 378
				end -- 485
			end -- 485
			local row -- 378
			do -- 378
				local _obj_0 = req.body -- 378
				local _type_1 = type(_obj_0) -- 378
				if "table" == _type_1 or "userdata" == _type_1 then -- 378
					row = _obj_0.row -- 378
				end -- 485
			end -- 485
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 378
				local searchPath = getSearchPath(file) -- 379
				repeat -- 380
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 381
					if lang == "yue" then -- 382
						if not item then -- 383
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 383
						end -- 383
						if not item then -- 384
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 384
						end -- 384
					end -- 382
					local searchType = nil -- 385
					if not item then -- 386
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 387
						if lang == "yue" then -- 388
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 389
						end -- 388
						if (item ~= nil) then -- 390
							searchType = "Image" -- 390
						end -- 390
					end -- 386
					if not item then -- 391
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 392
						if lang == "yue" then -- 393
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 394
						end -- 393
						if (item ~= nil) then -- 395
							searchType = "Font" -- 395
						end -- 395
					end -- 391
					if not item then -- 396
						break -- 396
					end -- 396
					local searchPaths = Content.searchPaths -- 397
					local _list_0 = getSearchFolders(file) -- 398
					for _index_0 = 1, #_list_0 do -- 398
						local folder = _list_0[_index_0] -- 398
						searchPaths[#searchPaths + 1] = folder -- 399
					end -- 399
					if searchType then -- 400
						searchPaths[#searchPaths + 1] = Content.assetPath -- 400
					end -- 400
					local tokens -- 401
					do -- 401
						local _accum_0 = { } -- 401
						local _len_0 = 1 -- 401
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 401
							_accum_0[_len_0] = mod -- 401
							_len_0 = _len_0 + 1 -- 401
						end -- 401
						tokens = _accum_0 -- 401
					end -- 401
					local suggestions = { } -- 402
					for _index_0 = 1, #searchPaths do -- 403
						local path = searchPaths[_index_0] -- 403
						local sPath = Path(path, table.unpack(tokens)) -- 404
						if not Content:exist(sPath) then -- 405
							goto _continue_0 -- 405
						end -- 405
						if searchType == "Font" then -- 406
							local fontPath = Path(sPath, "Font") -- 407
							if Content:exist(fontPath) then -- 408
								local _list_1 = Content:getFiles(fontPath) -- 409
								for _index_1 = 1, #_list_1 do -- 409
									local f = _list_1[_index_1] -- 409
									if _anon_func_1(Path, f) then -- 410
										if "." == f:sub(1, 1) then -- 411
											goto _continue_1 -- 411
										end -- 411
										suggestions[#suggestions + 1] = { -- 412
											Path:getName(f), -- 412
											"font", -- 412
											"field" -- 412
										} -- 412
									end -- 410
									::_continue_1:: -- 410
								end -- 412
							end -- 408
						end -- 406
						local _list_1 = Content:getFiles(sPath) -- 413
						for _index_1 = 1, #_list_1 do -- 413
							local f = _list_1[_index_1] -- 413
							if "Image" == searchType then -- 414
								do -- 415
									local _exp_0 = Path:getExt(f) -- 415
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 415
										if "." == f:sub(1, 1) then -- 416
											goto _continue_2 -- 416
										end -- 416
										suggestions[#suggestions + 1] = { -- 417
											f, -- 417
											"image", -- 417
											"field" -- 417
										} -- 417
									end -- 417
								end -- 417
								goto _continue_2 -- 418
							elseif "Font" == searchType then -- 419
								do -- 420
									local _exp_0 = Path:getExt(f) -- 420
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 420
										if "." == f:sub(1, 1) then -- 421
											goto _continue_2 -- 421
										end -- 421
										suggestions[#suggestions + 1] = { -- 422
											f, -- 422
											"font", -- 422
											"field" -- 422
										} -- 422
									end -- 422
								end -- 422
								goto _continue_2 -- 423
							end -- 423
							local _exp_0 = Path:getExt(f) -- 424
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 424
								local name = Path:getName(f) -- 425
								if "d" == Path:getExt(name) then -- 426
									goto _continue_2 -- 426
								end -- 426
								if "." == name:sub(1, 1) then -- 427
									goto _continue_2 -- 427
								end -- 427
								suggestions[#suggestions + 1] = { -- 428
									name, -- 428
									"module", -- 428
									"field" -- 428
								} -- 428
							end -- 428
							::_continue_2:: -- 414
						end -- 428
						local _list_2 = Content:getDirs(sPath) -- 429
						for _index_1 = 1, #_list_2 do -- 429
							local dir = _list_2[_index_1] -- 429
							if "." == dir:sub(1, 1) then -- 430
								goto _continue_3 -- 430
							end -- 430
							suggestions[#suggestions + 1] = { -- 431
								dir, -- 431
								"folder", -- 431
								"variable" -- 431
							} -- 431
							::_continue_3:: -- 430
						end -- 431
						::_continue_0:: -- 404
					end -- 431
					if item == "" and not searchType then -- 432
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 433
						for _index_0 = 1, #_list_1 do -- 433
							local _des_0 = _list_1[_index_0] -- 433
							local name = _des_0[1] -- 433
							suggestions[#suggestions + 1] = { -- 434
								name, -- 434
								"dora module", -- 434
								"function" -- 434
							} -- 434
						end -- 434
					end -- 432
					if #suggestions > 0 then -- 435
						do -- 436
							local _accum_0 = { } -- 436
							local _len_0 = 1 -- 436
							for _, v in pairs(_anon_func_2(suggestions)) do -- 436
								_accum_0[_len_0] = v -- 436
								_len_0 = _len_0 + 1 -- 436
							end -- 436
							suggestions = _accum_0 -- 436
						end -- 436
						return { -- 437
							success = true, -- 437
							suggestions = suggestions -- 437
						} -- 437
					else -- 439
						return { -- 439
							success = false -- 439
						} -- 439
					end -- 435
				until true -- 440
				if "tl" == lang or "lua" == lang then -- 441
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 442
					if not line:match("[%.:][%w_]+[%.:]?$") and not line:match("[%w_]+[%.:]$") then -- 443
						local checkSet -- 444
						do -- 444
							local _tbl_0 = { } -- 444
							for _index_0 = 1, #suggestions do -- 444
								local _des_0 = suggestions[_index_0] -- 444
								local name = _des_0[1] -- 444
								_tbl_0[name] = true -- 444
							end -- 444
							checkSet = _tbl_0 -- 444
						end -- 444
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 445
						for _index_0 = 1, #_list_0 do -- 445
							local item = _list_0[_index_0] -- 445
							if not checkSet[item[1]] then -- 446
								suggestions[#suggestions + 1] = item -- 446
							end -- 446
						end -- 446
						for _index_0 = 1, #luaKeywords do -- 447
							local word = luaKeywords[_index_0] -- 447
							suggestions[#suggestions + 1] = { -- 448
								word, -- 448
								"keyword", -- 448
								"keyword" -- 448
							} -- 448
						end -- 448
						if lang == "tl" then -- 449
							for _index_0 = 1, #tealKeywords do -- 450
								local word = tealKeywords[_index_0] -- 450
								suggestions[#suggestions + 1] = { -- 451
									word, -- 451
									"keyword", -- 451
									"keyword" -- 451
								} -- 451
							end -- 451
						end -- 449
					end -- 443
					if #suggestions > 0 then -- 452
						return { -- 453
							success = true, -- 453
							suggestions = suggestions -- 453
						} -- 453
					end -- 452
				elseif "yue" == lang then -- 454
					local suggestions = { } -- 455
					local gotGlobals = false -- 456
					do -- 457
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file) -- 457
						if luaCodes then -- 457
							gotGlobals = true -- 458
							do -- 459
								local chainOp = line:match("[^%w_]([%.\\])$") -- 459
								if chainOp then -- 459
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 460
									if not withVar then -- 461
										return { -- 461
											success = false -- 461
										} -- 461
									end -- 461
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 462
								elseif line:match("^([%.\\])$") then -- 463
									return { -- 464
										success = false -- 464
									} -- 464
								end -- 459
							end -- 459
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 465
							for _index_0 = 1, #_list_0 do -- 465
								local item = _list_0[_index_0] -- 465
								suggestions[#suggestions + 1] = item -- 465
							end -- 465
							if #suggestions == 0 then -- 466
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 467
								for _index_0 = 1, #_list_1 do -- 467
									local item = _list_1[_index_0] -- 467
									suggestions[#suggestions + 1] = item -- 467
								end -- 467
							end -- 466
						end -- 457
					end -- 457
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 468
						local checkSet -- 469
						do -- 469
							local _tbl_0 = { } -- 469
							for _index_0 = 1, #suggestions do -- 469
								local _des_0 = suggestions[_index_0] -- 469
								local name = _des_0[1] -- 469
								_tbl_0[name] = true -- 469
							end -- 469
							checkSet = _tbl_0 -- 469
						end -- 469
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 470
						for _index_0 = 1, #_list_0 do -- 470
							local item = _list_0[_index_0] -- 470
							if not checkSet[item[1]] then -- 471
								suggestions[#suggestions + 1] = item -- 471
							end -- 471
						end -- 471
						if not gotGlobals then -- 472
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 473
							for _index_0 = 1, #_list_1 do -- 473
								local item = _list_1[_index_0] -- 473
								if not checkSet[item[1]] then -- 474
									suggestions[#suggestions + 1] = item -- 474
								end -- 474
							end -- 474
						end -- 472
						for _index_0 = 1, #yueKeywords do -- 475
							local word = yueKeywords[_index_0] -- 475
							if not checkSet[word] then -- 476
								suggestions[#suggestions + 1] = { -- 477
									word, -- 477
									"keyword", -- 477
									"keyword" -- 477
								} -- 477
							end -- 476
						end -- 477
					end -- 468
					if #suggestions > 0 then -- 478
						return { -- 479
							success = true, -- 479
							suggestions = suggestions -- 479
						} -- 479
					end -- 478
				elseif "xml" == lang then -- 480
					local items = xml.complete(content) -- 481
					if #items > 0 then -- 482
						local suggestions -- 483
						do -- 483
							local _accum_0 = { } -- 483
							local _len_0 = 1 -- 483
							for _index_0 = 1, #items do -- 483
								local _des_0 = items[_index_0] -- 483
								local label, insertText = _des_0[1], _des_0[2] -- 483
								_accum_0[_len_0] = { -- 484
									label, -- 484
									insertText, -- 484
									"field" -- 484
								} -- 484
								_len_0 = _len_0 + 1 -- 484
							end -- 484
							suggestions = _accum_0 -- 483
						end -- 484
						return { -- 485
							success = true, -- 485
							suggestions = suggestions -- 485
						} -- 485
					end -- 482
				end -- 485
			end -- 378
		end -- 485
	end -- 485
	return { -- 377
		success = false -- 377
	} -- 485
end) -- 377
HttpServer:upload("/upload", function(req, filename) -- 489
	do -- 490
		local _type_0 = type(req) -- 490
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 490
		if _tab_0 then -- 490
			local path -- 490
			do -- 490
				local _obj_0 = req.params -- 490
				local _type_1 = type(_obj_0) -- 490
				if "table" == _type_1 or "userdata" == _type_1 then -- 490
					path = _obj_0.path -- 490
				end -- 496
			end -- 496
			if path ~= nil then -- 490
				local uploadPath = Path(Content.writablePath, ".upload") -- 491
				if not Content:exist(uploadPath) then -- 492
					Content:mkdir(uploadPath) -- 493
				end -- 492
				local targetPath = Path(uploadPath, filename) -- 494
				Content:mkdir(Path:getPath(targetPath)) -- 495
				return targetPath -- 496
			end -- 490
		end -- 496
	end -- 496
	return nil -- 496
end, function(req, file) -- 497
	do -- 498
		local _type_0 = type(req) -- 498
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 498
		if _tab_0 then -- 498
			local path -- 498
			do -- 498
				local _obj_0 = req.params -- 498
				local _type_1 = type(_obj_0) -- 498
				if "table" == _type_1 or "userdata" == _type_1 then -- 498
					path = _obj_0.path -- 498
				end -- 505
			end -- 505
			if path ~= nil then -- 498
				path = Path(Content.writablePath, path) -- 499
				if Content:exist(path) then -- 500
					local uploadPath = Path(Content.writablePath, ".upload") -- 501
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 502
					Content:mkdir(Path:getPath(targetPath)) -- 503
					if Content:move(file, targetPath) then -- 504
						return true -- 505
					end -- 504
				end -- 500
			end -- 498
		end -- 505
	end -- 505
	return false -- 505
end) -- 487
HttpServer:post("/list", function(req) -- 508
	do -- 509
		local _type_0 = type(req) -- 509
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 509
		if _tab_0 then -- 509
			local path -- 509
			do -- 509
				local _obj_0 = req.body -- 509
				local _type_1 = type(_obj_0) -- 509
				if "table" == _type_1 or "userdata" == _type_1 then -- 509
					path = _obj_0.path -- 509
				end -- 531
			end -- 531
			if path ~= nil then -- 509
				if Content:exist(path) then -- 510
					local files = { } -- 511
					local visitAssets -- 512
					visitAssets = function(path, folder) -- 512
						local dirs = Content:getDirs(path) -- 513
						for _index_0 = 1, #dirs do -- 514
							local dir = dirs[_index_0] -- 514
							if dir:match("^%.") then -- 515
								goto _continue_0 -- 515
							end -- 515
							local current -- 516
							if folder == "" then -- 516
								current = dir -- 517
							else -- 519
								current = Path(folder, dir) -- 519
							end -- 516
							files[#files + 1] = current -- 520
							visitAssets(Path(path, dir), current) -- 521
							::_continue_0:: -- 515
						end -- 521
						local fs = Content:getFiles(path) -- 522
						for _index_0 = 1, #fs do -- 523
							local f = fs[_index_0] -- 523
							if f:match("^%.") then -- 524
								goto _continue_1 -- 524
							end -- 524
							if folder == "" then -- 525
								files[#files + 1] = f -- 526
							else -- 528
								files[#files + 1] = Path(folder, f) -- 528
							end -- 525
							::_continue_1:: -- 524
						end -- 528
					end -- 512
					visitAssets(path, "") -- 529
					if #files == 0 then -- 530
						files = nil -- 530
					end -- 530
					return { -- 531
						success = true, -- 531
						files = files -- 531
					} -- 531
				end -- 510
			end -- 509
		end -- 531
	end -- 531
	return { -- 508
		success = false -- 508
	} -- 531
end) -- 508
HttpServer:post("/info", function() -- 533
	local Entry = require("Script.Dev.Entry") -- 534
	local engineDev = Entry.getEngineDev() -- 535
	return { -- 537
		platform = App.platform, -- 537
		locale = App.locale, -- 538
		version = App.version, -- 539
		engineDev = engineDev -- 540
	} -- 540
end) -- 533
HttpServer:post("/new", function(req) -- 542
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
				end -- 555
			end -- 555
			local content -- 543
			do -- 543
				local _obj_0 = req.body -- 543
				local _type_1 = type(_obj_0) -- 543
				if "table" == _type_1 or "userdata" == _type_1 then -- 543
					content = _obj_0.content -- 543
				end -- 555
			end -- 555
			if path ~= nil and content ~= nil then -- 543
				if not Content:exist(path) then -- 544
					local parent = Path:getPath(path) -- 545
					local files = Content:getFiles(parent) -- 546
					local name = Path:getName(path):lower() -- 547
					for _index_0 = 1, #files do -- 548
						local file = files[_index_0] -- 548
						if name == Path:getName(file):lower() then -- 549
							return { -- 550
								success = false -- 550
							} -- 550
						end -- 549
					end -- 550
					if "" == Path:getExt(path) then -- 551
						if Content:mkdir(path) then -- 552
							return { -- 553
								success = true -- 553
							} -- 553
						end -- 552
					elseif Content:save(path, content) then -- 554
						return { -- 555
							success = true -- 555
						} -- 555
					end -- 551
				end -- 544
			end -- 543
		end -- 555
	end -- 555
	return { -- 542
		success = false -- 542
	} -- 555
end) -- 542
HttpServer:post("/delete", function(req) -- 557
	do -- 558
		local _type_0 = type(req) -- 558
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 558
		if _tab_0 then -- 558
			local path -- 558
			do -- 558
				local _obj_0 = req.body -- 558
				local _type_1 = type(_obj_0) -- 558
				if "table" == _type_1 or "userdata" == _type_1 then -- 558
					path = _obj_0.path -- 558
				end -- 571
			end -- 571
			if path ~= nil then -- 558
				if Content:exist(path) then -- 559
					local parent = Path:getPath(path) -- 560
					local files = Content:getFiles(parent) -- 561
					local name = Path:getName(path):lower() -- 562
					local ext = Path:getExt(path) -- 563
					for _index_0 = 1, #files do -- 564
						local file = files[_index_0] -- 564
						if name == Path:getName(file):lower() then -- 565
							local _exp_0 = Path:getExt(file) -- 566
							if "tl" == _exp_0 then -- 566
								if ("vs" == ext) then -- 566
									Content:remove(Path(parent, file)) -- 567
								end -- 566
							elseif "lua" == _exp_0 then -- 568
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 568
									Content:remove(Path(parent, file)) -- 569
								end -- 568
							end -- 569
						end -- 565
					end -- 569
					if Content:remove(path) then -- 570
						return { -- 571
							success = true -- 571
						} -- 571
					end -- 570
				end -- 559
			end -- 558
		end -- 571
	end -- 571
	return { -- 557
		success = false -- 557
	} -- 571
end) -- 557
HttpServer:post("/rename", function(req) -- 573
	do -- 574
		local _type_0 = type(req) -- 574
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 574
		if _tab_0 then -- 574
			local old -- 574
			do -- 574
				local _obj_0 = req.body -- 574
				local _type_1 = type(_obj_0) -- 574
				if "table" == _type_1 or "userdata" == _type_1 then -- 574
					old = _obj_0.old -- 574
				end -- 596
			end -- 596
			local new -- 574
			do -- 574
				local _obj_0 = req.body -- 574
				local _type_1 = type(_obj_0) -- 574
				if "table" == _type_1 or "userdata" == _type_1 then -- 574
					new = _obj_0.new -- 574
				end -- 596
			end -- 596
			if old ~= nil and new ~= nil then -- 574
				if Content:exist(old) and not Content:exist(new) then -- 575
					local parent = Path:getPath(new) -- 576
					local files = Content:getFiles(parent) -- 577
					local name = Path:getName(new):lower() -- 578
					for _index_0 = 1, #files do -- 579
						local file = files[_index_0] -- 579
						if name == Path:getName(file):lower() then -- 580
							return { -- 581
								success = false -- 581
							} -- 581
						end -- 580
					end -- 581
					if Content:move(old, new) then -- 582
						local newParent = Path:getPath(new) -- 583
						parent = Path:getPath(old) -- 584
						files = Content:getFiles(parent) -- 585
						local newName = Path:getName(new) -- 586
						local oldName = Path:getName(old) -- 587
						name = oldName:lower() -- 588
						local ext = Path:getExt(old) -- 589
						for _index_0 = 1, #files do -- 590
							local file = files[_index_0] -- 590
							if name == Path:getName(file):lower() then -- 591
								local _exp_0 = Path:getExt(file) -- 592
								if "tl" == _exp_0 then -- 592
									if ("vs" == ext) then -- 592
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 593
									end -- 592
								elseif "lua" == _exp_0 then -- 594
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 594
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 595
									end -- 594
								end -- 595
							end -- 591
						end -- 595
						return { -- 596
							success = true -- 596
						} -- 596
					end -- 582
				end -- 575
			end -- 574
		end -- 596
	end -- 596
	return { -- 573
		success = false -- 573
	} -- 596
end) -- 573
HttpServer:postSchedule("/read", function(req) -- 598
	do -- 599
		local _type_0 = type(req) -- 599
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 599
		if _tab_0 then -- 599
			local path -- 599
			do -- 599
				local _obj_0 = req.body -- 599
				local _type_1 = type(_obj_0) -- 599
				if "table" == _type_1 or "userdata" == _type_1 then -- 599
					path = _obj_0.path -- 599
				end -- 602
			end -- 602
			if path ~= nil then -- 599
				if Content:exist(path) then -- 600
					local content = Content:loadAsync(path) -- 601
					if content then -- 601
						return { -- 602
							content = content, -- 602
							success = true -- 602
						} -- 602
					end -- 601
				end -- 600
			end -- 599
		end -- 602
	end -- 602
	return { -- 598
		success = false -- 598
	} -- 602
end) -- 598
local compileFileAsync -- 604
compileFileAsync = function(inputFile, sourceCodes) -- 604
	local file = inputFile -- 605
	local searchPath -- 606
	do -- 606
		local dir = getProjectDirFromFile(inputFile) -- 606
		if dir then -- 606
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 607
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 608
		else -- 610
			file = Path:getRelative(inputFile, Path(Content.writablePath)) -- 610
			if file:sub(1, 2) == ".." then -- 611
				file = Path:getRelative(inputFile, Path(Content.assetPath)) -- 612
			end -- 611
			searchPath = "" -- 613
		end -- 606
	end -- 606
	local outputFile = Path:replaceExt(inputFile, "lua") -- 614
	local yueext = yue.options.extension -- 615
	local resultCodes = nil -- 616
	do -- 617
		local _exp_0 = Path:getExt(inputFile) -- 617
		if yueext == _exp_0 then -- 617
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 618
				if not codes then -- 619
					return -- 619
				end -- 619
				local success, result = LintYueGlobals(codes, globals) -- 620
				if not success then -- 621
					return -- 621
				end -- 621
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 622
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 623
				codes = codes:gsub("^\n*", "") -- 624
				if not (result == "") then -- 625
					result = result .. "\n" -- 625
				end -- 625
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 626
				return resultCodes -- 627
			end, function(success) -- 618
				if not success then -- 628
					Content:remove(outputFile) -- 629
					resultCodes = false -- 630
				end -- 628
			end) -- 618
		elseif "tl" == _exp_0 then -- 631
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 632
			if codes then -- 632
				resultCodes = codes -- 633
				Content:saveAsync(outputFile, codes) -- 634
			else -- 636
				Content:remove(outputFile) -- 636
				resultCodes = false -- 637
			end -- 632
		elseif "xml" == _exp_0 then -- 638
			local codes = xml.tolua(sourceCodes) -- 639
			if codes then -- 639
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 640
				Content:saveAsync(outputFile, resultCodes) -- 641
			else -- 643
				Content:remove(outputFile) -- 643
				resultCodes = false -- 644
			end -- 639
		end -- 644
	end -- 644
	wait(function() -- 645
		return resultCodes ~= nil -- 645
	end) -- 645
	if resultCodes then -- 646
		return resultCodes -- 646
	end -- 646
	return nil -- 646
end -- 604
HttpServer:postSchedule("/write", function(req) -- 648
	do -- 649
		local _type_0 = type(req) -- 649
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 649
		if _tab_0 then -- 649
			local path -- 649
			do -- 649
				local _obj_0 = req.body -- 649
				local _type_1 = type(_obj_0) -- 649
				if "table" == _type_1 or "userdata" == _type_1 then -- 649
					path = _obj_0.path -- 649
				end -- 655
			end -- 655
			local content -- 649
			do -- 649
				local _obj_0 = req.body -- 649
				local _type_1 = type(_obj_0) -- 649
				if "table" == _type_1 or "userdata" == _type_1 then -- 649
					content = _obj_0.content -- 649
				end -- 655
			end -- 655
			if path ~= nil and content ~= nil then -- 649
				if Content:saveAsync(path, content) then -- 650
					do -- 651
						local _exp_0 = Path:getExt(path) -- 651
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 651
							if '' == Path:getExt(Path:getName(path)) then -- 652
								local resultCodes = compileFileAsync(path, content) -- 653
								return { -- 654
									success = true, -- 654
									resultCodes = resultCodes -- 654
								} -- 654
							end -- 652
						end -- 654
					end -- 654
					return { -- 655
						success = true -- 655
					} -- 655
				end -- 650
			end -- 649
		end -- 655
	end -- 655
	return { -- 648
		success = false -- 648
	} -- 655
end) -- 648
local extentionLevels = { -- 658
	vs = 2, -- 658
	ts = 1, -- 659
	tsx = 1, -- 660
	tl = 1, -- 661
	yue = 1, -- 662
	xml = 1, -- 663
	lua = 0 -- 664
} -- 657
local _anon_func_4 = function(Content, Path, visitAssets, zh) -- 731
	local _with_0 = visitAssets(Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")) -- 730
	_with_0.title = zh and "说明文档" or "Readme" -- 731
	return _with_0 -- 730
end -- 730
local _anon_func_5 = function(Content, Path, visitAssets, zh) -- 733
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")) -- 732
	_with_0.title = zh and "接口文档" or "API Doc" -- 733
	return _with_0 -- 732
end -- 732
local _anon_func_6 = function(Content, Path, visitAssets, zh) -- 735
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Example")) -- 734
	_with_0.title = zh and "代码示例" or "Example" -- 735
	return _with_0 -- 734
end -- 734
local _anon_func_7 = function(Content, Path, visitAssets, zh) -- 737
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Test")) -- 736
	_with_0.title = zh and "功能测试" or "Test" -- 737
	return _with_0 -- 736
end -- 736
local _anon_func_8 = function(Content, Path, engineDev, visitAssets, zh) -- 749
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib")) -- 741
	if engineDev then -- 742
		local _list_0 = _with_0.children -- 743
		for _index_0 = 1, #_list_0 do -- 743
			local child = _list_0[_index_0] -- 743
			if not (child.title == "Dora") then -- 744
				goto _continue_0 -- 744
			end -- 744
			local title = zh and "zh-Hans" or "en" -- 745
			do -- 746
				local _accum_0 = { } -- 746
				local _len_0 = 1 -- 746
				local _list_1 = child.children -- 746
				for _index_1 = 1, #_list_1 do -- 746
					local c = _list_1[_index_1] -- 746
					if c.title ~= title then -- 746
						_accum_0[_len_0] = c -- 746
						_len_0 = _len_0 + 1 -- 746
					end -- 746
				end -- 746
				child.children = _accum_0 -- 746
			end -- 746
			break -- 747
			::_continue_0:: -- 744
		end -- 747
	else -- 749
		local _accum_0 = { } -- 749
		local _len_0 = 1 -- 749
		local _list_0 = _with_0.children -- 749
		for _index_0 = 1, #_list_0 do -- 749
			local child = _list_0[_index_0] -- 749
			if child.title ~= "Dora" then -- 749
				_accum_0[_len_0] = child -- 749
				_len_0 = _len_0 + 1 -- 749
			end -- 749
		end -- 749
		_with_0.children = _accum_0 -- 749
	end -- 742
	return _with_0 -- 741
end -- 741
local _anon_func_9 = function(Content, Path, engineDev, visitAssets) -- 750
	if engineDev then -- 750
		return visitAssets(Path(Content.assetPath, "Script", "Dev")) -- 751
	end -- 750
end -- 750
local _anon_func_3 = function(Content, Path, engineDev, pairs, visitAssets, zh) -- 753
	local _tab_0 = { -- 725
		{ -- 726
			key = Path(Content.assetPath), -- 726
			dir = true, -- 727
			title = zh and "内置资源" or "Built-in", -- 728
			children = { -- 730
				_anon_func_4(Content, Path, visitAssets, zh), -- 730
				_anon_func_5(Content, Path, visitAssets, zh), -- 732
				_anon_func_6(Content, Path, visitAssets, zh), -- 734
				_anon_func_7(Content, Path, visitAssets, zh), -- 736
				visitAssets(Path(Content.assetPath, "Image")), -- 738
				visitAssets(Path(Content.assetPath, "Spine")), -- 739
				visitAssets(Path(Content.assetPath, "Font")), -- 740
				_anon_func_8(Content, Path, engineDev, visitAssets, zh), -- 741
				_anon_func_9(Content, Path, engineDev, visitAssets) -- 750
			} -- 729
		} -- 725
	} -- 754
	local _obj_0 = visitAssets(Content.writablePath, true) -- 754
	local _idx_0 = #_tab_0 + 1 -- 754
	for _index_0 = 1, #_obj_0 do -- 754
		local _value_0 = _obj_0[_index_0] -- 754
		_tab_0[_idx_0] = _value_0 -- 754
		_idx_0 = _idx_0 + 1 -- 754
	end -- 754
	return _tab_0 -- 753
end -- 725
HttpServer:post("/assets", function() -- 666
	local Entry = require("Script.Dev.Entry") -- 667
	local engineDev = Entry.getEngineDev() -- 668
	local visitAssets -- 669
	visitAssets = function(path, root) -- 669
		local children = nil -- 670
		local dirs = Content:getDirs(path) -- 671
		for _index_0 = 1, #dirs do -- 672
			local dir = dirs[_index_0] -- 672
			if root then -- 673
				if ".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir then -- 673
					goto _continue_0 -- 674
				end -- 674
			elseif dir == ".git" then -- 675
				goto _continue_0 -- 676
			end -- 673
			if not children then -- 677
				children = { } -- 677
			end -- 677
			children[#children + 1] = visitAssets(Path(path, dir)) -- 678
			::_continue_0:: -- 673
		end -- 678
		local files = Content:getFiles(path) -- 679
		local names = { } -- 680
		for _index_0 = 1, #files do -- 681
			local file = files[_index_0] -- 681
			if file:match("^%.") then -- 682
				goto _continue_1 -- 682
			end -- 682
			local name = Path:getName(file) -- 683
			local ext = names[name] -- 684
			if ext then -- 684
				local lv1 -- 685
				do -- 685
					local _exp_0 = extentionLevels[ext] -- 685
					if _exp_0 ~= nil then -- 685
						lv1 = _exp_0 -- 685
					else -- 685
						lv1 = -1 -- 685
					end -- 685
				end -- 685
				ext = Path:getExt(file) -- 686
				local lv2 -- 687
				do -- 687
					local _exp_0 = extentionLevels[ext] -- 687
					if _exp_0 ~= nil then -- 687
						lv2 = _exp_0 -- 687
					else -- 687
						lv2 = -1 -- 687
					end -- 687
				end -- 687
				if lv2 > lv1 then -- 688
					names[name] = ext -- 688
				end -- 688
			else -- 690
				ext = Path:getExt(file) -- 690
				if not extentionLevels[ext] then -- 691
					names[file] = "" -- 692
				else -- 694
					names[name] = ext -- 694
				end -- 691
			end -- 684
			::_continue_1:: -- 682
		end -- 694
		do -- 695
			local _accum_0 = { } -- 695
			local _len_0 = 1 -- 695
			for name, ext in pairs(names) do -- 695
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 695
				_len_0 = _len_0 + 1 -- 695
			end -- 695
			files = _accum_0 -- 695
		end -- 695
		for _index_0 = 1, #files do -- 696
			local file = files[_index_0] -- 696
			if not children then -- 697
				children = { } -- 697
			end -- 697
			children[#children + 1] = { -- 699
				key = Path(path, file), -- 699
				dir = false, -- 700
				title = file -- 701
			} -- 698
		end -- 702
		if children then -- 703
			table.sort(children, function(a, b) -- 704
				if a.dir == b.dir then -- 705
					return a.title < b.title -- 706
				else -- 708
					return a.dir -- 708
				end -- 705
			end) -- 704
		end -- 703
		local title = Path:getFilename(path) -- 709
		if title == "" then -- 710
			return children -- 711
		else -- 713
			return { -- 714
				key = path, -- 714
				dir = true, -- 715
				title = title, -- 716
				children = children -- 717
			} -- 718
		end -- 710
	end -- 669
	local zh = (App.locale:match("^zh") ~= nil) -- 719
	return { -- 721
		key = Content.writablePath, -- 721
		dir = true, -- 722
		title = "Assets", -- 723
		children = _anon_func_3(Content, Path, engineDev, pairs, visitAssets, zh) -- 724
	} -- 756
end) -- 666
HttpServer:postSchedule("/run", function(req) -- 758
	do -- 759
		local _type_0 = type(req) -- 759
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 759
		if _tab_0 then -- 759
			local file -- 759
			do -- 759
				local _obj_0 = req.body -- 759
				local _type_1 = type(_obj_0) -- 759
				if "table" == _type_1 or "userdata" == _type_1 then -- 759
					file = _obj_0.file -- 759
				end -- 774
			end -- 774
			local asProj -- 759
			do -- 759
				local _obj_0 = req.body -- 759
				local _type_1 = type(_obj_0) -- 759
				if "table" == _type_1 or "userdata" == _type_1 then -- 759
					asProj = _obj_0.asProj -- 759
				end -- 774
			end -- 774
			if file ~= nil and asProj ~= nil then -- 759
				if not Content:isAbsolutePath(file) then -- 760
					local devFile = Path(Content.writablePath, file) -- 761
					if Content:exist(devFile) then -- 762
						file = devFile -- 762
					end -- 762
				end -- 760
				local Entry = require("Script.Dev.Entry") -- 763
				if asProj then -- 764
					local proj = getProjectDirFromFile(file) -- 765
					if proj then -- 765
						Entry.allClear() -- 766
						local target = Path(proj, "init") -- 767
						local success, err = Entry.enterEntryAsync({ -- 768
							"Project", -- 768
							target -- 768
						}) -- 768
						target = Path:getName(Path:getPath(target)) -- 769
						return { -- 770
							success = success, -- 770
							target = target, -- 770
							err = err -- 770
						} -- 770
					end -- 765
				end -- 764
				Entry.allClear() -- 771
				file = Path:replaceExt(file, "") -- 772
				local success, err = Entry.enterEntryAsync({ -- 773
					Path:getName(file), -- 773
					file -- 773
				}) -- 773
				return { -- 774
					success = success, -- 774
					err = err -- 774
				} -- 774
			end -- 759
		end -- 774
	end -- 774
	return { -- 758
		success = false -- 758
	} -- 774
end) -- 758
HttpServer:postSchedule("/stop", function() -- 776
	local Entry = require("Script.Dev.Entry") -- 777
	return { -- 778
		success = Entry.stop() -- 778
	} -- 778
end) -- 776
HttpServer:postSchedule("/zip", function(req) -- 780
	do -- 781
		local _type_0 = type(req) -- 781
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 781
		if _tab_0 then -- 781
			local path -- 781
			do -- 781
				local _obj_0 = req.body -- 781
				local _type_1 = type(_obj_0) -- 781
				if "table" == _type_1 or "userdata" == _type_1 then -- 781
					path = _obj_0.path -- 781
				end -- 784
			end -- 784
			local zipFile -- 781
			do -- 781
				local _obj_0 = req.body -- 781
				local _type_1 = type(_obj_0) -- 781
				if "table" == _type_1 or "userdata" == _type_1 then -- 781
					zipFile = _obj_0.zipFile -- 781
				end -- 784
			end -- 784
			if path ~= nil and zipFile ~= nil then -- 781
				Content:mkdir(Path:getPath(zipFile)) -- 782
				return { -- 783
					success = Content:zipAsync(path, zipFile, function(file) -- 783
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 784
					end) -- 783
				} -- 784
			end -- 781
		end -- 784
	end -- 784
	return { -- 780
		success = false -- 780
	} -- 784
end) -- 780
HttpServer:postSchedule("/unzip", function(req) -- 786
	do -- 787
		local _type_0 = type(req) -- 787
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 787
		if _tab_0 then -- 787
			local zipFile -- 787
			do -- 787
				local _obj_0 = req.body -- 787
				local _type_1 = type(_obj_0) -- 787
				if "table" == _type_1 or "userdata" == _type_1 then -- 787
					zipFile = _obj_0.zipFile -- 787
				end -- 789
			end -- 789
			local path -- 787
			do -- 787
				local _obj_0 = req.body -- 787
				local _type_1 = type(_obj_0) -- 787
				if "table" == _type_1 or "userdata" == _type_1 then -- 787
					path = _obj_0.path -- 787
				end -- 789
			end -- 789
			if zipFile ~= nil and path ~= nil then -- 787
				return { -- 788
					success = Content:unzipAsync(zipFile, path, function(file) -- 788
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 789
					end) -- 788
				} -- 789
			end -- 787
		end -- 789
	end -- 789
	return { -- 786
		success = false -- 786
	} -- 789
end) -- 786
HttpServer:post("/editingInfo", function(req) -- 791
	local Entry = require("Script.Dev.Entry") -- 792
	local config = Entry.getConfig() -- 793
	local _type_0 = type(req) -- 794
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 794
	local _match_0 = false -- 794
	if _tab_0 then -- 794
		local editingInfo -- 794
		do -- 794
			local _obj_0 = req.body -- 794
			local _type_1 = type(_obj_0) -- 794
			if "table" == _type_1 or "userdata" == _type_1 then -- 794
				editingInfo = _obj_0.editingInfo -- 794
			end -- 796
		end -- 796
		if editingInfo ~= nil then -- 794
			_match_0 = true -- 794
			config.editingInfo = editingInfo -- 795
			return { -- 796
				success = true -- 796
			} -- 796
		end -- 794
	end -- 794
	if not _match_0 then -- 794
		if not (config.editingInfo ~= nil) then -- 798
			local json = require("json") -- 799
			local folder -- 800
			if App.locale:match('^zh') then -- 800
				folder = 'zh-Hans' -- 800
			else -- 800
				folder = 'en' -- 800
			end -- 800
			config.editingInfo = json.dump({ -- 802
				index = 0, -- 802
				files = { -- 804
					{ -- 805
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 805
						title = "welcome.md" -- 806
					} -- 804
				} -- 803
			}) -- 801
		end -- 798
		return { -- 810
			success = true, -- 810
			editingInfo = config.editingInfo -- 810
		} -- 810
	end -- 810
end) -- 791
HttpServer:post("/command", function(req) -- 812
	do -- 813
		local _type_0 = type(req) -- 813
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 813
		if _tab_0 then -- 813
			local code -- 813
			do -- 813
				local _obj_0 = req.body -- 813
				local _type_1 = type(_obj_0) -- 813
				if "table" == _type_1 or "userdata" == _type_1 then -- 813
					code = _obj_0.code -- 813
				end -- 815
			end -- 815
			if code ~= nil then -- 813
				emit("AppCommand", code) -- 814
				return { -- 815
					success = true -- 815
				} -- 815
			end -- 813
		end -- 815
	end -- 815
	return { -- 812
		success = false -- 812
	} -- 815
end) -- 812
HttpServer:post("/exist", function(req) -- 817
	do -- 818
		local _type_0 = type(req) -- 818
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 818
		if _tab_0 then -- 818
			local file -- 818
			do -- 818
				local _obj_0 = req.body -- 818
				local _type_1 = type(_obj_0) -- 818
				if "table" == _type_1 or "userdata" == _type_1 then -- 818
					file = _obj_0.file -- 818
				end -- 819
			end -- 819
			if file ~= nil then -- 818
				return { -- 819
					success = Content:exist(file) -- 819
				} -- 819
			end -- 818
		end -- 819
	end -- 819
	return { -- 817
		success = false -- 817
	} -- 819
end) -- 817
local status = { } -- 821
_module_0 = status -- 822
thread(function() -- 824
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 825
	local doraReady = Path(Content.writablePath, ".www", "dora-ready") -- 826
	if Content:exist(doraWeb) then -- 827
		local needReload -- 828
		if Content:exist(doraReady) then -- 828
			needReload = App.version ~= Content:load(doraReady) -- 829
		else -- 830
			needReload = true -- 830
		end -- 828
		if needReload then -- 831
			Content:remove(Path(Content.writablePath, ".www")) -- 832
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.writablePath, ".www")) -- 833
			Content:save(doraReady, App.version) -- 837
			print("Dora Dora is ready!") -- 838
		end -- 831
	end -- 827
	if HttpServer:start(8866) then -- 839
		local localIP = HttpServer.localIP -- 840
		if localIP == "" then -- 841
			localIP = "localhost" -- 841
		end -- 841
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 842
		return HttpServer:startWS(8868) -- 843
	else -- 845
		status.url = nil -- 845
		return print("8866 Port not available!") -- 846
	end -- 839
end) -- 824
return _module_0 -- 846
