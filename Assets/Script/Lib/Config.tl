--[[ Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. ]]

local Struct = require("Utils").Struct
local DB = require("DB")
local thread = require("thread")

local record DoraConfig
	embed Struct.Type
	loadAsync: function(self: DoraConfig)
	load: function(self: DoraConfig)
end

return function(schema: string, ...: string): DoraConfig
	schema = schema or ""
	local Config =
		schema == "" and
		Struct.Config(...) or
		Struct[schema].Config(...)
	local schemaPart, tablePart = string.match(schema, "^(%w*)%.(%w*)$")
	local tableName: string
	if schemaPart == nil then
		tableName = schema == "" and "Config" or schema .. ".Config"
		schemaPart = ""
		tablePart = "Config"
	else
		if tablePart == "" then tablePart = "Config" end
		if schemaPart ~= "" then
			tableName = schemaPart .. '.' .. tablePart
		else
			tableName = tablePart
		end
	end
	local conf = Config()
	local oldValues: {string: any} = {}
	local insertValues: {string: any} = {}
	local updateValues: {string: any} = {}
	local deleteValues: {string} = {}
	local loaded = false

	local function modified(key: string, value: any)
		if oldValues[key] == nil then
			insertValues[key] = value
		elseif value == nil then
			deleteValues[#deleteValues + 1] = key
		elseif oldValues[key] ~= value then
			updateValues[key] = value
		end
		oldValues[key] = value
	end

	local function updated()
		assert(loaded, "Config should be loaded before updating")
		local iValues: {{string, number | boolean, string | boolean, integer | boolean}} = {}
		for k, v in pairs(insertValues) do
			local num: boolean | number = false
			local str: boolean | string = false
			local bool: boolean | integer = false
			if v is number then
				num = v
			elseif v is string then
				str = v
			elseif v is boolean then
				bool = v and 1 or 0
			else
				print("expecting config value named \"" .. k .. '" to be string | number | boolean, got ' .. type(v))
			end
			iValues[#iValues + 1] = {k, num, str, bool}
		end
		insertValues = {}
		local uValues: {{number | boolean, string | boolean, integer | boolean, string}} = {}
		for k, v in pairs(updateValues) do
			local num: boolean | number = false
			local str: boolean | string = false
			local bool: boolean | integer = false
			if v is number then
				num = v
			elseif v is string then
				str = v
			elseif v is boolean then
				bool = v and 1 or 0
			else
				print("expecting config value named \"" .. k .. '" to be string | number | boolean, got ' .. type(v))
			end
			uValues[#uValues + 1] = {num, str, bool, k}
		end
		updateValues = {}
		local dValues: {{string}} = {}
		for i = 1, #deleteValues do
			dValues[#dValues + 1] = {deleteValues[i]}
		end
		deleteValues = {}
		thread(function()
			if #iValues > 0 then
				DB:insertAsync(tableName, iValues)
			end
			if #uValues > 0 then
				DB:execAsync("update " .. tableName .. " set value_num = ?, value_str = ?, value_bool = ? where name = ?", uValues)
			end
			if #dValues > 0 then
				DB:execAsync("delete from " .. tableName .. " where name = ?", dValues)
			end
		end)
	end

	local tableOK = false
	if DB:exist(tablePart, schemaPart) then
		local ok = DB:query("select name, value_num, value_str, value_bool from " .. tableName .. " limit 0")
		if ok then
			tableOK = true
		else
			DB:exec("DROP TABLE " .. tableName)
		end
	end

	if not tableOK then
		DB:exec([[
			CREATE TABLE ]] .. tableName .. [[(
				name TEXT(90) NOT NULL, --配置项名称
				value_num REAL(24,6), --配置项数值
				value_str TEXT(255), --配置项文本
				value_bool INTEGER, --配置项布尔值
				PRIMARY KEY (name)
			); --通用配置表
		]])
	end

	local function initConfig(self: DoraConfig, rows: {{string, number, string, integer}})
		local mt = getmetatable(self) as {string}
		local fields = {}
		for i = 1, #mt do
			local fieldName = mt[i]
			fields[fieldName] = true
		end
		for i = 1, #rows do
			local key = rows[i][1]
			if fields[key] then
				if rows[i][4] then
					local value = rows[i][4] > 0
					oldValues[key] = value
					self[key] = value
				else
					local value: number | string = rows[i][2] or rows[i][3] or nil
					if value == nil then
						DB:exec("delete from " .. tableName .. " where name = ?", {key})
					end
					oldValues[key] = value
					self[key] = value
				end
			else
				print("Config key \"" .. key .. "\" is no longer exist")
			end
		end
	end

	rawset(conf as table, "loadAsync", function(self: DoraConfig)
		local rows = DB:queryAsync("select name, value_num, value_str, value_bool from " .. tableName) as {{string, number, string, integer}} | nil
		if not rows is nil then
			loaded = true
			initConfig(self, rows)
		end
	end)

	rawset(conf as table, "load", function(self: DoraConfig)
		local rows = DB:query("select name, value_num, value_str, value_bool from " .. tableName) as {{string, number, string, integer}} | nil
		if not rows is nil then
			loaded = true
			initConfig(self, rows)
		end
	end)

	conf.__modified = modified
	conf.__updated = updated

	return conf as DoraConfig
end


