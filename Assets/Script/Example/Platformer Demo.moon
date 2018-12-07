Dorothy builtin.Platformer
AlignNode = require "UI.Control.Basic.AlignNode"
Rectangle = require "UI.View.Shape.Rectangle"
Circle = require "UI.View.Shape.Circle"
Star = require "UI.View.Shape.Star"
CircleButton = require "UI.Control.Basic.CircleButton"

groundEntranceEnd = (name,model)->
	return unless name == "groundEntrance"
	model.parent\stop!

UnitAction\add "groundEntrance",
	priority: 6
	reaction: 999
	recovery: 0
	available: -> true
	create: =>
		@entity.lastGroup = @group
		@group = 0
		with @model
			.speed = 1
			.loop = false
			\slot "AnimationEnd",groundEntranceEnd
			\play "groundEntrance"
		-> false,
	stop: =>
		@model\slot("AnimationEnd")\remove groundEntranceEnd
		@group = @entity.lastGroup
		@entity.lastGroup = nil
		@entity.entered = true

UnitAction\add "fallOff",
	priority: 1
	reaction: 1
	recovery: 0
	available: => not @onSurface
	create: =>
		if @velocityY <= 0
			@entity.fallDown = true
			with @model
				.speed = 1
				.loop = false
				\play "fallOff"
		else @entity.fallDown = false
		(action)=>
			return true if @onSurface
			if not @entity.fallDown and
				@model.currentAnimation ~= "fallOff" and
				@velocityY <= 0
				@entity.fallDown = true
				with @model
					.speed = 1
					.loop = false
					\play "fallOff"
			false,
	stop: =>
		@model\stop!

UnitAction\add "backJump",
	priority: 2
	reaction: 10
	recovery: 0
	available: => @onSurface
	create: =>
		@faceRight = not @faceRight
		with @model
			.speed = 1
			.loop = true
			\play "walk"
		@velocityX = (@faceRight and 1 or -1)*@move*@moveSpeed
		loop =>
			cycle 0.25,->
				@velocityX = (@faceRight and 1 or -1)*@move*@moveSpeed
			@faceRight = not @faceRight
			cycle 0.1,->
				@velocityX = (@faceRight and 1 or -1)*@move*@moveSpeed	
			@velocityY = @jump
			@velocityX = (@faceRight and 1 or -1)*@move*@moveSpeed
			with @model
				.speed = 1
				.loop = false
				\play "jump"
			sleep 0.2
			true
	stop: =>
		@model\stop!

rangeAttack = Sel {
	Seq {
		Con =>
			sensor = @getSensorByTag UnitDef.AttackSensorTag
			sensor.sensedBodies\each (body)->
				body.group == Data.groupTerrain and
				body.tag == "Obstacle" and
				(@x > body.x) ~= @faceRight
		Act "jump"
		False!
	}
	Act "rangeAttack"
}

walk = Sel {
	Seq {
		Con =>
			{:world} = Data.cache
			sensor = @getSensorByTag UnitDef.AttackSensorTag
			sensor.sensedBodies\each (body)->
				if body.group == Data.groupTerrain and
					body.tag == "Obstacle" and
					(@x > body.x) ~= @faceRight
					start = @position
					stop = Vec2 start.x+(@faceRight and 140 or -140),start.y
					if world\raycast start,stop,true,(b,p)->
							obstacleDistance = math.abs p.x-start.x
							if b == body and obstacleDistance <= 140
								@entity.obstacleDistance = obstacleDistance
								true
							else
								false
						return true
					else
						return false
		Sel {
			Seq {
				Con => @entity.obstacleDistance <= 80
				Act "backJump"
			}
			Seq {
				Con => math.abs(@velocityX) > 0
				Act "jump"
			}
		}
	}
	Act "walk"
}

attackDecision = Seq {
	Con => if AI\getNearestUnit(Relation.Enemy) then true else false
	Sel {
		Seq {
			Con =>
				enemy = AI\getNearestUnit Relation.Enemy
				(@x > enemy.x) == @faceRight
			Act "turn"
		}
		Seq {
			Con => 
				enemy = AI\getNearestUnit Relation.Enemy
				attackUnits = AI\getUnitsInAttackRange!
				attackUnits and attackUnits\contains(enemy) or false
			Sel {
				rangeAttack
				Act "meleeAttack"
			}
		}
		Seq {
			Con => App.rand % 5 == 0
			Act "jump"
		}
		walk
	}
}

Data.cache["AI_Zombie"] = Sel {
	Seq {
		Con => @entity.hp <= 0
		True!
	}
	Seq {
		Con => not @entity.entered
		Act "groundEntrance"
	}
	attackDecision
	Seq {
		Con => not @isDoing "idle"
		Act "cancel"
		Act "idle"
	}
}

playerGroup = Group {"player"}

Data.cache["AI_KidFollow"] = Sel {
	Seq {
		Con => @entity.hp <= 0
		True!
	}
	attackDecision
	Seq {
		Con => not @onSurface
		Act "fallOff"
	}
	Seq {
		Con =>
			target = nil
			playerGroup\each (e)-> target = e.unit if e.unit ~= @
			@entity.followTarget = target
			target ~= nil and math.abs(@x-target.x) > 50
		Sel {
			Seq {
				Con => (@x > @entity.followTarget.x) == @faceRight
				Act "turn"
			}
			True!
		}
		walk
	}
	Seq {
		Con => not @isDoing "idle"
		Act "cancel"
		Act "idle"
	}
}

Data.cache["AI_KidSearch"] = Sel {
	Seq {
		Con => @entity.hp <= 0
		True!
	}
	attackDecision
	Seq {
		Con => not @onSurface
		Act "fallOff"
	}
	Seq {
		Con => math.abs(@x) > 1150 and (@x > 0 == @faceRight)
		Act "turn"
	}
	walk
}

Data.cache["AI_PlayerControl"] = Sel {
	Seq {
		Con => @entity.hp <= 0
		True!
	}
	Seq {
		Con => @entity.keyShoot
		Sel {
			Act "meleeAttack"
			Act "rangeAttack"
		}
	}
	Seq {
		Seq {
			Con => not (@entity.keyLeft and @entity.keyRight) and ((@entity.keyLeft and @faceRight) or (@entity.keyRight and not @faceRight))
			Act "turn"
		}
		False!
	}
	Sel {
		Seq {
			Con => not @onSurface
			Act "fallOff"
		}
		Seq {
			Con => @entity.keyUp
			Act "jump"
		}
	}
	Seq {
		Con => @entity.keyLeft or @entity.keyRight
		Act "walk"
	}
	Seq {
		Con => not @isDoing "idle"
		Act "cancel"
		Act "idle"
	}
}

Data.cache["Bullet_Zombie"] = with BulletDef!
	.tag = ""
	.endEffect = ""
	.lifeTime = 5
	.damageRadius = 5
	.highSpeedFix = false
	.gravityScale = 1
	.face = Face "Particle/fire.par"
	\setAsCircle 10
	\setVelocity 60,600

Data.cache["Bullet_KidM"] = with BulletDef!
	.tag = ""
	.endEffect = ""
	.lifeTime = 1
	.damageRadius = 3
	.highSpeedFix = false
	.gravityScale = 0
	.face = Face -> Rectangle width:6,height:6,borderColor:0xffff0088,fillColor:0x66ff0088,fillOrder:1,lineOrder:2
	\setAsCircle 10
	\setVelocity 0,600

Data.cache["Bullet_KidW"] = with BulletDef!
	.tag = ""
	.endEffect = ""
	.lifeTime = 5
	.damageRadius = 3
	.highSpeedFix = false
	.gravityScale = 1
	.face = Face -> Star size:15,borderColor:0xffff0088,fillColor:0x66ff0088,fillOrder:1,lineOrder:2
	\setAsCircle 10
	\setVelocity 60,600

Data.cache["Unit_Zombie1"] = with UnitDef!
	.static = false
	.scale = 5
	.density = 1.0
	.friction = 1.0
	.restitution = 0.0
	.model = "Model/Zombie1.model"
	.size = Size 40,110
	.tag = "Zombie1"
	.sensity = 0.2
	.move = 120
	.jump = 600
	.detectDistance = 600
	.maxHp = 5
	.attackBase = 1
	.attackDelay = 0.4
	.attackEffectDelay = 0.1
	.attackRange = Size 80,50
	.attackPower = Vec2 200,200
	.attackType = AttackType.Melee
	.attackTarget = AttackTarget.Single
	.targetAllow = (with TargetAllow!
		.terrainAllowed = true
		\allow Relation.Enemy,true)
	.damageType = 0
	.defenceType = 0
	.bulletType = "Bullet_Zombie"
	.attackEffect = ""
	.hitEffect = ""
	.name = "Zombie1"
	.desc = ""
	.sndAttack = ""
	.sndFallen = ""
	.decisionTree = "AI_Zombie"
	.usePreciseHit = false
	.actions = {
		"walk",
		"turn",
		"meleeAttack",
		"idle",
		"cancel",
		"jump",
		"backJump",
		"hit",
		"fall",
		"groundEntrance",
	}

Data.cache["Unit_Zombie2"] = with UnitDef!
	.static = false
	.scale = 5
	.density = 1.0
	.friction = 1.0
	.restitution = 0.0
	.model = "Model/Zombie2.model"
	.size = Size 40,110
	.tag = "Zombie2"
	.sensity = 0.2
	.move = 60
	.jump = 400
	.detectDistance = 600
	.maxHp = 5
	.attackBase = 1
	.attackDelay = 0.4
	.attackEffectDelay = 0.1
	.attackRange = Size 150,80
	.attackPower = Vec2 200,200
	.attackType = AttackType.Melee
	.attackTarget = AttackTarget.Multi
	.targetAllow = (with TargetAllow!
		.terrainAllowed = true
		\allow Relation.Enemy,true)
	.damageType = 0
	.defenceType = 0
	.bulletType = ""
	.attackEffect = ""
	.hitEffect = ""
	.name = "Zombie2"
	.desc = ""
	.sndAttack = ""
	.sndFallen = ""
	.decisionTree = "AI_Zombie"
	.usePreciseHit = false
	.actions = {
		"walk",
		"turn",
		"meleeAttack",
		"idle",
		"cancel",
		"jump",
		"backJump",
		"hit",
		"fall",
		"groundEntrance",
	}

Data.cache["Unit_KidW"] = with UnitDef!
	.static = false
	.scale = 5
	.density = 1.0
	.friction = 1.0
	.restitution = 0.0
	.model = "Model/KidW.model"
	.size = Size 30,110
	.tag = "KidW"
	.sensity = 0.1
	.move = 250
	.jump = 500
	.detectDistance = 350
	.maxHp = 5
	.attackBase = 2.5
	.attackDelay = 0.1
	.attackEffectDelay = 0.1
	.attackRange = Size 350,50
	.attackPower = Vec2 100,100
	.attackType = AttackType.Range
	.attackTarget = AttackTarget.Single
	.targetAllow = (with TargetAllow!
		.terrainAllowed = true
		\allow Relation.Enemy,true)
	.damageType = 0
	.defenceType = 0
	.bulletType = "Bullet_KidW"
	.attackEffect = ""
	.hitEffect = ""
	.name = "KidW"
	.desc = ""
	.sndAttack = ""
	.sndFallen = ""
	.decisionTree = "AI_KidSearch"
	.usePreciseHit = false
	.actions = {
		"walk",
		"turn",
		"rangeAttack",
		"idle",
		"cancel",
		"jump",
		"backJump",
		"hit",
		"fall",
		"fallOff",
	}

Data.cache["Unit_KidM"] = with UnitDef!
	.static = false
	.scale = 5
	.density = 1.0
	.friction = 1.0
	.restitution = 0.0
	.model = "Model/KidM.model"
	.size = Size 30,110
	.tag = "KidM"
	.sensity = 0.1
	.move = 250
	.jump = 500
	.detectDistance = 500
	.maxHp = 5
	.attackBase = 0.5
	.attackDelay = 0.1
	.attackEffectDelay = 0.1
	.attackRange = Size 400,50
	.attackPower = Vec2 100,0
	.attackType = AttackType.Range
	.attackTarget = AttackTarget.Single
	.targetAllow = (with TargetAllow!
		.terrainAllowed = true
		\allow Relation.Enemy,true)
	.damageType = 0
	.defenceType = 0
	.bulletType = "Bullet_KidM"
	.attackEffect = ""
	.hitEffect = ""
	.name = "KidM"
	.desc = ""
	.sndAttack = ""
	.sndFallen = ""
	.decisionTree = "AI_KidFollow"
	.usePreciseHit = false
	.actions = {
		"walk",
		"turn",
		"rangeAttack",
		"idle",
		"cancel",
		"jump",
		"backJump",
		"hit",
		"fall",
		"fallOff"
	}

Data.cache["obstacleS"] = with BodyDef!
	.type = BodyType.Static
	\attachPolygon 100,60

Data.cache["obstacleM"] = with BodyDef!
	.type = BodyType.Static
	\attachPolygon 260,60

Data.cache["obstacleC"] = with BodyDef!
	.type = BodyType.Dynamic
	\attachCircle 40,1,1,0.4

PlayerLayer = 2
ZombieLayer = 1
TerrainLayer = 0

PlayerGroup = 1
ZombieGroup = 2

Data\setRelation PlayerGroup,ZombieGroup,Relation.Enemy

with Observer "Add", {"obstacleDef","size","position","color"}
	\every =>
		{:obstacleDef,:size,:position,:color} = @
		{:world} = Data.cache
		color = Color3 color
		with Body Data.cache[obstacleDef],world,position
			.tag = "Obstacle"
			.order = TerrainLayer
			.group = Data.groupTerrain
			if "number" == type size
				\addChild Circle radius:size,fillColor:Color(color,0x66)\toARGB!,borderColor:Color(color,0xff)\toARGB!,fillOrder:1,lineOrder:2
				\addChild Star size:20,borderColor:0xffffffff,fillColor:0x66ffffff,fillOrder:1,lineOrder:2
			else
				\addChild Rectangle width:size.width,height:size.height,fillColor:Color(color,0x66)\toARGB!,borderColor:Color(color,0xff)\toARGB!,fillOrder:1,lineOrder:2
			\addTo world
		@destroy!

with Observer "Add", {"unitDef","position","order","group","isPlayer","faceRight"}
	\every =>
		{:unitDef,:position,:order,:group,:isPlayer,:faceRight} = @
		{:world} = Data.cache
		unit = with Unit unitDef,"world",@,position
			.group = group
			.order = order
			.faceRight = faceRight
			\addTo world
			\eachAction (action)-> action.recovery = 0
			.model\eachNode (sp)-> sp.filter = TextureFilter.Point
		world.camera.followTarget = unit if isPlayer and unit.decisionTree == "AI_KidSearch"
		@faceRight = nil

with Observer "Change", {"hp","unit"}
	\every =>
		{:hp,:unit} = @
		{hp:lastHp} = @valueCache
		if hp < lastHp
			if hp > 0
				unit\start "hit"
			else
				unit\start "hit"
				unit\start "fall"
				unit.group = Data.groupHide
				unit\schedule once ->
					sleep 5
					unit\runAction Sequence(
						Opacity 0.5,1,0,Ease.OutQuad
						Call -> unit\removeFromParent!
					)

zombieGroup = Group {"zombie"}
spawnZombies = loop ->
	{:world} = Data.cache
	if zombieGroup.count < 50
		for i = zombieGroup.count,50
			available = false
			pos = Vec2.zero
			while not available
				pos = Vec2 App.rand%2400-1200,-430
				available = not world\query Rect(pos,Size(5,5)),=> @group == Data.groupTerrain
			with Entity!
				.unitDef = "Unit_Zombie#{App.rand%2 + 1}"
				.order = ZombieLayer
				.position = pos
				.group = ZombieGroup
				.isPlayer = false
				.faceRight = App.rand%2 == 0
				.zombie = true
			sleep 0.1*App.rand%5
	sleep 20

zombieKilled = 0
with Observer "Change", {"hp","zombie"}
	\every => zombieKilled += 1 if @hp <= 0

world = with PlatformWorld!
	\getLayer(PlayerLayer).renderGroup = true
	\getLayer(ZombieLayer).renderGroup = true
	\getLayer(TerrainLayer).renderGroup = true
	.camera.followRatio = Vec2 0.01,0.01
	.gravity = Vec2 0,-12

Data.cache["world"] = world

terrainDef = with BodyDef!
	.type = BodyType.Static
	\attachPolygon Vec2(0,-500),2500,10
	\attachPolygon Vec2(0,500),2500,10
	\attachPolygon Vec2(1250,0),10,1000
	\attachPolygon Vec2(-1250,0),10,1000

with Body terrainDef,world,Vec2.zero
	.order = TerrainLayer
	.group = Data.groupTerrain
	\addChild Rectangle y:-500,width:2500,height:10,fillColor:0x6600ffff,borderColor:0xff00ffff,fillOrder:1,lineOrder:2
	\addChild Rectangle x:1250,y:0,width:10,height:1000,fillColor:0x6600ffff,borderColor:0xff00ffff,fillOrder:1,lineOrder:2
	\addChild Rectangle x:-1250,y:0,width:10,height:1000,fillColor:0x6600ffff,borderColor:0xff00ffff,fillOrder:1,lineOrder:2
	\addTo world

with Entity!
	.obstacleDef = "obstacleS"
	.size = Size 100,60
	.position = Vec2 100,-464
	.color = 0x00ffff

with Entity!
	.obstacleDef = "obstacleM"
	.size = Size 260,60
	.position = Vec2 -400,-464
	.color = 0x00ffff

with Entity!
	.obstacleDef = "obstacleS"
	.size = Size 100,60
	.position = Vec2 -400,-404
	.color = 0x00ffff

with Entity!
	.obstacleDef = "obstacleC"
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

with Director.entry
	.visible = false
	\schedule once -> Director.entry.visible = true
	\addChild world

keyboardEnabled = false
controlPlayer = "KidM"
updatePlayerControl = (key,flag)->
	player = nil
	playerGroup\each => player = @ if @unit.tag == controlPlayer
	player[key] = flag if player
uiScale = App.size.width/App.designSize.width

with AlignNode true
	.visible = false
	\addChild with AlignNode!
		.hAlign = "Left"
		.vAlign = "Bottom"
		\addChild with Menu!
			\addChild with CircleButton {
					text:"Left"
					x:20*uiScale
					y:60*uiScale
					radius:30*uiScale
					fontSize:18*uiScale
				}
				.anchor = Vec2.zero
				\slot "TapBegan",-> updatePlayerControl "keyLeft",true
				\slot "TapEnded",-> updatePlayerControl "keyLeft",false
			\addChild with CircleButton {
					text:"Right"
					x:90*uiScale
					y:60*uiScale
					radius:30*uiScale
					fontSize:18*uiScale
				}
				.anchor = Vec2.zero
				\slot "TapBegan",-> updatePlayerControl "keyRight",true
				\slot "TapEnded",-> updatePlayerControl "keyRight",false
	\addChild with AlignNode!
		.hAlign = "Right"
		.vAlign = "Bottom"
		\addChild with Menu!
			\addChild with CircleButton {
					text:"Jump"
					x:-80*uiScale
					y:60*uiScale
					radius:30*uiScale
					fontSize:18*uiScale
				}
				.anchor = Vec2.zero
				\slot "TapBegan",-> updatePlayerControl "keyUp",true
				\slot "TapEnded",-> updatePlayerControl "keyUp",false
			\addChild with CircleButton {
					text:"Shoot"
					x:-150*uiScale
					y:60*uiScale
					radius:30*uiScale
					fontSize:18*uiScale
				}
				.anchor = Vec2.zero
				\slot "TapBegan",-> updatePlayerControl "keyShoot",true
				\slot "TapEnded",-> updatePlayerControl "keyShoot",false
	\addTo with Director.ui
		.renderGroup = true

keyboardControl = loop ->
	return unless keyboardEnabled
	updatePlayerControl "keyLeft", Keyboard\isKeyPressed "A"
	updatePlayerControl "keyRight", Keyboard\isKeyPressed "D"
	updatePlayerControl "keyUp", Keyboard\isKeyPressed "K"
	updatePlayerControl "keyShoot", Keyboard\isKeyPressed "J"

threadLoop ->
	spawnZombies!
	keyboardControl!
	world.parent == nil

Dorothy builtin.ImGui,builtin.Platformer

userControl = false
playerChoice = 1
controlChoice = switch App.platform
	when "iOS","Android" then 0
	else 1
world\schedule ->
	{:width,:height} = App.designSize
	SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
	SetNextWindowSize Vec2(240,userControl and 450 or 220)
	if Begin "Platformer Game Demo", "NoResize|NoSavedSettings"
		TextWrapped "Zombie Killed: #{zombieKilled}"
		SameLine!
		if Button "Army"
			for i = 0,10
				available = false
				pos = Vec2.zero
				while not available
					pos = Vec2 App.rand%2400-1200,-430
					available = not world\query Rect(pos,Size(5,5)),=> @group == Data.groupTerrain
				with Entity!
					.unitDef = "Unit_Zombie#{App.rand%2 + 1}"
					.order = ZombieLayer
					.position = pos
					.group = PlayerGroup
					.isPlayer = false
					.faceRight = App.rand%2 == 0
					.stared = true
		playerGroup\each => TextWrapped "#{@unit.tag} HP: #{@hp}"
		changed,result = Checkbox "Physics Debug",world.showDebug
		world.showDebug = result if changed
		
		changed,userControl = Checkbox "Take Control",userControl
		if userControl
			if controlPlayer == "Zombie" and
				not playerGroup\each => @unit.tag == "Zombie"
				zombieGroup\each =>
					@player = true
					@zombie = nil
					world.camera.followTarget = with @unit
						.tag = "Zombie"
						.group = PlayerGroup
						.decisionTree = "AI_PlayerControl"
						.sensity = 0
						\addChild Star y:20,size:3,borderColor:0xffff8800,fillColor:0x66ff8800,fillOrder:1,lineOrder:2
					true
			Separator!
			pressedA,choice = RadioButton "Male",playerChoice,0
			playerChoice = choice if pressedA
			pressedB,choice = RadioButton "Female",playerChoice,1
			playerChoice = choice if pressedB
			pressedC,choice = RadioButton "Zombie",playerChoice,2
			playerChoice = choice if pressedC
			if pressedA or pressedB or pressedC or changed
				controlPlayer = switch playerChoice
					when 0 then "KidM"
					when 1 then "KidW"
					when 2 then "Zombie"
				if controlPlayer == "Zombie" and
					not playerGroup\each => @unit.tag == "Zombie"
					zombieGroup\each =>
						@player = true
						@zombie = nil
						with @unit
							.tag = "Zombie"
							.group = PlayerGroup
							\addChild Star y:20,size:3,borderColor:0xffff8800,fillColor:0x66ff8800,fillOrder:1,lineOrder:2
						true
				playerGroup\each =>
					if @unit.tag == controlPlayer
						@unit.decisionTree = "AI_PlayerControl"
						@unit.sensity = 0
						world.camera.followTarget = @unit
					else
						@unit.decisionTree = switch @unit.tag
							when "KidM" then "AI_KidFollow"
							when "KidW" then "AI_KidSearch"
							when "Zombie" then "AI_Zombie"
						@unit.sensity = 0.1
			if changed
				keyboardEnabled = controlChoice == 1
				Director.ui\eachChild => @visible = controlChoice == 0
			Separator!
			TextWrapped if controlChoice == 1
				"Keyboard: Left(A), Right(D), Shoot(J), Jump(K)"
			else "TouchPad: Use buttons in lower screen to control unit."
			Separator!
			pressedA,choice = RadioButton "TouchPad",controlChoice,0
			if pressedA
				controlChoice = choice
				keyboardEnabled = false
				Director.ui\eachChild => @visible = true
			pressedB,choice = RadioButton "Keyboard",controlChoice,1
			if pressedB
				controlChoice = choice
				keyboardEnabled = true
				Director.ui\eachChild => @visible = false
		elseif changed
			playerGroup\each =>
				@unit.decisionTree = (@unit.tag == "KidM" and "AI_KidFollow" or "AI_KidSearch")
				@unit.sensity = 0.1
			keyboardEnabled = false
			Director.ui\eachChild => @visible = false
	End!

with Observer "Add", {"unitDef","position","order","group","isPlayer","faceRight","stared"}
	\every =>
		{:group,:unit} = @
		unit\addChild Star y:20,size:3,borderColor:0xff66ccff,fillColor:0x6666ccff,fillOrder:1,lineOrder:2

