-- Executed as the startup script in a staged ordinary application bundle.
local D = Dora
D.App.devMode = false
local out = @OUTPUT@
local missing = @MISSING@
assert(D.GodotNode.getUnsupportedReason() == "")
assert(D.Director:beginGameCapture())
local ordinary = D.DrawNode()
ordinary:drawPolygon({D.Vec2(-40,-40),D.Vec2(40,-40),D.Vec2(40,40),D.Vec2(-40,40)},D.Color(0xff00ff00))
ordinary.x = -220
ordinary:addTo(D.Director.ui, 100)
local godot = D.GodotNode(@PROJECT@, "res://main.tscn", 640, 360, 3)
assert(godot)
assert(godot.projectPath == @EXPECTED_PROJECT_PATH@, "Relative project path resolved incorrectly")
godot:addTo(D.Director.ui)
local control = D.Node()
control:addTo(D.Director.ui)
local elapsed, ready, phase, captured = 0, nil, 0, 0
control:schedule(function(dt)
    elapsed = elapsed + dt
    if elapsed > 20 then error("Ordinary Godot acceptance timed out") end
    if not ready then
        if missing then
            if godot.lastError == "" then return false end
            assert(not godot.running)
            assert(godot.lastError:find(@LIBRARY_NAME@, 1, true))
            print("GODOT_ORDINARY missing_library_rejected=1")
            godot:removeFromParent()
            godot = nil
        else
            assert(godot.lastError == "", godot.lastError)
            if not godot.running then return false end
            print("GODOT_ORDINARY running=1")
        end
        ready = elapsed
    end
    local age = elapsed - ready
    if phase < 2 and age > (phase == 0 and 1 or 2) then
        phase = phase + 1
        ordinary.x = phase == 1 and -220 or 220
        local name = "frame-" .. phase .. ".png"
        assert(D.Director:captureGameAsync(out .. "/" .. name, function(ok)
            assert(ok)
            captured = captured + 1
            print("GODOT_ORDINARY capture=" .. name)
        end))
    end
    if captured == 2 and age > 3 then
        if godot then godot:removeFromParent(); godot = nil end
        if age > 4 then
            print("GODOT_ORDINARY complete=1")
            D.Director:endGameCapture()
            D.App:shutdown()
            return true
        end
    end
    return false
end)
