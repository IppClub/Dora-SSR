-- [yue]: Script/Game/Involution Warrior/init.yue
local _module_1 = dora.Platformer -- 1
local Data = _module_1.Data -- 1
local App = dora.App -- 1
local Vec2 = dora.Vec2 -- 1
local Size = dora.Size -- 1
local DrawNode = dora.DrawNode -- 1
local Color = dora.Color -- 1
local Line = dora.Line -- 1
local Group = dora.Group -- 1
local PlatformWorld = _module_1.PlatformWorld -- 1
local table = _G.table -- 1
local math = _G.math -- 1
local View = dora.View -- 1
local BodyDef = dora.BodyDef -- 1
local Body = dora.Body -- 1
local UnitAction = _module_1.UnitAction -- 1
local once = dora.once -- 1
local Audio = dora.Audio -- 1
local Bullet = _module_1.Bullet -- 1
local sleep = dora.sleep -- 1
local BulletDef = _module_1.BulletDef -- 1
local Face = _module_1.Face -- 1
local cycle = dora.cycle -- 1
local Rect = dora.Rect -- 1
local Dictionary = dora.Dictionary -- 1
local TargetAllow = _module_1.TargetAllow -- 1
local Array = dora.Array -- 1
local Unit = _module_1.Unit -- 1
local tostring = _G.tostring -- 1
local Sprite = dora.Sprite -- 1
local pairs = _G.pairs -- 1
local _module_2 = dora.Platformer.Decision -- 1
local Sel = _module_2.Sel -- 1
local Seq = _module_2.Seq -- 1
local Con = _module_2.Con -- 1
local Accept = _module_2.Accept -- 1
local Act = _module_2.Act -- 1
local AI = _module_2.AI -- 1
local Observer = dora.Observer -- 1
local Action = dora.Action -- 1
local Scale = dora.Scale -- 1
local Ease = dora.Ease -- 1
local Label = dora.Label -- 1
local Sequence = dora.Sequence -- 1
local Y = dora.Y -- 1
local Opacity = dora.Opacity -- 1
local Event = dora.Event -- 1
local Visual = _module_1.Visual -- 1
local emit = dora.emit -- 1
local Spawn = dora.Spawn -- 1
local Director = dora.Director -- 1
local string = _G.string -- 1
local Delay = dora.Delay -- 1
local Entity = dora.Entity -- 1
local _module_0 = dora.ImGui -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local Begin = _module_0.Begin -- 1
local ProgressBar = _module_0.ProgressBar -- 1
local Node = dora.Node -- 1
local PushStyleVar = _module_0.PushStyleVar -- 1
local Text = _module_0.Text -- 1
local Image = _module_0.Image -- 1
local SameLine = _module_0.SameLine -- 1
local AlignNode = require("UI.Control.Basic.AlignNode") -- 7
local CircleButton = require("UI.Control.Basic.CircleButton") -- 8
local Set = require("Utils").Set -- 9
local Store = Data.store -- 10
local themeColor = App.themeColor -- 12
local mutables = { -- 17
	"hp", -- 17
	"moveSpeed", -- 18
	"move", -- 19
	"jump", -- 20
	"targetAllow", -- 21
	"attackBase", -- 22
	"attackPower", -- 23
	"attackSpeed", -- 24
	"damageType", -- 25
	"attackBonus", -- 26
	"attackFactor", -- 27
	"attackTarget", -- 28
	"defenceType" -- 29
} -- 16
local elementTypes = { -- 33
	Green = 1, -- 33
	Red = 2, -- 34
	Yellow = 3, -- 35
	Purple = 4 -- 36
} -- 32
do -- 38
	local _with_0 = Data -- 38
	_with_0:setDamageFactor(elementTypes.Green, elementTypes.Red, 3) -- 39
	_with_0:setDamageFactor(elementTypes.Red, elementTypes.Yellow, 3) -- 40
	_with_0:setDamageFactor(elementTypes.Yellow, elementTypes.Green, 3) -- 41
end -- 38
local itemSlots = { -- 44
	"head", -- 44
	"mask", -- 45
	"body", -- 46
	"lhand", -- 47
	"rhand" -- 48
} -- 43
local headItems = { -- 51
	"item_hat", -- 51
	"item_hatTop", -- 52
	"item_helmet", -- 53
	"item_helmetModern" -- 54
} -- 50
local lhandItems = { -- 57
	"item_shield", -- 57
	"item_shieldRound", -- 58
	"tile_heart", -- 59
	"ui_hand" -- 60
} -- 56
local rhandItems = { -- 63
	"item_bow", -- 63
	"item_sword", -- 64
	"item_rod", -- 65
	"item_spear" -- 66
} -- 62
local characterTypes = { -- 69
	"square", -- 69
	"round" -- 70
} -- 68
local characterColors = { -- 73
	"Green", -- 73
	"Red", -- 74
	"Yellow" -- 75
} -- 72
local masks = { -- 78
	"bear", -- 78
	"buffalo", -- 79
	"chick", -- 80
	"chicken", -- 81
	"cow", -- 82
	"crocodile", -- 83
	"dog", -- 84
	"duck", -- 85
	"elephant", -- 86
	"frog", -- 87
	"giraffe", -- 88
	"goat", -- 89
	"gorilla", -- 90
	"hippo", -- 91
	"horse", -- 92
	"monkey", -- 93
	"moose", -- 94
	"narwhal", -- 95
	"owl", -- 96
	"panda", -- 97
	"parrot", -- 98
	"penguin", -- 99
	"pig", -- 100
	"rabbit", -- 101
	"rhino", -- 102
	"sloth", -- 103
	"snake", -- 104
	"walrus", -- 105
	"whale", -- 106
	"zebra" -- 107
} -- 77
local itemSettings = { -- 111
	item_hat = { -- 112
		skill = "jump", -- 112
		offset = Vec2(0, 30) -- 113
	}, -- 111
	item_hatTop = { -- 116
		skill = "evade", -- 116
		offset = Vec2(0, 30) -- 117
	}, -- 115
	item_helmet = { -- 120
		skill = "rush", -- 120
		offset = Vec2(0, 0) -- 121
	}, -- 119
	item_helmetModern = { -- 124
		skill = "rush", -- 124
		offset = Vec2(0, 0) -- 125
	}, -- 123
	item_shield = { -- 128
		skill = "", -- 128
		offset = Vec2(0, 0) -- 129
	}, -- 127
	item_shieldRound = { -- 132
		skill = "jump", -- 132
		offset = Vec2(0, 0) -- 133
	}, -- 131
	tile_heart = { -- 136
		skill = "jump", -- 136
		offset = Vec2(0, 0), -- 137
		attackPower = Vec2(600, 0) -- 138
	}, -- 135
	ui_hand = { -- 141
		skill = "evade", -- 141
		offset = Vec2(0, 0) -- 142
	}, -- 140
	item_bow = { -- 145
		skill = "range", -- 145
		offset = Vec2(10, 0), -- 146
		attackRange = Size(550, 150), -- 147
		sndAttack = "Audio/d_att.wav" -- 148
	}, -- 144
	item_sword = { -- 151
		skill = "meleeAttack", -- 151
		offset = Vec2(15, 50), -- 152
		attackRange = Size(120, 150), -- 153
		sndAttack = "Audio/f_att.wav" -- 154
	}, -- 150
	item_rod = { -- 157
		skill = "meleeAttack", -- 157
		offset = Vec2(15, 50), -- 158
		attackRange = Size(200, 150), -- 159
		attackPower = Vec2(100, 800), -- 160
		sndAttack = "Audio/b_att.wav" -- 161
	}, -- 156
	item_spear = { -- 164
		skill = "meleeAttack", -- 164
		offset = Vec2(15, 50), -- 165
		attackRange = Size(200, 150), -- 166
		sndAttack = "Audio/f_att.wav" -- 167
	} -- 163
} -- 110
local GamePaused = true -- 169
local size, grid = 1500, 150 -- 173
local _anon_func_0 = function(Color, Line, Vec2, _with_0, grid, size) -- 194
	local _with_1 = Line() -- 183
	_with_1.depthWrite = true -- 184
	_with_1.z = -10 -- 185
	for i = -size / grid, size / grid do -- 186
		_with_1:add({ -- 188
			Vec2(i * grid, size), -- 188
			Vec2(i * grid, -size) -- 189
		}, Color(0xff000000)) -- 187
		_with_1:add({ -- 192
			Vec2(-size, i * grid), -- 192
			Vec2(size, i * grid) -- 193
		}, Color(0xff000000)) -- 191
	end -- 194
	return _with_1 -- 183
end -- 183
local background -- 175
background = function() -- 175
	local _with_0 = DrawNode() -- 175
	_with_0.depthWrite = true -- 176
	_with_0:drawPolygon({ -- 178
		Vec2(-size, size), -- 178
		Vec2(size, size), -- 179
		Vec2(size, -size), -- 180
		Vec2(-size, -size) -- 181
	}, Color(0xff888888)) -- 177
	_with_0:addChild(_anon_func_0(Color, Line, Vec2, _with_0, grid, size)) -- 183
	return _with_0 -- 175
end -- 175
do -- 196
	local _with_0 = background() -- 196
	_with_0.z = 600 -- 197
end -- 196
do -- 198
	local _with_0 = background() -- 198
	_with_0.angleX = 45 -- 199
end -- 198
local TerrainLayer = 0 -- 203
local EnemyLayer = 1 -- 204
local PlayerLayer = 2 -- 205
local PlayerGroup = 1 -- 207
local EnemyGroup = 2 -- 208
Data:setRelation(PlayerGroup, EnemyGroup, "Enemy") -- 210
Data:setShouldContact(PlayerGroup, EnemyGroup, true) -- 211
local unitGroup = Group({ -- 213
	"unit" -- 213
}) -- 213
local world -- 215
do -- 215
	local _with_0 = PlatformWorld() -- 215
	_with_0:schedule(function() -- 216
		local origin = Vec2.zero -- 217
		local locs = { -- 218
			origin -- 218
		} -- 218
		unitGroup:each(function(self) -- 219
			return table.insert(locs, self.unit.position) -- 219
		end) -- 219
		local dist = 0 -- 220
		for _index_0 = 1, #locs do -- 221
			local loc = locs[_index_0] -- 221
			dist = math.max(dist, loc:distance(origin)) -- 222
		end -- 222
		local DesignWidth <const> = 1250 -- 223
		local currentZoom = _with_0.camera.zoom -- 224
		local baseZoom = View.size.width / DesignWidth -- 225
		local targetZoom = baseZoom * math.max(math.min(3.0, (DesignWidth / dist / 4)), 0.8) -- 226
		_with_0.camera.zoom = currentZoom + (targetZoom - currentZoom) * 0.005 -- 227
	end) -- 216
	world = _with_0 -- 215
end -- 215
Store["world"] = world -- 229
local terrainDef -- 231
do -- 231
	local _with_0 = BodyDef() -- 231
	_with_0.type = "Static" -- 232
	_with_0:attachPolygon(Vec2(0, 0), 2500, 10, 0, 1, 1, 0) -- 233
	_with_0:attachPolygon(Vec2(0, 1000), 2500, 10, 0, 1, 1, 0) -- 234
	_with_0:attachPolygon(Vec2(800, 1000), 10, 2000, 0, 1, 1, 0) -- 235
	_with_0:attachPolygon(Vec2(-800, 1000), 10, 2000, 0, 1, 1, 0) -- 236
	terrainDef = _with_0 -- 231
end -- 231
do -- 238
	local _with_0 = Body(terrainDef, world, Vec2.zero) -- 238
	_with_0.order = TerrainLayer -- 239
	_with_0.group = Data.groupTerrain -- 240
	_with_0:addTo(world) -- 241
end -- 238
local rangeAttackEnd -- 245
rangeAttackEnd = function(name, playable) -- 245
	if name == "range" then -- 246
		return playable.parent:stop() -- 246
	end -- 246
end -- 245
UnitAction:add("range", { -- 249
	priority = 3, -- 249
	reaction = 10, -- 250
	recovery = 0.1, -- 251
	queued = true, -- 252
	available = function(self) -- 253
		return true -- 253
	end, -- 253
	create = function(self) -- 254
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 255
		do -- 255
			local _obj_0 = self.entity -- 260
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 255
		end -- 260
		do -- 261
			local _with_0 = self.playable -- 261
			_with_0.speed = attackSpeed -- 262
			_with_0:play("range") -- 263
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 264
		end -- 261
		return once(function(self) -- 265
			local bulletDef = Store[self.unitDef.bulletType] -- 266
			local onAttack -- 267
			onAttack = function() -- 267
				Audio:play(self.unitDef.sndAttack) -- 268
				local _with_0 = Bullet(bulletDef, self) -- 269
				if self.group == EnemyGroup then -- 270
					_with_0.color = Color(0xff666666) -- 270
				end -- 270
				_with_0.targetAllow = targetAllow -- 271
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 272
					do -- 273
						local _with_1 = target.data -- 273
						_with_1.hitPoint = pos -- 274
						_with_1.hitPower = attackPower -- 275
						_with_1.hitFromRight = bullet.velocityX < 0 -- 276
					end -- 273
					local entity = target.entity -- 277
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 278
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 279
					entity.hp = entity.hp - damage -- 280
					bullet.hitStop = true -- 281
				end) -- 272
				_with_0:addTo(self.world, self.order) -- 282
				return _with_0 -- 269
			end -- 267
			sleep(0.5 * 28.0 / 30.0 / attackSpeed) -- 283
			onAttack() -- 284
			while true do -- 285
				sleep() -- 285
			end -- 285
		end) -- 285
	end, -- 254
	stop = function(self) -- 286
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 287
	end -- 286
}) -- 248
local BigArrow -- 289
do -- 289
	local _with_0 = BulletDef() -- 289
	_with_0.tag = "" -- 290
	_with_0.endEffect = "" -- 291
	_with_0.lifeTime = 5 -- 292
	_with_0.damageRadius = 0 -- 293
	_with_0.highSpeedFix = false -- 294
	_with_0.gravity = Vec2(0, -10) -- 295
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2(-100, 0), 2) -- 296
	_with_0:setAsCircle(10) -- 297
	_with_0:setVelocity(25, 800) -- 298
	BigArrow = _with_0 -- 289
end -- 289
UnitAction:add("multiArrow", { -- 301
	priority = 3, -- 301
	reaction = 10, -- 302
	recovery = 0.1, -- 303
	queued = true, -- 304
	available = function(self) -- 305
		return true -- 305
	end, -- 305
	create = function(self) -- 306
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 307
		do -- 307
			local _obj_0 = self.entity -- 312
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 307
		end -- 312
		do -- 313
			local _with_0 = self.playable -- 313
			_with_0.speed = attackSpeed -- 314
			_with_0:play("range") -- 315
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 316
		end -- 313
		return once(function(self) -- 317
			local onAttack -- 318
			onAttack = function(angle, speed) -- 318
				BigArrow:setVelocity(angle, speed) -- 319
				local _with_0 = Bullet(BigArrow, self) -- 320
				if self.group == EnemyGroup then -- 321
					_with_0.color = Color(0xff666666) -- 321
				end -- 321
				_with_0.targetAllow = targetAllow -- 322
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 323
					do -- 324
						local _with_1 = target.data -- 324
						_with_1.hitPoint = pos -- 325
						_with_1.hitPower = attackPower -- 326
						_with_1.hitFromRight = bullet.velocityX < 0 -- 327
					end -- 324
					local entity = target.entity -- 328
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 329
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 330
					entity.hp = entity.hp - damage -- 331
					bullet.hitStop = true -- 332
				end) -- 323
				_with_0:addTo(self.world, self.order) -- 333
				return _with_0 -- 320
			end -- 318
			sleep(30.0 / 60.0 / attackSpeed) -- 334
			Audio:play("Audio/d_att.wav") -- 335
			onAttack(30, 1100) -- 336
			onAttack(10, 1000) -- 337
			onAttack(-10, 900) -- 338
			onAttack(-30, 800) -- 339
			onAttack(-50, 700) -- 340
			while true do -- 341
				sleep() -- 341
			end -- 341
		end) -- 341
	end, -- 306
	stop = function(self) -- 342
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 343
	end -- 342
}) -- 300
UnitAction:add("fallOff", { -- 346
	priority = 1, -- 346
	reaction = 1, -- 347
	recovery = 0, -- 348
	available = function(self) -- 349
		return not self.onSurface -- 349
	end, -- 349
	create = function(self) -- 350
		if self.velocityY <= 0 then -- 351
			self.data.fallDown = true -- 352
			do -- 353
				local _with_0 = self.playable -- 353
				_with_0.speed = 2.5 -- 354
				_with_0:play("idle") -- 355
			end -- 353
		else -- 356
			self.data.fallDown = false -- 356
		end -- 351
		return function(self, action) -- 357
			if self.onSurface then -- 358
				return true -- 358
			end -- 358
			if not self.data.fallDown and self.velocityY <= 0 then -- 359
				self.data.fallDown = true -- 360
				do -- 361
					local _with_0 = self.playable -- 361
					_with_0.speed = 2.5 -- 362
					_with_0:play("idle") -- 363
				end -- 361
			end -- 359
			return false -- 364
		end -- 364
	end -- 350
}) -- 345
UnitAction:add("evade", { -- 367
	priority = 10, -- 367
	reaction = 10, -- 368
	recovery = 0, -- 369
	queued = true, -- 370
	available = function(self) -- 371
		return true -- 371
	end, -- 371
	create = function(self) -- 372
		do -- 373
			local _with_0 = self.playable -- 373
			_with_0.speed = 1.0 -- 374
			_with_0.recovery = 0.0 -- 375
			_with_0:play("bevade") -- 376
		end -- 373
		return once(function(self) -- 377
			local group = self.group -- 378
			self.group = Data.groupHide -- 379
			local dir = self.faceRight and -1 or 1 -- 380
			cycle(0.1, function() -- 381
				self.velocityX = 400 * dir -- 381
			end) -- 381
			self.group = group -- 382
			sleep(0.1) -- 383
			do -- 384
				local _with_0 = self.playable -- 384
				_with_0.speed = 1.0 -- 385
				_with_0:play("idle") -- 386
			end -- 384
			sleep(0.3) -- 387
			return true -- 388
		end) -- 388
	end -- 372
}) -- 366
UnitAction:add("rush", { -- 391
	priority = 10, -- 391
	reaction = 10, -- 392
	recovery = 0, -- 393
	queued = true, -- 394
	available = function(self) -- 395
		return true -- 395
	end, -- 395
	create = function(self) -- 396
		do -- 397
			local _with_0 = self.playable -- 397
			_with_0.speed = 1.0 -- 398
			_with_0.recovery = 0.0 -- 399
			_with_0:play("fevade") -- 400
		end -- 397
		return once(function(self) -- 401
			local group = self.group -- 402
			self.group = Data.groupHide -- 403
			local dir = self.faceRight and 1 or -1 -- 404
			cycle(0.1, function() -- 405
				self.velocityX = 800 * dir -- 405
			end) -- 405
			self.group = group -- 406
			sleep(0.1) -- 407
			do -- 408
				local _with_0 = self.playable -- 408
				_with_0.speed = 1.0 -- 409
				_with_0:play("idle") -- 410
			end -- 408
			sleep(0.3) -- 411
			return true -- 412
		end) -- 412
	end -- 396
}) -- 390
local spearAttackEnd -- 414
spearAttackEnd = function(name, playable) -- 414
	if name == "spear" then -- 415
		return playable.parent:stop() -- 415
	end -- 415
end -- 414
UnitAction:add("spearAttack", { -- 418
	priority = 3, -- 418
	reaction = 10, -- 419
	recovery = 0.1, -- 420
	queued = true, -- 421
	available = function(self) -- 422
		return true -- 422
	end, -- 422
	create = function(self) -- 423
		local attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor -- 424
		do -- 424
			local _obj_0 = self.entity -- 428
			attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 424
		end -- 428
		do -- 429
			local _with_0 = self.playable -- 429
			_with_0.speed = attackSpeed -- 430
			_with_0.recovery = 0.2 -- 431
			_with_0:play("spear") -- 432
			_with_0:slot("AnimationEnd", spearAttackEnd) -- 433
		end -- 429
		return once(function(self) -- 434
			sleep(50.0 / 60.0) -- 435
			Audio:play("Audio/f_att.wav") -- 436
			local dir = self.faceRight and 0 or -900 -- 437
			local origin = self.position - Vec2(0, 205) + Vec2(dir, 0) -- 438
			size = Size(900, 40) -- 439
			world:query(Rect(origin, size), function(body) -- 440
				local entity = body.entity -- 441
				if entity and Data:isEnemy(body, self) then -- 442
					do -- 443
						local _with_0 = body.data -- 443
						_with_0.hitPoint = body.position -- 444
						_with_0.hitPower = attackPower -- 445
						_with_0.hitFromRight = not self.faceRight -- 446
					end -- 443
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 447
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 448
					entity.hp = entity.hp - damage -- 449
				end -- 442
				return false -- 450
			end) -- 440
			while true do -- 451
				sleep() -- 451
			end -- 451
		end) -- 451
	end -- 423
}) -- 417
do -- 453
	local _with_0 = BulletDef() -- 453
	_with_0.tag = "" -- 454
	_with_0.endEffect = "" -- 455
	_with_0.lifeTime = 5 -- 456
	_with_0.damageRadius = 0 -- 457
	_with_0.highSpeedFix = false -- 458
	_with_0.gravity = Vec2(0, -10) -- 459
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2.zero) -- 460
	_with_0:setAsCircle(10) -- 461
	_with_0:setVelocity(25, 800) -- 462
	Store["Bullet_Arrow"] = _with_0 -- 453
end -- 453
local GetBoss -- 464
GetBoss = function(entity, pos, black) -- 464
	local unitDef -- 465
	do -- 465
		local _with_0 = Dictionary() -- 465
		_with_0.linearAcceleration = Vec2(0, -10) -- 466
		_with_0.bodyType = "Dynamic" -- 467
		_with_0.scale = 2 -- 468
		_with_0.density = 10.0 -- 469
		_with_0.friction = 1.0 -- 470
		_with_0.restitution = 0.0 -- 471
		_with_0.playable = "model:Model/bossp.model" -- 472
		_with_0.size = Size(150, 410) -- 473
		_with_0.tag = "Boss" -- 474
		_with_0.sensity = 0 -- 475
		_with_0.move = 100 -- 476
		_with_0.moveSpeed = 1.0 -- 477
		_with_0.jump = 600 -- 478
		_with_0.detectDistance = 1500 -- 479
		_with_0.hp = 30.0 -- 480
		_with_0.attackSpeed = 1.0 -- 481
		_with_0.attackBase = 2.5 -- 482
		_with_0.attackDelay = 50.0 / 60.0 -- 483
		_with_0.attackEffectDelay = 50.0 / 60.0 -- 484
		_with_0.attackBonus = 0.0 -- 485
		_with_0.attackFactor = 1.0 -- 486
		_with_0.attackRange = Size(780, 300) -- 487
		_with_0.attackPower = Vec2(200, 200) -- 488
		_with_0.attackTarget = "Multi" -- 489
		do -- 490
			local conf -- 491
			do -- 491
				local _with_1 = TargetAllow() -- 491
				_with_1.terrainAllowed = true -- 492
				_with_1:allow("Enemy", true) -- 493
				conf = _with_1 -- 491
			end -- 491
			_with_0.targetAllow = conf:toValue() -- 494
		end -- 494
		_with_0.damageType = elementTypes.Purple -- 495
		_with_0.defenceType = elementTypes.Purple -- 496
		_with_0.bulletType = "Bullet_Arrow" -- 497
		_with_0.attackEffect = "" -- 498
		_with_0.hitEffect = "Particle/bloodp.par" -- 499
		_with_0.sndAttack = "Audio/f_att.wav" -- 500
		_with_0.sndFallen = "" -- 501
		_with_0.decisionTree = "AI_Boss" -- 502
		_with_0.usePreciseHit = true -- 503
		_with_0.actions = Array({ -- 505
			"walk", -- 505
			"turn", -- 506
			"meleeAttack", -- 507
			"multiArrow", -- 508
			"spearAttack", -- 509
			"idle", -- 510
			"cancel", -- 511
			"jump", -- 512
			"fall", -- 513
			"fallOff" -- 514
		}) -- 504
		unitDef = _with_0 -- 465
	end -- 465
	for _index_0 = 1, #mutables do -- 516
		local var = mutables[_index_0] -- 516
		entity[var] = unitDef[var] -- 517
	end -- 517
	local _with_0 = Unit(unitDef, world, entity, pos) -- 518
	if black then -- 519
		for i = 1, 7 do -- 520
			do -- 521
				local node = _with_0.playable:getNodeByName("w" .. tostring(i)) -- 521
				if node then -- 521
					node.color = Color(0xff666666) -- 522
				end -- 521
			end -- 521
		end -- 522
	end -- 519
	do -- 523
		local node = _with_0.playable:getNodeByName("mask") -- 523
		if node then -- 523
			node:addChild(Sprite("Model/patreon.clip|" .. tostring(masks[math.random(1, #masks)]))) -- 524
		end -- 523
	end -- 523
	return _with_0 -- 518
end -- 464
local _anon_func_1 = function(entity, itemSettings, items, pairs, tostring) -- 545
	local _accum_0 = { } -- 542
	local _len_0 = 1 -- 542
	for _, v in pairs(items) do -- 542
		do -- 543
			local skill = itemSettings[v].skill -- 543
			if skill then -- 543
				entity[tostring(skill) .. "Skill"] = true -- 544
				_accum_0[_len_0] = skill -- 545
			end -- 543
		end -- 543
		_len_0 = _len_0 + 1 -- 545
	end -- 545
	return _accum_0 -- 545
end -- 542
local _anon_func_2 = function(Color, Sprite, _with_0, black, item, itemSettings, tostring) -- 609
	local _with_1 = Sprite("Model/patreon.clip|" .. tostring(item)) -- 607
	if black then -- 608
		_with_1.color = Color(0xff666666) -- 608
	end -- 608
	_with_1.position = itemSettings[item].offset -- 609
	return _with_1 -- 607
end -- 607
local GetUnit -- 526
GetUnit = function(entity, pos, black) -- 526
	local characterType = characterTypes[math.random(1, #characterTypes)] -- 527
	local characterColor = characterColors[math.random(1, #characterColors)] -- 528
	local character = { -- 530
		body = "character_" .. tostring(characterType) .. tostring(characterColor), -- 530
		lhand = "character_hand" .. tostring(characterColor), -- 531
		rhand = "character_hand" .. tostring(characterColor), -- 532
		mask = masks[math.random(1, #masks)] -- 533
	} -- 529
	local items = { -- 535
		head = headItems[math.random(1, #headItems)], -- 535
		lhand = lhandItems[math.random(1, #lhandItems)], -- 536
		rhand = rhandItems[math.random(1, #rhandItems)] -- 537
	} -- 534
	local attackRange = itemSettings[items.rhand].attackRange or Size(350, 150) -- 538
	local bonusPower = itemSettings[items.lhand].attackPower or Vec2.zero -- 539
	local attackPower = bonusPower + (itemSettings[items.rhand].attackPower or Vec2(100, 100)) -- 540
	local sndAttack = itemSettings[items.rhand].sndAttack or "" -- 541
	local skills = Set(_anon_func_1(entity, itemSettings, items, pairs, tostring)) -- 542
	local actions = Array({ -- 547
		"walk", -- 547
		"turn", -- 548
		"idle", -- 549
		"cancel", -- 550
		"hit", -- 551
		"fall", -- 552
		"fallOff" -- 553
	}) -- 546
	for k in pairs(skills) do -- 555
		actions:add(k) -- 556
	end -- 556
	local unitDef -- 557
	do -- 557
		local _with_0 = Dictionary() -- 557
		_with_0.linearAcceleration = Vec2(0, -10) -- 558
		_with_0.bodyType = "Dynamic" -- 559
		_with_0.scale = 1 -- 560
		_with_0.density = 1.0 -- 561
		_with_0.friction = 1.0 -- 562
		_with_0.restitution = 0.0 -- 563
		_with_0.playable = "model:Model/patreon.model" -- 564
		_with_0.size = Size(64, 128) -- 565
		_with_0.tag = "Fighter" -- 566
		_with_0.sensity = 0 -- 567
		_with_0.move = 250 -- 568
		_with_0.moveSpeed = 1.0 -- 569
		_with_0.jump = 700 -- 570
		_with_0.detectDistance = 800 -- 571
		_with_0.hp = 10.0 -- 572
		_with_0.attackSpeed = 1.0 -- 573
		_with_0.attackBase = 2.5 -- 574
		_with_0.attackDelay = 20.0 / 60.0 -- 575
		_with_0.attackEffectDelay = 20.0 / 60.0 -- 576
		_with_0.attackBonus = 0.0 -- 577
		_with_0.attackFactor = 1.0 -- 578
		_with_0.attackRange = attackRange -- 579
		_with_0.attackPower = attackPower -- 580
		_with_0.attackTarget = "Single" -- 581
		do -- 582
			local conf -- 583
			do -- 583
				local _with_1 = TargetAllow() -- 583
				_with_1.terrainAllowed = true -- 584
				_with_1:allow("Enemy", true) -- 585
				conf = _with_1 -- 583
			end -- 583
			_with_0.targetAllow = conf:toValue() -- 586
		end -- 586
		_with_0.damageType = elementTypes[characterColor] -- 587
		_with_0.defenceType = elementTypes[characterColor] -- 588
		_with_0.bulletType = "Bullet_Arrow" -- 589
		_with_0.attackEffect = "" -- 590
		_with_0.hitEffect = "Particle/bloodp.par" -- 591
		_with_0.name = "Fighter" -- 592
		_with_0.desc = "" -- 593
		_with_0.sndAttack = sndAttack -- 594
		_with_0.sndFallen = "" -- 595
		_with_0.decisionTree = "AI_Common" -- 596
		_with_0.usePreciseHit = true -- 597
		_with_0.actions = actions -- 598
		unitDef = _with_0 -- 557
	end -- 557
	for _index_0 = 1, #mutables do -- 599
		local var = mutables[_index_0] -- 599
		entity[var] = unitDef[var] -- 600
	end -- 600
	local _with_0 = Unit(unitDef, world, entity, pos) -- 601
	for _index_0 = 1, #itemSlots do -- 602
		local slot = itemSlots[_index_0] -- 602
		local node = _with_0.playable:getNodeByName(slot) -- 603
		do -- 604
			local item = character[slot] -- 604
			if item then -- 604
				node:addChild(Sprite("Model/patreon.clip|" .. tostring(item))) -- 605
			end -- 604
		end -- 604
		do -- 606
			local item = items[slot] -- 606
			if item then -- 606
				node:addChild(_anon_func_2(Color, Sprite, _with_0, black, item, itemSettings, tostring)) -- 607
			end -- 606
		end -- 606
	end -- 609
	return _with_0 -- 601
end -- 526
Store["AI_Common"] = Sel({ -- 614
	Seq({ -- 615
		Con("is dead", function(self) -- 615
			return self.entity.hp <= 0 -- 615
		end), -- 615
		Accept() -- 616
	}), -- 614
	Seq({ -- 619
		Con("is falling", function(self) -- 619
			return not self.onSurface -- 619
		end), -- 619
		Act("fallOff") -- 620
	}), -- 618
	Seq({ -- 623
		Con("game paused", function() -- 623
			return GamePaused -- 623
		end), -- 623
		Act("idle") -- 624
	}), -- 622
	Seq({ -- 627
		Con("is not attacking", function(self) -- 627
			return not self:isDoing("melee") and not self:isDoing("range") -- 629
		end), -- 627
		Con("need attack", function(self) -- 630
			local attackUnits = AI:getUnitsInAttackRange() -- 631
			for _index_0 = 1, #attackUnits do -- 632
				local unit = attackUnits[_index_0] -- 632
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 633
					return true -- 635
				end -- 633
			end -- 635
			return false -- 636
		end), -- 630
		Sel({ -- 638
			Seq({ -- 639
				Con("attack", function(self) -- 639
					return App.rand % 10 == 0 -- 639
				end), -- 639
				Sel({ -- 641
					Act("meleeAttack"), -- 641
					Act("range") -- 642
				}) -- 640
			}), -- 638
			Act("idle") -- 645
		}) -- 637
	}), -- 626
	Seq({ -- 649
		Con("rush or evade", function(self) -- 649
			return not self:isDoing("rush") and not self:isDoing("evade") and App.rand % 300 == 0 -- 650
		end), -- 649
		Sel({ -- 652
			Seq({ -- 653
				Con("too far away", function(self) -- 653
					if self.entity.rushSkill then -- 654
						local units = AI:getDetectedUnits() -- 655
						for _index_0 = 1, #units do -- 656
							local unit = units[_index_0] -- 656
							if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight and self.position:distance(unit.position) > 300 then -- 657
								return true -- 659
							end -- 657
						end -- 659
					end -- 654
					return false -- 660
				end), -- 653
				Act("rush") -- 661
			}), -- 652
			Seq({ -- 664
				Con("too close", function(self) -- 664
					if self.entity.evadeSkill then -- 665
						local units = AI:getDetectedUnits() -- 666
						for _index_0 = 1, #units do -- 667
							local unit = units[_index_0] -- 667
							if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight and self.position:distance(unit.position) < 300 then -- 668
								return true -- 670
							end -- 668
						end -- 670
					end -- 665
					return false -- 671
				end), -- 664
				Act("evade") -- 672
			}) -- 663
		}) -- 651
	}), -- 648
	Seq({ -- 677
		Con("need turn", function(self) -- 677
			return (self.x < -750 and not self.faceRight) or (self.x > 750 and self.faceRight) -- 678
		end), -- 677
		Act("turn") -- 679
	}), -- 676
	Act("walk") -- 681
}) -- 613
Store["AI_Boss"] = Sel({ -- 685
	Seq({ -- 686
		Con("is dead", function(self) -- 686
			return self.entity.hp <= 0 -- 686
		end), -- 686
		Accept() -- 687
	}), -- 685
	Seq({ -- 690
		Con("is falling", function(self) -- 690
			return not self.onSurface -- 690
		end), -- 690
		Act("fallOff") -- 691
	}), -- 689
	Seq({ -- 694
		Con("game paused", function() -- 694
			return GamePaused -- 694
		end), -- 694
		Act("idle") -- 695
	}), -- 693
	Seq({ -- 698
		Con("is not attacking", function(self) -- 698
			return not self:isDoing("meleeAttack") and not self:isDoing("multiArrow") and not self:isDoing("spearAttack") -- 701
		end), -- 698
		Con("need attack", function(self) -- 702
			local attackUnits = AI:getUnitsInAttackRange() -- 703
			for _index_0 = 1, #attackUnits do -- 704
				local unit = attackUnits[_index_0] -- 704
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 705
					return true -- 707
				end -- 705
			end -- 707
			return false -- 708
		end), -- 702
		Sel({ -- 710
			Seq({ -- 711
				Con("melee attack", function(self) -- 711
					return App.rand % 40 == 0 -- 711
				end), -- 711
				Act("meleeAttack") -- 712
			}), -- 710
			Seq({ -- 715
				Con("multi Arrow", function(self) -- 715
					return App.rand % 40 == 0 -- 715
				end), -- 715
				Act("multiArrow") -- 716
			}), -- 714
			Seq({ -- 719
				Con("spear attack", function(self) -- 719
					return App.rand % 40 == 0 -- 719
				end), -- 719
				Act("spearAttack") -- 720
			}), -- 718
			Act("idle") -- 722
		}) -- 709
	}), -- 697
	Seq({ -- 726
		Con("need turn", function(self) -- 726
			return (self.x < -750 and not self.faceRight) or (self.x > 750 and self.faceRight) -- 727
		end), -- 726
		Act("turn") -- 728
	}), -- 725
	Act("walk") -- 730
}) -- 684
do -- 733
	local _with_0 = Observer("Add", { -- 733
		"position", -- 733
		"order", -- 733
		"group", -- 733
		"faceRight" -- 733
	}) -- 733
	_with_0:watch(function(self, position, order, group, faceRight) -- 734
		world = Store.world -- 735
		if group == PlayerGroup then -- 736
			self.player = true -- 736
		end -- 736
		if group == EnemyGroup then -- 737
			self.enemy = true -- 737
		end -- 737
		do -- 738
			local _with_1 -- 738
			if self.boss then -- 738
				_with_1 = GetBoss(self, position, group == EnemyGroup) -- 739
			else -- 741
				_with_1 = GetUnit(self, position, group == EnemyGroup) -- 741
			end -- 738
			_with_1.group = group -- 742
			_with_1.order = order -- 743
			_with_1.playable:runAction(Action(Scale(0.5, 0, self.unit.unitDef.scale, Ease.OutBack))) -- 744
			_with_1.faceRight = faceRight -- 745
			_with_1:addTo(world) -- 746
		end -- 738
		return false -- 746
	end) -- 734
end -- 733
do -- 748
	local _with_0 = Observer("Change", { -- 748
		"hp", -- 748
		"unit" -- 748
	}) -- 748
	_with_0:watch(function(self, hp, unit) -- 749
		local boss = self.boss -- 750
		local lastHp = self.oldValues.hp -- 751
		if hp < lastHp then -- 752
			if not boss and unit:isDoing("hit") then -- 753
				unit:start("cancel") -- 753
			end -- 753
			do -- 754
				local _with_1 = Label("sarasa-mono-sc-regular", 30) -- 754
				_with_1.order = PlayerLayer -- 755
				_with_1.color = Color(0xffff0000) -- 756
				_with_1.position = unit.position + Vec2(0, 40) -- 757
				_with_1.text = "-" .. tostring(lastHp - hp) -- 758
				_with_1:runAction(Action(Sequence(Y(0.5, _with_1.y, _with_1.y + 100), Opacity(0.2, 1, 0), Event("End")))) -- 759
				_with_1:slot("End", function() -- 764
					return _with_1:removeFromParent() -- 764
				end) -- 764
				_with_1:addTo(world) -- 765
			end -- 754
			if boss then -- 766
				do -- 767
					local _with_1 = Visual("Particle/bloodp.par") -- 767
					_with_1.position = unit.data.hitPoint -- 768
					_with_1:addTo(world, unit.order) -- 769
					_with_1:autoRemove() -- 770
					_with_1:start() -- 771
				end -- 767
			end -- 766
			if hp > 0 then -- 772
				unit:start("hit") -- 773
			else -- 775
				unit:start("cancel") -- 775
				unit:start("hit") -- 776
				unit:start("fall") -- 777
				unit.group = Data.groupHide -- 778
				unit:schedule(once(function(self) -- 779
					sleep(3) -- 780
					unit:removeFromParent() -- 781
					if not Group({ -- 782
						"unit" -- 782
					}):each(function(self) -- 782
						return self.group == PlayerGroup -- 782
					end) then -- 782
						return emit("Lost") -- 783
					elseif not Group({ -- 784
						"unit" -- 784
					}):each(function(self) -- 784
						return self.group == EnemyGroup -- 784
					end) then -- 784
						return emit("Win") -- 785
					end -- 782
				end)) -- 779
			end -- 772
		end -- 752
		return false -- 785
	end) -- 749
end -- 748
local WaitForSignal -- 787
WaitForSignal = function(text, duration) -- 787
	local _with_0 = Label("sarasa-mono-sc-regular", 100) -- 788
	_with_0.color = themeColor -- 789
	_with_0.text = text -- 790
	_with_0:runAction(Spawn(Scale(0.5, 0.3, 1, Ease.OutBack), Opacity(0.3, 0, 1))) -- 791
	sleep(duration - 0.3) -- 795
	_with_0:runAction(Spawn(Scale(0.3, 1, 1.5, Ease.OutQuad), Opacity(0.3, 1, 0, Ease.OutQuad))) -- 796
	sleep(0.3) -- 800
	_with_0:removeFromParent() -- 801
	return _with_0 -- 788
end -- 787
local GameScore = 20 -- 803
local uiScale = App.devicePixelRatio -- 805
local _anon_func_3 = function(Delay, Ease, Event, Label, Opacity, Scale, Sequence, Spawn, _with_1, string, themeColor, tostring, value) -- 829
	local _with_0 = Label("sarasa-mono-sc-regular", 64) -- 814
	_with_0.color = themeColor -- 815
	_with_0.text = string.format(tostring(value > 0 and '+' or '') .. "%d", value) -- 816
	_with_0:runAction(Sequence(Spawn(Scale(0.5, 0.3, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(0.5), Spawn(Scale(0.3, 1, 1.5, Ease.OutQuad), Opacity(0.3, 1, 0, Ease.OutQuad)), Event("End"))) -- 817
	_with_0:slot("End", function() -- 829
		return _with_0:removeFromParent() -- 829
	end) -- 829
	return _with_0 -- 814
end -- 814
Director.ui:addChild((function() -- 806
	local _with_0 = AlignNode({ -- 806
		isRoot = true -- 806
	}) -- 806
	_with_0:addChild((function() -- 807
		local _with_1 = AlignNode() -- 807
		_with_1.size = Size(0, 0) -- 808
		_with_1.hAlign = "Left" -- 809
		_with_1.vAlign = "Top" -- 810
		_with_1.alignOffset = Vec2(360, 80) * (uiScale / 2) -- 811
		_with_1:gslot("AddScore", function(value) -- 812
			if value < 0 and GameScore == 0 then -- 813
				return -- 813
			end -- 813
			_with_1:addChild(_anon_func_3(Delay, Ease, Event, Label, Opacity, Scale, Sequence, Spawn, _with_1, string, themeColor, tostring, value)) -- 814
			GameScore = math.max(0, GameScore + value) -- 830
			if GameScore == 0 then -- 831
				return _with_1:schedule(once(function() -- 832
					Audio:play("Audio/game_over.wav") -- 833
					WaitForSignal("FOREVER LOST!", 3) -- 834
					return emit("GameLost") -- 835
				end)) -- 835
			end -- 831
		end) -- 812
		return _with_1 -- 807
	end)()) -- 807
	_with_0:addChild((function() -- 836
		local _with_1 = AlignNode() -- 836
		_with_1.size = Size(0, 0) -- 837
		_with_1.hAlign = "Center" -- 838
		_with_1.vAlign = "Center" -- 839
		_with_1.alignOffset = Vec2(0, -300 * (uiScale / 2)) -- 840
		_with_1:addChild((function() -- 841
			local _with_2 = CircleButton({ -- 842
				text = "STRIKE\nBACK", -- 842
				radius = 80, -- 843
				fontName = "sarasa-mono-sc-regular", -- 844
				fontSize = 48 -- 845
			}) -- 841
			_with_2.visible = false -- 847
			_with_2.touchEnabled = false -- 848
			_with_2:gslot("GameLost", function() -- 849
				_with_2.visible = true -- 850
				_with_2.touchEnabled = true -- 851
			end) -- 849
			_with_2:slot("Tapped", function() -- 852
				_with_2.touchEnabled = false -- 853
				Audio:play("Audio/v_att.wav") -- 854
				return _with_2:schedule(once(function() -- 855
					sleep(0.5) -- 856
					_with_2.visible = false -- 857
					emit("AddScore", 20) -- 858
					return emit("Start") -- 859
				end)) -- 859
			end) -- 852
			return _with_2 -- 841
		end)()) -- 841
		_with_1:addChild((function() -- 860
			local _with_2 = CircleButton({ -- 861
				text = "FIGHT", -- 861
				x = -200, -- 862
				radius = 80, -- 863
				fontName = "sarasa-mono-sc-regular", -- 864
				fontSize = 48 -- 865
			}) -- 860
			_with_2:slot("Tapped", function() -- 867
				if GameScore <= 0 then -- 868
					return -- 868
				end -- 868
				GamePaused = false -- 869
				return _with_2:schedule(once(function() -- 870
					emit("Fight") -- 871
					Audio:play("Audio/choose.wav") -- 872
					return WaitForSignal("FIGHT!", 1) -- 873
				end)) -- 873
			end) -- 867
			return _with_2 -- 860
		end)()) -- 860
		_with_1:addChild((function() -- 874
			local _with_2 = CircleButton({ -- 875
				text = "ANOTHER\nWAY", -- 875
				x = 200, -- 876
				radius = 80, -- 877
				fontName = "sarasa-mono-sc-regular", -- 878
				fontSize = 48 -- 879
			}) -- 874
			_with_2:slot("Tapped", function() -- 881
				Audio:play("Audio/switch.wav") -- 882
				emit("AddScore", -5) -- 883
				return emit("Start") -- 884
			end) -- 881
			return _with_2 -- 874
		end)()) -- 874
		_with_1:gslot("Lost", function() -- 885
			return _with_1:schedule(once(function() -- 886
				emit("AddScore", -(10 + math.floor(GameScore / 20) * 5)) -- 887
				if GameScore == 0 then -- 888
					return -- 888
				end -- 888
				Audio:play("Audio/hero_fall.wav") -- 889
				WaitForSignal("LOST!", 1.5) -- 890
				return emit("Start") -- 891
			end)) -- 891
		end) -- 885
		_with_1:gslot("Win", function() -- 892
			return _with_1:schedule(once(function() -- 893
				local score = 5 * Group({ -- 894
					"player" -- 894
				}).count -- 894
				emit("AddScore", score) -- 895
				Audio:play("Audio/hero_win.wav") -- 896
				WaitForSignal("WIN!", 1.5) -- 897
				return emit("Start") -- 898
			end)) -- 898
		end) -- 892
		_with_1:gslot("Wasted", function() -- 899
			_with_1:eachChild(function(self) -- 900
				self.visible = false -- 901
				self.touchEnabled = false -- 902
			end) -- 900
			return emit("AddScore", -20) -- 903
		end) -- 899
		_with_1:gslot("Fight", function() -- 904
			_with_1:eachChild(function(self) -- 905
				self.visible = false -- 906
				self.touchEnabled = false -- 907
			end) -- 905
			return _with_1:unschedule() -- 908
		end) -- 904
		_with_1:gslot("Start", function() -- 909
			if GameScore == 0 then -- 910
				return -- 910
			end -- 910
			GamePaused = true -- 911
			_with_1:eachChild(function(self) -- 912
				if self.text ~= "STRIKE\nBACK" then -- 913
					self.touchEnabled = true -- 914
					self.visible = true -- 915
				end -- 913
			end) -- 912
			Group({ -- 916
				"unit" -- 916
			}):each(function(self) -- 916
				return self.unit:removeFromParent() -- 916
			end) -- 916
			local unitCount -- 917
			if GameScore < 40 then -- 917
				unitCount = 1 + math.min(2, math.floor(math.max(0, GameScore - 20) / 5)) -- 918
			else -- 920
				unitCount = 3 + math.min(3, math.floor(GameScore / 35)) -- 920
			end -- 917
			if math.random(1, 100) == 1 then -- 921
				Entity({ -- 923
					position = Vec2(-200, 100), -- 923
					order = PlayerLayer, -- 924
					group = PlayerGroup, -- 925
					boss = true, -- 926
					faceRight = true -- 927
				}) -- 922
			else -- 929
				for i = 1, unitCount do -- 929
					Entity({ -- 931
						position = Vec2(-100 * i, 100), -- 931
						order = PlayerLayer, -- 932
						group = PlayerGroup, -- 933
						faceRight = true -- 934
					}) -- 930
				end -- 934
			end -- 921
			if math.random(1, 100) == 1 then -- 935
				Entity({ -- 937
					position = Vec2(200, 100), -- 937
					order = EnemyLayer, -- 938
					group = EnemyGroup, -- 939
					boss = true, -- 940
					faceRight = false -- 941
				}) -- 936
			else -- 943
				for i = 1, unitCount do -- 943
					Entity({ -- 945
						position = Vec2(100 * i, 100), -- 945
						order = EnemyLayer, -- 946
						group = EnemyGroup, -- 947
						faceRight = false -- 948
					}) -- 944
				end -- 948
			end -- 935
			return _with_1:schedule(once(function() -- 949
				local time = 2 -- 950
				cycle(time, function(dt) -- 951
					local width, height -- 952
					do -- 952
						local _obj_0 = App.visualSize -- 952
						width, height = _obj_0.width, _obj_0.height -- 952
					end -- 952
					SetNextWindowPos(Vec2(width / 2 - 150, height / 2 + 30)) -- 953
					SetNextWindowSize(Vec2(300, 50), "FirstUseEver") -- 954
					return Begin("CountDown", { -- 955
						"NoResize", -- 955
						"NoSavedSettings", -- 955
						"NoTitleBar", -- 955
						"NoMove" -- 955
					}, function() -- 955
						return ProgressBar(1.0 - dt, Vec2(-1, 30), string.format("%.2fs", (1 - dt) * time)) -- 956
					end) -- 956
				end) -- 951
				emit("Wasted") -- 957
				if GameScore == 0 then -- 958
					return -- 958
				end -- 958
				Audio:play("Audio/choose.wav") -- 959
				WaitForSignal("WASTED!", 1.5) -- 960
				return emit("Start") -- 961
			end)) -- 961
		end) -- 909
		_with_1:addChild((function() -- 962
			local _with_2 = Node() -- 962
			_with_2:schedule(function() -- 963
				local width, height -- 964
				do -- 964
					local _obj_0 = App.visualSize -- 964
					width, height = _obj_0.width, _obj_0.height -- 964
				end -- 964
				SetNextWindowPos(Vec2(20, 20)) -- 965
				SetNextWindowSize(Vec2(120, 280), "FirstUseEver") -- 966
				return PushStyleVar("ItemSpacing", Vec2.zero, function() -- 967
					return Begin("Stats", { -- 968
						"NoResize", -- 968
						"NoSavedSettings", -- 968
						"NoTitleBar", -- 968
						"NoMove" -- 968
					}, function() -- 968
						Text("VALUE: " .. tostring(GameScore)) -- 969
						Image("Model/patreon.clip|character_handGreen", Vec2(30, 30)) -- 970
						SameLine() -- 971
						Text("->") -- 972
						SameLine() -- 973
						Image("Model/patreon.clip|character_handRed", Vec2(30, 30)) -- 974
						SameLine() -- 975
						Text("x3") -- 976
						Image("Model/patreon.clip|character_handRed", Vec2(30, 30)) -- 977
						SameLine() -- 978
						Text("->") -- 979
						SameLine() -- 980
						Image("Model/patreon.clip|character_handYellow", Vec2(30, 30)) -- 981
						SameLine() -- 982
						Text("x3") -- 983
						Image("Model/patreon.clip|character_handYellow", Vec2(30, 30)) -- 984
						SameLine() -- 985
						Text("->") -- 986
						SameLine() -- 987
						Image("Model/patreon.clip|character_handGreen", Vec2(30, 30)) -- 988
						SameLine() -- 989
						Text("x3") -- 990
						Image("Model/patreon.clip|item_bow", Vec2(30, 30)) -- 991
						SameLine() -- 992
						Text(">") -- 993
						SameLine() -- 994
						Image("Model/patreon.clip|item_sword", Vec2(30, 30)) -- 995
						Image("Model/patreon.clip|item_hatTop", Vec2(30, 30)) -- 996
						SameLine() -- 997
						Text("dodge") -- 998
						Image("Model/patreon.clip|item_helmet", Vec2(30, 30)) -- 999
						SameLine() -- 1000
						Text("rush") -- 1001
						Image("Model/patreon.clip|item_rod", Vec2(30, 30)) -- 1002
						SameLine() -- 1003
						Text("knock") -- 1004
						Image("Model/patreon.clip|tile_heart", Vec2(30, 30)) -- 1005
						SameLine() -- 1006
						return Text("bash") -- 1007
					end) -- 1007
				end) -- 1007
			end) -- 963
			return _with_2 -- 962
		end)()) -- 962
		return _with_1 -- 836
	end)()) -- 836
	return _with_0 -- 806
end)()) -- 806
return emit("Start") -- 1009
