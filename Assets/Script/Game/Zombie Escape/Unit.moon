Dorothy builtin.Platformer
{store:Store} = Data

Store["Unit_KidW"] = with UnitDef!
	.bodyDef.linearAcceleration = Vec2 0,-10
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
	.attackRange = Size 350,150
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

Store["Unit_KidM"] = with UnitDef!
	.bodyDef.linearAcceleration = Vec2 0,-10
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
	.attackBase = 1.0
	.attackDelay = 0.1
	.attackEffectDelay = 0.1
	.attackRange = Size 400,100
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

Store["Unit_Zombie1"] = with UnitDef!
	.bodyDef.linearAcceleration = Vec2 0,-10
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
	.attackDelay = 0.25
	.attackEffectDelay = 0.1
	.attackRange = Size 80,50
	.attackPower = Vec2 150,100
	.attackType = AttackType.Melee
	.attackTarget = AttackTarget.Single
	.targetAllow = (with TargetAllow!
		.terrainAllowed = true
		\allow Relation.Enemy,true)
	.damageType = 0
	.defenceType = 0
	.bulletType = ""
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
		"fallOff"
	}

Store["Unit_Zombie2"] = with UnitDef!
	.bodyDef.linearAcceleration = Vec2 0,-10
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
	.jump = 500
	.detectDistance = 600
	.maxHp = 5
	.attackBase = 1
	.attackDelay = 0.4
	.attackEffectDelay = 0.1
	.attackRange = Size 150,80
	.attackPower = Vec2 150,100
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
		"fallOff"
	}

