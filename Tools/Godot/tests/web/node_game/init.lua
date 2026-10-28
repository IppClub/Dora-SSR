local D = require("Dora")
assert(D.Director:beginGameCapture(), "Begin capture scope")
local node, frame, waiting, pending = nil, 0, 0, false
local aliases = {}
local captures = { [15]="preboot", [55]="animated", [100]="key", [150]="paused", [170]="paused-again", [210]="resumed", [270]="restart", [350]="resize", [420]="aliases", [490]="removed", [500]="removed-again", [570]="recreated" }
local function create()
    node = assert(D.GodotNode("/game/godot", "", 640, 360, 3), "GodotNode constructor")
    node:pause()
    D.Director.ui:addChild(node)
end
create()
local controller = D.Node()
D.Director.ui:addChild(controller)
controller:schedule(function()
    if pending then return false end
    if node and node.lastError ~= "" then error("GodotNode: " .. node.lastError) end
    if node and not node.running then
        waiting = waiting + 1
        assert(waiting < 900, "GodotNode startup timeout")
        return false
    end
    frame = frame + 1
    if frame == 25 then node:resume() end
    if frame == 70 then node:sendPointer(100, 70, 1, true); node:sendPointer(100, 70, 1, false); node:sendKey("Space", true) end
    if frame == 105 then
        node:emit("ButtonDown", 7, "a")
        node:emit("Axis", 7, "leftx", 0.75)
        node:emit("Axis", 7, "leftx", 0.0)
        node:emit("ButtonUp", 7, "a")
    end
    if frame == 110 then
        D.emit("AppEvent", "WindowFocusGained")
        node:emit("ButtonDown", 7, "a")
        node:emit("Axis", 7, "leftx", 0.5)
        D.emit("AppEvent", "WindowFocusLost")
    end
    if frame == 112 then D.emit("AppEvent", "WindowFocusGained") end
    if frame == 115 then node:sendKey("Space", false) end
    if frame == 130 then node:pause() end
    if frame == 185 then node:resume() end
    if frame == 230 then assert(node:restart(""), "GodotNode restart") end
    if frame == 300 then assert(node:resizeViewport(480, 270), "GodotNode resize") end
    if frame >= 380 and frame <= 395 then
        local texture = node.texture
        local found = false
        for _, alias in ipairs(aliases) do if alias.texture == texture then found = true end end
        if not found and #aliases < 3 then
            local alias = D.Sprite(texture)
            alias.effect, alias.blendFunc = node.effect, node.blendFunc
            alias.scaleX, alias.scaleY = 0.25, 0.25
            alias.x, alias.y = -480, (#aliases - 1) * 110
            D.Director.ui:addChild(alias)
            aliases[#aliases + 1] = alias
        end
    end
    if frame == 450 then node:removeFromParent(); node = nil end
    if frame == 510 then create() end
    if frame == 535 then node:resume() end
    local name = captures[frame]
    if name then
        pending = true
        assert(D.Director:captureGameAsync("/user/" .. name .. ".png", function(ok)
            assert(ok, "Dora screenshot " .. name)
            print("DORA_WEB_NODE_CAPTURE " .. name .. " frame=" .. frame)
            pending = false
        end), "Dora capture request " .. name)
    end
    if frame == 620 then
        if node then node:removeFromParent(); node = nil end
        for _, alias in ipairs(aliases) do alias:removeFromParent() end
        print("DORA_WEB_NODE_DONE frames=" .. frame .. " aliases=" .. #aliases)
        return true
    end
    return false
end)
