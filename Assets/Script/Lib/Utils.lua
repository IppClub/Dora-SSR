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
local insert, remove, concat, sort = table.insert, table.remove, table.concat, table.sort -- 10
local floor, ceil = math.floor, math.ceil -- 11
local type, tostring, setmetatable, table, rawset, rawget = _G.type, _G.tostring, _G.setmetatable, _G.table, _G.rawset, _G.rawget -- 12
local StructUpdated -- 14
StructUpdated = function(self) -- 14
	local update = rawget(self, "__update") -- 15
	if not update then -- 16
		return rawset(self, "__update", thread(function() -- 17
			local notify = rawget(self, "__notify") -- 18
			notify("Updated") -- 19
			return rawset(self, "__update", nil) -- 20
		end)) -- 20
	end -- 16
end -- 14
local StructToString -- 21
StructToString = function(self) -- 21
	local structDef = getmetatable(self) -- 22
	local content = { } -- 23
	local ordered = true -- 24
	local count -- 25
	if #structDef == 0 then -- 25
		count = #self -- 25
	else -- 25
		count = #structDef + 1 -- 25
	end -- 25
	for i = 1, count do -- 26
		local value = self[i] -- 27
		if value == nil then -- 28
			ordered = false -- 29
			goto _continue_0 -- 30
		else -- 32
			value = (type(value) == 'string' and "\"" .. tostring(value) .. "\"" or tostring(value)) -- 32
			if ordered then -- 33
				content[#content + 1] = value -- 34
			else -- 36
				content[#content + 1] = "[" .. tostring(i) .. "]=" .. tostring(value) -- 36
			end -- 33
		end -- 28
		::_continue_0:: -- 27
	end -- 36
	return "{" .. (concat(content, ',')) .. "}" -- 37
end -- 21
local StructDefMeta = { -- 39
	set = function(self, index, item) -- 39
		index = index + 1 -- 40
		if 1 <= index and index <= #self then -- 41
			self[index] = item -- 42
			local notify = rawget(self, "__notify") -- 43
			if notify then -- 44
				notify("Changed", index - 1, item) -- 45
				return StructUpdated(self) -- 46
			end -- 44
		else -- 48
			return error("Access index out of range.") -- 48
		end -- 41
	end, -- 39
	get = function(self, index) -- 49
		if 1 <= index and index < #self then -- 50
			return self[index + 1] -- 51
		else -- 53
			return nil -- 53
		end -- 50
	end, -- 49
	insert = function(self, argA, argB) -- 54
		local item, index -- 55
		if argB then -- 56
			item = argB -- 57
			index = argA + 1 -- 58
			if index > #self then -- 59
				index = #self + 1 -- 60
			elseif index < 1 then -- 61
				index = 1 -- 62
			end -- 59
		else -- 64
			item = argA -- 64
			index = #self + 1 -- 65
		end -- 56
		insert(self, index, item) -- 66
		local notify = rawget(self, "__notify") -- 67
		if notify then -- 68
			notify("Added", index - 1, item) -- 69
			StructUpdated(self) -- 70
		end -- 68
		return item -- 71
	end, -- 54
	remove = function(self, arg) -- 72
		local item, index -- 73
		for i = 2, #self do -- 74
			if self[i] == arg then -- 75
				item = arg -- 76
				index = i -- 77
				remove(self, index) -- 78
				break -- 79
			end -- 75
		end -- 79
		if index then -- 80
			local notify = rawget(self, "__notify") -- 81
			if notify then -- 82
				notify("Removed", index - 1, item) -- 83
				StructUpdated(self) -- 84
			end -- 82
		end -- 80
		return item -- 85
	end, -- 72
	removeAt = function(self, index) -- 86
		local length = #self -- 87
		local item -- 88
		if index then -- 88
			if 0 < index and index < length then -- 89
				index = index + 1 -- 90
				item = remove(self, index) -- 91
			else -- 93
				item = nil -- 93
			end -- 89
		else -- 95
			if length > 1 then -- 95
				index = length -- 96
				item = remove(self, index) -- 97
			else -- 99
				item = nil -- 99
			end -- 95
		end -- 88
		if item then -- 100
			local notify = rawget(self, "__notify") -- 101
			if notify then -- 102
				notify("Removed", index - 1, item) -- 103
				StructUpdated(self) -- 104
			end -- 102
		end -- 100
		return item -- 105
	end, -- 86
	clear = function(self) -- 106
		local notify = rawget(self, "__notify") -- 107
		for index = #self, 2, -1 do -- 108
			local item = remove(self) -- 109
			if notify then -- 110
				notify("Removed", index - 1, item) -- 111
				StructUpdated(self) -- 112
			end -- 110
		end -- 112
	end, -- 106
	each = function(self, handler) -- 113
		for index = 2, #self do -- 114
			if true == handler(self[index], index - 1) then -- 115
				return true -- 116
			end -- 115
		end -- 116
		return false -- 117
	end, -- 113
	eachAttr = function(self, handler) -- 118
		for i, v in ipairs(getmetatable(self)) do -- 119
			handler(v, self[i + 1]) -- 120
		end -- 120
	end, -- 118
	contains = function(self, item) -- 121
		for index = 2, #self do -- 122
			if item == self[index] then -- 123
				return true -- 124
			end -- 123
		end -- 124
		return false -- 125
	end, -- 121
	toArray = function(self) -- 126
		local _accum_0 = { } -- 126
		local _len_0 = 1 -- 126
		local _list_0 = self -- 126
		for _index_0 = 2, #_list_0 do -- 126
			local item = _list_0[_index_0] -- 126
			_accum_0[_len_0] = item -- 126
			_len_0 = _len_0 + 1 -- 126
		end -- 126
		return _accum_0 -- 126
	end, -- 126
	count = function(self) -- 127
		return #self - 1 -- 127
	end, -- 127
	sort = function(self, comparer) -- 128
		local arr = self:toArray() -- 129
		sort(arr, comparer) -- 130
		for i = 1, #arr do -- 131
			self:set(i, arr[i]) -- 132
		end -- 132
	end, -- 128
	__tostring = function(self) -- 133
		local content = { } -- 134
		for k, v in pairs(self) do -- 135
			if "number" == type(v) then -- 136
				content[v - 1] = k -- 137
			end -- 136
		end -- 137
		if #content > 1 then -- 138
			return concat({ -- 139
				"Struct.", -- 139
				self.__name, -- 139
				"{\"", -- 139
				concat(content, "\",\""), -- 139
				"\"}" -- 139
			}) -- 139
		else -- 141
			return "Struct." .. tostring(self.__name) .. "()" -- 141
		end -- 138
	end, -- 133
	__call = function(self, data) -- 142
		local item = { -- 143
			self.__name -- 143
		} -- 143
		if data then -- 144
			for k, v in pairs(data) do -- 145
				local key = self[k] -- 146
				if key then -- 147
					item[key] = v -- 148
				elseif type(k) == "number" then -- 149
					item[k + 1] = v -- 150
				else -- 152
					error("Initialize to an invalid field named \"" .. tostring(k) .. "\" for \"" .. tostring(self) .. "\".") -- 152
				end -- 147
			end -- 152
		end -- 144
		setmetatable(item, self) -- 153
		return item -- 154
	end -- 142
} -- 38
local StructDefs = { } -- 156
local StructHelper = { -- 158
	__call = function(self, ...) -- 158
		local structName = self.path .. self.name -- 159
		local tupleDef -- 160
		tupleDef = setmetatable({ -- 162
			__name = structName, -- 162
			__index = function(self, key) -- 163
				local item = tupleDef[key] -- 164
				if item then -- 165
					return rawget(self, item) -- 166
				else -- 168
					return StructDefMeta[key] -- 168
				end -- 165
			end, -- 163
			__newindex = function(self, key, value) -- 169
				local index = tupleDef[key] -- 170
				if index then -- 171
					local oldValue = rawget(self, index) -- 172
					if oldValue == value then -- 173
						return -- 173
					end -- 173
					rawset(self, index, value) -- 174
					local notify = rawget(self, "__notify") -- 175
					if notify then -- 176
						notify("Modified", key, value) -- 177
						return StructUpdated(self) -- 178
					end -- 176
				elseif "number" == type(key) then -- 179
					return rawset(self, key, value) -- 180
				elseif key ~= "__notify" then -- 181
					return error("Access invalid key \"" .. tostring(key) .. "\" for " .. tostring(tupleDef)) -- 182
				elseif value then -- 183
					rawset(self, "__notify", value) -- 184
					if #tupleDef == 0 then -- 185
						for i = 2, #self do -- 186
							value("Added", i - 1, self[i]) -- 187
						end -- 187
					else -- 189
						for _index_0 = 1, #tupleDef do -- 189
							local key = tupleDef[_index_0] -- 189
							value("Modified", key, self[key]) -- 190
						end -- 190
					end -- 185
					return StructUpdated(self) -- 191
				end -- 171
			end, -- 169
			__tostring = StructToString -- 192
		}, StructDefMeta) -- 161
		local count = select("#", ...) -- 194
		if count > 0 then -- 195
			local arg = select(1, ...) -- 196
			if "table" == type(arg) then -- 197
				for i, name in ipairs(arg) do -- 198
					tupleDef[i] = name -- 199
					tupleDef[name] = i + 1 -- 200
				end -- 200
			else -- 202
				for i = 1, count do -- 202
					local name = select(i, ...) -- 203
					tupleDef[i] = name -- 204
					tupleDef[name] = i + 1 -- 205
				end -- 205
			end -- 197
		end -- 195
		StructDefs[structName] = tupleDef -- 206
		return tupleDef -- 207
	end, -- 158
	__index = function(self, key) -- 208
		self.path = self.path .. self.name -- 209
		self.path = self.path .. "." -- 210
		self.name = key -- 211
		return self -- 212
	end, -- 208
	__tostring = function(self) -- 213
		local content = { } -- 214
		local path = self.path .. self.name .. "." -- 215
		local i = 1 -- 216
		for k, v in pairs(StructDefs) do -- 217
			if k:find(path, 1, true) then -- 218
				content[i] = tostring(v) -- 219
				i = i + 1 -- 220
			end -- 218
		end -- 220
		return concat(content, "\n") -- 221
	end -- 213
} -- 157
setmetatable(StructHelper, StructHelper) -- 223
local Struct -- 224
local StructLoad -- 225
StructLoad = function(data) -- 225
	if "table" == type(data) then -- 226
		local mt = StructDefs[data[1]] -- 227
		assert(mt, "Struct started with \"" .. tostring(data[1]) .. "\" is not defined.") -- 228
		setmetatable(data, mt) -- 229
		for _index_0 = 1, #data do -- 230
			local item = data[_index_0] -- 230
			StructLoad(item) -- 231
		end -- 231
	end -- 226
end -- 225
local _anon_func_0 = function(StructDefs, pairs, tostring) -- 264
	local _accum_0 = { } -- 264
	local _len_0 = 1 -- 264
	for _, v in pairs(StructDefs) do -- 264
		_accum_0[_len_0] = tostring(v) -- 264
		_len_0 = _len_0 + 1 -- 264
	end -- 264
	return _accum_0 -- 264
end -- 264
Struct = setmetatable({ -- 233
	load = function(self, ...) -- 233
		local count = select("#", ...) -- 234
		if count > 1 then -- 235
			local name = select(1, ...) -- 236
			local data = select(2, ...) -- 237
			insert(data, 1, name) -- 238
			StructLoad(data) -- 239
			return data -- 240
		else -- 242
			local arg = select(1, ...) -- 242
			local data -- 243
			do -- 243
				local _exp_0 = type(arg) -- 243
				if "string" == _exp_0 then -- 244
					if arg:sub(1, 6) ~= "return" then -- 245
						arg = "return " .. arg -- 246
					end -- 245
					data = (load(arg))() -- 247
				elseif "table" == _exp_0 then -- 248
					data = arg -- 249
				end -- 249
			end -- 249
			StructLoad(data) -- 250
			return data -- 251
		end -- 235
	end, -- 233
	clear = function(self) -- 252
		StructDefs = { } -- 253
	end, -- 252
	has = function(self, name) -- 254
		return (StructDefs[name] ~= nil) -- 254
	end -- 254
}, { -- 256
	__index = function(self, name) -- 256
		local def = StructDefs[name] -- 257
		if not def then -- 258
			StructHelper.name = name -- 259
			StructHelper.path = "" -- 260
			def = StructHelper -- 261
		end -- 258
		return def -- 262
	end, -- 256
	__tostring = function(self) -- 263
		return concat(_anon_func_0(StructDefs, pairs, tostring), "\n") -- 264
	end -- 263
}) -- 232
_module_0["Struct"] = Struct -- 265
local Set -- 267
Set = function(list) -- 267
	local _tbl_0 = { } -- 267
	for _index_0 = 1, #list do -- 267
		local item = list[_index_0] -- 267
		_tbl_0[item] = true -- 267
	end -- 267
	return _tbl_0 -- 267
end -- 267
_module_0["Set"] = Set -- 267
local CompareTable -- 269
CompareTable = function(olds, news) -- 269
	local itemsToDel = { } -- 270
	local itemSet = Set(news) -- 271
	for _index_0 = 1, #olds do -- 272
		local item = olds[_index_0] -- 272
		if not itemSet[item] then -- 273
			itemsToDel[#itemsToDel + 1] = item -- 274
		end -- 273
	end -- 274
	local itemsToAdd = { } -- 275
	itemSet = Set(olds) -- 276
	for _index_0 = 1, #news do -- 277
		local item = news[_index_0] -- 277
		if not itemSet[item] then -- 278
			itemsToAdd[#itemsToAdd + 1] = item -- 279
		end -- 278
	end -- 279
	return itemsToAdd, itemsToDel -- 280
end -- 269
_module_0["CompareTable"] = CompareTable -- 280
local Round -- 282
Round = function(val) -- 282
	if type(val) == "number" then -- 283
		return val > 0 and floor(val + 0.5) or ceil(val - 0.5) -- 284
	else -- 286
		return Vec2(val.x > 0 and floor(val.x + 0.5) or ceil(val.x - 0.5), val.y > 0 and floor(val.y + 0.5) or ceil(val.y - 0.5)) -- 289
	end -- 283
end -- 282
_module_0["Round"] = Round -- 289
local IsValidPath -- 291
IsValidPath = function(filename) -- 291
	return not filename:match("[\\/|:*?<>\"]") -- 291
end -- 291
_module_0["IsValidPath"] = IsValidPath -- 291
local allowedUseOfGlobals = Set({ -- 294
	"Dora", -- 294
	"dora", -- 295
	"require", -- 296
	"_G" -- 297
}) -- 293
local LintYueGlobals -- 299
LintYueGlobals = function(luaCodes, globals, globalInLocal) -- 299
	if globalInLocal == nil then -- 299
		globalInLocal = true -- 299
	end -- 299
	local errors = { } -- 300
	local requireModules = { } -- 301
	luaCodes = luaCodes:gsub("^local _module_[^\r\n]*[^\r\n]+", "") -- 302
	local importCodes = luaCodes:match("^%s*local%s*_ENV%s*=%s*Dora%(([^%)]-)%)") -- 303
	local importItems -- 304
	if importCodes then -- 304
		local _accum_0 = { } -- 305
		local _len_0 = 1 -- 305
		for item in importCodes:gmatch("%s*([^,\n\r]+)%s*") do -- 305
			local getImport = load("return " .. tostring(item)) -- 306
			local importItem -- 307
			if getImport ~= nil then -- 307
				importItem = getImport() -- 307
			end -- 307
			if not importItem or "table" ~= type(importItem) then -- 308
				goto _continue_0 -- 308
			end -- 308
			_accum_0[_len_0] = { -- 309
				importItem, -- 309
				item -- 309
			} -- 309
			_len_0 = _len_0 + 1 -- 309
			::_continue_0:: -- 306
		end -- 309
		importItems = _accum_0 -- 305
	else -- 310
		importItems = { } -- 310
	end -- 304
	local importSet = { } -- 311
	local globalSet = { } -- 312
	for _index_0 = 1, #globals do -- 313
		local globalVar = globals[_index_0] -- 313
		local name = globalVar[1] -- 314
		if globalSet[name] then -- 315
			goto _continue_1 -- 315
		end -- 315
		globalSet[name] = true -- 316
		if allowedUseOfGlobals[name] then -- 317
			goto _continue_1 -- 317
		end -- 317
		if _G[name] then -- 318
			if globalInLocal then -- 319
				requireModules[#requireModules + 1] = "local " .. tostring(name) .. " = _G." .. tostring(name) .. " -- 1" -- 320
			end -- 319
			goto _continue_1 -- 321
		end -- 318
		local findModule = false -- 322
		if importCodes then -- 323
			if dora[name] then -- 324
				requireModules[#requireModules + 1] = "local " .. tostring(name) .. " = dora." .. tostring(name) .. " -- 1" -- 325
				findModule = true -- 326
			else -- 328
				for i, _des_0 in ipairs(importItems) do -- 328
					local mod, modName = _des_0[1], _des_0[2] -- 328
					if (mod[name] ~= nil) then -- 329
						local moduleName = "_module_" .. tostring(i - 1) -- 330
						if not importSet[mod] then -- 331
							importSet[mod] = true -- 332
							requireModules[#requireModules + 1] = "local " .. tostring(moduleName) .. " = " .. tostring(modName) .. " -- 1" -- 333
						end -- 331
						requireModules[#requireModules + 1] = "local " .. tostring(name) .. " = " .. tostring(moduleName) .. "." .. tostring(name) .. " -- 1" -- 334
						findModule = true -- 335
						break -- 336
					end -- 329
				end -- 336
			end -- 324
		end -- 323
		if not findModule then -- 337
			errors[#errors + 1] = globalVar -- 338
		end -- 337
		::_continue_1:: -- 314
	end -- 338
	if #errors > 0 then -- 339
		return false, errors -- 340
	else -- 342
		return true, table.concat(requireModules, "\n") -- 342
	end -- 339
end -- 299
_module_0["LintYueGlobals"] = LintYueGlobals -- 342
local GSplit -- 344
GSplit = function(text, pattern, plain) -- 344
	local splitStart, length = 1, #text -- 345
	return function() -- 346
		if splitStart then -- 347
			local sepStart, sepEnd = string.find(text, pattern, splitStart, plain) -- 348
			local ret -- 349
			if not sepStart then -- 350
				ret = string.sub(text, splitStart) -- 351
				splitStart = nil -- 352
			elseif sepEnd < sepStart then -- 353
				ret = string.sub(text, splitStart, sepStart) -- 354
				if sepStart < length then -- 355
					splitStart = sepStart + 1 -- 356
				else -- 358
					splitStart = nil -- 358
				end -- 355
			else -- 360
				ret = sepStart > splitStart and string.sub(text, splitStart, sepStart - 1) or '' -- 360
				splitStart = sepEnd + 1 -- 361
			end -- 350
			return ret -- 362
		end -- 347
	end -- 362
end -- 344
_module_0["GSplit"] = GSplit -- 362
return _module_0 -- 362
