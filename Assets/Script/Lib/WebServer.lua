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
	"can't match a record to a map with non%-string keys" -- 49
} -- 32
local yueCheck -- 51
yueCheck = function(file, content) -- 51
	local searchPath = getSearchPath(file) -- 52
	local checkResult, luaCodes = yue.checkAsync(content, searchPath) -- 53
	local info = { } -- 54
	local globals = { } -- 55
	for _index_0 = 1, #checkResult do -- 56
		local _des_0 = checkResult[_index_0] -- 56
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 56
		if "error" == t then -- 57
			info[#info + 1] = { -- 58
				"syntax", -- 58
				file, -- 58
				line, -- 58
				col, -- 58
				msg -- 58
			} -- 58
		elseif "global" == t then -- 59
			globals[#globals + 1] = { -- 60
				msg, -- 60
				line, -- 60
				col -- 60
			} -- 60
		end -- 60
	end -- 60
	if luaCodes then -- 61
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 62
		if success then -- 63
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 64
			if not (lintResult == "") then -- 65
				lintResult = lintResult .. "\n" -- 65
			end -- 65
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 66
		else -- 67
			for _index_0 = 1, #lintResult do -- 67
				local _des_0 = lintResult[_index_0] -- 67
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 67
				info[#info + 1] = { -- 68
					"syntax", -- 68
					file, -- 68
					line, -- 68
					col, -- 68
					"invalid global variable" -- 68
				} -- 68
			end -- 68
		end -- 63
	end -- 61
	return luaCodes, info -- 69
end -- 51
local luaCheck -- 71
luaCheck = function(file, content) -- 71
	local res, err = load(content, "check") -- 72
	if not res then -- 73
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 74
		return { -- 75
			success = false, -- 75
			info = { -- 75
				{ -- 75
					"syntax", -- 75
					file, -- 75
					tonumber(line), -- 75
					0, -- 75
					msg -- 75
				} -- 75
			} -- 75
		} -- 75
	end -- 73
	local success, info = teal.checkAsync(content, file, true, "") -- 76
	if info then -- 77
		do -- 78
			local _accum_0 = { } -- 78
			local _len_0 = 1 -- 78
			for _index_0 = 1, #info do -- 78
				local item = info[_index_0] -- 78
				local useCheck = true -- 79
				for _index_1 = 1, #disabledCheckForLua do -- 80
					local check = disabledCheckForLua[_index_1] -- 80
					if not item[5]:match("unused") and item[5]:match(check) then -- 81
						useCheck = false -- 82
					end -- 81
				end -- 82
				if not useCheck then -- 83
					goto _continue_0 -- 83
				end -- 83
				do -- 84
					local _exp_0 = item[1] -- 84
					if "type" == _exp_0 then -- 85
						item[1] = "warning" -- 86
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 87
						goto _continue_0 -- 88
					end -- 88
				end -- 88
				_accum_0[_len_0] = item -- 89
				_len_0 = _len_0 + 1 -- 89
				::_continue_0:: -- 79
			end -- 89
			info = _accum_0 -- 78
		end -- 89
		if #info == 0 then -- 90
			info = nil -- 91
			success = true -- 92
		end -- 90
	end -- 77
	return { -- 93
		success = success, -- 93
		info = info -- 93
	} -- 93
end -- 71
local luaCheckWithLineInfo -- 95
luaCheckWithLineInfo = function(file, luaCodes) -- 95
	local res = luaCheck(file, luaCodes) -- 96
	local info = { } -- 97
	if not res.success then -- 98
		local current = 1 -- 99
		local lastLine = 1 -- 100
		local lineMap = { } -- 101
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 102
			local num = lineCode:match("--%s*(%d+)%s*$") -- 103
			if num then -- 104
				lastLine = tonumber(num) -- 105
			end -- 104
			lineMap[current] = lastLine -- 106
			current = current + 1 -- 107
		end -- 107
		local _list_0 = res.info -- 108
		for _index_0 = 1, #_list_0 do -- 108
			local item = _list_0[_index_0] -- 108
			item[3] = lineMap[item[3]] or 0 -- 109
			item[4] = 0 -- 110
			info[#info + 1] = item -- 111
		end -- 111
		return false, info -- 112
	end -- 98
	return true, info -- 113
end -- 95
local getCompiledYueLine -- 115
getCompiledYueLine = function(content, line, row, file) -- 115
	local luaCodes, info = yueCheck(file, content) -- 116
	if not luaCodes then -- 117
		return nil -- 117
	end -- 117
	local current = 1 -- 118
	local lastLine = 1 -- 119
	local targetLine = nil -- 120
	local targetRow = nil -- 121
	local lineMap = { } -- 122
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 123
		local num = lineCode:match("--%s*(%d+)%s*$") -- 124
		if num then -- 125
			lastLine = tonumber(num) -- 125
		end -- 125
		lineMap[current] = lastLine -- 126
		if row == lastLine and not targetLine then -- 127
			targetRow = current -- 128
			targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 129
			if targetLine then -- 130
				break -- 130
			end -- 130
		end -- 127
		current = current + 1 -- 131
	end -- 131
	if targetLine and targetRow then -- 132
		return luaCodes, targetLine, targetRow, lineMap -- 133
	else -- 135
		return nil -- 135
	end -- 132
end -- 115
HttpServer:postSchedule("/check", function(req) -- 137
	do -- 138
		local _type_0 = type(req) -- 138
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 138
		if _tab_0 then -- 138
			local file -- 138
			do -- 138
				local _obj_0 = req.body -- 138
				local _type_1 = type(_obj_0) -- 138
				if "table" == _type_1 or "userdata" == _type_1 then -- 138
					file = _obj_0.file -- 138
				end -- 168
			end -- 168
			local content -- 138
			do -- 138
				local _obj_0 = req.body -- 138
				local _type_1 = type(_obj_0) -- 138
				if "table" == _type_1 or "userdata" == _type_1 then -- 138
					content = _obj_0.content -- 138
				end -- 168
			end -- 168
			if file ~= nil and content ~= nil then -- 138
				local ext = Path:getExt(file) -- 139
				if "tl" == ext then -- 140
					local searchPath = getSearchPath(file) -- 141
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 142
					return { -- 143
						success = success, -- 143
						info = info -- 143
					} -- 143
				elseif "lua" == ext then -- 144
					return luaCheck(file, content) -- 145
				elseif "yue" == ext then -- 146
					local luaCodes, info = yueCheck(file, content) -- 147
					local success = false -- 148
					if luaCodes then -- 149
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 150
						do -- 151
							local _tab_1 = { } -- 151
							local _idx_0 = #_tab_1 + 1 -- 151
							for _index_0 = 1, #info do -- 151
								local _value_0 = info[_index_0] -- 151
								_tab_1[_idx_0] = _value_0 -- 151
								_idx_0 = _idx_0 + 1 -- 151
							end -- 151
							local _idx_1 = #_tab_1 + 1 -- 151
							for _index_0 = 1, #luaInfo do -- 151
								local _value_0 = luaInfo[_index_0] -- 151
								_tab_1[_idx_1] = _value_0 -- 151
								_idx_1 = _idx_1 + 1 -- 151
							end -- 151
							info = _tab_1 -- 151
						end -- 151
						success = success and luaSuccess -- 152
					end -- 149
					if #info > 0 then -- 153
						return { -- 154
							success = success, -- 154
							info = info -- 154
						} -- 154
					else -- 156
						return { -- 156
							success = success -- 156
						} -- 156
					end -- 153
				elseif "xml" == ext then -- 157
					local success, result = xml.check(content) -- 158
					if success then -- 159
						local info -- 160
						success, info = luaCheckWithLineInfo(file, result) -- 160
						if #info > 0 then -- 161
							return { -- 162
								success = success, -- 162
								info = info -- 162
							} -- 162
						else -- 164
							return { -- 164
								success = success -- 164
							} -- 164
						end -- 161
					else -- 166
						local info -- 166
						do -- 166
							local _accum_0 = { } -- 166
							local _len_0 = 1 -- 166
							for _index_0 = 1, #result do -- 166
								local _des_0 = result[_index_0] -- 166
								local row, err = _des_0[1], _des_0[2] -- 166
								_accum_0[_len_0] = { -- 167
									"syntax", -- 167
									file, -- 167
									row, -- 167
									0, -- 167
									err -- 167
								} -- 167
								_len_0 = _len_0 + 1 -- 167
							end -- 167
							info = _accum_0 -- 166
						end -- 167
						return { -- 168
							success = false, -- 168
							info = info -- 168
						} -- 168
					end -- 159
				end -- 168
			end -- 138
		end -- 168
	end -- 168
	return { -- 137
		success = true -- 137
	} -- 168
end) -- 137
local updateInferedDesc -- 170
updateInferedDesc = function(infered) -- 170
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 171
		return -- 171
	end -- 171
	local key, row = infered.key, infered.row -- 172
	do -- 173
		local codes = Content:loadAsync(key) -- 173
		if codes then -- 173
			local comments = { } -- 174
			local line = 0 -- 175
			local skipping = false -- 176
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 177
				line = line + 1 -- 178
				if line >= row then -- 179
					break -- 179
				end -- 179
				if lineCode:match("^%s*%-%- @") then -- 180
					skipping = true -- 181
					goto _continue_0 -- 182
				end -- 180
				do -- 183
					local result = lineCode:match("^%s*%-%- (.+)") -- 183
					if result then -- 183
						if not skipping then -- 184
							comments[#comments + 1] = result -- 184
						end -- 184
					elseif #comments > 0 then -- 185
						comments = { } -- 186
						skipping = false -- 187
					end -- 183
				end -- 183
				::_continue_0:: -- 178
			end -- 187
			infered.doc = table.concat(comments, "\n") -- 188
		end -- 173
	end -- 173
end -- 170
HttpServer:postSchedule("/infer", function(req) -- 190
	do -- 191
		local _type_0 = type(req) -- 191
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 191
		if _tab_0 then -- 191
			local lang -- 191
			do -- 191
				local _obj_0 = req.body -- 191
				local _type_1 = type(_obj_0) -- 191
				if "table" == _type_1 or "userdata" == _type_1 then -- 191
					lang = _obj_0.lang -- 191
				end -- 208
			end -- 208
			local file -- 191
			do -- 191
				local _obj_0 = req.body -- 191
				local _type_1 = type(_obj_0) -- 191
				if "table" == _type_1 or "userdata" == _type_1 then -- 191
					file = _obj_0.file -- 191
				end -- 208
			end -- 208
			local content -- 191
			do -- 191
				local _obj_0 = req.body -- 191
				local _type_1 = type(_obj_0) -- 191
				if "table" == _type_1 or "userdata" == _type_1 then -- 191
					content = _obj_0.content -- 191
				end -- 208
			end -- 208
			local line -- 191
			do -- 191
				local _obj_0 = req.body -- 191
				local _type_1 = type(_obj_0) -- 191
				if "table" == _type_1 or "userdata" == _type_1 then -- 191
					line = _obj_0.line -- 191
				end -- 208
			end -- 208
			local row -- 191
			do -- 191
				local _obj_0 = req.body -- 191
				local _type_1 = type(_obj_0) -- 191
				if "table" == _type_1 or "userdata" == _type_1 then -- 191
					row = _obj_0.row -- 191
				end -- 208
			end -- 208
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 191
				local searchPath = getSearchPath(file) -- 192
				if "tl" == lang or "lua" == lang then -- 193
					local infered = teal.inferAsync(content, line, row, searchPath) -- 194
					if (infered ~= nil) then -- 195
						updateInferedDesc(infered) -- 196
						return { -- 197
							success = true, -- 197
							infered = infered -- 197
						} -- 197
					end -- 195
				elseif "yue" == lang then -- 198
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file) -- 199
					if not luaCodes then -- 200
						return { -- 200
							success = false -- 200
						} -- 200
					end -- 200
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 201
					if (infered ~= nil) then -- 202
						local col -- 203
						file, row, col = infered.file, infered.row, infered.col -- 203
						if file == "" and row > 0 and col > 0 then -- 204
							infered.row = lineMap[row] or 0 -- 205
							infered.col = 0 -- 206
						end -- 204
						updateInferedDesc(infered) -- 207
						return { -- 208
							success = true, -- 208
							infered = infered -- 208
						} -- 208
					end -- 202
				end -- 208
			end -- 191
		end -- 208
	end -- 208
	return { -- 190
		success = false -- 190
	} -- 208
end) -- 190
local getParamDocs -- 210
getParamDocs = function(signatures) -- 210
	do -- 211
		local codes = Content:loadAsync(signatures[1].file) -- 211
		if codes then -- 211
			local comments = { } -- 212
			local params = { } -- 213
			local line = 0 -- 214
			local docs = { } -- 215
			local returnType = nil -- 216
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 217
				line = line + 1 -- 218
				local needBreak = true -- 219
				for i, _des_0 in ipairs(signatures) do -- 220
					local row = _des_0.row -- 220
					if line >= row and not (docs[i] ~= nil) then -- 221
						if #comments > 0 or #params > 0 or returnType then -- 222
							docs[i] = { -- 224
								doc = table.concat(comments, "  \n"), -- 224
								returnType = returnType -- 225
							} -- 223
							if #params > 0 then -- 227
								docs[i].params = params -- 227
							end -- 227
						else -- 229
							docs[i] = false -- 229
						end -- 222
					end -- 221
					if not docs[i] then -- 230
						needBreak = false -- 230
					end -- 230
				end -- 230
				if needBreak then -- 231
					break -- 231
				end -- 231
				do -- 232
					local result = lineCode:match("%s*%-%- (.+)") -- 232
					if result then -- 232
						local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 233
						if not name then -- 234
							name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 235
						end -- 234
						if name then -- 236
							local pname = name -- 237
							if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 238
								pname = pname .. "?" -- 238
							end -- 238
							params[#params + 1] = { -- 240
								name = tostring(pname) .. ": " .. tostring(typ), -- 240
								desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 241
							} -- 239
						else -- 244
							typ = result:match("^@return%s*%(([^%)]-)%)") -- 244
							if typ then -- 244
								if returnType then -- 245
									returnType = returnType .. ", " .. typ -- 246
								else -- 248
									returnType = typ -- 248
								end -- 245
								result = result:gsub("@return", "**return:**") -- 249
							end -- 244
							comments[#comments + 1] = result -- 250
						end -- 236
					elseif #comments > 0 then -- 251
						comments = { } -- 252
						params = { } -- 253
						returnType = nil -- 254
					end -- 232
				end -- 232
			end -- 254
			local results = { } -- 255
			for _index_0 = 1, #docs do -- 256
				local doc = docs[_index_0] -- 256
				if not doc then -- 257
					goto _continue_0 -- 257
				end -- 257
				if doc.params then -- 258
					doc.desc = "function(" .. tostring(table.concat((function() -- 259
						local _accum_0 = { } -- 259
						local _len_0 = 1 -- 259
						local _list_0 = doc.params -- 259
						for _index_1 = 1, #_list_0 do -- 259
							local param = _list_0[_index_1] -- 259
							_accum_0[_len_0] = param.name -- 259
							_len_0 = _len_0 + 1 -- 259
						end -- 259
						return _accum_0 -- 259
					end)(), ', ')) .. ")" -- 259
				else -- 261
					doc.desc = "function()" -- 261
				end -- 258
				if doc.returnType then -- 262
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 263
					doc.returnType = nil -- 264
				end -- 262
				results[#results + 1] = doc -- 265
				::_continue_0:: -- 257
			end -- 265
			if #results > 0 then -- 266
				return results -- 266
			else -- 266
				return nil -- 266
			end -- 266
		end -- 211
	end -- 211
	return nil -- 266
end -- 210
HttpServer:postSchedule("/signature", function(req) -- 268
	do -- 269
		local _type_0 = type(req) -- 269
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 269
		if _tab_0 then -- 269
			local lang -- 269
			do -- 269
				local _obj_0 = req.body -- 269
				local _type_1 = type(_obj_0) -- 269
				if "table" == _type_1 or "userdata" == _type_1 then -- 269
					lang = _obj_0.lang -- 269
				end -- 286
			end -- 286
			local file -- 269
			do -- 269
				local _obj_0 = req.body -- 269
				local _type_1 = type(_obj_0) -- 269
				if "table" == _type_1 or "userdata" == _type_1 then -- 269
					file = _obj_0.file -- 269
				end -- 286
			end -- 286
			local content -- 269
			do -- 269
				local _obj_0 = req.body -- 269
				local _type_1 = type(_obj_0) -- 269
				if "table" == _type_1 or "userdata" == _type_1 then -- 269
					content = _obj_0.content -- 269
				end -- 286
			end -- 286
			local line -- 269
			do -- 269
				local _obj_0 = req.body -- 269
				local _type_1 = type(_obj_0) -- 269
				if "table" == _type_1 or "userdata" == _type_1 then -- 269
					line = _obj_0.line -- 269
				end -- 286
			end -- 286
			local row -- 269
			do -- 269
				local _obj_0 = req.body -- 269
				local _type_1 = type(_obj_0) -- 269
				if "table" == _type_1 or "userdata" == _type_1 then -- 269
					row = _obj_0.row -- 269
				end -- 286
			end -- 286
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 269
				local searchPath = getSearchPath(file) -- 270
				if "tl" == lang or "lua" == lang then -- 271
					do -- 272
						local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 272
						if signatures then -- 272
							signatures = getParamDocs(signatures) -- 273
							if signatures then -- 273
								return { -- 274
									success = true, -- 274
									signatures = signatures -- 274
								} -- 274
							end -- 273
						end -- 272
					end -- 272
				elseif "yue" == lang then -- 275
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file) -- 276
					if not luaCodes then -- 277
						return { -- 277
							success = false -- 277
						} -- 277
					end -- 277
					do -- 278
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 278
						if chainOp then -- 278
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 279
							targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 280
						end -- 278
					end -- 278
					do -- 281
						local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 281
						if signatures then -- 281
							signatures = getParamDocs(signatures) -- 282
							if signatures then -- 282
								return { -- 283
									success = true, -- 283
									signatures = signatures -- 283
								} -- 283
							end -- 282
						else -- 284
							signatures = teal.getSignatureAsync(luaCodes, "dora." .. tostring(targetLine), targetRow, searchPath) -- 284
							if signatures then -- 284
								signatures = getParamDocs(signatures) -- 285
								if signatures then -- 285
									return { -- 286
										success = true, -- 286
										signatures = signatures -- 286
									} -- 286
								end -- 285
							end -- 284
						end -- 281
					end -- 281
				end -- 286
			end -- 269
		end -- 286
	end -- 286
	return { -- 268
		success = false -- 268
	} -- 286
end) -- 268
local luaKeywords = { -- 289
	'and', -- 289
	'break', -- 290
	'do', -- 291
	'else', -- 292
	'elseif', -- 293
	'end', -- 294
	'false', -- 295
	'for', -- 296
	'function', -- 297
	'goto', -- 298
	'if', -- 299
	'in', -- 300
	'local', -- 301
	'nil', -- 302
	'not', -- 303
	'or', -- 304
	'repeat', -- 305
	'return', -- 306
	'then', -- 307
	'true', -- 308
	'until', -- 309
	'while' -- 310
} -- 288
local tealKeywords = { -- 314
	'record', -- 314
	'as', -- 315
	'is', -- 316
	'type', -- 317
	'embed', -- 318
	'enum', -- 319
	'global', -- 320
	'any', -- 321
	'boolean', -- 322
	'integer', -- 323
	'number', -- 324
	'string', -- 325
	'thread' -- 326
} -- 313
local yueKeywords = { -- 330
	"and", -- 330
	"break", -- 331
	"do", -- 332
	"else", -- 333
	"elseif", -- 334
	"false", -- 335
	"for", -- 336
	"goto", -- 337
	"if", -- 338
	"in", -- 339
	"local", -- 340
	"nil", -- 341
	"not", -- 342
	"or", -- 343
	"repeat", -- 344
	"return", -- 345
	"then", -- 346
	"true", -- 347
	"until", -- 348
	"while", -- 349
	"as", -- 350
	"class", -- 351
	"continue", -- 352
	"export", -- 353
	"extends", -- 354
	"from", -- 355
	"global", -- 356
	"import", -- 357
	"macro", -- 358
	"switch", -- 359
	"try", -- 360
	"unless", -- 361
	"using", -- 362
	"when", -- 363
	"with" -- 364
} -- 329
HttpServer:postSchedule("/complete", function(req) -- 367
	do -- 368
		local _type_0 = type(req) -- 368
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 368
		if _tab_0 then -- 368
			local lang -- 368
			do -- 368
				local _obj_0 = req.body -- 368
				local _type_1 = type(_obj_0) -- 368
				if "table" == _type_1 or "userdata" == _type_1 then -- 368
					lang = _obj_0.lang -- 368
				end -- 475
			end -- 475
			local file -- 368
			do -- 368
				local _obj_0 = req.body -- 368
				local _type_1 = type(_obj_0) -- 368
				if "table" == _type_1 or "userdata" == _type_1 then -- 368
					file = _obj_0.file -- 368
				end -- 475
			end -- 475
			local content -- 368
			do -- 368
				local _obj_0 = req.body -- 368
				local _type_1 = type(_obj_0) -- 368
				if "table" == _type_1 or "userdata" == _type_1 then -- 368
					content = _obj_0.content -- 368
				end -- 475
			end -- 475
			local line -- 368
			do -- 368
				local _obj_0 = req.body -- 368
				local _type_1 = type(_obj_0) -- 368
				if "table" == _type_1 or "userdata" == _type_1 then -- 368
					line = _obj_0.line -- 368
				end -- 475
			end -- 475
			local row -- 368
			do -- 368
				local _obj_0 = req.body -- 368
				local _type_1 = type(_obj_0) -- 368
				if "table" == _type_1 or "userdata" == _type_1 then -- 368
					row = _obj_0.row -- 368
				end -- 475
			end -- 475
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 368
				local searchPath = getSearchPath(file) -- 369
				repeat -- 370
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 371
					if lang == "yue" then -- 372
						if not item then -- 373
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 373
						end -- 373
						if not item then -- 374
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 374
						end -- 374
					end -- 372
					local searchType = nil -- 375
					if not item then -- 376
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 377
						if lang == "yue" then -- 378
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 379
						end -- 378
						if (item ~= nil) then -- 380
							searchType = "Image" -- 380
						end -- 380
					end -- 376
					if not item then -- 381
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 382
						if lang == "yue" then -- 383
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 384
						end -- 383
						if (item ~= nil) then -- 385
							searchType = "Font" -- 385
						end -- 385
					end -- 381
					if not item then -- 386
						break -- 386
					end -- 386
					local searchPaths = Content.searchPaths -- 387
					local _list_0 = getSearchFolders(file) -- 388
					for _index_0 = 1, #_list_0 do -- 388
						local folder = _list_0[_index_0] -- 388
						searchPaths[#searchPaths + 1] = folder -- 389
					end -- 389
					if searchType then -- 390
						searchPaths[#searchPaths + 1] = Content.assetPath -- 390
					end -- 390
					local tokens -- 391
					do -- 391
						local _accum_0 = { } -- 391
						local _len_0 = 1 -- 391
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 391
							_accum_0[_len_0] = mod -- 391
							_len_0 = _len_0 + 1 -- 391
						end -- 391
						tokens = _accum_0 -- 391
					end -- 391
					local suggestions = { } -- 392
					for _index_0 = 1, #searchPaths do -- 393
						local path = searchPaths[_index_0] -- 393
						local sPath = Path(path, table.unpack(tokens)) -- 394
						if not Content:exist(sPath) then -- 395
							goto _continue_0 -- 395
						end -- 395
						if searchType == "Font" then -- 396
							local fontPath = Path(sPath, "Font") -- 397
							if Content:exist(fontPath) then -- 398
								local _list_1 = Content:getFiles(fontPath) -- 399
								for _index_1 = 1, #_list_1 do -- 399
									local f = _list_1[_index_1] -- 399
									if (function() -- 400
										local _val_0 = Path:getExt(f) -- 400
										return "ttf" == _val_0 or "otf" == _val_0 -- 400
									end)() then -- 400
										if "." == f:sub(1, 1) then -- 401
											goto _continue_1 -- 401
										end -- 401
										suggestions[#suggestions + 1] = { -- 402
											Path:getName(f), -- 402
											"font", -- 402
											"field" -- 402
										} -- 402
									end -- 400
									::_continue_1:: -- 400
								end -- 402
							end -- 398
						end -- 396
						local _list_1 = Content:getFiles(sPath) -- 403
						for _index_1 = 1, #_list_1 do -- 403
							local f = _list_1[_index_1] -- 403
							if "Image" == searchType then -- 404
								do -- 405
									local _exp_0 = Path:getExt(f) -- 405
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 405
										if "." == f:sub(1, 1) then -- 406
											goto _continue_2 -- 406
										end -- 406
										suggestions[#suggestions + 1] = { -- 407
											f, -- 407
											"image", -- 407
											"field" -- 407
										} -- 407
									end -- 407
								end -- 407
								goto _continue_2 -- 408
							elseif "Font" == searchType then -- 409
								do -- 410
									local _exp_0 = Path:getExt(f) -- 410
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 410
										if "." == f:sub(1, 1) then -- 411
											goto _continue_2 -- 411
										end -- 411
										suggestions[#suggestions + 1] = { -- 412
											f, -- 412
											"font", -- 412
											"field" -- 412
										} -- 412
									end -- 412
								end -- 412
								goto _continue_2 -- 413
							end -- 413
							do -- 414
								local _exp_0 = Path:getExt(f) -- 414
								if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 414
									local name = Path:getName(f) -- 415
									if "d" == Path:getExt(name) then -- 416
										goto _continue_2 -- 416
									end -- 416
									if "." == name:sub(1, 1) then -- 417
										goto _continue_2 -- 417
									end -- 417
									suggestions[#suggestions + 1] = { -- 418
										name, -- 418
										"module", -- 418
										"field" -- 418
									} -- 418
								end -- 418
							end -- 418
							::_continue_2:: -- 404
						end -- 418
						local _list_2 = Content:getDirs(sPath) -- 419
						for _index_1 = 1, #_list_2 do -- 419
							local dir = _list_2[_index_1] -- 419
							if "." == dir:sub(1, 1) then -- 420
								goto _continue_3 -- 420
							end -- 420
							suggestions[#suggestions + 1] = { -- 421
								dir, -- 421
								"folder", -- 421
								"variable" -- 421
							} -- 421
							::_continue_3:: -- 420
						end -- 421
						::_continue_0:: -- 394
					end -- 421
					if item == "" and not searchType then -- 422
						local _list_1 = teal.completeAsync("", "dora.", 1, searchPath) -- 423
						for _index_0 = 1, #_list_1 do -- 423
							local _des_0 = _list_1[_index_0] -- 423
							local name = _des_0[1] -- 423
							suggestions[#suggestions + 1] = { -- 424
								name, -- 424
								"dora module", -- 424
								"function" -- 424
							} -- 424
						end -- 424
					end -- 422
					if #suggestions > 0 then -- 425
						do -- 426
							local _accum_0 = { } -- 426
							local _len_0 = 1 -- 426
							for _, v in pairs((function() -- 426
								local _tbl_0 = { } -- 426
								for _index_0 = 1, #suggestions do -- 426
									local item = suggestions[_index_0] -- 426
									_tbl_0[item[1] .. item[2]] = item -- 426
								end -- 426
								return _tbl_0 -- 426
							end)()) do -- 426
								_accum_0[_len_0] = v -- 426
								_len_0 = _len_0 + 1 -- 426
							end -- 426
							suggestions = _accum_0 -- 426
						end -- 426
						return { -- 427
							success = true, -- 427
							suggestions = suggestions -- 427
						} -- 427
					else -- 429
						return { -- 429
							success = false -- 429
						} -- 429
					end -- 425
				until true -- 430
				if "tl" == lang or "lua" == lang then -- 431
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 432
					if not line:match("[%.:][%w_]+[%.:]?$") and not line:match("[%w_]+[%.:]$") then -- 433
						local checkSet -- 434
						do -- 434
							local _tbl_0 = { } -- 434
							for _index_0 = 1, #suggestions do -- 434
								local _des_0 = suggestions[_index_0] -- 434
								local name = _des_0[1] -- 434
								_tbl_0[name] = true -- 434
							end -- 434
							checkSet = _tbl_0 -- 434
						end -- 434
						local _list_0 = teal.completeAsync("", "dora.", 1, searchPath) -- 435
						for _index_0 = 1, #_list_0 do -- 435
							local item = _list_0[_index_0] -- 435
							if not checkSet[item[1]] then -- 436
								suggestions[#suggestions + 1] = item -- 436
							end -- 436
						end -- 436
						for _index_0 = 1, #luaKeywords do -- 437
							local word = luaKeywords[_index_0] -- 437
							suggestions[#suggestions + 1] = { -- 438
								word, -- 438
								"keyword", -- 438
								"keyword" -- 438
							} -- 438
						end -- 438
						if lang == "tl" then -- 439
							for _index_0 = 1, #tealKeywords do -- 440
								local word = tealKeywords[_index_0] -- 440
								suggestions[#suggestions + 1] = { -- 441
									word, -- 441
									"keyword", -- 441
									"keyword" -- 441
								} -- 441
							end -- 441
						end -- 439
					end -- 433
					if #suggestions > 0 then -- 442
						return { -- 443
							success = true, -- 443
							suggestions = suggestions -- 443
						} -- 443
					end -- 442
				elseif "yue" == lang then -- 444
					local suggestions = { } -- 445
					local gotGlobals = false -- 446
					do -- 447
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file) -- 447
						if luaCodes then -- 447
							gotGlobals = true -- 448
							do -- 449
								local chainOp = line:match("[^%w_]([%.\\])$") -- 449
								if chainOp then -- 449
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 450
									if not withVar then -- 451
										return { -- 451
											success = false -- 451
										} -- 451
									end -- 451
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 452
								elseif line:match("^([%.\\])$") then -- 453
									return { -- 454
										success = false -- 454
									} -- 454
								end -- 449
							end -- 449
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 455
							for _index_0 = 1, #_list_0 do -- 455
								local item = _list_0[_index_0] -- 455
								suggestions[#suggestions + 1] = item -- 455
							end -- 455
							if #suggestions == 0 then -- 456
								local _list_1 = teal.completeAsync(luaCodes, "dora." .. tostring(targetLine), targetRow, searchPath) -- 457
								for _index_0 = 1, #_list_1 do -- 457
									local item = _list_1[_index_0] -- 457
									suggestions[#suggestions + 1] = item -- 457
								end -- 457
							end -- 456
						end -- 447
					end -- 447
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 458
						local checkSet -- 459
						do -- 459
							local _tbl_0 = { } -- 459
							for _index_0 = 1, #suggestions do -- 459
								local _des_0 = suggestions[_index_0] -- 459
								local name = _des_0[1] -- 459
								_tbl_0[name] = true -- 459
							end -- 459
							checkSet = _tbl_0 -- 459
						end -- 459
						local _list_0 = teal.completeAsync("", "dora.", 1, searchPath) -- 460
						for _index_0 = 1, #_list_0 do -- 460
							local item = _list_0[_index_0] -- 460
							if not checkSet[item[1]] then -- 461
								suggestions[#suggestions + 1] = item -- 461
							end -- 461
						end -- 461
						if not gotGlobals then -- 462
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 463
							for _index_0 = 1, #_list_1 do -- 463
								local item = _list_1[_index_0] -- 463
								if not checkSet[item[1]] then -- 464
									suggestions[#suggestions + 1] = item -- 464
								end -- 464
							end -- 464
						end -- 462
						for _index_0 = 1, #yueKeywords do -- 465
							local word = yueKeywords[_index_0] -- 465
							if not checkSet[word] then -- 466
								suggestions[#suggestions + 1] = { -- 467
									word, -- 467
									"keyword", -- 467
									"keyword" -- 467
								} -- 467
							end -- 466
						end -- 467
					end -- 458
					if #suggestions > 0 then -- 468
						return { -- 469
							success = true, -- 469
							suggestions = suggestions -- 469
						} -- 469
					end -- 468
				elseif "xml" == lang then -- 470
					local items = xml.complete(content) -- 471
					if #items > 0 then -- 472
						local suggestions -- 473
						do -- 473
							local _accum_0 = { } -- 473
							local _len_0 = 1 -- 473
							for _index_0 = 1, #items do -- 473
								local _des_0 = items[_index_0] -- 473
								local label, insertText = _des_0[1], _des_0[2] -- 473
								_accum_0[_len_0] = { -- 474
									label, -- 474
									insertText, -- 474
									"field" -- 474
								} -- 474
								_len_0 = _len_0 + 1 -- 474
							end -- 474
							suggestions = _accum_0 -- 473
						end -- 474
						return { -- 475
							success = true, -- 475
							suggestions = suggestions -- 475
						} -- 475
					end -- 472
				end -- 475
			end -- 368
		end -- 475
	end -- 475
	return { -- 367
		success = false -- 367
	} -- 475
end) -- 367
HttpServer:upload("/upload", function(req, filename) -- 479
	do -- 480
		local _type_0 = type(req) -- 480
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 480
		if _tab_0 then -- 480
			local path -- 480
			do -- 480
				local _obj_0 = req.params -- 480
				local _type_1 = type(_obj_0) -- 480
				if "table" == _type_1 or "userdata" == _type_1 then -- 480
					path = _obj_0.path -- 480
				end -- 486
			end -- 486
			if path ~= nil then -- 480
				local uploadPath = Path(Content.writablePath, ".upload") -- 481
				if not Content:exist(uploadPath) then -- 482
					Content:mkdir(uploadPath) -- 483
				end -- 482
				local targetPath = Path(uploadPath, filename) -- 484
				Content:mkdir(Path:getPath(targetPath)) -- 485
				return targetPath -- 486
			end -- 480
		end -- 486
	end -- 486
	return nil -- 486
end, function(req, file) -- 487
	do -- 488
		local _type_0 = type(req) -- 488
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 488
		if _tab_0 then -- 488
			local path -- 488
			do -- 488
				local _obj_0 = req.params -- 488
				local _type_1 = type(_obj_0) -- 488
				if "table" == _type_1 or "userdata" == _type_1 then -- 488
					path = _obj_0.path -- 488
				end -- 493
			end -- 493
			if path ~= nil then -- 488
				local uploadPath = Path(Content.writablePath, ".upload") -- 489
				local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 490
				Content:mkdir(Path:getPath(targetPath)) -- 491
				if Content:move(file, targetPath) then -- 492
					return true -- 493
				end -- 492
			end -- 488
		end -- 493
	end -- 493
	return false -- 493
end) -- 477
HttpServer:post("/list", function(req) -- 496
	do -- 497
		local _type_0 = type(req) -- 497
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 497
		if _tab_0 then -- 497
			local path -- 497
			do -- 497
				local _obj_0 = req.body -- 497
				local _type_1 = type(_obj_0) -- 497
				if "table" == _type_1 or "userdata" == _type_1 then -- 497
					path = _obj_0.path -- 497
				end -- 519
			end -- 519
			if path ~= nil then -- 497
				if Content:exist(path) then -- 498
					local files = { } -- 499
					local visitAssets -- 500
					visitAssets = function(path, folder) -- 500
						local dirs = Content:getDirs(path) -- 501
						for _index_0 = 1, #dirs do -- 502
							local dir = dirs[_index_0] -- 502
							if dir:match("^%.") then -- 503
								goto _continue_0 -- 503
							end -- 503
							local current -- 504
							if folder == "" then -- 504
								current = dir -- 505
							else -- 507
								current = Path(folder, dir) -- 507
							end -- 504
							files[#files + 1] = current -- 508
							visitAssets(Path(path, dir), current) -- 509
							::_continue_0:: -- 503
						end -- 509
						local fs = Content:getFiles(path) -- 510
						for _index_0 = 1, #fs do -- 511
							local f = fs[_index_0] -- 511
							if f:match("^%.") then -- 512
								goto _continue_1 -- 512
							end -- 512
							if folder == "" then -- 513
								files[#files + 1] = f -- 514
							else -- 516
								files[#files + 1] = Path(folder, f) -- 516
							end -- 513
							::_continue_1:: -- 512
						end -- 516
					end -- 500
					visitAssets(path, "") -- 517
					if #files == 0 then -- 518
						files = nil -- 518
					end -- 518
					return { -- 519
						success = true, -- 519
						files = files -- 519
					} -- 519
				end -- 498
			end -- 497
		end -- 519
	end -- 519
	return { -- 496
		success = false -- 496
	} -- 519
end) -- 496
HttpServer:post("/info", function() -- 521
	return { -- 522
		platform = App.platform, -- 522
		locale = App.locale, -- 523
		version = App.version -- 524
	} -- 524
end) -- 521
HttpServer:post("/new", function(req) -- 526
	do -- 527
		local _type_0 = type(req) -- 527
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 527
		if _tab_0 then -- 527
			local path -- 527
			do -- 527
				local _obj_0 = req.body -- 527
				local _type_1 = type(_obj_0) -- 527
				if "table" == _type_1 or "userdata" == _type_1 then -- 527
					path = _obj_0.path -- 527
				end -- 539
			end -- 539
			local content -- 527
			do -- 527
				local _obj_0 = req.body -- 527
				local _type_1 = type(_obj_0) -- 527
				if "table" == _type_1 or "userdata" == _type_1 then -- 527
					content = _obj_0.content -- 527
				end -- 539
			end -- 539
			if path ~= nil and content ~= nil then -- 527
				if not Content:exist(path) then -- 528
					local parent = Path:getPath(path) -- 529
					local files = Content:getFiles(parent) -- 530
					local name = Path:getName(path):lower() -- 531
					for _index_0 = 1, #files do -- 532
						local file = files[_index_0] -- 532
						if name == Path:getName(file):lower() then -- 533
							return { -- 534
								success = false -- 534
							} -- 534
						end -- 533
					end -- 534
					if "" == Path:getExt(path) then -- 535
						if Content:mkdir(path) then -- 536
							return { -- 537
								success = true -- 537
							} -- 537
						end -- 536
					elseif Content:save(path, content) then -- 538
						return { -- 539
							success = true -- 539
						} -- 539
					end -- 535
				end -- 528
			end -- 527
		end -- 539
	end -- 539
	return { -- 526
		success = false -- 526
	} -- 539
end) -- 526
HttpServer:post("/delete", function(req) -- 541
	do -- 542
		local _type_0 = type(req) -- 542
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 542
		if _tab_0 then -- 542
			local path -- 542
			do -- 542
				local _obj_0 = req.body -- 542
				local _type_1 = type(_obj_0) -- 542
				if "table" == _type_1 or "userdata" == _type_1 then -- 542
					path = _obj_0.path -- 542
				end -- 555
			end -- 555
			if path ~= nil then -- 542
				if Content:exist(path) then -- 543
					local parent = Path:getPath(path) -- 544
					local files = Content:getFiles(parent) -- 545
					local name = Path:getName(path):lower() -- 546
					local ext = Path:getExt(path) -- 547
					for _index_0 = 1, #files do -- 548
						local file = files[_index_0] -- 548
						if name == Path:getName(file):lower() then -- 549
							do -- 550
								local _exp_0 = Path:getExt(file) -- 550
								if "tl" == _exp_0 then -- 550
									if ("vs" == ext) then -- 550
										Content:remove(Path(parent, file)) -- 551
									end -- 550
								elseif "lua" == _exp_0 then -- 552
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 552
										Content:remove(Path(parent, file)) -- 553
									end -- 552
								end -- 553
							end -- 553
						end -- 549
					end -- 553
					if Content:remove(path) then -- 554
						return { -- 555
							success = true -- 555
						} -- 555
					end -- 554
				end -- 543
			end -- 542
		end -- 555
	end -- 555
	return { -- 541
		success = false -- 541
	} -- 555
end) -- 541
HttpServer:post("/rename", function(req) -- 557
	do -- 558
		local _type_0 = type(req) -- 558
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 558
		if _tab_0 then -- 558
			local old -- 558
			do -- 558
				local _obj_0 = req.body -- 558
				local _type_1 = type(_obj_0) -- 558
				if "table" == _type_1 or "userdata" == _type_1 then -- 558
					old = _obj_0.old -- 558
				end -- 580
			end -- 580
			local new -- 558
			do -- 558
				local _obj_0 = req.body -- 558
				local _type_1 = type(_obj_0) -- 558
				if "table" == _type_1 or "userdata" == _type_1 then -- 558
					new = _obj_0.new -- 558
				end -- 580
			end -- 580
			if old ~= nil and new ~= nil then -- 558
				if Content:exist(old) and not Content:exist(new) then -- 559
					local parent = Path:getPath(new) -- 560
					local files = Content:getFiles(parent) -- 561
					local name = Path:getName(new):lower() -- 562
					for _index_0 = 1, #files do -- 563
						local file = files[_index_0] -- 563
						if name == Path:getName(file):lower() then -- 564
							return { -- 565
								success = false -- 565
							} -- 565
						end -- 564
					end -- 565
					if Content:move(old, new) then -- 566
						local newParent = Path:getPath(new) -- 567
						parent = Path:getPath(old) -- 568
						files = Content:getFiles(parent) -- 569
						local newName = Path:getName(new) -- 570
						local oldName = Path:getName(old) -- 571
						name = oldName:lower() -- 572
						local ext = Path:getExt(old) -- 573
						for _index_0 = 1, #files do -- 574
							local file = files[_index_0] -- 574
							if name == Path:getName(file):lower() then -- 575
								do -- 576
									local _exp_0 = Path:getExt(file) -- 576
									if "tl" == _exp_0 then -- 576
										if ("vs" == ext) then -- 576
											Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 577
										end -- 576
									elseif "lua" == _exp_0 then -- 578
										if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 578
											Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 579
										end -- 578
									end -- 579
								end -- 579
							end -- 575
						end -- 579
						return { -- 580
							success = true -- 580
						} -- 580
					end -- 566
				end -- 559
			end -- 558
		end -- 580
	end -- 580
	return { -- 557
		success = false -- 557
	} -- 580
end) -- 557
HttpServer:postSchedule("/read", function(req) -- 582
	do -- 583
		local _type_0 = type(req) -- 583
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 583
		if _tab_0 then -- 583
			local path -- 583
			do -- 583
				local _obj_0 = req.body -- 583
				local _type_1 = type(_obj_0) -- 583
				if "table" == _type_1 or "userdata" == _type_1 then -- 583
					path = _obj_0.path -- 583
				end -- 586
			end -- 586
			if path ~= nil then -- 583
				if Content:exist(path) then -- 584
					do -- 585
						local content = Content:loadAsync(path) -- 585
						if content then -- 585
							return { -- 586
								content = content, -- 586
								success = true -- 586
							} -- 586
						end -- 585
					end -- 585
				end -- 584
			end -- 583
		end -- 586
	end -- 586
	return { -- 582
		success = false -- 582
	} -- 586
end) -- 582
local compileFileAsync -- 588
compileFileAsync = function(inputFile, sourceCodes) -- 588
	local file = Path:getFilename(inputFile) -- 589
	local searchPath -- 590
	do -- 590
		local dir = getProjectDirFromFile(inputFile) -- 590
		if dir then -- 590
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 591
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 592
		else -- 593
			searchPath = "" -- 593
		end -- 590
	end -- 590
	local outputFile = Path:replaceExt(inputFile, "lua") -- 594
	local yueext = yue.options.extension -- 595
	local resultCodes = nil -- 596
	do -- 597
		local _exp_0 = Path:getExt(inputFile) -- 597
		if yueext == _exp_0 then -- 597
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 598
				if not codes then -- 599
					return -- 599
				end -- 599
				local success, result = LintYueGlobals(codes, globals) -- 600
				if not success then -- 601
					return -- 601
				end -- 601
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 602
				codes = codes:gsub("^\n*", "") -- 603
				if not (result == "") then -- 604
					result = result .. "\n" -- 604
				end -- 604
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 605
				return resultCodes -- 606
			end, function(success) -- 598
				if not success then -- 607
					Content:remove(outputFile) -- 608
					resultCodes = false -- 609
				end -- 607
			end) -- 598
		elseif "tl" == _exp_0 then -- 610
			do -- 611
				local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 611
				if codes then -- 611
					resultCodes = codes -- 612
					Content:saveAsync(outputFile, codes) -- 613
				else -- 615
					Content:remove(outputFile) -- 615
					resultCodes = false -- 616
				end -- 611
			end -- 611
		elseif "xml" == _exp_0 then -- 617
			do -- 618
				local codes = xml.tolua(sourceCodes) -- 618
				if codes then -- 618
					resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 619
					Content:saveAsync(outputFile, resultCodes) -- 620
				else -- 622
					Content:remove(outputFile) -- 622
					resultCodes = false -- 623
				end -- 618
			end -- 618
		end -- 623
	end -- 623
	wait(function() -- 624
		return resultCodes ~= nil -- 624
	end) -- 624
	if resultCodes then -- 625
		return resultCodes -- 625
	end -- 625
	return nil -- 625
end -- 588
HttpServer:postSchedule("/write", function(req) -- 627
	do -- 628
		local _type_0 = type(req) -- 628
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 628
		if _tab_0 then -- 628
			local path -- 628
			do -- 628
				local _obj_0 = req.body -- 628
				local _type_1 = type(_obj_0) -- 628
				if "table" == _type_1 or "userdata" == _type_1 then -- 628
					path = _obj_0.path -- 628
				end -- 634
			end -- 634
			local content -- 628
			do -- 628
				local _obj_0 = req.body -- 628
				local _type_1 = type(_obj_0) -- 628
				if "table" == _type_1 or "userdata" == _type_1 then -- 628
					content = _obj_0.content -- 628
				end -- 634
			end -- 634
			if path ~= nil and content ~= nil then -- 628
				if Content:saveAsync(path, content) then -- 629
					do -- 630
						local _exp_0 = Path:getExt(path) -- 630
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 630
							if '' == Path:getExt(Path:getName(path)) then -- 631
								local resultCodes = compileFileAsync(path, content) -- 632
								return { -- 633
									success = true, -- 633
									resultCodes = resultCodes -- 633
								} -- 633
							end -- 631
						end -- 633
					end -- 633
					return { -- 634
						success = true -- 634
					} -- 634
				end -- 629
			end -- 628
		end -- 634
	end -- 634
	return { -- 627
		success = false -- 627
	} -- 634
end) -- 627
local extentionLevels = { -- 637
	vs = 2, -- 637
	ts = 1, -- 638
	tsx = 1, -- 639
	tl = 1, -- 640
	yue = 1, -- 641
	xml = 1, -- 642
	lua = 0 -- 643
} -- 636
HttpServer:post("/assets", function() -- 645
	local visitAssets -- 646
	visitAssets = function(path, root) -- 646
		local children = nil -- 647
		local dirs = Content:getDirs(path) -- 648
		for _index_0 = 1, #dirs do -- 649
			local dir = dirs[_index_0] -- 649
			if root then -- 650
				if ".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir then -- 650
					goto _continue_0 -- 651
				end -- 651
			elseif dir == ".git" then -- 652
				goto _continue_0 -- 653
			end -- 650
			if not children then -- 654
				children = { } -- 654
			end -- 654
			children[#children + 1] = visitAssets(Path(path, dir)) -- 655
			::_continue_0:: -- 650
		end -- 655
		local files = Content:getFiles(path) -- 656
		local names = { } -- 657
		for _index_0 = 1, #files do -- 658
			local file = files[_index_0] -- 658
			if file:match("^%.") then -- 659
				goto _continue_1 -- 659
			end -- 659
			local name = Path:getName(file) -- 660
			do -- 661
				local ext = names[name] -- 661
				if ext then -- 661
					local lv1 -- 662
					do -- 662
						local _exp_0 = extentionLevels[ext] -- 662
						if _exp_0 ~= nil then -- 662
							lv1 = _exp_0 -- 662
						else -- 662
							lv1 = -1 -- 662
						end -- 662
					end -- 662
					ext = Path:getExt(file) -- 663
					local lv2 -- 664
					do -- 664
						local _exp_0 = extentionLevels[ext] -- 664
						if _exp_0 ~= nil then -- 664
							lv2 = _exp_0 -- 664
						else -- 664
							lv2 = -1 -- 664
						end -- 664
					end -- 664
					if lv2 > lv1 then -- 665
						names[name] = ext -- 665
					end -- 665
				else -- 667
					ext = Path:getExt(file) -- 667
					if not extentionLevels[ext] then -- 668
						names[file] = "" -- 669
					else -- 671
						names[name] = ext -- 671
					end -- 668
				end -- 661
			end -- 661
			::_continue_1:: -- 659
		end -- 671
		do -- 672
			local _accum_0 = { } -- 672
			local _len_0 = 1 -- 672
			for name, ext in pairs(names) do -- 672
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 672
				_len_0 = _len_0 + 1 -- 672
			end -- 672
			files = _accum_0 -- 672
		end -- 672
		for _index_0 = 1, #files do -- 673
			local file = files[_index_0] -- 673
			if not children then -- 674
				children = { } -- 674
			end -- 674
			children[#children + 1] = { -- 676
				key = Path(path, file), -- 676
				dir = false, -- 677
				title = file -- 678
			} -- 675
		end -- 679
		if children then -- 680
			table.sort(children, function(a, b) -- 681
				if a.dir == b.dir then -- 682
					return a.title < b.title -- 683
				else -- 685
					return a.dir -- 685
				end -- 682
			end) -- 681
		end -- 680
		local title = Path:getFilename(path) -- 686
		if title == "" then -- 687
			return children -- 688
		else -- 690
			return { -- 691
				key = path, -- 691
				dir = true, -- 692
				title = title, -- 693
				children = children -- 694
			} -- 695
		end -- 687
	end -- 646
	local zh = (App.locale:match("^zh") ~= nil) -- 696
	return { -- 698
		key = Content.writablePath, -- 698
		dir = true, -- 699
		title = "Assets", -- 700
		children = (function() -- 702
			local _tab_0 = { -- 702
				{ -- 703
					key = Path(Content.assetPath), -- 703
					dir = true, -- 704
					title = zh and "内置资源" or "Built-in", -- 705
					children = { -- 707
						(function() -- 707
							local _with_0 = visitAssets(Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")) -- 707
							_with_0.title = zh and "说明文档" or "Readme" -- 708
							return _with_0 -- 707
						end)(), -- 707
						(function() -- 709
							local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")) -- 709
							_with_0.title = zh and "接口文档" or "API Doc" -- 710
							return _with_0 -- 709
						end)(), -- 709
						(function() -- 711
							local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Example")) -- 711
							_with_0.title = zh and "代码示例" or "Example" -- 712
							return _with_0 -- 711
						end)(), -- 711
						(function() -- 713
							local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Test")) -- 713
							_with_0.title = zh and "功能测试" or "Test" -- 714
							return _with_0 -- 713
						end)(), -- 713
						visitAssets(Path(Content.assetPath, "Image")), -- 715
						visitAssets(Path(Content.assetPath, "Spine")), -- 716
						visitAssets(Path(Content.assetPath, "Font")) -- 717
					} -- 706
				} -- 702
			} -- 720
			local _obj_0 = visitAssets(Content.writablePath, true) -- 720
			local _idx_0 = #_tab_0 + 1 -- 720
			for _index_0 = 1, #_obj_0 do -- 720
				local _value_0 = _obj_0[_index_0] -- 720
				_tab_0[_idx_0] = _value_0 -- 720
				_idx_0 = _idx_0 + 1 -- 720
			end -- 720
			return _tab_0 -- 719
		end)() -- 701
	} -- 722
end) -- 645
HttpServer:postSchedule("/run", function(req) -- 724
	do -- 725
		local _type_0 = type(req) -- 725
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 725
		if _tab_0 then -- 725
			local file -- 725
			do -- 725
				local _obj_0 = req.body -- 725
				local _type_1 = type(_obj_0) -- 725
				if "table" == _type_1 or "userdata" == _type_1 then -- 725
					file = _obj_0.file -- 725
				end -- 737
			end -- 737
			local asProj -- 725
			do -- 725
				local _obj_0 = req.body -- 725
				local _type_1 = type(_obj_0) -- 725
				if "table" == _type_1 or "userdata" == _type_1 then -- 725
					asProj = _obj_0.asProj -- 725
				end -- 737
			end -- 737
			if file ~= nil and asProj ~= nil then -- 725
				local Entry = require("Dev.Entry") -- 726
				if asProj then -- 727
					do -- 728
						local proj = getProjectDirFromFile(file) -- 728
						if proj then -- 728
							Entry.allClear() -- 729
							local target = Path(proj, "init") -- 730
							local success, err = Entry.enterEntryAsync({ -- 731
								"Project", -- 731
								target -- 731
							}) -- 731
							target = Path:getName(Path:getPath(target)) -- 732
							return { -- 733
								success = success, -- 733
								target = target, -- 733
								err = err -- 733
							} -- 733
						end -- 728
					end -- 728
				end -- 727
				Entry.allClear() -- 734
				file = Path:replaceExt(file, "") -- 735
				local success, err = Entry.enterEntryAsync({ -- 736
					Path:getName(file), -- 736
					file -- 736
				}) -- 736
				return { -- 737
					success = success, -- 737
					err = err -- 737
				} -- 737
			end -- 725
		end -- 737
	end -- 737
	return { -- 724
		success = false -- 724
	} -- 737
end) -- 724
HttpServer:postSchedule("/stop", function() -- 739
	local Entry = require("Dev.Entry") -- 740
	return { -- 741
		success = Entry.stop() -- 741
	} -- 741
end) -- 739
HttpServer:postSchedule("/zip", function(req) -- 743
	do -- 744
		local _type_0 = type(req) -- 744
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 744
		if _tab_0 then -- 744
			local path -- 744
			do -- 744
				local _obj_0 = req.body -- 744
				local _type_1 = type(_obj_0) -- 744
				if "table" == _type_1 or "userdata" == _type_1 then -- 744
					path = _obj_0.path -- 744
				end -- 747
			end -- 747
			local zipFile -- 744
			do -- 744
				local _obj_0 = req.body -- 744
				local _type_1 = type(_obj_0) -- 744
				if "table" == _type_1 or "userdata" == _type_1 then -- 744
					zipFile = _obj_0.zipFile -- 744
				end -- 747
			end -- 747
			if path ~= nil and zipFile ~= nil then -- 744
				Content:mkdir(Path:getPath(zipFile)) -- 745
				return { -- 746
					success = Content:zipAsync(path, zipFile, function(file) -- 746
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 747
					end) -- 746
				} -- 747
			end -- 744
		end -- 747
	end -- 747
	return { -- 743
		success = false -- 743
	} -- 747
end) -- 743
HttpServer:postSchedule("/unzip", function(req) -- 749
	do -- 750
		local _type_0 = type(req) -- 750
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 750
		if _tab_0 then -- 750
			local zipFile -- 750
			do -- 750
				local _obj_0 = req.body -- 750
				local _type_1 = type(_obj_0) -- 750
				if "table" == _type_1 or "userdata" == _type_1 then -- 750
					zipFile = _obj_0.zipFile -- 750
				end -- 752
			end -- 752
			local path -- 750
			do -- 750
				local _obj_0 = req.body -- 750
				local _type_1 = type(_obj_0) -- 750
				if "table" == _type_1 or "userdata" == _type_1 then -- 750
					path = _obj_0.path -- 750
				end -- 752
			end -- 752
			if zipFile ~= nil and path ~= nil then -- 750
				return { -- 751
					success = Content:unzipAsync(zipFile, path, function(file) -- 751
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 752
					end) -- 751
				} -- 752
			end -- 750
		end -- 752
	end -- 752
	return { -- 753
		success = false -- 753
	} -- 753
end) -- 749
HttpServer:post("/editingInfo", function(req) -- 755
	local Entry = require("Dev.Entry") -- 756
	local config = Entry.getConfig() -- 757
	do -- 758
		local _type_0 = type(req) -- 758
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 758
		local _match_0 = false -- 758
		if _tab_0 then -- 758
			local editingInfo -- 758
			do -- 758
				local _obj_0 = req.body -- 758
				local _type_1 = type(_obj_0) -- 758
				if "table" == _type_1 or "userdata" == _type_1 then -- 758
					editingInfo = _obj_0.editingInfo -- 758
				end -- 760
			end -- 760
			if editingInfo ~= nil then -- 758
				_match_0 = true -- 758
				config.editingInfo = editingInfo -- 759
				return { -- 760
					success = true -- 760
				} -- 760
			end -- 758
		end -- 758
		if not _match_0 then -- 758
			if not (config.editingInfo ~= nil) then -- 762
				local json = require("json") -- 763
				local folder -- 764
				if App.locale:match('^zh') then -- 764
					folder = 'zh-Hans' -- 764
				else -- 764
					folder = 'en' -- 764
				end -- 764
				config.editingInfo = json.dump({ -- 766
					index = 0, -- 766
					files = { -- 768
						{ -- 769
							key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 769
							title = "welcome.md" -- 770
						} -- 768
					} -- 767
				}) -- 765
			end -- 762
			return { -- 774
				success = true, -- 774
				editingInfo = config.editingInfo -- 774
			} -- 774
		end -- 774
	end -- 774
end) -- 755
HttpServer:post("/command", function(req) -- 776
	do -- 777
		local _type_0 = type(req) -- 777
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 777
		if _tab_0 then -- 777
			local code -- 777
			do -- 777
				local _obj_0 = req.body -- 777
				local _type_1 = type(_obj_0) -- 777
				if "table" == _type_1 or "userdata" == _type_1 then -- 777
					code = _obj_0.code -- 777
				end -- 779
			end -- 779
			if code ~= nil then -- 777
				emit("AppCommand", code) -- 778
				return { -- 779
					success = true -- 779
				} -- 779
			end -- 777
		end -- 779
	end -- 779
	return { -- 776
		success = false -- 776
	} -- 779
end) -- 776
HttpServer:post("/exist", function(req) -- 781
	do -- 782
		local _type_0 = type(req) -- 782
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 782
		if _tab_0 then -- 782
			local file -- 782
			do -- 782
				local _obj_0 = req.body -- 782
				local _type_1 = type(_obj_0) -- 782
				if "table" == _type_1 or "userdata" == _type_1 then -- 782
					file = _obj_0.file -- 782
				end -- 783
			end -- 783
			if file ~= nil then -- 782
				return { -- 783
					success = Content:exist(file) -- 783
				} -- 783
			end -- 782
		end -- 783
	end -- 783
	return { -- 781
		success = false -- 781
	} -- 783
end) -- 781
local status = { -- 785
	url = nil -- 785
} -- 785
_module_0 = status -- 786
thread(function() -- 788
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 789
	local doraReady = Path(Content.writablePath, ".www", "dora-ready") -- 790
	if Content:exist(doraWeb) then -- 791
		local needReload -- 792
		if Content:exist(doraReady) then -- 792
			needReload = App.version ~= Content:load(doraReady) -- 793
		else -- 794
			needReload = true -- 794
		end -- 792
		if needReload then -- 795
			Content:remove(Path(Content.writablePath, ".www")) -- 796
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.writablePath, ".www")) -- 797
			Content:save(doraReady, App.version) -- 801
			print("Dora Dora is ready!") -- 802
		end -- 795
		if HttpServer:start(8866) then -- 803
			local localIP = HttpServer.localIP -- 804
			if localIP == "" then -- 805
				localIP = "localhost" -- 805
			end -- 805
			status.url = "http://" .. tostring(localIP) .. ":8866" -- 806
			return HttpServer:startWS(8868) -- 807
		else -- 809
			status.url = nil -- 809
			return print("8866 Port not available!") -- 810
		end -- 803
	end -- 791
end) -- 788
return _module_0 -- 810
