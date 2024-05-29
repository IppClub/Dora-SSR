-- [yue]: Script/Example/Body.yue
local Vec2 = Dora.Vec2 -- 1
local BodyDef = Dora.BodyDef -- 1
local PhysicsWorld = Dora.PhysicsWorld -- 1
local Body = Dora.Body -- 1
local threadLoop = Dora.threadLoop -- 1
local App = Dora.App -- 1
local ImGui = Dora.ImGui -- 1
local gravity <const> = Vec2(0, -10) -- 4
local groupZero <const> = 0 -- 6
local groupOne <const> = 1 -- 7
local groupTwo <const> = 2 -- 8
local terrainDef -- 10
do -- 10
	local _with_0 = BodyDef() -- 10
	_with_0.type = "Static" -- 11
	_with_0:attachPolygon(800, 10, 1, 0.8, 0.2) -- 12
	terrainDef = _with_0 -- 10
end -- 10
local polygonDef -- 14
do -- 14
	local _with_0 = BodyDef() -- 14
	_with_0.type = "Dynamic" -- 15
	_with_0.linearAcceleration = gravity -- 16
	_with_0:attachPolygon({ -- 18
		Vec2(60, 0), -- 18
		Vec2(30, -30), -- 19
		Vec2(-30, -30), -- 20
		Vec2(-60, 0), -- 21
		Vec2(-30, 30), -- 22
		Vec2(30, 30) -- 23
	}, 1, 0.4, 0.4) -- 17
	polygonDef = _with_0 -- 14
end -- 14
local diskDef -- 26
do -- 26
	local _with_0 = BodyDef() -- 26
	_with_0.type = "Dynamic" -- 27
	_with_0.linearAcceleration = gravity -- 28
	_with_0:attachDisk(60, 1, 0.4, 0.4) -- 29
	diskDef = _with_0 -- 26
end -- 26
do -- 31
	local world = PhysicsWorld() -- 31
	world.y = -200 -- 32
	world.showDebug = true -- 33
	world:setShouldContact(groupZero, groupOne, false) -- 35
	world:setShouldContact(groupZero, groupTwo, true) -- 36
	world:setShouldContact(groupOne, groupTwo, true) -- 37
	world:addChild((function() -- 39
		local _with_0 = Body(terrainDef, world, Vec2.zero) -- 39
		_with_0.group = groupTwo -- 40
		return _with_0 -- 39
	end)()) -- 39
	world:addChild((function() -- 42
		local _with_0 = Body(polygonDef, world, Vec2(0, 500), 15) -- 42
		_with_0.group = groupOne -- 43
		return _with_0 -- 42
	end)()) -- 42
	world:addChild((function() -- 45
		local _with_0 = Body(diskDef, world, Vec2(50, 800)) -- 45
		_with_0.group = groupZero -- 46
		_with_0.angularRate = 90 -- 47
		return _with_0 -- 45
	end)()) -- 45
end -- 31
local windowFlags = { -- 52
	"NoDecoration", -- 52
	"AlwaysAutoResize", -- 53
	"NoSavedSettings", -- 54
	"NoFocusOnAppearing", -- 55
	"NoNav", -- 56
	"NoMove" -- 57
} -- 51
return threadLoop(function() -- 58
	local width -- 59
	width = App.visualSize.width -- 59
	ImGui.SetNextWindowBgAlpha(0.35) -- 60
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 61
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 62
	return ImGui.Begin("Body", windowFlags, function() -- 63
		ImGui.Text("Body (Yuescript)") -- 64
		ImGui.Separator() -- 65
		return ImGui.TextWrapped("Basic usage to create physics bodies!") -- 66
	end) -- 66
end) -- 66
