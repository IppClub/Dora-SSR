-- QA controller for the unchanged upstream Godot "Dodge the Creeps" project.
-- The project itself is copied from godotengine/godot-demo-projects and is not
-- patched; this script only drives Dora's public GodotNode API.
local D = Dora
D.App.devMode = false
D.App.winSize = D.Size(1280, 800)
D.Director.clearColor = D.Color(0xff192331)
assert(D.GodotNode.getUnsupportedReason() == "")
assert(D.Director:beginGameCapture())

local marker = D.DrawNode()
marker:drawPolygon({
	D.Vec2(-45, -45), D.Vec2(45, -45),
	D.Vec2(45, 45), D.Vec2(-45, 45),
}, D.Color(0xff00ff00))
marker.x = -520
marker:addTo(D.Director.ui, 100)

local game = assert(D.GodotNode(@PROJECT@, "", 480, 720, 3))
game.scaleX, game.scaleY = 0.85, 0.85
game:addTo(D.Director.ui)

local control = D.Node()
control:addTo(D.Director.ui)
local ready, ticks, elapsed, pending, captures = false, 0, 0, false, 0

local function capture(name)
	pending = true
	assert(D.Director:captureGameAsync(@OUTPUT@ .. "/" .. name .. ".png", function(ok)
		assert(ok)
		captures = captures + 1
		pending = false
		print("DORA_DODGE capture=" .. name)
	end))
end

control:schedule(function(dt)
	elapsed = elapsed + dt
	assert(elapsed < 45, "Dodge the Creeps acceptance timed out")
	if not ready then
		assert(game.lastError == "", game.lastError)
		if not game.running then return false end
		ready = true
		print("DORA_DODGE running=1")
	end
	if pending then return false end
	ticks = ticks + 1
	if game then assert(game.running and game.lastError == "", game.lastError) end
	if ticks == 30 then capture("title") end
	-- The upstream button occupies x=150..330, y=520..620 in its 480x720 viewport.
	if ticks == 45 then
		game:sendPointer(240, 570, 1, true)
		game:sendPointer(240, 570, 1, false)
		print("DORA_DODGE start_click=1")
	end
	if ticks == 60 then capture("input-before") end
	if ticks == 65 then game:sendKey("D", true) end
	if ticks == 100 then game:sendKey("D", false) end
	if ticks == 105 then capture("input-after") end
	if ticks == 180 then capture("active-a") end
	if ticks == 240 then capture("active-b") end
	if ticks == 255 then game:pause(); assert(game.paused); print("DORA_DODGE paused=1") end
	if ticks == 285 then capture("paused-a") end
	if ticks == 325 then capture("paused-b") end
	if ticks == 330 then game:resume(); assert(not game.paused); print("DORA_DODGE resumed=1") end
	if ticks == 380 then capture("resumed") end
	if ticks == 400 then game:removeFromParent(); game = nil end
	if ticks == 430 then capture("removed") end
	if ticks == 455 then
		assert(captures == 9)
		print("DORA_DODGE complete=1 captures=9 ticks=455")
		D.Director:endGameCapture()
		D.App:shutdown()
		return true
	end
	return false
end)
