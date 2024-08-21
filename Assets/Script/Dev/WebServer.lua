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
local json = Dora.json -- 1
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
					if not line:match("[%.:]$") then -- 451
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
	local webProfiler, drawerWidth -- 543
	do -- 543
		local _obj_0 = Entry.getConfig() -- 543
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 543
	end -- 543
	local engineDev = Entry.getEngineDev() -- 544
	return { -- 546
		platform = App.platform, -- 546
		locale = App.locale, -- 547
		version = App.version, -- 548
		engineDev = engineDev, -- 549
		webProfiler = webProfiler, -- 550
		drawerWidth = drawerWidth -- 551
	} -- 551
end) -- 541
HttpServer:post("/new", function(req) -- 553
	do -- 554
		local _type_0 = type(req) -- 554
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 554
		if _tab_0 then -- 554
			local path -- 554
			do -- 554
				local _obj_0 = req.body -- 554
				local _type_1 = type(_obj_0) -- 554
				if "table" == _type_1 or "userdata" == _type_1 then -- 554
					path = _obj_0.path -- 554
				end -- 573
			end -- 573
			local content -- 554
			do -- 554
				local _obj_0 = req.body -- 554
				local _type_1 = type(_obj_0) -- 554
				if "table" == _type_1 or "userdata" == _type_1 then -- 554
					content = _obj_0.content -- 554
				end -- 573
			end -- 573
			local folder -- 554
			do -- 554
				local _obj_0 = req.body -- 554
				local _type_1 = type(_obj_0) -- 554
				if "table" == _type_1 or "userdata" == _type_1 then -- 554
					folder = _obj_0.folder -- 554
				end -- 573
			end -- 573
			if path ~= nil and content ~= nil and folder ~= nil then -- 554
				if not Content:exist(path) then -- 555
					local parent = Path:getPath(path) -- 556
					local files = Content:getFiles(parent) -- 557
					if folder then -- 558
						local name = Path:getFilename(path):lower() -- 559
						for _index_0 = 1, #files do -- 560
							local file = files[_index_0] -- 560
							if name == Path:getFilename(file):lower() then -- 561
								return { -- 562
									success = false -- 562
								} -- 562
							end -- 561
						end -- 562
						if Content:mkdir(path) then -- 563
							return { -- 564
								success = true -- 564
							} -- 564
						end -- 563
					else -- 566
						local name = Path:getName(path):lower() -- 566
						for _index_0 = 1, #files do -- 567
							local file = files[_index_0] -- 567
							if name == Path:getName(file):lower() then -- 568
								if ("d" == Path:getExt(name)) and (Path:getExt(file) ~= Path:getExt(path)) then -- 569
									goto _continue_0 -- 570
								end -- 569
								return { -- 571
									success = false -- 571
								} -- 571
							end -- 568
							::_continue_0:: -- 568
						end -- 571
						if Content:save(path, content) then -- 572
							return { -- 573
								success = true -- 573
							} -- 573
						end -- 572
					end -- 558
				end -- 555
			end -- 554
		end -- 573
	end -- 573
	return { -- 553
		success = false -- 553
	} -- 573
end) -- 553
HttpServer:post("/delete", function(req) -- 575
	do -- 576
		local _type_0 = type(req) -- 576
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 576
		if _tab_0 then -- 576
			local path -- 576
			do -- 576
				local _obj_0 = req.body -- 576
				local _type_1 = type(_obj_0) -- 576
				if "table" == _type_1 or "userdata" == _type_1 then -- 576
					path = _obj_0.path -- 576
				end -- 589
			end -- 589
			if path ~= nil then -- 576
				if Content:exist(path) then -- 577
					local parent = Path:getPath(path) -- 578
					local files = Content:getFiles(parent) -- 579
					local name = Path:getName(path):lower() -- 580
					local ext = Path:getExt(path) -- 581
					for _index_0 = 1, #files do -- 582
						local file = files[_index_0] -- 582
						if name == Path:getName(file):lower() then -- 583
							local _exp_0 = Path:getExt(file) -- 584
							if "tl" == _exp_0 then -- 584
								if ("vs" == ext) then -- 584
									Content:remove(Path(parent, file)) -- 585
								end -- 584
							elseif "lua" == _exp_0 then -- 586
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 586
									Content:remove(Path(parent, file)) -- 587
								end -- 586
							end -- 587
						end -- 583
					end -- 587
					if Content:remove(path) then -- 588
						return { -- 589
							success = true -- 589
						} -- 589
					end -- 588
				end -- 577
			end -- 576
		end -- 589
	end -- 589
	return { -- 575
		success = false -- 575
	} -- 589
end) -- 575
HttpServer:post("/rename", function(req) -- 591
	do -- 592
		local _type_0 = type(req) -- 592
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 592
		if _tab_0 then -- 592
			local old -- 592
			do -- 592
				local _obj_0 = req.body -- 592
				local _type_1 = type(_obj_0) -- 592
				if "table" == _type_1 or "userdata" == _type_1 then -- 592
					old = _obj_0.old -- 592
				end -- 622
			end -- 622
			local new -- 592
			do -- 592
				local _obj_0 = req.body -- 592
				local _type_1 = type(_obj_0) -- 592
				if "table" == _type_1 or "userdata" == _type_1 then -- 592
					new = _obj_0.new -- 592
				end -- 622
			end -- 622
			if old ~= nil and new ~= nil then -- 592
				if Content:exist(old) and not Content:exist(new) then -- 593
					local parent = Path:getPath(new) -- 594
					local files = Content:getFiles(parent) -- 595
					if Content:isdir(old) then -- 596
						local name = Path:getFilename(new):lower() -- 597
						for _index_0 = 1, #files do -- 598
							local file = files[_index_0] -- 598
							if name == Path:getFilename(file):lower() then -- 599
								return { -- 600
									success = false -- 600
								} -- 600
							end -- 599
						end -- 600
					else -- 602
						local name = Path:getName(new):lower() -- 602
						for _index_0 = 1, #files do -- 603
							local file = files[_index_0] -- 603
							if name == Path:getName(file):lower() then -- 604
								if ("d" == Path:getExt(name)) and (Path:getExt(file) ~= Path:getExt(new)) then -- 605
									goto _continue_0 -- 606
								end -- 605
								return { -- 607
									success = false -- 607
								} -- 607
							end -- 604
							::_continue_0:: -- 604
						end -- 607
					end -- 596
					if Content:move(old, new) then -- 608
						local newParent = Path:getPath(new) -- 609
						parent = Path:getPath(old) -- 610
						files = Content:getFiles(parent) -- 611
						local newName = Path:getName(new) -- 612
						local oldName = Path:getName(old) -- 613
						local name = oldName:lower() -- 614
						local ext = Path:getExt(old) -- 615
						for _index_0 = 1, #files do -- 616
							local file = files[_index_0] -- 616
							if name == Path:getName(file):lower() then -- 617
								local _exp_0 = Path:getExt(file) -- 618
								if "tl" == _exp_0 then -- 618
									if ("vs" == ext) then -- 618
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 619
									end -- 618
								elseif "lua" == _exp_0 then -- 620
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "xml" == ext) then -- 620
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 621
									end -- 620
								end -- 621
							end -- 617
						end -- 621
						return { -- 622
							success = true -- 622
						} -- 622
					end -- 608
				end -- 593
			end -- 592
		end -- 622
	end -- 622
	return { -- 591
		success = false -- 591
	} -- 622
end) -- 591
HttpServer:postSchedule("/read", function(req) -- 624
	do -- 625
		local _type_0 = type(req) -- 625
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 625
		if _tab_0 then -- 625
			local path -- 625
			do -- 625
				local _obj_0 = req.body -- 625
				local _type_1 = type(_obj_0) -- 625
				if "table" == _type_1 or "userdata" == _type_1 then -- 625
					path = _obj_0.path -- 625
				end -- 628
			end -- 628
			if path ~= nil then -- 625
				if Content:exist(path) then -- 626
					local content = Content:loadAsync(path) -- 627
					if content then -- 627
						return { -- 628
							content = content, -- 628
							success = true -- 628
						} -- 628
					end -- 627
				end -- 626
			end -- 625
		end -- 628
	end -- 628
	return { -- 624
		success = false -- 624
	} -- 628
end) -- 624
local compileFileAsync -- 630
compileFileAsync = function(inputFile, sourceCodes) -- 630
	local file = inputFile -- 631
	local searchPath -- 632
	do -- 632
		local dir = getProjectDirFromFile(inputFile) -- 632
		if dir then -- 632
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 633
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 634
		else -- 636
			file = Path:getRelative(inputFile, Path(Content.writablePath)) -- 636
			if file:sub(1, 2) == ".." then -- 637
				file = Path:getRelative(inputFile, Path(Content.assetPath)) -- 638
			end -- 637
			searchPath = "" -- 639
		end -- 632
	end -- 632
	local outputFile = Path:replaceExt(inputFile, "lua") -- 640
	local yueext = yue.options.extension -- 641
	local resultCodes = nil -- 642
	do -- 643
		local _exp_0 = Path:getExt(inputFile) -- 643
		if yueext == _exp_0 then -- 643
			yue.compile(inputFile, outputFile, searchPath, function(codes, _err, globals) -- 644
				if not codes then -- 645
					return -- 645
				end -- 645
				local success, result = LintYueGlobals(codes, globals) -- 646
				if not success then -- 647
					return -- 647
				end -- 647
				if codes == "" then -- 648
					return nil -- 648
				end -- 648
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 649
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 650
				codes = codes:gsub("^\n*", "") -- 651
				if not (result == "") then -- 652
					result = result .. "\n" -- 652
				end -- 652
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 653
				return resultCodes -- 654
			end, function(success) -- 644
				if not success then -- 655
					Content:remove(outputFile) -- 656
					resultCodes = false -- 657
				end -- 655
			end) -- 644
		elseif "tl" == _exp_0 then -- 658
			local codes = teal.toluaAsync(sourceCodes, file, searchPath) -- 659
			if codes then -- 659
				resultCodes = codes -- 660
				Content:saveAsync(outputFile, codes) -- 661
			else -- 663
				Content:remove(outputFile) -- 663
				resultCodes = false -- 664
			end -- 659
		elseif "xml" == _exp_0 then -- 665
			local codes = xml.tolua(sourceCodes) -- 666
			if codes then -- 666
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 667
				Content:saveAsync(outputFile, resultCodes) -- 668
			else -- 670
				Content:remove(outputFile) -- 670
				resultCodes = false -- 671
			end -- 666
		end -- 671
	end -- 671
	wait(function() -- 672
		return resultCodes ~= nil -- 672
	end) -- 672
	if resultCodes then -- 673
		return resultCodes -- 673
	end -- 673
	return nil -- 673
end -- 630
HttpServer:postSchedule("/write", function(req) -- 675
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
				end -- 682
			end -- 682
			local content -- 676
			do -- 676
				local _obj_0 = req.body -- 676
				local _type_1 = type(_obj_0) -- 676
				if "table" == _type_1 or "userdata" == _type_1 then -- 676
					content = _obj_0.content -- 676
				end -- 682
			end -- 682
			if path ~= nil and content ~= nil then -- 676
				if Content:saveAsync(path, content) then -- 677
					do -- 678
						local _exp_0 = Path:getExt(path) -- 678
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 678
							if '' == Path:getExt(Path:getName(path)) then -- 679
								local resultCodes = compileFileAsync(path, content) -- 680
								return { -- 681
									success = true, -- 681
									resultCodes = resultCodes -- 681
								} -- 681
							end -- 679
						end -- 681
					end -- 681
					return { -- 682
						success = true -- 682
					} -- 682
				end -- 677
			end -- 676
		end -- 682
	end -- 682
	return { -- 675
		success = false -- 675
	} -- 682
end) -- 675
local extentionLevels = { -- 685
	vs = 2, -- 685
	ts = 1, -- 686
	tsx = 1, -- 687
	tl = 1, -- 688
	yue = 1, -- 689
	xml = 1, -- 690
	lua = 0 -- 691
} -- 684
local _anon_func_4 = function(Content, Path, visitAssets, zh) -- 760
	local _with_0 = visitAssets(Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")) -- 759
	_with_0.title = zh and "说明文档" or "Readme" -- 760
	return _with_0 -- 759
end -- 759
local _anon_func_5 = function(Content, Path, visitAssets, zh) -- 762
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")) -- 761
	_with_0.title = zh and "接口文档" or "API Doc" -- 762
	return _with_0 -- 761
end -- 761
local _anon_func_6 = function(Content, Path, visitAssets, zh) -- 764
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Tools")) -- 763
	_with_0.title = zh and "开发工具" or "Tools" -- 764
	return _with_0 -- 763
end -- 763
local _anon_func_7 = function(Content, Path, visitAssets, zh) -- 766
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Example")) -- 765
	_with_0.title = zh and "代码示例" or "Example" -- 766
	return _with_0 -- 765
end -- 765
local _anon_func_8 = function(Content, Path, visitAssets, zh) -- 768
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Game")) -- 767
	_with_0.title = zh and "游戏演示" or "Demo Game" -- 768
	return _with_0 -- 767
end -- 767
local _anon_func_9 = function(Content, Path, visitAssets, zh) -- 770
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Test")) -- 769
	_with_0.title = zh and "功能测试" or "Test" -- 770
	return _with_0 -- 769
end -- 769
local _anon_func_10 = function(Content, Path, engineDev, visitAssets, zh) -- 782
	local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Lib")) -- 774
	if engineDev then -- 775
		local _list_0 = _with_0.children -- 776
		for _index_0 = 1, #_list_0 do -- 776
			local child = _list_0[_index_0] -- 776
			if not (child.title == "Dora") then -- 777
				goto _continue_0 -- 777
			end -- 777
			local title = zh and "zh-Hans" or "en" -- 778
			do -- 779
				local _accum_0 = { } -- 779
				local _len_0 = 1 -- 779
				local _list_1 = child.children -- 779
				for _index_1 = 1, #_list_1 do -- 779
					local c = _list_1[_index_1] -- 779
					if c.title ~= title then -- 779
						_accum_0[_len_0] = c -- 779
						_len_0 = _len_0 + 1 -- 779
					end -- 779
				end -- 779
				child.children = _accum_0 -- 779
			end -- 779
			break -- 780
			::_continue_0:: -- 777
		end -- 780
	else -- 782
		local _accum_0 = { } -- 782
		local _len_0 = 1 -- 782
		local _list_0 = _with_0.children -- 782
		for _index_0 = 1, #_list_0 do -- 782
			local child = _list_0[_index_0] -- 782
			if child.title ~= "Dora" then -- 782
				_accum_0[_len_0] = child -- 782
				_len_0 = _len_0 + 1 -- 782
			end -- 782
		end -- 782
		_with_0.children = _accum_0 -- 782
	end -- 775
	return _with_0 -- 774
end -- 774
local _anon_func_11 = function(Content, Path, engineDev, visitAssets) -- 783
	if engineDev then -- 783
		local _with_0 = visitAssets(Path(Content.assetPath, "Script", "Dev")) -- 784
		local _obj_0 = _with_0.children -- 785
		_obj_0[#_obj_0 + 1] = { -- 786
			key = Path(Content.assetPath, "Script", "init.yue"), -- 786
			dir = false, -- 787
			title = "init.yue" -- 788
		} -- 785
		return _with_0 -- 784
	end -- 783
end -- 783
local _anon_func_3 = function(Content, Path, engineDev, visitAssets, zh) -- 791
	local _tab_0 = { -- 754
		{ -- 755
			key = Path(Content.assetPath), -- 755
			dir = true, -- 756
			title = zh and "内置资源" or "Built-in", -- 757
			children = { -- 759
				_anon_func_4(Content, Path, visitAssets, zh), -- 759
				_anon_func_5(Content, Path, visitAssets, zh), -- 761
				_anon_func_6(Content, Path, visitAssets, zh), -- 763
				_anon_func_7(Content, Path, visitAssets, zh), -- 765
				_anon_func_8(Content, Path, visitAssets, zh), -- 767
				_anon_func_9(Content, Path, visitAssets, zh), -- 769
				visitAssets(Path(Content.assetPath, "Image")), -- 771
				visitAssets(Path(Content.assetPath, "Spine")), -- 772
				visitAssets(Path(Content.assetPath, "Font")), -- 773
				_anon_func_10(Content, Path, engineDev, visitAssets, zh), -- 774
				_anon_func_11(Content, Path, engineDev, visitAssets) -- 783
			} -- 758
		} -- 754
	} -- 792
	local _obj_0 = visitAssets(Content.writablePath, true) -- 792
	local _idx_0 = #_tab_0 + 1 -- 792
	for _index_0 = 1, #_obj_0 do -- 792
		local _value_0 = _obj_0[_index_0] -- 792
		_tab_0[_idx_0] = _value_0 -- 792
		_idx_0 = _idx_0 + 1 -- 792
	end -- 792
	return _tab_0 -- 791
end -- 754
HttpServer:post("/assets", function() -- 693
	local Entry = require("Script.Dev.Entry") -- 694
	local engineDev = Entry.getEngineDev() -- 695
	local visitAssets -- 696
	visitAssets = function(path, root) -- 696
		local children = nil -- 697
		local dirs = Content:getDirs(path) -- 698
		for _index_0 = 1, #dirs do -- 699
			local dir = dirs[_index_0] -- 699
			if root then -- 700
				if ".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir then -- 700
					goto _continue_0 -- 701
				end -- 701
			elseif dir == ".git" then -- 702
				goto _continue_0 -- 703
			end -- 700
			if not children then -- 704
				children = { } -- 704
			end -- 704
			children[#children + 1] = visitAssets(Path(path, dir)) -- 705
			::_continue_0:: -- 700
		end -- 705
		local files = Content:getFiles(path) -- 706
		local names = { } -- 707
		for _index_0 = 1, #files do -- 708
			local file = files[_index_0] -- 708
			if file:match("^%.") then -- 709
				goto _continue_1 -- 709
			end -- 709
			local name = Path:getName(file) -- 710
			local ext = names[name] -- 711
			if ext then -- 711
				local lv1 -- 712
				do -- 712
					local _exp_0 = extentionLevels[ext] -- 712
					if _exp_0 ~= nil then -- 712
						lv1 = _exp_0 -- 712
					else -- 712
						lv1 = -1 -- 712
					end -- 712
				end -- 712
				ext = Path:getExt(file) -- 713
				local lv2 -- 714
				do -- 714
					local _exp_0 = extentionLevels[ext] -- 714
					if _exp_0 ~= nil then -- 714
						lv2 = _exp_0 -- 714
					else -- 714
						lv2 = -1 -- 714
					end -- 714
				end -- 714
				if lv2 > lv1 then -- 715
					names[name] = ext -- 716
				elseif lv2 == lv1 then -- 717
					names[name .. '.' .. ext] = "" -- 718
				end -- 715
			else -- 720
				ext = Path:getExt(file) -- 720
				if not extentionLevels[ext] then -- 721
					names[file] = "" -- 722
				else -- 724
					names[name] = ext -- 724
				end -- 721
			end -- 711
			::_continue_1:: -- 709
		end -- 724
		do -- 725
			local _accum_0 = { } -- 725
			local _len_0 = 1 -- 725
			for name, ext in pairs(names) do -- 725
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 725
				_len_0 = _len_0 + 1 -- 725
			end -- 725
			files = _accum_0 -- 725
		end -- 725
		for _index_0 = 1, #files do -- 726
			local file = files[_index_0] -- 726
			if not children then -- 727
				children = { } -- 727
			end -- 727
			children[#children + 1] = { -- 729
				key = Path(path, file), -- 729
				dir = false, -- 730
				title = file -- 731
			} -- 728
		end -- 732
		if children then -- 733
			table.sort(children, function(a, b) -- 734
				if a.dir == b.dir then -- 735
					return a.title < b.title -- 736
				else -- 738
					return a.dir -- 738
				end -- 735
			end) -- 734
		end -- 733
		if root then -- 739
			return children -- 740
		else -- 742
			return { -- 743
				key = path, -- 743
				dir = true, -- 744
				title = Path:getFilename(path), -- 745
				children = children -- 746
			} -- 747
		end -- 739
	end -- 696
	local zh = (App.locale:match("^zh") ~= nil) -- 748
	return { -- 750
		key = Content.writablePath, -- 750
		dir = true, -- 751
		title = "Assets", -- 752
		children = _anon_func_3(Content, Path, engineDev, visitAssets, zh) -- 753
	} -- 794
end) -- 693
HttpServer:postSchedule("/run", function(req) -- 796
	do -- 797
		local _type_0 = type(req) -- 797
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 797
		if _tab_0 then -- 797
			local file -- 797
			do -- 797
				local _obj_0 = req.body -- 797
				local _type_1 = type(_obj_0) -- 797
				if "table" == _type_1 or "userdata" == _type_1 then -- 797
					file = _obj_0.file -- 797
				end -- 812
			end -- 812
			local asProj -- 797
			do -- 797
				local _obj_0 = req.body -- 797
				local _type_1 = type(_obj_0) -- 797
				if "table" == _type_1 or "userdata" == _type_1 then -- 797
					asProj = _obj_0.asProj -- 797
				end -- 812
			end -- 812
			if file ~= nil and asProj ~= nil then -- 797
				if not Content:isAbsolutePath(file) then -- 798
					local devFile = Path(Content.writablePath, file) -- 799
					if Content:exist(devFile) then -- 800
						file = devFile -- 800
					end -- 800
				end -- 798
				local Entry = require("Script.Dev.Entry") -- 801
				if asProj then -- 802
					local proj = getProjectDirFromFile(file) -- 803
					if proj then -- 803
						Entry.allClear() -- 804
						local target = Path(proj, "init") -- 805
						local success, err = Entry.enterEntryAsync({ -- 806
							"Project", -- 806
							target -- 806
						}) -- 806
						target = Path:getName(Path:getPath(target)) -- 807
						return { -- 808
							success = success, -- 808
							target = target, -- 808
							err = err -- 808
						} -- 808
					end -- 803
				end -- 802
				Entry.allClear() -- 809
				file = Path:replaceExt(file, "") -- 810
				local success, err = Entry.enterEntryAsync({ -- 811
					Path:getName(file), -- 811
					file -- 811
				}) -- 811
				return { -- 812
					success = success, -- 812
					err = err -- 812
				} -- 812
			end -- 797
		end -- 812
	end -- 812
	return { -- 796
		success = false -- 796
	} -- 812
end) -- 796
HttpServer:postSchedule("/stop", function() -- 814
	local Entry = require("Script.Dev.Entry") -- 815
	return { -- 816
		success = Entry.stop() -- 816
	} -- 816
end) -- 814
HttpServer:postSchedule("/zip", function(req) -- 818
	do -- 819
		local _type_0 = type(req) -- 819
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 819
		if _tab_0 then -- 819
			local path -- 819
			do -- 819
				local _obj_0 = req.body -- 819
				local _type_1 = type(_obj_0) -- 819
				if "table" == _type_1 or "userdata" == _type_1 then -- 819
					path = _obj_0.path -- 819
				end -- 822
			end -- 822
			local zipFile -- 819
			do -- 819
				local _obj_0 = req.body -- 819
				local _type_1 = type(_obj_0) -- 819
				if "table" == _type_1 or "userdata" == _type_1 then -- 819
					zipFile = _obj_0.zipFile -- 819
				end -- 822
			end -- 822
			if path ~= nil and zipFile ~= nil then -- 819
				Content:mkdir(Path:getPath(zipFile)) -- 820
				return { -- 821
					success = Content:zipAsync(path, zipFile, function(file) -- 821
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 822
					end) -- 821
				} -- 822
			end -- 819
		end -- 822
	end -- 822
	return { -- 818
		success = false -- 818
	} -- 822
end) -- 818
HttpServer:postSchedule("/unzip", function(req) -- 824
	do -- 825
		local _type_0 = type(req) -- 825
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 825
		if _tab_0 then -- 825
			local zipFile -- 825
			do -- 825
				local _obj_0 = req.body -- 825
				local _type_1 = type(_obj_0) -- 825
				if "table" == _type_1 or "userdata" == _type_1 then -- 825
					zipFile = _obj_0.zipFile -- 825
				end -- 827
			end -- 827
			local path -- 825
			do -- 825
				local _obj_0 = req.body -- 825
				local _type_1 = type(_obj_0) -- 825
				if "table" == _type_1 or "userdata" == _type_1 then -- 825
					path = _obj_0.path -- 825
				end -- 827
			end -- 827
			if zipFile ~= nil and path ~= nil then -- 825
				return { -- 826
					success = Content:unzipAsync(zipFile, path, function(file) -- 826
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 827
					end) -- 826
				} -- 827
			end -- 825
		end -- 827
	end -- 827
	return { -- 824
		success = false -- 824
	} -- 827
end) -- 824
HttpServer:post("/editingInfo", function(req) -- 829
	local Entry = require("Script.Dev.Entry") -- 830
	local config = Entry.getConfig() -- 831
	local _type_0 = type(req) -- 832
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 832
	local _match_0 = false -- 832
	if _tab_0 then -- 832
		local editingInfo -- 832
		do -- 832
			local _obj_0 = req.body -- 832
			local _type_1 = type(_obj_0) -- 832
			if "table" == _type_1 or "userdata" == _type_1 then -- 832
				editingInfo = _obj_0.editingInfo -- 832
			end -- 834
		end -- 834
		if editingInfo ~= nil then -- 832
			_match_0 = true -- 832
			config.editingInfo = editingInfo -- 833
			return { -- 834
				success = true -- 834
			} -- 834
		end -- 832
	end -- 832
	if not _match_0 then -- 832
		if not (config.editingInfo ~= nil) then -- 836
			local folder -- 837
			if App.locale:match('^zh') then -- 837
				folder = 'zh-Hans' -- 837
			else -- 837
				folder = 'en' -- 837
			end -- 837
			config.editingInfo = json.dump({ -- 839
				index = 0, -- 839
				files = { -- 841
					{ -- 842
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 842
						title = "welcome.md" -- 843
					} -- 841
				} -- 840
			}) -- 838
		end -- 836
		return { -- 847
			success = true, -- 847
			editingInfo = config.editingInfo -- 847
		} -- 847
	end -- 847
end) -- 829
HttpServer:post("/command", function(req) -- 849
	do -- 850
		local _type_0 = type(req) -- 850
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 850
		if _tab_0 then -- 850
			local code -- 850
			do -- 850
				local _obj_0 = req.body -- 850
				local _type_1 = type(_obj_0) -- 850
				if "table" == _type_1 or "userdata" == _type_1 then -- 850
					code = _obj_0.code -- 850
				end -- 852
			end -- 852
			local log -- 850
			do -- 850
				local _obj_0 = req.body -- 850
				local _type_1 = type(_obj_0) -- 850
				if "table" == _type_1 or "userdata" == _type_1 then -- 850
					log = _obj_0.log -- 850
				end -- 852
			end -- 852
			if code ~= nil and log ~= nil then -- 850
				emit("AppCommand", code, log) -- 851
				return { -- 852
					success = true -- 852
				} -- 852
			end -- 850
		end -- 852
	end -- 852
	return { -- 849
		success = false -- 849
	} -- 852
end) -- 849
HttpServer:post("/exist", function(req) -- 854
	do -- 855
		local _type_0 = type(req) -- 855
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 855
		if _tab_0 then -- 855
			local file -- 855
			do -- 855
				local _obj_0 = req.body -- 855
				local _type_1 = type(_obj_0) -- 855
				if "table" == _type_1 or "userdata" == _type_1 then -- 855
					file = _obj_0.file -- 855
				end -- 856
			end -- 856
			if file ~= nil then -- 855
				return { -- 856
					success = Content:exist(file) -- 856
				} -- 856
			end -- 855
		end -- 856
	end -- 856
	return { -- 854
		success = false -- 854
	} -- 856
end) -- 854
local status = { } -- 858
_module_0 = status -- 859
thread(function() -- 861
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 862
	local doraReady = Path(Content.writablePath, ".www", "dora-ready") -- 863
	if Content:exist(doraWeb) then -- 864
		local needReload -- 865
		if Content:exist(doraReady) then -- 865
			needReload = App.version ~= Content:load(doraReady) -- 866
		else -- 867
			needReload = true -- 867
		end -- 865
		if needReload then -- 868
			Content:remove(Path(Content.writablePath, ".www")) -- 869
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.writablePath, ".www")) -- 870
			Content:save(doraReady, App.version) -- 874
			print("Dora Dora is ready!") -- 875
		end -- 868
	end -- 864
	if HttpServer:start(8866) then -- 876
		local localIP = HttpServer.localIP -- 877
		if localIP == "" then -- 878
			localIP = "localhost" -- 878
		end -- 878
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 879
		return HttpServer:startWS(8868) -- 880
	else -- 882
		status.url = nil -- 882
		return print("8866 Port not available!") -- 883
	end -- 876
end) -- 861
return _module_0 -- 883
