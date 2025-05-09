-- [yue]: Script/Example/Body.yue
local Vec2 = Dora.Vec2 -- 1
local BodyDef = Dora.BodyDef -- 1
local PhysicsWorld = Dora.PhysicsWorld -- 1
local Body = Dora.Body -- 1
local threadLoop = Dora.threadLoop -- 1
local App = Dora.App -- 1
local ImGui = Dora.ImGui -- 1
local gravity <const> = Vec2(0, -10) -- 3
local groupZero <const> = 0 -- 5
local groupOne <const> = 1 -- 6
local groupTwo <const> = 2 -- 7
local terrainDef -- 9
do -- 9
	local _with_0 = BodyDef() -- 9
	_with_0.type = "Static" -- 10
	_with_0:attachPolygon(800, 10, 1, 0.8, 0.2) -- 11
	terrainDef = _with_0 -- 9
end -- 9
local polygonDef -- 13
do -- 13
	local _with_0 = BodyDef() -- 13
	_with_0.type = "Dynamic" -- 14
	_with_0.linearAcceleration = gravity -- 15
	_with_0:attachPolygon({ -- 17
		Vec2(60, 0), -- 17
		Vec2(30, -30), -- 18
		Vec2(-30, -30), -- 19
		Vec2(-60, 0), -- 20
		Vec2(-30, 30), -- 21
		Vec2(30, 30) -- 22
	}, 1, 0.4, 0.4) -- 16
	polygonDef = _with_0 -- 13
end -- 13
local diskDef -- 25
do -- 25
	local _with_0 = BodyDef() -- 25
	_with_0.type = "Dynamic" -- 26
	_with_0.linearAcceleration = gravity -- 27
	_with_0:attachDisk(60, 1, 0.4, 0.4) -- 28
	diskDef = _with_0 -- 25
end -- 25
do -- 30
	local world = PhysicsWorld() -- 30
	world.y = -200 -- 31
	world.showDebug = true -- 32
	world:setShouldContact(groupZero, groupOne, false) -- 34
	world:setShouldContact(groupZero, groupTwo, true) -- 35
	world:setShouldContact(groupOne, groupTwo, true) -- 36
	world:addChild((function() -- 38
		local _with_0 = Body(terrainDef, world, Vec2.zero) -- 38
		_with_0.group = groupTwo -- 39
		return _with_0 -- 38
	end)()) -- 38
	world:addChild((function() -- 41
		local _with_0 = Body(polygonDef, world, Vec2(0, 500), 15) -- 41
		_with_0.group = groupOne -- 42
		return _with_0 -- 41
	end)()) -- 41
	world:addChild((function() -- 44
		local _with_0 = Body(diskDef, world, Vec2(50, 800)) -- 44
		_with_0.group = groupZero -- 45
		_with_0.angularRate = 90 -- 46
		return _with_0 -- 44
	end)()) -- 44
end -- 30
local windowFlags = { -- 51
	"NoDecoration", -- 51
	"AlwaysAutoResize", -- 51
	"NoSavedSettings", -- 51
	"NoFocusOnAppearing", -- 51
	"NoNav", -- 51
	"NoMove" -- 51
} -- 51
return threadLoop(function() -- 59
	local width -- 60
	width = App.visualSize.width -- 60
	ImGui.SetNextWindowBgAlpha(0.35) -- 61
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 62
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 63
	return ImGui.Begin("Body", windowFlags, function() -- 64
		ImGui.Text("Body (Yuescript)") -- 65
		ImGui.Separator() -- 66
		return ImGui.TextWrapped("Basic usage to create physics bodies!") -- 67
	end) -- 67
end) -- 67
