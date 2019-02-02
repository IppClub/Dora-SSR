Dorothy builtin.Platformer
{store:Store} = Data

Store["Flandre"] = with UnitDef!
	.bodyDef.linearAcceleration = Vec2 0,-10
	.static = false
	.scale = 2
	.density = 1.0
	.friction = 0.6
	.restitution = 0.0
	.model = "Model/flandre.model"
	.size = Size 84,186
	.tag = "Hero"
	.sensity = 0
	.move = 200
	.jump = 780
	.detectDistance = 0
	.maxHp = 8
	.attackBase = 1.0
	.attackDelay = 20.0*1.0/30.0
	.attackEffectDelay = 0.0
	.attackRange = Size 260+84/2,200
	.attackPower = Vec2 400,400
	.attackType = AttackType.Melee
	.attackTarget = AttackTarget.Multi
	.targetAllow = (with TargetAllow!
		.terrainAllowed = false
		\allow Relation.Enemy,true)
	.damageType = 0
	.defenceType = 0
	.bulletType = ""
	.attackEffect = ""
	.hitEffect = "Particle/blood.par"
	.name = "Flandre"
	.desc = ""
	.sndAttack = "Audio/f_att.wav"
	.sndFallen = ""
	.decisionTree = ""
	.usePreciseHit = true
	.actions = {
		"walk"
		"turn"
		"meleeAttack"
		"idle"
		"cancel"
		"jump"
		"hit"
		"fall"
		"fallOff"
		"pushSwitch"
		"strike"
		"wait"
	}

Store["Dorothy"] = with UnitDef!
	.bodyDef.linearAcceleration = Vec2 0,-10
	.static = false
	.scale = 2
	.density = 1.0
	.friction = 0.4
	.restitution = 0.0
	.model = "Model/dorothy.model"
	.size = Size 84,170
	.tag = "Hero"
	.sensity = 0
	.move = 150
	.jump = 600
	.detectDistance = 0
	.maxHp = 8
	.attackBase = 2.0
	.attackDelay = 18.0*1.0/30.0
	.attackEffectDelay = 0.0
	.attackRange = Size 500+84/2,100
	.attackPower = Vec2 300,300
	.attackType = AttackType.Range
	.attackTarget = AttackTarget.Single
	.targetAllow = (with TargetAllow!
		.terrainAllowed = true
		\allow Relation.Enemy,true)
	.damageType = 0
	.defenceType = 0
	.bulletType = "Arrow"
	.attackEffect = ""
	.hitEffect = "Particle/blood.par"
	.name = "Dorothy"
	.desc = ""
	.sndAttack = "Audio/d_att.wav"
	.sndFallen = ""
	.decisionTree = "HeroAI"
	.usePreciseHit = true
	.actions = {
		"walk"
		"turn"
		"rangeAttack"
		"idle"
		"cancel"
		"jump"
		"hit"
		"fall"
		"fallOff"
		"pushSwitch"
		"strike"
		"wait"
	}

Store["Villy"] = with UnitDef!
	.bodyDef.linearAcceleration = Vec2 0,-10
	.static = false
	.scale = 2
	.density = 1.0
	.friction = 0.4
	.restitution = 0.0
	.model = "Model/villy.model"
	.size = Size 84,186
	.tag = "Hero"
	.sensity = 0
	.move = 240
	.jump = 600
	.detectDistance = 0
	.maxHp = 8
	.attackBase = 1.0
	.attackDelay = 0.0
	.attackEffectDelay = 0.0
	.attackRange = Size 300+84/2,100
	.attackPower = Vec2 200,300
	.attackType = AttackType.Range
	.attackTarget = AttackTarget.Single
	.targetAllow = (with TargetAllow!
		.terrainAllowed = true
		\allow Relation.Enemy,true)
	.damageType = 0
	.defenceType = 0
	.bulletType = "Bubble"
	.attackEffect = ""
	.hitEffect = "Particle/blood.par"
	.name = "Villy"
	.desc = ""
	.sndAttack = "Audio/v_att.wav"
	.sndFallen = ""
	.decisionTree = ""
	.usePreciseHit = true
	.actions = {
		"walk"
		"turn"
		"villyAttack"
		"idle"
		"cancel"
		"jump"
		"hit"
		"fall"
		"fallOff"
		"pushSwitch"
		"strike"
		"wait"
	}

Store["BunnyP"] = with UnitDef!
	.bodyDef.linearAcceleration = Vec2 0,-10
	.static = false
	.scale = 2
	.density = 1.0
	.friction = 0.4
	.restitution = 0.0
	.model = "Model/bunnyp.model"
	.size = Size 132,128
	.tag = "Bunny"
	.sensity = 0
	.move = 150
	.jump = 600
	.detectDistance = 0
	.maxHp = 3
	.attackBase = 1.0
	.attackDelay = 20.0*1.0/60.0
	.attackEffectDelay = 0.0
	.attackRange = Size 60+132/2,80
	.attackPower = Vec2 400,400
	.attackType = AttackType.Melee
	.attackTarget = AttackTarget.Single
	.targetAllow = (with TargetAllow!
		.terrainAllowed = false
		\allow Relation.Enemy,true)
	.damageType = 0
	.defenceType = 0
	.bulletType = ""
	.attackEffect = ""
	.hitEffect = "Particle/blood.par"
	.name = "BunnyP"
	.desc = ""
	.sndAttack = "Audio/b_att.wav"
	.sndFallen = ""
	.decisionTree = ""
	.usePreciseHit = true
	.actions = {
		"walk"
		"turn"
		"meleeAttack"
		"idle"
		"cancel"
		"jump"
		"hit"
		"fall"
		"fallOff"
		"pushSwitch"
		"strike"
		"wait"
	}

Store["BunnyG"] = with UnitDef!
	.bodyDef.linearAcceleration = Vec2 0,-10
	.static = false
	.scale = 2
	.density = 1.0
	.friction = 0.4
	.restitution = 0.0
	.model = "Model/bunnyg.model"
	.size = Size 132,128
	.tag = "Bunny"
	.sensity = 0
	.move = 150
	.jump = 600
	.detectDistance = 0
	.maxHp = 3
	.attackBase = 1.0
	.attackDelay = 20.0*1.0/60.0
	.attackEffectDelay = 0.0
	.attackRange = Size 60+132/2,80
	.attackPower = Vec2 400,400
	.attackType = AttackType.Melee
	.attackTarget = AttackTarget.Single
	.targetAllow = (with TargetAllow!
		.terrainAllowed = false
		\allow Relation.Enemy,true)
	.damageType = 0
	.defenceType = 0
	.bulletType = ""
	.attackEffect = ""
	.hitEffect = "Particle/blood.par"
	.name = "BunnyG"
	.desc = ""
	.sndAttack = "Audio/b_att.wav"
	.sndFallen = ""
	.decisionTree = ""
	.usePreciseHit = true
	.actions = {
		"walk"
		"turn"
		"meleeAttack"
		"idle"
		"cancel"
		"jump"
		"hit"
		"fall"
		"fallOff"
		"pushSwitch"
		"strike"
		"wait"
	}

Store["BlockA"] = with UnitDef!
	.bodyDef.linearAcceleration = Vec2 0,-10
	.static = false
	.scale = 2
	.model = "Model/block1.model"
	.bodyDef\attachPolygon 90,90,1.0,0.4,0.0
	.tag = "Block"
	.maxHp = 2
	.hitEffect = "Particle/heart.par"
	.name = "BlockA"
	.actions = {
		"hit"
	}

Store["BlockB"] = with UnitDef!
	.bodyDef.linearAcceleration = Vec2 0,-10
	.static = false
	.scale = 2
	.model = "Model/block2.model"
	.bodyDef\attachPolygon 90,210,0.5,0.4,0.0
	.tag = "Block"
	.maxHp = 3
	.hitEffect = "Particle/heart.par"
	.name = "BlockB"
	.actions = {
		"hit"
	}

Store["BlockC"] = with UnitDef!
	.bodyDef.linearAcceleration = Vec2 0,-10
	.static = false
	.scale = 2
	.model = "Model/block3.model"
	.bodyDef\attachPolygon 450,90,0.5,0.4,0.0
	.tag = "Block"
	.maxHp = 4
	.hitEffect = "Particle/heart.par"
	.name = "BlockC"
	.actions = {
		"hit"
	}

Store["Switch"] = with UnitDef!
	.static = true
	.model = "Model/switch.model"
	.attackRange = Size 80,126
	.tag = "Switch"
	.name = "Switch"
	.decisionTree = "SwitchAI"
	.actions = {
		"waitUser"
		"pushed"
	}

Store["SwitchG"] = with UnitDef!
	.static = true
	.model = "Model/switch.model"
	.attackRange = Size 80,126
	.tag = "Switch"
	.name = "SwitchG"
	.decisionTree = "SwitchAI"
	.actions = {
		"waitUser"
		"pushed"
	}
