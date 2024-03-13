-- [yue]: Script/Test/Struct.yue
local print = _G.print -- 1
local tostring = _G.tostring -- 1
local Struct = require("Utils").Struct -- 1
local Unit = Struct.My.Name.Space.Unit("name", "group", "tag", "actions") -- 4
local Action = Struct.Action("name", "id") -- 5
local Array = Struct.Array() -- 6
local unit = Unit({ -- 10
	name = "abc", -- 10
	group = 123, -- 11
	tag = "tagX", -- 12
	actions = Array({ -- 14
		Action({ -- 14
			name = "walk", -- 14
			id = "a1" -- 14
		}), -- 14
		Action({ -- 15
			name = "run", -- 15
			id = "a2" -- 15
		}), -- 15
		Action({ -- 16
			name = "sleep", -- 16
			id = "a3" -- 16
		}) -- 16
	}) -- 13
}) -- 9
unit.__notify = function(event, key, value) -- 19
	if "Modified" == event then -- 21
		return print("Value of name \"" .. tostring(key) .. "\" changed to " .. tostring(value) .. ".") -- 22
	elseif "Updated" == event then -- 23
		return print("Values updated.") -- 24
	end -- 24
end -- 19
unit.actions.__notify = function(event, index, item) -- 27
	if "Added" == event then -- 29
		return print("Add item " .. tostring(item) .. " at index " .. tostring(index) .. ".") -- 30
	elseif "Removed" == event then -- 31
		return print("Remove item " .. tostring(item) .. " at index " .. tostring(index) .. ".") -- 32
	elseif "Changed" == event then -- 33
		return print("Change item to " .. tostring(item) .. " at index " .. tostring(index) .. ".") -- 34
	elseif "Updated" == event then -- 35
		return print("Items updated.") -- 36
	end -- 36
end -- 27
unit.name = "pig" -- 38
unit.actions:insert(Action({ -- 39
	name = "idle", -- 39
	id = "a4" -- 39
})) -- 39
unit.actions:removeAt(1) -- 40
local structStr = tostring(unit) -- 42
print(structStr) -- 43
local loadedUnit = Struct:load(structStr) -- 45
for i = 1, loadedUnit.actions:count() do -- 46
	print(loadedUnit.actions:get(i)) -- 47
end -- 47
print(Struct) -- 49
return Struct:clear() -- 52
