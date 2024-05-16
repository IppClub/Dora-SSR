-- [yue]: Script/Game/Zombie Escape/Unit.yue
local _module_0 = Dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Dictionary = Dora.Dictionary -- 1
local Vec2 = Dora.Vec2 -- 1
local Size = Dora.Size -- 1
local TargetAllow = _module_0.TargetAllow -- 1
local Array = Dora.Array -- 1
local Store = Data.store -- 11
do -- 13
	local _with_0 = Dictionary() -- 13
	_with_0.linearAcceleration = Vec2(0, -10) -- 14
	_with_0.bodyType = "Dynamic" -- 15
	_with_0.scale = 5 -- 16
	_with_0.density = 1.0 -- 17
	_with_0.friction = 1.0 -- 18
	_with_0.restitution = 0.0 -- 19
	_with_0.playable = "model:Model/KidW" -- 20
	_with_0.size = Size(30, 110) -- 21
	_with_0.tag = "KidW" -- 22
	_with_0.sensity = 0.1 -- 23
	_with_0.move = 250 -- 24
	_with_0.moveSpeed = 1.0 -- 25
	_with_0.jump = 500 -- 26
	_with_0.detectDistance = 350 -- 27
	_with_0.hp = 5.0 -- 28
	_with_0.attackBase = 2.5 -- 29
	_with_0.attackDelay = 0.1 -- 30
	_with_0.attackEffectDelay = 0.1 -- 31
	_with_0.attackRange = Size(350, 150) -- 32
	_with_0.attackPower = Vec2(100, 100) -- 33
	_with_0.attackTarget = "Single" -- 34
	do -- 35
		local conf -- 36
		do -- 36
			local _with_1 = TargetAllow() -- 36
			_with_1.terrainAllowed = true -- 37
			_with_1:allow("Enemy", true) -- 38
			conf = _with_1 -- 36
		end -- 36
		_with_0.targetAllow = conf:toValue() -- 39
	end -- 39
	_with_0.damageType = 0 -- 40
	_with_0.defenceType = 0 -- 41
	_with_0.bulletType = "Bullet_KidW" -- 42
	_with_0.attackEffect = "" -- 43
	_with_0.hitEffect = "" -- 44
	_with_0.sndAttack = "" -- 45
	_with_0.sndFallen = "" -- 46
	_with_0.decisionTree = "AI_KidSearch" -- 47
	_with_0.usePreciseHit = false -- 48
	_with_0.actions = Array({ -- 50
		"walk", -- 50
		"turn", -- 51
		"rangeAttack", -- 52
		"idle", -- 53
		"cancel", -- 54
		"jump", -- 55
		"hit", -- 56
		"fall", -- 57
		"fallOff" -- 58
	}) -- 49
	Store["Unit_KidW"] = _with_0 -- 13
end -- 13
do -- 60
	local _with_0 = Dictionary() -- 60
	_with_0.linearAcceleration = Vec2(0, -10) -- 61
	_with_0.bodyType = "Dynamic" -- 62
	_with_0.scale = 5 -- 63
	_with_0.density = 1.0 -- 64
	_with_0.friction = 1.0 -- 65
	_with_0.restitution = 0.0 -- 66
	_with_0.playable = "model:Model/KidM" -- 67
	_with_0.size = Size(30, 110) -- 68
	_with_0.tag = "KidM" -- 69
	_with_0.sensity = 0.1 -- 70
	_with_0.move = 250 -- 71
	_with_0.moveSpeed = 1.0 -- 72
	_with_0.jump = 500 -- 73
	_with_0.detectDistance = 500 -- 74
	_with_0.hp = 5.0 -- 75
	_with_0.attackBase = 1.0 -- 76
	_with_0.attackDelay = 0.1 -- 77
	_with_0.attackEffectDelay = 0.1 -- 78
	_with_0.attackRange = Size(400, 100) -- 79
	_with_0.attackPower = Vec2(100, 0) -- 80
	_with_0.attackTarget = "Single" -- 81
	do -- 82
		local conf -- 83
		do -- 83
			local _with_1 = TargetAllow() -- 83
			_with_1.terrainAllowed = true -- 84
			_with_1:allow("Enemy", true) -- 85
			conf = _with_1 -- 83
		end -- 83
		_with_0.targetAllow = conf:toValue() -- 86
	end -- 86
	_with_0.damageType = 0 -- 87
	_with_0.defenceType = 0 -- 88
	_with_0.bulletType = "Bullet_KidM" -- 89
	_with_0.attackEffect = "" -- 90
	_with_0.hitEffect = "" -- 91
	_with_0.sndAttack = "" -- 92
	_with_0.sndFallen = "" -- 93
	_with_0.decisionTree = "AI_KidFollow" -- 94
	_with_0.usePreciseHit = false -- 95
	_with_0.actions = Array({ -- 97
		"walk", -- 97
		"turn", -- 98
		"rangeAttack", -- 99
		"idle", -- 100
		"cancel", -- 101
		"jump", -- 102
		"hit", -- 103
		"fall", -- 104
		"fallOff" -- 105
	}) -- 96
	Store["Unit_KidM"] = _with_0 -- 60
end -- 60
do -- 107
	local _with_0 = Dictionary() -- 107
	_with_0.linearAcceleration = Vec2(0, -10) -- 108
	_with_0.bodyType = "Dynamic" -- 109
	_with_0.scale = 5 -- 110
	_with_0.density = 1.0 -- 111
	_with_0.friction = 1.0 -- 112
	_with_0.restitution = 0.0 -- 113
	_with_0.playable = "model:Model/Zombie1" -- 114
	_with_0.size = Size(40, 110) -- 115
	_with_0.tag = "Zombie1" -- 116
	_with_0.sensity = 0.2 -- 117
	_with_0.move = 120 -- 118
	_with_0.moveSpeed = 1.0 -- 119
	_with_0.jump = 600 -- 120
	_with_0.detectDistance = 600 -- 121
	_with_0.hp = 5.0 -- 122
	_with_0.attackBase = 1 -- 123
	_with_0.attackDelay = 0.25 -- 124
	_with_0.attackEffectDelay = 0.1 -- 125
	_with_0.attackRange = Size(80, 50) -- 126
	_with_0.attackPower = Vec2(150, 100) -- 127
	_with_0.attackTarget = "Single" -- 128
	do -- 129
		local conf -- 130
		do -- 130
			local _with_1 = TargetAllow() -- 130
			_with_1.terrainAllowed = true -- 131
			_with_1:allow("Enemy", true) -- 132
			conf = _with_1 -- 130
		end -- 130
		_with_0.targetAllow = conf:toValue() -- 133
	end -- 133
	_with_0.damageType = 0 -- 134
	_with_0.defenceType = 0 -- 135
	_with_0.bulletType = "" -- 136
	_with_0.attackEffect = "" -- 137
	_with_0.hitEffect = "" -- 138
	_with_0.sndAttack = "" -- 139
	_with_0.sndFallen = "" -- 140
	_with_0.decisionTree = "AI_Zombie" -- 141
	_with_0.usePreciseHit = false -- 142
	_with_0.actions = Array({ -- 144
		"walk", -- 144
		"turn", -- 145
		"meleeAttack", -- 146
		"idle", -- 147
		"cancel", -- 148
		"jump", -- 149
		"hit", -- 150
		"fall", -- 151
		"groundEntrance", -- 152
		"fallOff" -- 153
	}) -- 143
	Store["Unit_Zombie1"] = _with_0 -- 107
end -- 107
local _with_0 = Dictionary() -- 155
_with_0.linearAcceleration = Vec2(0, -10) -- 156
_with_0.bodyType = "Dynamic" -- 157
_with_0.scale = 5 -- 158
_with_0.density = 1.0 -- 159
_with_0.friction = 1.0 -- 160
_with_0.restitution = 0.0 -- 161
_with_0.playable = "model:Model/Zombie2" -- 162
_with_0.size = Size(40, 110) -- 163
_with_0.tag = "Zombie2" -- 164
_with_0.sensity = 0.2 -- 165
_with_0.move = 60 -- 166
_with_0.moveSpeed = 1.0 -- 167
_with_0.jump = 500 -- 168
_with_0.detectDistance = 600 -- 169
_with_0.hp = 5.0 -- 170
_with_0.attackBase = 1 -- 171
_with_0.attackDelay = 0.4 -- 172
_with_0.attackEffectDelay = 0.1 -- 173
_with_0.attackRange = Size(150, 80) -- 174
_with_0.attackPower = Vec2(150, 100) -- 175
_with_0.attackTarget = "Multi" -- 176
do -- 177
	local conf -- 178
	do -- 178
		local _with_1 = TargetAllow() -- 178
		_with_1.terrainAllowed = true -- 179
		_with_1:allow("Enemy", true) -- 180
		conf = _with_1 -- 178
	end -- 178
	_with_0.targetAllow = conf:toValue() -- 181
end -- 181
_with_0.damageType = 0 -- 182
_with_0.defenceType = 0 -- 183
_with_0.bulletType = "" -- 184
_with_0.attackEffect = "" -- 185
_with_0.hitEffect = "" -- 186
_with_0.sndAttack = "" -- 187
_with_0.sndFallen = "" -- 188
_with_0.decisionTree = "AI_Zombie" -- 189
_with_0.usePreciseHit = false -- 190
_with_0.actions = Array({ -- 192
	"walk", -- 192
	"turn", -- 193
	"meleeAttack", -- 194
	"idle", -- 195
	"cancel", -- 196
	"jump", -- 197
	"hit", -- 198
	"fall", -- 199
	"groundEntrance", -- 200
	"fallOff" -- 201
}) -- 191
Store["Unit_Zombie2"] = _with_0 -- 155
