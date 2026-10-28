local D = require("Dora")
local node = assert(D.GodotNode("/game/godot", "", 640, 360, 3))
D.Director.ui:addChild(node)
node:gslot("AppEvent", function(name) print("DORA_DOM_APP " .. name) end)
local stage, ticks = 0, 0
local function target(index, x, y)
    node:convertToWindowSpace(D.Vec2(x, 360-y), function(p)
        print("DORA_DOM_TARGET " .. index .. " x=" .. p.x .. " y=" .. p.y)
    end)
end
local controller = D.Node()
D.Director.ui:addChild(controller)
controller:schedule(function()
    assert(node.lastError == "", node.lastError)
    if not node.running then return false end
    ticks = ticks + 1
    if stage == 0 and ticks >= 20 then target(1,120,90); stage=1 end
    if stage == 1 and D.Content:exist("/user/dom-step-1") then
        node.x,node.y,node.angle,node.scaleX,node.scaleY=64,-32,12,1.25,1.25
        stage=2; ticks=0
    end
    if stage == 2 and ticks >= 10 then target(2,200,120); stage=3 end
    if stage == 3 and D.Content:exist("/user/dom-step-2") then
        node:detachIME(); node:removeFromParent()
        print("DORA_DOM_DONE")
        return true
    end
    return false
end)
