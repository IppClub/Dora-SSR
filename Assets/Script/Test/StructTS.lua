-- [ts]: StructTS.ts
local ____exports = {} -- 1
local ____Utils = require("Utils") -- 2
local Struct = ____Utils.Struct -- 2
local Unit = Struct.My.Name.Space.Unit("name", "group", "tag", "actions") -- 15
local Action = Struct.Action("name", "id") -- 16
local Array = Struct.Array() -- 17
local unit = Unit({ -- 20
	name = "abc", -- 21
	group = 123, -- 22
	tag = "tagX", -- 23
	actions = Array({ -- 24
		Action({name = "walk", id = "a1"}), -- 25
		Action({name = "run", id = "a2"}), -- 26
		Action({name = "sleep", id = "a3"}) -- 27
	}) -- 27
}) -- 27
unit.__modified = function(key, value) return print(((("Value of name \"" .. key) .. "\" changed to ") .. tostring(value)) .. ".") end -- 32
unit.__updated = function() return print("Values updated.") end -- 33
unit.actions.__added = function(index, item) return print(((("Add item " .. tostring(item)) .. " at index ") .. tostring(index)) .. ".") end -- 36
unit.actions.__removed = function(index, item) return print(((("Remove item " .. tostring(item)) .. " at index ") .. tostring(index)) .. ".") end -- 37
unit.actions.__changed = function(index, item) return print(((("Change item to " .. tostring(item)) .. " at index ") .. tostring(index)) .. ".") end -- 38
unit.actions.__updated = function() return print("Items updated.") end -- 39
unit.name = "pig" -- 41
unit.actions:insert(Action({name = "idle", id = "a4"})) -- 42
unit.actions:removeAt(1) -- 43
local structStr = tostring(unit) -- 45
print(structStr) -- 46
local loadedUnit = Struct:load(structStr) -- 48
do -- 48
	local i = 1 -- 49
	while i <= loadedUnit.actions:count() do -- 49
		print( -- 50
			i, -- 50
			loadedUnit.actions:get(i) -- 50
		) -- 50
		i = i + 1 -- 49
	end -- 49
end -- 49
print(Struct) -- 53
Struct:clear() -- 56
return ____exports -- 56