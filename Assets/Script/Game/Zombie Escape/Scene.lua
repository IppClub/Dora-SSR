-- [yue]: Script/Game/Zombie Escape/Scene.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local PlatformWorld = _module_0.PlatformWorld -- 1
local Vec2 = dora.Vec2 -- 1
local View = dora.View -- 1
local BodyDef = dora.BodyDef -- 1
local Color = dora.Color -- 1
local App = dora.App -- 1
local Body = dora.Body -- 1
local Entity = dora.Entity -- 1
local Size = dora.Size -- 1
local Rectangle = require("UI.View.Shape.Rectangle") -- 2
local Store = Data.store -- 4
local PlayerLayer, PlayerGroup, ZombieLayer, TerrainLayer = Store.PlayerLayer, Store.PlayerGroup, Store.ZombieLayer, Store.TerrainLayer -- 5
local DesignWidth <const> = 1280 -- 12
local world -- 14
do -- 14
	local _with_0 = PlatformWorld() -- 14
	_with_0:getLayer(PlayerLayer).renderGroup = true -- 15
	_with_0:getLayer(ZombieLayer).renderGroup = true -- 16
	_with_0:getLayer(TerrainLayer).renderGroup = true -- 17
	_with_0.camera.followRatio = Vec2(0.01, 0.01) -- 18
	_with_0.camera.zoom = View.size.width / DesignWidth -- 19
	_with_0:gslot("AppSizeChanged", function() -- 20
		_with_0.camera.zoom = View.size.width / DesignWidth -- 21
	end) -- 20
	world = _with_0 -- 14
end -- 14
Store.world = world -- 22
local terrainDef -- 24
do -- 24
	local _with_0 = BodyDef() -- 24
	_with_0.type = "Static" -- 25
	_with_0:attachPolygon(Vec2(0, -500), 2500, 10, 0, 1, 1, 0) -- 26
	_with_0:attachPolygon(Vec2(0, 500), 2500, 10, 0, 1, 1, 0) -- 27
	_with_0:attachPolygon(Vec2(1250, 0), 10, 1000, 0, 1, 1, 0) -- 28
	_with_0:attachPolygon(Vec2(-1250, 0), 10, 1000, 0, 1, 1, 0) -- 29
	terrainDef = _with_0 -- 24
end -- 24
local fillColor = Color(App.themeColor:toColor3(), 0x66):toARGB() -- 31
local borderColor = App.themeColor:toARGB() -- 32
do -- 34
	local _with_0 = Body(terrainDef, world, Vec2.zero) -- 34
	_with_0.order = TerrainLayer -- 35
	_with_0.group = Data.groupTerrain -- 36
	_with_0:addChild(Rectangle({ -- 38
		y = -500, -- 38
		width = 2500, -- 39
		height = 10, -- 40
		fillColor = fillColor, -- 41
		borderColor = borderColor, -- 42
		fillOrder = 1, -- 43
		lineOrder = 2 -- 44
	})) -- 37
	_with_0:addChild(Rectangle({ -- 47
		x = 1250, -- 47
		y = 0, -- 48
		width = 10, -- 49
		height = 1000, -- 50
		fillColor = fillColor, -- 51
		borderColor = borderColor, -- 52
		fillOrder = 1, -- 53
		lineOrder = 2 -- 54
	})) -- 46
	_with_0:addChild(Rectangle({ -- 57
		x = -1250, -- 57
		y = 0, -- 58
		width = 10, -- 59
		height = 1000, -- 60
		fillColor = fillColor, -- 61
		borderColor = borderColor, -- 62
		fillOrder = 1, -- 63
		lineOrder = 2 -- 64
	})) -- 56
	_with_0:addTo(world) -- 66
end -- 34
Entity({ -- 69
	obstacleDef = "Body_ObstacleS", -- 69
	size = Size(100, 60), -- 70
	position = Vec2(100, -464), -- 71
	color = borderColor -- 72
}) -- 68
Entity({ -- 75
	obstacleDef = "Body_ObstacleM", -- 75
	size = Size(260, 60), -- 76
	position = Vec2(-400, -464), -- 77
	color = borderColor -- 78
}) -- 74
Entity({ -- 81
	obstacleDef = "Body_ObstacleS", -- 81
	size = Size(100, 60), -- 82
	position = Vec2(-400, -404), -- 83
	color = borderColor -- 84
}) -- 80
Entity({ -- 87
	obstacleDef = "Body_ObstacleC", -- 87
	size = 40, -- 88
	position = Vec2(400, -464), -- 89
	color = 0xff6666 -- 90
}) -- 86
Entity({ -- 93
	unitDef = "Unit_KidM", -- 93
	order = PlayerLayer, -- 94
	position = Vec2(-50, -430), -- 95
	group = PlayerGroup, -- 96
	faceRight = false, -- 97
	player = true -- 98
}) -- 92
return Entity({ -- 101
	unitDef = "Unit_KidW", -- 101
	order = PlayerLayer, -- 102
	position = Vec2(0, -430), -- 103
	group = PlayerGroup, -- 104
	faceRight = true, -- 105
	player = true -- 106
}) -- 106
