local D = Dora
D.App.devMode = false
local output, first, other = @OUTPUT@, @FIRST@, @OTHER@
local expectedError = @EXPECTED_ERROR@
assert(D.GodotNode.getUnsupportedReason() == "")
assert(D.Director:beginGameCapture())
D.Director.clearColor = D.Color(0xff192331)
local node = assert(D.GodotNode(first, "res://main.tscn", 640, 360, 3))
node:addTo(D.Director.ui)
local control = D.Node()
control:addTo(D.Director.ui)
local phase, ticks, elapsed, pending, captures = 0, 0, 0, false, 0
local function capture(name)
    pending = true
    assert(D.Director:captureGameAsync(output .. "/" .. name .. ".png", function(ok)
        assert(ok, name)
        captures, pending = captures + 1, false
        print("GODOT_PROJECT_BOUNDARY capture=" .. name)
    end))
end
control:schedule(function(dt)
    elapsed = elapsed + dt
    assert(elapsed < 45, "Project boundary timeout")
    if pending then return false end
    if phase == 0 or phase == 4 then
        assert(node.lastError == "", node.lastError)
        if not node.running then return false end
        phase, ticks = phase + 1, 0
        print("GODOT_PROJECT_BOUNDARY running=" .. (phase == 1 and "initial" or "recovered"))
    elseif phase == 1 or phase == 5 then
        assert(node.running and node.lastError == "", node.lastError)
        ticks = ticks + 1
        local prefix = phase == 1 and "initial" or "recovered"
        if ticks == 30 then capture(prefix .. "-a") end
        if ticks == 60 then capture(prefix .. "-b") end
        if ticks == 90 then
            node:removeFromParent()
            node, phase, ticks = nil, phase + 1, 0
        end
    elseif phase == 2 or phase == 6 then
        ticks = ticks + 1
        if ticks == 30 and phase == 2 then capture("removed") end
        if ticks == 60 then
            if phase == 6 then
                assert(captures == 5)
                print("GODOT_PROJECT_BOUNDARY complete=1 captures=5")
                D.Director:endGameCapture()
                D.App:shutdown()
                return true
            end
            node = assert(D.GodotNode(other, "res://main.tscn", 640, 360, 3))
            node:addTo(D.Director.ui)
            phase = 3
        end
    elseif phase == 3 then
        assert(not node.running, "Different project unexpectedly started")
        if node.lastError == "" then return false end
        assert(node.lastError:find(expectedError, 1, true), node.lastError)
        print("GODOT_PROJECT_BOUNDARY different_project_rejected=1")
        node:removeFromParent()
        node, phase, ticks = nil, 7, 0
    elseif phase == 7 then
        ticks = ticks + 1
        if ticks == 60 then
            node = assert(D.GodotNode(first, "res://main.tscn", 640, 360, 3))
            node:addTo(D.Director.ui)
            phase = 4
        end
    end
    return false
end)
