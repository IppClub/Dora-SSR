local _ENV = Dora

local lastMetrics
local lastKeyA = false
local lastLeftButton = false
local lastControllerA = false
local lastControllerAxis = 0
Director.ui.touchEnabled = true
Director.ui.controllerEnabled = true
Director.ui:slot("TapBegan", function(touch)
	local pos = touch.location
	local source = touch.fromMouse and "mouse" or "touch"
	print(string.format("Dora Web input %s-began id=%d x=%.1f y=%.1f", source, touch.id, pos.x, pos.y))
end)
Director.ui:slot("TapMoved", function(touch)
	local pos = touch.location
	local source = touch.fromMouse and "mouse" or "touch"
	print(string.format("Dora Web input %s-moved id=%d x=%.1f y=%.1f", source, touch.id, pos.x, pos.y))
end)
Director.ui:slot("TapEnded", function(touch)
	local source = touch.fromMouse and "mouse" or "touch"
	print(string.format("Dora Web input %s-ended id=%d", source, touch.id))
end)
Director.ui:slot("ButtonDown", function(controllerId, button)
	print(string.format("Dora Web gamepad button-down id=%d button=%s", controllerId, button))
end)
Director.ui:slot("ButtonUp", function(controllerId, button)
	print(string.format("Dora Web gamepad button-up id=%d button=%s", controllerId, button))
end)
Director.ui:slot("Axis", function(controllerId, axis, value)
	print(string.format("Dora Web gamepad axis id=%d axis=%s value=%.3f", controllerId, axis, value))
end)
Director.postScheduler:schedule(function()
	local visual = App.visualSize
	local buffer = App.bufferSize
	local metrics = string.format(
		"visual=%dx%d buffer=%dx%d dpr=%.3f fullscreen=%s",
		visual.width,
		visual.height,
		buffer.width,
		buffer.height,
		App.devicePixelRatio,
		tostring(App.fullScreen)
	)
	if metrics ~= lastMetrics then
		lastMetrics = metrics
		print("Dora SSR Web Player metrics " .. metrics)
	end
	local keyA = Keyboard:isKeyPressed("A")
	if keyA ~= lastKeyA then
		lastKeyA = keyA
		print("Dora Web input key=A pressed=" .. tostring(keyA))
	end
	local leftButton = Mouse.leftButtonPressed
	if leftButton ~= lastLeftButton then
		lastLeftButton = leftButton
		local pos = Mouse.position
		print(string.format("Dora Web input mouse-left=%s x=%.1f y=%.1f", tostring(leftButton), pos.x, pos.y))
	end
	local wheel = Mouse.wheel
	if wheel.x ~= 0 or wheel.y ~= 0 then
		print(string.format("Dora Web input wheel x=%.1f y=%.1f", wheel.x, wheel.y))
	end
	local controllerA = Controller:isButtonPressed(0, "a")
	if controllerA ~= lastControllerA then
		lastControllerA = controllerA
		print("Dora Web gamepad a=" .. tostring(controllerA))
	end
	local controllerAxis = Controller:getAxis(0, "leftx")
	if math.abs(controllerAxis - lastControllerAxis) > 0.01 then
		lastControllerAxis = controllerAxis
		print(string.format("Dora Web gamepad leftx=%.3f", controllerAxis))
	end
	return false
end)

thread(function()
	local lazyText = Content:loadAsync("lazy.txt")
	assert(lazyText == "Dora Web lazy asset ready\n", "lazy Web asset content mismatch")
	assert(Content:loadAsync("Image/logo.png"), "Sprite fixture failed to load")
	assert(Content:loadAsync("Font/web-fixture.ttf"), "Label fixture font failed to load")
	assert(Content:loadAsync("Audio/fixture.wav"), "WAV fixture failed to load")
	assert(Content:loadAsync("Audio/fixture.ogg"), "OGG fixture failed to load")
	assert(Content:loadAsync("Particle/fire.par"), "Particle fixture failed to load")
	assert(Content:loadAsync("Spine/web-spine.atlas"), "Spine atlas fixture failed to load")
	assert(Content:loadAsync("Spine/web-spine.json"), "Spine skeleton fixture failed to load")
	assert(Content:loadAsync("Spine/web-spine.png"), "Spine texture fixture failed to load")
	assert(Content:loadAsync("DragonBones/web-dragon_ske.json"), "DragonBones skeleton fixture failed to load")
	assert(Content:loadAsync("DragonBones/web-dragon_tex.json"), "DragonBones atlas fixture failed to load")
	assert(Content:loadAsync("DragonBones/web-dragon.png"), "DragonBones texture fixture failed to load")
	local imguiFontReady = false
	Director.systemScheduler:schedule(function()
		ImGui.SetDefaultFont("Font/web-fixture.ttf", 22)
		imguiFontReady = true
		return true
	end)
	wait(function()
		return imguiFontReady
	end)
	local imguiBoundsPrinted = false
	Director.postScheduler:schedule(function()
		ImGui.SetNextWindowPos(Vec2(20, 260), "Always")
		ImGui.SetNextWindowSize(Vec2(220, 160), "Always")
		ImGui.PushStyleColor("WindowBg", Color(0xff203050))
		local visible = ImGui.Begin("Web ImGui")
		if visible then
			ImGui.Text("Dora Web UI")
			local buttonStart = ImGui.GetCursorScreenPos()
			ImGui.PushClipRect(buttonStart, Vec2(buttonStart.x + 72, buttonStart.y + 48), true)
			ImGui.PushStyleColor("Button", Color(0xffe04080))
			local clicked = ImGui.Button("Capture", Vec2(140, 42))
			local buttonMin = ImGui.GetItemRectMin()
			local buttonMax = ImGui.GetItemRectMax()
			ImGui.PopStyleColor()
			ImGui.PopClipRect()
			if not imguiBoundsPrinted then
				imguiBoundsPrinted = true
				print(string.format("Dora Web ImGui button bounds %.1f %.1f %.1f %.1f", buttonMin.x, buttonMin.y, buttonMax.x, buttonMax.y))
			end
			if clicked then
				print("Dora Web ImGui button clicked")
			end
		end
		ImGui.End()
		ImGui.PopStyleColor()
		return false
	end)
	local oldVolume = Audio.globalVolume
	Audio.globalVolume = 0.25
	local audioHandle = Audio:play("Audio/fixture.wav", true)
	assert(audioHandle ~= 0, "WAV fixture failed to play")
	Audio:setPauseAllCurrent(true)
	Audio:setPauseAllCurrent(false)
	Audio:stop(audioHandle)
	local oggHandle = Audio:play("Audio/fixture.ogg", false)
	assert(oggHandle ~= 0, "OGG fixture failed to play")
	Audio:stop(oggHandle)
	Audio.globalVolume = oldVolume
	print("Dora Web WAV/OGG play/loop/pause/volume/stop verified")

	local marker = DrawNode()
	marker:drawPolygon({
		Vec2(-180, -90),
		Vec2(180, -90),
		Vec2(180, 90),
		Vec2(-180, 90),
	}, Color(0xff4cc38a))
	Director.ui:addChild(marker)

	local sprite = Sprite("Image/logo.png")
	assert(sprite, "Sprite fixture failed to create")
	sprite.x = -260
	sprite.scaleX = 0.32
	sprite.scaleY = 0.32
	Director.ui:addChild(sprite)

	local label = Label("web-fixture", 44, true)
	assert(label, "Label fixture failed to create")
	label.text = "Dora Web"
	label.x = 120
	Director.ui:addChild(label)

	local renderTarget = RenderTarget(192, 192)
	assert(renderTarget, "RenderTarget fixture failed to create")
	assert(renderTarget.width == 192 and renderTarget.height == 192, "RenderTarget fixture size mismatch")
	local renderRoot = DrawNode()
	renderRoot:drawPolygon({
		Vec2(0, 0),
		Vec2(192, 0),
		Vec2(192, 192),
		Vec2(0, 192),
	}, Color(0xff17324d))
	local blended = DrawNode()
	blended.blendFunc = BlendFunc("SrcAlpha", "InvSrcAlpha")
	blended:drawPolygon({
		Vec2(16, 16),
		Vec2(112, 16),
		Vec2(112, 112),
		Vec2(16, 112),
	}, Color(0x80e85845))
	renderRoot:addChild(blended)
	local stencil = DrawNode()
	stencil:drawPolygon({
		Vec2(120, 16),
		Vec2(176, 16),
		Vec2(176, 80),
		Vec2(120, 80),
	}, Color(0xffffffff))
	local clipped = ClipNode(stencil)
	local clippedContent = DrawNode()
	clippedContent:drawPolygon({
		Vec2(96, 0),
		Vec2(192, 0),
		Vec2(192, 96),
		Vec2(96, 96),
	}, Color(0xffffd166))
	clipped:addChild(clippedContent)
	renderRoot:addChild(clipped)
	local scissor = ScissorNode(24, 16, 32, 48)
	local scissoredContent = DrawNode()
	scissoredContent:drawPolygon({
		Vec2(0, 8),
		Vec2(64, 8),
		Vec2(64, 72),
		Vec2(0, 72),
	}, Color(0xff45d9e8))
	scissor:addChild(scissoredContent)
	renderRoot:addChild(scissor)
	renderTarget:renderWithClear(renderRoot, Color(0xff102030))

	local targetSprite = Sprite(renderTarget.texture)
	assert(targetSprite, "RenderTarget texture Sprite failed to create")
	targetSprite.y = -220
	targetSprite.scaleX = 0.75
	targetSprite.scaleY = 0.75
	Director.ui:addChild(targetSprite)

	local particle = Particle("Particle/fire.par")
	assert(particle, "Particle fixture failed to create")
	particle.x = -430
	particle.y = -220
	particle:start()
	assert(particle.active, "Particle fixture failed to start")
	Director.ui:addChild(particle)

	local spine = Spine("Spine/web-spine")
	assert(spine, "Spine fixture failed to create")
	spine.x = 300
	spine.y = -220
	spine.scaleX = 0.55
	spine.scaleY = 0.55
	assert(spine:play("pulse", true) > 0, "Spine fixture animation failed to play")
	Director.ui:addChild(spine)

	local dragon = DragonBone("DragonBones/web-dragon")
	assert(dragon, "DragonBones fixture failed to create")
	dragon.x = 440
	dragon.y = -220
	dragon.scaleX = 0.5
	dragon.scaleY = 0.5
	assert(dragon:play("pulse", true) > 0, "DragonBones fixture animation failed to play")
	Director.ui:addChild(dragon)

	local vector = VGNode(160, 120, 1, 1)
	assert(vector, "NanoVG fixture failed to create")
	vector.x = -440
	vector.y = 180
	vector:render(function()
		nvg.BeginPath()
		nvg.Rect(0, 0, 160, 120)
		nvg.FillColor(Color(0xff49306b))
		nvg.Fill()
		nvg.Save()
		nvg.Scissor(40, 30, 80, 60)
		nvg.BeginPath()
		nvg.Circle(80, 60, 52)
		nvg.FillColor(Color(0xff7ee081))
		nvg.Fill()
		nvg.Restore()
	end)
	Director.ui:addChild(vector)

	local physics = PhysicsWorld()
	assert(physics, "PlayRho PhysicsWorld fixture failed to create")
	physics.x = 400
	physics.y = 180
	physics.showDebug = true
	physics:setIterations(4, 2)
	Director.ui:addChild(physics)

	local floorDef = BodyDef()
	floorDef.type = "Static"
	floorDef:attachPolygon(180, 20, 0, 0.6, 0)
	local floor = Body(floorDef, physics, Vec2(0, -40))
	assert(floor, "PlayRho static body fixture failed to create")
	physics:addChild(floor)

	local fallingDef = BodyDef()
	fallingDef.type = "Dynamic"
	fallingDef.fixedRotation = true
	fallingDef.linearAcceleration = Vec2(0, -500)
	fallingDef:attachPolygon(40, 40, 1, 0.4, 0)
	local falling = Body(fallingDef, physics, Vec2(0, 80))
	assert(falling and falling.mass > 0, "PlayRho dynamic body fixture failed to create")
	physics:addChild(falling)
	wait(function()
		return falling.y < 15
	end)
	local rayHit = false
	physics:raycast(Vec2(0, 100), Vec2(0, -80), true, function(body, point, normal)
		rayHit = body ~= nil and point.y < 100 and normal.y > 0
		return true
	end)
	assert(rayHit, "PlayRho raycast fixture failed")
	print(string.format("Dora Web PlayRho verified y=%.3f mass=%.3f", falling.y, falling.mass))

	local readbackDone = false
	local readbackSucceeded = false
	renderTarget:saveAsync("/tmp/dora-web-render-target.png", function(success)
		readbackSucceeded = success
		readbackDone = true
	end)
	wait(function()
		return readbackDone
	end)
	assert(readbackSucceeded, "RenderTarget readback failed")

	local function runCompiledExample(sourcePath, luaPath, sourceMarker)
		local source = Content:loadAsync(sourcePath)
		assert(source and source:find(sourceMarker, 1, true), sourcePath .. " source marker is missing")
		local luaSource = Content:loadAsync(luaPath)
		assert(luaSource and luaSource:find(sourcePath, 1, true), luaPath .. " generation provenance is missing")
		local chunk, loadError = load(luaSource, "@" .. luaPath, "t", Dora)
		assert(chunk, loadError)
		chunk()
	end

	local luaSource = Content:loadAsync("Examples/LuaSprite.lua")
	local luaChunk, luaError = load(luaSource, "@Examples/LuaSprite.lua", "t", Dora)
	assert(luaChunk, luaError)
	luaChunk()
	runCompiledExample("Examples/YueDraw.yue", "Examples/YueDraw.lua", "_ENV = Dora")
	runCompiledExample("Examples/TealLabel.tl", "Examples/TealLabel.lua", "local Label")

	print("Dora SSR Web Player manifest game ready; lazy asset, Sprite, Label, RenderTarget, blend, scissor, stencil, Particle, Spine, DragonBones, NanoVG, PlayRho, ImGui and Lua/YueScript/Teal examples verified")
end)
