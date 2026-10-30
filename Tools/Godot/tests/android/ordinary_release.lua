-- Public Lua APIs in a normal nondebuggable Release APK, without native test entrypoints.
local D = require("Dora")
D.App.devMode = false
D.Director.clearColor = D.Color(0xff192331)
local C, P = D.Content, D.Path
local work = P(C.writablePath, "godot-release")
if not C:exist(work) then assert(C:mkdir(work)) end
local config = P(work, "buffers.txt")
if not C:exist(config) then assert(C:save(config, "3")) end
local buffers = assert(tonumber(C:load(config)))
assert(buffers >= 2 and buffers <= 4)
local missing = C:exist(P(work, "expect-missing"))
local project = P(work, "project")
assert(C:copy("GodotProject", project))
local cache = P(project, ".godot")
if not C:exist(cache) then assert(C:mkdir(cache)) end
assert(C:save(P(cache, "global_script_class_cache.cfg"), "list=[]\n"))
assert(D.GodotNode.getUnsupportedReason() == "")
assert(D.Director:beginGameCapture())
local node = assert(D.GodotNode(project, "", 640, 360, buffers))
node:addTo(D.Director.ui)
local size = D.View.size
local scale = math.min(size.width / 640, size.height / 360) * 0.65
node.scaleX, node.scaleY = scale, scale
print(string.format("DORA_RELEASE view=%dx%d scale=%.6f buffers=%d missing=%d", size.width, size.height, scale, buffers, missing and 1 or 0))
local ordinary = D.DrawNode()
ordinary:drawPolygon({D.Vec2(-16,-16),D.Vec2(16,-16),D.Vec2(16,16),D.Vec2(-16,16)},D.Color(0xffff00ff))
ordinary.y = size.height * 0.38
ordinary:addTo(D.Director.ui, 100)
local control = D.Node()
control:addTo(D.Director.ui)
local ready, ticks, elapsed, pending, captures = false, 0, 0, false, 0
local function capture(name)
    pending = true
    assert(D.Director:captureGameAsync(P(work,name..".png"),function(ok)
        assert(ok)
        captures = captures + 1
        pending = false
        print("DORA_RELEASE capture=" .. name)
    end))
end
control:schedule(function(dt)
    elapsed = elapsed + dt
    assert(elapsed < 60, "Release package acceptance timed out")
    ordinary.x = math.sin(elapsed * 2) * size.width * 0.35
    if not ready then
        if missing then
            if node.lastError == "" then return false end
            assert(not node.running and node.lastError:find("libgodot_android.so",1,true))
            print("DORA_RELEASE missing_library_rejected=1")
            node:removeFromParent(); node = nil
        else
            assert(node.lastError == "",node.lastError)
            if not node.running then return false end
            print("DORA_RELEASE running=1")
        end
        ready = true
    end
    if pending then return false end
    ticks = ticks + 1
    if missing then
        if ticks == 30 then capture("fallback-a") end
        if ticks == 70 then capture("fallback-b") end
        if ticks == 90 then
            assert(captures == 2)
            assert(C:save(P(work,"result.json"),'{"complete":true,"missing":true,"captures":2}'))
            print("DORA_RELEASE complete=1 missing=1 captures=2")
            D.Director:endGameCapture();D.App:shutdown();return true
        end
        return false
    end
    if node then assert(node.running and node.lastError == "",node.lastError) end
    if ticks == 30 then capture("animated-a") end
    if ticks == 55 then capture("animated-b") end
    if ticks == 65 then node:pause();assert(node.paused) end
    if ticks == 90 then capture("paused-a") end
    if ticks == 115 then capture("paused-b") end
    if ticks == 120 then node:resume();assert(not node.paused) end
    if ticks == 150 then capture("resumed") end
    if ticks == 160 then
        assert(not D.Wasm:executeMainFile("ffi-trap.wasm"))
        print("DORA_RELEASE ffi_trap_recovered=1")
    end
    if ticks == 165 then node:sendPointer(320,220,1,true);node:sendPointer(320,220,1,false) end
    if ticks == 175 then capture("input") end
    if ticks == 185 then node:removeFromParent();node = nil end
    if ticks == 215 then capture("removed") end
    if ticks == 235 then
        assert(captures == 7)
        assert(C:save(P(work,"result.json"),string.format('{"complete":true,"missing":false,"captures":7,"buffers":%d}',buffers)))
        print("DORA_RELEASE complete=1 missing=0 captures=7")
        D.Director:endGameCapture();D.App:shutdown();return true
    end
    return false
end)
