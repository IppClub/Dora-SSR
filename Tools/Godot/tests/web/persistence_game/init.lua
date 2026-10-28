local D = require("Dora")
local node = assert(D.GodotNode("/game/godot", "", 320, 180, 3))
D.Director.ui:addChild(node)
local ticks = 0
node:schedule(function()
    if not node.running then return false end
    ticks = ticks + 1
    if ticks >= 180 then
        node:removeFromParent()
        print("DORA_PERSIST_DONE")
        return true
    end
    return false
end)
