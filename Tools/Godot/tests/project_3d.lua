local D = Dora
D.App.devMode = false
D.App.winSize = D.Size(1280,720)
D.Director.clearColor = D.Color(0xff192331)
assert(D.GodotNode.getUnsupportedReason() == "")
assert(D.Director:beginGameCapture())
local node = assert(D.GodotNode(@PROJECT@, "res://main.tscn",640,360,3))
node:addTo(D.Director.ui)
local control = D.Node()
control:addTo(D.Director.ui)
local ready, ticks, elapsed, pending, captures = false, 0, 0, false, 0
local function capture(name)
    pending = true
    assert(D.Director:captureGameAsync(@OUTPUT@ .. "/" .. name .. ".png",function(ok)
        assert(ok)
        captures = captures + 1
        pending = false
        print("DORA_PROJECT_3D capture=" .. name)
    end))
end
control:schedule(function(dt)
    elapsed = elapsed + dt
    assert(elapsed < 40,"3D project timeout")
    if not ready then
        assert(node.lastError == "", node.lastError)
        if not node.running then return false end
        ready = true
        print("DORA_PROJECT_3D running=1")
    end
    if pending then return false end
    ticks = ticks + 1
    if node then assert(node.lastError == "" and node.running) end
    if ticks == 30 then capture("animated-a") end
    if ticks == 50 then capture("animated-b") end
    if ticks == 65 then node:pause();assert(node.paused);print("DORA_PROJECT_3D paused=1") end
    if ticks == 90 then capture("paused-a") end
    if ticks == 115 then capture("paused-b") end
    if ticks == 120 then node:resume();assert(not node.paused);print("DORA_PROJECT_3D resumed=1") end
    if ticks == 150 then capture("resumed") end
    if ticks == 180 then node:removeFromParent();node = nil end
    if ticks == 210 then capture("removed") end
    if ticks == 230 then
        assert(captures == 6)
        print("DORA_PROJECT_3D complete=1 captures=6 ticks=230")
        D.Director:endGameCapture()
        D.App:shutdown()
        return true
    end
    return false
end)
