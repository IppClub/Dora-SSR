-- [yue]: Unit.yue
local _module_0 = Dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Dictionary = Dora.Dictionary -- 1
local Vec2 = Dora.Vec2 -- 1
local Size = Dora.Size -- 1
local TargetAllow = _module_0.TargetAllow -- 1
local Array = Dora.Array -- 1
local BodyDef = Dora.BodyDef -- 1
local Store = Data.store -- 11
do -- 13
	local _with_0 = Dictionary() -- 13
	_with_0.linearAcceleration = Vec2(0, -10) -- 14
	_with_0.bodyType = "Dynamic" -- 15
	_with_0.scale = 2 -- 16
	_with_0.density = 1.0 -- 17
	_with_0.friction = 0.6 -- 18
	_with_0.restitution = 0.0 -- 19
	_with_0.playable = "model:Model/flandre" -- 20
	_with_0.size = Size(84, 186) -- 21
	_with_0.tag = "Hero" -- 22
	_with_0.sensity = 0 -- 23
	_with_0.move = 200 -- 24
	_with_0.jump = 780 -- 25
	_with_0.detectDistance = 300 -- 26
	_with_0.hp = 8.0 -- 27
	_with_0.attackBase = 1.0 -- 28
	_with_0.attackSpeed = 1.0 -- 29
	_with_0.attackDelay = 20.0 * 1.0 / 30.0 -- 30
	_with_0.attackEffectDelay = 0.0 -- 31
	_with_0.attackRange = Size(260 + 84 / 2, 200) -- 32
	_with_0.attackPower = Vec2(400, 400) -- 33
	_with_0.attackBonus = 0 -- 34
	_with_0.attackFactor = 1.0 -- 35
	_with_0.attackTarget = "Multi" -- 36
	do -- 37
		local conf -- 38
		do -- 38
			local _with_1 = TargetAllow() -- 38
			_with_1.terrainAllowed = false -- 39
			_with_1:allow("Enemy", true) -- 40
			conf = _with_1 -- 38
		end -- 38
		_with_0.targetAllow = conf:toValue() -- 41
	end -- 41
	_with_0.damageType = 0 -- 42
	_with_0.defenceType = 0 -- 43
	_with_0.bulletType = "" -- 44
	_with_0.attackEffect = "" -- 45
	_with_0.hitEffect = "Particle/blood.par" -- 46
	_with_0.sndAttack = "Audio/f_att.wav" -- 47
	_with_0.sndFallen = "" -- 48
	_with_0.decisionTree = "" -- 49
	_with_0.usePreciseHit = true -- 50
	_with_0.actions = Array({ -- 52
		"walk", -- 52
		"turn", -- 53
		"meleeAttack", -- 54
		"idle", -- 55
		"cancel", -- 56
		"jump", -- 57
		"hit", -- 58
		"fall", -- 59
		"fallOff", -- 60
		"pushSwitch", -- 61
		"strike", -- 62
		"wait" -- 63
	}) -- 51
	Store["Flandre"] = _with_0 -- 13
end -- 13
do -- 66
	local _with_0 = Dictionary() -- 66
	_with_0.linearAcceleration = Vec2(0, -10) -- 67
	_with_0.bodyType = "Dynamic" -- 68
	_with_0.scale = 2 -- 69
	_with_0.density = 1.0 -- 70
	_with_0.friction = 0.4 -- 71
	_with_0.restitution = 0.0 -- 72
	_with_0.playable = "model:Model/dorothy" -- 73
	_with_0.size = Size(84, 170) -- 74
	_with_0.tag = "Hero" -- 75
	_with_0.sensity = 0 -- 76
	_with_0.move = 150 -- 77
	_with_0.jump = 600 -- 78
	_with_0.detectDistance = 300 -- 79
	_with_0.hp = 8.0 -- 80
	_with_0.attackBase = 2.0 -- 81
	_with_0.attackSpeed = 1.0 -- 82
	_with_0.attackDelay = 18.0 * 1.0 / 30.0 -- 83
	_with_0.attackEffectDelay = 0.0 -- 84
	_with_0.attackRange = Size(500 + 84 / 2, 100) -- 85
	_with_0.attackPower = Vec2(300, 300) -- 86
	_with_0.attackBonus = 0 -- 87
	_with_0.attackFactor = 1.0 -- 88
	_with_0.attackTarget = "Single" -- 89
	do -- 90
		local conf -- 91
		do -- 91
			local _with_1 = TargetAllow() -- 91
			_with_1.terrainAllowed = true -- 92
			_with_1:allow("Enemy", true) -- 93
			conf = _with_1 -- 91
		end -- 91
		_with_0.targetAllow = conf:toValue() -- 94
	end -- 94
	_with_0.damageType = 0 -- 95
	_with_0.defenceType = 0 -- 96
	_with_0.bulletType = "Arrow" -- 97
	_with_0.attackEffect = "" -- 98
	_with_0.hitEffect = "Particle/blood.par" -- 99
	_with_0.sndAttack = "Audio/d_att.wav" -- 100
	_with_0.sndFallen = "" -- 101
	_with_0.decisionTree = "HeroAI" -- 102
	_with_0.usePreciseHit = true -- 103
	_with_0.actions = Array({ -- 105
		"walk", -- 105
		"turn", -- 106
		"rangeAttack", -- 107
		"idle", -- 108
		"cancel", -- 109
		"jump", -- 110
		"hit", -- 111
		"fall", -- 112
		"fallOff", -- 113
		"pushSwitch", -- 114
		"strike", -- 115
		"wait" -- 116
	}) -- 104
	Store["Dorothy"] = _with_0 -- 66
end -- 66
do -- 119
	local _with_0 = Dictionary() -- 119
	_with_0.linearAcceleration = Vec2(0, -10) -- 120
	_with_0.bodyType = "Dynamic" -- 121
	_with_0.scale = 2 -- 122
	_with_0.density = 1.0 -- 123
	_with_0.friction = 0.4 -- 124
	_with_0.restitution = 0.0 -- 125
	_with_0.playable = "model:Model/villy" -- 126
	_with_0.size = Size(84, 186) -- 127
	_with_0.tag = "Hero" -- 128
	_with_0.sensity = 0 -- 129
	_with_0.move = 240 -- 130
	_with_0.jump = 600 -- 131
	_with_0.detectDistance = 300 -- 132
	_with_0.hp = 8.0 -- 133
	_with_0.attackBase = 1.0 -- 134
	_with_0.attackSpeed = 1.0 -- 135
	_with_0.attackDelay = 0.0 -- 136
	_with_0.attackEffectDelay = 0.0 -- 137
	_with_0.attackRange = Size(300 + 84 / 2, 100) -- 138
	_with_0.attackPower = Vec2(200, 300) -- 139
	_with_0.attackBonus = 0 -- 140
	_with_0.attackFactor = 1.0 -- 141
	_with_0.attackTarget = "Single" -- 142
	do -- 143
		local conf -- 144
		do -- 144
			local _with_1 = TargetAllow() -- 144
			_with_1.terrainAllowed = true -- 145
			_with_1:allow("Enemy", true) -- 146
			conf = _with_1 -- 144
		end -- 144
		_with_0.targetAllow = conf:toValue() -- 147
	end -- 147
	_with_0.damageType = 0 -- 148
	_with_0.defenceType = 0 -- 149
	_with_0.bulletType = "Bubble" -- 150
	_with_0.attackEffect = "" -- 151
	_with_0.hitEffect = "Particle/blood.par" -- 152
	_with_0.sndAttack = "Audio/v_att.wav" -- 153
	_with_0.sndFallen = "" -- 154
	_with_0.decisionTree = "" -- 155
	_with_0.usePreciseHit = true -- 156
	_with_0.actions = Array({ -- 158
		"walk", -- 158
		"turn", -- 159
		"villyAttack", -- 160
		"idle", -- 161
		"cancel", -- 162
		"jump", -- 163
		"hit", -- 164
		"fall", -- 165
		"fallOff", -- 166
		"pushSwitch", -- 167
		"strike", -- 168
		"wait" -- 169
	}) -- 157
	Store["Villy"] = _with_0 -- 119
end -- 119
do -- 172
	local _with_0 = Dictionary() -- 172
	_with_0.linearAcceleration = Vec2(0, -10) -- 173
	_with_0.bodyType = "Dynamic" -- 174
	_with_0.scale = 2 -- 175
	_with_0.density = 1.0 -- 176
	_with_0.friction = 0.4 -- 177
	_with_0.restitution = 0.0 -- 178
	_with_0.playable = "model:Model/bunnyp" -- 179
	_with_0.size = Size(132, 128) -- 180
	_with_0.tag = "Bunny" -- 181
	_with_0.sensity = 0 -- 182
	_with_0.move = 150 -- 183
	_with_0.jump = 600 -- 184
	_with_0.detectDistance = 0 -- 185
	_with_0.hp = 3.0 -- 186
	_with_0.attackBase = 1.0 -- 187
	_with_0.attackSpeed = 1.0 -- 188
	_with_0.attackDelay = 20.0 * 1.0 / 60.0 -- 189
	_with_0.attackEffectDelay = 0.0 -- 190
	_with_0.attackRange = Size(60 + 132 / 2, 80) -- 191
	_with_0.attackPower = Vec2(400, 400) -- 192
	_with_0.attackBonus = 0 -- 193
	_with_0.attackFactor = 1.0 -- 194
	_with_0.attackTarget = "Single" -- 195
	do -- 196
		local conf -- 197
		do -- 197
			local _with_1 = TargetAllow() -- 197
			_with_1.terrainAllowed = false -- 198
			_with_1:allow("Enemy", true) -- 199
			conf = _with_1 -- 197
		end -- 197
		_with_0.targetAllow = conf:toValue() -- 200
	end -- 200
	_with_0.damageType = 0 -- 201
	_with_0.defenceType = 0 -- 202
	_with_0.bulletType = "" -- 203
	_with_0.attackEffect = "" -- 204
	_with_0.hitEffect = "Particle/blood.par" -- 205
	_with_0.sndAttack = "Audio/b_att.wav" -- 206
	_with_0.sndFallen = "" -- 207
	_with_0.decisionTree = "" -- 208
	_with_0.usePreciseHit = true -- 209
	_with_0.actions = Array({ -- 211
		"walk", -- 211
		"turn", -- 212
		"meleeAttack", -- 213
		"idle", -- 214
		"cancel", -- 215
		"jump", -- 216
		"hit", -- 217
		"fall", -- 218
		"fallOff", -- 219
		"pushSwitch", -- 220
		"strike", -- 221
		"wait" -- 222
	}) -- 210
	Store["BunnyP"] = _with_0 -- 172
end -- 172
do -- 225
	local _with_0 = Dictionary() -- 225
	_with_0.linearAcceleration = Vec2(0, -10) -- 226
	_with_0.bodyType = "Dynamic" -- 227
	_with_0.scale = 2 -- 228
	_with_0.density = 1.0 -- 229
	_with_0.friction = 0.4 -- 230
	_with_0.restitution = 0.0 -- 231
	_with_0.playable = "model:Model/bunnyg" -- 232
	_with_0.size = Size(132, 128) -- 233
	_with_0.tag = "Bunny" -- 234
	_with_0.sensity = 0 -- 235
	_with_0.move = 150 -- 236
	_with_0.jump = 600 -- 237
	_with_0.detectDistance = 0 -- 238
	_with_0.hp = 3.0 -- 239
	_with_0.attackBase = 1.0 -- 240
	_with_0.attackSpeed = 1.0 -- 241
	_with_0.attackDelay = 20.0 * 1.0 / 60.0 -- 242
	_with_0.attackEffectDelay = 0.0 -- 243
	_with_0.attackRange = Size(60 + 132 / 2, 80) -- 244
	_with_0.attackPower = Vec2(400, 400) -- 245
	_with_0.attackBonus = 0 -- 246
	_with_0.attackFactor = 1.0 -- 247
	_with_0.attackTarget = "Single" -- 248
	do -- 249
		local conf -- 250
		do -- 250
			local _with_1 = TargetAllow() -- 250
			_with_1.terrainAllowed = false -- 251
			_with_1:allow("Enemy", true) -- 252
			conf = _with_1 -- 250
		end -- 250
		_with_0.targetAllow = conf:toValue() -- 253
	end -- 253
	_with_0.damageType = 0 -- 254
	_with_0.defenceType = 0 -- 255
	_with_0.bulletType = "" -- 256
	_with_0.attackEffect = "" -- 257
	_with_0.hitEffect = "Particle/blood.par" -- 258
	_with_0.sndAttack = "Audio/b_att.wav" -- 259
	_with_0.sndFallen = "" -- 260
	_with_0.decisionTree = "" -- 261
	_with_0.usePreciseHit = true -- 262
	_with_0.actions = Array({ -- 264
		"walk", -- 264
		"turn", -- 265
		"meleeAttack", -- 266
		"idle", -- 267
		"cancel", -- 268
		"jump", -- 269
		"hit", -- 270
		"fall", -- 271
		"fallOff", -- 272
		"pushSwitch", -- 273
		"strike", -- 274
		"wait" -- 275
	}) -- 263
	Store["BunnyG"] = _with_0 -- 225
end -- 225
do -- 278
	local _with_0 = Dictionary() -- 278
	_with_0.scale = 2 -- 279
	_with_0.playable = "model:Model/block1" -- 280
	do -- 281
		local _with_1 = BodyDef() -- 281
		_with_1.linearAcceleration = Vec2(0, -10) -- 282
		_with_1.type = "Dynamic" -- 283
		_with_1:attachPolygon(90, 90, 1.0, 0.4, 0.0) -- 284
		_with_0.bodyDef = _with_1 -- 281
	end -- 281
	_with_0.tag = "Block" -- 285
	_with_0.hp = 2.0 -- 286
	_with_0.hitEffect = "Particle/heart.par" -- 287
	_with_0.actions = Array({ -- 288
		"hit" -- 288
	}) -- 288
	Store["BlockA"] = _with_0 -- 278
end -- 278
do -- 290
	local _with_0 = Dictionary() -- 290
	_with_0.scale = 2 -- 291
	_with_0.playable = "model:Model/block2" -- 292
	do -- 293
		local _with_1 = BodyDef() -- 293
		_with_1.linearAcceleration = Vec2(0, -10) -- 294
		_with_1.type = "Dynamic" -- 295
		_with_1:attachPolygon(90, 210, 0.5, 0.4, 0.0) -- 296
		_with_0.bodyDef = _with_1 -- 293
	end -- 293
	_with_0.tag = "Block" -- 297
	_with_0.hp = 3.0 -- 298
	_with_0.hitEffect = "Particle/heart.par" -- 299
	_with_0.actions = Array({ -- 300
		"hit" -- 300
	}) -- 300
	Store["BlockB"] = _with_0 -- 290
end -- 290
do -- 302
	local _with_0 = Dictionary() -- 302
	_with_0.scale = 2 -- 303
	_with_0.playable = "model:Model/block3" -- 304
	do -- 305
		local _with_1 = BodyDef() -- 305
		_with_1.linearAcceleration = Vec2(0, -10) -- 306
		_with_1.type = "Dynamic" -- 307
		_with_1:attachPolygon(450, 90, 0.5, 0.4, 0.0) -- 308
		_with_0.bodyDef = _with_1 -- 305
	end -- 305
	_with_0.tag = "Block" -- 309
	_with_0.hp = 4.0 -- 310
	_with_0.hitEffect = "Particle/heart.par" -- 311
	_with_0.actions = Array({ -- 312
		"hit" -- 312
	}) -- 312
	Store["BlockC"] = _with_0 -- 302
end -- 302
do -- 314
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
	Store["Switch"] = _with_0 -- 314
end -- 314
local _with_0 = Dictionary() -- 322
_with_0.bodyType = "Static" -- 323
_with_0.playable = "model:Model/switch" -- 324
_with_0.attackRange = Size(80, 126) -- 325
_with_0.tag = "Switch" -- 326
_with_0.decisionTree = "SwitchAI" -- 327
_with_0.actions = Array({ -- 328
	"waitUser", -- 328
	"pushed" -- 328
}) -- 328
Store["SwitchG"] = _with_0 -- 322
