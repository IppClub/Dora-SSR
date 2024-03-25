-- [yue]: Script/Game/Loli War/Logic.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Group = dora.Group -- 1
local Observer = dora.Observer -- 1
local Vec2 = dora.Vec2 -- 1
local Rect = dora.Rect -- 1
local math = _G.math -- 1
local thread = dora.thread -- 1
local sleep = dora.sleep -- 1
local emit = dora.emit -- 1
local Audio = dora.Audio -- 1
local App = dora.App -- 1
local Entity = dora.Entity -- 1
local Unit = _module_0.Unit -- 1
local Visual = _module_0.Visual -- 1
local Action = dora.Action -- 1
local Sequence = dora.Sequence -- 1
local Y = dora.Y -- 1
local Ease = dora.Ease -- 1
local Sprite = dora.Sprite -- 1
local Spawn = dora.Spawn -- 1
local Opacity = dora.Opacity -- 1
local Scale = dora.Scale -- 1
local BodyDef = dora.BodyDef -- 1
local Body = dora.Body -- 1
local tostring = _G.tostring -- 1
local once = dora.once -- 1
local Node = dora.Node -- 1
local View = dora.View -- 1
local SpriteEffect = dora.SpriteEffect -- 1
local cycle = dora.cycle -- 1
local Director = dora.Director -- 1
local Store = Data.store -- 11
local GroupPlayer, GroupEnemy, GroupDisplay, GroupTerrain, GroupPlayerBlock, GroupEnemyBlock, GroupPlayerPoke, GroupEnemyPoke, LayerBunny, LayerReadMe, LayerPlayerHero, LayerEnemyHero, LayerBackground, LayerBlock, MaxEP, MaxHP = Store.GroupPlayer, Store.GroupEnemy, Store.GroupDisplay, Store.GroupTerrain, Store.GroupPlayerBlock, Store.GroupEnemyBlock, Store.GroupPlayerPoke, Store.GroupEnemyPoke, Store.LayerBunny, Store.LayerReadMe, Store.LayerPlayerHero, Store.LayerEnemyHero, Store.LayerBackground, Store.LayerBlock, Store.MaxEP, Store.MaxHP -- 12
local heroes = Group({ -- 31
	"hero" -- 31
}) -- 31
do -- 32
	local _with_0 = Observer("Add", { -- 32
		"world" -- 32
	}) -- 32
	_with_0:watch(function(self, world) -- 33
		do -- 35
			local _with_1 = world.camera -- 35
			_with_1.followRatio = Vec2(0.03, 0.03) -- 36
			_with_1.boundary = Rect(0, -110, 4096, 1004) -- 37
			_with_1.position = Vec2(1024, 274) -- 38
		end -- 35
		world:setIterations(2, 3) -- 39
		world:gslot("BlockValue", function(group, value) -- 40
			return heroes:each(function(hero) -- 40
				if hero.group == group then -- 41
					hero.blocks = value -- 41
				end -- 41
			end) -- 41
		end) -- 40
		world:gslot("BlockChange", function(group, value) -- 42
			return heroes:each(function(hero) -- 42
				if hero.group == group and hero.blocks then -- 43
					hero.blocks = math.max(hero.blocks + value, 0) -- 44
					if value < 0 then -- 45
						hero.defending = true -- 45
					end -- 45
				end -- 43
			end) -- 45
		end) -- 42
		world:gslot("EPChange", function(group, value) -- 46
			return heroes:each(function(hero) -- 46
				if hero.group == group then -- 47
					hero.ep = hero.ep + value -- 47
				end -- 47
			end) -- 47
		end) -- 46
		world:gslot("PlayerSelect", function(hero) -- 48
			return thread(function() -- 48
				sleep(1) -- 49
				world:clearScene() -- 50
				local _list_0 = { -- 51
					6, -- 51
					1, -- 51
					1 -- 51
				} -- 51
				for _index_0 = 1, #_list_0 do -- 51
					local ep = _list_0[_index_0] -- 51
					emit("EPChange", GroupPlayer, ep) -- 52
					emit("EPChange", GroupEnemy, ep) -- 53
				end -- 53
				Store.winner = nil -- 54
				world.playing = true -- 55
				Audio:playStream("Audio/LOOP14.ogg", true) -- 56
				local names -- 57
				do -- 57
					local _accum_0 = { } -- 57
					local _len_0 = 1 -- 57
					local _list_1 = { -- 57
						"Flandre", -- 57
						"Dorothy", -- 57
						"Villy" -- 57
					} -- 57
					for _index_0 = 1, #_list_1 do -- 57
						local n = _list_1[_index_0] -- 57
						if n ~= hero then -- 57
							_accum_0[_len_0] = n -- 57
							_len_0 = _len_0 + 1 -- 57
						end -- 57
					end -- 57
					names = _accum_0 -- 57
				end -- 57
				local enemyHero = names[(App.rand % 2) + 1] -- 58
				Entity({ -- 60
					hero = hero, -- 60
					group = GroupPlayer, -- 61
					faceRight = true, -- 62
					AI = "PlayerControlAI", -- 63
					layer = LayerPlayerHero, -- 64
					position = Vec2(512, 1004 - 712), -- 65
					ep = MaxEP -- 66
				}) -- 59
				Entity({ -- 68
					hero = enemyHero, -- 68
					group = GroupEnemy, -- 69
					faceRight = false, -- 70
					AI = "HeroAI", -- 71
					layer = LayerEnemyHero, -- 72
					position = Vec2(3584, 1004 - 712), -- 73
					ep = MaxEP -- 74
				}) -- 67
				world:buildCastles() -- 75
				world:addBunnySwither(GroupPlayer) -- 76
				return world:addBunnySwither(GroupEnemy) -- 77
			end) -- 77
		end) -- 48
		Store.world = world -- 34
		world:buildBackground() -- 79
		world:buildSwitches() -- 80
		world:buildGameReadme() -- 81
		Audio:playStream("Audio/LOOP13.ogg", true) -- 82
		return false -- 82
	end) -- 33
end -- 32
local mutables = { -- 85
	"hp", -- 85
	"moveSpeed", -- 86
	"move", -- 87
	"jump", -- 88
	"targetAllow", -- 89
	"attackBase", -- 90
	"attackPower", -- 91
	"attackSpeed", -- 92
	"damageType", -- 93
	"attackBonus", -- 94
	"attackFactor", -- 95
	"attackTarget", -- 96
	"defenceType" -- 97
} -- 84
local _anon_func_0 = function(Visual, _with_1) -- 119
	local _with_0 = Visual("Particle/select.par") -- 117
	_with_0:autoRemove() -- 118
	_with_0:start() -- 119
	return _with_0 -- 117
end -- 117
do -- 99
	local _with_0 = Observer("Add", { -- 99
		"hero", -- 99
		"group", -- 99
		"layer", -- 99
		"position", -- 99
		"faceRight", -- 99
		"AI" -- 99
	}) -- 99
	_with_0:watch(function(self, hero, group, layer, position, faceRight, AI) -- 100
		local world = Store.world -- 101
		local def = Store[hero] -- 102
		for _index_0 = 1, #mutables do -- 103
			local var = mutables[_index_0] -- 103
			self[var] = def[var] -- 104
		end -- 104
		local unit -- 105
		do -- 105
			local _with_1 = Unit(def, world, self, position) -- 105
			_with_1.group = group -- 106
			_with_1.faceRight = faceRight -- 107
			_with_1.order = layer -- 108
			_with_1.decisionTree = AI -- 109
			if "Dorothy" == hero then -- 111
				self.attackSpeed = 1.2 -- 111
			elseif "Villy" == hero then -- 112
				self.attackSpeed = 1.3 -- 112
			elseif "Flandre" == hero then -- 113
				self.attackSpeed = 1.8 -- 113
			end -- 113
			self.moveSpeed = 1.5 -- 114
			_with_1:eachAction(function(self) -- 115
				self.recovery = 0.05 -- 115
			end) -- 115
			_with_1:addTo(world) -- 116
			_with_1:addChild(_anon_func_0(Visual, _with_1)) -- 117
			unit = _with_1 -- 105
		end -- 105
		if group == GroupPlayer then -- 120
			world.camera.followTarget = unit -- 121
		end -- 120
		emit("HPChange", self.group, self.hp) -- 122
		return false -- 122
	end) -- 100
end -- 99
do -- 124
	local _with_0 = Observer("Add", { -- 124
		"bunny", -- 124
		"group", -- 124
		"layer", -- 124
		"position", -- 124
		"faceRight", -- 124
		"AI" -- 124
	}) -- 124
	_with_0:watch(function(self, bunny, group, layer, position, faceRight, AI) -- 125
		local world = Store.world -- 126
		local def = Store[bunny] -- 127
		for _index_0 = 1, #mutables do -- 128
			local var = mutables[_index_0] -- 128
			if var == "hp" and self[var] ~= nil then -- 129
				goto _continue_0 -- 130
			end -- 129
			self[var] = def[var] -- 131
			::_continue_0:: -- 129
		end -- 131
		local unit -- 132
		do -- 132
			local _with_1 = Unit(def, world, self, position) -- 132
			_with_1.group = group -- 133
			_with_1.faceRight = faceRight -- 134
			_with_1.order = layer -- 135
			_with_1.decisionTree = AI -- 136
			_with_1:eachAction(function(self) -- 137
				self.recovery = 0.1 -- 137
			end) -- 137
			_with_1:addTo(world) -- 138
			if self.hp == 0.0 then -- 139
				self.hp = self.hp - 1.0 -- 139
			end -- 139
			unit = _with_1 -- 132
		end -- 132
		return false -- 139
	end) -- 125
end -- 124
do -- 141
	local _with_0 = Observer("Add", { -- 141
		"switch", -- 141
		"group", -- 141
		"layer", -- 141
		"look", -- 141
		"position" -- 141
	}) -- 141
	_with_0:watch(function(self, switchType, group, layer, look, position) -- 142
		local world = Store.world -- 143
		local unit -- 144
		do -- 144
			local _with_1 = Unit(Store[switchType], world, self, position) -- 144
			_with_1.group = group -- 145
			_with_1.order = layer -- 146
			do -- 147
				local _with_2 = _with_1.playable -- 147
				_with_2.look = look -- 148
				_with_2.scaleX = 2 -- 149
				_with_2.scaleY = 2 -- 150
			end -- 147
			_with_1:addTo(world) -- 151
			_with_1.emittingEvent = true -- 152
			_with_1:slot("BodyEnter", function(self, sensorTag) -- 153
				if _with_1.attackSensor.tag == sensorTag and self.entity and Data:isFriend(self, unit) then -- 154
					if self.group == GroupPlayer and self.entity.hero and not self.data.tip then -- 155
						local floating = Action(Sequence(Y(0.5, 140, 150, Ease.OutQuad), Y(0.3, 150, 140, Ease.InQuad))) -- 156
						local _with_2 = Sprite("Model/items.clip|keyf_down") -- 160
						_with_2.y = 140 -- 161
						local scaleOut = Action(Spawn(Opacity(0.3, 0, 1), Scale(0.3, 0, 1, Ease.OutQuad))) -- 162
						_with_2:runAction(scaleOut) -- 166
						_with_2:slot("ActionEnd", function(self) -- 167
							return _with_2:runAction(floating) -- 167
						end) -- 167
						_with_2:addTo(self) -- 168
						self.data.tip = _with_2 -- 160
					end -- 155
					self.data.atSwitch = unit -- 169
				end -- 154
			end) -- 153
			_with_1:slot("BodyLeave", function(self, sensorTag) -- 170
				if _with_1.attackSensor.tag == sensorTag and Data:isFriend(self, unit) then -- 171
					self.data.atSwitch = nil -- 172
					if self.data.tip then -- 173
						do -- 174
							local _with_2 = self.data.tip -- 174
							_with_2:perform(Spawn(Scale(0.3, _with_2.scaleX, 0), Opacity(0.3, 1, 0))) -- 175
							_with_2:slot("ActionEnd"):set(function() -- 179
								return _with_2:removeFromParent() -- 179
							end) -- 179
						end -- 174
						self.data.tip = nil -- 180
					end -- 173
				end -- 171
			end) -- 170
			unit = _with_1 -- 144
		end -- 144
		return false -- 180
	end) -- 142
end -- 141
do -- 182
	local _with_0 = Observer("Add", { -- 182
		"block", -- 182
		"group", -- 182
		"layer", -- 182
		"look", -- 182
		"position" -- 182
	}) -- 182
	_with_0:watch(function(self, block, group, layer, look, position) -- 183
		local world = Store.world -- 184
		local def = Store[block] -- 185
		self.hp = def.hp -- 186
		self.defenceType = 0 -- 187
		do -- 188
			local _with_1 = Unit(def, world, self, position) -- 188
			_with_1.group = group -- 189
			_with_1.order = layer -- 190
			_with_1.playable.look = look -- 191
			_with_1:addTo(world) -- 192
		end -- 188
		return false -- 192
	end) -- 183
end -- 182
local _anon_func_1 = function(Data, GroupEnemy, GroupPlayer, _with_1, self) -- 221
	local _exp_0 = self.group -- 219
	if GroupPlayer == _exp_0 or GroupEnemy == _exp_0 then -- 220
		return Data:isEnemy(self.group, _with_1.group) -- 220
	else -- 221
		return false -- 221
	end -- 221
end -- 219
do -- 194
	local _with_0 = Observer("Add", { -- 194
		"poke", -- 194
		"group", -- 194
		"layer", -- 194
		"position" -- 194
	}) -- 194
	_with_0:watch(function(self, poke, group, layer, position) -- 195
		local world = Store.world -- 196
		local pokeDef -- 197
		do -- 197
			local _with_1 = BodyDef() -- 197
			_with_1.linearAcceleration = Vec2(0, -10) -- 198
			_with_1.type = "Dynamic" -- 199
			_with_1:attachDisk(192, 10.0, 0.1, 0.4) -- 200
			_with_1:attachDiskSensor(0, 194) -- 201
			pokeDef = _with_1 -- 197
		end -- 197
		do -- 202
			local _with_1 = Body(pokeDef, world, position) -- 202
			_with_1.group = group -- 203
			if GroupPlayerPoke == group then -- 205
				_with_1.velocityX = 400 -- 205
			elseif GroupEnemyPoke == group then -- 206
				_with_1.velocityX = -400 -- 206
			end -- 206
			local normal -- 207
			do -- 207
				local _with_2 = Sprite("Model/poke.clip|" .. tostring(poke)) -- 207
				_with_2.scaleX = 4 -- 208
				_with_2.scaleY = 4 -- 209
				_with_2.filter = "Point" -- 210
				normal = _with_2 -- 207
			end -- 207
			_with_1:addChild(normal) -- 211
			local glow -- 212
			do -- 212
				local _with_2 = Sprite("Model/poke.clip|" .. tostring(poke) .. "l") -- 212
				_with_2.scaleX = 4 -- 213
				_with_2.scaleY = 4 -- 214
				_with_2.filter = "Point" -- 215
				_with_2.visible = false -- 216
				glow = _with_2 -- 212
			end -- 212
			_with_1:addChild(glow) -- 217
			_with_1:slot("BodyEnter", function(self, sensorTag) -- 218
				if sensorTag == 0 and _anon_func_1(Data, GroupEnemy, GroupPlayer, _with_1, self) then -- 219
					if (_with_1.x < self.x) == (_with_1.velocityX > 0) then -- 222
						self.velocity = Vec2(_with_1.velocityX > 0 and 500 or -500, 400) -- 223
						return self:start("strike") -- 224
					end -- 222
				end -- 219
			end) -- 218
			_with_1:schedule(once(function() -- 225
				while 50 < math.abs(_with_1.velocityX) do -- 226
					sleep(0.1) -- 227
				end -- 227
				for i = 1, 6 do -- 228
					Audio:play("Audio/di.wav") -- 229
					normal.visible = not normal.visible -- 230
					glow.visible = not glow.visible -- 231
					sleep(0.5) -- 232
				end -- 232
				local sensor = _with_1:attachSensor(1, BodyDef:disk(500)) -- 233
				sleep() -- 235
				local _list_0 = sensor.sensedBodies -- 236
				for _index_0 = 1, #_list_0 do -- 236
					local body = _list_0[_index_0] -- 236
					if Data:isEnemy(body.group, _with_1.group) then -- 237
						local entity = body.entity -- 238
						if entity and entity.hp > 0 then -- 239
							local x = _with_1.x -- 240
							do -- 241
								local _with_2 = body.data -- 241
								_with_2.hitPoint = body:convertToWorldSpace(Vec2.zero) -- 242
								_with_2.hitPower = Vec2(2000, 2400) -- 243
								_with_2.hitFromRight = body.x < x -- 244
							end -- 241
							entity.hp = entity.hp - 1 -- 245
						end -- 239
					end -- 237
				end -- 245
				local pos = _with_1:convertToWorldSpace(Vec2.zero) -- 246
				do -- 247
					local _with_2 = Visual("Particle/boom.par") -- 247
					_with_2.position = pos -- 248
					_with_2.scaleX = 4 -- 249
					_with_2.scaleY = 4 -- 250
					_with_2:addTo(world, LayerBlock) -- 251
					_with_2:autoRemove() -- 252
					_with_2:start() -- 253
				end -- 247
				_with_1:removeFromParent() -- 254
				return Audio:play("Audio/explosion.wav") -- 255
			end)) -- 225
			_with_1:addTo(world, layer) -- 256
		end -- 202
		Audio:play("Audio/quake.wav") -- 257
		return false -- 257
	end) -- 195
end -- 194
do -- 259
	local _with_0 = Observer("Change", { -- 259
		"hp", -- 259
		"unit", -- 259
		"block" -- 259
	}) -- 259
	_with_0:watch(function(self, hp, unit) -- 260
		local lastHp = self.oldValues.hp -- 261
		if hp < lastHp then -- 262
			if unit:isDoing("hit") then -- 263
				unit:start("cancel") -- 263
			end -- 263
			if hp > 0 then -- 264
				unit:start("hit") -- 265
				unit.faceRight = true -- 266
				local _with_1 = unit.playable -- 267
				_with_1.recovery = 0.5 -- 268
				_with_1:play("hp" .. tostring(math.floor(hp))) -- 269
			else -- 271
				unit:start("hit") -- 271
				unit.faceRight = true -- 272
				unit.group = Data.groupHide -- 273
				unit.playable:perform(Scale(0.3, 1, 0, Ease.OutQuad)) -- 274
				unit:schedule(once(function() -- 275
					sleep(5) -- 276
					return unit:removeFromParent() -- 277
				end)) -- 275
				local group -- 278
				do -- 278
					local _exp_0 = self.group -- 278
					if GroupPlayerBlock == _exp_0 then -- 279
						group = GroupEnemy -- 279
					elseif GroupEnemyBlock == _exp_0 then -- 280
						group = GroupPlayer -- 280
					end -- 280
				end -- 280
				emit("EPChange", group, 1) -- 281
			end -- 264
			local group -- 282
			do -- 282
				local _exp_0 = self.group -- 282
				if GroupPlayerBlock == _exp_0 then -- 283
					group = GroupPlayer -- 283
				elseif GroupEnemyBlock == _exp_0 then -- 284
					group = GroupEnemy -- 284
				end -- 284
			end -- 284
			emit("BlockChange", group, math.max(hp, 0) - lastHp) -- 285
		end -- 262
		return false -- 285
	end) -- 260
end -- 259
do -- 287
	local _with_0 = Observer("Change", { -- 287
		"hp", -- 287
		"bunny" -- 287
	}) -- 287
	_with_0:watch(function(self, hp) -- 288
		local unit = self.unit -- 289
		local lastHp = self.oldValues.hp -- 290
		if hp < lastHp then -- 291
			if unit:isDoing("hit") then -- 292
				unit:start("cancel") -- 292
			end -- 292
			if hp > 0 then -- 293
				unit:start("hit") -- 294
			else -- 296
				unit:start("hit") -- 296
				unit:start("fall") -- 297
				unit.group = Data.groupHide -- 298
				local group -- 299
				do -- 299
					local _exp_0 = self.group -- 299
					if GroupPlayer == _exp_0 then -- 300
						group = GroupEnemy -- 300
					elseif GroupEnemy == _exp_0 then -- 301
						group = GroupPlayer -- 301
					end -- 301
				end -- 301
				emit("EPChange", group, 1) -- 302
				unit:schedule(once(function() -- 303
					sleep(5) -- 304
					return unit:removeFromParent() -- 305
				end)) -- 303
			end -- 293
		end -- 291
		return false -- 305
	end) -- 288
end -- 287
do -- 307
	local _with_0 = Observer("Change", { -- 307
		"hp", -- 307
		"hero" -- 307
	}) -- 307
	_with_0:watch(function(self, hp) -- 308
		local unit = self.unit -- 309
		local lastHp = self.oldValues.hp -- 310
		local world = Store.world -- 311
		if hp < lastHp then -- 312
			if unit:isDoing("hit") then -- 313
				unit:start("cancel") -- 313
			end -- 313
			if hp > 0 then -- 314
				unit:start("hit") -- 315
			else -- 317
				unit:start("hit") -- 317
				unit:start("fall") -- 318
				local lastGroup = unit.group -- 319
				unit.group = Data.groupHide -- 320
				if unit.data.tip then -- 321
					unit.data.tip:removeFromParent() -- 322
					unit.data.tip = nil -- 323
				end -- 321
				emit("EPChange", lastGroup, 6) -- 324
				if GroupPlayer == lastGroup then -- 326
					Audio:play("Audio/hero_fall.wav") -- 327
				elseif GroupEnemy == lastGroup then -- 328
					Audio:play("Audio/hero_kill.wav") -- 329
				end -- 329
				if lastGroup == GroupPlayer then -- 330
					world:addChild((function() -- 331
						local _with_1 = Node() -- 331
						_with_1:schedule(once(function() -- 332
							do -- 333
								local _with_2 = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritesaturation") -- 333
								_with_2:get(1):set("u_adjustment", 0) -- 334
								View.postEffect = _with_2 -- 333
							end -- 333
							sleep(3) -- 335
							cycle(5, function(dt) -- 336
								return View.postEffect:get(1):set("u_adjustment", dt) -- 336
							end) -- 336
							View.postEffect = nil -- 337
						end)) -- 332
						_with_1:slot("Cleanup", function() -- 338
							View.postEffect = nil -- 339
							Director.scheduler.timeScale = 1 -- 340
						end) -- 338
						return _with_1 -- 331
					end)()) -- 331
				end -- 330
				unit:schedule(once(function() -- 341
					Director.scheduler.timeScale = 0.25 -- 342
					sleep(3) -- 343
					Director.scheduler.timeScale = 1 -- 344
					sleep(2) -- 345
					world:addBunnySwither(lastGroup) -- 346
					unit.visible = false -- 347
					local start = unit.position -- 348
					local stop -- 349
					if GroupPlayer == lastGroup then -- 350
						stop = Vec2(512, 1004 - 512) -- 350
					elseif GroupEnemy == lastGroup then -- 351
						stop = Vec2(3584, 1004 - 512) -- 351
					end -- 351
					cycle(5, function(dt) -- 352
						unit.position = start + (stop - start) * Ease:func(Ease.OutQuad, dt) -- 352
					end) -- 352
					unit.playable.look = "happy" -- 353
					unit.visible = true -- 354
					unit.velocityY = 1 -- 355
					unit.group = lastGroup -- 356
					self.hp = MaxHP -- 357
					emit("HPChange", lastGroup, MaxHP) -- 358
					local _with_1 = Visual("Particle/select.par") -- 359
					_with_1:addTo(unit) -- 360
					_with_1:start() -- 361
					_with_1:autoRemove() -- 362
					return _with_1 -- 359
				end)) -- 341
				local group -- 363
				do -- 363
					local _exp_0 = self.group -- 363
					if GroupPlayer == _exp_0 then -- 364
						group = GroupEnemy -- 364
					elseif GroupEnemy == _exp_0 then -- 365
						group = GroupPlayer -- 365
					end -- 365
				end -- 365
				emit("EPChange", group, 1) -- 366
			end -- 314
		end -- 312
		emit("HPChange", self.group, math.max(hp, 0) - lastHp) -- 367
		return false -- 367
	end) -- 308
end -- 307
local _with_0 = Observer("Change", { -- 369
	"blocks", -- 369
	"group" -- 369
}) -- 369
_with_0:watch(function(self, blocks, group) -- 370
	local world = Store.world -- 371
	if not world.playing then -- 372
		return false -- 372
	end -- 372
	if blocks == 0 then -- 373
		world.playing = false -- 374
		Audio:playStream("Audio/LOOP11.ogg", true) -- 375
		local clip, sound -- 376
		if GroupPlayer == group then -- 377
			Store.winner, clip, sound = GroupEnemy, "lose", "hero_lose" -- 377
		elseif GroupEnemy == group then -- 378
			Store.winner, clip, sound = GroupPlayer, "win", "hero_win" -- 378
		end -- 378
		Audio:play("Audio/" .. tostring(sound) .. ".wav") -- 379
		local sp -- 380
		do -- 380
			local _with_1 = Sprite("Model/misc.clip|" .. tostring(clip)) -- 380
			_with_1.scaleX = 2 -- 381
			_with_1.scaleY = 2 -- 382
			_with_1.filter = "Point" -- 383
			sp = _with_1 -- 380
		end -- 380
		local rectDef -- 384
		do -- 384
			local _with_1 = BodyDef() -- 384
			_with_1.linearAcceleration = Vec2(0, -10) -- 385
			_with_1.type = "Dynamic" -- 386
			_with_1:attachPolygon(sp.width * 2, sp.height * 2, 1, 0, 1) -- 387
			rectDef = _with_1 -- 384
		end -- 384
		heroes:each(function(hero) -- 388
			if hero.group == GroupPlayer then -- 389
				local _with_1 = Body(rectDef, world, Vec2(hero.unit.x, 512)) -- 390
				_with_1.order = LayerBunny -- 391
				_with_1.group = GroupDisplay -- 392
				_with_1:addChild(sp) -- 393
				_with_1:addTo(world) -- 394
				return _with_1 -- 390
			end -- 389
		end) -- 388
	end -- 373
	return false -- 394
end) -- 370
return _with_0 -- 369
