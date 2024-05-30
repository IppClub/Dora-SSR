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
			return tostring(Path(dir, "Script", "?.lua")) .. ";" .. tostring(Path(dir, "?.lua")) -- 38
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
	"unknown variable", -- 48
	"cannot index key", -- 49
	"module not found", -- 50
	"don't know how to resolve a dynamic require", -- 51
	"ContainerItem", -- 52
	"cannot resolve a type", -- 53
	"invalid key", -- 54
	"inconsistent index type", -- 55
	"cannot use operator '#'", -- 56
	"attempting ipairs loop", -- 57
	"expects record or nominal", -- 58
	"variable is not being assigned a value", -- 59
	"<unknown type>", -- 60
	"<invalid type>", -- 61
	"using the '#' operator on this map will always return 0", -- 62
	"can't match a record to a map with non%-string keys", -- 63
	"redeclaration of variable" -- 64
} -- 46
local yueCheck -- 66
yueCheck = function(file, content) -- 66
	local searchPath = getSearchPath(file) -- 67
	local checkResult, luaCodes = yue.checkAsync(content, searchPath) -- 68
	local info = { } -- 69
	local globals = { } -- 70
	for _index_0 = 1, #checkResult do -- 71
		local _des_0 = checkResult[_index_0] -- 71
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 71
		if "error" == t then -- 72
			info[#info + 1] = { -- 73
				"syntax", -- 73
				file, -- 73
				line, -- 73
				col, -- 73
				msg -- 73
			} -- 73
		elseif "global" == t then -- 74
			globals[#globals + 1] = { -- 75
				msg, -- 75
				line, -- 75
				col -- 75
			} -- 75
		end -- 75
	end -- 75
	if luaCodes then -- 76
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 77
		if success then -- 78
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 79
			if not (lintResult == "") then -- 80
				lintResult = lintResult .. "\n" -- 80
			end -- 80
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 81
		else -- 82
			for _index_0 = 1, #lintResult do -- 82
				local _des_0 = lintResult[_index_0] -- 82
				local _name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 82
				info[#info + 1] = { -- 83
					"syntax", -- 83
					file, -- 83
					line, -- 83
					col, -- 83
					"invalid global variable" -- 83
				} -- 83
			end -- 83
		end -- 78
	end -- 76
	return luaCodes, info -- 84
end -- 66
local luaCheck -- 86
luaCheck = function(file, content) -- 86
	local res, err = load(content, "check") -- 87
	if not res then -- 88
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 89
		return { -- 90
			success = false, -- 90
			info = { -- 90
				{ -- 90
					"syntax", -- 90
					file, -- 90
					tonumber(line), -- 90
					0, -- 90
					msg -- 90
				} -- 90
			} -- 90
		} -- 90
	end -- 88
	local success, info = teal.checkAsync(content, file, true, "") -- 91
	if info then -- 92
		do -- 93
			local _accum_0 = { } -- 93
			local _len_0 = 1 -- 93
			for _index_0 = 1, #info do -- 93
				local item = info[_index_0] -- 93
				local useCheck = true -- 94
				if not item[5]:match("unused") then -- 95
					for _index_1 = 1, #disabledCheckForLua do -- 96
						local check = disabledCheckForLua[_index_1] -- 96
						if item[5]:match(check) then -- 97
							useCheck = false -- 98
						end -- 97
					end -- 98
				end -- 95
				if not useCheck then -- 99
					goto _continue_0 -- 99
				end -- 99
				do -- 100
					local _exp_0 = item[1] -- 100
					if "type" == _exp_0 then -- 101
						item[1] = "warning" -- 102
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 103
						goto _continue_0 -- 104
					end -- 104
				end -- 104
				_accum_0[_len_0] = item -- 105
				_len_0 = _len_0 + 1 -- 105
				::_continue_0:: -- 94
			end -- 105
			info = _accum_0 -- 93
		end -- 105
		if #info == 0 then -- 106
			info = nil -- 107
			success = true -- 108
		end -- 106
	end -- 92
	return { -- 109
		success = success, -- 109
		info = info -- 109
	} -- 109
end -- 86
local luaCheckWithLineInfo -- 111
luaCheckWithLineInfo = function(file, luaCodes) -- 111
	local res = luaCheck(file, luaCodes) -- 112
	local info = { } -- 113
	if not res.success then -- 114
		local current = 1 -- 115
		local lastLine = 1 -- 116
		local lineMap = { } -- 117
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 118
			local num = lineCode:match("--%s*(%d+)%s*$") -- 119
			if num then -- 120
				lastLine = tonumber(num) -- 121
			end -- 120
			lineMap[current] = lastLine -- 122
			current = current + 1 -- 123
		end -- 123
		local _list_0 = res.info -- 124
		for _index_0 = 1, #_list_0 do -- 124
			local item = _list_0[_index_0] -- 124
			item[3] = lineMap[item[3]] or 0 -- 125
			item[4] = 0 -- 126
			info[#info + 1] = item -- 127
		end -- 127
		return false, info -- 128
	end -- 114
	return true, info -- 129
end -- 111
local getCompiledYueLine -- 131
getCompiledYueLine = function(content, line, row, file) -- 131
	local luaCodes, _info = yueCheck(file, content) -- 132
	if not luaCodes then -- 133
		return nil -- 133
	end -- 133
	local current = 1 -- 134
	local lastLine = 1 -- 135
	local targetLine = nil -- 136
	local targetRow = nil -- 137
	local lineMap = { } -- 138
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 139
		local num = lineCode:match("--%s*(%d+)%s*$") -- 140
		if num then -- 141
			lastLine = tonumber(num) -- 141
		end -- 141
		lineMap[current] = lastLine -- 142
		if row == lastLine and not targetLine then -- 143
			targetRow = current -- 144
			targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 145
			if targetLine then -- 146
				break -- 146
			end -- 146
		end -- 143
		current = current + 1 -- 147
	end -- 147
	if targetLine and targetRow then -- 148
		return luaCodes, targetLine, targetRow, lineMap -- 149
	else -- 151
		return nil -- 151
	end -- 148
end -- 131
HttpServer:postSchedule("/check", function(req) -- 153
	do -- 154
		local _type_0 = type(req) -- 154
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 154
		if _tab_0 then -- 154
			local file -- 154
			do -- 154
				local _obj_0 = req.body -- 154
				local _type_1 = type(_obj_0) -- 154
				if "table" == _type_1 or "userdata" == _type_1 then -- 154
					file = _obj_0.file -- 154
				end -- 184
			end -- 184
			local content -- 154
			do -- 154
				local _obj_0 = req.body -- 154
				local _type_1 = type(_obj_0) -- 154
				if "table" == _type_1 or "userdata" == _type_1 then -- 154
					content = _obj_0.content -- 154
				end -- 184
			end -- 184
			if file ~= nil and content ~= nil then -- 154
				local ext = Path:getExt(file) -- 155
				if "tl" == ext then -- 156
					local searchPath = getSearchPath(file) -- 157
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 158
					return { -- 159
						success = success, -- 159
						info = info -- 159
					} -- 159
				elseif "lua" == ext then -- 160
					return luaCheck(file, content) -- 161
				elseif "yue" == ext then -- 162
					local luaCodes, info = yueCheck(file, content) -- 163
					local success = false -- 164
					if luaCodes then -- 165
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 166
						do -- 167
							local _tab_1 = { } -- 167
							local _idx_0 = #_tab_1 + 1 -- 167
							for _index_0 = 1, #info do -- 167
								local _value_0 = info[_index_0] -- 167
								_tab_1[_idx_0] = _value_0 -- 167
								_idx_0 = _idx_0 + 1 -- 167
							end -- 167
							local _idx_1 = #_tab_1 + 1 -- 167
							for _index_0 = 1, #luaInfo do -- 167
								local _value_0 = luaInfo[_index_0] -- 167
								_tab_1[_idx_1] = _value_0 -- 167
								_idx_1 = _idx_1 + 1 -- 167
							end -- 167
							info = _tab_1 -- 167
						end -- 167
						success = success and luaSuccess -- 168
					end -- 165
					if #info > 0 then -- 169
						return { -- 170
							success = success, -- 170
							info = info -- 170
						} -- 170
					else -- 172
						return { -- 172
							success = success -- 172
						} -- 172
					end -- 169
				elseif "xml" == ext then -- 173
					local success, result = xml.check(content) -- 174
					if success then -- 175
						local info -- 176
						success, info = luaCheckWithLineInfo(file, result) -- 176
						if #info > 0 then -- 177
							return { -- 178
								success = success, -- 178
								info = info -- 178
							} -- 178
						else -- 180
							return { -- 180
								success = success -- 180
							} -- 180
						end -- 177
					else -- 182
						local info -- 182
						do -- 182
							local _accum_0 = { } -- 182
							local _len_0 = 1 -- 182
							for _index_0 = 1, #result do -- 182
								local _des_0 = result[_index_0] -- 182
								local row, err = _des_0[1], _des_0[2] -- 182
								_accum_0[_len_0] = { -- 183
									"syntax", -- 183
									file, -- 183
									row, -- 183
									0, -- 183
									err -- 183
								} -- 183
								_len_0 = _len_0 + 1 -- 183
							end -- 183
							info = _accum_0 -- 182
						end -- 183
						return { -- 184
							success = false, -- 184
							info = info -- 184
						} -- 184
					end -- 175
				end -- 184
			end -- 154
		end -- 184
	end -- 184
	return { -- 153
		success = true -- 153
	} -- 184
end) -- 153
local updateInferedDesc -- 186
updateInferedDesc = function(infered) -- 186
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 187
		return -- 187
	end -- 187
	local key, row = infered.key, infered.row -- 188
	local codes = Content:loadAsync(key) -- 189
	if codes then -- 189
		local comments = { } -- 190
		local line = 0 -- 191
		local skipping = false -- 192
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 193
			line = line + 1 -- 194
			if line >= row then -- 195
				break -- 195
			end -- 195
			if lineCode:match("^%s*%-%- @") then -- 196
				skipping = true -- 197
				goto _continue_0 -- 198
			end -- 196
			local result = lineCode:match("^%s*%-%- (.+)") -- 199
			if result then -- 199
				if not skipping then -- 200
					comments[#comments + 1] = result -- 200
				end -- 200
			elseif #comments > 0 then -- 201
				comments = { } -- 202
				skipping = false -- 203
			end -- 199
			::_continue_0:: -- 194
		end -- 203
		infered.doc = table.concat(comments, "\n") -- 204
	end -- 189
end -- 186
HttpServer:postSchedule("/infer", function(req) -- 206
	do -- 207
		local _type_0 = type(req) -- 207
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 207
		if _tab_0 then -- 207
			local lang -- 207
			do -- 207
				local _obj_0 = req.body -- 207
				local _type_1 = type(_obj_0) -- 207
				if "table" == _type_1 or "userdata" == _type_1 then -- 207
					lang = _obj_0.lang -- 207
				end -- 224
			end -- 224
			local file -- 207
			do -- 207
				local _obj_0 = req.body -- 207
				local _type_1 = type(_obj_0) -- 207
				if "table" == _type_1 or "userdata" == _type_1 then -- 207
					file = _obj_0.file -- 207
				end -- 224
			end -- 224
			local content -- 207
			do -- 207
				local _obj_0 = req.body -- 207
				local _type_1 = type(_obj_0) -- 207
				if "table" == _type_1 or "userdata" == _type_1 then -- 207
					content = _obj_0.content -- 207
				end -- 224
			end -- 224
			local line -- 207
			do -- 207
				local _obj_0 = req.body -- 207
				local _type_1 = type(_obj_0) -- 207
				if "table" == _type_1 or "userdata" == _type_1 then -- 207
					line = _obj_0.line -- 207
				end -- 224
			end -- 224
			local row -- 207
			do -- 207
				local _obj_0 = req.body -- 207
				local _type_1 = type(_obj_0) -- 207
				if "table" == _type_1 or "userdata" == _type_1 then -- 207
					row = _obj_0.row -- 207
				end -- 224
			end -- 224
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 207
				local searchPath = getSearchPath(file) -- 208
				if "tl" == lang or "lua" == lang then -- 209
					local infered = teal.inferAsync(content, line, row, searchPath) -- 210
					if (infered ~= nil) then -- 211
						updateInferedDesc(infered) -- 212
						return { -- 213
							success = true, -- 213
							infered = infered -- 213
						} -- 213
					end -- 211
				elseif "yue" == lang then -- 214
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file) -- 215
					if not luaCodes then -- 216
						return { -- 216
							success = false -- 216
						} -- 216
					end -- 216
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 217
					if (infered ~= nil) then -- 218
						local col -- 219
						file, row, col = infered.file, infered.row, infered.col -- 219
						if file == "" and row > 0 and col > 0 then -- 220
							infered.row = lineMap[row] or 0 -- 221
							infered.col = 0 -- 222
						end -- 220
						updateInferedDesc(infered) -- 223
						return { -- 224
							success = true, -- 224
							infered = infered -- 224
						} -- 224
					end -- 218
				end -- 224
			end -- 207
		end -- 224
	end -- 224
	return { -- 206
		success = false -- 206
	} -- 224
end) -- 206
local _anon_func_0 = function(doc) -- 275
	local _accum_0 = { } -- 275
	local _len_0 = 1 -- 275
	local _list_0 = doc.params -- 275
	for _index_0 = 1, #_list_0 do -- 275
		local param = _list_0[_index_0] -- 275
		_accum_0[_len_0] = param.name -- 275
		_len_0 = _len_0 + 1 -- 275
	end -- 275
	return _accum_0 -- 275
end -- 275
local getParamDocs -- 226
getParamDocs = function(signatures) -- 226
	do -- 227
		local codes = Content:loadAsync(signatures[1].file) -- 227
		if codes then -- 227
			local comments = { } -- 228
			local params = { } -- 229
			local line = 0 -- 230
			local docs = { } -- 231
			local returnType = nil -- 232
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 233
				line = line + 1 -- 234
				local needBreak = true -- 235
				for i, _des_0 in ipairs(signatures) do -- 236
					local row = _des_0.row -- 236
					if line >= row and not (docs[i] ~= nil) then -- 237
						if #comments > 0 or #params > 0 or returnType then -- 238
							docs[i] = { -- 240
								doc = table.concat(comments, "  \n"), -- 240
								returnType = returnType -- 241
							} -- 239
							if #params > 0 then -- 243
								docs[i].params = params -- 243
							end -- 243
						else -- 245
							docs[i] = false -- 245
						end -- 238
					end -- 237
					if not docs[i] then -- 246
						needBreak = false -- 246
					end -- 246
				end -- 246
				if needBreak then -- 247
					break -- 247
				end -- 247
				local result = lineCode:match("%s*%-%- (.+)") -- 248
				if result then -- 248
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 249
					if not name then -- 250
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 251
					end -- 250
					if name then -- 252
						local pname = name -- 253
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 254
							pname = pname .. "?" -- 254
						end -- 254
						params[#params + 1] = { -- 256
							name = tostring(pname) .. ": " .. tostring(typ), -- 256
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 257
						} -- 255
					else -- 260
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 260
						if typ then -- 260
							if returnType then -- 261
								returnType = returnType .. ", " .. typ -- 262
							else -- 264
								returnType = typ -- 264
							end -- 261
							result = result:gsub("@return", "**return:**") -- 265
						end -- 260
						comments[#comments + 1] = result -- 266
					end -- 252
				elseif #comments > 0 then -- 267
					comments = { } -- 268
					params = { } -- 269
					returnType = nil -- 270
				end -- 248
			end -- 270
			local results = { } -- 271
			for _index_0 = 1, #docs do -- 272
				local doc = docs[_index_0] -- 272
				if not doc then -- 273
					goto _continue_0 -- 273
				end -- 273
				if doc.params then -- 274
					doc.desc = "function(" .. tostring(table.concat(_anon_func_0(doc), ', ')) .. ")" -- 275
				else -- 277
					doc.desc = "function()" -- 277
				end -- 274
				if doc.returnType then -- 278
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 279
					doc.returnType = nil -- 280
				end -- 278
				results[#results + 1] = doc -- 281
				::_continue_0:: -- 273
			end -- 281
			if #results > 0 then -- 282
				return results -- 282
			else -- 282
				return nil -- 282
			end -- 282
		end -- 227
	end -- 227
	return nil -- 282
end -- 226
HttpServer:postSchedule("/signature", function(req) -- 284
	do -- 285
		local _type_0 = type(req) -- 285
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 285
		if _tab_0 then -- 285
			local lang -- 285
			do -- 285
				local _obj_0 = req.body -- 285
				local _type_1 = type(_obj_0) -- 285
				if "table" == _type_1 or "userdata" == _type_1 then -- 285
					lang = _obj_0.lang -- 285
				end -- 302
			end -- 302
			local file -- 285
			do -- 285
				local _obj_0 = req.body -- 285
				local _type_1 = type(_obj_0) -- 285
				if "table" == _type_1 or "userdata" == _type_1 then -- 285
					file = _obj_0.file -- 285
				end -- 302
			end -- 302
			local content -- 285
			do -- 285
				local _obj_0 = req.body -- 285
				local _type_1 = type(_obj_0) -- 285
				if "table" == _type_1 or "userdata" == _type_1 then -- 285
					content = _obj_0.content -- 285
				end -- 302
			end -- 302
			local line -- 285
			do -- 285
				local _obj_0 = req.body -- 285
				local _type_1 = type(_obj_0) -- 285
				if "table" == _type_1 or "userdata" == _type_1 then -- 285
					line = _obj_0.line -- 285
				end -- 302
			end -- 302
			local row -- 285
			do -- 285
				local _obj_0 = req.body -- 285
				local _type_1 = type(_obj_0) -- 285
				if "table" == _type_1 or "userdata" == _type_1 then -- 285
					row = _obj_0.row -- 285
				end -- 302
			end -- 302
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 285
				local searchPath = getSearchPath(file) -- 286
				if "tl" == lang or "lua" == lang then -- 287
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 288
					if signatures then -- 288
						signatures = getParamDocs(signatures) -- 289
						if signatures then -- 289
							return { -- 290
								success = true, -- 290
								signatures = signatures -- 290
							} -- 290
						end -- 289
					end -- 288
				elseif "yue" == lang then -- 291
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file) -- 292
					if not luaCodes then -- 293
						return { -- 293
							success = false -- 293
						} -- 293
					end -- 293
					do -- 294
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 294
						if chainOp then -- 294
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 295
							targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 296
						end -- 294
					end -- 294
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 297
					if signatures then -- 297
						signatures = getParamDocs(signatures) -- 298
						if signatures then -- 298
							return { -- 299
								success = true, -- 299
								signatures = signatures -- 299
							} -- 299
						end -- 298
					else -- 300
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 300
						if signatures then -- 300
							signatures = getParamDocs(signatures) -- 301
							if signatures then -- 301
								return { -- 302
									success = true, -- 302
									signatures = signatures -- 302
								} -- 302
							end -- 301
						end -- 300
					end -- 297
				end -- 302
			end -- 285
		end -- 302
	end -- 302
	return { -- 284
		success = false -- 284
	} -- 302
end) -- 284
local luaKeywords = { -- 305
	'and', -- 305
	'break', -- 306
	'do', -- 307
	'else', -- 308
	'elseif', -- 309
	'end', -- 310
	'false', -- 311
	'for', -- 312
	'function', -- 313
	'goto', -- 314
	'if', -- 315
	'in', -- 316
	'local', -- 317
	'nil', -- 318
	'not', -- 319
	'or', -- 320
	'repeat', -- 321
	'return', -- 322
	'then', -- 323
	'true', -- 324
	'until', -- 325
	'while' -- 326
} -- 304
local tealKeywords = { -- 330
	'record', -- 330
	'as', -- 331
	'is', -- 332
	'type', -- 333
	'embed', -- 334
	'enum', -- 335
	'global', -- 336
	'any', -- 337
	'boolean', -- 338
	'integer', -- 339
	'number', -- 340
	'string', -- 341
	'thread' -- 342
} -- 329
local yueKeywords = { -- 346
	"and", -- 346
	"break", -- 347
	"do", -- 348
	"else", -- 349
	"elseif", -- 350
	"false", -- 351
	"for", -- 352
	"goto", -- 353
	"if", -- 354
	"in", -- 355
	"local", -- 356
	"nil", -- 357
	"not", -- 358
	"or", -- 359
	"repeat", -- 360
	"return", -- 361
	"then", -- 362
	"true", -- 363
	"until", -- 364
	"while", -- 365
	"as", -- 366
	"class", -- 367
	"continue", -- 368
	"export", -- 369
	"extends", -- 370
	"from", -- 371
	"global", -- 372
	"import", -- 373
	"macro", -- 374
	"switch", -- 375
	"try", -- 376
	"unless", -- 377
	"using", -- 378
	"when", -- 379
	"with" -- 380
} -- 345
local _anon_func_1 = function(Path, f) -- 416
	local _val_0 = Path:getExt(f) -- 416
	return "ttf" == _val_0 or "otf" == _val_0 -- 416
end -- 416
local _anon_func_2 = function(suggestions) -- 442
	local _tbl_0 = { } -- 442
	for _index_0 = 1, #suggestions do -- 442
		local item = suggestions[_index_0] -- 442
		_tbl_0[item[1] .. item[2]] = item -- 442
	end -- 442
	return _tbl_0 -- 442
end -- 442
HttpServer:postSchedule("/complete", function(req) -- 383
	do -- 384
		local _type_0 = type(req) -- 384
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 384
		if _tab_0 then -- 384
			local lang -- 384
			do -- 384
				local _obj_0 = req.body -- 384
				local _type_1 = type(_obj_0) -- 384
				if "table" == _type_1 or "userdata" == _type_1 then -- 384
					lang = _obj_0.lang -- 384
				end -- 491
			end -- 491
			local file -- 384
			do -- 384
				local _obj_0 = req.body -- 384
				local _type_1 = type(_obj_0) -- 384
				if "table" == _type_1 or "userdata" == _type_1 then -- 384
					file = _obj_0.file -- 384
				end -- 491
			end -- 491
			local content -- 384
			do -- 384
				local _obj_0 = req.body -- 384
				local _type_1 = type(_obj_0) -- 384
				if "table" == _type_1 or "userdata" == _type_1 then -- 384
					content = _obj_0.content -- 384
				end -- 491
			end -- 491
			local line -- 384
			do -- 384
				local _obj_0 = req.body -- 384
				local _type_1 = type(_obj_0) -- 384
				if "table" == _type_1 or "userdata" == _type_1 then -- 384
					line = _obj_0.line -- 384
				end -- 491
			end -- 491
			local row -- 384
			do -- 384
				local _obj_0 = req.body -- 384
				local _type_1 = type(_obj_0) -- 384
				if "table" == _type_1 or "userdata" == _type_1 then -- 384
					row = _obj_0.row -- 384
				end -- 491
			end -- 491
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 384
				local searchPath = getSearchPath(file) -- 385
				repeat -- 386
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 387
					if lang == "yue" then -- 388
						if not item then -- 389
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 389
						end -- 389
						if not item then -- 390
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 390
						end -- 390
					end -- 388
					local searchType = nil -- 391
					if not item then -- 392
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 393
						if lang == "yue" then -- 394
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 395
						end -- 394
						if (item ~= nil) then -- 396
							searchType = "Image" -- 396
						end -- 396
					end -- 392
					if not item then -- 397
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 398
						if lang == "yue" then -- 399
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 400
						end -- 399
						if (item ~= nil) then -- 401
							searchType = "Font" -- 401
						end -- 401
					end -- 397
					if not item then -- 402
						break -- 402
					end -- 402
					local searchPaths = Content.searchPaths -- 403
					local _list_0 = getSearchFolders(file) -- 404
					for _index_0 = 1, #_list_0 do -- 404
						local folder = _list_0[_index_0] -- 404
						searchPaths[#searchPaths + 1] = folder -- 405
					end -- 405
					if searchType then -- 406
						searchPaths[#searchPaths + 1] = Content.assetPath -- 406
					end -- 406
					local tokens -- 407
					do -- 407
						local _accum_0 = { } -- 407
						local _len_0 = 1 -- 407
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 407
							_accum_0[_len_0] = mod -- 407
							_len_0 = _len_0 + 1 -- 407
						end -- 407
						tokens = _accum_0 -- 407
					end -- 407
					local suggestions = { } -- 408
					for _index_0 = 1, #searchPaths do -- 409
						local path = searchPaths[_index_0] -- 409
						local sPath = Path(path, table.unpack(tokens)) -- 410
						if not Content:exist(sPath) then -- 411
							goto _continue_0 -- 411
						end -- 411
						if searchType == "Font" then -- 412
							local fontPath = Path(sPath, "Font") -- 413
							if Content:exist(fontPath) then -- 414
								local _list_1 = Content:getFiles(fontPath) -- 415
								for _index_1 = 1, #_list_1 do -- 415
									local f = _list_1[_index_1] -- 415
									if _anon_func_1(Path, f) then -- 416
										if "." == f:sub(1, 1) then -- 417
											goto _continue_1 -- 417
										end -- 417
										suggestions[#suggestions + 1] = { -- 418
											Path:getName(f), -- 418
											"font", -- 418
											"field" -- 418
										} -- 418
									end -- 416
									::_continue_1:: -- 416
								end -- 418
							end -- 414
						end -- 412
						local _list_1 = Content:getFiles(sPath) -- 419
						for _index_1 = 1, #_list_1 do -- 419
							local f = _list_1[_index_1] -- 419
							if "Image" == searchType then -- 420
								do -- 421
									local _exp_0 = Path:getExt(f) -- 421
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 421
										if "." == f:sub(1, 1) then -- 422
											goto _continue_2 -- 422
										end -- 422
										suggestions[#suggestions + 1] = { -- 423
											f, -- 423
											"image", -- 423
											"field" -- 423
										} -- 423
									end -- 423
								end -- 423
								goto _continue_2 -- 424
							elseif "Font" == searchType then -- 425
								do -- 426
									local _exp_0 = Path:getExt(f) -- 426
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 426
										if "." == f:sub(1, 1) then -- 427
											goto _continue_2 -- 427
										end -- 427
										suggestions[#suggestions + 1] = { -- 428
											f, -- 428
											"font", -- 428
											"field" -- 428
										} -- 428
									end -- 428
								end -- 428
								goto _continue_2 -- 429
							end -- 429
							local _exp_0 = Path:getExt(f) -- 430
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 430
								local name = Path:getName(f) -- 431
								if "d" == Path:getExt(name) then -- 432
									goto _continue_2 -- 432
								end -- 432
								if "." == name:sub(1, 1) then -- 433
									goto _continue_2 -- 433
								end -- 433
								suggestions[#suggestions + 1] = { -- 434
									name, -- 434
									"module", -- 434
									"field" -- 434
								} -- 434
							end -- 434
							::_continue_2:: -- 420
						end -- 434
						local _list_2 = Content:getDirs(sPath) -- 435
						for _index_1 = 1, #_list_2 do -- 435
							local dir = _list_2[_index_1] -- 435
							if "." == dir:sub(1, 1) then -- 436
								goto _continue_3 -- 436
							end -- 436
							suggestions[#suggestions + 1] = { -- 437
								dir, -- 437
								"folder", -- 437
								"variable" -- 437
							} -- 437
							::_continue_3:: -- 436
						end -- 437
						::_continue_0:: -- 410
					end -- 437
					if item == "" and not searchType then -- 438
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 439
						for _index_0 = 1, #_list_1 do -- 439
							local _des_0 = _list_1[_index_0] -- 439
							local name = _des_0[1] -- 439
							suggestions[#suggestions + 1] = { -- 440
								name, -- 440
								"dora module", -- 440
								"function" -- 440
							} -- 440
						end -- 440
					end -- 438
					if #suggestions > 0 then -- 441
						do -- 442
							local _accum_0 = { } -- 442
							local _len_0 = 1 -- 442
							for _, v in pairs(_anon_func_2(suggestions)) do -- 442
								_accum_0[_len_0] = v -- 442
								_len_0 = _len_0 + 1 -- 442
							end -- 442
							suggestions = _accum_0 -- 442
						end -- 442
						return { -- 443
							success = true, -- 443
							suggestions = suggestions -- 443
						} -- 443
					else -- 445
						return { -- 445
							success = false -- 445
						} -- 445
					end -- 441
				until true -- 446
				if "tl" == lang or "lua" == lang then -- 447
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 448
					if not line:match("[%.:][%w_]+[%.:]?$") and not line:match("[%w_]+[%.:]$") then -- 449
						local checkSet -- 450
						do -- 450
							local _tbl_0 = { } -- 450
							for _index_0 = 1, #suggestions do -- 450
								local _des_0 = suggestions[_index_0] -- 450
								local name = _des_0[1] -- 450
								_tbl_0[name] = true -- 450
							end -- 450
							checkSet = _tbl_0 -- 450
						end -- 450
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 451
						for _index_0 = 1, #_list_0 do -- 451
							local item = _list_0[_index_0] -- 451
							if not checkSet[item[1]] then -- 452
								suggestions[#suggestions + 1] = item -- 452
							end -- 452
						end -- 452
						for _index_0 = 1, #luaKeywords do -- 453
							local word = luaKeywords[_index_0] -- 453
							suggestions[#suggestions + 1] = { -- 454
								word, -- 454
								"keyword", -- 454
								"keyword" -- 454
							} -- 454
						end -- 454
						if lang == "tl" then -- 455
							for _index_0 = 1, #tealKeywords do -- 456
								local word = tealKeywords[_index_0] -- 456
								suggestions[#suggestions + 1] = { -- 457
									word, -- 457
									"keyword", -- 457
									"keyword" -- 457
								} -- 457
							end -- 457
						end -- 455
					end -- 449
					if #suggestions > 0 then -- 458
						return { -- 459
							success = true, -- 459
							suggestions = suggestions -- 459
						} -- 459
					end -- 458
				elseif "yue" == lang then -- 460
					local suggestions = { } -- 461
					local gotGlobals = false -- 462
					do -- 463
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file) -- 463
						if luaCodes then -- 463
							gotGlobals = true -- 464
							do -- 465
								local chainOp = line:match("[^%w_]([%.\\])$") -- 465
								if chainOp then -- 465
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 466
									if not withVar then -- 467
										return { -- 467
											success = false -- 467
										} -- 467
									end -- 467
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 468
								elseif line:match("^([%.\\])$") then -- 469
									return { -- 470
										success = false -- 470
									} -- 470
								end -- 465
							end -- 465
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 471
							for _index_0 = 1, #_list_0 do -- 471
								local item = _list_0[_index_0] -- 471
								suggestions[#suggestions + 1] = item -- 471
							end -- 471
							if #suggestions == 0 then -- 472
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 473
								for _index_0 = 1, #_list_1 do -- 473
									local item = _list_1[_index_0] -- 473
									suggestions[#suggestions + 1] = item -- 473
								end -- 473
							end -- 472
						end -- 463
					end -- 463
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 474
						local checkSet -- 475
						do -- 475
							local _tbl_0 = { } -- 475
							for _index_0 = 1, #suggestions do -- 475
								local _des_0 = suggestions[_index_0] -- 475
								local name = _des_0[1] -- 475
								_tbl_0[name] = true -- 475
							end -- 475
							checkSet = _tbl_0 -- 475
						end -- 475
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 476
						for _index_0 = 1, #_list_0 do -- 476
							local item = _list_0[_index_0] -- 476
							if not checkSet[item[1]] then -- 477
								suggestions[#suggestions + 1] = item -- 477
							end -- 477
						end -- 477
						if not gotGlobals then -- 478
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 479
							for _index_0 = 1, #_list_1 do -- 479
								local item = _list_1[_index_0] -- 479
								if not checkSet[item[1]] then -- 480
									suggestions[#suggestions + 1] = item -- 480
								end -- 480
							end -- 480
						end -- 478
						for _index_0 = 1, #yueKeywords do -- 481
							local word = yueKeywords[_index_0] -- 481
							if not checkSet[word] then -- 482
								suggestions[#suggestions + 1] = { -- 483
									word, -- 483
									"keyword", -- 483
									"keyword" -- 483
								} -- 483
							end -- 482
						end -- 483
					end -- 474
					if #suggestions > 0 then -- 484
						return { -- 485
							success = true, -- 485
							suggestions = suggestions -- 485
						} -- 485
					end -- 484
				elseif "xml" == lang then -- 486
					local items = xml.complete(content) -- 487
					if #items > 0 then -- 488
						local suggestions -- 489
						do -- 489
							local _accum_0 = { } -- 489
							local _len_0 = 1 -- 489
							for _index_0 = 1, #items do -- 489
								local _des_0 = items[_index_0] -- 489
								local label, insertText = _des_0[1], _des_0[2] -- 489
								_accum_0[_len_0] = { -- 490
									label, -- 490
									insertText, -- 490
									"field" -- 490
								} -- 490
								_len_0 = _len_0 + 1 -- 490
							end -- 490
							suggestions = _accum_0 -- 489
						end -- 490
						return { -- 491
							success = true, -- 491
							suggestions = suggestions -- 491
						} -- 491
					end -- 488
				end -- 491
			end -- 384
		end -- 491
	end -- 491
	return { -- 383
		success = false -- 383
	} -- 491
end) -- 383
HttpServer:upload("/upload", function(req, filename) -- 495
	do -- 496
		local _type_0 = type(req) -- 496
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 496
		if _tab_0 then -- 496
			local path -- 496
			do -- 496
				local _obj_0 = req.params -- 496
				local _type_1 = type(_obj_0) -- 496
				if "table" == _type_1 or "userdata" == _type_1 then -- 496
					path = _obj_0.path -- 496
				end -- 502
			end -- 502
			if path ~= nil then -- 496
				local uploadPath = Path(Content.writablePath, ".upload") -- 497
				if not Content:exist(uploadPath) then -- 498
					Content:mkdir(uploadPath) -- 499
				end -- 498
				local targetPath = Path(uploadPath, filename) -- 500
				Content:mkdir(Path:getPath(targetPath)) -- 501
				return targetPath -- 502
			end -- 496
		end -- 502
	end -- 502
	return nil -- 502
end, function(req, file) -- 503
	do -- 504
		local _type_0 = type(req) -- 504
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 504
		if _tab_0 then -- 504
			local path -- 504
			do -- 504
				local _obj_0 = req.params -- 504
				local _type_1 = type(_obj_0) -- 504
				if "table" == _type_1 or "userdata" == _type_1 then -- 504
					path = _obj_0.path -- 504
				end -- 511
			end -- 511
			if path ~= nil then -- 504
				path = Path(Content.writablePath, path) -- 505
				if Content:exist(path) then -- 506
					local uploadPath = Path(Content.writablePath, ".upload") -- 507
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 508
					Content:mkdir(Path:getPath(targetPath)) -- 509
					if Content:move(file, targetPath) then -- 510
						return true -- 511
					end -- 510
				end -- 506
			end -- 504
		end -- 511
	end -- 511
	return false -- 511
end) -- 493
HttpServer:post("/list", function(req) -- 514
	do -- 515
		local _type_0 = type(req) -- 515
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 515
		if _tab_0 then -- 515
			local path -- 515
			do -- 515
				local _obj_0 = req.body -- 515
				local _type_1 = type(_obj_0) -- 515
				if "table" == _type_1 or "userdata" == _type_1 then -- 515
					path = _obj_0.path -- 515
				end -- 537
			end -- 537
			if path ~= nil then -- 515
				if Content:exist(path) then -- 516
					local files = { } -- 517
					local visitAssets -- 518
					visitAssets = function(path, folder) -- 518
						local dirs = Content:getDirs(path) -- 519
						for _index_0 = 1, #dirs do -- 520
							local dir = dirs[_index_0] -- 520
							if dir:match("^%.") then -- 521
								goto _continue_0 -- 521
							end -- 521
							local current -- 522
							if folder == "" then -- 522
								current = dir -- 523
							else -- 525
								current = Path(folder, dir) -- 525
							end -- 522
							files[#files + 1] = current -- 526
							visitAssets(Path(path, dir), current) -- 527
							::_continue_0:: -- 521
						end -- 527
						local fs = Content:getFiles(path) -- 528
						for _index_0 = 1, #fs do -- 529
							local f = fs[_index_0] -- 529
							if f:match("^%.") then -- 530
								goto _continue_1 -- 530
							end -- 530
							if folder == "" then -- 531
								files[#files + 1] = f -- 532
							else -- 534
								files[#files + 1] = Path(folder, f) -- 534
							end -- 531
							::_continue_1:: -- 530
						end -- 534
					end -- 518
					visitAssets(path, "") -- 535
					if #files == 0 then -- 536
						files = nil -- 536
					end -- 536
					return { -- 537
						success = true, -- 537
						files = files -- 537
					} -- 537
				end -- 516
			end -- 515
		end -- 537
	end -- 537
	return { -- 514
		success = false -- 514
	} -- 537
end) -- 514
HttpServer:post("/info", function() -- 539
	local Entry = require("Script.Dev.Entry") -- 540
	local engineDev = Entry.getEngineDev() -- 541
	return { -- 543
		platform = App.platform, -- 543
		locale = App.locale, -- 544
		version = App.version, -- 545
		engineDev = engineDev -- 546
	} -- 546
end) -- 539
HttpServer:post("/new", function(req) -- 548
	do -- 549
		local _type_0 = type(req) -- 549
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 549
		if _tab_0 then -- 549
			local path -- 549
			do -- 549
				local _obj_0 = req.body -- 549
				local _type_1 = type(_obj_0) -- 549
				if "table" == _type_1 or "userdata" == _type_1 then -- 549
					path = _obj_0.path -- 549
				end -- 561
			end -- 561
			local content -- 549
			do -- 549
				local _obj_0 = req.body -- 549
				local _type_1 = type(_obj_0) -- 549
				if "table" == _type_1 or "userdata" == _type_1 then -- 549
					content = _obj_0.content -- 549
				end -- 561
			end -- 561
			if path ~= nil and content ~= nil then -- 549
				if not Content:exist(path) then -- 550
					local parent = Path:getPath(path) -- 551
					local files = Content:getFiles(parent) -- 552
					local name = Path:getName(path):lower() -- 553
					for _index_0 = 1, #files do -- 554
						local file = files[_index_0] -- 554
						if name == Path:getName(file):lower() then -- 555
							return { -- 556
								success = false -- 556
							} -- 556
						end -- 555
					end -- 556
					if "" == Path:getExt(path) then -- 557
						if Content:mkdir(path) then -- 558
							return { -- 559
								success = true -- 559
							} -- 559
						end -- 558
					elseif Content:save(path, content) then -- 560
						return { -- 561
							success = true -- 561
						} -- 561
					end -- 557
				end -- 550
			end -- 549
		end -- 561
	end -- 561
	return { -- 548
		success = false -- 548
	} -- 561
end) -- 548
HttpServer:post("/delete", function(req) -- 563
	do -- 564
		local _type_0 = type(req) -- 564
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 564
		if _tab_0 then -- 564
			local path -- 564
			do -- 564
				local _obj_0 = req.body -- 564
				local _type_1 = type(_obj_0) -- 564
				if "table" == _type_1 or "userdata" == _type_1 then -- 564
					path = _obj_0.path -- 564
				end -- 577
			end -- 577
			if path ~= nil then -- 564
				if Content:exist(path) then -- 565
					local parent = Path:getPath(path) -- 566
					local files = Content:getFiles(parent) -- 567
					local name = Path:getName(path):lower() -- 568
					local ext = Path:getExt(path) -- 569
					for _index_0 = 1, #files do -- 570
						local file = files[_index_0] -- 570
						if name == Path:getName(file):lower() then -- 571
							local _exp_0 = Path:getExt(file) -- 572
							if "tl" == _exp_0 then -- 572
								if ("vs" == ext) then -- 572
									Content:remove(Path(parent, file)) -- 573
								end -- 572
							elseif "lua" == _exp_0 then -- 574
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 574
									Content:remove(Path(parent, file)) -- 575
								end -- 574
							end -- 575
						end -- 571
					end -- 575
					if Content:remove(path) then -- 576
						return { -- 577
							success = true -- 577
						} -- 577
					end -- 576
				end -- 565
			end -- 564
		end -- 577
	end -- 577
	return { -- 563
		success = false -- 563
	} -- 577
end) -- 563
HttpServer:post("/rename", function(req) -- 579
	do -- 580
		local _type_0 = type(req) -- 580
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 580
		if _tab_0 then -- 580
			local old -- 580
			do -- 580
				local _obj_0 = req.body -- 580
				local _type_1 = type(_obj_0) -- 580
				if "table" == _type_1 or "userdata" == _type_1 then -- 580
					old = _obj_0.old -- 580
				end -- 602
			end -- 602
			local new -- 580
			do -- 580
				local _obj_0 = req.body -- 580
				local _type_1 = type(_obj_0) -- 580
				if "table" == _type_1 or "userdata" == _type_1 then -- 580
					new = _obj_0.new -- 580
				end -- 602
			end -- 602
			if old ~= nil and new ~= nil then -- 580
				if Content:exist(old) and not Content:exist(new) then -- 581
					local parent = Path:getPath(new) -- 582
					local files = Content:getFiles(parent) -- 583
					local name = Path:getName(new):lower() -- 584
					for _index_0 = 1, #files do -- 585
						local file = files[_index_0] -- 585
						if name == Path:getName(file):lower() then -- 586
							return { -- 587
								success = false -- 587
							} -- 587
						end -- 586
					end -- 587
					if Content:move(old, new) then -- 588
						local newParent = Path:getPath(new) -- 589
						parent = Path:getPath(old) -- 590
						files = Content:getFiles(parent) -- 591
						local newName = Path:getName(new) -- 592
						local oldName = Path:getName(old) -- 593
						name = oldName:lower() -- 594
						local ext = Path:getExt(old) -- 595
						for _index_0 = 1, #files do -- 596
							local file = files[_index_0] -- 596
							if name == Path:getName(file):lower() then -- 597
								local _exp_0 = Path:getExt(file) -- 598
								if "tl" == _exp_0 then -- 598
									if ("vs" == ext) then -- 598
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 599
									end -- 598
								elseif "lua" == _exp_0 then -- 600
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 600
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 601
									end -- 600
								end -- 601
							end -- 597
						end -- 601
						return { -- 602
							success = true -- 602
						} -- 602
					end -- 588
				end -- 581
			end -- 580
		end -- 602
	end -- 602
	return { -- 579
		success = false -- 579
	} -- 602
end) -- 579
HttpServer:postSchedule("/read", function(req) -- 604
	do -- 605
		local _type_0 = type(req) -- 605
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 605
		if _tab_0 then -- 605
			local path -- 605
			do -- 605
				local _obj_0 = req.body -- 605
				local _type_1 = type(_obj_0) -- 605
				if "table" == _type_1 or "userdata" == _type_1 then -- 605
					path = _obj_0.path -- 605
				end -- 608
			end -- 608
			if path ~= nil then -- 605
				if Content:exist(path) then -- 606
					local content = Content:loadAsync(path) -- 607
					if content then -- 607
						return { -- 608
							content = content, -- 608
							success = true -- 608
						} -- 608
					end -- 607
				end -- 606
			end -- 605
		end -- 608
	end -- 608
	return { -- 604
		success = false -- 604
	} -- 608
end) -- 604
local compileFileAsync -- 610
compileFileAsync = function(inputFile, sourceCodes) -- 610
	local file = inputFile -- 611
	local searchPath -- 612
	do -- 612
		local dir = getProjectDirFromFile(inputFile) -- 612
		if dir then -- 612
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 613
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 614
		else -- 616
			file = Path:getRelative(inputFile, Path(Content.writablePath)) -- 616
			if file:sub(1, 2) == ".." then -- 617
				file = Path:getRelative(inputFile, Path(Content.assetPath)) -- 618
			end -- 617
			searchPath = "" -- 619
		end -- 612
	end -- 612
	local outputFile = Path:replaceExt(inputFile, "lua") -- 620
	local yueext = yue.options.extension -- 621
	local resultCodes = nil -- 622
	do -- 623
		local _exp_0 = Path:getExt(inputFile) -- 623
		if yueext == _exp_0 then -- 623
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 624
				if not codes then -- 625
					return -- 625
				end -- 625
				local success, result = LintYueGlobals(codes, globals) -- 626
				if not success then -- 627
					return -- 627
				end -- 627
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 628
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 629
				codes = codes:gsub("^\n*", "") -- 630
				if not (result == "") then -- 631
					result = result .. "\n" -- 631
				end -- 631
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 632
				return resultCodes -- 633
			end, function(success) -- 624
				if not success then -- 634
					Content:remove(outputFile) -- 635
					resultCodes = false -- 636
				end -- 634
			end) -- 624
		elseif "tl" == _exp_0 then -- 637
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 638
			if codes then -- 638
				resultCodes = codes -- 639
				Content:saveAsync(outputFile, codes) -- 640
			else -- 642
				Content:remove(outputFile) -- 642
				resultCodes = false -- 643
			end -- 638
		elseif "xml" == _exp_0 then -- 644
			local codes = xml.tolua(sourceCodes) -- 645
			if codes then -- 645
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 646
				Content:saveAsync(outputFile, resultCodes) -- 647
			else -- 649
				Content:remove(outputFile) -- 649
				resultCodes = false -- 650
			end -- 645
		end -- 650
	end -- 650
	wait(function() -- 651
		return resultCodes ~= nil -- 651
	end) -- 651
	if resultCodes then -- 652
		return resultCodes -- 652
	end -- 652
	return nil -- 652
end -- 610
HttpServer:postSchedule("/write", function(req) -- 654
	do -- 655
		local _type_0 = type(req) -- 655
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 655
		if _tab_0 then -- 655
			local path -- 655
			do -- 655
				local _obj_0 = req.body -- 655
				local _type_1 = type(_obj_0) -- 655
				if "table" == _type_1 or "userdata" == _type_1 then -- 655
					path = _obj_0.path -- 655
				end -- 661
			end -- 661
			local content -- 655
			do -- 655
				local _obj_0 = req.body -- 655
				local _type_1 = type(_obj_0) -- 655
				if "table" == _type_1 or "userdata" == _type_1 then -- 655
					content = _obj_0.content -- 655
				end -- 661
			end -- 661
			if path ~= nil and content ~= nil then -- 655
				if Content:saveAsync(path, content) then -- 656
					do -- 657
						local _exp_0 = Path:getExt(path) -- 657
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 657
							if '' == Path:getExt(Path:getName(path)) then -- 658
								local resultCodes = compileFileAsync(path, content) -- 659
								return { -- 660
									success = true, -- 660
									resultCodes = resultCodes -- 660
								} -- 660
							end -- 658
						end -- 660
					end -- 660
					return { -- 661
						success = true -- 661
					} -- 661
				end -- 656
			end -- 655
		end -- 661
	end -- 661
	return { -- 654
		success = false -- 654
	} -- 661
end) -- 654
local extentionLevels = { -- 664
	vs = 2, -- 664
	ts = 1, -- 665
	tsx = 1, -- 666
	tl = 1, -- 667
	yue = 1, -- 668
	xml = 1, -- 669
	lua = 0 -- 670
} -- 663
local _anon_func_4 = function(Content, Path, visitAssets, zh) -- 736
	local _with_0 = visitAssets(Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")) -- 735
	_with_0.title = zh and "说明文档" or "Readme" -- 736
	return _with_0 -- 735
end -- 735
local _anon_func_5 = function(Content, Path, visitAssets, zh) -- 738
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")) -- 737
	_with_0.title = zh and "接口文档" or "API Doc" -- 738
	return _with_0 -- 737
end -- 737
local _anon_func_6 = function(Content, Path, visitAssets, zh) -- 740
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Example")) -- 739
	_with_0.title = zh and "代码示例" or "Example" -- 740
	return _with_0 -- 739
end -- 739
local _anon_func_7 = function(Content, Path, visitAssets, zh) -- 742
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Game")) -- 741
	_with_0.title = zh and "游戏演示" or "Demo Game" -- 742
	return _with_0 -- 741
end -- 741
local _anon_func_8 = function(Content, Path, visitAssets, zh) -- 744
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Test")) -- 743
	_with_0.title = zh and "功能测试" or "Test" -- 744
	return _with_0 -- 743
end -- 743
local _anon_func_9 = function(Content, Path, engineDev, visitAssets, zh) -- 756
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib")) -- 748
	if engineDev then -- 749
		local _list_0 = _with_0.children -- 750
		for _index_0 = 1, #_list_0 do -- 750
			local child = _list_0[_index_0] -- 750
			if not (child.title == "Dora") then -- 751
				goto _continue_0 -- 751
			end -- 751
			local title = zh and "zh-Hans" or "en" -- 752
			do -- 753
				local _accum_0 = { } -- 753
				local _len_0 = 1 -- 753
				local _list_1 = child.children -- 753
				for _index_1 = 1, #_list_1 do -- 753
					local c = _list_1[_index_1] -- 753
					if c.title ~= title then -- 753
						_accum_0[_len_0] = c -- 753
						_len_0 = _len_0 + 1 -- 753
					end -- 753
				end -- 753
				child.children = _accum_0 -- 753
			end -- 753
			break -- 754
			::_continue_0:: -- 751
		end -- 754
	else -- 756
		local _accum_0 = { } -- 756
		local _len_0 = 1 -- 756
		local _list_0 = _with_0.children -- 756
		for _index_0 = 1, #_list_0 do -- 756
			local child = _list_0[_index_0] -- 756
			if child.title ~= "Dora" then -- 756
				_accum_0[_len_0] = child -- 756
				_len_0 = _len_0 + 1 -- 756
			end -- 756
		end -- 756
		_with_0.children = _accum_0 -- 756
	end -- 749
	return _with_0 -- 748
end -- 748
local _anon_func_10 = function(Content, Path, engineDev, visitAssets) -- 757
	if engineDev then -- 757
		local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Dev")) -- 758
		local _obj_0 = _with_0.children -- 759
		_obj_0[#_obj_0 + 1] = { -- 760
			key = Path(Content.assetPath, "Script", "init.yue"), -- 760
			dir = false, -- 761
			title = "init.yue" -- 762
		} -- 759
		return _with_0 -- 758
	end -- 757
end -- 757
local _anon_func_3 = function(Content, Path, engineDev, pairs, visitAssets, zh) -- 765
	local _tab_0 = { -- 730
		{ -- 731
			key = Path(Content.assetPath), -- 731
			dir = true, -- 732
			title = zh and "内置资源" or "Built-in", -- 733
			children = { -- 735
				_anon_func_4(Content, Path, visitAssets, zh), -- 735
				_anon_func_5(Content, Path, visitAssets, zh), -- 737
				_anon_func_6(Content, Path, visitAssets, zh), -- 739
				_anon_func_7(Content, Path, visitAssets, zh), -- 741
				_anon_func_8(Content, Path, visitAssets, zh), -- 743
				visitAssets(Path(Content.assetPath, "Image")), -- 745
				visitAssets(Path(Content.assetPath, "Spine")), -- 746
				visitAssets(Path(Content.assetPath, "Font")), -- 747
				_anon_func_9(Content, Path, engineDev, visitAssets, zh), -- 748
				_anon_func_10(Content, Path, engineDev, visitAssets) -- 757
			} -- 734
		} -- 730
	} -- 766
	local _obj_0 = visitAssets(Content.writablePath, true) -- 766
	local _idx_0 = #_tab_0 + 1 -- 766
	for _index_0 = 1, #_obj_0 do -- 766
		local _value_0 = _obj_0[_index_0] -- 766
		_tab_0[_idx_0] = _value_0 -- 766
		_idx_0 = _idx_0 + 1 -- 766
	end -- 766
	return _tab_0 -- 765
end -- 730
HttpServer:post("/assets", function() -- 672
	local Entry = require("Script.Dev.Entry") -- 673
	local engineDev = Entry.getEngineDev() -- 674
	local visitAssets -- 675
	visitAssets = function(path, root) -- 675
		local children = nil -- 676
		local dirs = Content:getDirs(path) -- 677
		for _index_0 = 1, #dirs do -- 678
			local dir = dirs[_index_0] -- 678
			if root then -- 679
				if ".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir then -- 679
					goto _continue_0 -- 680
				end -- 680
			elseif dir == ".git" then -- 681
				goto _continue_0 -- 682
			end -- 679
			if not children then -- 683
				children = { } -- 683
			end -- 683
			children[#children + 1] = visitAssets(Path(path, dir)) -- 684
			::_continue_0:: -- 679
		end -- 684
		local files = Content:getFiles(path) -- 685
		local names = { } -- 686
		for _index_0 = 1, #files do -- 687
			local file = files[_index_0] -- 687
			if file:match("^%.") then -- 688
				goto _continue_1 -- 688
			end -- 688
			local name = Path:getName(file) -- 689
			local ext = names[name] -- 690
			if ext then -- 690
				local lv1 -- 691
				do -- 691
					local _exp_0 = extentionLevels[ext] -- 691
					if _exp_0 ~= nil then -- 691
						lv1 = _exp_0 -- 691
					else -- 691
						lv1 = -1 -- 691
					end -- 691
				end -- 691
				ext = Path:getExt(file) -- 692
				local lv2 -- 693
				do -- 693
					local _exp_0 = extentionLevels[ext] -- 693
					if _exp_0 ~= nil then -- 693
						lv2 = _exp_0 -- 693
					else -- 693
						lv2 = -1 -- 693
					end -- 693
				end -- 693
				if lv2 > lv1 then -- 694
					names[name] = ext -- 694
				end -- 694
			else -- 696
				ext = Path:getExt(file) -- 696
				if not extentionLevels[ext] then -- 697
					names[file] = "" -- 698
				else -- 700
					names[name] = ext -- 700
				end -- 697
			end -- 690
			::_continue_1:: -- 688
		end -- 700
		do -- 701
			local _accum_0 = { } -- 701
			local _len_0 = 1 -- 701
			for name, ext in pairs(names) do -- 701
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 701
				_len_0 = _len_0 + 1 -- 701
			end -- 701
			files = _accum_0 -- 701
		end -- 701
		for _index_0 = 1, #files do -- 702
			local file = files[_index_0] -- 702
			if not children then -- 703
				children = { } -- 703
			end -- 703
			children[#children + 1] = { -- 705
				key = Path(path, file), -- 705
				dir = false, -- 706
				title = file -- 707
			} -- 704
		end -- 708
		if children then -- 709
			table.sort(children, function(a, b) -- 710
				if a.dir == b.dir then -- 711
					return a.title < b.title -- 712
				else -- 714
					return a.dir -- 714
				end -- 711
			end) -- 710
		end -- 709
		if root then -- 715
			return children -- 716
		else -- 718
			return { -- 719
				key = path, -- 719
				dir = true, -- 720
				title = Path:getFilename(path), -- 721
				children = children -- 722
			} -- 723
		end -- 715
	end -- 675
	local zh = (App.locale:match("^zh") ~= nil) -- 724
	return { -- 726
		key = Content.writablePath, -- 726
		dir = true, -- 727
		title = "Assets", -- 728
		children = _anon_func_3(Content, Path, engineDev, pairs, visitAssets, zh) -- 729
	} -- 768
end) -- 672
HttpServer:postSchedule("/run", function(req) -- 770
	do -- 771
		local _type_0 = type(req) -- 771
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 771
		if _tab_0 then -- 771
			local file -- 771
			do -- 771
				local _obj_0 = req.body -- 771
				local _type_1 = type(_obj_0) -- 771
				if "table" == _type_1 or "userdata" == _type_1 then -- 771
					file = _obj_0.file -- 771
				end -- 786
			end -- 786
			local asProj -- 771
			do -- 771
				local _obj_0 = req.body -- 771
				local _type_1 = type(_obj_0) -- 771
				if "table" == _type_1 or "userdata" == _type_1 then -- 771
					asProj = _obj_0.asProj -- 771
				end -- 786
			end -- 786
			if file ~= nil and asProj ~= nil then -- 771
				if not Content:isAbsolutePath(file) then -- 772
					local devFile = Path(Content.writablePath, file) -- 773
					if Content:exist(devFile) then -- 774
						file = devFile -- 774
					end -- 774
				end -- 772
				local Entry = require("Script.Dev.Entry") -- 775
				if asProj then -- 776
					local proj = getProjectDirFromFile(file) -- 777
					if proj then -- 777
						Entry.allClear() -- 778
						local target = Path(proj, "init") -- 779
						local success, err = Entry.enterEntryAsync({ -- 780
							"Project", -- 780
							target -- 780
						}) -- 780
						target = Path:getName(Path:getPath(target)) -- 781
						return { -- 782
							success = success, -- 782
							target = target, -- 782
							err = err -- 782
						} -- 782
					end -- 777
				end -- 776
				Entry.allClear() -- 783
				file = Path:replaceExt(file, "") -- 784
				local success, err = Entry.enterEntryAsync({ -- 785
					Path:getName(file), -- 785
					file -- 785
				}) -- 785
				return { -- 786
					success = success, -- 786
					err = err -- 786
				} -- 786
			end -- 771
		end -- 786
	end -- 786
	return { -- 770
		success = false -- 770
	} -- 786
end) -- 770
HttpServer:postSchedule("/stop", function() -- 788
	local Entry = require("Script.Dev.Entry") -- 789
	return { -- 790
		success = Entry.stop() -- 790
	} -- 790
end) -- 788
HttpServer:postSchedule("/zip", function(req) -- 792
	do -- 793
		local _type_0 = type(req) -- 793
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 793
		if _tab_0 then -- 793
			local path -- 793
			do -- 793
				local _obj_0 = req.body -- 793
				local _type_1 = type(_obj_0) -- 793
				if "table" == _type_1 or "userdata" == _type_1 then -- 793
					path = _obj_0.path -- 793
				end -- 796
			end -- 796
			local zipFile -- 793
			do -- 793
				local _obj_0 = req.body -- 793
				local _type_1 = type(_obj_0) -- 793
				if "table" == _type_1 or "userdata" == _type_1 then -- 793
					zipFile = _obj_0.zipFile -- 793
				end -- 796
			end -- 796
			if path ~= nil and zipFile ~= nil then -- 793
				Content:mkdir(Path:getPath(zipFile)) -- 794
				return { -- 795
					success = Content:zipAsync(path, zipFile, function(file) -- 795
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 796
					end) -- 795
				} -- 796
			end -- 793
		end -- 796
	end -- 796
	return { -- 792
		success = false -- 792
	} -- 796
end) -- 792
HttpServer:postSchedule("/unzip", function(req) -- 798
	do -- 799
		local _type_0 = type(req) -- 799
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 799
		if _tab_0 then -- 799
			local zipFile -- 799
			do -- 799
				local _obj_0 = req.body -- 799
				local _type_1 = type(_obj_0) -- 799
				if "table" == _type_1 or "userdata" == _type_1 then -- 799
					zipFile = _obj_0.zipFile -- 799
				end -- 801
			end -- 801
			local path -- 799
			do -- 799
				local _obj_0 = req.body -- 799
				local _type_1 = type(_obj_0) -- 799
				if "table" == _type_1 or "userdata" == _type_1 then -- 799
					path = _obj_0.path -- 799
				end -- 801
			end -- 801
			if zipFile ~= nil and path ~= nil then -- 799
				return { -- 800
					success = Content:unzipAsync(zipFile, path, function(file) -- 800
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 801
					end) -- 800
				} -- 801
			end -- 799
		end -- 801
	end -- 801
	return { -- 798
		success = false -- 798
	} -- 801
end) -- 798
HttpServer:post("/editingInfo", function(req) -- 803
	local Entry = require("Script.Dev.Entry") -- 804
	local config = Entry.getConfig() -- 805
	local _type_0 = type(req) -- 806
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 806
	local _match_0 = false -- 806
	if _tab_0 then -- 806
		local editingInfo -- 806
		do -- 806
			local _obj_0 = req.body -- 806
			local _type_1 = type(_obj_0) -- 806
			if "table" == _type_1 or "userdata" == _type_1 then -- 806
				editingInfo = _obj_0.editingInfo -- 806
			end -- 808
		end -- 808
		if editingInfo ~= nil then -- 806
			_match_0 = true -- 806
			config.editingInfo = editingInfo -- 807
			return { -- 808
				success = true -- 808
			} -- 808
		end -- 806
	end -- 806
	if not _match_0 then -- 806
		if not (config.editingInfo ~= nil) then -- 810
			local json = require("json") -- 811
			local folder -- 812
			if App.locale:match('^zh') then -- 812
				folder = 'zh-Hans' -- 812
			else -- 812
				folder = 'en' -- 812
			end -- 812
			config.editingInfo = json.dump({ -- 814
				index = 0, -- 814
				files = { -- 816
					{ -- 817
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 817
						title = "welcome.md" -- 818
					} -- 816
				} -- 815
			}) -- 813
		end -- 810
		return { -- 822
			success = true, -- 822
			editingInfo = config.editingInfo -- 822
		} -- 822
	end -- 822
end) -- 803
HttpServer:post("/command", function(req) -- 824
	do -- 825
		local _type_0 = type(req) -- 825
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 825
		if _tab_0 then -- 825
			local code -- 825
			do -- 825
				local _obj_0 = req.body -- 825
				local _type_1 = type(_obj_0) -- 825
				if "table" == _type_1 or "userdata" == _type_1 then -- 825
					code = _obj_0.code -- 825
				end -- 827
			end -- 827
			if code ~= nil then -- 825
				emit("AppCommand", code) -- 826
				return { -- 827
					success = true -- 827
				} -- 827
			end -- 825
		end -- 827
	end -- 827
	return { -- 824
		success = false -- 824
	} -- 827
end) -- 824
HttpServer:post("/exist", function(req) -- 829
	do -- 830
		local _type_0 = type(req) -- 830
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 830
		if _tab_0 then -- 830
			local file -- 830
			do -- 830
				local _obj_0 = req.body -- 830
				local _type_1 = type(_obj_0) -- 830
				if "table" == _type_1 or "userdata" == _type_1 then -- 830
					file = _obj_0.file -- 830
				end -- 831
			end -- 831
			if file ~= nil then -- 830
				return { -- 831
					success = Content:exist(file) -- 831
				} -- 831
			end -- 830
		end -- 831
	end -- 831
	return { -- 829
		success = false -- 829
	} -- 831
end) -- 829
local status = { } -- 833
_module_0 = status -- 834
thread(function() -- 836
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 837
	local doraReady = Path(Content.writablePath, ".www", "dora-ready") -- 838
	if Content:exist(doraWeb) then -- 839
		local needReload -- 840
		if Content:exist(doraReady) then -- 840
			needReload = App.version ~= Content:load(doraReady) -- 841
		else -- 842
			needReload = true -- 842
		end -- 840
		if needReload then -- 843
			Content:remove(Path(Content.writablePath, ".www")) -- 844
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.writablePath, ".www")) -- 845
			Content:save(doraReady, App.version) -- 849
			print("Dora Dora is ready!") -- 850
		end -- 843
	end -- 839
	if HttpServer:start(8866) then -- 851
		local localIP = HttpServer.localIP -- 852
		if localIP == "" then -- 853
			localIP = "localhost" -- 853
		end -- 853
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 854
		return HttpServer:startWS(8868) -- 855
	else -- 857
		status.url = nil -- 857
		return print("8866 Port not available!") -- 858
	end -- 851
end) -- 836
return _module_0 -- 858
