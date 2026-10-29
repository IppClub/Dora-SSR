local D = require("Dora")
D.App.devMode = false
D.App.winSize = D.Size(1280,720)
assert(D.Director:beginGameCapture())
local green = D.DrawNode()
green:drawPolygon({D.Vec2(-40,-40),D.Vec2(40,-40),D.Vec2(40,40),D.Vec2(-40,40)},D.Color(0xff00ff00))
D.Director.ui:addChild(green,100)
local control, observed, age, phase, captured = D.Node(), false, 0, 0, 0
D.Director.ui:addChild(control)
control:gslot("GodotBindingAsyncError",function(language,message)
    assert(language == @LANGUAGE@ and message:find(@EXPECTED@,1,true))
    assert(not observed)
    observed = true
    print("GODOT_BINDING_ASYNC_HOST observed=1")
end)
-- The language fixture reports the asynchronous error through the public event.
control:schedule(function(dt)
    assert(D.App.runningTime < 30, "Binding fault test timed out")
    if not observed then return false end
    age = age + dt
    if phase < 2 and age > (phase == 0 and 0.5 or 1.5) then
        phase = phase + 1
        green.x = (phase == 1 and -220 or 220) * D.View.size.width / 1280
        local path = @OUTPUT@ .. "/frame-" .. phase .. ".png"
        assert(D.Director:captureGameAsync(path,function(ok)
            assert(ok)
            captured = captured + 1
        end))
    end
    if captured == 2 and age > 2 then
        print("GODOT_BINDING_ASYNC_HOST complete=1 captures=2")
        D.App:shutdown()
        return true
    end
    return false
end)
