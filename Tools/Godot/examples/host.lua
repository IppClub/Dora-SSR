local D = require("Dora")
local reason = D.GodotNode.getUnsupportedReason()
if reason ~= "" then
    print("Godot unavailable: " .. reason)
    return
end
local project = D.Content:getFullPath("GodotProject")
local node = D.GodotNode(project, "", 640, 360, 3)
if not node then
    print("Godot node could not be created; check the project path and viewport.")
    return
end
node:addTo(D.Director.ui)
local function fit()
    local size = D.View.size
    local scale = math.min(size.width / 640, size.height / 360) * 0.8
    node.scaleX, node.scaleY = scale, scale
end
fit()
local ready = false
node:schedule(function()
    fit()
    if node.lastError ~= "" then
        print("Godot startup failed: " .. node.lastError)
        node:removeFromParent()
        return true
    end
    if node.running and not ready then
        ready = true
        print("Godot example ready")
    end
    return false
end)
-- Control the same node with node:pause(), node:resume(), node:restart(),
-- or node:resizeViewport(800, 450). Only one GodotNode may be active.
return node
