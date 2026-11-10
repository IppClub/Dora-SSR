-- Ordinary Dora player used by project.lua; placeholders are replaced once.
local D = Dora
local function play()
D.App.devMode = false
local elapsed, readyAt, closeAt = 0, nil, nil
local pending, captured, failed = false, false, false
local function report(state)
    assert(D.Content:save(@STATE@, string.format(
        '{"state":"%s","ready":%s,"captured":%s,"failed":%s}',
        state, tostring(readyAt ~= nil), tostring(captured), tostring(failed))))
end
report("booting")
local reason = D.GodotNode.getUnsupportedReason()
assert(reason == "", reason)
local capture = @CAPTURE@
if capture ~= "" then assert(D.Director:beginGameCapture()) end
local game = assert(D.GodotNode(@PROJECT@, "", @WIDTH@, @HEIGHT@, @BUFFERS@))
game:addTo(D.Director.ui)
local control = D.Node()
control:addTo(D.Director.ui)
local function fail(message)
    failed = true
    D.Content:save(@ERROR@, tostring(message))
    report("failed")
    print("DORA_GAME_FAILED " .. tostring(message))
    game:removeFromParent()
    closeAt = elapsed + 0.25
end
local function step(dt)
    elapsed = elapsed + dt
    if closeAt then
        if elapsed >= closeAt then
            if not failed then report("closed") end
            if capture ~= "" then D.Director:endGameCapture() end
            D.App:shutdown()
            return true
        end
        return false
    end
    if game.lastError ~= "" then
        if readyAt and game.lastError == "Godot project requested quit" then
            game:removeFromParent()
            closeAt = elapsed + 0.25
        else
            fail(game.lastError)
        end
        return false
    end
    local view = D.View.size
    local size = game.viewportSize
    local scale = math.min(view.width / size.width, view.height / size.height)
    game.scaleX, game.scaleY = scale, scale
    if game.running and not readyAt then
        readyAt = elapsed
        report("ready")
        print("DORA_GAME_READY")
    end
    if not readyAt then
        if elapsed > 60 then
            fail("startup timeout")
        end
        return false
    end
    if capture ~= "" and not pending and not captured and elapsed - readyAt > 0.5 then
        pending = true
        assert(D.Director:captureGameAsync(capture, function(ok)
            assert(ok, "Game capture failed")
            pending, captured = false, true
            report("ready")
            print("DORA_GAME_CAPTURED")
        end))
    end
    if @DURATION@ > 0 and elapsed - readyAt >= @DURATION@ and not pending
        and (capture == "" or captured) then
        game:removeFromParent()
        closeAt = elapsed + 0.25
        print("DORA_GAME_CLOSED")
    end
    return false
end
control:schedule(function(dt)
    local ok, result = pcall(step, dt)
    if not ok then fail(result); return false end
    return result
end)

end
local ok, message = xpcall(play, debug.traceback)
if not ok then
    D.Content:save(@ERROR@, tostring(message))
    D.Content:save(@STATE@, '{"state":"failed","ready":false,"captured":false,"failed":true}')
    D.App:shutdown()
end
