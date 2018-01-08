Dorothy!

sceneGroup = EntityGroup {"scene"}
positionGroup = EntityGroup {"position"}
moveGroup = EntityGroup {"position","direction","speed","target"}

addSceneSystem = EntityObserver "Add", {"scene"}
addSpriteSystem = EntityObserver "Add", {"sprite"}
removeSpriteSystem = EntityObserver "Remove", {"sprite"}
renderSystem = EntityObserver "AddOrChange", {"position","direction","sprite"}

isStoped = false
threadLoop ->
	addSceneSystem\each (entity)->
		Director\pushEntry with entity.scene
			.touchEnabled = true
			\slot "TapEnded", (touch)->
				positionGroup\each (entity)->
					entity.target = touch.location
			\slot "Cleanup", -> isStoped = true

	addSpriteSystem\each (entity)->
		sceneGroup\each (e)->
			e.scene\addChild with entity.sprite
				\runAction Scale 0.5,0,1,Ease.OutBack

	removeSpriteSystem\each (entity)->
		sceneGroup\each (e)->
			e.scene\removeChild entity.valueCache.sprite

	moveGroup\each (entity)->
		{:position, :target, :speed} = entity
		dir = target - position
		dir\normalize!
		angle = math.deg math.atan2 dir.x,dir.y
		newPos = position + dir * speed
		newPos\clamp position, target
		entity.position = newPos
		entity.direction = angle
		entity.target = nil if newPos == target

	renderSystem\each (entity)->
		{:position, :direction, :sprite} = entity
		sprite.position = position
		lastDirection = entity.valueCache.direction or sprite.angle
		if math.abs(direction - lastDirection) > 1
			sprite\runAction Roll 0.3, lastDirection, direction

	isStoped

with Entity!
	.sprite = Sprite "Image/logo.png"
	.position = Vec2 100,200
	.direction = 45
	.speed = 4

with Entity!
	.sprite = Sprite "Image/logo.png"
	.position = Vec2 -100,200
	.direction = 90
	.speed = 10

with Entity!
	.scene = Node!

-- example ends here, just some test ui codes below --

Dorothy builtin.ImGui

addSceneSystem\each (entity)-> entity.scene\schedule ->
	{:width,:height} = Application.designSize
	SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
	SetNextWindowSize Vec2(240,160), "FirstUseEver"
	if Begin "ECS System", "NoResize|NoSavedSettings"
		if BeginChild "scroll"
			Text "Tap any place to move entity."
			if Button "Create Random Entity"
				with Entity!
					.sprite = Sprite "Image/logo.png"
					.position = Vec2 6*math.random(1,100),6*math.random(1,100)
					.direction = math.random 0,360
					.speed = math.random 1,20
			if Button "Destroy An Entity"
				EntityGroup({"sprite","position"})\each (entity)->
					entity.position = nil
					entity.sprite\runAction Sequence Scale(0.5, 1, 0, Ease.InBack), Call -> entity\destroy!
					true
		EndChild!
	End!
