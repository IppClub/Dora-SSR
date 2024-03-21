-- [yue]: Script/Game/Zombie Escape/Unit.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Dictionary = dora.Dictionary -- 1
local Vec2 = dora.Vec2 -- 1
local Size = dora.Size -- 1
local TargetAllow = _module_0.TargetAllow -- 1
local Array = dora.Array -- 1
local Store = Data.store -- 3
do -- 5
	local _with_0 = Dictionary() -- 5
	_with_0.linearAcceleration = Vec2(0, -10) -- 6
	_with_0.bodyType = "Dynamic" -- 7
	_with_0.scale = 5 -- 8
	_with_0.density = 1.0 -- 9
	_with_0.friction = 1.0 -- 10
	_with_0.restitution = 0.0 -- 11
	_with_0.playable = "model:Model/KidW" -- 12
	_with_0.size = Size(30, 110) -- 13
	_with_0.tag = "KidW" -- 14
	_with_0.sensity = 0.1 -- 15
	_with_0.move = 250 -- 16
	_with_0.moveSpeed = 1.0 -- 17
	_with_0.jump = 500 -- 18
	_with_0.detectDistance = 350 -- 19
	_with_0.hp = 5.0 -- 20
	_with_0.attackBase = 2.5 -- 21
	_with_0.attackDelay = 0.1 -- 22
	_with_0.attackEffectDelay = 0.1 -- 23
	_with_0.attackRange = Size(350, 150) -- 24
	_with_0.attackPower = Vec2(100, 100) -- 25
	_with_0.attackTarget = "Single" -- 26
	do -- 27
		local conf -- 28
		do -- 28
			local _with_1 = TargetAllow() -- 28
			_with_1.terrainAllowed = true -- 29
			_with_1:allow("Enemy", true) -- 30
			conf = _with_1 -- 28
		end -- 28
		_with_0.targetAllow = conf:toValue() -- 31
	end -- 31
	_with_0.damageType = 0 -- 32
	_with_0.defenceType = 0 -- 33
	_with_0.bulletType = "Bullet_KidW" -- 34
	_with_0.attackEffect = "" -- 35
	_with_0.hitEffect = "" -- 36
	_with_0.sndAttack = "" -- 37
	_with_0.sndFallen = "" -- 38
	_with_0.decisionTree = "AI_KidSearch" -- 39
	_with_0.usePreciseHit = false -- 40
	_with_0.actions = Array({ -- 42
		"walk", -- 42
		"turn", -- 43
		"rangeAttack", -- 44
		"idle", -- 45
		"cancel", -- 46
		"jump", -- 47
		"hit", -- 48
		"fall", -- 49
		"fallOff" -- 50
	}) -- 41
	Store["Unit_KidW"] = _with_0 -- 5
end -- 5
do -- 52
	local _with_0 = Dictionary() -- 52
	_with_0.linearAcceleration = Vec2(0, -10) -- 53
	_with_0.bodyType = "Dynamic" -- 54
	_with_0.scale = 5 -- 55
	_with_0.density = 1.0 -- 56
	_with_0.friction = 1.0 -- 57
	_with_0.restitution = 0.0 -- 58
	_with_0.playable = "model:Model/KidM" -- 59
	_with_0.size = Size(30, 110) -- 60
	_with_0.tag = "KidM" -- 61
	_with_0.sensity = 0.1 -- 62
	_with_0.move = 250 -- 63
	_with_0.moveSpeed = 1.0 -- 64
	_with_0.jump = 500 -- 65
	_with_0.detectDistance = 500 -- 66
	_with_0.hp = 5.0 -- 67
	_with_0.attackBase = 1.0 -- 68
	_with_0.attackDelay = 0.1 -- 69
	_with_0.attackEffectDelay = 0.1 -- 70
	_with_0.attackRange = Size(400, 100) -- 71
	_with_0.attackPower = Vec2(100, 0) -- 72
	_with_0.attackTarget = "Single" -- 73
	do -- 74
		local conf -- 75
		do -- 75
			local _with_1 = TargetAllow() -- 75
			_with_1.terrainAllowed = true -- 76
			_with_1:allow("Enemy", true) -- 77
			conf = _with_1 -- 75
		end -- 75
		_with_0.targetAllow = conf:toValue() -- 78
	end -- 78
	_with_0.damageType = 0 -- 79
	_with_0.defenceType = 0 -- 80
	_with_0.bulletType = "Bullet_KidM" -- 81
	_with_0.attackEffect = "" -- 82
	_with_0.hitEffect = "" -- 83
	_with_0.sndAttack = "" -- 84
	_with_0.sndFallen = "" -- 85
	_with_0.decisionTree = "AI_KidFollow" -- 86
	_with_0.usePreciseHit = false -- 87
	_with_0.actions = Array({ -- 89
		"walk", -- 89
		"turn", -- 90
		"rangeAttack", -- 91
		"idle", -- 92
		"cancel", -- 93
		"jump", -- 94
		"hit", -- 95
		"fall", -- 96
		"fallOff" -- 97
	}) -- 88
	Store["Unit_KidM"] = _with_0 -- 52
end -- 52
do -- 99
	local _with_0 = Dictionary() -- 99
	_with_0.linearAcceleration = Vec2(0, -10) -- 100
	_with_0.bodyType = "Dynamic" -- 101
	_with_0.scale = 5 -- 102
	_with_0.density = 1.0 -- 103
	_with_0.friction = 1.0 -- 104
	_with_0.restitution = 0.0 -- 105
	_with_0.playable = "model:Model/Zombie1" -- 106
	_with_0.size = Size(40, 110) -- 107
	_with_0.tag = "Zombie1" -- 108
	_with_0.sensity = 0.2 -- 109
	_with_0.move = 120 -- 110
	_with_0.moveSpeed = 1.0 -- 111
	_with_0.jump = 600 -- 112
	_with_0.detectDistance = 600 -- 113
	_with_0.hp = 5.0 -- 114
	_with_0.attackBase = 1 -- 115
	_with_0.attackDelay = 0.25 -- 116
	_with_0.attackEffectDelay = 0.1 -- 117
	_with_0.attackRange = Size(80, 50) -- 118
	_with_0.attackPower = Vec2(150, 100) -- 119
	_with_0.attackTarget = "Single" -- 120
	do -- 121
		local conf -- 122
		do -- 122
			local _with_1 = TargetAllow() -- 122
			_with_1.terrainAllowed = true -- 123
			_with_1:allow("Enemy", true) -- 124
			conf = _with_1 -- 122
		end -- 122
		_with_0.targetAllow = conf:toValue() -- 125
	end -- 125
	_with_0.damageType = 0 -- 126
	_with_0.defenceType = 0 -- 127
	_with_0.bulletType = "" -- 128
	_with_0.attackEffect = "" -- 129
	_with_0.hitEffect = "" -- 130
	_with_0.sndAttack = "" -- 131
	_with_0.sndFallen = "" -- 132
	_with_0.decisionTree = "AI_Zombie" -- 133
	_with_0.usePreciseHit = false -- 134
	_with_0.actions = Array({ -- 136
		"walk", -- 136
		"turn", -- 137
		"meleeAttack", -- 138
		"idle", -- 139
		"cancel", -- 140
		"jump", -- 141
		"hit", -- 142
		"fall", -- 143
		"groundEntrance", -- 144
		"fallOff" -- 145
	}) -- 135
	Store["Unit_Zombie1"] = _with_0 -- 99
end -- 99
local _with_0 = Dictionary() -- 147
_with_0.linearAcceleration = Vec2(0, -10) -- 148
_with_0.bodyType = "Dynamic" -- 149
_with_0.scale = 5 -- 150
_with_0.density = 1.0 -- 151
_with_0.friction = 1.0 -- 152
_with_0.restitution = 0.0 -- 153
_with_0.playable = "model:Model/Zombie2" -- 154
_with_0.size = Size(40, 110) -- 155
_with_0.tag = "Zombie2" -- 156
_with_0.sensity = 0.2 -- 157
_with_0.move = 60 -- 158
_with_0.moveSpeed = 1.0 -- 159
_with_0.jump = 500 -- 160
_with_0.detectDistance = 600 -- 161
_with_0.hp = 5.0 -- 162
_with_0.attackBase = 1 -- 163
_with_0.attackDelay = 0.4 -- 164
_with_0.attackEffectDelay = 0.1 -- 165
_with_0.attackRange = Size(150, 80) -- 166
_with_0.attackPower = Vec2(150, 100) -- 167
_with_0.attackTarget = "Multi" -- 168
do -- 169
	local conf -- 170
	do -- 170
		local _with_1 = TargetAllow() -- 170
		_with_1.terrainAllowed = true -- 171
		_with_1:allow("Enemy", true) -- 172
		conf = _with_1 -- 170
	end -- 170
	_with_0.targetAllow = conf:toValue() -- 173
end -- 173
_with_0.damageType = 0 -- 174
_with_0.defenceType = 0 -- 175
_with_0.bulletType = "" -- 176
_with_0.attackEffect = "" -- 177
_with_0.hitEffect = "" -- 178
_with_0.sndAttack = "" -- 179
_with_0.sndFallen = "" -- 180
_with_0.decisionTree = "AI_Zombie" -- 181
_with_0.usePreciseHit = false -- 182
_with_0.actions = Array({ -- 184
	"walk", -- 184
	"turn", -- 185
	"meleeAttack", -- 186
	"idle", -- 187
	"cancel", -- 188
	"jump", -- 189
	"hit", -- 190
	"fall", -- 191
	"groundEntrance", -- 192
	"fallOff" -- 193
}) -- 183
Store["Unit_Zombie2"] = _with_0 -- 147
