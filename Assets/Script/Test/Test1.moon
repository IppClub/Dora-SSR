Dorothy builtin.Platformer
import Path from require "Utils"

groundEntranceEnd = (name,model)->
	return unless name == "groundEntrance"
	model.parent\stop!

UnitAction\add "groundEntrance",
	6, -- priority
	999, -- reaction
	0, -- recovery,
	-> true, -- available,
	(owner)-> -- tolua_function_func_bool create,
		with owner
			.entity.lastGroup = .group
			.group = 0
			with .model
				.speed = 1
				.loop = false
				\slot "AnimationEnd",groundEntranceEnd
				\play "groundEntrance"
		-> false,
	(owner)-> -- tolua_function stop
		with owner
			.model\slot("AnimationEnd")\remove groundEntranceEnd
			.group = .entity.lastGroup
			.entity.lastGroup = nil
			.entity.entered = true

played = false
UnitAction\add "fallOff",
	1, -- priority
	0.2, -- reaction
	0, -- recovery,
	(owner)-> not owner.onSurface, -- available,
	(owner)-> -- create
		played = false
		with owner	
			if .velocityY <= 0
				played = true
				with .model
					.speed = 1
					.loop = false
					\play "fallOff"
		(owner,action)->
			with owner
				return true if .onSurface
				if not played and .model.currentAnimation ~= "fallOff" and .velocityY <= 0
					played = true
					with .model
						.speed = 1
						.loop = false
						\play "fallOff"
			false,
	(owner)-> -- stop
		owner.model\stop!

Data.cache["AI_Zombie1"] = Sel {
	Seq {
		Con -> not AI.self.entity.entered
		Act "groundEntrance"
	}
	Seq {
		Con -> AI.self.onSurface
		Sel {
			Seq {
				Con -> App.rand % 5 == 0
				Act "rangeAttack"
			}
			Act "walk"
		}
	}
	Act "idle"
}

Data.cache["AI_KidM"] = Act "idle"

Data.cache["AI_KidW"] = Sel {
	Seq {
		Con -> AI.self.onSurface
		Sel {
			Seq {
				Con -> App.rand % 5 == 0
				Act "jump"
			}
			Act "walk"
		}
	}
	Seq {
		Con -> not AI.self.onSurface
		Act "fallOff"
	}
	Act "idle"
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

Data.cache["Unit_Zombie1"] = with UnitDef!
	.static = false
	.scale = 5
	.density = 1.0
	.friction = 1.0
	.restitution = 0.0
	.model = "Model/Zombie1.model"
	.size = Size 15,26
	.tag = "Zombie1"
	.sensity = 0.2
	.move = 100
	.jump = 400
	.detectDistance = 300
	.maxHp = 5
	.attackBase = 20
	.attackDelay = 0.4
	.attackEffectDelay = 0.1
	.attackRange = Size 80,50
	.attackPower = Vec2 100,100
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
	.decisionTree = "AI_Zombie1"
	.usePreciseHit = false
	.actions = {
		"walk",
		"turn",
		"meleeAttack",
		"rangeAttack",
		"idle",
		"cancel",
		"jump",
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
	.size = Size 15,26
	.tag = "KidW"
	.sensity = 0.2
	.move = 100
	.jump = 800
	.detectDistance = 300
	.maxHp = 5
	.attackBase = 20
	.attackDelay = 0.4
	.attackEffectDelay = 0.1
	.attackRange = Size 80,50
	.attackPower = Vec2 100,100
	.attackType = AttackType.Range
	.attackTarget = AttackTarget.Single
	.targetAllow = (with TargetAllow!
		.terrainAllowed = true
		\allow Relation.Enemy,true)
	.damageType = 0
	.defenceType = 0
	.bulletType = "Bullet_Zombie"
	.attackEffect = ""
	.hitEffect = ""
	.name = "KidW"
	.desc = ""
	.sndAttack = ""
	.sndFallen = ""
	.decisionTree = "AI_KidW"
	.usePreciseHit = false
	.actions = {
		"walk",
		"turn",
		"meleeAttack",
		"rangeAttack",
		"idle",
		"cancel",
		"jump",
		"hit",
		"fall",
		"fallOff",
		"groundEntrance",
	}

world = with PlatformWorld!
	.showDebug = false
Data.cache["World"] = world

terrainDef = with BodyDef!
	.type = BodyType.Static
	\attachPolygon 800,10
	\attachPolygon Vec2(0,-50),1500,10

with Body terrainDef,world,Vec2.zero
	.group = Data.groupTerrain
	\addTo world

unit = with Unit "Unit_KidW","World",Entity!,Vec2 0,70
	.group = 1
	\addTo world
	.model\eachNode (sp)-> sp.filter = TextureFilter.Point
	\eachAction (action)-> action.recovery = 0

with Director.entry
	\addChild world
