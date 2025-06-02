-- [yue]: Script/Example/Contact.yue
local Vec2 = Dora.Vec2 -- 1
local PhysicsWorld = Dora.PhysicsWorld -- 1
local Label = Dora.Label -- 1
local BodyDef = Dora.BodyDef -- 1
local math = _G.math -- 1
local Body = Dora.Body -- 1
local Line = Dora.Line -- 1
local App = Dora.App -- 1
local string = _G.string -- 1
local threadLoop = Dora.threadLoop -- 1
local ImGui = Dora.ImGui -- 1
local gravity = Vec2(0, -10) -- 3
local world -- 5
do -- 5
	local _with_0 = PhysicsWorld() -- 5
	_with_0:setShouldContact(0, 0, true) -- 6
	_with_0.showDebug = true -- 7
	world = _with_0 -- 5
end -- 5
local label -- 9
do -- 9
	local _with_0 = Label("sarasa-mono-sc-regular", 30) -- 9
	_with_0:addTo(world) -- 10
	label = _with_0 -- 9
end -- 9
local terrainDef -- 12
do -- 12
	local _with_0 = BodyDef() -- 12
	local count = 50 -- 13
	local radius = 300 -- 14
	local vertices -- 15
	do -- 15
		local _accum_0 = { } -- 15
		local _len_0 = 1 -- 15
		for i = 1, count + 1 do -- 15
			local angle = 2 * math.pi * i / count -- 16
			_accum_0[_len_0] = Vec2(radius * math.cos(angle), radius * math.sin(angle)) -- 17
			_len_0 = _len_0 + 1 -- 16
		end -- 17
		vertices = _accum_0 -- 15
	end -- 17
	_with_0:attachChain(vertices, 0.4, 0) -- 18
	_with_0:attachDisk(Vec2(0, -270), 30, 1, 0, 1.0) -- 19
	_with_0:attachPolygon(Vec2(0, 80), 120, 30, 0, 1, 0, 1.0) -- 20
	terrainDef = _with_0 -- 12
end -- 12
do -- 22
	local terrain = Body(terrainDef, world) -- 22
	terrain:addTo(world) -- 23
end -- 22
local drawNode -- 25
do -- 25
	local _with_0 = Line({ -- 26
		Vec2(-20, 0), -- 26
		Vec2(20, 0), -- 27
		Vec2.zero, -- 28
		Vec2(0, -20), -- 29
		Vec2(0, 20) -- 30
	}, App.themeColor) -- 25
	_with_0:addTo(world) -- 32
	drawNode = _with_0 -- 25
end -- 25
local diskDef -- 34
do -- 34
	local _with_0 = BodyDef() -- 34
	_with_0.type = "Dynamic" -- 35
	_with_0.linearAcceleration = gravity -- 36
	_with_0:attachDisk(20, 5, 0.8, 1) -- 37
	diskDef = _with_0 -- 34
end -- 34
local disk -- 39
do -- 39
	local _with_0 = Body(diskDef, world, Vec2(100, 200)) -- 39
	_with_0:addTo(world) -- 40
	_with_0.angularRate = -1800 -- 41
	_with_0:onContactStart(function(_target, point, _normal, _enabled) -- 42
		drawNode.position = point -- 43
		label.text = string.format("Contact: [%.0f,%.0f]", point.x, point.y) -- 44
	end) -- 42
	disk = _with_0 -- 39
end -- 39
local windowFlags = { -- 49
	"NoDecoration", -- 49
	"AlwaysAutoResize", -- 49
	"NoSavedSettings", -- 49
	"NoFocusOnAppearing", -- 49
	"NoNav", -- 49
	"NoMove" -- 49
} -- 49
local receivingContact = disk.receivingContact -- 57
return threadLoop(function() -- 58
	local width -- 59
	width = App.visualSize.width -- 59
	ImGui.SetNextWindowBgAlpha(0.35) -- 60
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 61
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 62
	return ImGui.Begin("Contact", windowFlags, function() -- 63
		ImGui.Text("Contact (Yuescript)") -- 64
		ImGui.Separator() -- 65
		ImGui.TextWrapped("Receive events when physics bodies contact.") -- 66
		local changed -- 67
		changed, receivingContact = ImGui.Checkbox("Receiving Contact", receivingContact) -- 67
		if changed then -- 67
			disk.receivingContact = receivingContact -- 68
			label.text = "" -- 69
		end -- 67
	end) -- 69
end) -- 69
