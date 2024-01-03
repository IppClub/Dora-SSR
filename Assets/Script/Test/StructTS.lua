-- [ts]: StructTS.ts
local ____exports = {} -- 1
local ____Utils = require("Utils") -- 1
local Struct = ____Utils.Struct -- 1
local Unit = Struct.My.Name.Space.Unit("name", "group", "tag", "actions") -- 10
local Action = Struct.Action("name", "id") -- 15
local Array = Struct.Array() -- 16
local unit = Unit({ -- 19
    name = "abc", -- 20
    group = 123, -- 21
    tag = "tagX", -- 22
    actions = Array({ -- 23
        Action({name = "walk", id = "a1"}), -- 24
        Action({name = "run", id = "a2"}), -- 25
        Action({name = "sleep", id = "a3"}) -- 26
    }) -- 26
}) -- 26
unit.__notify = function(____, event, key, value) -- 31
    repeat -- 31
        local ____switch3 = event -- 31
        local ____cond3 = ____switch3 == "Modified" -- 31
        if ____cond3 then -- 31
            print(((("Value of name \"" .. key) .. "\" changed to ") .. tostring(value)) .. ".") -- 34
            break -- 35
        end -- 35
        ____cond3 = ____cond3 or ____switch3 == "Updated" -- 35
        if ____cond3 then -- 35
            print("Values updated.") -- 37
            break -- 38
        end -- 38
    until true -- 38
end -- 31
unit.actions.__notify = function(____, event, index, item) -- 43
    repeat -- 43
        local ____switch5 = event -- 43
        local ____cond5 = ____switch5 == "Added" -- 43
        if ____cond5 then -- 43
            print(((("Add item " .. tostring(item)) .. " at index ") .. tostring(index)) .. ".") -- 46
            break -- 47
        end -- 47
        ____cond5 = ____cond5 or ____switch5 == "Removed" -- 47
        if ____cond5 then -- 47
            print(((("Remove item " .. tostring(item)) .. " at index ") .. tostring(index)) .. ".") -- 49
            break -- 50
        end -- 50
        ____cond5 = ____cond5 or ____switch5 == "Changed" -- 50
        if ____cond5 then -- 50
            print(((("Change item to " .. tostring(item)) .. " at index ") .. tostring(index)) .. ".") -- 52
            break -- 53
        end -- 53
        ____cond5 = ____cond5 or ____switch5 == "Updated" -- 53
        if ____cond5 then -- 53
            print("Items updated.") -- 55
            break -- 56
        end -- 56
    until true -- 56
end -- 43
unit.name = "pig" -- 60
unit.actions:insert(Action({name = "idle", id = "a4"})) -- 61
unit.actions:removeAt(1) -- 62
local structStr = tostring(unit) -- 64
print(structStr) -- 65
local loadedUnit = Struct:load(structStr) -- 67
do -- 67
    local i = 1 -- 68
    while i <= loadedUnit.actions:count() do -- 68
        print( -- 69
            i, -- 69
            loadedUnit.actions:get(i) -- 69
        ) -- 69
        i = i + 1 -- 68
    end -- 68
end -- 68
print(Struct) -- 72
Struct:clear() -- 75
return ____exports -- 75