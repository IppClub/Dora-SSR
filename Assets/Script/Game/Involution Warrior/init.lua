-- [yue]: init.yue
local _module_1 = Dora.Platformer -- 1
local Data = _module_1.Data -- 1
local App = Dora.App -- 1
local Vec2 = Dora.Vec2 -- 1
local Size = Dora.Size -- 1
local DrawNode = Dora.DrawNode -- 1
local Color = Dora.Color -- 1
local Line = Dora.Line -- 1
local Group = Dora.Group -- 1
local PlatformWorld = _module_1.PlatformWorld -- 1
local table = _G.table -- 1
local math = _G.math -- 1
local View = Dora.View -- 1
local BodyDef = Dora.BodyDef -- 1
local Body = Dora.Body -- 1
local UnitAction = _module_1.UnitAction -- 1
local once = Dora.once -- 1
local Audio = Dora.Audio -- 1
local Bullet = _module_1.Bullet -- 1
local sleep = Dora.sleep -- 1
local BulletDef = _module_1.BulletDef -- 1
local Face = _module_1.Face -- 1
local cycle = Dora.cycle -- 1
local Rect = Dora.Rect -- 1
local Dictionary = Dora.Dictionary -- 1
local TargetAllow = _module_1.TargetAllow -- 1
local Array = Dora.Array -- 1
local Unit = _module_1.Unit -- 1
local tostring = _G.tostring -- 1
local Sprite = Dora.Sprite -- 1
local pairs = _G.pairs -- 1
local _module_2 = Dora.Platformer.Decision -- 1
local Sel = _module_2.Sel -- 1
local Seq = _module_2.Seq -- 1
local Con = _module_2.Con -- 1
local Accept = _module_2.Accept -- 1
local Act = _module_2.Act -- 1
local AI = _module_2.AI -- 1
local Observer = Dora.Observer -- 1
local Action = Dora.Action -- 1
local Scale = Dora.Scale -- 1
local Ease = Dora.Ease -- 1
local Label = Dora.Label -- 1
local Sequence = Dora.Sequence -- 1
local Y = Dora.Y -- 1
local Opacity = Dora.Opacity -- 1
local Event = Dora.Event -- 1
local Visual = _module_1.Visual -- 1
local emit = Dora.emit -- 1
local Spawn = Dora.Spawn -- 1
local Director = Dora.Director -- 1
local string = _G.string -- 1
local Delay = Dora.Delay -- 1
local Entity = Dora.Entity -- 1
local _module_0 = Dora.ImGui -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local Begin = _module_0.Begin -- 1
local ProgressBar = _module_0.ProgressBar -- 1
local Node = Dora.Node -- 1
local PushStyleVar = _module_0.PushStyleVar -- 1
local Text = _module_0.Text -- 1
local Image = _module_0.Image -- 1
local SameLine = _module_0.SameLine -- 1
local AlignNode = require("UI.Control.Basic.AlignNode") -- 16
local CircleButton = require("UI.Control.Basic.CircleButton") -- 17
local Set = require("Utils").Set -- 18
local Store = Data.store -- 19
local themeColor = App.themeColor -- 21
local mutables = { -- 26
	"hp", -- 26
	"moveSpeed", -- 27
	"move", -- 28
	"jump", -- 29
	"targetAllow", -- 30
	"attackBase", -- 31
	"attackPower", -- 32
	"attackSpeed", -- 33
	"damageType", -- 34
	"attackBonus", -- 35
	"attackFactor", -- 36
	"attackTarget", -- 37
	"defenceType" -- 38
} -- 25
local elementTypes = { -- 42
	Green = 1, -- 42
	Red = 2, -- 43
	Yellow = 3, -- 44
	Purple = 4 -- 45
} -- 41
do -- 47
	local _with_0 = Data -- 47
	_with_0:setDamageFactor(elementTypes.Green, elementTypes.Red, 3) -- 48
	_with_0:setDamageFactor(elementTypes.Red, elementTypes.Yellow, 3) -- 49
	_with_0:setDamageFactor(elementTypes.Yellow, elementTypes.Green, 3) -- 50
end -- 47
local itemSlots = { -- 53
	"head", -- 53
	"mask", -- 54
	"body", -- 55
	"lhand", -- 56
	"rhand" -- 57
} -- 52
local headItems = { -- 60
	"item_hat", -- 60
	"item_hatTop", -- 61
	"item_helmet", -- 62
	"item_helmetModern" -- 63
} -- 59
local lhandItems = { -- 66
	"item_shield", -- 66
	"item_shieldRound", -- 67
	"tile_heart", -- 68
	"ui_hand" -- 69
} -- 65
local rhandItems = { -- 72
	"item_bow", -- 72
	"item_sword", -- 73
	"item_rod", -- 74
	"item_spear" -- 75
} -- 71
local characterTypes = { -- 78
	"square", -- 78
	"round" -- 79
} -- 77
local characterColors = { -- 82
	"Green", -- 82
	"Red", -- 83
	"Yellow" -- 84
} -- 81
local masks = { -- 87
	"bear", -- 87
	"buffalo", -- 88
	"chick", -- 89
	"chicken", -- 90
	"cow", -- 91
	"crocodile", -- 92
	"dog", -- 93
	"duck", -- 94
	"elephant", -- 95
	"frog", -- 96
	"giraffe", -- 97
	"goat", -- 98
	"gorilla", -- 99
	"hippo", -- 100
	"horse", -- 101
	"monkey", -- 102
	"moose", -- 103
	"narwhal", -- 104
	"owl", -- 105
	"panda", -- 106
	"parrot", -- 107
	"penguin", -- 108
	"pig", -- 109
	"rabbit", -- 110
	"rhino", -- 111
	"sloth", -- 112
	"snake", -- 113
	"walrus", -- 114
	"whale", -- 115
	"zebra" -- 116
} -- 86
local itemSettings = { -- 120
	item_hat = { -- 121
		skill = "jump", -- 121
		offset = Vec2(0, 30) -- 122
	}, -- 120
	item_hatTop = { -- 125
		skill = "evade", -- 125
		offset = Vec2(0, 30) -- 126
	}, -- 124
	item_helmet = { -- 129
		skill = "rush", -- 129
		offset = Vec2(0, 0) -- 130
	}, -- 128
	item_helmetModern = { -- 133
		skill = "rush", -- 133
		offset = Vec2(0, 0) -- 134
	}, -- 132
	item_shield = { -- 137
		skill = "", -- 137
		offset = Vec2(0, 0) -- 138
	}, -- 136
	item_shieldRound = { -- 141
		skill = "jump", -- 141
		offset = Vec2(0, 0) -- 142
	}, -- 140
	tile_heart = { -- 145
		skill = "jump", -- 145
		offset = Vec2(0, 0), -- 146
		attackPower = Vec2(600, 0) -- 147
	}, -- 144
	ui_hand = { -- 150
		skill = "evade", -- 150
		offset = Vec2(0, 0) -- 151
	}, -- 149
	item_bow = { -- 154
		skill = "range", -- 154
		offset = Vec2(10, 0), -- 155
		attackRange = Size(550, 150), -- 156
		sndAttack = "Audio/d_att.wav" -- 157
	}, -- 153
	item_sword = { -- 160
		skill = "meleeAttack", -- 160
		offset = Vec2(15, 50), -- 161
		attackRange = Size(120, 150), -- 162
		sndAttack = "Audio/f_att.wav" -- 163
	}, -- 159
	item_rod = { -- 166
		skill = "meleeAttack", -- 166
		offset = Vec2(15, 50), -- 167
		attackRange = Size(200, 150), -- 168
		attackPower = Vec2(100, 800), -- 169
		sndAttack = "Audio/b_att.wav" -- 170
	}, -- 165
	item_spear = { -- 173
		skill = "meleeAttack", -- 173
		offset = Vec2(15, 50), -- 174
		attackRange = Size(200, 150), -- 175
		sndAttack = "Audio/f_att.wav" -- 176
	} -- 172
} -- 119
local GamePaused = true -- 178
local _anon_func_0 = function(Color, Line, Vec2, _with_0, grid, size) -- 204
	local _with_1 = Line() -- 193
	_with_1.depthWrite = true -- 194
	_with_1.z = -10 -- 195
	for i = -size / grid, size / grid do -- 196
		_with_1:add({ -- 198
			Vec2(i * grid, size), -- 198
			Vec2(i * grid, -size) -- 199
		}, Color(0xff000000)) -- 197
		_with_1:add({ -- 202
			Vec2(-size, i * grid), -- 202
			Vec2(size, i * grid) -- 203
		}, Color(0xff000000)) -- 201
	end -- 204
	return _with_1 -- 193
end -- 193
do -- 182
	local size <const>, grid <const> = 1500, 150 -- 183
	local background -- 185
	background = function() -- 185
		local _with_0 = DrawNode() -- 185
		_with_0.depthWrite = true -- 186
		_with_0:drawPolygon({ -- 188
			Vec2(-size, size), -- 188
			Vec2(size, size), -- 189
			Vec2(size, -size), -- 190
			Vec2(-size, -size) -- 191
		}, Color(0xff888888)) -- 187
		_with_0:addChild(_anon_func_0(Color, Line, Vec2, _with_0, grid, size)) -- 193
		return _with_0 -- 185
	end -- 185
	do -- 206
		local _with_0 = background() -- 206
		_with_0.z = 600 -- 207
	end -- 206
	local _with_0 = background() -- 208
	_with_0.angleX = 45 -- 209
end -- 209
local TerrainLayer = 0 -- 213
local EnemyLayer = 1 -- 214
local PlayerLayer = 2 -- 215
local PlayerGroup = 1 -- 217
local EnemyGroup = 2 -- 218
Data:setRelation(PlayerGroup, EnemyGroup, "Enemy") -- 220
Data:setShouldContact(PlayerGroup, EnemyGroup, true) -- 221
local unitGroup = Group({ -- 223
	"unit" -- 223
}) -- 223
local world -- 225
do -- 225
	local _with_0 = PlatformWorld() -- 225
	_with_0:schedule(function() -- 226
		local origin = Vec2.zero -- 227
		local locs = { -- 228
			origin -- 228
		} -- 228
		unitGroup:each(function(self) -- 229
			return table.insert(locs, self.unit.position) -- 229
		end) -- 229
		local dist = 0.0 -- 230
		for _index_0 = 1, #locs do -- 231
			local loc = locs[_index_0] -- 231
			dist = math.max(dist, loc:distance(origin)) -- 232
		end -- 232
		local DesignWidth <const> = 1250 -- 233
		local currentZoom = _with_0.camera.zoom -- 234
		local baseZoom = View.size.width / DesignWidth -- 235
		local targetZoom = baseZoom * math.max(math.min(3.0, (DesignWidth / dist / 4)), 0.8) -- 236
		_with_0.camera.zoom = currentZoom + (targetZoom - currentZoom) * 0.005 -- 237
	end) -- 226
	world = _with_0 -- 225
end -- 225
Store["world"] = world -- 239
local terrainDef -- 241
do -- 241
	local _with_0 = BodyDef() -- 241
	_with_0.type = "Static" -- 242
	_with_0:attachPolygon(Vec2(0, 0), 2500, 10, 0, 1, 1, 0) -- 243
	_with_0:attachPolygon(Vec2(0, 1000), 2500, 10, 0, 1, 1, 0) -- 244
	_with_0:attachPolygon(Vec2(800, 1000), 10, 2000, 0, 1, 1, 0) -- 245
	_with_0:attachPolygon(Vec2(-800, 1000), 10, 2000, 0, 1, 1, 0) -- 246
	terrainDef = _with_0 -- 241
end -- 241
do -- 248
	local _with_0 = Body(terrainDef, world, Vec2.zero) -- 248
	_with_0.order = TerrainLayer -- 249
	_with_0.group = Data.groupTerrain -- 250
	_with_0:addTo(world) -- 251
end -- 248
local rangeAttackEnd -- 255
rangeAttackEnd = function(name, playable) -- 255
	if name == "range" then -- 256
		return playable.parent:stop() -- 256
	end -- 256
end -- 255
UnitAction:add("range", { -- 259
	priority = 3, -- 259
	reaction = 10, -- 260
	recovery = 0.1, -- 261
	queued = true, -- 262
	available = function() -- 263
		return true -- 263
	end, -- 263
	create = function(self) -- 264
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 265
		do -- 265
			local _obj_0 = self.entity -- 270
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 265
		end -- 270
		do -- 271
			local _with_0 = self.playable -- 271
			_with_0.speed = attackSpeed -- 272
			_with_0:play("range") -- 273
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 274
		end -- 271
		return once(function(self) -- 275
			local bulletDef = Store[self.unitDef.bulletType] -- 276
			local onAttack -- 277
			onAttack = function() -- 277
				Audio:play(self.unitDef.sndAttack) -- 278
				local _with_0 = Bullet(bulletDef, self) -- 279
				if self.group == EnemyGroup then -- 280
					_with_0.color = Color(0xff666666) -- 280
				end -- 280
				_with_0.targetAllow = targetAllow -- 281
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 282
					do -- 283
						local _with_1 = target.data -- 283
						_with_1.hitPoint = pos -- 284
						_with_1.hitPower = attackPower -- 285
						_with_1.hitFromRight = bullet.velocityX < 0 -- 286
					end -- 283
					local entity = target.entity -- 287
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 288
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 289
					entity.hp = entity.hp - damage -- 290
					bullet.hitStop = true -- 291
				end) -- 282
				_with_0:addTo(self.world, self.order) -- 292
				return _with_0 -- 279
			end -- 277
			sleep(0.5 * 28.0 / 30.0 / attackSpeed) -- 293
			onAttack() -- 294
			while true do -- 295
				sleep() -- 295
			end -- 295
		end) -- 295
	end, -- 264
	stop = function(self) -- 296
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 297
	end -- 296
}) -- 258
local BigArrow -- 299
do -- 299
	local _with_0 = BulletDef() -- 299
	_with_0.tag = "" -- 300
	_with_0.endEffect = "" -- 301
	_with_0.lifeTime = 5 -- 302
	_with_0.damageRadius = 0 -- 303
	_with_0.highSpeedFix = false -- 304
	_with_0.gravity = Vec2(0, -10) -- 305
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2(-100, 0), 2) -- 306
	_with_0:setAsCircle(10) -- 307
	_with_0:setVelocity(25, 800) -- 308
	BigArrow = _with_0 -- 299
end -- 299
UnitAction:add("multiArrow", { -- 311
	priority = 3, -- 311
	reaction = 10, -- 312
	recovery = 0.1, -- 313
	queued = true, -- 314
	available = function() -- 315
		return true -- 315
	end, -- 315
	create = function(self) -- 316
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 317
		do -- 317
			local _obj_0 = self.entity -- 322
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 317
		end -- 322
		do -- 323
			local _with_0 = self.playable -- 323
			_with_0.speed = attackSpeed -- 324
			_with_0:play("range") -- 325
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 326
		end -- 323
		return once(function(self) -- 327
			local onAttack -- 328
			onAttack = function(angle, speed) -- 328
				BigArrow:setVelocity(angle, speed) -- 329
				local _with_0 = Bullet(BigArrow, self) -- 330
				if self.group == EnemyGroup then -- 331
					_with_0.color = Color(0xff666666) -- 331
				end -- 331
				_with_0.targetAllow = targetAllow -- 332
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 333
					do -- 334
						local _with_1 = target.data -- 334
						_with_1.hitPoint = pos -- 335
						_with_1.hitPower = attackPower -- 336
						_with_1.hitFromRight = bullet.velocityX < 0 -- 337
					end -- 334
					local entity = target.entity -- 338
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 339
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 340
					entity.hp = entity.hp - damage -- 341
					bullet.hitStop = true -- 342
				end) -- 333
				_with_0:addTo(self.world, self.order) -- 343
				return _with_0 -- 330
			end -- 328
			sleep(30.0 / 60.0 / attackSpeed) -- 344
			Audio:play("Audio/d_att.wav") -- 345
			onAttack(30, 1100) -- 346
			onAttack(10, 1000) -- 347
			onAttack(-10, 900) -- 348
			onAttack(-30, 800) -- 349
			onAttack(-50, 700) -- 350
			while true do -- 351
				sleep() -- 351
			end -- 351
		end) -- 351
	end, -- 316
	stop = function(self) -- 352
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 353
	end -- 352
}) -- 310
UnitAction:add("fallOff", { -- 356
	priority = 1, -- 356
	reaction = 1, -- 357
	recovery = 0, -- 358
	available = function(self) -- 359
		return not self.onSurface -- 359
	end, -- 359
	create = function(self) -- 360
		if self.velocityY <= 0 then -- 361
			self.data.fallDown = true -- 362
			local _with_0 = self.playable -- 363
			_with_0.speed = 2.5 -- 364
			_with_0:play("idle") -- 365
		else -- 366
			self.data.fallDown = false -- 366
		end -- 361
		return function(self) -- 367
			if self.onSurface then -- 368
				return true -- 368
			end -- 368
			if not self.data.fallDown and self.velocityY <= 0 then -- 369
				self.data.fallDown = true -- 370
				local _with_0 = self.playable -- 371
				_with_0.speed = 2.5 -- 372
				_with_0:play("idle") -- 373
			end -- 369
			return false -- 374
		end -- 374
	end -- 360
}) -- 355
UnitAction:add("evade", { -- 377
	priority = 10, -- 377
	reaction = 10, -- 378
	recovery = 0, -- 379
	queued = true, -- 380
	available = function() -- 381
		return true -- 381
	end, -- 381
	create = function(self) -- 382
		do -- 383
			local _with_0 = self.playable -- 383
			_with_0.speed = 1.0 -- 384
			_with_0.recovery = 0.0 -- 385
			_with_0:play("bevade") -- 386
		end -- 383
		return once(function(self) -- 387
			local group = self.group -- 388
			self.group = Data.groupHide -- 389
			local dir = self.faceRight and -1 or 1 -- 390
			cycle(0.1, function() -- 391
				self.velocityX = 400 * dir -- 391
			end) -- 391
			self.group = group -- 392
			sleep(0.1) -- 393
			do -- 394
				local _with_0 = self.playable -- 394
				_with_0.speed = 1.0 -- 395
				_with_0:play("idle") -- 396
			end -- 394
			sleep(0.3) -- 397
			return true -- 398
		end) -- 398
	end -- 382
}) -- 376
UnitAction:add("rush", { -- 401
	priority = 10, -- 401
	reaction = 10, -- 402
	recovery = 0, -- 403
	queued = true, -- 404
	available = function() -- 405
		return true -- 405
	end, -- 405
	create = function(self) -- 406
		do -- 407
			local _with_0 = self.playable -- 407
			_with_0.speed = 1.0 -- 408
			_with_0.recovery = 0.0 -- 409
			_with_0:play("fevade") -- 410
		end -- 407
		return once(function(self) -- 411
			local group = self.group -- 412
			self.group = Data.groupHide -- 413
			local dir = self.faceRight and 1 or -1 -- 414
			cycle(0.1, function() -- 415
				self.velocityX = 800 * dir -- 415
			end) -- 415
			self.group = group -- 416
			sleep(0.1) -- 417
			do -- 418
				local _with_0 = self.playable -- 418
				_with_0.speed = 1.0 -- 419
				_with_0:play("idle") -- 420
			end -- 418
			sleep(0.3) -- 421
			return true -- 422
		end) -- 422
	end -- 406
}) -- 400
local spearAttackEnd -- 424
spearAttackEnd = function(name, playable) -- 424
	if name == "spear" then -- 425
		return playable.parent:stop() -- 425
	end -- 425
end -- 424
UnitAction:add("spearAttack", { -- 428
	priority = 3, -- 428
	reaction = 10, -- 429
	recovery = 0.1, -- 430
	queued = true, -- 431
	available = function() -- 432
		return true -- 432
	end, -- 432
	create = function(self) -- 433
		local attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor -- 434
		do -- 434
			local _obj_0 = self.entity -- 438
			attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 434
		end -- 438
		do -- 439
			local _with_0 = self.playable -- 439
			_with_0.speed = attackSpeed -- 440
			_with_0.recovery = 0.2 -- 441
			_with_0:play("spear") -- 442
			_with_0:slot("AnimationEnd", spearAttackEnd) -- 443
		end -- 439
		return once(function(self) -- 444
			sleep(50.0 / 60.0) -- 445
			Audio:play("Audio/f_att.wav") -- 446
			local dir = self.faceRight and 0 or -900 -- 447
			local origin = self.position - Vec2(0, 205) + Vec2(dir, 0) -- 448
			local size = Size(900, 40) -- 449
			world:query(Rect(origin, size), function(body) -- 450
				local entity = body.entity -- 451
				if entity and Data:isEnemy(body, self) then -- 452
					do -- 453
						local _with_0 = body.data -- 453
						_with_0.hitPoint = body.position -- 454
						_with_0.hitPower = attackPower -- 455
						_with_0.hitFromRight = not self.faceRight -- 456
					end -- 453
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 457
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 458
					entity.hp = entity.hp - damage -- 459
				end -- 452
				return false -- 460
			end) -- 450
			while true do -- 461
				sleep() -- 461
			end -- 461
		end) -- 461
	end -- 433
}) -- 427
do -- 463
	local _with_0 = BulletDef() -- 463
	_with_0.tag = "" -- 464
	_with_0.endEffect = "" -- 465
	_with_0.lifeTime = 5 -- 466
	_with_0.damageRadius = 0 -- 467
	_with_0.highSpeedFix = false -- 468
	_with_0.gravity = Vec2(0, -10) -- 469
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2.zero) -- 470
	_with_0:setAsCircle(10) -- 471
	_with_0:setVelocity(25, 800) -- 472
	Store["Bullet_Arrow"] = _with_0 -- 463
end -- 463
local GetBoss -- 474
GetBoss = function(entity, pos, black) -- 474
	local unitDef -- 475
	do -- 475
		local _with_0 = Dictionary() -- 475
		_with_0.linearAcceleration = Vec2(0, -10) -- 476
		_with_0.bodyType = "Dynamic" -- 477
		_with_0.scale = 2 -- 478
		_with_0.density = 10.0 -- 479
		_with_0.friction = 1.0 -- 480
		_with_0.restitution = 0.0 -- 481
		_with_0.playable = "model:Model/bossp.model" -- 482
		_with_0.size = Size(150, 410) -- 483
		_with_0.tag = "Boss" -- 484
		_with_0.sensity = 0 -- 485
		_with_0.move = 100 -- 486
		_with_0.moveSpeed = 1.0 -- 487
		_with_0.jump = 600 -- 488
		_with_0.detectDistance = 1500 -- 489
		_with_0.hp = 30.0 -- 490
		_with_0.attackSpeed = 1.0 -- 491
		_with_0.attackBase = 2.5 -- 492
		_with_0.attackDelay = 50.0 / 60.0 -- 493
		_with_0.attackEffectDelay = 50.0 / 60.0 -- 494
		_with_0.attackBonus = 0.0 -- 495
		_with_0.attackFactor = 1.0 -- 496
		_with_0.attackRange = Size(780, 300) -- 497
		_with_0.attackPower = Vec2(200, 200) -- 498
		_with_0.attackTarget = "Multi" -- 499
		do -- 500
			local conf -- 501
			do -- 501
				local _with_1 = TargetAllow() -- 501
				_with_1.terrainAllowed = true -- 502
				_with_1:allow("Enemy", true) -- 503
				conf = _with_1 -- 501
			end -- 501
			_with_0.targetAllow = conf:toValue() -- 504
		end -- 504
		_with_0.damageType = elementTypes.Purple -- 505
		_with_0.defenceType = elementTypes.Purple -- 506
		_with_0.bulletType = "Bullet_Arrow" -- 507
		_with_0.attackEffect = "" -- 508
		_with_0.hitEffect = "Particle/bloodp.par" -- 509
		_with_0.sndAttack = "Audio/f_att.wav" -- 510
		_with_0.sndFallen = "" -- 511
		_with_0.decisionTree = "AI_Boss" -- 512
		_with_0.usePreciseHit = true -- 513
		_with_0.actions = Array({ -- 515
			"walk", -- 515
			"turn", -- 516
			"meleeAttack", -- 517
			"multiArrow", -- 518
			"spearAttack", -- 519
			"idle", -- 520
			"cancel", -- 521
			"jump", -- 522
			"fall", -- 523
			"fallOff" -- 524
		}) -- 514
		unitDef = _with_0 -- 475
	end -- 475
	for _index_0 = 1, #mutables do -- 526
		local var = mutables[_index_0] -- 526
		entity[var] = unitDef[var] -- 527
	end -- 527
	local _with_0 = Unit(unitDef, world, entity, pos) -- 528
	if black then -- 529
		for i = 1, 7 do -- 530
			local node = _with_0.playable:getNodeByName("w" .. tostring(i)) -- 531
			if node then -- 531
				node.color = Color(0xff666666) -- 532
			end -- 531
		end -- 532
	end -- 529
	local node = _with_0.playable:getNodeByName("mask") -- 533
	if node then -- 533
		node:addChild(Sprite("Model/patreon.clip|" .. tostring(masks[math.random(1, #masks)]))) -- 534
	end -- 533
	return _with_0 -- 528
end -- 474
local _anon_func_1 = function(entity, itemSettings, items, pairs, tostring) -- 555
	local _accum_0 = { } -- 552
	local _len_0 = 1 -- 552
	for _, v in pairs(items) do -- 552
		local skill = itemSettings[v].skill -- 553
		if skill then -- 553
			entity[tostring(skill) .. "Skill"] = true -- 554
			_accum_0[_len_0] = skill -- 555
		end -- 553
		_len_0 = _len_0 + 1 -- 555
	end -- 555
	return _accum_0 -- 555
end -- 552
local _anon_func_2 = function(Color, Sprite, _with_0, black, item, itemSettings, tostring) -- 619
	local _with_1 = Sprite("Model/patreon.clip|" .. tostring(item)) -- 617
	if black then -- 618
		_with_1.color = Color(0xff666666) -- 618
	end -- 618
	_with_1.position = itemSettings[item].offset -- 619
	return _with_1 -- 617
end -- 617
local GetUnit -- 536
GetUnit = function(entity, pos, black) -- 536
	local characterType = characterTypes[math.random(1, #characterTypes)] -- 537
	local characterColor = characterColors[math.random(1, #characterColors)] -- 538
	local character = { -- 540
		body = "character_" .. tostring(characterType) .. tostring(characterColor), -- 540
		lhand = "character_hand" .. tostring(characterColor), -- 541
		rhand = "character_hand" .. tostring(characterColor), -- 542
		mask = masks[math.random(1, #masks)] -- 543
	} -- 539
	local items = { -- 545
		head = headItems[math.random(1, #headItems)], -- 545
		lhand = lhandItems[math.random(1, #lhandItems)], -- 546
		rhand = rhandItems[math.random(1, #rhandItems)] -- 547
	} -- 544
	local attackRange = itemSettings[items.rhand].attackRange or Size(350, 150) -- 548
	local bonusPower = itemSettings[items.lhand].attackPower or Vec2.zero -- 549
	local attackPower = bonusPower + (itemSettings[items.rhand].attackPower or Vec2(100, 100)) -- 550
	local sndAttack = itemSettings[items.rhand].sndAttack or "" -- 551
	local skills = Set(_anon_func_1(entity, itemSettings, items, pairs, tostring)) -- 552
	local actions = Array({ -- 557
		"walk", -- 557
		"turn", -- 558
		"idle", -- 559
		"cancel", -- 560
		"hit", -- 561
		"fall", -- 562
		"fallOff" -- 563
	}) -- 556
	for k in pairs(skills) do -- 565
		actions:add(k) -- 566
	end -- 566
	local unitDef -- 567
	do -- 567
		local _with_0 = Dictionary() -- 567
		_with_0.linearAcceleration = Vec2(0, -10) -- 568
		_with_0.bodyType = "Dynamic" -- 569
		_with_0.scale = 1 -- 570
		_with_0.density = 1.0 -- 571
		_with_0.friction = 1.0 -- 572
		_with_0.restitution = 0.0 -- 573
		_with_0.playable = "model:Model/patreon.model" -- 574
		_with_0.size = Size(64, 128) -- 575
		_with_0.tag = "Fighter" -- 576
		_with_0.sensity = 0 -- 577
		_with_0.move = 250 -- 578
		_with_0.moveSpeed = 1.0 -- 579
		_with_0.jump = 700 -- 580
		_with_0.detectDistance = 800 -- 581
		_with_0.hp = 10.0 -- 582
		_with_0.attackSpeed = 1.0 -- 583
		_with_0.attackBase = 2.5 -- 584
		_with_0.attackDelay = 20.0 / 60.0 -- 585
		_with_0.attackEffectDelay = 20.0 / 60.0 -- 586
		_with_0.attackBonus = 0.0 -- 587
		_with_0.attackFactor = 1.0 -- 588
		_with_0.attackRange = attackRange -- 589
		_with_0.attackPower = attackPower -- 590
		_with_0.attackTarget = "Single" -- 591
		do -- 592
			local conf -- 593
			do -- 593
				local _with_1 = TargetAllow() -- 593
				_with_1.terrainAllowed = true -- 594
				_with_1:allow("Enemy", true) -- 595
				conf = _with_1 -- 593
			end -- 593
			_with_0.targetAllow = conf:toValue() -- 596
		end -- 596
		_with_0.damageType = elementTypes[characterColor] -- 597
		_with_0.defenceType = elementTypes[characterColor] -- 598
		_with_0.bulletType = "Bullet_Arrow" -- 599
		_with_0.attackEffect = "" -- 600
		_with_0.hitEffect = "Particle/bloodp.par" -- 601
		_with_0.name = "Fighter" -- 602
		_with_0.desc = "" -- 603
		_with_0.sndAttack = sndAttack -- 604
		_with_0.sndFallen = "" -- 605
		_with_0.decisionTree = "AI_Common" -- 606
		_with_0.usePreciseHit = true -- 607
		_with_0.actions = actions -- 608
		unitDef = _with_0 -- 567
	end -- 567
	for _index_0 = 1, #mutables do -- 609
		local var = mutables[_index_0] -- 609
		entity[var] = unitDef[var] -- 610
	end -- 610
	local _with_0 = Unit(unitDef, world, entity, pos) -- 611
	for _index_0 = 1, #itemSlots do -- 612
		local slot = itemSlots[_index_0] -- 612
		local node = _with_0.playable:getNodeByName(slot) -- 613
		do -- 614
			local item = character[slot] -- 614
			if item then -- 614
				node:addChild(Sprite("Model/patreon.clip|" .. tostring(item))) -- 615
			end -- 614
		end -- 614
		local item = items[slot] -- 616
		if item then -- 616
			node:addChild(_anon_func_2(Color, Sprite, _with_0, black, item, itemSettings, tostring)) -- 617
		end -- 616
	end -- 619
	return _with_0 -- 611
end -- 536
Store["AI_Common"] = Sel({ -- 624
	Seq({ -- 625
		Con("is dead", function(self) -- 625
			return self.entity.hp <= 0 -- 625
		end), -- 625
		Accept() -- 626
	}), -- 624
	Seq({ -- 629
		Con("is falling", function(self) -- 629
			return not self.onSurface -- 629
		end), -- 629
		Act("fallOff") -- 630
	}), -- 628
	Seq({ -- 633
		Con("game paused", function() -- 633
			return GamePaused -- 633
		end), -- 633
		Act("idle") -- 634
	}), -- 632
	Seq({ -- 637
		Con("is not attacking", function(self) -- 637
			return not self:isDoing("melee") and not self:isDoing("range") -- 639
		end), -- 637
		Con("need attack", function(self) -- 640
			local attackUnits = AI:getUnitsInAttackRange() -- 641
			for _index_0 = 1, #attackUnits do -- 642
				local unit = attackUnits[_index_0] -- 642
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 643
					return true -- 645
				end -- 643
			end -- 645
			return false -- 646
		end), -- 640
		Sel({ -- 648
			Seq({ -- 649
				Con("attack", function() -- 649
					return App.rand % 10 == 0 -- 649
				end), -- 649
				Sel({ -- 651
					Act("meleeAttack"), -- 651
					Act("range") -- 652
				}) -- 650
			}), -- 648
			Act("idle") -- 655
		}) -- 647
	}), -- 636
	Seq({ -- 659
		Con("rush or evade", function(self) -- 659
			return not self:isDoing("rush") and not self:isDoing("evade") and App.rand % 300 == 0 -- 660
		end), -- 659
		Sel({ -- 662
			Seq({ -- 663
				Con("too far away", function(self) -- 663
					if self.entity.rushSkill then -- 664
						local units = AI:getDetectedUnits() -- 665
						for _index_0 = 1, #units do -- 666
							local unit = units[_index_0] -- 666
							if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight and self.position:distance(unit.position) > 300 then -- 667
								return true -- 669
							end -- 667
						end -- 669
					end -- 664
					return false -- 670
				end), -- 663
				Act("rush") -- 671
			}), -- 662
			Seq({ -- 674
				Con("too close", function(self) -- 674
					if self.entity.evadeSkill then -- 675
						local units = AI:getDetectedUnits() -- 676
						for _index_0 = 1, #units do -- 677
							local unit = units[_index_0] -- 677
							if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight and self.position:distance(unit.position) < 300 then -- 678
								return true -- 680
							end -- 678
						end -- 680
					end -- 675
					return false -- 681
				end), -- 674
				Act("evade") -- 682
			}) -- 673
		}) -- 661
	}), -- 658
	Seq({ -- 687
		Con("need turn", function(self) -- 687
			return (self.x < -750 and not self.faceRight) or (self.x > 750 and self.faceRight) -- 688
		end), -- 687
		Act("turn") -- 689
	}), -- 686
	Act("walk") -- 691
}) -- 623
Store["AI_Boss"] = Sel({ -- 695
	Seq({ -- 696
		Con("is dead", function(self) -- 696
			return self.entity.hp <= 0 -- 696
		end), -- 696
		Accept() -- 697
	}), -- 695
	Seq({ -- 700
		Con("is falling", function(self) -- 700
			return not self.onSurface -- 700
		end), -- 700
		Act("fallOff") -- 701
	}), -- 699
	Seq({ -- 704
		Con("game paused", function() -- 704
			return GamePaused -- 704
		end), -- 704
		Act("idle") -- 705
	}), -- 703
	Seq({ -- 708
		Con("is not attacking", function(self) -- 708
			return not self:isDoing("meleeAttack") and not self:isDoing("multiArrow") and not self:isDoing("spearAttack") -- 711
		end), -- 708
		Con("need attack", function(self) -- 712
			local attackUnits = AI:getUnitsInAttackRange() -- 713
			for _index_0 = 1, #attackUnits do -- 714
				local unit = attackUnits[_index_0] -- 714
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 715
					return true -- 717
				end -- 715
			end -- 717
			return false -- 718
		end), -- 712
		Sel({ -- 720
			Seq({ -- 721
				Con("melee attack", function() -- 721
					return App.rand % 40 == 0 -- 721
				end), -- 721
				Act("meleeAttack") -- 722
			}), -- 720
			Seq({ -- 725
				Con("multi Arrow", function() -- 725
					return App.rand % 40 == 0 -- 725
				end), -- 725
				Act("multiArrow") -- 726
			}), -- 724
			Seq({ -- 729
				Con("spear attack", function() -- 729
					return App.rand % 40 == 0 -- 729
				end), -- 729
				Act("spearAttack") -- 730
			}), -- 728
			Act("idle") -- 732
		}) -- 719
	}), -- 707
	Seq({ -- 736
		Con("need turn", function(self) -- 736
			return (self.x < -750 and not self.faceRight) or (self.x > 750 and self.faceRight) -- 737
		end), -- 736
		Act("turn") -- 738
	}), -- 735
	Act("walk") -- 740
}) -- 694
do -- 743
	local _with_0 = Observer("Add", { -- 743
		"position", -- 743
		"order", -- 743
		"group", -- 743
		"faceRight" -- 743
	}) -- 743
	_with_0:watch(function(self, position, order, group, faceRight) -- 744
		world = Store.world -- 745
		if group == PlayerGroup then -- 746
			self.player = true -- 746
		end -- 746
		if group == EnemyGroup then -- 747
			self.enemy = true -- 747
		end -- 747
		do -- 748
			local _with_1 -- 748
			if self.boss then -- 748
				_with_1 = GetBoss(self, position, group == EnemyGroup) -- 749
			else -- 751
				_with_1 = GetUnit(self, position, group == EnemyGroup) -- 751
			end -- 748
			_with_1.group = group -- 752
			_with_1.order = order -- 753
			_with_1.playable:runAction(Action(Scale(0.5, 0, self.unit.unitDef.scale, Ease.OutBack))) -- 754
			_with_1.faceRight = faceRight -- 755
			_with_1:addTo(world) -- 756
		end -- 748
		return false -- 756
	end) -- 744
end -- 743
do -- 758
	local _with_0 = Observer("Change", { -- 758
		"hp", -- 758
		"unit" -- 758
	}) -- 758
	_with_0:watch(function(self, hp, unit) -- 759
		local boss = self.boss -- 760
		local lastHp = self.oldValues.hp -- 761
		if hp < lastHp then -- 762
			if not boss and unit:isDoing("hit") then -- 763
				unit:start("cancel") -- 763
			end -- 763
			do -- 764
				local _with_1 = Label("sarasa-mono-sc-regular", 30) -- 764
				_with_1.order = PlayerLayer -- 765
				_with_1.color = Color(0xffff0000) -- 766
				_with_1.position = unit.position + Vec2(0, 40) -- 767
				_with_1.text = "-" .. tostring(lastHp - hp) -- 768
				_with_1:runAction(Action(Sequence(Y(0.5, _with_1.y, _with_1.y + 100), Opacity(0.2, 1, 0), Event("End")))) -- 769
				_with_1:slot("End", function() -- 774
					return _with_1:removeFromParent() -- 774
				end) -- 774
				_with_1:addTo(world) -- 775
			end -- 764
			if boss then -- 776
				local _with_1 = Visual("Particle/bloodp.par") -- 777
				_with_1.position = unit.data.hitPoint -- 778
				_with_1:addTo(world, unit.order) -- 779
				_with_1:autoRemove() -- 780
				_with_1:start() -- 781
			end -- 776
			if hp > 0 then -- 782
				unit:start("hit") -- 783
			else -- 785
				unit:start("cancel") -- 785
				unit:start("hit") -- 786
				unit:start("fall") -- 787
				unit.group = Data.groupHide -- 788
				unit:schedule(once(function() -- 789
					sleep(3) -- 790
					unit:removeFromParent() -- 791
					if not Group({ -- 792
						"unit" -- 792
					}):each(function(self) -- 792
						return self.group == PlayerGroup -- 792
					end) then -- 792
						return emit("Lost") -- 793
					elseif not Group({ -- 794
						"unit" -- 794
					}):each(function(self) -- 794
						return self.group == EnemyGroup -- 794
					end) then -- 794
						return emit("Win") -- 795
					end -- 792
				end)) -- 789
			end -- 782
		end -- 762
		return false -- 795
	end) -- 759
end -- 758
local WaitForSignal -- 797
WaitForSignal = function(text, duration) -- 797
	local _with_0 = Label("sarasa-mono-sc-regular", 100) -- 798
	_with_0.color = themeColor -- 799
	_with_0.text = text -- 800
	_with_0:runAction(Spawn(Scale(0.5, 0.3, 1, Ease.OutBack), Opacity(0.3, 0, 1))) -- 801
	sleep(duration - 0.3) -- 805
	_with_0:runAction(Spawn(Scale(0.3, 1, 1.5, Ease.OutQuad), Opacity(0.3, 1, 0, Ease.OutQuad))) -- 806
	sleep(0.3) -- 810
	_with_0:removeFromParent() -- 811
	return _with_0 -- 798
end -- 797
local GameScore = 20 -- 813
local uiScale = App.devicePixelRatio -- 815
local _anon_func_3 = function(Delay, Ease, Event, Label, Opacity, Scale, Sequence, Spawn, _with_1, string, themeColor, tostring, value) -- 840
	local _with_0 = Label("sarasa-mono-sc-regular", 64) -- 825
	_with_0.color = themeColor -- 826
	_with_0.text = string.format(tostring(value > 0 and '+' or '') .. "%d", value) -- 827
	_with_0:runAction(Sequence(Spawn(Scale(0.5, 0.3, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(0.5), Spawn(Scale(0.3, 1, 1.5, Ease.OutQuad), Opacity(0.3, 1, 0, Ease.OutQuad)), Event("End"))) -- 828
	_with_0:slot("End", function() -- 840
		return _with_0:removeFromParent() -- 840
	end) -- 840
	return _with_0 -- 825
end -- 825
Director.ui:addChild((function() -- 816
	local _with_0 = AlignNode({ -- 816
		isRoot = true -- 816
	}) -- 816
	_with_0:addChild((function() -- 817
		local _with_1 = AlignNode() -- 817
		_with_1.size = Size(0, 0) -- 818
		_with_1.hAlign = "Left" -- 819
		_with_1.vAlign = "Top" -- 820
		local offset = Vec2(360, 80) * (uiScale / 2) -- 821
		_with_1.alignOffset = offset -- 822
		_with_1:gslot("AddScore", function(value) -- 823
			if value < 0 and GameScore == 0 then -- 824
				return -- 824
			end -- 824
			_with_1:addChild(_anon_func_3(Delay, Ease, Event, Label, Opacity, Scale, Sequence, Spawn, _with_1, string, themeColor, tostring, value)) -- 825
			GameScore = math.max(0, GameScore + value) -- 841
			if GameScore == 0 then -- 842
				return _with_1:schedule(once(function() -- 843
					Audio:play("Audio/game_over.wav") -- 844
					WaitForSignal("FOREVER LOST!", 3) -- 845
					return emit("GameLost") -- 846
				end)) -- 846
			end -- 842
		end) -- 823
		return _with_1 -- 817
	end)()) -- 817
	_with_0:addChild((function() -- 847
		local _with_1 = AlignNode() -- 847
		_with_1.size = Size(0, 0) -- 848
		_with_1.hAlign = "Center" -- 849
		_with_1.vAlign = "Center" -- 850
		_with_1.alignOffset = Vec2(0, -300 * (uiScale / 2)) -- 851
		_with_1:addChild((function() -- 852
			local _with_2 = CircleButton({ -- 853
				text = "STRIKE\nBACK", -- 853
				radius = 80, -- 854
				fontName = "sarasa-mono-sc-regular", -- 855
				fontSize = 48 -- 856
			}) -- 852
			_with_2.visible = false -- 858
			_with_2.touchEnabled = false -- 859
			_with_2:gslot("GameLost", function() -- 860
				_with_2.visible = true -- 861
				_with_2.touchEnabled = true -- 862
			end) -- 860
			_with_2:slot("Tapped", function() -- 863
				_with_2.touchEnabled = false -- 864
				Audio:play("Audio/v_att.wav") -- 865
				return _with_2:schedule(once(function() -- 866
					sleep(0.5) -- 867
					_with_2.visible = false -- 868
					emit("AddScore", 20) -- 869
					return emit("Start") -- 870
				end)) -- 870
			end) -- 863
			return _with_2 -- 852
		end)()) -- 852
		_with_1:addChild((function() -- 871
			local _with_2 = CircleButton({ -- 872
				text = "FIGHT", -- 872
				x = -200, -- 873
				radius = 80, -- 874
				fontName = "sarasa-mono-sc-regular", -- 875
				fontSize = 48 -- 876
			}) -- 871
			_with_2:slot("Tapped", function() -- 878
				if GameScore <= 0 then -- 879
					return -- 879
				end -- 879
				GamePaused = false -- 880
				return _with_2:schedule(once(function() -- 881
					emit("Fight") -- 882
					Audio:play("Audio/choose.wav") -- 883
					return WaitForSignal("FIGHT!", 1) -- 884
				end)) -- 884
			end) -- 878
			return _with_2 -- 871
		end)()) -- 871
		_with_1:addChild((function() -- 885
			local _with_2 = CircleButton({ -- 886
				text = "ANOTHER\nWAY", -- 886
				x = 200, -- 887
				radius = 80, -- 888
				fontName = "sarasa-mono-sc-regular", -- 889
				fontSize = 48 -- 890
			}) -- 885
			_with_2:slot("Tapped", function() -- 892
				Audio:play("Audio/switch.wav") -- 893
				emit("AddScore", -5) -- 894
				return emit("Start") -- 895
			end) -- 892
			return _with_2 -- 885
		end)()) -- 885
		_with_1:gslot("Lost", function() -- 896
			return _with_1:schedule(once(function() -- 897
				emit("AddScore", -(10 + math.floor(GameScore / 20) * 5)) -- 898
				if GameScore == 0 then -- 899
					return -- 899
				end -- 899
				Audio:play("Audio/hero_fall.wav") -- 900
				WaitForSignal("LOST!", 1.5) -- 901
				return emit("Start") -- 902
			end)) -- 902
		end) -- 896
		_with_1:gslot("Win", function() -- 903
			return _with_1:schedule(once(function() -- 904
				local score = 5 * Group({ -- 905
					"player" -- 905
				}).count -- 905
				emit("AddScore", score) -- 906
				Audio:play("Audio/hero_win.wav") -- 907
				WaitForSignal("WIN!", 1.5) -- 908
				return emit("Start") -- 909
			end)) -- 909
		end) -- 903
		_with_1:gslot("Wasted", function() -- 910
			_with_1:eachChild(function(self) -- 911
				self.visible = false -- 912
				self.touchEnabled = false -- 913
			end) -- 911
			return emit("AddScore", -20) -- 914
		end) -- 910
		_with_1:gslot("Fight", function() -- 915
			_with_1:eachChild(function(self) -- 916
				self.visible = false -- 917
				self.touchEnabled = false -- 918
			end) -- 916
			return _with_1:unschedule() -- 919
		end) -- 915
		_with_1:gslot("Start", function() -- 920
			if GameScore == 0 then -- 921
				return -- 921
			end -- 921
			GamePaused = true -- 922
			_with_1:eachChild(function(self) -- 923
				if self.text ~= "STRIKE\nBACK" then -- 924
					self.touchEnabled = true -- 925
					self.visible = true -- 926
				end -- 924
			end) -- 923
			Group({ -- 927
				"unit" -- 927
			}):each(function(self) -- 927
				return self.unit:removeFromParent() -- 927
			end) -- 927
			local unitCount -- 928
			if GameScore < 40 then -- 928
				unitCount = 1 + math.min(2, math.floor(math.max(0, GameScore - 20) / 5)) -- 929
			else -- 931
				unitCount = 3 + math.min(3, math.floor(GameScore / 35)) -- 931
			end -- 928
			if math.random(1, 100) == 1 then -- 932
				Entity({ -- 934
					position = Vec2(-200, 100), -- 934
					order = PlayerLayer, -- 935
					group = PlayerGroup, -- 936
					boss = true, -- 937
					faceRight = true -- 938
				}) -- 933
			else -- 940
				for i = 1, unitCount do -- 940
					Entity({ -- 942
						position = Vec2(-100 * i, 100), -- 942
						order = PlayerLayer, -- 943
						group = PlayerGroup, -- 944
						faceRight = true -- 945
					}) -- 941
				end -- 945
			end -- 932
			if math.random(1, 100) == 1 then -- 946
				Entity({ -- 948
					position = Vec2(200, 100), -- 948
					order = EnemyLayer, -- 949
					group = EnemyGroup, -- 950
					boss = true, -- 951
					faceRight = false -- 952
				}) -- 947
			else -- 954
				for i = 1, unitCount do -- 954
					Entity({ -- 956
						position = Vec2(100 * i, 100), -- 956
						order = EnemyLayer, -- 957
						group = EnemyGroup, -- 958
						faceRight = false -- 959
					}) -- 955
				end -- 959
			end -- 946
			return _with_1:schedule(once(function() -- 960
				local time = 2 -- 961
				cycle(time, function(dt) -- 962
					local width, height -- 963
					do -- 963
						local _obj_0 = App.visualSize -- 963
						width, height = _obj_0.width, _obj_0.height -- 963
					end -- 963
					SetNextWindowPos(Vec2(width / 2 - 150, height / 2 + 30)) -- 964
					SetNextWindowSize(Vec2(300, 50), "FirstUseEver") -- 965
					return Begin("CountDown", { -- 966
						"NoResize", -- 966
						"NoSavedSettings", -- 966
						"NoTitleBar", -- 966
						"NoMove" -- 966
					}, function() -- 966
						return ProgressBar(1.0 - dt, Vec2(-1, 30), string.format("%.2fs", (1 - dt) * time)) -- 967
					end) -- 967
				end) -- 962
				emit("Wasted") -- 968
				if GameScore == 0 then -- 969
					return -- 969
				end -- 969
				Audio:play("Audio/choose.wav") -- 970
				WaitForSignal("WASTED!", 1.5) -- 971
				return emit("Start") -- 972
			end)) -- 972
		end) -- 920
		_with_1:addChild((function() -- 973
			local _with_2 = Node() -- 973
			_with_2:schedule(function() -- 974
				SetNextWindowPos(Vec2(20, 20)) -- 975
				SetNextWindowSize(Vec2(120, 280), "FirstUseEver") -- 976
				return PushStyleVar("ItemSpacing", Vec2.zero, function() -- 977
					return Begin("Stats", { -- 978
						"NoResize", -- 978
						"NoSavedSettings", -- 978
						"NoTitleBar", -- 978
						"NoMove" -- 978
					}, function() -- 978
						Text("VALUE: " .. tostring(GameScore)) -- 979
						Image("Model/patreon.clip|character_handGreen", Vec2(30, 30)) -- 980
						SameLine() -- 981
						Text("->") -- 982
						SameLine() -- 983
						Image("Model/patreon.clip|character_handRed", Vec2(30, 30)) -- 984
						SameLine() -- 985
						Text("x3") -- 986
						Image("Model/patreon.clip|character_handRed", Vec2(30, 30)) -- 987
						SameLine() -- 988
						Text("->") -- 989
						SameLine() -- 990
						Image("Model/patreon.clip|character_handYellow", Vec2(30, 30)) -- 991
						SameLine() -- 992
						Text("x3") -- 993
						Image("Model/patreon.clip|character_handYellow", Vec2(30, 30)) -- 994
						SameLine() -- 995
						Text("->") -- 996
						SameLine() -- 997
						Image("Model/patreon.clip|character_handGreen", Vec2(30, 30)) -- 998
						SameLine() -- 999
						Text("x3") -- 1000
						Image("Model/patreon.clip|item_bow", Vec2(30, 30)) -- 1001
						SameLine() -- 1002
						Text(">") -- 1003
						SameLine() -- 1004
						Image("Model/patreon.clip|item_sword", Vec2(30, 30)) -- 1005
						Image("Model/patreon.clip|item_hatTop", Vec2(30, 30)) -- 1006
						SameLine() -- 1007
						Text("dodge") -- 1008
						Image("Model/patreon.clip|item_helmet", Vec2(30, 30)) -- 1009
						SameLine() -- 1010
						Text("rush") -- 1011
						Image("Model/patreon.clip|item_rod", Vec2(30, 30)) -- 1012
						SameLine() -- 1013
						Text("knock") -- 1014
						Image("Model/patreon.clip|tile_heart", Vec2(30, 30)) -- 1015
						SameLine() -- 1016
						return Text("bash") -- 1017
					end) -- 1017
				end) -- 1017
			end) -- 974
			return _with_2 -- 973
		end)()) -- 973
		return _with_1 -- 847
	end)()) -- 847
	return _with_0 -- 816
end)()) -- 816
return emit("Start") -- 1019
