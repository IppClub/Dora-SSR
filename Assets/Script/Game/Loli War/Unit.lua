-- [yue]: Script/Game/Loli War/Unit.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Dictionary = dora.Dictionary -- 1
local Vec2 = dora.Vec2 -- 1
local Size = dora.Size -- 1
local TargetAllow = _module_0.TargetAllow -- 1
local Array = dora.Array -- 1
local BodyDef = dora.BodyDef -- 1
local Store = Data.store -- 3
do -- 5
	local _with_0 = Dictionary() -- 5
	_with_0.linearAcceleration = Vec2(0, -10) -- 6
	_with_0.bodyType = "Dynamic" -- 7
	_with_0.scale = 2 -- 8
	_with_0.density = 1.0 -- 9
	_with_0.friction = 0.6 -- 10
	_with_0.restitution = 0.0 -- 11
	_with_0.playable = "model:Model/flandre" -- 12
	_with_0.size = Size(84, 186) -- 13
	_with_0.tag = "Hero" -- 14
	_with_0.sensity = 0 -- 15
	_with_0.move = 200 -- 16
	_with_0.jump = 780 -- 17
	_with_0.detectDistance = 300 -- 18
	_with_0.hp = 8.0 -- 19
	_with_0.attackBase = 1.0 -- 20
	_with_0.attackSpeed = 1.0 -- 21
	_with_0.attackDelay = 20.0 * 1.0 / 30.0 -- 22
	_with_0.attackEffectDelay = 0.0 -- 23
	_with_0.attackRange = Size(260 + 84 / 2, 200) -- 24
	_with_0.attackPower = Vec2(400, 400) -- 25
	_with_0.attackBonus = 0 -- 26
	_with_0.attackFactor = 1.0 -- 27
	_with_0.attackTarget = "Multi" -- 28
	do -- 29
		local conf -- 30
		do -- 30
			local _with_1 = TargetAllow() -- 30
			_with_1.terrainAllowed = false -- 31
			_with_1:allow("Enemy", true) -- 32
			conf = _with_1 -- 30
		end -- 30
		_with_0.targetAllow = conf:toValue() -- 33
	end -- 33
	_with_0.damageType = 0 -- 34
	_with_0.defenceType = 0 -- 35
	_with_0.bulletType = "" -- 36
	_with_0.attackEffect = "" -- 37
	_with_0.hitEffect = "Particle/blood.par" -- 38
	_with_0.sndAttack = "Audio/f_att.wav" -- 39
	_with_0.sndFallen = "" -- 40
	_with_0.decisionTree = "" -- 41
	_with_0.usePreciseHit = true -- 42
	_with_0.actions = Array({ -- 44
		"walk", -- 44
		"turn", -- 45
		"meleeAttack", -- 46
		"idle", -- 47
		"cancel", -- 48
		"jump", -- 49
		"hit", -- 50
		"fall", -- 51
		"fallOff", -- 52
		"pushSwitch", -- 53
		"strike", -- 54
		"wait" -- 55
	}) -- 43
	Store["Flandre"] = _with_0 -- 5
end -- 5
do -- 58
	local _with_0 = Dictionary() -- 58
	_with_0.linearAcceleration = Vec2(0, -10) -- 59
	_with_0.bodyType = "Dynamic" -- 60
	_with_0.scale = 2 -- 61
	_with_0.density = 1.0 -- 62
	_with_0.friction = 0.4 -- 63
	_with_0.restitution = 0.0 -- 64
	_with_0.playable = "model:Model/dorothy" -- 65
	_with_0.size = Size(84, 170) -- 66
	_with_0.tag = "Hero" -- 67
	_with_0.sensity = 0 -- 68
	_with_0.move = 150 -- 69
	_with_0.jump = 600 -- 70
	_with_0.detectDistance = 300 -- 71
	_with_0.hp = 8.0 -- 72
	_with_0.attackBase = 2.0 -- 73
	_with_0.attackSpeed = 1.0 -- 74
	_with_0.attackDelay = 18.0 * 1.0 / 30.0 -- 75
	_with_0.attackEffectDelay = 0.0 -- 76
	_with_0.attackRange = Size(500 + 84 / 2, 100) -- 77
	_with_0.attackPower = Vec2(300, 300) -- 78
	_with_0.attackBonus = 0 -- 79
	_with_0.attackFactor = 1.0 -- 80
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
	_with_0.bulletType = "Arrow" -- 89
	_with_0.attackEffect = "" -- 90
	_with_0.hitEffect = "Particle/blood.par" -- 91
	_with_0.sndAttack = "Audio/d_att.wav" -- 92
	_with_0.sndFallen = "" -- 93
	_with_0.decisionTree = "HeroAI" -- 94
	_with_0.usePreciseHit = true -- 95
	_with_0.actions = Array({ -- 97
		"walk", -- 97
		"turn", -- 98
		"rangeAttack", -- 99
		"idle", -- 100
		"cancel", -- 101
		"jump", -- 102
		"hit", -- 103
		"fall", -- 104
		"fallOff", -- 105
		"pushSwitch", -- 106
		"strike", -- 107
		"wait" -- 108
	}) -- 96
	Store["Dorothy"] = _with_0 -- 58
end -- 58
do -- 111
	local _with_0 = Dictionary() -- 111
	_with_0.linearAcceleration = Vec2(0, -10) -- 112
	_with_0.bodyType = "Dynamic" -- 113
	_with_0.scale = 2 -- 114
	_with_0.density = 1.0 -- 115
	_with_0.friction = 0.4 -- 116
	_with_0.restitution = 0.0 -- 117
	_with_0.playable = "model:Model/villy" -- 118
	_with_0.size = Size(84, 186) -- 119
	_with_0.tag = "Hero" -- 120
	_with_0.sensity = 0 -- 121
	_with_0.move = 240 -- 122
	_with_0.jump = 600 -- 123
	_with_0.detectDistance = 300 -- 124
	_with_0.hp = 8.0 -- 125
	_with_0.attackBase = 1.0 -- 126
	_with_0.attackSpeed = 1.0 -- 127
	_with_0.attackDelay = 0.0 -- 128
	_with_0.attackEffectDelay = 0.0 -- 129
	_with_0.attackRange = Size(300 + 84 / 2, 100) -- 130
	_with_0.attackPower = Vec2(200, 300) -- 131
	_with_0.attackBonus = 0 -- 132
	_with_0.attackFactor = 1.0 -- 133
	_with_0.attackTarget = "Single" -- 134
	do -- 135
		local conf -- 136
		do -- 136
			local _with_1 = TargetAllow() -- 136
			_with_1.terrainAllowed = true -- 137
			_with_1:allow("Enemy", true) -- 138
			conf = _with_1 -- 136
		end -- 136
		_with_0.targetAllow = conf:toValue() -- 139
	end -- 139
	_with_0.damageType = 0 -- 140
	_with_0.defenceType = 0 -- 141
	_with_0.bulletType = "Bubble" -- 142
	_with_0.attackEffect = "" -- 143
	_with_0.hitEffect = "Particle/blood.par" -- 144
	_with_0.sndAttack = "Audio/v_att.wav" -- 145
	_with_0.sndFallen = "" -- 146
	_with_0.decisionTree = "" -- 147
	_with_0.usePreciseHit = true -- 148
	_with_0.actions = Array({ -- 150
		"walk", -- 150
		"turn", -- 151
		"villyAttack", -- 152
		"idle", -- 153
		"cancel", -- 154
		"jump", -- 155
		"hit", -- 156
		"fall", -- 157
		"fallOff", -- 158
		"pushSwitch", -- 159
		"strike", -- 160
		"wait" -- 161
	}) -- 149
	Store["Villy"] = _with_0 -- 111
end -- 111
do -- 164
	local _with_0 = Dictionary() -- 164
	_with_0.linearAcceleration = Vec2(0, -10) -- 165
	_with_0.bodyType = "Dynamic" -- 166
	_with_0.scale = 2 -- 167
	_with_0.density = 1.0 -- 168
	_with_0.friction = 0.4 -- 169
	_with_0.restitution = 0.0 -- 170
	_with_0.playable = "model:Model/bunnyp" -- 171
	_with_0.size = Size(132, 128) -- 172
	_with_0.tag = "Bunny" -- 173
	_with_0.sensity = 0 -- 174
	_with_0.move = 150 -- 175
	_with_0.jump = 600 -- 176
	_with_0.detectDistance = 0 -- 177
	_with_0.hp = 3.0 -- 178
	_with_0.attackBase = 1.0 -- 179
	_with_0.attackSpeed = 1.0 -- 180
	_with_0.attackDelay = 20.0 * 1.0 / 60.0 -- 181
	_with_0.attackEffectDelay = 0.0 -- 182
	_with_0.attackRange = Size(60 + 132 / 2, 80) -- 183
	_with_0.attackPower = Vec2(400, 400) -- 184
	_with_0.attackBonus = 0 -- 185
	_with_0.attackFactor = 1.0 -- 186
	_with_0.attackTarget = "Single" -- 187
	do -- 188
		local conf -- 189
		do -- 189
			local _with_1 = TargetAllow() -- 189
			_with_1.terrainAllowed = false -- 190
			_with_1:allow("Enemy", true) -- 191
			conf = _with_1 -- 189
		end -- 189
		_with_0.targetAllow = conf:toValue() -- 192
	end -- 192
	_with_0.damageType = 0 -- 193
	_with_0.defenceType = 0 -- 194
	_with_0.bulletType = "" -- 195
	_with_0.attackEffect = "" -- 196
	_with_0.hitEffect = "Particle/blood.par" -- 197
	_with_0.sndAttack = "Audio/b_att.wav" -- 198
	_with_0.sndFallen = "" -- 199
	_with_0.decisionTree = "" -- 200
	_with_0.usePreciseHit = true -- 201
	_with_0.actions = Array({ -- 203
		"walk", -- 203
		"turn", -- 204
		"meleeAttack", -- 205
		"idle", -- 206
		"cancel", -- 207
		"jump", -- 208
		"hit", -- 209
		"fall", -- 210
		"fallOff", -- 211
		"pushSwitch", -- 212
		"strike", -- 213
		"wait" -- 214
	}) -- 202
	Store["BunnyP"] = _with_0 -- 164
end -- 164
do -- 217
	local _with_0 = Dictionary() -- 217
	_with_0.linearAcceleration = Vec2(0, -10) -- 218
	_with_0.bodyType = "Dynamic" -- 219
	_with_0.scale = 2 -- 220
	_with_0.density = 1.0 -- 221
	_with_0.friction = 0.4 -- 222
	_with_0.restitution = 0.0 -- 223
	_with_0.playable = "model:Model/bunnyg" -- 224
	_with_0.size = Size(132, 128) -- 225
	_with_0.tag = "Bunny" -- 226
	_with_0.sensity = 0 -- 227
	_with_0.move = 150 -- 228
	_with_0.jump = 600 -- 229
	_with_0.detectDistance = 0 -- 230
	_with_0.hp = 3.0 -- 231
	_with_0.attackBase = 1.0 -- 232
	_with_0.attackSpeed = 1.0 -- 233
	_with_0.attackDelay = 20.0 * 1.0 / 60.0 -- 234
	_with_0.attackEffectDelay = 0.0 -- 235
	_with_0.attackRange = Size(60 + 132 / 2, 80) -- 236
	_with_0.attackPower = Vec2(400, 400) -- 237
	_with_0.attackBonus = 0 -- 238
	_with_0.attackFactor = 1.0 -- 239
	_with_0.attackTarget = "Single" -- 240
	do -- 241
		local conf -- 242
		do -- 242
			local _with_1 = TargetAllow() -- 242
			_with_1.terrainAllowed = false -- 243
			_with_1:allow("Enemy", true) -- 244
			conf = _with_1 -- 242
		end -- 242
		_with_0.targetAllow = conf:toValue() -- 245
	end -- 245
	_with_0.damageType = 0 -- 246
	_with_0.defenceType = 0 -- 247
	_with_0.bulletType = "" -- 248
	_with_0.attackEffect = "" -- 249
	_with_0.hitEffect = "Particle/blood.par" -- 250
	_with_0.sndAttack = "Audio/b_att.wav" -- 251
	_with_0.sndFallen = "" -- 252
	_with_0.decisionTree = "" -- 253
	_with_0.usePreciseHit = true -- 254
	_with_0.actions = Array({ -- 256
		"walk", -- 256
		"turn", -- 257
		"meleeAttack", -- 258
		"idle", -- 259
		"cancel", -- 260
		"jump", -- 261
		"hit", -- 262
		"fall", -- 263
		"fallOff", -- 264
		"pushSwitch", -- 265
		"strike", -- 266
		"wait" -- 267
	}) -- 255
	Store["BunnyG"] = _with_0 -- 217
end -- 217
do -- 270
	local _with_0 = Dictionary() -- 270
	_with_0.scale = 2 -- 271
	_with_0.playable = "model:Model/block1" -- 272
	do -- 273
		local _with_1 = BodyDef() -- 273
		_with_1.linearAcceleration = Vec2(0, -10) -- 274
		_with_1.type = "Dynamic" -- 275
		_with_1:attachPolygon(90, 90, 1.0, 0.4, 0.0) -- 276
		_with_0.bodyDef = _with_1 -- 273
	end -- 273
	_with_0.tag = "Block" -- 277
	_with_0.hp = 2.0 -- 278
	_with_0.hitEffect = "Particle/heart.par" -- 279
	_with_0.actions = Array({ -- 280
		"hit" -- 280
	}) -- 280
	Store["BlockA"] = _with_0 -- 270
end -- 270
do -- 282
	local _with_0 = Dictionary() -- 282
	_with_0.scale = 2 -- 283
	_with_0.playable = "model:Model/block2" -- 284
	do -- 285
		local _with_1 = BodyDef() -- 285
		_with_1.linearAcceleration = Vec2(0, -10) -- 286
		_with_1.type = "Dynamic" -- 287
		_with_1:attachPolygon(90, 210, 0.5, 0.4, 0.0) -- 288
		_with_0.bodyDef = _with_1 -- 285
	end -- 285
	_with_0.tag = "Block" -- 289
	_with_0.hp = 3.0 -- 290
	_with_0.hitEffect = "Particle/heart.par" -- 291
	_with_0.actions = Array({ -- 292
		"hit" -- 292
	}) -- 292
	Store["BlockB"] = _with_0 -- 282
end -- 282
do -- 294
	local _with_0 = Dictionary() -- 294
	_with_0.scale = 2 -- 295
	_with_0.playable = "model:Model/block3" -- 296
	do -- 297
		local _with_1 = BodyDef() -- 297
		_with_1.linearAcceleration = Vec2(0, -10) -- 298
		_with_1.type = "Dynamic" -- 299
		_with_1:attachPolygon(450, 90, 0.5, 0.4, 0.0) -- 300
		_with_0.bodyDef = _with_1 -- 297
	end -- 297
	_with_0.tag = "Block" -- 301
	_with_0.hp = 4.0 -- 302
	_with_0.hitEffect = "Particle/heart.par" -- 303
	_with_0.actions = Array({ -- 304
		"hit" -- 304
	}) -- 304
	Store["BlockC"] = _with_0 -- 294
end -- 294
do -- 306
	local _with_0 = Dictionary() -- 306
	_with_0.bodyType = "Static" -- 307
	_with_0.playable = "model:Model/switch" -- 308
	_with_0.attackRange = Size(80, 126) -- 309
	_with_0.tag = "Switch" -- 310
	_with_0.decisionTree = "SwitchAI" -- 311
	_with_0.actions = Array({ -- 312
		"waitUser", -- 312
		"pushed" -- 312
	}) -- 312
	Store["Switch"] = _with_0 -- 306
end -- 306
local _with_0 = Dictionary() -- 314
_with_0.bodyType = "Static" -- 315
_with_0.playable = "model:Model/switch" -- 316
_with_0.attackRange = Size(80, 126) -- 317
_with_0.tag = "Switch" -- 318
_with_0.decisionTree = "SwitchAI" -- 319
_with_0.actions = Array({ -- 320
	"waitUser", -- 320
	"pushed" -- 320
}) -- 320
Store["SwitchG"] = _with_0 -- 314
