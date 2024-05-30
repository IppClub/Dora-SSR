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
unit.__notify = function(event, key, value) -- 20
	if "Modified" == event then -- 22
		return print("Value of name \"" .. tostring(key) .. "\" changed to " .. tostring(value) .. ".") -- 23
	elseif "Updated" == event then -- 24
		return print("Values updated.") -- 25
	end -- 25
end -- 20
unit.actions.__notify = function(event, index, item) -- 28
	if "Added" == event then -- 30
		return print("Add item " .. tostring(item) .. " at index " .. tostring(index) .. ".") -- 31
	elseif "Removed" == event then -- 32
		return print("Remove item " .. tostring(item) .. " at index " .. tostring(index) .. ".") -- 33
	elseif "Changed" == event then -- 34
		return print("Change item to " .. tostring(item) .. " at index " .. tostring(index) .. ".") -- 35
	elseif "Updated" == event then -- 36
		return print("Items updated.") -- 37
	end -- 37
end -- 28
unit.name = "pig" -- 39
unit.actions:insert(Action({ -- 40
	name = "idle", -- 40
	id = "a4" -- 40
})) -- 40
unit.actions:removeAt(1) -- 41
local structStr = tostring(unit) -- 43
print(structStr) -- 44
local loadedUnit = Struct:load(structStr) -- 46
for i = 1, loadedUnit.actions:count() do -- 47
	print(loadedUnit.actions:get(i)) -- 48
end -- 48
print(Struct) -- 50
return Struct:clear() -- 53
