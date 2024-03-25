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
local Rectangle = require("UI.View.Shape.Rectangle") -- 10
local Store = Data.store -- 12
local PlayerLayer, PlayerGroup, ZombieLayer, TerrainLayer = Store.PlayerLayer, Store.PlayerGroup, Store.ZombieLayer, Store.TerrainLayer -- 13
local DesignWidth <const> = 1280 -- 20
local world -- 22
do -- 22
	local _with_0 = PlatformWorld() -- 22
	_with_0:getLayer(PlayerLayer).renderGroup = true -- 23
	_with_0:getLayer(ZombieLayer).renderGroup = true -- 24
	_with_0:getLayer(TerrainLayer).renderGroup = true -- 25
	_with_0.camera.followRatio = Vec2(0.01, 0.01) -- 26
	_with_0.camera.zoom = View.size.width / DesignWidth -- 27
	_with_0:gslot("AppSizeChanged", function() -- 28
		_with_0.camera.zoom = View.size.width / DesignWidth -- 29
	end) -- 28
	world = _with_0 -- 22
end -- 22
Store.world = world -- 30
local terrainDef -- 32
do -- 32
	local _with_0 = BodyDef() -- 32
	_with_0.type = "Static" -- 33
	_with_0:attachPolygon(Vec2(0, -500), 2500, 10, 0, 1, 1, 0) -- 34
	_with_0:attachPolygon(Vec2(0, 500), 2500, 10, 0, 1, 1, 0) -- 35
	_with_0:attachPolygon(Vec2(1250, 0), 10, 1000, 0, 1, 1, 0) -- 36
	_with_0:attachPolygon(Vec2(-1250, 0), 10, 1000, 0, 1, 1, 0) -- 37
	terrainDef = _with_0 -- 32
end -- 32
local fillColor = Color(App.themeColor:toColor3(), 0x66):toARGB() -- 39
local borderColor = App.themeColor:toARGB() -- 40
do -- 42
	local _with_0 = Body(terrainDef, world, Vec2.zero) -- 42
	_with_0.order = TerrainLayer -- 43
	_with_0.group = Data.groupTerrain -- 44
	_with_0:addChild(Rectangle({ -- 46
		y = -500, -- 46
		width = 2500, -- 47
		height = 10, -- 48
		fillColor = fillColor, -- 49
		borderColor = borderColor, -- 50
		fillOrder = 1, -- 51
		lineOrder = 2 -- 52
	})) -- 45
	_with_0:addChild(Rectangle({ -- 55
		x = 1250, -- 55
		y = 0, -- 56
		width = 10, -- 57
		height = 1000, -- 58
		fillColor = fillColor, -- 59
		borderColor = borderColor, -- 60
		fillOrder = 1, -- 61
		lineOrder = 2 -- 62
	})) -- 54
	_with_0:addChild(Rectangle({ -- 65
		x = -1250, -- 65
		y = 0, -- 66
		width = 10, -- 67
		height = 1000, -- 68
		fillColor = fillColor, -- 69
		borderColor = borderColor, -- 70
		fillOrder = 1, -- 71
		lineOrder = 2 -- 72
	})) -- 64
	_with_0:addTo(world) -- 74
end -- 42
Entity({ -- 77
	obstacleDef = "Body_ObstacleS", -- 77
	size = Size(100, 60), -- 78
	position = Vec2(100, -464), -- 79
	color = borderColor -- 80
}) -- 76
Entity({ -- 83
	obstacleDef = "Body_ObstacleM", -- 83
	size = Size(260, 60), -- 84
	position = Vec2(-400, -464), -- 85
	color = borderColor -- 86
}) -- 82
Entity({ -- 89
	obstacleDef = "Body_ObstacleS", -- 89
	size = Size(100, 60), -- 90
	position = Vec2(-400, -404), -- 91
	color = borderColor -- 92
}) -- 88
Entity({ -- 95
	obstacleDef = "Body_ObstacleC", -- 95
	size = 40, -- 96
	position = Vec2(400, -464), -- 97
	color = 0xff6666 -- 98
}) -- 94
Entity({ -- 101
	unitDef = "Unit_KidM", -- 101
	order = PlayerLayer, -- 102
	position = Vec2(-50, -430), -- 103
	group = PlayerGroup, -- 104
	faceRight = false, -- 105
	player = true -- 106
}) -- 100
return Entity({ -- 109
	unitDef = "Unit_KidW", -- 109
	order = PlayerLayer, -- 110
	position = Vec2(0, -430), -- 111
	group = PlayerGroup, -- 112
	faceRight = true, -- 113
	player = true -- 114
}) -- 114
