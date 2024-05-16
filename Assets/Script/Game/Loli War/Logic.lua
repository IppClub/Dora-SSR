-- [yue]: Script/Game/Loli War/Logic.yue
local _module_0 = Dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Group = Dora.Group -- 1
local Observer = Dora.Observer -- 1
local Vec2 = Dora.Vec2 -- 1
local Rect = Dora.Rect -- 1
local math = _G.math -- 1
local thread = Dora.thread -- 1
local sleep = Dora.sleep -- 1
local emit = Dora.emit -- 1
local Audio = Dora.Audio -- 1
local App = Dora.App -- 1
local Entity = Dora.Entity -- 1
local Unit = _module_0.Unit -- 1
local Visual = _module_0.Visual -- 1
local Action = Dora.Action -- 1
local Sequence = Dora.Sequence -- 1
local Y = Dora.Y -- 1
local Ease = Dora.Ease -- 1
local Sprite = Dora.Sprite -- 1
local Spawn = Dora.Spawn -- 1
local Opacity = Dora.Opacity -- 1
local Scale = Dora.Scale -- 1
local BodyDef = Dora.BodyDef -- 1
local Body = Dora.Body -- 1
local tostring = _G.tostring -- 1
local once = Dora.once -- 1
local Node = Dora.Node -- 1
local View = Dora.View -- 1
local SpriteEffect = Dora.SpriteEffect -- 1
local cycle = Dora.cycle -- 1
local Director = Dora.Director -- 1
local Store = Data.store -- 11
local GroupPlayer, GroupEnemy, GroupDisplay, GroupPlayerBlock, GroupEnemyBlock, GroupPlayerPoke, GroupEnemyPoke, LayerBunny, LayerPlayerHero, LayerEnemyHero, LayerBlock, MaxEP, MaxHP = Store.GroupPlayer, Store.GroupEnemy, Store.GroupDisplay, Store.GroupPlayerBlock, Store.GroupEnemyBlock, Store.GroupPlayerPoke, Store.GroupEnemyPoke, Store.LayerBunny, Store.LayerPlayerHero, Store.LayerEnemyHero, Store.LayerBlock, Store.MaxEP, Store.MaxHP -- 12
local heroes = Group({ -- 28
	"hero" -- 28
}) -- 28
do -- 29
	local _with_0 = Observer("Add", { -- 29
		"world" -- 29
	}) -- 29
	_with_0:watch(function(self, world) -- 30
		do -- 32
			local _with_1 = world.camera -- 32
			_with_1.followRatio = Vec2(0.03, 0.03) -- 33
			_with_1.boundary = Rect(0, -110, 4096, 1004) -- 34
			_with_1.position = Vec2(1024, 274) -- 35
		end -- 32
		world:setIterations(2, 3) -- 36
		world:gslot("BlockValue", function(group, value) -- 37
			return heroes:each(function(hero) -- 37
				if hero.group == group then -- 38
					hero.blocks = value -- 38
				end -- 38
			end) -- 38
		end) -- 37
		world:gslot("BlockChange", function(group, value) -- 39
			return heroes:each(function(hero) -- 39
				if hero.group == group and hero.blocks then -- 40
					hero.blocks = math.max(hero.blocks + value, 0) -- 41
					if value < 0 then -- 42
						hero.defending = true -- 42
					end -- 42
				end -- 40
			end) -- 42
		end) -- 39
		world:gslot("EPChange", function(group, value) -- 43
			return heroes:each(function(hero) -- 43
				if hero.group == group then -- 44
					hero.ep = hero.ep + value -- 44
				end -- 44
			end) -- 44
		end) -- 43
		world:gslot("PlayerSelect", function(hero) -- 45
			return thread(function() -- 45
				sleep(1) -- 46
				world:clearScene() -- 47
				local _list_0 = { -- 48
					6, -- 48
					1, -- 48
					1 -- 48
				} -- 48
				for _index_0 = 1, #_list_0 do -- 48
					local ep = _list_0[_index_0] -- 48
					emit("EPChange", GroupPlayer, ep) -- 49
					emit("EPChange", GroupEnemy, ep) -- 50
				end -- 50
				Store.winner = nil -- 51
				world.playing = true -- 52
				Audio:playStream("Audio/LOOP14.ogg", true) -- 53
				local names -- 54
				do -- 54
					local _accum_0 = { } -- 54
					local _len_0 = 1 -- 54
					local _list_1 = { -- 54
						"Flandre", -- 54
						"Dorothy", -- 54
						"Villy" -- 54
					} -- 54
					for _index_0 = 1, #_list_1 do -- 54
						local n = _list_1[_index_0] -- 54
						if n ~= hero then -- 54
							_accum_0[_len_0] = n -- 54
							_len_0 = _len_0 + 1 -- 54
						end -- 54
					end -- 54
					names = _accum_0 -- 54
				end -- 54
				local enemyHero = names[(App.rand % 2) + 1] -- 55
				Entity({ -- 57
					hero = hero, -- 57
					group = GroupPlayer, -- 58
					faceRight = true, -- 59
					AI = "PlayerControlAI", -- 60
					layer = LayerPlayerHero, -- 61
					position = Vec2(512, 1004 - 712), -- 62
					ep = MaxEP -- 63
				}) -- 56
				Entity({ -- 65
					hero = enemyHero, -- 65
					group = GroupEnemy, -- 66
					faceRight = false, -- 67
					AI = "HeroAI", -- 68
					layer = LayerEnemyHero, -- 69
					position = Vec2(3584, 1004 - 712), -- 70
					ep = MaxEP -- 71
				}) -- 64
				world:buildCastles() -- 72
				world:addBunnySwither(GroupPlayer) -- 73
				return world:addBunnySwither(GroupEnemy) -- 74
			end) -- 74
		end) -- 45
		Store.world = world -- 31
		world:buildBackground() -- 76
		world:buildSwitches() -- 77
		world:buildGameReadme() -- 78
		Audio:playStream("Audio/LOOP13.ogg", true) -- 79
		return false -- 79
	end) -- 30
end -- 29
local mutables = { -- 82
	"hp", -- 82
	"moveSpeed", -- 83
	"move", -- 84
	"jump", -- 85
	"targetAllow", -- 86
	"attackBase", -- 87
	"attackPower", -- 88
	"attackSpeed", -- 89
	"damageType", -- 90
	"attackBonus", -- 91
	"attackFactor", -- 92
	"attackTarget", -- 93
	"defenceType" -- 94
} -- 81
local _anon_func_0 = function(Visual, _with_1) -- 116
	local _with_0 = Visual("Particle/select.par") -- 114
	_with_0:autoRemove() -- 115
	_with_0:start() -- 116
	return _with_0 -- 114
end -- 114
do -- 96
	local _with_0 = Observer("Add", { -- 96
		"hero", -- 96
		"group", -- 96
		"layer", -- 96
		"position", -- 96
		"faceRight", -- 96
		"AI" -- 96
	}) -- 96
	_with_0:watch(function(self, hero, group, layer, position, faceRight, AI) -- 97
		local world = Store.world -- 98
		local def = Store[hero] -- 99
		for _index_0 = 1, #mutables do -- 100
			local var = mutables[_index_0] -- 100
			self[var] = def[var] -- 101
		end -- 101
		local unit -- 102
		do -- 102
			local _with_1 = Unit(def, world, self, position) -- 102
			_with_1.group = group -- 103
			_with_1.faceRight = faceRight -- 104
			_with_1.order = layer -- 105
			_with_1.decisionTree = AI -- 106
			if "Dorothy" == hero then -- 108
				self.attackSpeed = 1.2 -- 108
			elseif "Villy" == hero then -- 109
				self.attackSpeed = 1.3 -- 109
			elseif "Flandre" == hero then -- 110
				self.attackSpeed = 1.8 -- 110
			end -- 110
			self.moveSpeed = 1.5 -- 111
			_with_1:eachAction(function(self) -- 112
				self.recovery = 0.05 -- 112
			end) -- 112
			_with_1:addTo(world) -- 113
			_with_1:addChild(_anon_func_0(Visual, _with_1)) -- 114
			unit = _with_1 -- 102
		end -- 102
		if group == GroupPlayer then -- 117
			world.camera.followTarget = unit -- 118
		end -- 117
		emit("HPChange", self.group, self.hp) -- 119
		return false -- 119
	end) -- 97
end -- 96
do -- 121
	local _with_0 = Observer("Add", { -- 121
		"bunny", -- 121
		"group", -- 121
		"layer", -- 121
		"position", -- 121
		"faceRight", -- 121
		"AI" -- 121
	}) -- 121
	_with_0:watch(function(self, bunny, group, layer, position, faceRight, AI) -- 122
		local world = Store.world -- 123
		local def = Store[bunny] -- 124
		for _index_0 = 1, #mutables do -- 125
			local var = mutables[_index_0] -- 125
			if var == "hp" and self[var] ~= nil then -- 126
				goto _continue_0 -- 127
			end -- 126
			self[var] = def[var] -- 128
			::_continue_0:: -- 126
		end -- 128
		do -- 129
			local _with_1 = Unit(def, world, self, position) -- 129
			_with_1.group = group -- 130
			_with_1.faceRight = faceRight -- 131
			_with_1.order = layer -- 132
			_with_1.decisionTree = AI -- 133
			_with_1:eachAction(function(self) -- 134
				self.recovery = 0.1 -- 134
			end) -- 134
			_with_1:addTo(world) -- 135
			if self.hp == 0.0 then -- 136
				self.hp = self.hp - 1.0 -- 136
			end -- 136
		end -- 129
		return false -- 136
	end) -- 122
end -- 121
do -- 138
	local _with_0 = Observer("Add", { -- 138
		"switch", -- 138
		"group", -- 138
		"layer", -- 138
		"look", -- 138
		"position" -- 138
	}) -- 138
	_with_0:watch(function(self, switchType, group, layer, look, position) -- 139
		local world = Store.world -- 140
		local unit -- 141
		do -- 141
			local _with_1 = Unit(Store[switchType], world, self, position) -- 141
			_with_1.group = group -- 142
			_with_1.order = layer -- 143
			do -- 144
				local _with_2 = _with_1.playable -- 144
				_with_2.look = look -- 145
				_with_2.scaleX = 2 -- 146
				_with_2.scaleY = 2 -- 147
			end -- 144
			_with_1:addTo(world) -- 148
			_with_1.emittingEvent = true -- 149
			_with_1:slot("BodyEnter", function(self, sensorTag) -- 150
				if _with_1.attackSensor.tag == sensorTag and self.entity and Data:isFriend(self, unit) then -- 151
					if self.group == GroupPlayer and self.entity.hero and not self.data.tip then -- 152
						local floating = Action(Sequence(Y(0.5, 140, 150, Ease.OutQuad), Y(0.3, 150, 140, Ease.InQuad))) -- 153
						local _with_2 = Sprite("Model/items.clip|keyf_down") -- 157
						_with_2.y = 140 -- 158
						local scaleOut = Action(Spawn(Opacity(0.3, 0, 1), Scale(0.3, 0, 1, Ease.OutQuad))) -- 159
						_with_2:runAction(scaleOut) -- 163
						_with_2:slot("ActionEnd", function(self) -- 164
							return _with_2:runAction(floating) -- 164
						end) -- 164
						_with_2:addTo(self) -- 165
						self.data.tip = _with_2 -- 157
					end -- 152
					self.data.atSwitch = unit -- 166
				end -- 151
			end) -- 150
			_with_1:slot("BodyLeave", function(self, sensorTag) -- 167
				if _with_1.attackSensor.tag == sensorTag and Data:isFriend(self, unit) then -- 168
					self.data.atSwitch = nil -- 169
					if self.data.tip then -- 170
						do -- 171
							local _with_2 = self.data.tip -- 171
							_with_2:perform(Spawn(Scale(0.3, _with_2.scaleX, 0), Opacity(0.3, 1, 0))) -- 172
							_with_2:slot("ActionEnd"):set(function() -- 176
								return _with_2:removeFromParent() -- 176
							end) -- 176
						end -- 171
						self.data.tip = nil -- 177
					end -- 170
				end -- 168
			end) -- 167
			unit = _with_1 -- 141
		end -- 141
		return false -- 177
	end) -- 139
end -- 138
do -- 179
	local _with_0 = Observer("Add", { -- 179
		"block", -- 179
		"group", -- 179
		"layer", -- 179
		"look", -- 179
		"position" -- 179
	}) -- 179
	_with_0:watch(function(self, block, group, layer, look, position) -- 180
		local world = Store.world -- 181
		local def = Store[block] -- 182
		self.hp = def.hp -- 183
		self.defenceType = 0 -- 184
		do -- 185
			local _with_1 = Unit(def, world, self, position) -- 185
			_with_1.group = group -- 186
			_with_1.order = layer -- 187
			_with_1.playable.look = look -- 188
			_with_1:addTo(world) -- 189
		end -- 185
		return false -- 189
	end) -- 180
end -- 179
local _anon_func_1 = function(Data, GroupEnemy, GroupPlayer, _with_1, self) -- 218
	local _exp_0 = self.group -- 216
	if GroupPlayer == _exp_0 or GroupEnemy == _exp_0 then -- 217
		return Data:isEnemy(self.group, _with_1.group) -- 217
	else -- 218
		return false -- 218
	end -- 218
end -- 216
do -- 191
	local _with_0 = Observer("Add", { -- 191
		"poke", -- 191
		"group", -- 191
		"layer", -- 191
		"position" -- 191
	}) -- 191
	_with_0:watch(function(self, poke, group, layer, position) -- 192
		local world = Store.world -- 193
		local pokeDef -- 194
		do -- 194
			local _with_1 = BodyDef() -- 194
			_with_1.linearAcceleration = Vec2(0, -10) -- 195
			_with_1.type = "Dynamic" -- 196
			_with_1:attachDisk(192, 10.0, 0.1, 0.4) -- 197
			_with_1:attachDiskSensor(0, 194) -- 198
			pokeDef = _with_1 -- 194
		end -- 194
		do -- 199
			local _with_1 = Body(pokeDef, world, position) -- 199
			_with_1.group = group -- 200
			if GroupPlayerPoke == group then -- 202
				_with_1.velocityX = 400 -- 202
			elseif GroupEnemyPoke == group then -- 203
				_with_1.velocityX = -400 -- 203
			end -- 203
			local normal -- 204
			do -- 204
				local _with_2 = Sprite("Model/poke.clip|" .. tostring(poke)) -- 204
				_with_2.scaleX = 4 -- 205
				_with_2.scaleY = 4 -- 206
				_with_2.filter = "Point" -- 207
				normal = _with_2 -- 204
			end -- 204
			_with_1:addChild(normal) -- 208
			local glow -- 209
			do -- 209
				local _with_2 = Sprite("Model/poke.clip|" .. tostring(poke) .. "l") -- 209
				_with_2.scaleX = 4 -- 210
				_with_2.scaleY = 4 -- 211
				_with_2.filter = "Point" -- 212
				_with_2.visible = false -- 213
				glow = _with_2 -- 209
			end -- 209
			_with_1:addChild(glow) -- 214
			_with_1:slot("BodyEnter", function(self, sensorTag) -- 215
				if sensorTag == 0 and _anon_func_1(Data, GroupEnemy, GroupPlayer, _with_1, self) then -- 216
					if (_with_1.x < self.x) == (_with_1.velocityX > 0) then -- 219
						self.velocity = Vec2(_with_1.velocityX > 0 and 500 or -500, 400) -- 220
						return self:start("strike") -- 221
					end -- 219
				end -- 216
			end) -- 215
			_with_1:schedule(once(function() -- 222
				while 50 < math.abs(_with_1.velocityX) do -- 223
					sleep(0.1) -- 224
				end -- 224
				for i = 1, 6 do -- 225
					Audio:play("Audio/di.wav") -- 226
					normal.visible = not normal.visible -- 227
					glow.visible = not glow.visible -- 228
					sleep(0.5) -- 229
				end -- 229
				local sensor = _with_1:attachSensor(1, BodyDef:disk(500)) -- 230
				sleep() -- 232
				local _list_0 = sensor.sensedBodies -- 233
				for _index_0 = 1, #_list_0 do -- 233
					local body = _list_0[_index_0] -- 233
					if Data:isEnemy(body.group, _with_1.group) then -- 234
						local entity = body.entity -- 235
						if entity and entity.hp > 0 then -- 236
							local x = _with_1.x -- 237
							do -- 238
								local _with_2 = body.data -- 238
								_with_2.hitPoint = body:convertToWorldSpace(Vec2.zero) -- 239
								_with_2.hitPower = Vec2(2000, 2400) -- 240
								_with_2.hitFromRight = body.x < x -- 241
							end -- 238
							entity.hp = entity.hp - 1 -- 242
						end -- 236
					end -- 234
				end -- 242
				local pos = _with_1:convertToWorldSpace(Vec2.zero) -- 243
				do -- 244
					local _with_2 = Visual("Particle/boom.par") -- 244
					_with_2.position = pos -- 245
					_with_2.scaleX = 4 -- 246
					_with_2.scaleY = 4 -- 247
					_with_2:addTo(world, LayerBlock) -- 248
					_with_2:autoRemove() -- 249
					_with_2:start() -- 250
				end -- 244
				_with_1:removeFromParent() -- 251
				return Audio:play("Audio/explosion.wav") -- 252
			end)) -- 222
			_with_1:addTo(world, layer) -- 253
		end -- 199
		Audio:play("Audio/quake.wav") -- 254
		return false -- 254
	end) -- 192
end -- 191
do -- 256
	local _with_0 = Observer("Change", { -- 256
		"hp", -- 256
		"unit", -- 256
		"block" -- 256
	}) -- 256
	_with_0:watch(function(self, hp, unit) -- 257
		local lastHp = self.oldValues.hp -- 258
		if hp < lastHp then -- 259
			if unit:isDoing("hit") then -- 260
				unit:start("cancel") -- 260
			end -- 260
			if hp > 0 then -- 261
				unit:start("hit") -- 262
				unit.faceRight = true -- 263
				local _with_1 = unit.playable -- 264
				_with_1.recovery = 0.5 -- 265
				_with_1:play("hp" .. tostring(math.floor(hp))) -- 266
			else -- 268
				unit:start("hit") -- 268
				unit.faceRight = true -- 269
				unit.group = Data.groupHide -- 270
				unit.playable:perform(Scale(0.3, 1, 0, Ease.OutQuad)) -- 271
				unit:schedule(once(function() -- 272
					sleep(5) -- 273
					return unit:removeFromParent() -- 274
				end)) -- 272
				local group -- 275
				do -- 275
					local _exp_0 = self.group -- 275
					if GroupPlayerBlock == _exp_0 then -- 276
						group = GroupEnemy -- 276
					elseif GroupEnemyBlock == _exp_0 then -- 277
						group = GroupPlayer -- 277
					end -- 277
				end -- 277
				emit("EPChange", group, 1) -- 278
			end -- 261
			local group -- 279
			do -- 279
				local _exp_0 = self.group -- 279
				if GroupPlayerBlock == _exp_0 then -- 280
					group = GroupPlayer -- 280
				elseif GroupEnemyBlock == _exp_0 then -- 281
					group = GroupEnemy -- 281
				end -- 281
			end -- 281
			emit("BlockChange", group, math.max(hp, 0) - lastHp) -- 282
		end -- 259
		return false -- 282
	end) -- 257
end -- 256
do -- 284
	local _with_0 = Observer("Change", { -- 284
		"hp", -- 284
		"bunny" -- 284
	}) -- 284
	_with_0:watch(function(self, hp) -- 285
		local unit = self.unit -- 286
		local lastHp = self.oldValues.hp -- 287
		if hp < lastHp then -- 288
			if unit:isDoing("hit") then -- 289
				unit:start("cancel") -- 289
			end -- 289
			if hp > 0 then -- 290
				unit:start("hit") -- 291
			else -- 293
				unit:start("hit") -- 293
				unit:start("fall") -- 294
				unit.group = Data.groupHide -- 295
				local group -- 296
				do -- 296
					local _exp_0 = self.group -- 296
					if GroupPlayer == _exp_0 then -- 297
						group = GroupEnemy -- 297
					elseif GroupEnemy == _exp_0 then -- 298
						group = GroupPlayer -- 298
					end -- 298
				end -- 298
				emit("EPChange", group, 1) -- 299
				unit:schedule(once(function() -- 300
					sleep(5) -- 301
					return unit:removeFromParent() -- 302
				end)) -- 300
			end -- 290
		end -- 288
		return false -- 302
	end) -- 285
end -- 284
do -- 304
	local _with_0 = Observer("Change", { -- 304
		"hp", -- 304
		"hero" -- 304
	}) -- 304
	_with_0:watch(function(self, hp) -- 305
		local unit = self.unit -- 306
		local lastHp = self.oldValues.hp -- 307
		local world = Store.world -- 308
		if hp < lastHp then -- 309
			if unit:isDoing("hit") then -- 310
				unit:start("cancel") -- 310
			end -- 310
			if hp > 0 then -- 311
				unit:start("hit") -- 312
			else -- 314
				unit:start("hit") -- 314
				unit:start("fall") -- 315
				local lastGroup = unit.group -- 316
				unit.group = Data.groupHide -- 317
				if unit.data.tip then -- 318
					unit.data.tip:removeFromParent() -- 319
					unit.data.tip = nil -- 320
				end -- 318
				emit("EPChange", lastGroup, 6) -- 321
				if GroupPlayer == lastGroup then -- 323
					Audio:play("Audio/hero_fall.wav") -- 324
				elseif GroupEnemy == lastGroup then -- 325
					Audio:play("Audio/hero_kill.wav") -- 326
				end -- 326
				if lastGroup == GroupPlayer then -- 327
					world:addChild((function() -- 328
						local _with_1 = Node() -- 328
						_with_1:schedule(once(function() -- 329
							do -- 330
								local _with_2 = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritesaturation") -- 330
								_with_2:get(1):set("u_adjustment", 0) -- 331
								View.postEffect = _with_2 -- 330
							end -- 330
							sleep(3) -- 332
							cycle(5, function(dt) -- 333
								return View.postEffect:get(1):set("u_adjustment", dt) -- 333
							end) -- 333
							View.postEffect = nil -- 334
						end)) -- 329
						_with_1:slot("Cleanup", function() -- 335
							View.postEffect = nil -- 336
							Director.scheduler.timeScale = 1 -- 337
						end) -- 335
						return _with_1 -- 328
					end)()) -- 328
				end -- 327
				unit:schedule(once(function() -- 338
					Director.scheduler.timeScale = 0.25 -- 339
					sleep(3) -- 340
					Director.scheduler.timeScale = 1 -- 341
					sleep(2) -- 342
					world:addBunnySwither(lastGroup) -- 343
					unit.visible = false -- 344
					local start = unit.position -- 345
					local stop -- 346
					if GroupPlayer == lastGroup then -- 347
						stop = Vec2(512, 1004 - 512) -- 347
					elseif GroupEnemy == lastGroup then -- 348
						stop = Vec2(3584, 1004 - 512) -- 348
					end -- 348
					cycle(5, function(dt) -- 349
						unit.position = start + (stop - start) * Ease:func(Ease.OutQuad, dt) -- 349
					end) -- 349
					unit.playable.look = "happy" -- 350
					unit.visible = true -- 351
					unit.velocityY = 1 -- 352
					unit.group = lastGroup -- 353
					self.hp = MaxHP -- 354
					emit("HPChange", lastGroup, MaxHP) -- 355
					local _with_1 = Visual("Particle/select.par") -- 356
					_with_1:addTo(unit) -- 357
					_with_1:start() -- 358
					_with_1:autoRemove() -- 359
					return _with_1 -- 356
				end)) -- 338
				local group -- 360
				do -- 360
					local _exp_0 = self.group -- 360
					if GroupPlayer == _exp_0 then -- 361
						group = GroupEnemy -- 361
					elseif GroupEnemy == _exp_0 then -- 362
						group = GroupPlayer -- 362
					end -- 362
				end -- 362
				emit("EPChange", group, 1) -- 363
			end -- 311
		end -- 309
		emit("HPChange", self.group, math.max(hp, 0) - lastHp) -- 364
		return false -- 364
	end) -- 305
end -- 304
local _with_0 = Observer("Change", { -- 366
	"blocks", -- 366
	"group" -- 366
}) -- 366
_with_0:watch(function(self, blocks, group) -- 367
	local world = Store.world -- 368
	if not world.playing then -- 369
		return false -- 369
	end -- 369
	if blocks == 0 then -- 370
		world.playing = false -- 371
		Audio:playStream("Audio/LOOP11.ogg", true) -- 372
		local clip, sound -- 373
		if GroupPlayer == group then -- 374
			Store.winner, clip, sound = GroupEnemy, "lose", "hero_lose" -- 374
		elseif GroupEnemy == group then -- 375
			Store.winner, clip, sound = GroupPlayer, "win", "hero_win" -- 375
		end -- 375
		Audio:play("Audio/" .. tostring(sound) .. ".wav") -- 376
		local sp -- 377
		do -- 377
			local _with_1 = Sprite("Model/misc.clip|" .. tostring(clip)) -- 377
			_with_1.scaleX = 2 -- 378
			_with_1.scaleY = 2 -- 379
			_with_1.filter = "Point" -- 380
			sp = _with_1 -- 377
		end -- 377
		local rectDef -- 381
		do -- 381
			local _with_1 = BodyDef() -- 381
			_with_1.linearAcceleration = Vec2(0, -10) -- 382
			_with_1.type = "Dynamic" -- 383
			_with_1:attachPolygon(sp.width * 2, sp.height * 2, 1, 0, 1) -- 384
			rectDef = _with_1 -- 381
		end -- 381
		heroes:each(function(hero) -- 385
			if hero.group == GroupPlayer then -- 386
				local _with_1 = Body(rectDef, world, Vec2(hero.unit.x, 512)) -- 387
				_with_1.order = LayerBunny -- 388
				_with_1.group = GroupDisplay -- 389
				_with_1:addChild(sp) -- 390
				_with_1:addTo(world) -- 391
				return _with_1 -- 387
			end -- 386
		end) -- 385
	end -- 370
	return false -- 391
end) -- 367
return _with_0 -- 366
