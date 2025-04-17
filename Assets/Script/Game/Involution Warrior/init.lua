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
local AlignNode = Dora.AlignNode -- 1
local Delay = Dora.Delay -- 1
local string = _G.string -- 1
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
local CircleButton = require("UI.Control.Basic.CircleButton") -- 16
local Set = require("Utils").Set -- 17
local Store = Data.store -- 18
local themeColor = App.themeColor -- 20
local mutables = { -- 25
	"hp", -- 25
	"moveSpeed", -- 26
	"move", -- 27
	"jump", -- 28
	"targetAllow", -- 29
	"attackBase", -- 30
	"attackPower", -- 31
	"attackSpeed", -- 32
	"damageType", -- 33
	"attackBonus", -- 34
	"attackFactor", -- 35
	"attackTarget", -- 36
	"defenceType" -- 37
} -- 24
local elementTypes = { -- 41
	Green = 1, -- 41
	Red = 2, -- 42
	Yellow = 3, -- 43
	Purple = 4 -- 44
} -- 40
do -- 46
	local _with_0 = Data -- 46
	_with_0:setDamageFactor(elementTypes.Green, elementTypes.Red, 3) -- 47
	_with_0:setDamageFactor(elementTypes.Red, elementTypes.Yellow, 3) -- 48
	_with_0:setDamageFactor(elementTypes.Yellow, elementTypes.Green, 3) -- 49
end -- 46
local itemSlots = { -- 52
	"head", -- 52
	"mask", -- 53
	"body", -- 54
	"lhand", -- 55
	"rhand" -- 56
} -- 51
local headItems = { -- 59
	"item_hat", -- 59
	"item_hatTop", -- 60
	"item_helmet", -- 61
	"item_helmetModern" -- 62
} -- 58
local lhandItems = { -- 65
	"item_shield", -- 65
	"item_shieldRound", -- 66
	"tile_heart", -- 67
	"ui_hand" -- 68
} -- 64
local rhandItems = { -- 71
	"item_bow", -- 71
	"item_sword", -- 72
	"item_rod", -- 73
	"item_spear" -- 74
} -- 70
local characterTypes = { -- 77
	"square", -- 77
	"round" -- 78
} -- 76
local characterColors = { -- 81
	"Green", -- 81
	"Red", -- 82
	"Yellow" -- 83
} -- 80
local masks = { -- 86
	"bear", -- 86
	"buffalo", -- 87
	"chick", -- 88
	"chicken", -- 89
	"cow", -- 90
	"crocodile", -- 91
	"dog", -- 92
	"duck", -- 93
	"elephant", -- 94
	"frog", -- 95
	"giraffe", -- 96
	"goat", -- 97
	"gorilla", -- 98
	"hippo", -- 99
	"horse", -- 100
	"monkey", -- 101
	"moose", -- 102
	"narwhal", -- 103
	"owl", -- 104
	"panda", -- 105
	"parrot", -- 106
	"penguin", -- 107
	"pig", -- 108
	"rabbit", -- 109
	"rhino", -- 110
	"sloth", -- 111
	"snake", -- 112
	"walrus", -- 113
	"whale", -- 114
	"zebra" -- 115
} -- 85
local itemSettings = { -- 119
	item_hat = { -- 120
		skill = "jump", -- 120
		offset = Vec2(0, 30) -- 121
	}, -- 119
	item_hatTop = { -- 124
		skill = "evade", -- 124
		offset = Vec2(0, 30) -- 125
	}, -- 123
	item_helmet = { -- 128
		skill = "rush", -- 128
		offset = Vec2(0, 0) -- 129
	}, -- 127
	item_helmetModern = { -- 132
		skill = "rush", -- 132
		offset = Vec2(0, 0) -- 133
	}, -- 131
	item_shield = { -- 136
		skill = "", -- 136
		offset = Vec2(0, 0) -- 137
	}, -- 135
	item_shieldRound = { -- 140
		skill = "jump", -- 140
		offset = Vec2(0, 0) -- 141
	}, -- 139
	tile_heart = { -- 144
		skill = "jump", -- 144
		offset = Vec2(0, 0), -- 145
		attackPower = Vec2(600, 0) -- 146
	}, -- 143
	ui_hand = { -- 149
		skill = "evade", -- 149
		offset = Vec2(0, 0) -- 150
	}, -- 148
	item_bow = { -- 153
		skill = "range", -- 153
		offset = Vec2(10, 0), -- 154
		attackRange = Size(550, 150), -- 155
		sndAttack = "Audio/d_att.wav" -- 156
	}, -- 152
	item_sword = { -- 159
		skill = "meleeAttack", -- 159
		offset = Vec2(15, 50), -- 160
		attackRange = Size(120, 150), -- 161
		sndAttack = "Audio/f_att.wav" -- 162
	}, -- 158
	item_rod = { -- 165
		skill = "meleeAttack", -- 165
		offset = Vec2(15, 50), -- 166
		attackRange = Size(200, 150), -- 167
		attackPower = Vec2(100, 800), -- 168
		sndAttack = "Audio/b_att.wav" -- 169
	}, -- 164
	item_spear = { -- 172
		skill = "meleeAttack", -- 172
		offset = Vec2(15, 50), -- 173
		attackRange = Size(200, 150), -- 174
		sndAttack = "Audio/f_att.wav" -- 175
	} -- 171
} -- 118
local GamePaused = true -- 177
local _anon_func_0 = function(Color, Line, Vec2, _with_0, grid, size) -- 203
	local _with_1 = Line() -- 192
	_with_1.depthWrite = true -- 193
	_with_1.z = -10 -- 194
	for i = -size / grid, size / grid do -- 195
		_with_1:add({ -- 197
			Vec2(i * grid, size), -- 197
			Vec2(i * grid, -size) -- 198
		}, Color(0xff000000)) -- 196
		_with_1:add({ -- 201
			Vec2(-size, i * grid), -- 201
			Vec2(size, i * grid) -- 202
		}, Color(0xff000000)) -- 200
	end -- 203
	return _with_1 -- 192
end -- 192
do -- 181
	local size <const>, grid <const> = 1500, 150 -- 182
	local background -- 184
	background = function() -- 184
		local _with_0 = DrawNode() -- 184
		_with_0.depthWrite = true -- 185
		_with_0:drawPolygon({ -- 187
			Vec2(-size, size), -- 187
			Vec2(size, size), -- 188
			Vec2(size, -size), -- 189
			Vec2(-size, -size) -- 190
		}, Color(0xff888888)) -- 186
		_with_0:addChild(_anon_func_0(Color, Line, Vec2, _with_0, grid, size)) -- 192
		return _with_0 -- 184
	end -- 184
	do -- 205
		local _with_0 = background() -- 205
		_with_0.z = 600 -- 206
	end -- 205
	local _with_0 = background() -- 207
	_with_0.angleX = 45 -- 208
end -- 208
local TerrainLayer = 0 -- 212
local EnemyLayer = 1 -- 213
local PlayerLayer = 2 -- 214
local PlayerGroup = 1 -- 216
local EnemyGroup = 2 -- 217
Data:setRelation(PlayerGroup, EnemyGroup, "Enemy") -- 219
Data:setShouldContact(PlayerGroup, EnemyGroup, true) -- 220
local unitGroup = Group({ -- 222
	"unit" -- 222
}) -- 222
local world -- 224
do -- 224
	local _with_0 = PlatformWorld() -- 224
	_with_0:schedule(function() -- 225
		local origin = Vec2.zero -- 226
		local locs = { -- 227
			origin -- 227
		} -- 227
		unitGroup:each(function(self) -- 228
			return table.insert(locs, self.unit.position) -- 228
		end) -- 228
		local dist = 0.0 -- 229
		for _index_0 = 1, #locs do -- 230
			local loc = locs[_index_0] -- 230
			dist = math.max(dist, loc:distance(origin)) -- 231
		end -- 231
		local DesignWidth <const> = 1250 -- 232
		local currentZoom = _with_0.camera.zoom -- 233
		local baseZoom = View.size.width / DesignWidth -- 234
		local targetZoom = baseZoom * math.max(math.min(3.0, (DesignWidth / dist / 4)), 0.8) -- 235
		_with_0.camera.zoom = currentZoom + (targetZoom - currentZoom) * 0.005 -- 236
	end) -- 225
	world = _with_0 -- 224
end -- 224
Store["world"] = world -- 238
local terrainDef -- 240
do -- 240
	local _with_0 = BodyDef() -- 240
	_with_0.type = "Static" -- 241
	_with_0:attachPolygon(Vec2(0, 0), 2500, 10, 0, 1, 1, 0) -- 242
	_with_0:attachPolygon(Vec2(0, 1000), 2500, 10, 0, 1, 1, 0) -- 243
	_with_0:attachPolygon(Vec2(800, 1000), 10, 2000, 0, 1, 1, 0) -- 244
	_with_0:attachPolygon(Vec2(-800, 1000), 10, 2000, 0, 1, 1, 0) -- 245
	terrainDef = _with_0 -- 240
end -- 240
do -- 247
	local _with_0 = Body(terrainDef, world, Vec2.zero) -- 247
	_with_0.order = TerrainLayer -- 248
	_with_0.group = Data.groupTerrain -- 249
	_with_0:addTo(world) -- 250
end -- 247
local rangeAttackEnd -- 254
rangeAttackEnd = function(name, playable) -- 254
	if name == "range" then -- 255
		return playable.parent:stop() -- 255
	end -- 255
end -- 254
UnitAction:add("range", { -- 258
	priority = 3, -- 258
	reaction = 10, -- 259
	recovery = 0.1, -- 260
	queued = true, -- 261
	available = function() -- 262
		return true -- 262
	end, -- 262
	create = function(self) -- 263
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 264
		do -- 264
			local _obj_0 = self.entity -- 269
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 264
		end -- 269
		do -- 270
			local _with_0 = self.playable -- 270
			_with_0.speed = attackSpeed -- 271
			_with_0:play("range") -- 272
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 273
		end -- 270
		return once(function(self) -- 274
			local bulletDef = Store[self.unitDef.bulletType] -- 275
			local onAttack -- 276
			onAttack = function() -- 276
				Audio:play(self.unitDef.sndAttack) -- 277
				local _with_0 = Bullet(bulletDef, self) -- 278
				if self.group == EnemyGroup then -- 279
					_with_0.color = Color(0xff666666) -- 279
				end -- 279
				_with_0.targetAllow = targetAllow -- 280
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 281
					do -- 282
						local _with_1 = target.data -- 282
						_with_1.hitPoint = pos -- 283
						_with_1.hitPower = attackPower -- 284
						_with_1.hitFromRight = bullet.velocityX < 0 -- 285
					end -- 282
					local entity = target.entity -- 286
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 287
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 288
					entity.hp = entity.hp - damage -- 289
					bullet.hitStop = true -- 290
				end) -- 281
				_with_0:addTo(self.world, self.order) -- 291
				return _with_0 -- 278
			end -- 276
			sleep(0.5 * 28.0 / 30.0 / attackSpeed) -- 292
			onAttack() -- 293
			while true do -- 294
				sleep() -- 294
			end -- 294
		end) -- 294
	end, -- 263
	stop = function(self) -- 295
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 296
	end -- 295
}) -- 257
local BigArrow -- 298
do -- 298
	local _with_0 = BulletDef() -- 298
	_with_0.tag = "" -- 299
	_with_0.endEffect = "" -- 300
	_with_0.lifeTime = 5 -- 301
	_with_0.damageRadius = 0 -- 302
	_with_0.highSpeedFix = false -- 303
	_with_0.gravity = Vec2(0, -10) -- 304
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2(-100, 0), 2) -- 305
	_with_0:setAsCircle(10) -- 306
	_with_0:setVelocity(25, 800) -- 307
	BigArrow = _with_0 -- 298
end -- 298
UnitAction:add("multiArrow", { -- 310
	priority = 3, -- 310
	reaction = 10, -- 311
	recovery = 0.1, -- 312
	queued = true, -- 313
	available = function() -- 314
		return true -- 314
	end, -- 314
	create = function(self) -- 315
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 316
		do -- 316
			local _obj_0 = self.entity -- 321
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 316
		end -- 321
		do -- 322
			local _with_0 = self.playable -- 322
			_with_0.speed = attackSpeed -- 323
			_with_0:play("range") -- 324
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 325
		end -- 322
		return once(function(self) -- 326
			local onAttack -- 327
			onAttack = function(angle, speed) -- 327
				BigArrow:setVelocity(angle, speed) -- 328
				local _with_0 = Bullet(BigArrow, self) -- 329
				if self.group == EnemyGroup then -- 330
					_with_0.color = Color(0xff666666) -- 330
				end -- 330
				_with_0.targetAllow = targetAllow -- 331
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 332
					do -- 333
						local _with_1 = target.data -- 333
						_with_1.hitPoint = pos -- 334
						_with_1.hitPower = attackPower -- 335
						_with_1.hitFromRight = bullet.velocityX < 0 -- 336
					end -- 333
					local entity = target.entity -- 337
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 338
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 339
					entity.hp = entity.hp - damage -- 340
					bullet.hitStop = true -- 341
				end) -- 332
				_with_0:addTo(self.world, self.order) -- 342
				return _with_0 -- 329
			end -- 327
			sleep(30.0 / 60.0 / attackSpeed) -- 343
			Audio:play("Audio/d_att.wav") -- 344
			onAttack(30, 1100) -- 345
			onAttack(10, 1000) -- 346
			onAttack(-10, 900) -- 347
			onAttack(-30, 800) -- 348
			onAttack(-50, 700) -- 349
			while true do -- 350
				sleep() -- 350
			end -- 350
		end) -- 350
	end, -- 315
	stop = function(self) -- 351
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 352
	end -- 351
}) -- 309
UnitAction:add("fallOff", { -- 355
	priority = 1, -- 355
	reaction = 1, -- 356
	recovery = 0, -- 357
	available = function(self) -- 358
		return not self.onSurface -- 358
	end, -- 358
	create = function(self) -- 359
		if self.velocityY <= 0 then -- 360
			self.data.fallDown = true -- 361
			local _with_0 = self.playable -- 362
			_with_0.speed = 2.5 -- 363
			_with_0:play("idle") -- 364
		else -- 365
			self.data.fallDown = false -- 365
		end -- 360
		return function(self) -- 366
			if self.onSurface then -- 367
				return true -- 367
			end -- 367
			if not self.data.fallDown and self.velocityY <= 0 then -- 368
				self.data.fallDown = true -- 369
				local _with_0 = self.playable -- 370
				_with_0.speed = 2.5 -- 371
				_with_0:play("idle") -- 372
			end -- 368
			return false -- 373
		end -- 373
	end -- 359
}) -- 354
UnitAction:add("evade", { -- 376
	priority = 10, -- 376
	reaction = 10, -- 377
	recovery = 0, -- 378
	queued = true, -- 379
	available = function() -- 380
		return true -- 380
	end, -- 380
	create = function(self) -- 381
		do -- 382
			local _with_0 = self.playable -- 382
			_with_0.speed = 1.0 -- 383
			_with_0.recovery = 0.0 -- 384
			_with_0:play("bevade") -- 385
		end -- 382
		return once(function(self) -- 386
			local group = self.group -- 387
			self.group = Data.groupHide -- 388
			local dir = self.faceRight and -1 or 1 -- 389
			cycle(0.1, function() -- 390
				self.velocityX = 400 * dir -- 390
			end) -- 390
			self.group = group -- 391
			sleep(0.1) -- 392
			do -- 393
				local _with_0 = self.playable -- 393
				_with_0.speed = 1.0 -- 394
				_with_0:play("idle") -- 395
			end -- 393
			sleep(0.3) -- 396
			return true -- 397
		end) -- 397
	end -- 381
}) -- 375
UnitAction:add("rush", { -- 400
	priority = 10, -- 400
	reaction = 10, -- 401
	recovery = 0, -- 402
	queued = true, -- 403
	available = function() -- 404
		return true -- 404
	end, -- 404
	create = function(self) -- 405
		do -- 406
			local _with_0 = self.playable -- 406
			_with_0.speed = 1.0 -- 407
			_with_0.recovery = 0.0 -- 408
			_with_0:play("fevade") -- 409
		end -- 406
		return once(function(self) -- 410
			local group = self.group -- 411
			self.group = Data.groupHide -- 412
			local dir = self.faceRight and 1 or -1 -- 413
			cycle(0.1, function() -- 414
				self.velocityX = 800 * dir -- 414
			end) -- 414
			self.group = group -- 415
			sleep(0.1) -- 416
			do -- 417
				local _with_0 = self.playable -- 417
				_with_0.speed = 1.0 -- 418
				_with_0:play("idle") -- 419
			end -- 417
			sleep(0.3) -- 420
			return true -- 421
		end) -- 421
	end -- 405
}) -- 399
local spearAttackEnd -- 423
spearAttackEnd = function(name, playable) -- 423
	if name == "spear" then -- 424
		return playable.parent:stop() -- 424
	end -- 424
end -- 423
UnitAction:add("spearAttack", { -- 427
	priority = 3, -- 427
	reaction = 10, -- 428
	recovery = 0.1, -- 429
	queued = true, -- 430
	available = function() -- 431
		return true -- 431
	end, -- 431
	create = function(self) -- 432
		local attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor -- 433
		do -- 433
			local _obj_0 = self.entity -- 437
			attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 433
		end -- 437
		do -- 438
			local _with_0 = self.playable -- 438
			_with_0.speed = attackSpeed -- 439
			_with_0.recovery = 0.2 -- 440
			_with_0:play("spear") -- 441
			_with_0:slot("AnimationEnd", spearAttackEnd) -- 442
		end -- 438
		return once(function(self) -- 443
			sleep(50.0 / 60.0) -- 444
			Audio:play("Audio/f_att.wav") -- 445
			local dir = self.faceRight and 0 or -900 -- 446
			local origin = self.position - Vec2(0, 205) + Vec2(dir, 0) -- 447
			local size = Size(900, 40) -- 448
			world:query(Rect(origin, size), function(body) -- 449
				local entity = body.entity -- 450
				if entity and Data:isEnemy(body, self) then -- 451
					do -- 452
						local _with_0 = body.data -- 452
						_with_0.hitPoint = body.position -- 453
						_with_0.hitPower = attackPower -- 454
						_with_0.hitFromRight = not self.faceRight -- 455
					end -- 452
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 456
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 457
					entity.hp = entity.hp - damage -- 458
				end -- 451
				return false -- 459
			end) -- 449
			while true do -- 460
				sleep() -- 460
			end -- 460
		end) -- 460
	end -- 432
}) -- 426
do -- 462
	local _with_0 = BulletDef() -- 462
	_with_0.tag = "" -- 463
	_with_0.endEffect = "" -- 464
	_with_0.lifeTime = 5 -- 465
	_with_0.damageRadius = 0 -- 466
	_with_0.highSpeedFix = false -- 467
	_with_0.gravity = Vec2(0, -10) -- 468
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2.zero) -- 469
	_with_0:setAsCircle(10) -- 470
	_with_0:setVelocity(25, 800) -- 471
	Store["Bullet_Arrow"] = _with_0 -- 462
end -- 462
local GetBoss -- 473
GetBoss = function(entity, pos, black) -- 473
	local unitDef -- 474
	do -- 474
		local _with_0 = Dictionary() -- 474
		_with_0.linearAcceleration = Vec2(0, -10) -- 475
		_with_0.bodyType = "Dynamic" -- 476
		_with_0.scale = 2 -- 477
		_with_0.density = 10.0 -- 478
		_with_0.friction = 1.0 -- 479
		_with_0.restitution = 0.0 -- 480
		_with_0.playable = "model:Model/bossp.model" -- 481
		_with_0.size = Size(150, 410) -- 482
		_with_0.tag = "Boss" -- 483
		_with_0.sensity = 0 -- 484
		_with_0.move = 100 -- 485
		_with_0.moveSpeed = 1.0 -- 486
		_with_0.jump = 600 -- 487
		_with_0.detectDistance = 1500 -- 488
		_with_0.hp = 30.0 -- 489
		_with_0.attackSpeed = 1.0 -- 490
		_with_0.attackBase = 2.5 -- 491
		_with_0.attackDelay = 50.0 / 60.0 -- 492
		_with_0.attackEffectDelay = 50.0 / 60.0 -- 493
		_with_0.attackBonus = 0.0 -- 494
		_with_0.attackFactor = 1.0 -- 495
		_with_0.attackRange = Size(780, 300) -- 496
		_with_0.attackPower = Vec2(200, 200) -- 497
		_with_0.attackTarget = "Multi" -- 498
		do -- 499
			local conf -- 500
			do -- 500
				local _with_1 = TargetAllow() -- 500
				_with_1.terrainAllowed = true -- 501
				_with_1:allow("Enemy", true) -- 502
				conf = _with_1 -- 500
			end -- 500
			_with_0.targetAllow = conf:toValue() -- 503
		end -- 503
		_with_0.damageType = elementTypes.Purple -- 504
		_with_0.defenceType = elementTypes.Purple -- 505
		_with_0.bulletType = "Bullet_Arrow" -- 506
		_with_0.attackEffect = "" -- 507
		_with_0.hitEffect = "Particle/bloodp.par" -- 508
		_with_0.sndAttack = "Audio/f_att.wav" -- 509
		_with_0.sndFallen = "" -- 510
		_with_0.decisionTree = "AI_Boss" -- 511
		_with_0.usePreciseHit = true -- 512
		_with_0.actions = Array({ -- 514
			"walk", -- 514
			"turn", -- 515
			"meleeAttack", -- 516
			"multiArrow", -- 517
			"spearAttack", -- 518
			"idle", -- 519
			"cancel", -- 520
			"jump", -- 521
			"fall", -- 522
			"fallOff" -- 523
		}) -- 513
		unitDef = _with_0 -- 474
	end -- 474
	for _index_0 = 1, #mutables do -- 525
		local var = mutables[_index_0] -- 525
		entity[var] = unitDef[var] -- 526
	end -- 526
	local _with_0 = Unit(unitDef, world, entity, pos) -- 527
	if black then -- 528
		for i = 1, 7 do -- 529
			local node = _with_0.playable:getNodeByName("w" .. tostring(i)) -- 530
			if node then -- 530
				node.color = Color(0xff666666) -- 531
			end -- 530
		end -- 531
	end -- 528
	local node = _with_0.playable:getNodeByName("mask") -- 532
	if node then -- 532
		node:addChild(Sprite("Model/patreon.clip|" .. tostring(masks[math.random(1, #masks)]))) -- 533
	end -- 532
	return _with_0 -- 527
end -- 473
local _anon_func_1 = function(entity, itemSettings, items, pairs, tostring) -- 554
	local _accum_0 = { } -- 551
	local _len_0 = 1 -- 551
	for _, v in pairs(items) do -- 551
		local skill = itemSettings[v].skill -- 552
		if skill then -- 552
			entity[tostring(skill) .. "Skill"] = true -- 553
			_accum_0[_len_0] = skill -- 554
		end -- 552
		_len_0 = _len_0 + 1 -- 554
	end -- 554
	return _accum_0 -- 554
end -- 551
local _anon_func_2 = function(Color, Sprite, _with_0, black, item, itemSettings, tostring) -- 618
	local _with_1 = Sprite("Model/patreon.clip|" .. tostring(item)) -- 616
	if black then -- 617
		_with_1.color = Color(0xff666666) -- 617
	end -- 617
	_with_1.position = itemSettings[item].offset -- 618
	return _with_1 -- 616
end -- 616
local GetUnit -- 535
GetUnit = function(entity, pos, black) -- 535
	local characterType = characterTypes[math.random(1, #characterTypes)] -- 536
	local characterColor = characterColors[math.random(1, #characterColors)] -- 537
	local character = { -- 539
		body = "character_" .. tostring(characterType) .. tostring(characterColor), -- 539
		lhand = "character_hand" .. tostring(characterColor), -- 540
		rhand = "character_hand" .. tostring(characterColor), -- 541
		mask = masks[math.random(1, #masks)] -- 542
	} -- 538
	local items = { -- 544
		head = headItems[math.random(1, #headItems)], -- 544
		lhand = lhandItems[math.random(1, #lhandItems)], -- 545
		rhand = rhandItems[math.random(1, #rhandItems)] -- 546
	} -- 543
	local attackRange = itemSettings[items.rhand].attackRange or Size(350, 150) -- 547
	local bonusPower = itemSettings[items.lhand].attackPower or Vec2.zero -- 548
	local attackPower = bonusPower + (itemSettings[items.rhand].attackPower or Vec2(100, 100)) -- 549
	local sndAttack = itemSettings[items.rhand].sndAttack or "" -- 550
	local skills = Set(_anon_func_1(entity, itemSettings, items, pairs, tostring)) -- 551
	local actions = Array({ -- 556
		"walk", -- 556
		"turn", -- 557
		"idle", -- 558
		"cancel", -- 559
		"hit", -- 560
		"fall", -- 561
		"fallOff" -- 562
	}) -- 555
	for k in pairs(skills) do -- 564
		actions:add(k) -- 565
	end -- 565
	local unitDef -- 566
	do -- 566
		local _with_0 = Dictionary() -- 566
		_with_0.linearAcceleration = Vec2(0, -10) -- 567
		_with_0.bodyType = "Dynamic" -- 568
		_with_0.scale = 1 -- 569
		_with_0.density = 1.0 -- 570
		_with_0.friction = 1.0 -- 571
		_with_0.restitution = 0.0 -- 572
		_with_0.playable = "model:Model/patreon.model" -- 573
		_with_0.size = Size(64, 128) -- 574
		_with_0.tag = "Fighter" -- 575
		_with_0.sensity = 0 -- 576
		_with_0.move = 250 -- 577
		_with_0.moveSpeed = 1.0 -- 578
		_with_0.jump = 700 -- 579
		_with_0.detectDistance = 800 -- 580
		_with_0.hp = 10.0 -- 581
		_with_0.attackSpeed = 1.0 -- 582
		_with_0.attackBase = 2.5 -- 583
		_with_0.attackDelay = 20.0 / 60.0 -- 584
		_with_0.attackEffectDelay = 20.0 / 60.0 -- 585
		_with_0.attackBonus = 0.0 -- 586
		_with_0.attackFactor = 1.0 -- 587
		_with_0.attackRange = attackRange -- 588
		_with_0.attackPower = attackPower -- 589
		_with_0.attackTarget = "Single" -- 590
		do -- 591
			local conf -- 592
			do -- 592
				local _with_1 = TargetAllow() -- 592
				_with_1.terrainAllowed = true -- 593
				_with_1:allow("Enemy", true) -- 594
				conf = _with_1 -- 592
			end -- 592
			_with_0.targetAllow = conf:toValue() -- 595
		end -- 595
		_with_0.damageType = elementTypes[characterColor] -- 596
		_with_0.defenceType = elementTypes[characterColor] -- 597
		_with_0.bulletType = "Bullet_Arrow" -- 598
		_with_0.attackEffect = "" -- 599
		_with_0.hitEffect = "Particle/bloodp.par" -- 600
		_with_0.name = "Fighter" -- 601
		_with_0.desc = "" -- 602
		_with_0.sndAttack = sndAttack -- 603
		_with_0.sndFallen = "" -- 604
		_with_0.decisionTree = "AI_Common" -- 605
		_with_0.usePreciseHit = true -- 606
		_with_0.actions = actions -- 607
		unitDef = _with_0 -- 566
	end -- 566
	for _index_0 = 1, #mutables do -- 608
		local var = mutables[_index_0] -- 608
		entity[var] = unitDef[var] -- 609
	end -- 609
	local _with_0 = Unit(unitDef, world, entity, pos) -- 610
	for _index_0 = 1, #itemSlots do -- 611
		local slot = itemSlots[_index_0] -- 611
		local node = _with_0.playable:getNodeByName(slot) -- 612
		do -- 613
			local item = character[slot] -- 613
			if item then -- 613
				node:addChild(Sprite("Model/patreon.clip|" .. tostring(item))) -- 614
			end -- 613
		end -- 613
		local item = items[slot] -- 615
		if item then -- 615
			node:addChild(_anon_func_2(Color, Sprite, _with_0, black, item, itemSettings, tostring)) -- 616
		end -- 615
	end -- 618
	return _with_0 -- 610
end -- 535
Store["AI_Common"] = Sel({ -- 623
	Seq({ -- 624
		Con("is dead", function(self) -- 624
			return self.entity.hp <= 0 -- 624
		end), -- 624
		Accept() -- 625
	}), -- 623
	Seq({ -- 628
		Con("is falling", function(self) -- 628
			return not self.onSurface -- 628
		end), -- 628
		Act("fallOff") -- 629
	}), -- 627
	Seq({ -- 632
		Con("game paused", function() -- 632
			return GamePaused -- 632
		end), -- 632
		Act("idle") -- 633
	}), -- 631
	Seq({ -- 636
		Con("is not attacking", function(self) -- 636
			return not self:isDoing("melee") and not self:isDoing("range") -- 638
		end), -- 636
		Con("need attack", function(self) -- 639
			local attackUnits = AI:getUnitsInAttackRange() -- 640
			for _index_0 = 1, #attackUnits do -- 641
				local unit = attackUnits[_index_0] -- 641
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 642
					return true -- 644
				end -- 642
			end -- 644
			return false -- 645
		end), -- 639
		Sel({ -- 647
			Seq({ -- 648
				Con("attack", function() -- 648
					return App.rand % 10 == 0 -- 648
				end), -- 648
				Sel({ -- 650
					Act("meleeAttack"), -- 650
					Act("range") -- 651
				}) -- 649
			}), -- 647
			Act("idle") -- 654
		}) -- 646
	}), -- 635
	Seq({ -- 658
		Con("rush or evade", function(self) -- 658
			return not self:isDoing("rush") and not self:isDoing("evade") and App.rand % 300 == 0 -- 659
		end), -- 658
		Sel({ -- 661
			Seq({ -- 662
				Con("too far away", function(self) -- 662
					if self.entity.rushSkill then -- 663
						local units = AI:getDetectedUnits() -- 664
						for _index_0 = 1, #units do -- 665
							local unit = units[_index_0] -- 665
							if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight and self.position:distance(unit.position) > 300 then -- 666
								return true -- 668
							end -- 666
						end -- 668
					end -- 663
					return false -- 669
				end), -- 662
				Act("rush") -- 670
			}), -- 661
			Seq({ -- 673
				Con("too close", function(self) -- 673
					if self.entity.evadeSkill then -- 674
						local units = AI:getDetectedUnits() -- 675
						for _index_0 = 1, #units do -- 676
							local unit = units[_index_0] -- 676
							if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight and self.position:distance(unit.position) < 300 then -- 677
								return true -- 679
							end -- 677
						end -- 679
					end -- 674
					return false -- 680
				end), -- 673
				Act("evade") -- 681
			}) -- 672
		}) -- 660
	}), -- 657
	Seq({ -- 686
		Con("need turn", function(self) -- 686
			return (self.x < -750 and not self.faceRight) or (self.x > 750 and self.faceRight) -- 687
		end), -- 686
		Act("turn") -- 688
	}), -- 685
	Act("walk") -- 690
}) -- 622
Store["AI_Boss"] = Sel({ -- 694
	Seq({ -- 695
		Con("is dead", function(self) -- 695
			return self.entity.hp <= 0 -- 695
		end), -- 695
		Accept() -- 696
	}), -- 694
	Seq({ -- 699
		Con("is falling", function(self) -- 699
			return not self.onSurface -- 699
		end), -- 699
		Act("fallOff") -- 700
	}), -- 698
	Seq({ -- 703
		Con("game paused", function() -- 703
			return GamePaused -- 703
		end), -- 703
		Act("idle") -- 704
	}), -- 702
	Seq({ -- 707
		Con("is not attacking", function(self) -- 707
			return not self:isDoing("meleeAttack") and not self:isDoing("multiArrow") and not self:isDoing("spearAttack") -- 710
		end), -- 707
		Con("need attack", function(self) -- 711
			local attackUnits = AI:getUnitsInAttackRange() -- 712
			for _index_0 = 1, #attackUnits do -- 713
				local unit = attackUnits[_index_0] -- 713
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 714
					return true -- 716
				end -- 714
			end -- 716
			return false -- 717
		end), -- 711
		Sel({ -- 719
			Seq({ -- 720
				Con("melee attack", function() -- 720
					return App.rand % 40 == 0 -- 720
				end), -- 720
				Act("meleeAttack") -- 721
			}), -- 719
			Seq({ -- 724
				Con("multi Arrow", function() -- 724
					return App.rand % 40 == 0 -- 724
				end), -- 724
				Act("multiArrow") -- 725
			}), -- 723
			Seq({ -- 728
				Con("spear attack", function() -- 728
					return App.rand % 40 == 0 -- 728
				end), -- 728
				Act("spearAttack") -- 729
			}), -- 727
			Act("idle") -- 731
		}) -- 718
	}), -- 706
	Seq({ -- 735
		Con("need turn", function(self) -- 735
			return (self.x < -750 and not self.faceRight) or (self.x > 750 and self.faceRight) -- 736
		end), -- 735
		Act("turn") -- 737
	}), -- 734
	Act("walk") -- 739
}) -- 693
do -- 742
	local _with_0 = Observer("Add", { -- 742
		"position", -- 742
		"order", -- 742
		"group", -- 742
		"faceRight" -- 742
	}) -- 742
	_with_0:watch(function(self, position, order, group, faceRight) -- 743
		world = Store.world -- 744
		if group == PlayerGroup then -- 745
			self.player = true -- 745
		end -- 745
		if group == EnemyGroup then -- 746
			self.enemy = true -- 746
		end -- 746
		local unit -- 747
		if self.boss then -- 747
			unit = GetBoss(self, position, group == EnemyGroup) -- 748
		else -- 750
			unit = GetUnit(self, position, group == EnemyGroup) -- 750
		end -- 747
		unit.group = group -- 752
		unit.order = order -- 753
		unit.playable:runAction(Action(Scale(0.5, 0, self.unit.unitDef.scale, Ease.OutBack))) -- 754
		unit.faceRight = faceRight -- 755
		unit:addTo(world) -- 756
		return false -- 756
	end) -- 743
end -- 742
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
local _anon_func_3 = function(Delay, Ease, Event, Label, Opacity, Scale, Sequence, Spawn, _with_2, string, themeColor, tostring, value) -- 838
	local _with_0 = Label("sarasa-mono-sc-regular", 32) -- 823
	_with_0.color = themeColor -- 824
	_with_0.text = string.format(tostring(value > 0 and '+' or '') .. "%d", value) -- 825
	_with_0:runAction(Sequence(Spawn(Scale(0.5, 0.3, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(0.5), Spawn(Scale(0.3, 1, 1.5, Ease.OutQuad), Opacity(0.3, 1, 0, Ease.OutQuad)), Event("End"))) -- 826
	_with_0:slot("End", function() -- 838
		return _with_0:removeFromParent() -- 838
	end) -- 838
	return _with_0 -- 823
end -- 823
Director.ui:addChild((function() -- 815
	local _with_0 = AlignNode(true) -- 815
	_with_0:css('flex-direction: row') -- 816
	_with_0:addChild((function() -- 817
		local _with_1 = AlignNode() -- 817
		_with_1:css('width: 30%') -- 818
		_with_1:addChild((function() -- 819
			local _with_2 = AlignNode() -- 819
			_with_2:css('margin-left: 165; margin-top: 40; width: 0; height: 1') -- 820
			_with_2:gslot("AddScore", function(value) -- 821
				if value < 0 and GameScore == 0 then -- 822
					return -- 822
				end -- 822
				_with_2:addChild(_anon_func_3(Delay, Ease, Event, Label, Opacity, Scale, Sequence, Spawn, _with_2, string, themeColor, tostring, value)) -- 823
				GameScore = math.max(0, GameScore + value) -- 839
				if GameScore == 0 then -- 840
					return _with_2:schedule(once(function() -- 841
						Audio:play("Audio/game_over.wav") -- 842
						WaitForSignal("FOREVER LOST!", 3) -- 843
						return emit("GameLost") -- 844
					end)) -- 844
				end -- 840
			end) -- 821
			return _with_2 -- 819
		end)()) -- 819
		return _with_1 -- 817
	end)()) -- 817
	_with_0:addChild((function() -- 845
		local _with_1 = AlignNode() -- 845
		_with_1:css('width: 40%; flex-direction: row; justify-content: center; align-items: center') -- 846
		_with_1:addChild((function() -- 847
			local _with_2 = AlignNode() -- 847
			_with_2:css('height: 1; width: 0; margin-top: 200; margin-right: 80') -- 848
			_with_2:addChild((function() -- 849
				local _with_3 = CircleButton({ -- 850
					text = "FIGHT", -- 850
					radius = 40, -- 851
					fontName = "sarasa-mono-sc-regular", -- 852
					fontSize = 24 -- 853
				}) -- 849
				_with_3:slot("Tapped", function() -- 855
					if GameScore <= 0 then -- 856
						return -- 856
					end -- 856
					GamePaused = false -- 857
					return _with_3.parent:schedule(once(function() -- 858
						emit("Fight") -- 859
						Audio:play("Audio/choose.wav") -- 860
						return WaitForSignal("FIGHT!", 1) -- 861
					end)) -- 861
				end) -- 855
				return _with_3 -- 849
			end)()) -- 849
			return _with_2 -- 847
		end)()) -- 847
		_with_1:addChild((function() -- 862
			local _with_2 = AlignNode() -- 862
			_with_2:css('height: 1; width: 0; margin-top: 200') -- 863
			_with_2:addChild((function() -- 864
				local _with_3 = CircleButton({ -- 865
					text = "STRIKE\nBACK", -- 865
					radius = 40, -- 866
					fontName = "sarasa-mono-sc-regular", -- 867
					fontSize = 24 -- 868
				}) -- 864
				_with_3.visible = false -- 870
				_with_3:gslot("GameLost", function() -- 871
					_with_3.visible = true -- 872
					_with_3.parent.visible = true -- 873
					_with_3.touchEnabled = true -- 874
				end) -- 871
				_with_3:slot("Tapped", function() -- 875
					_with_3.touchEnabled = false -- 876
					Audio:play("Audio/v_att.wav") -- 877
					return _with_3:schedule(once(function() -- 878
						sleep(0.5) -- 879
						_with_3.visible = false -- 880
						emit("AddScore", 20) -- 881
						return emit("Start") -- 882
					end)) -- 882
				end) -- 875
				return _with_3 -- 864
			end)()) -- 864
			return _with_2 -- 862
		end)()) -- 862
		_with_1:addChild((function() -- 883
			local _with_2 = AlignNode() -- 883
			_with_2:css('height: 1; width: 0; margin-top: 200; margin-left: 80') -- 884
			_with_2:addChild((function() -- 885
				local _with_3 = CircleButton({ -- 886
					text = "ANOTHER\nWAY", -- 886
					radius = 40, -- 887
					fontName = "sarasa-mono-sc-regular", -- 888
					fontSize = 24 -- 889
				}) -- 885
				_with_3:slot("Tapped", function() -- 891
					Audio:play("Audio/switch.wav") -- 892
					if GameScore <= 5 then -- 893
						local _with_4 = _with_3.parent.parent -- 894
						_with_4:eachChild(function(self) -- 895
							self.visible = false -- 895
						end) -- 895
						_with_4:unschedule() -- 896
					end -- 893
					emit("AddScore", -5) -- 897
					return emit("Start") -- 898
				end) -- 891
				return _with_3 -- 885
			end)()) -- 885
			return _with_2 -- 883
		end)()) -- 883
		_with_1:gslot("Lost", function() -- 899
			return _with_1:schedule(once(function() -- 900
				emit("AddScore", -(10 + math.floor(GameScore / 20) * 5)) -- 901
				if GameScore == 0 then -- 902
					return -- 902
				end -- 902
				Audio:play("Audio/hero_fall.wav") -- 903
				WaitForSignal("LOST!", 1.5) -- 904
				return emit("Start") -- 905
			end)) -- 905
		end) -- 899
		_with_1:gslot("Win", function() -- 906
			return _with_1:schedule(once(function() -- 907
				local score = 5 * Group({ -- 908
					"player" -- 908
				}).count -- 908
				emit("AddScore", score) -- 909
				Audio:play("Audio/hero_win.wav") -- 910
				WaitForSignal("WIN!", 1.5) -- 911
				return emit("Start") -- 912
			end)) -- 912
		end) -- 906
		_with_1:gslot("Wasted", function() -- 913
			_with_1:eachChild(function(self) -- 914
				self.visible = false -- 915
			end) -- 914
			return emit("AddScore", -20) -- 916
		end) -- 913
		_with_1:gslot("Fight", function() -- 917
			_with_1:eachChild(function(self) -- 918
				self.visible = false -- 918
			end) -- 918
			return _with_1:unschedule() -- 919
		end) -- 917
		_with_1:gslot("Start", function() -- 920
			if GameScore == 0 then -- 921
				return -- 921
			end -- 921
			GamePaused = true -- 922
			_with_1:eachChild(function(self) -- 923
				self.visible = true -- 923
			end) -- 923
			Group({ -- 924
				"unit" -- 924
			}):each(function(self) -- 924
				return self.unit:removeFromParent() -- 924
			end) -- 924
			local unitCount -- 925
			if GameScore < 40 then -- 925
				unitCount = 1 + math.min(2, math.floor(math.max(0, GameScore - 20) / 5)) -- 926
			else -- 928
				unitCount = 3 + math.min(3, math.floor(GameScore / 35)) -- 928
			end -- 925
			if math.random(1, 100) == 1 then -- 929
				Entity({ -- 931
					position = Vec2(-200, 100), -- 931
					order = PlayerLayer, -- 932
					group = PlayerGroup, -- 933
					boss = true, -- 934
					faceRight = true -- 935
				}) -- 930
			else -- 937
				for i = 1, unitCount do -- 937
					Entity({ -- 939
						position = Vec2(-100 * i, 100), -- 939
						order = PlayerLayer, -- 940
						group = PlayerGroup, -- 941
						faceRight = true -- 942
					}) -- 938
				end -- 942
			end -- 929
			if math.random(1, 100) == 1 then -- 943
				Entity({ -- 945
					position = Vec2(200, 100), -- 945
					order = EnemyLayer, -- 946
					group = EnemyGroup, -- 947
					boss = true, -- 948
					faceRight = false -- 949
				}) -- 944
			else -- 951
				for i = 1, unitCount do -- 951
					Entity({ -- 953
						position = Vec2(100 * i, 100), -- 953
						order = EnemyLayer, -- 954
						group = EnemyGroup, -- 955
						faceRight = false -- 956
					}) -- 952
				end -- 956
			end -- 943
			return _with_1:schedule(once(function() -- 957
				local time = 2 -- 958
				cycle(time, function(dt) -- 959
					local width, height -- 960
					do -- 960
						local _obj_0 = App.visualSize -- 960
						width, height = _obj_0.width, _obj_0.height -- 960
					end -- 960
					SetNextWindowPos(Vec2(width / 2 - 150, height / 2)) -- 961
					SetNextWindowSize(Vec2(300, 50), "FirstUseEver") -- 962
					return Begin("CountDown", { -- 963
						"NoResize", -- 963
						"NoSavedSettings", -- 963
						"NoTitleBar", -- 963
						"NoMove" -- 963
					}, function() -- 963
						return ProgressBar(1.0 - dt, Vec2(-1, 30), string.format("%.2fs", (1 - dt) * time)) -- 964
					end) -- 964
				end) -- 959
				emit("Wasted") -- 965
				if GameScore == 0 then -- 966
					return -- 966
				end -- 966
				Audio:play("Audio/choose.wav") -- 967
				WaitForSignal("WASTED!", 1.5) -- 968
				return emit("Start") -- 969
			end)) -- 969
		end) -- 920
		_with_1:addChild((function() -- 970
			local _with_2 = Node() -- 970
			_with_2:schedule(function() -- 971
				SetNextWindowPos(Vec2(20, 20)) -- 972
				SetNextWindowSize(Vec2(120, 280), "FirstUseEver") -- 973
				return PushStyleVar("ItemSpacing", Vec2.zero, function() -- 974
					return Begin("Stats", { -- 975
						"NoResize", -- 975
						"NoSavedSettings", -- 975
						"NoTitleBar", -- 975
						"NoMove" -- 975
					}, function() -- 975
						Text("VALUE: " .. tostring(GameScore)) -- 976
						Image("Model/patreon.clip|character_handGreen", Vec2(30, 30)) -- 977
						SameLine() -- 978
						Text("->") -- 979
						SameLine() -- 980
						Image("Model/patreon.clip|character_handRed", Vec2(30, 30)) -- 981
						SameLine() -- 982
						Text("x3") -- 983
						Image("Model/patreon.clip|character_handRed", Vec2(30, 30)) -- 984
						SameLine() -- 985
						Text("->") -- 986
						SameLine() -- 987
						Image("Model/patreon.clip|character_handYellow", Vec2(30, 30)) -- 988
						SameLine() -- 989
						Text("x3") -- 990
						Image("Model/patreon.clip|character_handYellow", Vec2(30, 30)) -- 991
						SameLine() -- 992
						Text("->") -- 993
						SameLine() -- 994
						Image("Model/patreon.clip|character_handGreen", Vec2(30, 30)) -- 995
						SameLine() -- 996
						Text("x3") -- 997
						Image("Model/patreon.clip|item_bow", Vec2(30, 30)) -- 998
						SameLine() -- 999
						Text(">") -- 1000
						SameLine() -- 1001
						Image("Model/patreon.clip|item_sword", Vec2(30, 30)) -- 1002
						Image("Model/patreon.clip|item_hatTop", Vec2(30, 30)) -- 1003
						SameLine() -- 1004
						Text("dodge") -- 1005
						Image("Model/patreon.clip|item_helmet", Vec2(30, 30)) -- 1006
						SameLine() -- 1007
						Text("rush") -- 1008
						Image("Model/patreon.clip|item_rod", Vec2(30, 30)) -- 1009
						SameLine() -- 1010
						Text("knock") -- 1011
						Image("Model/patreon.clip|tile_heart", Vec2(30, 30)) -- 1012
						SameLine() -- 1013
						return Text("bash") -- 1014
					end) -- 1014
				end) -- 1014
			end) -- 971
			return _with_2 -- 970
		end)()) -- 970
		return _with_1 -- 845
	end)()) -- 845
	return _with_0 -- 815
end)()) -- 815
return emit("Start") -- 1016
