-- [ts]: StructTS.ts
local ____exports = {} -- 1
local ____Utils = require("Utils") -- 2
local Struct = ____Utils.Struct -- 2
local Unit = Struct.My.Name.Space.Unit("name", "group", "tag", "actions") -- 11
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
unit.__notify = function(____, event, key, value) -- 32
    repeat -- 32
        local ____switch3 = event -- 32
        local ____cond3 = ____switch3 == "Modified" -- 32
        if ____cond3 then -- 32
            print(((("Value of name \"" .. key) .. "\" changed to ") .. tostring(value)) .. ".") -- 35
            break -- 36
        end -- 36
        ____cond3 = ____cond3 or ____switch3 == "Updated" -- 36
        if ____cond3 then -- 36
            print("Values updated.") -- 38
            break -- 39
        end -- 39
    until true -- 39
end -- 32
unit.actions.__notify = function(____, event, index, item) -- 44
    repeat -- 44
        local ____switch5 = event -- 44
        local ____cond5 = ____switch5 == "Added" -- 44
        if ____cond5 then -- 44
            print(((("Add item " .. tostring(item)) .. " at index ") .. tostring(index)) .. ".") -- 47
            break -- 48
        end -- 48
        ____cond5 = ____cond5 or ____switch5 == "Removed" -- 48
        if ____cond5 then -- 48
            print(((("Remove item " .. tostring(item)) .. " at index ") .. tostring(index)) .. ".") -- 50
            break -- 51
        end -- 51
        ____cond5 = ____cond5 or ____switch5 == "Changed" -- 51
        if ____cond5 then -- 51
            print(((("Change item to " .. tostring(item)) .. " at index ") .. tostring(index)) .. ".") -- 53
            break -- 54
        end -- 54
        ____cond5 = ____cond5 or ____switch5 == "Updated" -- 54
        if ____cond5 then -- 54
            print("Items updated.") -- 56
            break -- 57
        end -- 57
    until true -- 57
end -- 44
unit.name = "pig" -- 61
unit.actions:insert(Action({name = "idle", id = "a4"})) -- 62
unit.actions:removeAt(1) -- 63
local structStr = tostring(unit) -- 65
print(structStr) -- 66
local loadedUnit = Struct:load(structStr) -- 68
do -- 68
    local i = 1 -- 69
    while i <= loadedUnit.actions:count() do -- 69
        print( -- 70
            i, -- 70
            loadedUnit.actions:get(i) -- 70
        ) -- 70
        i = i + 1 -- 69
    end -- 69
end -- 69
print(Struct) -- 73
Struct:clear() -- 76
return ____exports -- 76