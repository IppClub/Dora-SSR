_ENV = Dorothy builtin.Platformer, builtin.ImGui
import "UI.Control.Basic.AlignNode"
import "UI.Control.Basic.CircleButton"
store:Store = Data

--LoadFontTTF "Font/sarasa-mono-sc-regular.ttf", 20, "Chinese"

characters =
	* body: "character_roundGreen"
		lhand: "character_handGreen"
		rhand: "character_handGreen"

	* body: "character_roundRed"
		lhand: "character_handRed"
		rhand: "character_handRed"

	* body: "character_roundYellow"
		lhand: "character_handYellow"
		rhand: "character_handYellow"

headItems =
	* "item_hat"
	* "item_hatTop"
	* "item_helmet"
	* "item_helmetModern"

lhandItems =
	* "item_shield"
	* "item_shieldRound"
	* "tile_heart"
	* "ui_hand"

rhandItems =
	* "item_bow"
	* "item_sword"
	* "item_rod"
	* "item_spear"

characterTypes =
	* "square"
	* "round"

characterColors =
	* "Green"
	* "Red"
	* "Yellow"

itemSettings =
	item_hat:
		name: "普通帽子"
		desc: "就是很普通的帽子，增加许些防御力"
		cost: 1
		skill: "jump"
		skillDesc: "跳跃"
		offset: Vec2 0,30

	item_hatTop:
		name: "高帽子"
		desc: "就是很普通的帽子，增加许些防御力"
		cost: 1
		skill: "evade"
		skillDesc: "闪避"
		offset: Vec2 0,30

	item_helmet:
		name: "战盔"
		desc: "就是很普通的帽子，增加许些防御力"
		cost: 1
		skill: "evade"
		skillDesc: "闪避"
		offset: Vec2 0,0

	item_helmetModern:
		name: "橄榄球盔"
		desc: "就是很普通的帽子，增加许些防御力"
		cost: 1
		skill: ""
		skillDesc: "无"
		offset: Vec2 0,0

	item_shield:
		name: "方形盾"
		desc: "无"
		cost: 1
		skill: "evade"
		skillDesc: "闪避"
		offset: Vec2 0,0

	item_shieldRound:
		name: "小圆盾"
		desc: "无"
		cost: 1
		skill: "jump"
		skillDesc: "跳跃"
		offset: Vec2 0,0

	tile_heart:
		name: "爱心"
		desc: "无"
		cost: 1
		skill: "jump"
		skillDesc: "跳跃"
		offset: Vec2 0,0

	ui_hand:
		name: "手套"
		desc: "无"
		cost: 1
		skill: "evade"
		skillDesc: "闪避"
		offset: Vec2 0,0

	item_bow:
		name: "短弓"
		desc: "无"
		cost: 1
		skill: "range"
		skillDesc: "远程攻击"
		offset: Vec2 10,0
		attackRange: Size 630,150

	item_sword:
		name: "剑"
		desc: "无"
		cost: 1
		skill: "meleeAttack"
		skillDesc: "近程攻击"
		offset: Vec2 15,50
		attackRange: Size 120,150

	item_rod:
		name: "法杖"
		desc: "无"
		cost: 1
		skill: "meleeAttack"
		skillDesc: "近程攻击"
		offset: Vec2 15,50
		attackRange: Size 200,150

	item_spear:
		name: "长矛"
		desc: "无"
		cost: 1
		skill: "meleeAttack"
		skillDesc: "近程攻击"
		offset: Vec2 15,50
		attackRange: Size 200,150

itemSlots =
	* "head"
	* "lhand"
	* "rhand"

characters =
	* head: nil
		lhand: nil
		rhand: nil
		type: 1
		color: 1
		learnedAI: -> "unknown"

	* head: nil
		lhand: nil
		rhand: nil
		type: 1
		color: 2
		learnedAI: -> "unknown"

	* head: nil
		lhand: nil
		rhand: nil
		type: 1
		color: 3
		learnedAI: -> "unknown"

bossGroup = Group {"boss"}

lastAction = "idle"
lastActionFrame = App.frame
data = {}
row = nil
Do = (name)-> Seq {
	Con "Collect data", =>
		if @isDoing name
			row = nil
			return true

		unless AI\getNearestUnit(Relation.Enemy)?
			row = nil
			return true

		attack_ready = do
			attackUnits = AI\getUnitsInAttackRange!
			ready = false
			for unit in *attackUnits
				if Relation.Enemy == Data\getRelation(@,unit) and
					(@x < unit.x) == @faceRight
					ready = true
					break
			ready

		not_facing_enemy = do
			enemy = AI\getNearestUnit Relation.Enemy
			if enemy
				(@x > enemy.x) == @faceRight
			else
				false

		enemy_in_attack_range = do
			enemy = AI\getNearestUnit Relation.Enemy
			attackUnits = AI\getUnitsInAttackRange!
			attackUnits and attackUnits\contains(enemy) or false

		nearest_enemy_distance = do
			enemy = AI\getNearestUnit Relation.Enemy
			if enemy?
				math.abs enemy.x - @x
			else
				999999

		enemy_hero_action = do
			enemy = AI\getNearestUnit Relation.Enemy
			enemy.currentAction?.name or "unknown"

		row = {
			:not_facing_enemy
			:enemy_in_attack_range
			:attack_ready
			:enemy_hero_action
			:nearest_enemy_distance
			action:name
		}
		true
	Sel {
		Con "is doing",=> @isDoing name
		Seq {
			Act name
			Con "action succeeded",=>
				lastAction = name
				lastActionFrame = App.frame
				true
		}
	}
	Con "Save data",=>
		return true if row == nil
		table.insert data,row
		true
}

rowNames = {
	"not_facing_enemy"
	"enemy_in_attack_range"

	"attack_ready"
	"enemy_hero_action"
	"nearest_enemy_distance"

	"action"
}

rowTypes = {
	'C','C'
	'C','C','N'
	'C'
}

Director.entry\addChild with Node!
	\gslot "TrainAI", (charSet)->
		csvData = for row in *data
			rd = for name in *rowNames
				val = if row[name]? then row[name] else "N"
				if "boolean" == type val
					val = if val then "T" else "F"
				tostring val
			table.concat rd,","
		names = "#{table.concat rowNames,','}\n"
		dataStr = "#{names}#{table.concat rowTypes,','}\n#{table.concat csvData,'\n'}"
		data = {}
		thread ->
			lines = {"(_ENV)->"}
			accuracy = ML\buildDecisionTreeAsync dataStr,0,(depth,name,op,value)->
				line = string.rep("\t",depth+1) .. if name ~= "" then
					"if #{name} #{op} #{op=='==' and "\"#{value}\"" or value}"
				else
					"#{op} \"#{value}\""
				lines[#lines+1] = line
			codes = table.concat lines,"\n"
			--print "learning accuracy: #{accuracy}"
			--print codes
			--print dataStr
			import "moonp"
			luaCodes = moonp.to_lua codes,{reserve_line_number:false}
			learnedAI = load(luaCodes)?! or -> "unknown"
			characters[charSet].learnedAI = learnedAI
			emit "LearnedAI", learnedAI

Store["AI_Learned"] = Sel {
	Seq {
		Con "is dead",=> @entity.hp <= 0
		Pass!
	}
	Seq {
		Con "is falling",=> not @onSurface
		Act "fallOff"
	}
	Seq {
		Con "run learned AI", =>
			@entity.lastActionTime or= 0.0

			return false unless AI\getNearestUnit(Relation.Enemy)?

			if App.totalTime - @entity.lastActionTime < 0.1
				return false
			else
				@entity.lastActionTime = App.totalTime

			attack_ready = do
				attackUnits = AI\getUnitsInAttackRange!
				ready = "F"
				for unit in *attackUnits
					if Relation.Enemy == Data\getRelation(@,unit) and
						(@x < unit.x) == @faceRight
						ready = "T"
						break
				ready

			not_facing_enemy = do
				enemy = AI\getNearestUnit Relation.Enemy
				if enemy
					if (@x > enemy.x) == @faceRight
						"T"
					else
						"F"
				else
					"F"

			enemy_in_attack_range = do
				enemy = AI\getNearestUnit Relation.Enemy
				attackUnits = AI\getUnitsInAttackRange!
				(attackUnits and attackUnits\contains(enemy)) and "T" or "F"

			nearest_enemy_distance = do
				enemy = AI\getNearestUnit Relation.Enemy
				if enemy?
					math.abs enemy.x - @x
				else
					999999

			enemy_hero_action = do
				enemy = AI\getNearestUnit Relation.Enemy
				enemy.currentAction?.name or "unknown"

			@entity.learnedAction = characters[@entity.charSet].learnedAI({
				:not_facing_enemy
				:enemy_in_attack_range
				:attack_ready
				:enemy_hero_action
				:nearest_enemy_distance
			}) or "unknown"
			true
		Sel {
			Con "is doing",=> @isDoing @entity.learnedAction
			Seq {
				Act => @entity.learnedAction
				Con "Succeeded prediction",=>
					emit "Prediction",true
					true
			}
			Con "Failed prediction",=>
				emit "Prediction",false
				false
		}
	}
	Seq {
		Con "not facing enemy",=> bossGroup\each (boss)->
			{:unit} = boss
			if Relation.Enemy == Data\getRelation unit,@
				if (@x > unit.x) == @faceRight
					return true
		Act "turn"
	}
	Seq {
		Con "need turn",=>
			(@x < -1000 and not @faceRight) or (@x > 1000 and @faceRight)
		Act "turn"
	}
	Sel {
		Seq {
			Con "take a break",=> App.rand % 60 == 0
			Act "idle"
		}
		Act "walk"
	}
}

Store["Bullet_Arrow"] = with BulletDef!
	.tag = ""
	.endEffect = ""
	.lifeTime = 5
	.damageRadius = 0
	.highSpeedFix = false
	.gravity = Vec2 0,-10
	.face = Face "Image/patreon.clip|item_arrow", Vec2(0,0)
	\setAsCircle 10
	\setVelocity 25,800

Store["AI_Boss"] = Sel {
	Seq {
		Con "is dead",=> @entity.hp <= 0
		Pass!
	}
	Seq {
		Con "is falling",=> not @onSurface
		Act "fallOff"
	}
	Seq {
		Con "is not attacking", =>
			not @isDoing("meleeAttack") and
			not @isDoing("multiArrow") and
			not @isDoing("spearAttack")
		Con "need attack",=>
			attackUnits = AI\getUnitsInAttackRange!
			for unit in *attackUnits
				if Relation.Enemy == Data\getRelation(@,unit) and
					(@x < unit.x) == @faceRight
					return true
			false
		Sel {
			Seq {
				Con "melee attack",=> App.rand % 250 == 0
				Act "meleeAttack"
			}
			Seq {
				Con "range attack",=> App.rand % 250 == 0
				Act "multiArrow"
			}
			Seq {
				Con "spear attack",=> App.rand % 250 == 0
				Act "spearAttack"
			}
			Act "idle"
		}
	}
	Seq {
		Con "need turn",=>
			(@x < -1000 and not @faceRight) or (@x > 1000 and @faceRight)
		Act "turn"
	}
	Act "walk"
}

Store["AI_PlayerControl"] = Sel {
	Seq {
		Con "is dead",=> @entity.hp <= 0
		Pass!
	}
	Seq {
		Seq {
			Con "move key down",=>
				not (@entity.keyLeft and @entity.keyRight) and
				(
					(@entity.keyLeft and @faceRight) or
					(@entity.keyRight and not @faceRight)
				)
			Act "turn"
		}
		Reject!
	}
	Seq {
		Con "evade key down",=> @entity.keyE
		Do "evade"
	}
	Seq {
		Con "attack key down",=> @entity.keyF
		Sel {
			Do "meleeAttack"
			Do "range"
		}
	}
	Sel {
		Seq {
			Con "is falling",=> not @onSurface and not @isDoing "evade"
			Act "fallOff"
		}
		Seq {
			Con "jump key down",=> @entity.keyUp
			Do "jump"
		}
	}
	Seq {
		Con "move key down",=> @entity.keyLeft or @entity.keyRight
		Do "walk"
	}
	Act "idle"
}

NewFighterDef = -> with UnitDef!
	.bodyDef.linearAcceleration = Vec2 0,-10
	.static = false
	.scale = 1
	.density = 1.0
	.friction = 1.0
	.restitution = 0.0
	.playable = "Model/patreon.model"
	.size = Size 64,128
	.tag = "Fighter"
	.sensity = 0
	.move = 250
	.jump = 700
	.detectDistance = 800
	.maxHp = 50
	.attackBase = 2.5
	.attackDelay = 20.0/60.0
	.attackEffectDelay = 20.0/60.0
	.attackRange = Size 350,150
	.attackPower = Vec2 100,100
	.attackType = AttackType.Range
	.attackTarget = AttackTarget.Single
	.targetAllow = (with TargetAllow!
		.terrainAllowed = true
		\allow Relation.Enemy,true)
	.damageType = 0
	.defenceType = 0
	.bulletType = "Bullet_Arrow"
	.attackEffect = ""
	.hitEffect = "Particle/bloodp.par"
	.name = "Fighter"
	.desc = ""
	.sndAttack = ""
	.sndFallen = ""
	.decisionTree = "AI_PlayerControl"
	.usePreciseHit = true
	.actions = {
		"walk"
		"turn"
		"idle"
		"cancel"
		"hit"
		"fall"
		"fallOff"
	}

NewBossDef = -> with UnitDef!
	.bodyDef.linearAcceleration = Vec2 0,-10
	.static = false
	.scale = 2
	.density = 10.0
	.friction = 1.0
	.restitution = 0.0
	.playable = "Model/bossp.model"
	.size = Size 150,410
	.tag = "Boss"
	.sensity = 0
	.move = 100
	.jump = 600
	.detectDistance = 1500
	.maxHp = 200
	.attackBase = 2.5
	.attackDelay = 50.0/60.0
	.attackEffectDelay = 50.0/60.0
	.attackRange = Size 780,300
	.attackPower = Vec2 200,200
	.attackType = AttackType.Range
	.attackTarget = AttackTarget.Multi
	.targetAllow = (with TargetAllow!
		.terrainAllowed = true
		\allow Relation.Enemy,true)
	.damageType = 0
	.defenceType = 0
	.bulletType = "Bullet_Arrow"
	.attackEffect = ""
	.hitEffect = "Particle/bloodp.par"
	.name = "Boss"
	.desc = ""
	.sndAttack = ""
	.sndFallen = ""
	.decisionTree = "AI_Boss"
	.usePreciseHit = true
	.actions = {
		"walk"
		"turn"
		"meleeAttack"
		"multiArrow"
		"spearAttack"
		"idle"
		"cancel"
		"jump"
		"fall"
		"fallOff",
	}

UnitDefFuncs = {
	fighter: NewFighterDef
	boss: NewBossDef
}

itemSize = 64
NewItemPanel = (displayName, itemName, itemOptions, currentSet)->
	selectItems = false
	->
		Columns 1, false
		TextColored Color(0xff00ffff), displayName
		NextColumn!
		if selectItems
			Columns #itemOptions + 1, false
			PushID "#{itemName}x", ->
				if Button "x", Vec2(itemSize+10, itemSize+10)
					currentSet[itemName] = nil
					selectItems = false
			NextColumn!
			for i = 1, #itemOptions
				item = itemOptions[i]
				PushID "#{itemName}#{i}", ->
					if ImageButton "Image/patreon.clip|#{item}", Vec2(itemSize,itemSize), 5
						currentSet[itemName] = item
						selectItems = false
				NextColumn!
		else
			if not currentSet[itemName]
				Columns 3, false
				PushID "#{itemName}c1", ->
					selectItems = true if Button "x", Vec2(itemSize+10, itemSize+10)
				NextColumn!
				Text "未装备"
			else
				Columns 3, false
				item = currentSet[itemName]
				PushID "#{itemName}c2", ->
					selectItems = true if ImageButton "Image/patreon.clip|#{item}", Vec2(itemSize,itemSize)
				NextColumn!
				TextColored Color(0xfffffa0a), itemSettings[item].name
				TextWrapped itemSettings[item].desc
				NextColumn!
				TextColored Color(0xffff0a90), "消耗: #{itemSettings[item].cost}"
				Text "特技: #{itemSettings[item].skillDesc}"
				NextColumn!

-- background

size,grid = 2500,100

background = -> with DrawNode!
	.is3D = true
	\drawPolygon {
		Vec2 -size,size
		Vec2 size,size
		Vec2 size,-size
		Vec2 -size,-size
	}, Color 0xff888888
	\addChild with Line!
		.is3D = true
		.z = -10
		for i = -size/grid,size/grid
			\add {
				Vec2 i*grid,size
				Vec2 i*grid,-size
			}, Color 0xff000000
			\add {
				Vec2 -size,i*grid
				Vec2 size,i*grid
			}, Color 0xff000000

Director.entry\addChild with background!
	.z = 600
Director.entry\addChild with background!
	.angleX = 45

-- Scene

TerrainLayer = 0
EnemyLayer = 1
PlayerLayer = 2

PlayerGroup = 1
EnemyGroup = 2

Data\setRelation PlayerGroup, EnemyGroup, Relation.Enemy
Data\setShouldContact PlayerGroup, EnemyGroup, true

world = with PlatformWorld!
	.camera.followRatio = Vec2 0.01,0.01
Store["world"] = world

terrainDef = with BodyDef!
	.type = BodyType.Static
	\attachPolygon Vec2(0,0),2500,10,0,1,1,0
	\attachPolygon Vec2(0,1000),2500,10,0,1,1,0
	\attachPolygon Vec2(1250,500),10,1000,0,1,1,0
	\attachPolygon Vec2(-1250,500),10,1000,0,1,1,0

with Body terrainDef,world,Vec2.zero
	.order = TerrainLayer
	.group = Data.groupTerrain
	\addTo world

with Director.entry
	\addChild world

updateModel = (model, currentSet)->
	node = model\getNodeByName "body"
	node\removeAllChildren!
	charType = characterTypes[currentSet.type]
	charColor = characterColors[currentSet.color]
	node\addChild Sprite "Image/patreon.clip|character_#{charType}#{charColor}"
	node = model\getNodeByName "lhand"
	node\removeAllChildren!
	node\addChild Sprite "Image/patreon.clip|character_hand#{charColor}"
	node = model\getNodeByName "rhand"
	node\removeAllChildren!
	node\addChild Sprite "Image/patreon.clip|character_hand#{charColor}"
	model\getNodeByName("head")\removeAllChildren!
	for slot in *itemSlots
		node = model\getNodeByName slot
		item = currentSet[slot]
		if item
			offset = itemSettings[item].offset
			node\addChild with Sprite "Image/patreon.clip|#{item}"
				.position = offset

NewFighter = (name, currentSet)->
	assembleFighter = false
	fighter = with Model "Model/patreon.model"
		modelRect = Rect -128,-128,256,256
		.recovery = 0.2
		.order = PlayerLayer
		.touchEnabled = true
		\slot "TapFilter",(touch)->
			unless modelRect\containsPoint touch.location
				touch.enabled = false
		\slot "Tapped", ->
			if not fighter\getChildByTag "select"
				selectFrame = with Sprite "Image/patreon.clip|ui_select"
					\addTo fighter, 0, "select"
					\runAction Scale 0.3,0,1.8,Ease.OutBack
					assembleFighter = true
		\play "idle", true
	updateModel fighter, currentSet
	HeadItemPanel = NewItemPanel "头部", "head", headItems, currentSet
	LHandItemPanel = NewItemPanel "副手", "lhand", lhandItems, currentSet
	RHandItemPanel = NewItemPanel "主手", "rhand", rhandItems, currentSet
	fighter, ->
		SetNextWindowSize Vec2(445,600), "FirstUseEver"
		if assembleFighter
			assembleFighter = false
			OpenPopup "战士#{name}"
		BeginPopupModal "战士#{name}", "NoResize|NoSavedSettings", ->
			HeadItemPanel!
			RHandItemPanel!
			LHandItemPanel!
			Columns 1, false
			TextColored Color(0xff00ffff), "性别"
			NextColumn!
			_, currentSet.type = RadioButton "男", currentSet.type, 1
			SameLine!
			_, currentSet.type = RadioButton "女", currentSet.type, 2
			Columns 1, false
			cost = 0
			for slot in *itemSlots
				item = currentSet[slot]
				cost += item and itemSettings[item].cost or 0
			TextColored Color(0xff00ffff), "累计消耗资源：#{cost}"
			NextColumn!
			Columns 2, false
			if Button "进行训练！", Vec2(200,80)
				updateModel fighter, currentSet
				CloseCurrentPopup!
				with fighter\getChildByTag "select"
					\removeFromParent!
				emit "ShowSetting",false
				charSet = 1
				for i = 1,#characters
					if currentSet == characters[i]
						charSet = i
						break
				with Entity!
					.unitDef = "fighter"
					.charSet = charSet
					.order = PlayerLayer
					.position = Vec2 -400,400
					.group = PlayerGroup
					.faceRight = true
					.player = true
					.decisionTree = "AI_PlayerControl"
				with Entity!
					.unitDef = "boss"
					.order = EnemyLayer
					.position = Vec2 400,400
					.group = EnemyGroup
					.faceRight = false
					.boss = true
				emit "ShowTraining", true
			NextColumn!
			if Button "装备完成！", Vec2(200,80)
				updateModel fighter, currentSet
				CloseCurrentPopup!
				with fighter\getChildByTag "select"
					\runAction Sequence Spawn(
						Scale 0.3, 1.8, 2.5
						Opacity 0.3, 1, 0
					), Emit "End"
					\slot "End", -> \removeFromParent!
			NextColumn!

fighterFigures = {}
fighterPanels = {}
for i = 1, #characters
	fighter, fighterPanel = NewFighter string.rep("I",i), characters[i]
	table.insert fighterFigures, fighter
	table.insert fighterPanels, fighterPanel

playerGroup = Group {"player"}
updatePlayerControl = (key,flag)->
	player = nil
	playerGroup\each => player = @
	player[key] = flag if player

uiScale = App.deviceRatio

Director.ui\addChild with AlignNode isRoot:true
	\schedule ->
		:width,:height = App.visualSize
		SetNextWindowPos Vec2(10,10), "FirstUseEver"
		SetNextWindowSize Vec2(350,160), "FirstUseEver"
		Begin "AI军团", "NoResize|NoSavedSettings", ->
			isPC = switch App.platform
				when "macOS","Windows" then true
				else false
			TextWrapped "点击你的学员部队配备装备，并亲自进行战斗方法的训练，最后带领部队挑战敌人。\n学员战斗AI通过玩家操作自动学习生成。#{isPC and '训练操作按键：向左A，向右D，闪避E，攻击J，跳跃K' or ''}"
	\addChild with AlignNode!
		.size = Size 0,0
		.hAlign = "Center"
		.vAlign = "Center"
		.alignOffset = Vec2 0, 32
		.visible = false
		\gslot "ShowTraining",(show)->
			.visible = show
			if show
				\addChild with CircleButton {
						text:"训练\n结束！"
						y:-300
						radius:80
						fontName:"NotoSansHans-Regular"
						fontSize:48
					}
					\slot "Tapped",->
						emit "ShowTraining", false
						Group({"player"})\each (e)->
							if e.charSet
								emit "TrainAI", e.charSet 
								e.unit\removeFromParent!
						Group({"boss"})\each (e)->
							e.unit\removeFromParent!
						emit "ShowSetting", true
			else
				\removeAllChildren!
		\gslot "ShowFight",(show)->
			.visible = show
			if show
				\addChild with CircleButton {
						text:"离开\n战斗"
						y:-300
						radius:80
						fontName:"NotoSansHans-Regular"
						fontSize:48
					}
					\slot "Tapped",->
						Group({"unitDef"})\each (e)->
							e.unit?\removeFromParent!
						emit "ShowSetting", true
						thread -> emit "ShowFight", false
			else
				\removeAllChildren!
	\addChild with AlignNode!
		.size = Size 0,0
		.hAlign = "Center"
		.vAlign = "Center"
		.alignOffset = Vec2 0, 32
		\gslot "ShowSetting",(show)-> .visible = show
		\addChild with Model "Model/bossp.model"
			.x = 500
			.y = 100
			.faceRight = false
			.speed = 0.8
			.scaleX,.scaleY = 2,2
			.recovery = 0.2
			\play "idle", true
		for i = 1, #fighterFigures
			fighter = fighterFigures[i]
			\addChild with fighter
				.x = -500 + (i - 1) * 200
		\addChild with CircleButton {
				text:"开战！"
				y:-300
				radius:80
				fontName:"NotoSansHans-Regular"
				fontSize:48
			}
			\gslot "ShowFight",(show)-> .visible = not show
			\gslot "ShowTraining",(show)-> .visible = not show
			\slot "Tapped",->
				return if not .visible
				for i = 1,#characters
					char = characters[i]
					with Entity!
						.unitDef = "fighter"
						.charSet = i
						.order = PlayerLayer
						.position = Vec2 -600+(i-1)*200,400
						.group = PlayerGroup
						.faceRight = true
						.decisionTree = "AI_Learned"
						.player = true
				with Entity!
					.unitDef = "boss"
					.order = EnemyLayer
					.position = Vec2 400,400
					.group = EnemyGroup
					.faceRight = false
					.boss = true
				emit "ShowSetting", false
				emit "ShowFight", true
	switch App.platform
		when "iOS","Android"
			\addChild with AlignNode!
				.hAlign = "Left"
				.vAlign = "Bottom"
				.visible = false
				\gslot "ShowTraining",(show)-> .visible = show
				\addChild with Menu!
					\addChild with CircleButton {
							text: "左"
							x: 20*uiScale
							y: 90*uiScale
							radius: 30*uiScale
							fontSize: math.floor 18*uiScale
						}
						.anchor = Vec2.zero
						\slot "TapBegan",-> updatePlayerControl "keyLeft",true
						\slot "TapEnded",-> updatePlayerControl "keyLeft",false
					\addChild with CircleButton {
							text: "右"
							x: 90*uiScale
							y: 90*uiScale
							radius: 30*uiScale
							fontSize: math.floor 18*uiScale
						}
						.anchor = Vec2.zero
						\slot "TapBegan",-> updatePlayerControl "keyRight",true
						\slot "TapEnded",-> updatePlayerControl "keyRight",false
			\addChild with AlignNode!
				.hAlign = "Right"
				.vAlign = "Bottom"
				.visible = false
				\gslot "ShowTraining",(show)-> .visible = show
				\addChild with Menu!
					\addChild with CircleButton {
							text: "闪"
							x: -80*uiScale
							y: 160*uiScale
							radius: 30*uiScale
							fontSize: math.floor 18*uiScale
						}
						.anchor = Vec2.zero
						\slot "TapBegan",-> updatePlayerControl "keyE",true
						\slot "TapEnded",-> updatePlayerControl "keyE",false
					\addChild with CircleButton {
							text: "跳"
							x: -80*uiScale
							y: 90*uiScale
							radius: 30*uiScale
							fontSize: math.floor 18*uiScale
						}
						.anchor = Vec2.zero
						\slot "TapBegan",-> updatePlayerControl "keyUp",true
						\slot "TapEnded",-> updatePlayerControl "keyUp",false
					\addChild with CircleButton {
							text: "打"
							x: -150*uiScale
							y: 90*uiScale
							radius: 30*uiScale
							fontSize: math.floor 18*uiScale
						}
						.anchor = Vec2.zero
						\slot "TapBegan",-> updatePlayerControl "keyF",true
						\slot "TapEnded",-> updatePlayerControl "keyF",false
		when "macOS","Windows"
			Director.entry\addChild with Node!
				\schedule ->
					updatePlayerControl "keyLeft", Keyboard\isKeyPressed "A"
					updatePlayerControl "keyRight", Keyboard\isKeyPressed "D"
					updatePlayerControl "keyUp", Keyboard\isKeyPressed "K"
					updatePlayerControl "keyF", Keyboard\isKeyPressed "J"
					updatePlayerControl "keyE", Keyboard\isKeyPressed "E"

Director.entry\addChild with Node!
	\schedule ->
		:width, :height = App.visualSize
		panel! for panel in *fighterPanels

rangeAttackEnd = (name,playable)->
	playable.parent\stop! if name == "range"

UnitAction\add "range",
	priority: 3
	reaction: 10
	recovery: 0.1
	available: => true
	create: =>
		with @playable
			.speed = @attackSpeed
			\play "range"
			\slot "AnimationEnd", rangeAttackEnd
		once =>
			bulletDef = Store[@unitDef.bulletType]
			onAttack = ->
				with Bullet bulletDef,@
					.targetAllow = @targetAllow
					\slot "HitTarget",(bullet,target,pos)->
						entity = target.entity
						entity.hitPoint = pos
						entity.hitPower = @attackPower
						entity.hitFromRight = bullet.velocityX < 0
						factor = Data\getDamageFactor @damageType, target.defenceType
						damage = (@attackBase + @attackBonus) * (@attackFactor + factor)
						entity.hp -= damage
						bullet.hitStop = true
					\addTo @world,@order
			attackSpeed = @attackSpeed
			sleep 0.5*28.0/30.0/attackSpeed
			onAttack!
			while true do sleep!
	stop: =>
		@playable\slot("AnimationEnd")\remove rangeAttackEnd

BigArrow = with BulletDef!
	.tag = ""
	.endEffect = ""
	.lifeTime = 5
	.damageRadius = 0
	.highSpeedFix = false
	.gravity = Vec2 0,-10
	.face = Face "Image/patreon.clip|item_arrow", Vec2(-100,0), 2
	\setAsCircle 10
	\setVelocity 25,800

UnitAction\add "multiArrow",
	priority: 3
	reaction: 10
	recovery: 0.1
	available: => true
	create: =>
		with @playable
			.speed = @attackSpeed
			\play "range"
			\slot "AnimationEnd", rangeAttackEnd
		once =>
			onAttack = (angle,speed)->
				BigArrow\setVelocity angle,speed
				with Bullet BigArrow,@
					.targetAllow = @targetAllow
					\slot "HitTarget",(bullet,target,pos)->
						entity = target.entity
						entity.hitPoint = pos
						entity.hitPower = @attackPower
						entity.hitFromRight = bullet.velocityX < 0
						factor = Data\getDamageFactor @damageType, target.defenceType
						damage = (@attackBase + @attackBonus) * (@attackFactor + factor)
						entity.hp -= damage
						bullet.hitStop = true
					\addTo @world,@order
			attackSpeed = @attackSpeed
			sleep 30.0/60.0/attackSpeed
			onAttack 30,1100
			onAttack 10,1000
			onAttack -10,900
			onAttack -30,800
			onAttack -50,700
			while true do sleep!
	stop: =>
		@playable\slot("AnimationEnd")\remove rangeAttackEnd

UnitAction\add "fallOff",
	priority: 1
	reaction: 1
	recovery: 0
	available: => not @onSurface
	create: =>
		if @velocityY <= 0
			@entity.fallDown = true
			with @playable
				.speed = 2.5
				\play "idle"
		else @entity.fallDown = false
		(action)=>
			return true if @onSurface
			if not @entity.fallDown and @velocityY <= 0
				@entity.fallDown = true
				with @playable
					.speed = 2.5
					\play "idle"
			false

UnitAction\add "evade",
	priority: 10
	reaction: 10
	recovery: 0
	available: => true
	create: =>
		with @playable
			.speed = 1.0
			.recovery = 0.0
			\play "bevade"
		once =>
			group = @group
			@group = Data.groupHide
			dir = @faceRight and -1 or 1
			cycle 0.2,-> @velocityX = 800 * dir
			@group = group
			with @playable
				.speed = 1.0
				\play "idle"
			sleep 1
			true

spearAttackEnd = (name,playable)->
	playable.parent\stop! if name == "spear"

UnitAction\add "spearAttack",
	priority: 3
	reaction: 10
	recovery: 0.1
	available: => true
	create: =>
		with @playable
			.speed = 1.0
			.recovery = 0.2
			\play "spear"
			\slot "AnimationEnd", spearAttackEnd
		once =>
			sleep 50.0/60.0
			dir = @faceRight and 0 or -900
			origin = @position - Vec2(0,205) + Vec2(dir,0)
			size = Size 900,40
			world\query Rect(origin,size), (body)->
				if body.entity and Relation.Enemy == Data\getRelation(body,@)
					entity = body.entity
					entity.hitPoint = body.position
					entity.hitPower = @attackPower
					entity.hitFromRight = not @faceRight
					factor = Data\getDamageFactor @damageType, body.defenceType
					damage = (@attackBase + @attackBonus) * (@attackFactor + factor)
					entity.hp -= damage
				false
			while true do sleep!
	stop: =>
		@playable\slot("AnimationEnd")\remove spearAttackEnd

with Observer "Add", {"unitDef","position","order","group","faceRight"}
	\every =>
		{:unitDef,:position,:order,:group,:player,:faceRight,:charSet,:decisionTree} = @
		{:world} = Store
		func = UnitDefFuncs[unitDef]
		def = func!
		if charSet
			set = characters[charSet]
			actions = def.actions
			actionSet = {a,true for a in *actions}
			for slot in *itemSlots
				item = set[slot]
				continue unless item
				skill = itemSettings[item].skill
				if skill and not actionSet[skill]
					table.insert actions, skill
				attackRange = itemSettings[item].attackRange
				def.attackRange = attackRange if attackRange
			def.actions = actions
		def.decisionTree = decisionTree if decisionTree
		unit = with Unit def,world,@,position
			.group = group
			.order = order
			.faceRight = faceRight
			\addTo world
		updateModel unit.playable, characters[charSet] if charSet
		if player
			world.camera.followTarget = unit

with Observer "Change", {"hp","unit"}
	\every =>
		{:hp,:unit,:boss} = @
		{hp:lastHp} = @oldValues
		if hp < lastHp
			unit\start "cancel" if not boss and unit\isDoing "hit"
			if boss
				with Visual "Particle/bloodp.par"
					.position = @hitPoint
					\addTo world,unit.order
					\autoRemove!
					\start!
			if hp > 0
				unit\start "hit"
			else
				unit\start "hit"
				unit\start "fall"
				unit.group = Data.groupHide
				if @player
					playerGroup\each (p)=>
						if p and p.unit and p.hp > 0
							world.camera.followTarget = p.unit
							true
						else false

--world.showDebug = true
