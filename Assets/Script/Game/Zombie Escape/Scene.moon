_ENV = Dorothy builtin.Platformer
import "UI.View.Shape.Rectangle"
{store:Store} = Data

{
	:PlayerLayer,
	:PlayerGroup,
	:ZombieLayer,
	:TerrainLayer
} = Store

world = with PlatformWorld!
	\getLayer(PlayerLayer).renderGroup = true
	\getLayer(ZombieLayer).renderGroup = true
	\getLayer(TerrainLayer).renderGroup = true
	.camera.followRatio = Vec2 0.01,0.01
Store["world"] = world

terrainDef = with BodyDef!
	.type = BodyType.Static
	\attachPolygon Vec2(0,-500),2500,10,0,1,1,0
	\attachPolygon Vec2(0,500),2500,10,0,1,1,0
	\attachPolygon Vec2(1250,0),10,1000,0,1,1,0
	\attachPolygon Vec2(-1250,0),10,1000,0,1,1,0

with Body terrainDef,world,Vec2.zero
	.order = TerrainLayer
	.group = Data.groupTerrain
	\addChild Rectangle {y:-500,width:2500,height:10,
		fillColor:0x6600ffff,borderColor:0xff00ffff,
		fillOrder:1,lineOrder:2}
	\addChild Rectangle {x:1250,y:0,width:10,height:1000,
		fillColor:0x6600ffff,borderColor:0xff00ffff,
		fillOrder:1,lineOrder:2}
	\addChild Rectangle {x:-1250,y:0,width:10,height:1000,
		fillColor:0x6600ffff,borderColor:0xff00ffff,
		fillOrder:1,lineOrder:2}
	\addTo world

with Director.entry
	\addChild world

with Entity!
	.obstacleDef = "Body_ObstacleS"
	.size = Size 100,60
	.position = Vec2 100,-464
	.color = 0x00ffff

with Entity!
	.obstacleDef = "Body_ObstacleM"
	.size = Size 260,60
	.position = Vec2 -400,-464
	.color = 0x00ffff

with Entity!
	.obstacleDef = "Body_ObstacleS"
	.size = Size 100,60
	.position = Vec2 -400,-404
	.color = 0x00ffff

with Entity!
	.obstacleDef = "Body_ObstacleC"
	.size = 40
	.position = Vec2 400,-464
	.color = 0xff6666

with Entity!
	.unitDef = "Unit_KidM"
	.order = PlayerLayer
	.position = Vec2 -50,-430
	.group = PlayerGroup
	.isPlayer = true
	.faceRight = false
	.player = true

with Entity!
	.unitDef = "Unit_KidW"
	.order = PlayerLayer
	.position = Vec2 0,-430
	.group = PlayerGroup
	.isPlayer = true
	.faceRight = true
	.player = true
