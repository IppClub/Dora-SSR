local D = require("Dora")
assert(D.Director:beginGameCapture(), "Begin capture scope")
local node = assert(D.GodotNode("/game/godot", "", 640, 360, 3))
D.Director.ui:addChild(node)
local aliases = {}
local controller, frame, pending, waiting = D.Node(), 0, false, 0
D.Director.ui:addChild(controller)
controller:schedule(function()
    assert(node.lastError == "", node.lastError)
    if not node.running then
        waiting = waiting + 1
        assert(waiting < 900, "Godot startup timeout")
        return false
    end
    if pending then return false end
    frame = frame + 1
    local texture, found = node.texture, false
    for _, alias in ipairs(aliases) do if alias.texture == texture then found = true end end
    if not found and #aliases < 3 then
        local alias = D.Sprite(texture)
        alias.effect, alias.blendFunc = node.effect, node.blendFunc
        alias.scaleX, alias.scaleY = 0.25, 0.25
        alias.x, alias.y = -480, (#aliases - 1) * 110
        D.Director.ui:addChild(alias)
        aliases[#aliases + 1] = alias
    end
    if frame == 30 or frame == 90 then
        local name = frame == 30 and "active-a" or "active-b"
        pending = true
        assert(D.Director:captureGameAsync("/user/" .. name .. ".png", function(ok)
            assert(ok, "Active node screenshot")
            print("DORA_WEB_NODE_CAPTURE " .. name .. " frame=" .. frame)
            pending = false
        end))
    end
    if frame >= 120 then
        assert(#aliases == 3, "Retain every native texture slot before host stop")
        assert(D.Content:save("/user/active-stop.json", string.format(
            '{"running":true,"frame":%d,"aliases":%d,"buffers":3}', frame, #aliases)))
        if frame == 120 then print("DORA_WEB_ACTIVE_STOP_READY") end
    end
    -- Keep the node, aliases, animation and PCM alive until the host stops.
    return false
end)
