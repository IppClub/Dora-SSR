Dorothy builtin.Platformer

{store:Store} = Data
{
	:GroupPlayer
	:GroupEnemy
	:GroupDisplay
	:GroupTerrain
	:GroupPlayerBlock
	:GroupEnemyBlock
	:GroupPlayerPoke
	:GroupEnemyPoke
	:LayerBunny
	:LayerReadMe
	:LayerPlayerHero
	:LayerEnemyHero
	:LayerBackground
	:LayerBlock
	:MaxEP
	:MaxHP
} = Store

heroes = Group {"hero"}

with Observer "Add",{"world"}
	\every =>
		{:world} = @
		Store.world = with world
			with .camera
				.followRatio = Vec2 0.03,0.03
				.boundary = Rect 0,-110,4096,1004
				.position = Vec2 1024,274
			\addTo Director.entry
			\setIterations 2,3
			\gslot "BlockValue",(group,value)-> heroes\each (hero)->
				hero.blocks = value if hero.group == group
			\gslot "BlockChange",(group,value)-> heroes\each (hero)->
				if hero.group == group
					hero.blocks = math.max hero.blocks+value,0
					hero.defending = true if value < 0
			\gslot "EPChange",(group,value)-> heroes\each (hero)->
				hero.ep += value if hero.group == group
			\gslot "PlayerSelect",(hero)-> thread ->
				sleep 1
				\clearScene!
				for ep in *{6,1,1}
					emit "EPChange",GroupPlayer,ep
					emit "EPChange",GroupEnemy,ep
				.playing = true
				Store.winner = nil
				Audio\playStream "Audio/LOOP14.ogg",true
				names = {"Flandre","Dorothy","Villy"}
				for i,v in ipairs names
					if v == hero
						table.remove names,i
						break
				enemyHero = names[(App.rand%2)+1]
				with Entity!
					.hero = hero
					.group = GroupPlayer
					.faceRight = true
					.AI = "PlayerControlAI"
					.layer = LayerPlayerHero
					.position = Vec2 512,1004-712
					.ep = MaxEP
				with Entity!
					.hero = enemyHero
					.group = GroupEnemy
					.faceRight = false
					.AI = "HeroAI"
					.layer = LayerEnemyHero
					.position = Vec2 3584,1004-712
					.ep = MaxEP
				world\buildCastles!
				world\addBunnySwither GroupPlayer
				world\addBunnySwither GroupEnemy

		world\buildBackground!
		world\buildSwitches!
		world\buildGameReadme!
		Audio\playStream "Audio/LOOP13.ogg",true

with Observer "Add",{"hero","group","layer","position","faceRight","AI"}
	\every =>
		{:hero,:group,:layer,:position,:faceRight,:AI} = @
		{:world} = Store
		unit = with Unit Store[hero],world,@,position
			.group = group
			.faceRight = faceRight
			.order = layer
			.decisionTree = AI
			.attackSpeed = switch hero
				when "Dorothy" then 1.2
				when "Villy" then 1.3
				when "Flandre" then 1.8
			.moveSpeed = 1.5
			\eachAction => @recovery = 0.05
			\addTo world
			\addChild with Visual "Particle/select.par"
				\autoRemove!
				\start!
		if group == GroupPlayer
			world.camera.followTarget = unit

with Observer "Add",{"bunny","group","layer","position","faceRight","AI"}
	\every =>
		{:bunny,:group,:layer,:position,:faceRight,:AI} = @
		{:world} = Store
		unit = with Unit Store[bunny],world,@,position
			.group = group
			.faceRight = faceRight
			.order = layer
			.decisionTree = AI
			\eachAction => @recovery = 0.1
			\addTo world
			@hp -= 1 if @hp == 0

with Observer "Add",{"switch_","group","layer","look","position"}
	\every =>
		{:switch_,:group,:layer,:look,:position} = @
		{:world} = Store
		unit = with Unit Store[switch_],world,@,position
			.group = group
			.order = layer
			with .model
				.look = look
				.scaleX = 2
				.scaleY = 2
			\addTo world
			.emittingEvent = true
			\slot "BodyEnter",(sensor)=>
				if .attackSensor == sensor and @entity and Relation.Friend == Data\getRelation @,unit
					if @group == GroupPlayer and @entity.hero and not @entity.tip
						floating = Action Sequence(
							Y 0.5,140,150,Ease.OutQuad
							Y 0.3,150,140,Ease.InQuad
						)
						@entity.tip = with Sprite "Image/items.clip|keyf_down"
							.y = 140
							scaleOut = Action Spawn(
								Opacity 0.3,0,1
								Scale 0.3,0,1,Ease.OutQuad
							)
							\runAction scaleOut
							\slot "ActionEnd",=> \runAction floating
							\addTo @
					@entity.atSwitch = unit
			\slot "BodyLeave",(sensor)=>
				if .attackSensor == sensor and @entity and Relation.Friend == Data\getRelation @,unit
					@entity.atSwitch = nil
					if @entity.tip
						with @entity.tip
							\perform Spawn(
								Scale 0.3,.scaleX,0
								Opacity 0.3,1,0
							)
							\slot("ActionEnd")\set -> \removeFromParent!
						@entity.tip = nil

with Observer "Add",{"block","group","layer","look","position"}
	\every =>
		{:block,:group,:layer,:look,:position} = @
		{:world} = Store
		with Unit Store[block],world,@,position
			.group = group
			.order = layer
			.model.look = look
			\addTo world

with Observer "Add",{"poke","group","layer","position"}
	\every =>
		{:poke,:group,:layer,:position} = @
		{:world} = Store
		pokeDef = with BodyDef!
			.linearAcceleration = Vec2 0,-10
			.type = BodyType.Dynamic
			\attachDisk 192,10.0,0.1,0.4
			\attachDiskSensor 0,194
		with Body pokeDef,world,position
			.group = group
			.velocityX = switch group
				when GroupPlayerPoke then 400
				when GroupEnemyPoke then -400
			normal = with Sprite "Image/poke.clip|#{poke}"
				.scaleX = 4
				.scaleY = 4
				.filter = TextureFilter.Point
			\addChild normal
			glow = with Sprite "Image/poke.clip|#{poke}l"
				.scaleX = 4
				.scaleY = 4
				.filter = TextureFilter.Point
				.visible = false
			\addChild glow
			\slot "BodyEnter",(sensor)=>
				if sensor.tag == 0 and Relation.Enemy == switch @group
						when GroupPlayer,GroupEnemy then Data\getRelation @group,.group
						else Relation.Unknown
					if (.x < @x) == (.velocityX > 0)
						@velocity = Vec2 .velocityX > 0 and 500 or -500,400
						@start "strike"
			\schedule once ->
				while 50 < math.abs .velocityX
					sleep 0.1
				for i = 1,6
					Audio\play "Audio/di.wav"
					normal.visible = not normal.visible
					glow.visible = not glow.visible
					sleep 0.5
				sensor = \attachSensor 1,BodyDef\disk 500
				sleep!
				for body in *sensor.sensedBodies
					if Relation.Enemy == Data\getRelation body.group,.group
						entity = body.entity
						if entity and entity.hp > 0
							entity.hitPoint = body\convertToWorldSpace Vec2.zero
							entity.hitPower = Vec2 2000,2400
							entity.hitFromRight = body.x < .x
							entity.hp -= 1
				pos = \convertToWorldSpace Vec2.zero
				with Visual "Particle/boom.par"
					.position = pos
					.scaleX = 4
					.scaleY = 4
					\addTo world,LayerBlock
					\autoRemove!
					\start!
				\removeFromParent!
				Audio\play "Audio/explosion.wav"
			\addTo world,layer
		Audio\play "Audio/quake.wav"

with Observer "Change", {"hp","unit","block"}
	\every =>
		{:hp,:unit} = @
		{hp:lastHp} = @oldValues
		if hp < lastHp
			unit\start "cancel" if unit\isDoing "hit"
			if hp > 0
				unit\start "hit"
				unit.faceRight = false
				with unit.model
					.recovery = 0.5
					\play "hp#{hp}"
			else
				unit\start "hit"
				unit.faceRight = false
				unit.group = Data.groupHide
				unit.model\perform Scale 0.3,1,0,Ease.OutQuad
				unit\schedule once ->
					sleep 5
					unit\removeFromParent!
				group = switch @group
					when GroupPlayerBlock then GroupEnemy
					when GroupEnemyBlock then GroupPlayer
				emit "EPChange",group,1
			group = switch @group
				when GroupPlayerBlock then GroupPlayer
				when GroupEnemyBlock then GroupEnemy
			emit "BlockChange",group,math.max(hp,0)-lastHp

with Observer "Change", {"hp","bunny"}
	\every =>
		{:hp,:unit} = @
		{hp:lastHp} = @oldValues
		if hp < lastHp
			unit\start "cancel" if unit\isDoing "hit"
			if hp > 0
				unit\start "hit"
			else
				unit\start "hit"
				unit\start "fall"
				unit.group = Data.groupHide
				group = switch @group
					when GroupPlayer then GroupEnemy
					when GroupEnemy then GroupPlayer
				emit "EPChange",group,1
				unit\schedule once ->
					sleep 5
					unit\removeFromParent!

with Observer "Change", {"hp","hero"}
	\every =>
		{:hp,:unit} = @
		{hp:lastHp} = @oldValues
		{:world} = Store
		if hp < lastHp
			unit\start "cancel" if unit\isDoing "hit"
			if hp > 0
				unit\start "hit"
			else
				unit\start "hit"
				unit\start "fall"
				lastGroup = unit.group
				unit.group = Data.groupHide
				if unit.entity.tip
					unit.entity.tip\removeFromParent!
					unit.entity.tip = nil
				emit "EPChange",lastGroup,6
				switch lastGroup
					when GroupPlayer
						Audio\play "Audio/hero_fall.wav"
						thread ->
							saturation = with SpriteEffect "builtin::vs_sprite","builtin::fs_spritesaturation"
								\set "u_adjustment",0
							View.postEffect = saturation
							sleep 3
							cycle 5,(dt)-> saturation\set "u_adjustment",dt
							View.postEffect = nil
					when GroupEnemy then Audio\play "Audio/hero_kill.wav"
				unit\schedule once ->
					Director.scheduler.timeScale = 0.25
					sleep 3
					Director.scheduler.timeScale = 1
					sleep 2
					world\addBunnySwither lastGroup
					unit.visible = false
					start = unit.position
					stop = switch lastGroup
						when GroupPlayer then Vec2 512,1004-512
						when GroupEnemy then Vec2 3584,1004-512
					cycle 5,(dt)-> unit.position = start + (stop-start) * Ease\func Ease.OutQuad,dt
					unit.model.look = "happy"
					unit.visible = true
					unit.velocityY = 1
					unit.group = lastGroup
					@hp = MaxHP
					emit "HPChange",lastGroup,MaxHP
					with Visual "Particle/select.par"
						\addTo unit
						\start!
						\autoRemove!
				group = switch @group
					when GroupPlayer then GroupEnemy
					when GroupEnemy then GroupPlayer
				emit "EPChange",group,1
		emit "HPChange",@group,math.max(hp,0)-lastHp

with Observer "Change", {"blocks","group"}
	\every =>
		{:world} = Store
		return unless world.playing
		{:blocks,:group} = @
		if blocks == 0
			world.playing = false
			Audio\playStream "Audio/LOOP11.ogg",true
			Store.winner,clip,sound = switch group
				when GroupPlayer then GroupEnemy,"lose","hero_lose"
				when GroupEnemy then GroupPlayer,"win","hero_win"
			Audio\play "Audio/#{sound}.wav"
			sp = with Sprite "Image/misc.clip|#{clip}"
				.scaleX = 2
				.scaleY = 2
				.filter = TextureFilter.Point
			rectDef = with BodyDef!
				.linearAcceleration = Vec2 0,-10
				.type = BodyType.Dynamic
				\attachPolygon sp.width*2,sp.height*2,1,0,1
			with Body rectDef,world,Vec2(@unit.x,512)
				.order = LayerBunny
				.group = GroupDisplay
				\addChild sp
				\addTo world
