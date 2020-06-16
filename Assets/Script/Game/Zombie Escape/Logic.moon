_ENV = Dorothy builtin.Platformer
import "UI.View.Shape.Rectangle"
import "UI.View.Shape.Circle"
import "UI.View.Shape.Star"
{store:Store} = Data

with Observer "Add", {"obstacleDef","size","position","color"}
	\every =>
		{:obstacleDef,:size,:position,:color} = @
		{:world,:TerrainLayer} = Store
		color = Color3 color
		with Body Store[obstacleDef],world,position
			.tag = "Obstacle"
			.order = TerrainLayer
			.group = Data.groupTerrain
			if "number" == type size
				\addChild Circle {
					radius: size
					fillColor: Color(color,0x66)\toARGB!
					borderColor: Color(color,0xff)\toARGB!
					fillOrder: 1
					lineOrder: 2
				}
				\addChild Star {
					size: 20
					borderColor: 0xffffffff
					fillColor: 0x66ffffff
					fillOrder: 1
					lineOrder: 2
				}
			else
				\addChild Rectangle {
					width: size.width
					height: size.height
					fillColor: Color(color,0x66)\toARGB!
					borderColor: Color(color,0xff)\toARGB!
					fillOrder: 1
					lineOrder: 2
				}
			\addTo world
		@destroy!

with Observer "Add", {"unitDef","position","order","group","isPlayer","faceRight"}
	\every =>
		{:unitDef,:position,:order,:group,:isPlayer,:faceRight} = @
		{:world} = Store
		def = Store[unitDef]
		unit = with Unit def,world,@,position
			.group = group
			.order = order
			.faceRight = faceRight
			\addTo world
			\eachAction => @recovery = 0
			.playable\eachNode (sp)-> sp.filter = TextureFilter.Point
		world.camera.followTarget = unit if isPlayer and unit.decisionTree == "AI_KidSearch"

with Observer "Change", {"hp","unit"}
	\every =>
		{:hp,:unit} = @
		{hp:lastHp} = @oldValues
		if hp < lastHp
			if hp > 0
				unit\start "hit"
			else
				unit\start "hit"
				unit\start "fall"
				unit.group = Data.groupHide
				unit\schedule once ->
					sleep 5
					unit\runAction Opacity 0.5,1,0,Ease.OutQuad
					sleep 0.5
					unit\removeFromParent!

Store.zombieKilled = 0
with Observer "Change", {"hp","zombie"}
	\every => Store.zombieKilled += 1 if @hp <= 0

zombieGroup = Group {"zombie"}
spawnZombies = ->
	{
		:ZombieLayer,
		:ZombieGroup,
		:MaxZombies,
		:ZombieWaveDelay
		:world
	} = Store
	if zombieGroup.count < MaxZombies
		for i = zombieGroup.count,MaxZombies
			available = false
			pos = Vec2.zero
			while not available
				pos = Vec2 App.rand%2400-1200,-430
				available = not world\query Rect(pos,Size(5,5)),=> @group == Data.groupTerrain
			with Entity!
				.unitDef = "Unit_Zombie#{math.floor App.rand%2 + 1}"
				.order = ZombieLayer
				.position = pos
				.group = ZombieGroup
				.isPlayer = false
				.faceRight = App.rand%2 == 0
				.zombie = true
			sleep 0.1*App.rand%5
	sleep ZombieWaveDelay

Director.entry\addChild with Node!
	\schedule loop spawnZombies
