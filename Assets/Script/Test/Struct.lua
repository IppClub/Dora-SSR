-- [yue]: Script/Test/Struct.yue
local print = _G.print -- 1
local tostring = _G.tostring -- 1
local Struct = require("Utils").Struct -- 2
local Unit = Struct.My.Name.Space.Unit("name", "group", "tag", "actions") -- 5
local Action = Struct.Action("name", "id") -- 6
local Array = Struct.Array() -- 7
local unit = Unit({ -- 11
	name = "abc", -- 11
	group = 123, -- 12
	tag = "tagX", -- 13
	actions = Array({ -- 15
		Action({ -- 15
			name = "walk", -- 15
			id = "a1" -- 15
		}), -- 15
		Action({ -- 16
			name = "run", -- 16
			id = "a2" -- 16
		}), -- 16
		Action({ -- 17
			name = "sleep", -- 17
			id = "a3" -- 17
		}) -- 17
	}) -- 14
}) -- 10
unit.__modified = function(key, value) -- 20
	return print("Value of name \"" .. tostring(key) .. "\" changed to " .. tostring(value) .. ".") -- 20
end -- 20
unit.__updated = function() -- 21
	return print("Values updated.") -- 21
end -- 21
do -- 24
	local _with_0 = unit.actions -- 24
	_with_0.__added = function(index, item) -- 25
		return print("Add item " .. tostring(item) .. " at index " .. tostring(index) .. ".") -- 25
	end -- 25
	_with_0.__removed = function(index, item) -- 26
		return print("Remove item " .. tostring(item) .. " at index " .. tostring(index) .. ".") -- 26
	end -- 26
	_with_0.__changed = function(index, item) -- 27
		return print("Change item to " .. tostring(item) .. " at index " .. tostring(index) .. ".") -- 27
	end -- 27
	_with_0.__updated = function() -- 28
		return print("Items updated.") -- 28
	end -- 28
end -- 24
unit.name = "pig" -- 30
unit.actions:insert(Action({ -- 31
	name = "idle", -- 31
	id = "a4" -- 31
})) -- 31
unit.actions:removeAt(1) -- 32
local structStr = tostring(unit) -- 34
print(structStr) -- 35
local loadedUnit = Struct:load(structStr) -- 37
for i = 1, loadedUnit.actions:count() do -- 38
	print(loadedUnit.actions:get(i)) -- 39
end -- 39
print(Struct) -- 41
return Struct:clear() -- 44
