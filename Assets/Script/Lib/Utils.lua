-- [yue]: Script/Lib/Utils.yue
local table = _G.table -- 1
local math = _G.math -- 1
local thread = dora.thread -- 1
local getmetatable = _G.getmetatable -- 1
local error = _G.error -- 1
local ipairs = _G.ipairs -- 1
local pairs = _G.pairs -- 1
local select = _G.select -- 1
local assert = _G.assert -- 1
local load = _G.load -- 1
local Vec2 = dora.Vec2 -- 1
local string = _G.string -- 1
local _module_0 = { } -- 1
local insert, remove, concat, sort = table.insert, table.remove, table.concat, table.sort -- 2
local floor, ceil = math.floor, math.ceil -- 3
local type, tostring, setmetatable, table, rawset, rawget = _G.type, _G.tostring, _G.setmetatable, _G.table, _G.rawset, _G.rawget -- 4
local StructUpdated -- 6
StructUpdated = function(self) -- 6
	local update = rawget(self, "__update") -- 7
	if not update then -- 8
		return rawset(self, "__update", thread(function() -- 9
			local notify = rawget(self, "__notify") -- 10
			notify("Updated") -- 11
			return rawset(self, "__update", nil) -- 12
		end)) -- 12
	end -- 8
end -- 6
local StructToString -- 13
StructToString = function(self) -- 13
	local structDef = getmetatable(self) -- 14
	local content = { } -- 15
	local ordered = true -- 16
	local count -- 17
	if #structDef == 0 then -- 17
		count = #self -- 17
	else -- 17
		count = #structDef + 1 -- 17
	end -- 17
	for i = 1, count do -- 18
		local value = self[i] -- 19
		if value == nil then -- 20
			ordered = false -- 21
			goto _continue_0 -- 22
		else -- 24
			value = (type(value) == 'string' and "\"" .. tostring(value) .. "\"" or tostring(value)) -- 24
			if ordered then -- 25
				content[#content + 1] = value -- 26
			else -- 28
				content[#content + 1] = "[" .. tostring(i) .. "]=" .. tostring(value) -- 28
			end -- 25
		end -- 20
		::_continue_0:: -- 19
	end -- 28
	return "{" .. (concat(content, ',')) .. "}" -- 29
end -- 13
local StructDefMeta = { -- 31
	set = function(self, index, item) -- 31
		index = index + 1 -- 32
		if 1 <= index and index <= #self then -- 33
			self[index] = item -- 34
			local notify = rawget(self, "__notify") -- 35
			if notify then -- 36
				notify("Changed", index - 1, item) -- 37
				return StructUpdated(self) -- 38
			end -- 36
		else -- 40
			return error("Access index out of range.") -- 40
		end -- 33
	end, -- 31
	get = function(self, index) -- 41
		if 1 <= index and index < #self then -- 42
			return self[index + 1] -- 43
		else -- 45
			return nil -- 45
		end -- 42
	end, -- 41
	insert = function(self, argA, argB) -- 46
		local item, index -- 47
		if argB then -- 48
			item = argB -- 49
			index = argA + 1 -- 50
			if index > #self then -- 51
				index = #self + 1 -- 52
			elseif index < 1 then -- 53
				index = 1 -- 54
			end -- 51
		else -- 56
			item = argA -- 56
			index = #self + 1 -- 57
		end -- 48
		insert(self, index, item) -- 58
		local notify = rawget(self, "__notify") -- 59
		if notify then -- 60
			notify("Added", index - 1, item) -- 61
			StructUpdated(self) -- 62
		end -- 60
		return item -- 63
	end, -- 46
	remove = function(self, arg) -- 64
		local item, index -- 65
		for i = 2, #self do -- 66
			if self[i] == arg then -- 67
				item = arg -- 68
				index = i -- 69
				remove(self, index) -- 70
				break -- 71
			end -- 67
		end -- 71
		if index then -- 72
			local notify = rawget(self, "__notify") -- 73
			if notify then -- 74
				notify("Removed", index - 1, item) -- 75
				StructUpdated(self) -- 76
			end -- 74
		end -- 72
		return item -- 77
	end, -- 64
	removeAt = function(self, index) -- 78
		local length = #self -- 79
		local item -- 80
		if index then -- 80
			if 0 < index and index < length then -- 81
				index = index + 1 -- 82
				item = remove(self, index) -- 83
			else -- 85
				item = nil -- 85
			end -- 81
		else -- 87
			if length > 1 then -- 87
				index = length -- 88
				item = remove(self, index) -- 89
			else -- 91
				item = nil -- 91
			end -- 87
		end -- 80
		if item then -- 92
			local notify = rawget(self, "__notify") -- 93
			if notify then -- 94
				notify("Removed", index - 1, item) -- 95
				StructUpdated(self) -- 96
			end -- 94
		end -- 92
		return item -- 97
	end, -- 78
	clear = function(self) -- 98
		local notify = rawget(self, "__notify") -- 99
		for index = #self, 2, -1 do -- 100
			local item = remove(self) -- 101
			if notify then -- 102
				notify("Removed", index - 1, item) -- 103
				StructUpdated(self) -- 104
			end -- 102
		end -- 104
	end, -- 98
	each = function(self, handler) -- 105
		for index = 2, #self do -- 106
			if true == handler(self[index], index - 1) then -- 107
				return true -- 108
			end -- 107
		end -- 108
		return false -- 109
	end, -- 105
	eachAttr = function(self, handler) -- 110
		for i, v in ipairs(getmetatable(self)) do -- 111
			handler(v, self[i + 1]) -- 112
		end -- 112
	end, -- 110
	contains = function(self, item) -- 113
		for index = 2, #self do -- 114
			if item == self[index] then -- 115
				return true -- 116
			end -- 115
		end -- 116
		return false -- 117
	end, -- 113
	toArray = function(self) -- 118
		local _accum_0 = { } -- 118
		local _len_0 = 1 -- 118
		local _list_0 = self -- 118
		for _index_0 = 2, #_list_0 do -- 118
			local item = _list_0[_index_0] -- 118
			_accum_0[_len_0] = item -- 118
			_len_0 = _len_0 + 1 -- 118
		end -- 118
		return _accum_0 -- 118
	end, -- 118
	count = function(self) -- 119
		return #self - 1 -- 119
	end, -- 119
	sort = function(self, comparer) -- 120
		local arr = self:toArray() -- 121
		sort(arr, comparer) -- 122
		for i = 1, #arr do -- 123
			self:set(i, arr[i]) -- 124
		end -- 124
	end, -- 120
	__tostring = function(self) -- 125
		local content = { } -- 126
		for k, v in pairs(self) do -- 127
			if "number" == type(v) then -- 128
				content[v - 1] = k -- 129
			end -- 128
		end -- 129
		if #content > 1 then -- 130
			return concat({ -- 131
				"Struct.", -- 131
				self.__name, -- 131
				"{\"", -- 131
				concat(content, "\",\""), -- 131
				"\"}" -- 131
			}) -- 131
		else -- 133
			return "Struct." .. tostring(self.__name) .. "()" -- 133
		end -- 130
	end, -- 125
	__call = function(self, data) -- 134
		local item = { -- 135
			self.__name -- 135
		} -- 135
		if data then -- 136
			for k, v in pairs(data) do -- 137
				local key = self[k] -- 138
				if key then -- 139
					item[key] = v -- 140
				elseif type(k) == "number" then -- 141
					item[k + 1] = v -- 142
				else -- 144
					error("Initialize to an invalid field named \"" .. tostring(k) .. "\" for \"" .. tostring(self) .. "\".") -- 144
				end -- 139
			end -- 144
		end -- 136
		setmetatable(item, self) -- 145
		return item -- 146
	end -- 134
} -- 30
local StructDefs = { } -- 148
local StructHelper = { -- 150
	__call = function(self, ...) -- 150
		local structName = self.path .. self.name -- 151
		local tupleDef -- 152
		tupleDef = setmetatable({ -- 154
			__name = structName, -- 154
			__index = function(self, key) -- 155
				local item = tupleDef[key] -- 156
				if item then -- 157
					return rawget(self, item) -- 158
				else -- 160
					return StructDefMeta[key] -- 160
				end -- 157
			end, -- 155
			__newindex = function(self, key, value) -- 161
				local index = tupleDef[key] -- 162
				if index then -- 163
					local oldValue = rawget(self, index) -- 164
					if oldValue == value then -- 165
						return -- 165
					end -- 165
					rawset(self, index, value) -- 166
					local notify = rawget(self, "__notify") -- 167
					if notify then -- 168
						notify("Modified", key, value) -- 169
						return StructUpdated(self) -- 170
					end -- 168
				elseif "number" == type(key) then -- 171
					return rawset(self, key, value) -- 172
				elseif key ~= "__notify" then -- 173
					return error("Access invalid key \"" .. tostring(key) .. "\" for " .. tostring(tupleDef)) -- 174
				elseif value then -- 175
					rawset(self, "__notify", value) -- 176
					if #tupleDef == 0 then -- 177
						for i = 2, #self do -- 178
							value("Added", i - 1, self[i]) -- 179
						end -- 179
					else -- 181
						for _index_0 = 1, #tupleDef do -- 181
							local key = tupleDef[_index_0] -- 181
							value("Modified", key, self[key]) -- 182
						end -- 182
					end -- 177
					return StructUpdated(self) -- 183
				end -- 163
			end, -- 161
			__tostring = StructToString -- 184
		}, StructDefMeta) -- 153
		local count = select("#", ...) -- 186
		if count > 0 then -- 187
			local arg = select(1, ...) -- 188
			if "table" == type(arg) then -- 189
				for i, name in ipairs(arg) do -- 190
					tupleDef[i] = name -- 191
					tupleDef[name] = i + 1 -- 192
				end -- 192
			else -- 194
				for i = 1, count do -- 194
					local name = select(i, ...) -- 195
					tupleDef[i] = name -- 196
					tupleDef[name] = i + 1 -- 197
				end -- 197
			end -- 189
		end -- 187
		StructDefs[structName] = tupleDef -- 198
		return tupleDef -- 199
	end, -- 150
	__index = function(self, key) -- 200
		self.path = self.path .. self.name -- 201
		self.path = self.path .. "." -- 202
		self.name = key -- 203
		return self -- 204
	end, -- 200
	__tostring = function(self) -- 205
		local content = { } -- 206
		local path = self.path .. self.name .. "." -- 207
		local i = 1 -- 208
		for k, v in pairs(StructDefs) do -- 209
			if k:find(path, 1, true) then -- 210
				content[i] = tostring(v) -- 211
				i = i + 1 -- 212
			end -- 210
		end -- 212
		return concat(content, "\n") -- 213
	end -- 205
} -- 149
setmetatable(StructHelper, StructHelper) -- 215
local Struct -- 216
local StructLoad -- 217
StructLoad = function(data) -- 217
	if "table" == type(data) then -- 218
		local mt = StructDefs[data[1]] -- 219
		assert(mt, "Struct started with \"" .. tostring(data[1]) .. "\" is not defined.") -- 220
		setmetatable(data, mt) -- 221
		for _index_0 = 1, #data do -- 222
			local item = data[_index_0] -- 222
			StructLoad(item) -- 223
		end -- 223
	end -- 218
end -- 217
Struct = setmetatable({ -- 225
	load = function(self, ...) -- 225
		local count = select("#", ...) -- 226
		if count > 1 then -- 227
			local name = select(1, ...) -- 228
			local data = select(2, ...) -- 229
			insert(data, 1, name) -- 230
			StructLoad(data) -- 231
			return data -- 232
		else -- 234
			local arg = select(1, ...) -- 234
			local data -- 235
			do -- 235
				local _exp_0 = type(arg) -- 235
				if "string" == _exp_0 then -- 236
					if arg:sub(1, 6) ~= "return" then -- 237
						arg = "return " .. arg -- 238
					end -- 237
					data = (load(arg))() -- 239
				elseif "table" == _exp_0 then -- 240
					data = arg -- 241
				end -- 241
			end -- 241
			StructLoad(data) -- 242
			return data -- 243
		end -- 227
	end, -- 225
	clear = function(self) -- 244
		StructDefs = { } -- 245
	end, -- 244
	has = function(self, name) -- 246
		return (StructDefs[name] ~= nil) -- 246
	end -- 246
}, { -- 248
	__index = function(self, name) -- 248
		local def = StructDefs[name] -- 249
		if not def then -- 250
			StructHelper.name = name -- 251
			StructHelper.path = "" -- 252
			def = StructHelper -- 253
		end -- 250
		return def -- 254
	end, -- 248
	__tostring = function(self) -- 255
		return concat((function() -- 256
			local _accum_0 = { } -- 256
			local _len_0 = 1 -- 256
			for _, v in pairs(StructDefs) do -- 256
				_accum_0[_len_0] = tostring(v) -- 256
				_len_0 = _len_0 + 1 -- 256
			end -- 256
			return _accum_0 -- 256
		end)(), "\n") -- 256
	end -- 255
}) -- 224
_module_0["Struct"] = Struct -- 257
local Set -- 259
Set = function(list) -- 259
	local _tbl_0 = { } -- 259
	for _index_0 = 1, #list do -- 259
		local item = list[_index_0] -- 259
		_tbl_0[item] = true -- 259
	end -- 259
	return _tbl_0 -- 259
end -- 259
_module_0["Set"] = Set -- 259
local CompareTable -- 261
CompareTable = function(olds, news) -- 261
	local itemsToDel = { } -- 262
	local itemSet = Set(news) -- 263
	for _index_0 = 1, #olds do -- 264
		local item = olds[_index_0] -- 264
		if not itemSet[item] then -- 265
			itemsToDel[#itemsToDel + 1] = item -- 266
		end -- 265
	end -- 266
	local itemsToAdd = { } -- 267
	itemSet = Set(olds) -- 268
	for _index_0 = 1, #news do -- 269
		local item = news[_index_0] -- 269
		if not itemSet[item] then -- 270
			itemsToAdd[#itemsToAdd + 1] = item -- 271
		end -- 270
	end -- 271
	return itemsToAdd, itemsToDel -- 272
end -- 261
_module_0["CompareTable"] = CompareTable -- 272
local Round -- 274
Round = function(val) -- 274
	if type(val) == "number" then -- 275
		return val > 0 and floor(val + 0.5) or ceil(val - 0.5) -- 276
	else -- 278
		return Vec2(val.x > 0 and floor(val.x + 0.5) or ceil(val.x - 0.5), val.y > 0 and floor(val.y + 0.5) or ceil(val.y - 0.5)) -- 281
	end -- 275
end -- 274
_module_0["Round"] = Round -- 281
local IsValidPath -- 283
IsValidPath = function(filename) -- 283
	return not filename:match("[\\/|:*?<>\"]") -- 283
end -- 283
_module_0["IsValidPath"] = IsValidPath -- 283
local allowedUseOfGlobals = Set({ -- 286
	"Dora", -- 286
	"dora", -- 287
	"require", -- 288
	"_G" -- 289
}) -- 285
local LintYueGlobals -- 291
LintYueGlobals = function(luaCodes, globals, globalInLocal) -- 291
	if globalInLocal == nil then -- 291
		globalInLocal = true -- 291
	end -- 291
	local errors = { } -- 292
	local requireModules = { } -- 293
	luaCodes = luaCodes:gsub("^local _module_[^\r\n]*[^\r\n]+", "") -- 294
	local importCodes = luaCodes:match("^%s*local%s*_ENV%s*=%s*Dora%(([^%)]-)%)") -- 295
	local importItems -- 296
	if importCodes then -- 296
		do -- 297
			local _accum_0 = { } -- 297
			local _len_0 = 1 -- 297
			for item in importCodes:gmatch("%s*([^,\n\r]+)%s*") do -- 297
				local getImport = load("return " .. tostring(item)) -- 298
				local importItem -- 299
				if getImport ~= nil then -- 299
					importItem = getImport() -- 299
				end -- 299
				if not importItem or "table" ~= type(importItem) then -- 300
					goto _continue_0 -- 300
				end -- 300
				_accum_0[_len_0] = { -- 301
					importItem, -- 301
					item -- 301
				} -- 301
				_len_0 = _len_0 + 1 -- 301
				::_continue_0:: -- 298
			end -- 301
			importItems = _accum_0 -- 297
		end -- 301
	else -- 302
		importItems = { } -- 302
	end -- 296
	local importSet = { } -- 303
	for _index_0 = 1, #globals do -- 304
		local globalVar = globals[_index_0] -- 304
		local name, line, col = globalVar[1], globalVar[2], globalVar[3] -- 305
		if allowedUseOfGlobals[name] then -- 306
			goto _continue_1 -- 306
		end -- 306
		if _G[name] then -- 307
			if globalInLocal then -- 308
				requireModules[#requireModules + 1] = "local " .. tostring(name) .. " = _G." .. tostring(name) .. " -- 1" -- 309
			end -- 308
			goto _continue_1 -- 310
		end -- 307
		local findModule = false -- 311
		if importCodes then -- 312
			if dora[name] then -- 313
				requireModules[#requireModules + 1] = "local " .. tostring(name) .. " = dora." .. tostring(name) .. " -- 1" -- 314
				findModule = true -- 315
			else -- 317
				for i, _des_0 in ipairs(importItems) do -- 317
					local mod, modName = _des_0[1], _des_0[2] -- 317
					if (mod[name] ~= nil) then -- 318
						local moduleName = "_module_" .. tostring(i - 1) -- 319
						if not importSet[mod] then -- 320
							importSet[mod] = true -- 321
							requireModules[#requireModules + 1] = "local " .. tostring(moduleName) .. " = " .. tostring(modName) .. " -- 1" -- 322
						end -- 320
						requireModules[#requireModules + 1] = "local " .. tostring(name) .. " = " .. tostring(moduleName) .. "." .. tostring(name) .. " -- 1" -- 323
						findModule = true -- 324
						break -- 325
					end -- 318
				end -- 325
			end -- 313
		end -- 312
		if not findModule then -- 326
			errors[#errors + 1] = globalVar -- 327
		end -- 326
		::_continue_1:: -- 305
	end -- 327
	if #errors > 0 then -- 328
		return false, errors -- 329
	else -- 331
		return true, table.concat(requireModules, "\n") -- 331
	end -- 328
end -- 291
_module_0["LintYueGlobals"] = LintYueGlobals -- 331
local GSplit -- 333
GSplit = function(text, pattern, plain) -- 333
	local splitStart, length = 1, #text -- 334
	return function() -- 335
		if splitStart then -- 336
			local sepStart, sepEnd = string.find(text, pattern, splitStart, plain) -- 337
			local ret -- 338
			if not sepStart then -- 339
				ret = string.sub(text, splitStart) -- 340
				splitStart = nil -- 341
			elseif sepEnd < sepStart then -- 342
				ret = string.sub(text, splitStart, sepStart) -- 343
				if sepStart < length then -- 344
					splitStart = sepStart + 1 -- 345
				else -- 347
					splitStart = nil -- 347
				end -- 344
			else -- 349
				ret = sepStart > splitStart and string.sub(text, splitStart, sepStart - 1) or '' -- 349
				splitStart = sepEnd + 1 -- 350
			end -- 339
			return ret -- 351
		end -- 336
	end -- 351
end -- 333
_module_0["GSplit"] = GSplit -- 351
return _module_0 -- 351
