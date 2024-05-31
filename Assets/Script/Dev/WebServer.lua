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
	"not a function" -- 66
} -- 46
local yueCheck -- 68
yueCheck = function(file, content) -- 68
	local searchPath = getSearchPath(file) -- 69
	local checkResult, luaCodes = yue.checkAsync(content, searchPath) -- 70
	local info = { } -- 71
	local globals = { } -- 72
	for _index_0 = 1, #checkResult do -- 73
		local _des_0 = checkResult[_index_0] -- 73
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 73
		if "error" == t then -- 74
			info[#info + 1] = { -- 75
				"syntax", -- 75
				file, -- 75
				line, -- 75
				col, -- 75
				msg -- 75
			} -- 75
		elseif "global" == t then -- 76
			globals[#globals + 1] = { -- 77
				msg, -- 77
				line, -- 77
				col -- 77
			} -- 77
		end -- 77
	end -- 77
	if luaCodes then -- 78
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 79
		if success then -- 80
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 81
			if not (lintResult == "") then -- 82
				lintResult = lintResult .. "\n" -- 82
			end -- 82
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 83
		else -- 84
			for _index_0 = 1, #lintResult do -- 84
				local _des_0 = lintResult[_index_0] -- 84
				local _name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 84
				info[#info + 1] = { -- 85
					"syntax", -- 85
					file, -- 85
					line, -- 85
					col, -- 85
					"invalid global variable" -- 85
				} -- 85
			end -- 85
		end -- 80
	end -- 78
	return luaCodes, info -- 86
end -- 68
local luaCheck -- 88
luaCheck = function(file, content) -- 88
	local res, err = load(content, "check") -- 89
	if not res then -- 90
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 91
		return { -- 92
			success = false, -- 92
			info = { -- 92
				{ -- 92
					"syntax", -- 92
					file, -- 92
					tonumber(line), -- 92
					0, -- 92
					msg -- 92
				} -- 92
			} -- 92
		} -- 92
	end -- 90
	local success, info = teal.checkAsync(content, file, true, "") -- 93
	if info then -- 94
		do -- 95
			local _accum_0 = { } -- 95
			local _len_0 = 1 -- 95
			for _index_0 = 1, #info do -- 95
				local item = info[_index_0] -- 95
				local useCheck = true -- 96
				if not item[5]:match("unused") then -- 97
					for _index_1 = 1, #disabledCheckForLua do -- 98
						local check = disabledCheckForLua[_index_1] -- 98
						if item[5]:match(check) then -- 99
							useCheck = false -- 100
						end -- 99
					end -- 100
				end -- 97
				if not useCheck then -- 101
					goto _continue_0 -- 101
				end -- 101
				do -- 102
					local _exp_0 = item[1] -- 102
					if "type" == _exp_0 then -- 103
						item[1] = "warning" -- 104
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 105
						goto _continue_0 -- 106
					end -- 106
				end -- 106
				_accum_0[_len_0] = item -- 107
				_len_0 = _len_0 + 1 -- 107
				::_continue_0:: -- 96
			end -- 107
			info = _accum_0 -- 95
		end -- 107
		if #info == 0 then -- 108
			info = nil -- 109
			success = true -- 110
		end -- 108
	end -- 94
	return { -- 111
		success = success, -- 111
		info = info -- 111
	} -- 111
end -- 88
local luaCheckWithLineInfo -- 113
luaCheckWithLineInfo = function(file, luaCodes) -- 113
	local res = luaCheck(file, luaCodes) -- 114
	local info = { } -- 115
	if not res.success then -- 116
		local current = 1 -- 117
		local lastLine = 1 -- 118
		local lineMap = { } -- 119
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 120
			local num = lineCode:match("--%s*(%d+)%s*$") -- 121
			if num then -- 122
				lastLine = tonumber(num) -- 123
			end -- 122
			lineMap[current] = lastLine -- 124
			current = current + 1 -- 125
		end -- 125
		local _list_0 = res.info -- 126
		for _index_0 = 1, #_list_0 do -- 126
			local item = _list_0[_index_0] -- 126
			item[3] = lineMap[item[3]] or 0 -- 127
			item[4] = 0 -- 128
			info[#info + 1] = item -- 129
		end -- 129
		return false, info -- 130
	end -- 116
	return true, info -- 131
end -- 113
local getCompiledYueLine -- 133
getCompiledYueLine = function(content, line, row, file) -- 133
	local luaCodes, _info = yueCheck(file, content) -- 134
	if not luaCodes then -- 135
		return nil -- 135
	end -- 135
	local current = 1 -- 136
	local lastLine = 1 -- 137
	local targetLine = nil -- 138
	local targetRow = nil -- 139
	local lineMap = { } -- 140
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 141
		local num = lineCode:match("--%s*(%d+)%s*$") -- 142
		if num then -- 143
			lastLine = tonumber(num) -- 143
		end -- 143
		lineMap[current] = lastLine -- 144
		if row == lastLine and not targetLine then -- 145
			targetRow = current -- 146
			targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 147
			if targetLine then -- 148
				break -- 148
			end -- 148
		end -- 145
		current = current + 1 -- 149
	end -- 149
	if targetLine and targetRow then -- 150
		return luaCodes, targetLine, targetRow, lineMap -- 151
	else -- 153
		return nil -- 153
	end -- 150
end -- 133
HttpServer:postSchedule("/check", function(req) -- 155
	do -- 156
		local _type_0 = type(req) -- 156
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 156
		if _tab_0 then -- 156
			local file -- 156
			do -- 156
				local _obj_0 = req.body -- 156
				local _type_1 = type(_obj_0) -- 156
				if "table" == _type_1 or "userdata" == _type_1 then -- 156
					file = _obj_0.file -- 156
				end -- 186
			end -- 186
			local content -- 156
			do -- 156
				local _obj_0 = req.body -- 156
				local _type_1 = type(_obj_0) -- 156
				if "table" == _type_1 or "userdata" == _type_1 then -- 156
					content = _obj_0.content -- 156
				end -- 186
			end -- 186
			if file ~= nil and content ~= nil then -- 156
				local ext = Path:getExt(file) -- 157
				if "tl" == ext then -- 158
					local searchPath = getSearchPath(file) -- 159
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 160
					return { -- 161
						success = success, -- 161
						info = info -- 161
					} -- 161
				elseif "lua" == ext then -- 162
					return luaCheck(file, content) -- 163
				elseif "yue" == ext then -- 164
					local luaCodes, info = yueCheck(file, content) -- 165
					local success = false -- 166
					if luaCodes then -- 167
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 168
						do -- 169
							local _tab_1 = { } -- 169
							local _idx_0 = #_tab_1 + 1 -- 169
							for _index_0 = 1, #info do -- 169
								local _value_0 = info[_index_0] -- 169
								_tab_1[_idx_0] = _value_0 -- 169
								_idx_0 = _idx_0 + 1 -- 169
							end -- 169
							local _idx_1 = #_tab_1 + 1 -- 169
							for _index_0 = 1, #luaInfo do -- 169
								local _value_0 = luaInfo[_index_0] -- 169
								_tab_1[_idx_1] = _value_0 -- 169
								_idx_1 = _idx_1 + 1 -- 169
							end -- 169
							info = _tab_1 -- 169
						end -- 169
						success = success and luaSuccess -- 170
					end -- 167
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
				elseif "xml" == ext then -- 175
					local success, result = xml.check(content) -- 176
					if success then -- 177
						local info -- 178
						success, info = luaCheckWithLineInfo(file, result) -- 178
						if #info > 0 then -- 179
							return { -- 180
								success = success, -- 180
								info = info -- 180
							} -- 180
						else -- 182
							return { -- 182
								success = success -- 182
							} -- 182
						end -- 179
					else -- 184
						local info -- 184
						do -- 184
							local _accum_0 = { } -- 184
							local _len_0 = 1 -- 184
							for _index_0 = 1, #result do -- 184
								local _des_0 = result[_index_0] -- 184
								local row, err = _des_0[1], _des_0[2] -- 184
								_accum_0[_len_0] = { -- 185
									"syntax", -- 185
									file, -- 185
									row, -- 185
									0, -- 185
									err -- 185
								} -- 185
								_len_0 = _len_0 + 1 -- 185
							end -- 185
							info = _accum_0 -- 184
						end -- 185
						return { -- 186
							success = false, -- 186
							info = info -- 186
						} -- 186
					end -- 177
				end -- 186
			end -- 156
		end -- 186
	end -- 186
	return { -- 155
		success = true -- 155
	} -- 186
end) -- 155
local updateInferedDesc -- 188
updateInferedDesc = function(infered) -- 188
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 189
		return -- 189
	end -- 189
	local key, row = infered.key, infered.row -- 190
	local codes = Content:loadAsync(key) -- 191
	if codes then -- 191
		local comments = { } -- 192
		local line = 0 -- 193
		local skipping = false -- 194
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 195
			line = line + 1 -- 196
			if line >= row then -- 197
				break -- 197
			end -- 197
			if lineCode:match("^%s*%-%- @") then -- 198
				skipping = true -- 199
				goto _continue_0 -- 200
			end -- 198
			local result = lineCode:match("^%s*%-%- (.+)") -- 201
			if result then -- 201
				if not skipping then -- 202
					comments[#comments + 1] = result -- 202
				end -- 202
			elseif #comments > 0 then -- 203
				comments = { } -- 204
				skipping = false -- 205
			end -- 201
			::_continue_0:: -- 196
		end -- 205
		infered.doc = table.concat(comments, "\n") -- 206
	end -- 191
end -- 188
HttpServer:postSchedule("/infer", function(req) -- 208
	do -- 209
		local _type_0 = type(req) -- 209
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 209
		if _tab_0 then -- 209
			local lang -- 209
			do -- 209
				local _obj_0 = req.body -- 209
				local _type_1 = type(_obj_0) -- 209
				if "table" == _type_1 or "userdata" == _type_1 then -- 209
					lang = _obj_0.lang -- 209
				end -- 226
			end -- 226
			local file -- 209
			do -- 209
				local _obj_0 = req.body -- 209
				local _type_1 = type(_obj_0) -- 209
				if "table" == _type_1 or "userdata" == _type_1 then -- 209
					file = _obj_0.file -- 209
				end -- 226
			end -- 226
			local content -- 209
			do -- 209
				local _obj_0 = req.body -- 209
				local _type_1 = type(_obj_0) -- 209
				if "table" == _type_1 or "userdata" == _type_1 then -- 209
					content = _obj_0.content -- 209
				end -- 226
			end -- 226
			local line -- 209
			do -- 209
				local _obj_0 = req.body -- 209
				local _type_1 = type(_obj_0) -- 209
				if "table" == _type_1 or "userdata" == _type_1 then -- 209
					line = _obj_0.line -- 209
				end -- 226
			end -- 226
			local row -- 209
			do -- 209
				local _obj_0 = req.body -- 209
				local _type_1 = type(_obj_0) -- 209
				if "table" == _type_1 or "userdata" == _type_1 then -- 209
					row = _obj_0.row -- 209
				end -- 226
			end -- 226
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 209
				local searchPath = getSearchPath(file) -- 210
				if "tl" == lang or "lua" == lang then -- 211
					local infered = teal.inferAsync(content, line, row, searchPath) -- 212
					if (infered ~= nil) then -- 213
						updateInferedDesc(infered) -- 214
						return { -- 215
							success = true, -- 215
							infered = infered -- 215
						} -- 215
					end -- 213
				elseif "yue" == lang then -- 216
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file) -- 217
					if not luaCodes then -- 218
						return { -- 218
							success = false -- 218
						} -- 218
					end -- 218
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 219
					if (infered ~= nil) then -- 220
						local col -- 221
						file, row, col = infered.file, infered.row, infered.col -- 221
						if file == "" and row > 0 and col > 0 then -- 222
							infered.row = lineMap[row] or 0 -- 223
							infered.col = 0 -- 224
						end -- 222
						updateInferedDesc(infered) -- 225
						return { -- 226
							success = true, -- 226
							infered = infered -- 226
						} -- 226
					end -- 220
				end -- 226
			end -- 209
		end -- 226
	end -- 226
	return { -- 208
		success = false -- 208
	} -- 226
end) -- 208
local _anon_func_0 = function(doc) -- 277
	local _accum_0 = { } -- 277
	local _len_0 = 1 -- 277
	local _list_0 = doc.params -- 277
	for _index_0 = 1, #_list_0 do -- 277
		local param = _list_0[_index_0] -- 277
		_accum_0[_len_0] = param.name -- 277
		_len_0 = _len_0 + 1 -- 277
	end -- 277
	return _accum_0 -- 277
end -- 277
local getParamDocs -- 228
getParamDocs = function(signatures) -- 228
	do -- 229
		local codes = Content:loadAsync(signatures[1].file) -- 229
		if codes then -- 229
			local comments = { } -- 230
			local params = { } -- 231
			local line = 0 -- 232
			local docs = { } -- 233
			local returnType = nil -- 234
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 235
				line = line + 1 -- 236
				local needBreak = true -- 237
				for i, _des_0 in ipairs(signatures) do -- 238
					local row = _des_0.row -- 238
					if line >= row and not (docs[i] ~= nil) then -- 239
						if #comments > 0 or #params > 0 or returnType then -- 240
							docs[i] = { -- 242
								doc = table.concat(comments, "  \n"), -- 242
								returnType = returnType -- 243
							} -- 241
							if #params > 0 then -- 245
								docs[i].params = params -- 245
							end -- 245
						else -- 247
							docs[i] = false -- 247
						end -- 240
					end -- 239
					if not docs[i] then -- 248
						needBreak = false -- 248
					end -- 248
				end -- 248
				if needBreak then -- 249
					break -- 249
				end -- 249
				local result = lineCode:match("%s*%-%- (.+)") -- 250
				if result then -- 250
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 251
					if not name then -- 252
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 253
					end -- 252
					if name then -- 254
						local pname = name -- 255
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 256
							pname = pname .. "?" -- 256
						end -- 256
						params[#params + 1] = { -- 258
							name = tostring(pname) .. ": " .. tostring(typ), -- 258
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 259
						} -- 257
					else -- 262
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 262
						if typ then -- 262
							if returnType then -- 263
								returnType = returnType .. ", " .. typ -- 264
							else -- 266
								returnType = typ -- 266
							end -- 263
							result = result:gsub("@return", "**return:**") -- 267
						end -- 262
						comments[#comments + 1] = result -- 268
					end -- 254
				elseif #comments > 0 then -- 269
					comments = { } -- 270
					params = { } -- 271
					returnType = nil -- 272
				end -- 250
			end -- 272
			local results = { } -- 273
			for _index_0 = 1, #docs do -- 274
				local doc = docs[_index_0] -- 274
				if not doc then -- 275
					goto _continue_0 -- 275
				end -- 275
				if doc.params then -- 276
					doc.desc = "function(" .. tostring(table.concat(_anon_func_0(doc), ', ')) .. ")" -- 277
				else -- 279
					doc.desc = "function()" -- 279
				end -- 276
				if doc.returnType then -- 280
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 281
					doc.returnType = nil -- 282
				end -- 280
				results[#results + 1] = doc -- 283
				::_continue_0:: -- 275
			end -- 283
			if #results > 0 then -- 284
				return results -- 284
			else -- 284
				return nil -- 284
			end -- 284
		end -- 229
	end -- 229
	return nil -- 284
end -- 228
HttpServer:postSchedule("/signature", function(req) -- 286
	do -- 287
		local _type_0 = type(req) -- 287
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 287
		if _tab_0 then -- 287
			local lang -- 287
			do -- 287
				local _obj_0 = req.body -- 287
				local _type_1 = type(_obj_0) -- 287
				if "table" == _type_1 or "userdata" == _type_1 then -- 287
					lang = _obj_0.lang -- 287
				end -- 304
			end -- 304
			local file -- 287
			do -- 287
				local _obj_0 = req.body -- 287
				local _type_1 = type(_obj_0) -- 287
				if "table" == _type_1 or "userdata" == _type_1 then -- 287
					file = _obj_0.file -- 287
				end -- 304
			end -- 304
			local content -- 287
			do -- 287
				local _obj_0 = req.body -- 287
				local _type_1 = type(_obj_0) -- 287
				if "table" == _type_1 or "userdata" == _type_1 then -- 287
					content = _obj_0.content -- 287
				end -- 304
			end -- 304
			local line -- 287
			do -- 287
				local _obj_0 = req.body -- 287
				local _type_1 = type(_obj_0) -- 287
				if "table" == _type_1 or "userdata" == _type_1 then -- 287
					line = _obj_0.line -- 287
				end -- 304
			end -- 304
			local row -- 287
			do -- 287
				local _obj_0 = req.body -- 287
				local _type_1 = type(_obj_0) -- 287
				if "table" == _type_1 or "userdata" == _type_1 then -- 287
					row = _obj_0.row -- 287
				end -- 304
			end -- 304
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 287
				local searchPath = getSearchPath(file) -- 288
				if "tl" == lang or "lua" == lang then -- 289
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 290
					if signatures then -- 290
						signatures = getParamDocs(signatures) -- 291
						if signatures then -- 291
							return { -- 292
								success = true, -- 292
								signatures = signatures -- 292
							} -- 292
						end -- 291
					end -- 290
				elseif "yue" == lang then -- 293
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file) -- 294
					if not luaCodes then -- 295
						return { -- 295
							success = false -- 295
						} -- 295
					end -- 295
					do -- 296
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 296
						if chainOp then -- 296
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 297
							targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 298
						end -- 296
					end -- 296
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 299
					if signatures then -- 299
						signatures = getParamDocs(signatures) -- 300
						if signatures then -- 300
							return { -- 301
								success = true, -- 301
								signatures = signatures -- 301
							} -- 301
						end -- 300
					else -- 302
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 302
						if signatures then -- 302
							signatures = getParamDocs(signatures) -- 303
							if signatures then -- 303
								return { -- 304
									success = true, -- 304
									signatures = signatures -- 304
								} -- 304
							end -- 303
						end -- 302
					end -- 299
				end -- 304
			end -- 287
		end -- 304
	end -- 304
	return { -- 286
		success = false -- 286
	} -- 304
end) -- 286
local luaKeywords = { -- 307
	'and', -- 307
	'break', -- 308
	'do', -- 309
	'else', -- 310
	'elseif', -- 311
	'end', -- 312
	'false', -- 313
	'for', -- 314
	'function', -- 315
	'goto', -- 316
	'if', -- 317
	'in', -- 318
	'local', -- 319
	'nil', -- 320
	'not', -- 321
	'or', -- 322
	'repeat', -- 323
	'return', -- 324
	'then', -- 325
	'true', -- 326
	'until', -- 327
	'while' -- 328
} -- 306
local tealKeywords = { -- 332
	'record', -- 332
	'as', -- 333
	'is', -- 334
	'type', -- 335
	'embed', -- 336
	'enum', -- 337
	'global', -- 338
	'any', -- 339
	'boolean', -- 340
	'integer', -- 341
	'number', -- 342
	'string', -- 343
	'thread' -- 344
} -- 331
local yueKeywords = { -- 348
	"and", -- 348
	"break", -- 349
	"do", -- 350
	"else", -- 351
	"elseif", -- 352
	"false", -- 353
	"for", -- 354
	"goto", -- 355
	"if", -- 356
	"in", -- 357
	"local", -- 358
	"nil", -- 359
	"not", -- 360
	"or", -- 361
	"repeat", -- 362
	"return", -- 363
	"then", -- 364
	"true", -- 365
	"until", -- 366
	"while", -- 367
	"as", -- 368
	"class", -- 369
	"continue", -- 370
	"export", -- 371
	"extends", -- 372
	"from", -- 373
	"global", -- 374
	"import", -- 375
	"macro", -- 376
	"switch", -- 377
	"try", -- 378
	"unless", -- 379
	"using", -- 380
	"when", -- 381
	"with" -- 382
} -- 347
local _anon_func_1 = function(Path, f) -- 418
	local _val_0 = Path:getExt(f) -- 418
	return "ttf" == _val_0 or "otf" == _val_0 -- 418
end -- 418
local _anon_func_2 = function(suggestions) -- 444
	local _tbl_0 = { } -- 444
	for _index_0 = 1, #suggestions do -- 444
		local item = suggestions[_index_0] -- 444
		_tbl_0[item[1] .. item[2]] = item -- 444
	end -- 444
	return _tbl_0 -- 444
end -- 444
HttpServer:postSchedule("/complete", function(req) -- 385
	do -- 386
		local _type_0 = type(req) -- 386
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 386
		if _tab_0 then -- 386
			local lang -- 386
			do -- 386
				local _obj_0 = req.body -- 386
				local _type_1 = type(_obj_0) -- 386
				if "table" == _type_1 or "userdata" == _type_1 then -- 386
					lang = _obj_0.lang -- 386
				end -- 493
			end -- 493
			local file -- 386
			do -- 386
				local _obj_0 = req.body -- 386
				local _type_1 = type(_obj_0) -- 386
				if "table" == _type_1 or "userdata" == _type_1 then -- 386
					file = _obj_0.file -- 386
				end -- 493
			end -- 493
			local content -- 386
			do -- 386
				local _obj_0 = req.body -- 386
				local _type_1 = type(_obj_0) -- 386
				if "table" == _type_1 or "userdata" == _type_1 then -- 386
					content = _obj_0.content -- 386
				end -- 493
			end -- 493
			local line -- 386
			do -- 386
				local _obj_0 = req.body -- 386
				local _type_1 = type(_obj_0) -- 386
				if "table" == _type_1 or "userdata" == _type_1 then -- 386
					line = _obj_0.line -- 386
				end -- 493
			end -- 493
			local row -- 386
			do -- 386
				local _obj_0 = req.body -- 386
				local _type_1 = type(_obj_0) -- 386
				if "table" == _type_1 or "userdata" == _type_1 then -- 386
					row = _obj_0.row -- 386
				end -- 493
			end -- 493
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 386
				local searchPath = getSearchPath(file) -- 387
				repeat -- 388
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 389
					if lang == "yue" then -- 390
						if not item then -- 391
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 391
						end -- 391
						if not item then -- 392
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 392
						end -- 392
					end -- 390
					local searchType = nil -- 393
					if not item then -- 394
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 395
						if lang == "yue" then -- 396
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 397
						end -- 396
						if (item ~= nil) then -- 398
							searchType = "Image" -- 398
						end -- 398
					end -- 394
					if not item then -- 399
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 400
						if lang == "yue" then -- 401
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 402
						end -- 401
						if (item ~= nil) then -- 403
							searchType = "Font" -- 403
						end -- 403
					end -- 399
					if not item then -- 404
						break -- 404
					end -- 404
					local searchPaths = Content.searchPaths -- 405
					local _list_0 = getSearchFolders(file) -- 406
					for _index_0 = 1, #_list_0 do -- 406
						local folder = _list_0[_index_0] -- 406
						searchPaths[#searchPaths + 1] = folder -- 407
					end -- 407
					if searchType then -- 408
						searchPaths[#searchPaths + 1] = Content.assetPath -- 408
					end -- 408
					local tokens -- 409
					do -- 409
						local _accum_0 = { } -- 409
						local _len_0 = 1 -- 409
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 409
							_accum_0[_len_0] = mod -- 409
							_len_0 = _len_0 + 1 -- 409
						end -- 409
						tokens = _accum_0 -- 409
					end -- 409
					local suggestions = { } -- 410
					for _index_0 = 1, #searchPaths do -- 411
						local path = searchPaths[_index_0] -- 411
						local sPath = Path(path, table.unpack(tokens)) -- 412
						if not Content:exist(sPath) then -- 413
							goto _continue_0 -- 413
						end -- 413
						if searchType == "Font" then -- 414
							local fontPath = Path(sPath, "Font") -- 415
							if Content:exist(fontPath) then -- 416
								local _list_1 = Content:getFiles(fontPath) -- 417
								for _index_1 = 1, #_list_1 do -- 417
									local f = _list_1[_index_1] -- 417
									if _anon_func_1(Path, f) then -- 418
										if "." == f:sub(1, 1) then -- 419
											goto _continue_1 -- 419
										end -- 419
										suggestions[#suggestions + 1] = { -- 420
											Path:getName(f), -- 420
											"font", -- 420
											"field" -- 420
										} -- 420
									end -- 418
									::_continue_1:: -- 418
								end -- 420
							end -- 416
						end -- 414
						local _list_1 = Content:getFiles(sPath) -- 421
						for _index_1 = 1, #_list_1 do -- 421
							local f = _list_1[_index_1] -- 421
							if "Image" == searchType then -- 422
								do -- 423
									local _exp_0 = Path:getExt(f) -- 423
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 423
										if "." == f:sub(1, 1) then -- 424
											goto _continue_2 -- 424
										end -- 424
										suggestions[#suggestions + 1] = { -- 425
											f, -- 425
											"image", -- 425
											"field" -- 425
										} -- 425
									end -- 425
								end -- 425
								goto _continue_2 -- 426
							elseif "Font" == searchType then -- 427
								do -- 428
									local _exp_0 = Path:getExt(f) -- 428
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 428
										if "." == f:sub(1, 1) then -- 429
											goto _continue_2 -- 429
										end -- 429
										suggestions[#suggestions + 1] = { -- 430
											f, -- 430
											"font", -- 430
											"field" -- 430
										} -- 430
									end -- 430
								end -- 430
								goto _continue_2 -- 431
							end -- 431
							local _exp_0 = Path:getExt(f) -- 432
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 432
								local name = Path:getName(f) -- 433
								if "d" == Path:getExt(name) then -- 434
									goto _continue_2 -- 434
								end -- 434
								if "." == name:sub(1, 1) then -- 435
									goto _continue_2 -- 435
								end -- 435
								suggestions[#suggestions + 1] = { -- 436
									name, -- 436
									"module", -- 436
									"field" -- 436
								} -- 436
							end -- 436
							::_continue_2:: -- 422
						end -- 436
						local _list_2 = Content:getDirs(sPath) -- 437
						for _index_1 = 1, #_list_2 do -- 437
							local dir = _list_2[_index_1] -- 437
							if "." == dir:sub(1, 1) then -- 438
								goto _continue_3 -- 438
							end -- 438
							suggestions[#suggestions + 1] = { -- 439
								dir, -- 439
								"folder", -- 439
								"variable" -- 439
							} -- 439
							::_continue_3:: -- 438
						end -- 439
						::_continue_0:: -- 412
					end -- 439
					if item == "" and not searchType then -- 440
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 441
						for _index_0 = 1, #_list_1 do -- 441
							local _des_0 = _list_1[_index_0] -- 441
							local name = _des_0[1] -- 441
							suggestions[#suggestions + 1] = { -- 442
								name, -- 442
								"dora module", -- 442
								"function" -- 442
							} -- 442
						end -- 442
					end -- 440
					if #suggestions > 0 then -- 443
						do -- 444
							local _accum_0 = { } -- 444
							local _len_0 = 1 -- 444
							for _, v in pairs(_anon_func_2(suggestions)) do -- 444
								_accum_0[_len_0] = v -- 444
								_len_0 = _len_0 + 1 -- 444
							end -- 444
							suggestions = _accum_0 -- 444
						end -- 444
						return { -- 445
							success = true, -- 445
							suggestions = suggestions -- 445
						} -- 445
					else -- 447
						return { -- 447
							success = false -- 447
						} -- 447
					end -- 443
				until true -- 448
				if "tl" == lang or "lua" == lang then -- 449
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 450
					if not line:match("[%.:][%w_]+[%.:]?$") and not line:match("[%w_]+[%.:]$") then -- 451
						local checkSet -- 452
						do -- 452
							local _tbl_0 = { } -- 452
							for _index_0 = 1, #suggestions do -- 452
								local _des_0 = suggestions[_index_0] -- 452
								local name = _des_0[1] -- 452
								_tbl_0[name] = true -- 452
							end -- 452
							checkSet = _tbl_0 -- 452
						end -- 452
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 453
						for _index_0 = 1, #_list_0 do -- 453
							local item = _list_0[_index_0] -- 453
							if not checkSet[item[1]] then -- 454
								suggestions[#suggestions + 1] = item -- 454
							end -- 454
						end -- 454
						for _index_0 = 1, #luaKeywords do -- 455
							local word = luaKeywords[_index_0] -- 455
							suggestions[#suggestions + 1] = { -- 456
								word, -- 456
								"keyword", -- 456
								"keyword" -- 456
							} -- 456
						end -- 456
						if lang == "tl" then -- 457
							for _index_0 = 1, #tealKeywords do -- 458
								local word = tealKeywords[_index_0] -- 458
								suggestions[#suggestions + 1] = { -- 459
									word, -- 459
									"keyword", -- 459
									"keyword" -- 459
								} -- 459
							end -- 459
						end -- 457
					end -- 451
					if #suggestions > 0 then -- 460
						return { -- 461
							success = true, -- 461
							suggestions = suggestions -- 461
						} -- 461
					end -- 460
				elseif "yue" == lang then -- 462
					local suggestions = { } -- 463
					local gotGlobals = false -- 464
					do -- 465
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file) -- 465
						if luaCodes then -- 465
							gotGlobals = true -- 466
							do -- 467
								local chainOp = line:match("[^%w_]([%.\\])$") -- 467
								if chainOp then -- 467
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 468
									if not withVar then -- 469
										return { -- 469
											success = false -- 469
										} -- 469
									end -- 469
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 470
								elseif line:match("^([%.\\])$") then -- 471
									return { -- 472
										success = false -- 472
									} -- 472
								end -- 467
							end -- 467
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 473
							for _index_0 = 1, #_list_0 do -- 473
								local item = _list_0[_index_0] -- 473
								suggestions[#suggestions + 1] = item -- 473
							end -- 473
							if #suggestions == 0 then -- 474
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 475
								for _index_0 = 1, #_list_1 do -- 475
									local item = _list_1[_index_0] -- 475
									suggestions[#suggestions + 1] = item -- 475
								end -- 475
							end -- 474
						end -- 465
					end -- 465
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 476
						local checkSet -- 477
						do -- 477
							local _tbl_0 = { } -- 477
							for _index_0 = 1, #suggestions do -- 477
								local _des_0 = suggestions[_index_0] -- 477
								local name = _des_0[1] -- 477
								_tbl_0[name] = true -- 477
							end -- 477
							checkSet = _tbl_0 -- 477
						end -- 477
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 478
						for _index_0 = 1, #_list_0 do -- 478
							local item = _list_0[_index_0] -- 478
							if not checkSet[item[1]] then -- 479
								suggestions[#suggestions + 1] = item -- 479
							end -- 479
						end -- 479
						if not gotGlobals then -- 480
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 481
							for _index_0 = 1, #_list_1 do -- 481
								local item = _list_1[_index_0] -- 481
								if not checkSet[item[1]] then -- 482
									suggestions[#suggestions + 1] = item -- 482
								end -- 482
							end -- 482
						end -- 480
						for _index_0 = 1, #yueKeywords do -- 483
							local word = yueKeywords[_index_0] -- 483
							if not checkSet[word] then -- 484
								suggestions[#suggestions + 1] = { -- 485
									word, -- 485
									"keyword", -- 485
									"keyword" -- 485
								} -- 485
							end -- 484
						end -- 485
					end -- 476
					if #suggestions > 0 then -- 486
						return { -- 487
							success = true, -- 487
							suggestions = suggestions -- 487
						} -- 487
					end -- 486
				elseif "xml" == lang then -- 488
					local items = xml.complete(content) -- 489
					if #items > 0 then -- 490
						local suggestions -- 491
						do -- 491
							local _accum_0 = { } -- 491
							local _len_0 = 1 -- 491
							for _index_0 = 1, #items do -- 491
								local _des_0 = items[_index_0] -- 491
								local label, insertText = _des_0[1], _des_0[2] -- 491
								_accum_0[_len_0] = { -- 492
									label, -- 492
									insertText, -- 492
									"field" -- 492
								} -- 492
								_len_0 = _len_0 + 1 -- 492
							end -- 492
							suggestions = _accum_0 -- 491
						end -- 492
						return { -- 493
							success = true, -- 493
							suggestions = suggestions -- 493
						} -- 493
					end -- 490
				end -- 493
			end -- 386
		end -- 493
	end -- 493
	return { -- 385
		success = false -- 385
	} -- 493
end) -- 385
HttpServer:upload("/upload", function(req, filename) -- 497
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
				end -- 504
			end -- 504
			if path ~= nil then -- 498
				local uploadPath = Path(Content.writablePath, ".upload") -- 499
				if not Content:exist(uploadPath) then -- 500
					Content:mkdir(uploadPath) -- 501
				end -- 500
				local targetPath = Path(uploadPath, filename) -- 502
				Content:mkdir(Path:getPath(targetPath)) -- 503
				return targetPath -- 504
			end -- 498
		end -- 504
	end -- 504
	return nil -- 504
end, function(req, file) -- 505
	do -- 506
		local _type_0 = type(req) -- 506
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 506
		if _tab_0 then -- 506
			local path -- 506
			do -- 506
				local _obj_0 = req.params -- 506
				local _type_1 = type(_obj_0) -- 506
				if "table" == _type_1 or "userdata" == _type_1 then -- 506
					path = _obj_0.path -- 506
				end -- 513
			end -- 513
			if path ~= nil then -- 506
				path = Path(Content.writablePath, path) -- 507
				if Content:exist(path) then -- 508
					local uploadPath = Path(Content.writablePath, ".upload") -- 509
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 510
					Content:mkdir(Path:getPath(targetPath)) -- 511
					if Content:move(file, targetPath) then -- 512
						return true -- 513
					end -- 512
				end -- 508
			end -- 506
		end -- 513
	end -- 513
	return false -- 513
end) -- 495
HttpServer:post("/list", function(req) -- 516
	do -- 517
		local _type_0 = type(req) -- 517
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 517
		if _tab_0 then -- 517
			local path -- 517
			do -- 517
				local _obj_0 = req.body -- 517
				local _type_1 = type(_obj_0) -- 517
				if "table" == _type_1 or "userdata" == _type_1 then -- 517
					path = _obj_0.path -- 517
				end -- 539
			end -- 539
			if path ~= nil then -- 517
				if Content:exist(path) then -- 518
					local files = { } -- 519
					local visitAssets -- 520
					visitAssets = function(path, folder) -- 520
						local dirs = Content:getDirs(path) -- 521
						for _index_0 = 1, #dirs do -- 522
							local dir = dirs[_index_0] -- 522
							if dir:match("^%.") then -- 523
								goto _continue_0 -- 523
							end -- 523
							local current -- 524
							if folder == "" then -- 524
								current = dir -- 525
							else -- 527
								current = Path(folder, dir) -- 527
							end -- 524
							files[#files + 1] = current -- 528
							visitAssets(Path(path, dir), current) -- 529
							::_continue_0:: -- 523
						end -- 529
						local fs = Content:getFiles(path) -- 530
						for _index_0 = 1, #fs do -- 531
							local f = fs[_index_0] -- 531
							if f:match("^%.") then -- 532
								goto _continue_1 -- 532
							end -- 532
							if folder == "" then -- 533
								files[#files + 1] = f -- 534
							else -- 536
								files[#files + 1] = Path(folder, f) -- 536
							end -- 533
							::_continue_1:: -- 532
						end -- 536
					end -- 520
					visitAssets(path, "") -- 537
					if #files == 0 then -- 538
						files = nil -- 538
					end -- 538
					return { -- 539
						success = true, -- 539
						files = files -- 539
					} -- 539
				end -- 518
			end -- 517
		end -- 539
	end -- 539
	return { -- 516
		success = false -- 516
	} -- 539
end) -- 516
HttpServer:post("/info", function() -- 541
	local Entry = require("Script.Dev.Entry") -- 542
	local engineDev = Entry.getEngineDev() -- 543
	return { -- 545
		platform = App.platform, -- 545
		locale = App.locale, -- 546
		version = App.version, -- 547
		engineDev = engineDev -- 548
	} -- 548
end) -- 541
HttpServer:post("/new", function(req) -- 550
	do -- 551
		local _type_0 = type(req) -- 551
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 551
		if _tab_0 then -- 551
			local path -- 551
			do -- 551
				local _obj_0 = req.body -- 551
				local _type_1 = type(_obj_0) -- 551
				if "table" == _type_1 or "userdata" == _type_1 then -- 551
					path = _obj_0.path -- 551
				end -- 563
			end -- 563
			local content -- 551
			do -- 551
				local _obj_0 = req.body -- 551
				local _type_1 = type(_obj_0) -- 551
				if "table" == _type_1 or "userdata" == _type_1 then -- 551
					content = _obj_0.content -- 551
				end -- 563
			end -- 563
			if path ~= nil and content ~= nil then -- 551
				if not Content:exist(path) then -- 552
					local parent = Path:getPath(path) -- 553
					local files = Content:getFiles(parent) -- 554
					local name = Path:getName(path):lower() -- 555
					for _index_0 = 1, #files do -- 556
						local file = files[_index_0] -- 556
						if name == Path:getName(file):lower() then -- 557
							return { -- 558
								success = false -- 558
							} -- 558
						end -- 557
					end -- 558
					if "" == Path:getExt(path) then -- 559
						if Content:mkdir(path) then -- 560
							return { -- 561
								success = true -- 561
							} -- 561
						end -- 560
					elseif Content:save(path, content) then -- 562
						return { -- 563
							success = true -- 563
						} -- 563
					end -- 559
				end -- 552
			end -- 551
		end -- 563
	end -- 563
	return { -- 550
		success = false -- 550
	} -- 563
end) -- 550
HttpServer:post("/delete", function(req) -- 565
	do -- 566
		local _type_0 = type(req) -- 566
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 566
		if _tab_0 then -- 566
			local path -- 566
			do -- 566
				local _obj_0 = req.body -- 566
				local _type_1 = type(_obj_0) -- 566
				if "table" == _type_1 or "userdata" == _type_1 then -- 566
					path = _obj_0.path -- 566
				end -- 579
			end -- 579
			if path ~= nil then -- 566
				if Content:exist(path) then -- 567
					local parent = Path:getPath(path) -- 568
					local files = Content:getFiles(parent) -- 569
					local name = Path:getName(path):lower() -- 570
					local ext = Path:getExt(path) -- 571
					for _index_0 = 1, #files do -- 572
						local file = files[_index_0] -- 572
						if name == Path:getName(file):lower() then -- 573
							local _exp_0 = Path:getExt(file) -- 574
							if "tl" == _exp_0 then -- 574
								if ("vs" == ext) then -- 574
									Content:remove(Path(parent, file)) -- 575
								end -- 574
							elseif "lua" == _exp_0 then -- 576
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 576
									Content:remove(Path(parent, file)) -- 577
								end -- 576
							end -- 577
						end -- 573
					end -- 577
					if Content:remove(path) then -- 578
						return { -- 579
							success = true -- 579
						} -- 579
					end -- 578
				end -- 567
			end -- 566
		end -- 579
	end -- 579
	return { -- 565
		success = false -- 565
	} -- 579
end) -- 565
HttpServer:post("/rename", function(req) -- 581
	do -- 582
		local _type_0 = type(req) -- 582
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 582
		if _tab_0 then -- 582
			local old -- 582
			do -- 582
				local _obj_0 = req.body -- 582
				local _type_1 = type(_obj_0) -- 582
				if "table" == _type_1 or "userdata" == _type_1 then -- 582
					old = _obj_0.old -- 582
				end -- 604
			end -- 604
			local new -- 582
			do -- 582
				local _obj_0 = req.body -- 582
				local _type_1 = type(_obj_0) -- 582
				if "table" == _type_1 or "userdata" == _type_1 then -- 582
					new = _obj_0.new -- 582
				end -- 604
			end -- 604
			if old ~= nil and new ~= nil then -- 582
				if Content:exist(old) and not Content:exist(new) then -- 583
					local parent = Path:getPath(new) -- 584
					local files = Content:getFiles(parent) -- 585
					local name = Path:getName(new):lower() -- 586
					for _index_0 = 1, #files do -- 587
						local file = files[_index_0] -- 587
						if name == Path:getName(file):lower() then -- 588
							return { -- 589
								success = false -- 589
							} -- 589
						end -- 588
					end -- 589
					if Content:move(old, new) then -- 590
						local newParent = Path:getPath(new) -- 591
						parent = Path:getPath(old) -- 592
						files = Content:getFiles(parent) -- 593
						local newName = Path:getName(new) -- 594
						local oldName = Path:getName(old) -- 595
						name = oldName:lower() -- 596
						local ext = Path:getExt(old) -- 597
						for _index_0 = 1, #files do -- 598
							local file = files[_index_0] -- 598
							if name == Path:getName(file):lower() then -- 599
								local _exp_0 = Path:getExt(file) -- 600
								if "tl" == _exp_0 then -- 600
									if ("vs" == ext) then -- 600
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 601
									end -- 600
								elseif "lua" == _exp_0 then -- 602
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 602
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 603
									end -- 602
								end -- 603
							end -- 599
						end -- 603
						return { -- 604
							success = true -- 604
						} -- 604
					end -- 590
				end -- 583
			end -- 582
		end -- 604
	end -- 604
	return { -- 581
		success = false -- 581
	} -- 604
end) -- 581
HttpServer:postSchedule("/read", function(req) -- 606
	do -- 607
		local _type_0 = type(req) -- 607
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 607
		if _tab_0 then -- 607
			local path -- 607
			do -- 607
				local _obj_0 = req.body -- 607
				local _type_1 = type(_obj_0) -- 607
				if "table" == _type_1 or "userdata" == _type_1 then -- 607
					path = _obj_0.path -- 607
				end -- 610
			end -- 610
			if path ~= nil then -- 607
				if Content:exist(path) then -- 608
					local content = Content:loadAsync(path) -- 609
					if content then -- 609
						return { -- 610
							content = content, -- 610
							success = true -- 610
						} -- 610
					end -- 609
				end -- 608
			end -- 607
		end -- 610
	end -- 610
	return { -- 606
		success = false -- 606
	} -- 610
end) -- 606
local compileFileAsync -- 612
compileFileAsync = function(inputFile, sourceCodes) -- 612
	local file = inputFile -- 613
	local searchPath -- 614
	do -- 614
		local dir = getProjectDirFromFile(inputFile) -- 614
		if dir then -- 614
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 615
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 616
		else -- 618
			file = Path:getRelative(inputFile, Path(Content.writablePath)) -- 618
			if file:sub(1, 2) == ".." then -- 619
				file = Path:getRelative(inputFile, Path(Content.assetPath)) -- 620
			end -- 619
			searchPath = "" -- 621
		end -- 614
	end -- 614
	local outputFile = Path:replaceExt(inputFile, "lua") -- 622
	local yueext = yue.options.extension -- 623
	local resultCodes = nil -- 624
	do -- 625
		local _exp_0 = Path:getExt(inputFile) -- 625
		if yueext == _exp_0 then -- 625
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 626
				if not codes then -- 627
					return -- 627
				end -- 627
				local success, result = LintYueGlobals(codes, globals) -- 628
				if not success then -- 629
					return -- 629
				end -- 629
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 630
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 631
				codes = codes:gsub("^\n*", "") -- 632
				if not (result == "") then -- 633
					result = result .. "\n" -- 633
				end -- 633
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 634
				return resultCodes -- 635
			end, function(success) -- 626
				if not success then -- 636
					Content:remove(outputFile) -- 637
					resultCodes = false -- 638
				end -- 636
			end) -- 626
		elseif "tl" == _exp_0 then -- 639
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 640
			if codes then -- 640
				resultCodes = codes -- 641
				Content:saveAsync(outputFile, codes) -- 642
			else -- 644
				Content:remove(outputFile) -- 644
				resultCodes = false -- 645
			end -- 640
		elseif "xml" == _exp_0 then -- 646
			local codes = xml.tolua(sourceCodes) -- 647
			if codes then -- 647
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 648
				Content:saveAsync(outputFile, resultCodes) -- 649
			else -- 651
				Content:remove(outputFile) -- 651
				resultCodes = false -- 652
			end -- 647
		end -- 652
	end -- 652
	wait(function() -- 653
		return resultCodes ~= nil -- 653
	end) -- 653
	if resultCodes then -- 654
		return resultCodes -- 654
	end -- 654
	return nil -- 654
end -- 612
HttpServer:postSchedule("/write", function(req) -- 656
	do -- 657
		local _type_0 = type(req) -- 657
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 657
		if _tab_0 then -- 657
			local path -- 657
			do -- 657
				local _obj_0 = req.body -- 657
				local _type_1 = type(_obj_0) -- 657
				if "table" == _type_1 or "userdata" == _type_1 then -- 657
					path = _obj_0.path -- 657
				end -- 663
			end -- 663
			local content -- 657
			do -- 657
				local _obj_0 = req.body -- 657
				local _type_1 = type(_obj_0) -- 657
				if "table" == _type_1 or "userdata" == _type_1 then -- 657
					content = _obj_0.content -- 657
				end -- 663
			end -- 663
			if path ~= nil and content ~= nil then -- 657
				if Content:saveAsync(path, content) then -- 658
					do -- 659
						local _exp_0 = Path:getExt(path) -- 659
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 659
							if '' == Path:getExt(Path:getName(path)) then -- 660
								local resultCodes = compileFileAsync(path, content) -- 661
								return { -- 662
									success = true, -- 662
									resultCodes = resultCodes -- 662
								} -- 662
							end -- 660
						end -- 662
					end -- 662
					return { -- 663
						success = true -- 663
					} -- 663
				end -- 658
			end -- 657
		end -- 663
	end -- 663
	return { -- 656
		success = false -- 656
	} -- 663
end) -- 656
local extentionLevels = { -- 666
	vs = 2, -- 666
	ts = 1, -- 667
	tsx = 1, -- 668
	tl = 1, -- 669
	yue = 1, -- 670
	xml = 1, -- 671
	lua = 0 -- 672
} -- 665
local _anon_func_4 = function(Content, Path, visitAssets, zh) -- 741
	local _with_0 = visitAssets(Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")) -- 740
	_with_0.title = zh and "说明文档" or "Readme" -- 741
	return _with_0 -- 740
end -- 740
local _anon_func_5 = function(Content, Path, visitAssets, zh) -- 743
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")) -- 742
	_with_0.title = zh and "接口文档" or "API Doc" -- 743
	return _with_0 -- 742
end -- 742
local _anon_func_6 = function(Content, Path, visitAssets, zh) -- 745
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Example")) -- 744
	_with_0.title = zh and "代码示例" or "Example" -- 745
	return _with_0 -- 744
end -- 744
local _anon_func_7 = function(Content, Path, visitAssets, zh) -- 747
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Game")) -- 746
	_with_0.title = zh and "游戏演示" or "Demo Game" -- 747
	return _with_0 -- 746
end -- 746
local _anon_func_8 = function(Content, Path, visitAssets, zh) -- 749
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Test")) -- 748
	_with_0.title = zh and "功能测试" or "Test" -- 749
	return _with_0 -- 748
end -- 748
local _anon_func_9 = function(Content, Path, engineDev, visitAssets, zh) -- 761
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib")) -- 753
	if engineDev then -- 754
		local _list_0 = _with_0.children -- 755
		for _index_0 = 1, #_list_0 do -- 755
			local child = _list_0[_index_0] -- 755
			if not (child.title == "Dora") then -- 756
				goto _continue_0 -- 756
			end -- 756
			local title = zh and "zh-Hans" or "en" -- 757
			do -- 758
				local _accum_0 = { } -- 758
				local _len_0 = 1 -- 758
				local _list_1 = child.children -- 758
				for _index_1 = 1, #_list_1 do -- 758
					local c = _list_1[_index_1] -- 758
					if c.title ~= title then -- 758
						_accum_0[_len_0] = c -- 758
						_len_0 = _len_0 + 1 -- 758
					end -- 758
				end -- 758
				child.children = _accum_0 -- 758
			end -- 758
			break -- 759
			::_continue_0:: -- 756
		end -- 759
	else -- 761
		local _accum_0 = { } -- 761
		local _len_0 = 1 -- 761
		local _list_0 = _with_0.children -- 761
		for _index_0 = 1, #_list_0 do -- 761
			local child = _list_0[_index_0] -- 761
			if child.title ~= "Dora" then -- 761
				_accum_0[_len_0] = child -- 761
				_len_0 = _len_0 + 1 -- 761
			end -- 761
		end -- 761
		_with_0.children = _accum_0 -- 761
	end -- 754
	return _with_0 -- 753
end -- 753
local _anon_func_10 = function(Content, Path, engineDev, visitAssets) -- 762
	if engineDev then -- 762
		local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Dev")) -- 763
		local _obj_0 = _with_0.children -- 764
		_obj_0[#_obj_0 + 1] = { -- 765
			key = Path(Content.assetPath, "Script", "init.yue"), -- 765
			dir = false, -- 766
			title = "init.yue" -- 767
		} -- 764
		return _with_0 -- 763
	end -- 762
end -- 762
local _anon_func_3 = function(Content, Path, engineDev, visitAssets, zh) -- 770
	local _tab_0 = { -- 735
		{ -- 736
			key = Path(Content.assetPath), -- 736
			dir = true, -- 737
			title = zh and "内置资源" or "Built-in", -- 738
			children = { -- 740
				_anon_func_4(Content, Path, visitAssets, zh), -- 740
				_anon_func_5(Content, Path, visitAssets, zh), -- 742
				_anon_func_6(Content, Path, visitAssets, zh), -- 744
				_anon_func_7(Content, Path, visitAssets, zh), -- 746
				_anon_func_8(Content, Path, visitAssets, zh), -- 748
				visitAssets(Path(Content.assetPath, "Image")), -- 750
				visitAssets(Path(Content.assetPath, "Spine")), -- 751
				visitAssets(Path(Content.assetPath, "Font")), -- 752
				_anon_func_9(Content, Path, engineDev, visitAssets, zh), -- 753
				_anon_func_10(Content, Path, engineDev, visitAssets) -- 762
			} -- 739
		} -- 735
	} -- 771
	local _obj_0 = visitAssets(Content.writablePath, true) -- 771
	local _idx_0 = #_tab_0 + 1 -- 771
	for _index_0 = 1, #_obj_0 do -- 771
		local _value_0 = _obj_0[_index_0] -- 771
		_tab_0[_idx_0] = _value_0 -- 771
		_idx_0 = _idx_0 + 1 -- 771
	end -- 771
	return _tab_0 -- 770
end -- 735
HttpServer:post("/assets", function() -- 674
	local Entry = require("Script.Dev.Entry") -- 675
	local engineDev = Entry.getEngineDev() -- 676
	local visitAssets -- 677
	visitAssets = function(path, root) -- 677
		local children = nil -- 678
		local dirs = Content:getDirs(path) -- 679
		for _index_0 = 1, #dirs do -- 680
			local dir = dirs[_index_0] -- 680
			if root then -- 681
				if ".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir then -- 681
					goto _continue_0 -- 682
				end -- 682
			elseif dir == ".git" then -- 683
				goto _continue_0 -- 684
			end -- 681
			if not children then -- 685
				children = { } -- 685
			end -- 685
			children[#children + 1] = visitAssets(Path(path, dir)) -- 686
			::_continue_0:: -- 681
		end -- 686
		local files = Content:getFiles(path) -- 687
		local names = { } -- 688
		for _index_0 = 1, #files do -- 689
			local file = files[_index_0] -- 689
			if file:match("^%.") then -- 690
				goto _continue_1 -- 690
			end -- 690
			local name = Path:getName(file) -- 691
			local ext = names[name] -- 692
			if ext then -- 692
				local lv1 -- 693
				do -- 693
					local _exp_0 = extentionLevels[ext] -- 693
					if _exp_0 ~= nil then -- 693
						lv1 = _exp_0 -- 693
					else -- 693
						lv1 = -1 -- 693
					end -- 693
				end -- 693
				ext = Path:getExt(file) -- 694
				local lv2 -- 695
				do -- 695
					local _exp_0 = extentionLevels[ext] -- 695
					if _exp_0 ~= nil then -- 695
						lv2 = _exp_0 -- 695
					else -- 695
						lv2 = -1 -- 695
					end -- 695
				end -- 695
				if lv2 > lv1 then -- 696
					names[name] = ext -- 697
				elseif lv2 == lv1 then -- 698
					names[name .. '.' .. ext] = "" -- 699
				end -- 696
			else -- 701
				ext = Path:getExt(file) -- 701
				if not extentionLevels[ext] then -- 702
					names[file] = "" -- 703
				else -- 705
					names[name] = ext -- 705
				end -- 702
			end -- 692
			::_continue_1:: -- 690
		end -- 705
		do -- 706
			local _accum_0 = { } -- 706
			local _len_0 = 1 -- 706
			for name, ext in pairs(names) do -- 706
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 706
				_len_0 = _len_0 + 1 -- 706
			end -- 706
			files = _accum_0 -- 706
		end -- 706
		for _index_0 = 1, #files do -- 707
			local file = files[_index_0] -- 707
			if not children then -- 708
				children = { } -- 708
			end -- 708
			children[#children + 1] = { -- 710
				key = Path(path, file), -- 710
				dir = false, -- 711
				title = file -- 712
			} -- 709
		end -- 713
		if children then -- 714
			table.sort(children, function(a, b) -- 715
				if a.dir == b.dir then -- 716
					return a.title < b.title -- 717
				else -- 719
					return a.dir -- 719
				end -- 716
			end) -- 715
		end -- 714
		if root then -- 720
			return children -- 721
		else -- 723
			return { -- 724
				key = path, -- 724
				dir = true, -- 725
				title = Path:getFilename(path), -- 726
				children = children -- 727
			} -- 728
		end -- 720
	end -- 677
	local zh = (App.locale:match("^zh") ~= nil) -- 729
	return { -- 731
		key = Content.writablePath, -- 731
		dir = true, -- 732
		title = "Assets", -- 733
		children = _anon_func_3(Content, Path, engineDev, visitAssets, zh) -- 734
	} -- 773
end) -- 674
HttpServer:postSchedule("/run", function(req) -- 775
	do -- 776
		local _type_0 = type(req) -- 776
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 776
		if _tab_0 then -- 776
			local file -- 776
			do -- 776
				local _obj_0 = req.body -- 776
				local _type_1 = type(_obj_0) -- 776
				if "table" == _type_1 or "userdata" == _type_1 then -- 776
					file = _obj_0.file -- 776
				end -- 791
			end -- 791
			local asProj -- 776
			do -- 776
				local _obj_0 = req.body -- 776
				local _type_1 = type(_obj_0) -- 776
				if "table" == _type_1 or "userdata" == _type_1 then -- 776
					asProj = _obj_0.asProj -- 776
				end -- 791
			end -- 791
			if file ~= nil and asProj ~= nil then -- 776
				if not Content:isAbsolutePath(file) then -- 777
					local devFile = Path(Content.writablePath, file) -- 778
					if Content:exist(devFile) then -- 779
						file = devFile -- 779
					end -- 779
				end -- 777
				local Entry = require("Script.Dev.Entry") -- 780
				if asProj then -- 781
					local proj = getProjectDirFromFile(file) -- 782
					if proj then -- 782
						Entry.allClear() -- 783
						local target = Path(proj, "init") -- 784
						local success, err = Entry.enterEntryAsync({ -- 785
							"Project", -- 785
							target -- 785
						}) -- 785
						target = Path:getName(Path:getPath(target)) -- 786
						return { -- 787
							success = success, -- 787
							target = target, -- 787
							err = err -- 787
						} -- 787
					end -- 782
				end -- 781
				Entry.allClear() -- 788
				file = Path:replaceExt(file, "") -- 789
				local success, err = Entry.enterEntryAsync({ -- 790
					Path:getName(file), -- 790
					file -- 790
				}) -- 790
				return { -- 791
					success = success, -- 791
					err = err -- 791
				} -- 791
			end -- 776
		end -- 791
	end -- 791
	return { -- 775
		success = false -- 775
	} -- 791
end) -- 775
HttpServer:postSchedule("/stop", function() -- 793
	local Entry = require("Script.Dev.Entry") -- 794
	return { -- 795
		success = Entry.stop() -- 795
	} -- 795
end) -- 793
HttpServer:postSchedule("/zip", function(req) -- 797
	do -- 798
		local _type_0 = type(req) -- 798
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 798
		if _tab_0 then -- 798
			local path -- 798
			do -- 798
				local _obj_0 = req.body -- 798
				local _type_1 = type(_obj_0) -- 798
				if "table" == _type_1 or "userdata" == _type_1 then -- 798
					path = _obj_0.path -- 798
				end -- 801
			end -- 801
			local zipFile -- 798
			do -- 798
				local _obj_0 = req.body -- 798
				local _type_1 = type(_obj_0) -- 798
				if "table" == _type_1 or "userdata" == _type_1 then -- 798
					zipFile = _obj_0.zipFile -- 798
				end -- 801
			end -- 801
			if path ~= nil and zipFile ~= nil then -- 798
				Content:mkdir(Path:getPath(zipFile)) -- 799
				return { -- 800
					success = Content:zipAsync(path, zipFile, function(file) -- 800
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 801
					end) -- 800
				} -- 801
			end -- 798
		end -- 801
	end -- 801
	return { -- 797
		success = false -- 797
	} -- 801
end) -- 797
HttpServer:postSchedule("/unzip", function(req) -- 803
	do -- 804
		local _type_0 = type(req) -- 804
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 804
		if _tab_0 then -- 804
			local zipFile -- 804
			do -- 804
				local _obj_0 = req.body -- 804
				local _type_1 = type(_obj_0) -- 804
				if "table" == _type_1 or "userdata" == _type_1 then -- 804
					zipFile = _obj_0.zipFile -- 804
				end -- 806
			end -- 806
			local path -- 804
			do -- 804
				local _obj_0 = req.body -- 804
				local _type_1 = type(_obj_0) -- 804
				if "table" == _type_1 or "userdata" == _type_1 then -- 804
					path = _obj_0.path -- 804
				end -- 806
			end -- 806
			if zipFile ~= nil and path ~= nil then -- 804
				return { -- 805
					success = Content:unzipAsync(zipFile, path, function(file) -- 805
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 806
					end) -- 805
				} -- 806
			end -- 804
		end -- 806
	end -- 806
	return { -- 803
		success = false -- 803
	} -- 806
end) -- 803
HttpServer:post("/editingInfo", function(req) -- 808
	local Entry = require("Script.Dev.Entry") -- 809
	local config = Entry.getConfig() -- 810
	local _type_0 = type(req) -- 811
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 811
	local _match_0 = false -- 811
	if _tab_0 then -- 811
		local editingInfo -- 811
		do -- 811
			local _obj_0 = req.body -- 811
			local _type_1 = type(_obj_0) -- 811
			if "table" == _type_1 or "userdata" == _type_1 then -- 811
				editingInfo = _obj_0.editingInfo -- 811
			end -- 813
		end -- 813
		if editingInfo ~= nil then -- 811
			_match_0 = true -- 811
			config.editingInfo = editingInfo -- 812
			return { -- 813
				success = true -- 813
			} -- 813
		end -- 811
	end -- 811
	if not _match_0 then -- 811
		if not (config.editingInfo ~= nil) then -- 815
			local json = require("json") -- 816
			local folder -- 817
			if App.locale:match('^zh') then -- 817
				folder = 'zh-Hans' -- 817
			else -- 817
				folder = 'en' -- 817
			end -- 817
			config.editingInfo = json.dump({ -- 819
				index = 0, -- 819
				files = { -- 821
					{ -- 822
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 822
						title = "welcome.md" -- 823
					} -- 821
				} -- 820
			}) -- 818
		end -- 815
		return { -- 827
			success = true, -- 827
			editingInfo = config.editingInfo -- 827
		} -- 827
	end -- 827
end) -- 808
HttpServer:post("/command", function(req) -- 829
	do -- 830
		local _type_0 = type(req) -- 830
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 830
		if _tab_0 then -- 830
			local code -- 830
			do -- 830
				local _obj_0 = req.body -- 830
				local _type_1 = type(_obj_0) -- 830
				if "table" == _type_1 or "userdata" == _type_1 then -- 830
					code = _obj_0.code -- 830
				end -- 832
			end -- 832
			if code ~= nil then -- 830
				emit("AppCommand", code) -- 831
				return { -- 832
					success = true -- 832
				} -- 832
			end -- 830
		end -- 832
	end -- 832
	return { -- 829
		success = false -- 829
	} -- 832
end) -- 829
HttpServer:post("/exist", function(req) -- 834
	do -- 835
		local _type_0 = type(req) -- 835
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 835
		if _tab_0 then -- 835
			local file -- 835
			do -- 835
				local _obj_0 = req.body -- 835
				local _type_1 = type(_obj_0) -- 835
				if "table" == _type_1 or "userdata" == _type_1 then -- 835
					file = _obj_0.file -- 835
				end -- 836
			end -- 836
			if file ~= nil then -- 835
				return { -- 836
					success = Content:exist(file) -- 836
				} -- 836
			end -- 835
		end -- 836
	end -- 836
	return { -- 834
		success = false -- 834
	} -- 836
end) -- 834
local status = { } -- 838
_module_0 = status -- 839
thread(function() -- 841
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 842
	local doraReady = Path(Content.writablePath, ".www", "dora-ready") -- 843
	if Content:exist(doraWeb) then -- 844
		local needReload -- 845
		if Content:exist(doraReady) then -- 845
			needReload = App.version ~= Content:load(doraReady) -- 846
		else -- 847
			needReload = true -- 847
		end -- 845
		if needReload then -- 848
			Content:remove(Path(Content.writablePath, ".www")) -- 849
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.writablePath, ".www")) -- 850
			Content:save(doraReady, App.version) -- 854
			print("Dora Dora is ready!") -- 855
		end -- 848
	end -- 844
	if HttpServer:start(8866) then -- 856
		local localIP = HttpServer.localIP -- 857
		if localIP == "" then -- 858
			localIP = "localhost" -- 858
		end -- 858
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 859
		return HttpServer:startWS(8868) -- 860
	else -- 862
		status.url = nil -- 862
		return print("8866 Port not available!") -- 863
	end -- 856
end) -- 841
return _module_0 -- 863
