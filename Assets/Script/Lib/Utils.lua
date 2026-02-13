-- [yue]: Script/Lib/Utils.yue
local _module_0 = { } -- 1
local _ENV = Dora -- 9
local insert, concat, remove, sort = table.insert, table.concat, table.remove, table.sort -- 10
local ceil, floor = math.ceil, math.floor -- 11
local rawget <const> = rawget -- 12
local rawset <const> = rawset -- 12
local thread <const> = thread -- 12
local getmetatable <const> = getmetatable -- 12
local type <const> = type -- 12
local tostring <const> = tostring -- 12
local error <const> = error -- 12
local ipairs <const> = ipairs -- 12
local pairs <const> = pairs -- 12
local setmetatable <const> = setmetatable -- 12
local select <const> = select -- 12
local assert <const> = assert -- 12
local load <const> = load -- 12
local Vec2 <const> = Vec2 -- 12
local pcall <const> = pcall -- 12
local _G <const> = _G -- 12
local Dora <const> = Dora -- 12
local table <const> = table -- 12
local string <const> = string -- 12
local StructUpdated -- 14
StructUpdated = function(self) -- 14
	local update = rawget(self, "__updateThread") -- 15
	if not update then -- 16
		return rawset(self, "__updateThread", thread(function() -- 17
			do -- 18
				local notify = rawget(self, "__updated") -- 18
				if notify then -- 18
					notify() -- 18
				end -- 18
			end -- 18
			return rawset(self, "__updateThread", nil) -- 19
		end)) -- 17
	end -- 16
end -- 14
local StructToString -- 20
StructToString = function(self) -- 20
	local structDef = getmetatable(self) -- 21
	local content = { } -- 22
	local ordered = true -- 23
	local count -- 24
	if #structDef == 0 then -- 24
		count = #self -- 24
	else -- 24
		count = #structDef + 1 -- 24
	end -- 24
	for i = 1, count do -- 25
		local value = self[i] -- 26
		if value == nil then -- 27
			ordered = false -- 28
			goto _continue_0 -- 29
		else -- 31
			value = (type(value) == 'string' and "\"" .. tostring(value) .. "\"" or tostring(value)) -- 31
			if ordered then -- 32
				content[#content + 1] = value -- 33
			else -- 35
				content[#content + 1] = "[" .. tostring(i) .. "]=" .. tostring(value) -- 35
			end -- 32
		end -- 27
		::_continue_0:: -- 26
	end -- 25
	return "{" .. (concat(content, ',')) .. "}" -- 36
end -- 20
local StructDefMeta = { -- 38
	set = function(self, index, item) -- 38
		index = index + 1 -- 39
		if 1 <= index and index <= #self then -- 40
			self[index] = item -- 41
			local notify = rawget(self, "__changed") -- 42
			if notify then -- 42
				notify(index - 1, item) -- 43
				return StructUpdated(self) -- 44
			end -- 42
		else -- 46
			return error("Access index out of range.") -- 46
		end -- 40
	end, -- 38
	get = function(self, index) -- 47
		if 1 <= index and index < #self then -- 48
			return self[index + 1] -- 49
		else -- 51
			return nil -- 51
		end -- 48
	end, -- 47
	insert = function(self, argA, argB) -- 52
		local item, index -- 53
		if argB then -- 54
			item = argB -- 55
			index = argA + 1 -- 56
			if index > #self then -- 57
				index = #self + 1 -- 58
			elseif index < 1 then -- 59
				index = 1 -- 60
			end -- 57
		else -- 62
			item = argA -- 62
			index = #self + 1 -- 63
		end -- 54
		insert(self, index, item) -- 64
		do -- 65
			local notify = rawget(self, "__added") -- 65
			if notify then -- 65
				notify(index - 1, item) -- 66
				StructUpdated(self) -- 67
			end -- 65
		end -- 65
		return item -- 68
	end, -- 52
	remove = function(self, arg) -- 69
		local item, index -- 70
		for i = 2, #self do -- 71
			if self[i] == arg then -- 72
				item = arg -- 73
				index = i -- 74
				remove(self, index) -- 75
				break -- 76
			end -- 72
		end -- 71
		if index then -- 77
			local notify = rawget(self, "__removed") -- 78
			if notify then -- 78
				notify(index - 1, item) -- 79
				StructUpdated(self) -- 80
			end -- 78
		end -- 77
		return item -- 81
	end, -- 69
	removeAt = function(self, index) -- 82
		local length = #self -- 83
		local item -- 84
		if index then -- 84
			if 0 < index and index < length then -- 85
				index = index + 1 -- 86
				item = remove(self, index) -- 87
			else -- 89
				item = nil -- 89
			end -- 85
		else -- 91
			if length > 1 then -- 91
				index = length -- 92
				item = remove(self, index) -- 93
			else -- 95
				item = nil -- 95
			end -- 91
		end -- 84
		if item then -- 96
			local notify = rawget(self, "__removed") -- 97
			if notify then -- 97
				notify(index - 1, item) -- 98
				StructUpdated(self) -- 99
			end -- 97
		end -- 96
		return item -- 100
	end, -- 82
	clear = function(self) -- 101
		local notify = rawget(self, "__removed") -- 102
		for index = #self, 2, -1 do -- 103
			local item = remove(self) -- 104
			if notify then -- 105
				notify(index - 1, item) -- 106
				StructUpdated(self) -- 107
			end -- 105
		end -- 103
	end, -- 101
	each = function(self, handler) -- 108
		for index = 2, #self do -- 109
			if true == handler(self[index], index - 1) then -- 110
				return true -- 111
			end -- 110
		end -- 109
		return false -- 112
	end, -- 108
	eachAttr = function(self, handler) -- 113
		for i, v in ipairs(getmetatable(self)) do -- 114
			handler(v, self[i + 1]) -- 115
		end -- 114
	end, -- 113
	contains = function(self, item) -- 116
		for index = 2, #self do -- 117
			if item == self[index] then -- 118
				return true -- 119
			end -- 118
		end -- 117
		return false -- 120
	end, -- 116
	toArray = function(self) -- 121
		local _accum_0 = { } -- 121
		local _len_0 = 1 -- 121
		local _list_0 = self -- 121
		local _max_0 = #_list_0 -- 121
		for _index_0 = 2, _max_0 do -- 121
			local item = _list_0[_index_0] -- 121
			_accum_0[_len_0] = item -- 121
			_len_0 = _len_0 + 1 -- 121
		end -- 121
		return _accum_0 -- 121
	end, -- 121
	count = function(self) -- 122
		return #self - 1 -- 122
	end, -- 122
	sort = function(self, comparer) -- 123
		local arr = self:toArray() -- 124
		sort(arr, comparer) -- 125
		for i = 1, #arr do -- 126
			self:set(i, arr[i]) -- 127
		end -- 126
	end, -- 123
	__tostring = function(self) -- 128
		local content = { } -- 129
		for k, v in pairs(self) do -- 130
			if "number" == type(v) then -- 131
				content[v - 1] = k -- 132
			end -- 131
		end -- 130
		if #content > 1 then -- 133
			return concat({ -- 134
				"Struct.", -- 134
				self.__name, -- 134
				"{\"", -- 134
				concat(content, "\",\""), -- 134
				"\"}" -- 134
			}) -- 134
		else -- 136
			return "Struct." .. tostring(self.__name) .. "()" -- 136
		end -- 133
	end, -- 128
	__call = function(self, data) -- 137
		local item = { -- 138
			self.__name -- 138
		} -- 138
		if data then -- 139
			for k, v in pairs(data) do -- 140
				local key = self[k] -- 141
				if key then -- 142
					item[key] = v -- 143
				elseif type(k) == "number" then -- 144
					item[k + 1] = v -- 145
				else -- 147
					error("Initialize to an invalid field named \"" .. tostring(k) .. "\" for \"" .. tostring(self) .. "\".") -- 147
				end -- 142
			end -- 140
		end -- 139
		setmetatable(item, self) -- 148
		return item -- 149
	end -- 137
} -- 37
local StructDefs = { } -- 151
local StructHelper = { -- 153
	__call = function(self, ...) -- 153
		local structName = self.path .. self.name -- 154
		local tupleDef -- 155
		tupleDef = setmetatable({ -- 157
			__name = structName, -- 157
			__index = function(self, key) -- 158
				local item = tupleDef[key] -- 159
				if item then -- 160
					return rawget(self, item) -- 161
				else -- 163
					return StructDefMeta[key] -- 163
				end -- 160
			end, -- 158
			__newindex = function(self, key, value) -- 164
				local index = tupleDef[key] -- 165
				if index then -- 166
					local oldValue = rawget(self, index) -- 167
					if oldValue == value then -- 168
						return -- 168
					end -- 168
					rawset(self, index, value) -- 169
					local notify = rawget(self, "__modified") -- 170
					if notify then -- 170
						notify(key, value) -- 171
						return StructUpdated(self) -- 172
					end -- 170
				elseif "number" == type(key) then -- 173
					return rawset(self, key, value) -- 174
				elseif (value ~= nil) and ("__added" == key or "__modified" == key) then -- 175
					rawset(self, key, value) -- 176
					if key == "__added" then -- 177
						if #tupleDef == 0 then -- 178
							local initVar = false -- 179
							for i = 2, #self do -- 180
								value(i - 1, self[i]) -- 181
								initVar = true -- 182
							end -- 180
							if initVar then -- 183
								return StructUpdated(self) -- 183
							end -- 183
						end -- 178
					else -- 185
						local initVar = false -- 185
						for _index_0 = 1, #tupleDef do -- 186
							local key = tupleDef[_index_0] -- 186
							local v = self[key] -- 187
							if (v ~= nil) then -- 188
								value(key, v) -- 189
								initVar = true -- 190
							end -- 188
						end -- 186
						if initVar then -- 191
							return StructUpdated(self) -- 191
						end -- 191
					end -- 177
				elseif ("__updated" == key or "__removed" == key or "__changed" == key) then -- 192
					return rawset(self, key, value) -- 193
				else -- 195
					return error("Access invalid key \"" .. tostring(key) .. "\" for " .. tostring(tupleDef)) -- 195
				end -- 166
			end, -- 164
			__tostring = StructToString -- 196
		}, StructDefMeta) -- 156
		local count = select("#", ...) -- 198
		if count > 0 then -- 199
			local arg = select(1, ...) -- 200
			if "table" == type(arg) then -- 201
				for i, name in ipairs(arg) do -- 202
					tupleDef[i] = name -- 203
					tupleDef[name] = i + 1 -- 204
				end -- 202
			else -- 206
				for i = 1, count do -- 206
					local name = select(i, ...) -- 207
					tupleDef[i] = name -- 208
					tupleDef[name] = i + 1 -- 209
				end -- 206
			end -- 201
		end -- 199
		StructDefs[structName] = tupleDef -- 210
		return tupleDef -- 211
	end, -- 153
	__index = function(self, key) -- 212
		self.path = self.path .. self.name -- 213
		self.path = self.path .. "." -- 214
		self.name = key -- 215
		return self -- 216
	end, -- 212
	__tostring = function(self) -- 217
		local content = { } -- 218
		local path = self.path .. self.name .. "." -- 219
		local i = 1 -- 220
		for k, v in pairs(StructDefs) do -- 221
			if k:find(path, 1, true) then -- 222
				content[i] = tostring(v) -- 223
				i = i + 1 -- 224
			end -- 222
		end -- 221
		return concat(content, "\n") -- 225
	end -- 217
} -- 152
setmetatable(StructHelper, StructHelper) -- 227
local Struct -- 228
local StructLoad -- 229
StructLoad = function(data) -- 229
	if "table" == type(data) then -- 230
		local mt = StructDefs[data[1]] -- 231
		assert(mt, "Struct started with \"" .. tostring(data[1]) .. "\" is not defined.") -- 232
		setmetatable(data, mt) -- 233
		for _index_0 = 1, #data do -- 234
			local item = data[_index_0] -- 234
			StructLoad(item) -- 235
		end -- 234
	end -- 230
end -- 229
local _anon_func_0 = function(StructDefs) -- 268
	local _accum_0 = { } -- 268
	local _len_0 = 1 -- 268
	for _, v in pairs(StructDefs) do -- 268
		_accum_0[_len_0] = tostring(v) -- 268
		_len_0 = _len_0 + 1 -- 268
	end -- 268
	return _accum_0 -- 268
end -- 268
Struct = setmetatable({ -- 237
	load = function(_self, ...) -- 237
		local count = select("#", ...) -- 238
		if count > 1 then -- 239
			local name = select(1, ...) -- 240
			local data = select(2, ...) -- 241
			insert(data, 1, name) -- 242
			StructLoad(data) -- 243
			return data -- 244
		else -- 246
			local arg = select(1, ...) -- 246
			local data -- 247
			do -- 247
				local _exp_0 = type(arg) -- 247
				if "string" == _exp_0 then -- 248
					if arg:sub(1, 6) ~= "return" then -- 249
						arg = "return " .. arg -- 250
					end -- 249
					data = (load(arg))() -- 251
				elseif "table" == _exp_0 then -- 252
					data = arg -- 253
				end -- 247
			end -- 247
			StructLoad(data) -- 254
			return data -- 255
		end -- 239
	end, -- 237
	clear = function(_self) -- 256
		StructDefs = { } -- 257
	end, -- 256
	has = function(_self, name) -- 258
		return (StructDefs[name] ~= nil) -- 258
	end -- 258
}, { -- 260
	__index = function(_self, name) -- 260
		local def = StructDefs[name] -- 261
		if not def then -- 262
			StructHelper.name = name -- 263
			StructHelper.path = "" -- 264
			def = StructHelper -- 265
		end -- 262
		return def -- 266
	end, -- 260
	__tostring = function(_self) -- 267
		return concat(_anon_func_0(StructDefs), "\n") -- 268
	end -- 267
}) -- 236
_module_0["Struct"] = Struct -- 236
local Set -- 271
Set = function(list) -- 271
	local _tbl_0 = { } -- 271
	for _index_0 = 1, #list do -- 271
		local item = list[_index_0] -- 271
		_tbl_0[item] = true -- 271
	end -- 271
	return _tbl_0 -- 271
end -- 271
_module_0["Set"] = Set -- 271
local CompareTable -- 273
CompareTable = function(olds, news) -- 273
	local itemsToDel = { } -- 274
	local itemSet = Set(news) -- 275
	for _index_0 = 1, #olds do -- 276
		local item = olds[_index_0] -- 276
		if not itemSet[item] then -- 277
			itemsToDel[#itemsToDel + 1] = item -- 278
		end -- 277
	end -- 276
	local itemsToAdd = { } -- 279
	itemSet = Set(olds) -- 280
	for _index_0 = 1, #news do -- 281
		local item = news[_index_0] -- 281
		if not itemSet[item] then -- 282
			itemsToAdd[#itemsToAdd + 1] = item -- 283
		end -- 282
	end -- 281
	return itemsToAdd, itemsToDel -- 284
end -- 273
_module_0["CompareTable"] = CompareTable -- 273
local Round -- 286
Round = function(val) -- 286
	if type(val) == "number" then -- 287
		return val > 0 and floor(val + 0.5) or ceil(val - 0.5) -- 288
	else -- 290
		return Vec2(val.x > 0 and floor(val.x + 0.5) or ceil(val.x - 0.5), val.y > 0 and floor(val.y + 0.5) or ceil(val.y - 0.5)) -- 290
	end -- 287
end -- 286
_module_0["Round"] = Round -- 286
local IsValidPath -- 295
IsValidPath = function(filename) -- 295
	return not filename:match("[\\/|:*?<>\"]") -- 295
end -- 295
_module_0["IsValidPath"] = IsValidPath -- 295
local tic80APIs -- 297
local CheckTIC80Code -- 298
CheckTIC80Code = function(codes) -- 298
	local isTIC80 = codes:match("^%-%-[ \t]*tic80[ \t]*[$\r\n]") -- 299
	if isTIC80 then -- 300
		if not tic80APIs then -- 301
			local _tbl_0 = { } -- 302
			for api in ("btn,btnp,key,keyp,mouse,clip,cls,circ,circb,elli,ellib,line,pix,rect,rectb,spr,tri,trib,ttri,font,map,mget,mset,fget,fset,sfx,music,peek,peek1,peek2,peek4,poke,poke1,poke2,poke4,pmem,memcpy,memset,exit,reset,sync,time,tstamp,trace,vbank"):gmatch("[^,]+") do -- 302
				_tbl_0[api] = true -- 302
			end -- 302
			tic80APIs = _tbl_0 -- 302
		end -- 301
	end -- 300
	return isTIC80, tic80APIs -- 303
end -- 298
_module_0["CheckTIC80Code"] = CheckTIC80Code -- 298
local allowedUseOfGlobals = Set({ -- 306
	"Dora", -- 306
	"require", -- 307
	"_G" -- 308
}) -- 305
local LintYueGlobals -- 310
LintYueGlobals = function(luaCodes, globals, globalInLocal, extraGlobals) -- 310
	if globalInLocal == nil then -- 310
		globalInLocal = true -- 310
	end -- 310
	if extraGlobals == nil then -- 310
		extraGlobals = nil -- 310
	end -- 310
	local errors = { } -- 311
	local requireModules = { } -- 312
	luaCodes = luaCodes:gsub("^local _module_[^\r\n]*[^\r\n]+", "") -- 313
	local importCodes = luaCodes:match("^%s*local%s*_ENV%s*=%s*Dora%(([^%)]-)%)") -- 314
	local importItems -- 315
	if importCodes then -- 315
		local _accum_0 = { } -- 316
		local _len_0 = 1 -- 316
		for item in importCodes:gmatch("%s*([^,\n\r]+)%s*") do -- 316
			local getImport = load("return " .. tostring(item)) -- 317
			local importItem -- 318
			do -- 318
				local success, result = pcall(getImport) -- 318
				if success then -- 318
					importItem = result -- 318
				end -- 318
			end -- 318
			if not importItem or "table" ~= type(importItem) then -- 319
				goto _continue_0 -- 319
			end -- 319
			_accum_0[_len_0] = { -- 320
				importItem, -- 320
				item -- 320
			} -- 320
			_len_0 = _len_0 + 1 -- 317
			::_continue_0:: -- 317
		end -- 316
		importItems = _accum_0 -- 315
	else -- 321
		importItems = { } -- 321
	end -- 315
	if importCodes == nil then -- 322
		importCodes = luaCodes:match("^%s*local%s*_ENV%s*=%s*Dora[^%w_$]") -- 322
	end -- 322
	local importSet = { } -- 323
	local globalSet = { } -- 324
	for _index_0 = 1, #globals do -- 325
		local globalVar = globals[_index_0] -- 325
		local name = globalVar[1] -- 326
		if globalSet[name] then -- 327
			goto _continue_1 -- 327
		end -- 327
		globalSet[name] = true -- 328
		if allowedUseOfGlobals[name] then -- 329
			goto _continue_1 -- 329
		end -- 329
		if _G[name] or (extraGlobals and extraGlobals[name]) then -- 330
			if globalInLocal then -- 331
				requireModules[#requireModules + 1] = "local " .. tostring(name) .. " = _G." .. tostring(name) .. " -- 1" -- 332
			end -- 331
			goto _continue_1 -- 333
		end -- 330
		local findModule = false -- 334
		if importCodes then -- 335
			if Dora[name] then -- 336
				requireModules[#requireModules + 1] = "local " .. tostring(name) .. " = Dora." .. tostring(name) .. " -- 1" -- 337
				findModule = true -- 338
			else -- 340
				for i, _des_0 in ipairs(importItems) do -- 340
					local mod, modName = _des_0[1], _des_0[2] -- 340
					if (mod[name] ~= nil) then -- 341
						local moduleName = "_module_" .. tostring(i - 1) -- 342
						if not importSet[mod] then -- 343
							importSet[mod] = true -- 344
							requireModules[#requireModules + 1] = "local " .. tostring(moduleName) .. " = " .. tostring(modName) .. " -- 1" -- 345
						end -- 343
						requireModules[#requireModules + 1] = "local " .. tostring(name) .. " = " .. tostring(moduleName) .. "." .. tostring(name) .. " -- 1" -- 346
						findModule = true -- 347
						break -- 348
					end -- 341
				end -- 340
			end -- 336
		end -- 335
		if not findModule then -- 349
			errors[#errors + 1] = globalVar -- 350
		end -- 349
		::_continue_1:: -- 326
	end -- 325
	if #errors > 0 then -- 351
		return false, errors -- 352
	else -- 354
		return true, table.concat(requireModules, "\n") -- 354
	end -- 351
end -- 310
_module_0["LintYueGlobals"] = LintYueGlobals -- 310
local GSplit -- 356
GSplit = function(text, pattern, plain) -- 356
	local splitStart, length = 1, #text -- 357
	return function() -- 358
		if splitStart then -- 359
			local sepStart, sepEnd = string.find(text, pattern, splitStart, plain) -- 360
			local ret -- 361
			if not sepStart then -- 362
				ret = string.sub(text, splitStart) -- 363
				splitStart = nil -- 364
			elseif sepEnd < sepStart then -- 365
				ret = string.sub(text, splitStart, sepStart) -- 366
				if sepStart < length then -- 367
					splitStart = sepStart + 1 -- 368
				else -- 370
					splitStart = nil -- 370
				end -- 367
			else -- 372
				ret = sepStart > splitStart and string.sub(text, splitStart, sepStart - 1) or '' -- 372
				splitStart = sepEnd + 1 -- 373
			end -- 362
			return ret -- 374
		end -- 359
	end -- 358
end -- 356
_module_0["GSplit"] = GSplit -- 356
return _module_0 -- 1
