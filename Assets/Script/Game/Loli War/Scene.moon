Dorothy builtin.Platformer

{store:Store} = Data
{
	:GroupPlayer
	:GroupEnemy
	:GroupPlayerBlock
	:GroupEnemyBlock
	:GroupTerrain
	:GroupDisplay
	:LayerReadMe
	:LayerBlock
	:LayerBunny
	:LayerSwitch
	:LayerPlayerHero
	:LayerEnemyHero
	:LayerBackground
	:MaxEP
} = Store

GameWorld = Class PlatformWorld,
	__init:=>
		@entity = with Entity!
			.world = @
		@slot "Cleanup",-> @entity\destroy!

	buildBackground: =>
		terrainDef = with BodyDef!
			.type = BodyType.Static
			\attachPolygon Vec2(2048,1004-994),4096,10
			\attachPolygon Vec2(2048,1004),4096,10
			\attachPolygon Vec2(-5,1004-512),10,1024
			\attachPolygon Vec2(4101,1004-512),10,1024

		@addChild with Body terrainDef,@,Vec2.zero
			.order = LayerBackground
			.group = GroupTerrain

		@addChild with Sprite "Image/items.clip|background"
			.order = LayerBackground
			.anchor = Vec2.zero
			.scaleX = 4146/.width
			.scaleY = 1600/.height
			.y = -50

		@addChild with Node!
			.order = LayerBackground
			.y = -44
			for i = 0,32
				\addChild with Sprite "Image/misc.clip|floor"
					.scaleX = 8
					.scaleY = 8
					.x = i*128
					.filter = TextureFilter.Point

	buildGameReadme: =>
		pos = @camera.position
		readmeDef = with BodyDef!
			.type = BodyType.Static
			\attachPolygon Vec2(pos.x,1004-994),1024,10
			\attachPolygon Vec2(pos.x,1004),1024,10
			\attachPolygon Vec2(pos.x-512,1004-512),10,1024
			\attachPolygon Vec2(pos.x+512,1004-512),10,1024

		readme = with Body readmeDef,@,Vec2.zero
			.order = LayerBackground
			.group = GroupDisplay
			\addTo @
			\gslot "PlayerSelect",->
				.children\each (child)->
					with Visual "Particle/heart.par"
						.position = child\convertToWorldSpace Vec2.zero
						\addTo Director.entry
						\autoRemove!
						\start!
				\removeFromParent!

		for item in *{
				{"war",Vec2(pos.x-512+369,1004-413-200)}
				{"use",Vec2(pos.x-512+459,1004-575-200)}
				{"key",Vec2(pos.x-512+521,1004-499-200)}
				{"loli",Vec2(pos.x-512+655,1004-423-200)}
				{"select",Vec2(pos.x-512+709,1004-509-200)}
				{"mosic",Vec2(pos.x-512+599,1004-339-200)}
				{"breakblocks",Vec2(pos.x-512+578,1004-626-200)}
				{"search",Vec2(pos.x-512+746,1004-604-200)}
				{"quit",Vec2(pos.x-512+363,1004-566-200)}
				{"pushSwitch",Vec2(pos.x-512+494,1004-631-200)}
				{"attack",Vec2(pos.x-512+630,1004-631-200)}
			}
			sp = with Sprite "Image/misc.clip|#{item[1]}"
				.scaleX = 2
				.scaleY = 2
				.filter = TextureFilter.Point
			rectDef = with BodyDef!
				.linearAcceleration = Vec2 0,-10
				.type = BodyType.Dynamic
				\attachPolygon sp.width*2,sp.height*2,1,0,1
			with Body rectDef,@,item[2]
				.order = LayerBackground
				.group = GroupDisplay
				\addChild sp
				\addTo readme

	buildCastles: =>
		Block = (block,group,look,x,y)->
			with Entity!
				.block = "Block#{block}"
				.group = group
				.layer = LayerBlock
				.look = look
				.position = Vec2 x,y

		-- Player's castle 1
		Block "C",GroupPlayerBlock,"gray",419,1004-280
		Block "A",GroupPlayerBlock,"green",239,1004-190
		Block "A",GroupPlayerBlock,"green",419,1004-190
		Block "A",GroupPlayerBlock,"green",599,1004-190
		Block "C",GroupPlayerBlock,"gray",419,1004-580
		Block "B",GroupPlayerBlock,"",291,1004-430
		Block "B",GroupPlayerBlock,"",416,1004-430
		Block "B",GroupPlayerBlock,"",540,1004-430
		Block "A",GroupPlayerBlock,"gray",239,1004-670
		Block "A",GroupPlayerBlock,"gray",599,1004-670
		Block "A",GroupPlayerBlock,"blue",239,1004-760
		Block "A",GroupPlayerBlock,"blue",599,1004-760
		Block "A",GroupPlayerBlock,"red",239,1004-850
		Block "A",GroupPlayerBlock,"red",599,1004-850
		Block "C",GroupPlayerBlock,"jade",419,1004-940

		-- Player's castle 2
		Block "C",GroupPlayerBlock,"jade",1074,1004-552
		Block "C",GroupPlayerBlock,"jade",1074,1004-731
		Block "A",GroupPlayerBlock,"blue",894,1004-463
		Block "A",GroupPlayerBlock,"blue",1075,1004-463
		Block "A",GroupPlayerBlock,"blue",1254,1004-463
		Block "A",GroupPlayerBlock,"green",956,1004-642
		Block "A",GroupPlayerBlock,"green",1194,1004-642
		Block "B",GroupPlayerBlock,"",893,1004-881
		Block "B",GroupPlayerBlock,"",1254,1004-881

		-- Enemy's castle 1
		Block "C",GroupEnemyBlock,"gray",3674,1004-281
		Block "A",GroupEnemyBlock,"green",3494,1004-191
		Block "A",GroupEnemyBlock,"green",3674,1004-191
		Block "A",GroupEnemyBlock,"green",3854,1004-191
		Block "C",GroupEnemyBlock,"gray",3674,1004-581
		Block "B",GroupEnemyBlock,"",3546,1004-431
		Block "B",GroupEnemyBlock,"",3671,1004-431
		Block "B",GroupEnemyBlock,"",3795,1004-431
		Block "A",GroupEnemyBlock,"gray",3494,1004-671
		Block "A",GroupEnemyBlock,"gray",3854,1004-671
		Block "A",GroupEnemyBlock,"blue",3494,1004-761
		Block "A",GroupEnemyBlock,"blue",3854,1004-761
		Block "A",GroupEnemyBlock,"red",3494,1004-851
		Block "A",GroupEnemyBlock,"red",3854,1004-851
		Block "C",GroupEnemyBlock,"jade",3674,1004-941

		-- Enemy's castle 2
		Block "C",GroupEnemyBlock,"jade",3024,1004-552
		Block "C",GroupEnemyBlock,"jade",3024,1004-731
		Block "A",GroupEnemyBlock,"blue",2844,1004-463
		Block "A",GroupEnemyBlock,"blue",3025,1004-463
		Block "A",GroupEnemyBlock,"blue",3204,1004-463
		Block "A",GroupEnemyBlock,"green",2906,1004-642
		Block "A",GroupEnemyBlock,"green",3144,1004-642
		Block "B",GroupEnemyBlock,"",2843,1004-881
		Block "B",GroupEnemyBlock,"",3204,1004-881

		playerBlockHP = 0
		enemyBlockHP = 0
		with Group {"block"}
			\each => switch @group
				when GroupPlayerBlock
					playerBlockHP += Store[@block].maxHp
				when GroupEnemyBlock
					enemyBlockHP += Store[@block].maxHp
		emit "BlockValue",GroupPlayer,playerBlockHP
		emit "BlockValue",GroupEnemy,enemyBlockHP

	buildSwitches: =>
		Switch = (switch_,group,look,x,y)->
			with Entity!
				.switch_ = switch_
				.group = group
				.look = look
				.layer = LayerSwitch
				.position = Vec2 x,y

		Switch "Switch",GroupPlayer,"normal",777,1004-923
		Switch "SwitchG",GroupPlayer,"gold",116,1004-923
		Switch "Switch",GroupEnemy,"normal",3331,1004-923
		Switch "SwitchG",GroupEnemy,"gold",3977,1004-923

	addBunnySwither: (group)=>
		switchG = false
		switchN = false
		bunnySwitchers = Group {"bunny","targetSwitch"}
		bunnySwitchers\each (switcher)->
			if switcher.group == group
				switch switcher.targetSwitch
					when "SwitchG" then switchG = true
					when "Switch" then switchN = true
		if not switchG
			with Entity!
				.group = group
				.bunny,.faceRight,.position = switch group
					when GroupPlayer then "BunnyG",false,Vec2 216,500
					when GroupEnemy then "BunnyP",true,Vec2 3877,500
				.AI = "BunnySwitcherAI"
				.layer = LayerBunny
				.targetSwitch = "SwitchG"
		if not switchN
			with Entity!
				.group = group
				.bunny,.faceRight,.position = switch group
					when GroupPlayer then "BunnyG",true,Vec2 677,500
					when GroupEnemy then "BunnyP",false,Vec2 3431,500
				.AI = "BunnySwitcherAI"
				.layer = LayerBunny
				.targetSwitch = "Switch"

	clearScene: =>
		@removeLayer LayerBlock
		@removeLayer LayerBunny
		@removeLayer LayerPlayerHero
		@removeLayer LayerEnemyHero

GameWorld!
