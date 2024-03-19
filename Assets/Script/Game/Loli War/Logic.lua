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
local Store = Data.store -- 3
local GroupPlayer, GroupEnemy, GroupDisplay, GroupTerrain, GroupPlayerBlock, GroupEnemyBlock, GroupPlayerPoke, GroupEnemyPoke, LayerBunny, LayerReadMe, LayerPlayerHero, LayerEnemyHero, LayerBackground, LayerBlock, MaxEP, MaxHP = Store.GroupPlayer, Store.GroupEnemy, Store.GroupDisplay, Store.GroupTerrain, Store.GroupPlayerBlock, Store.GroupEnemyBlock, Store.GroupPlayerPoke, Store.GroupEnemyPoke, Store.LayerBunny, Store.LayerReadMe, Store.LayerPlayerHero, Store.LayerEnemyHero, Store.LayerBackground, Store.LayerBlock, Store.MaxEP, Store.MaxHP -- 4
local heroes = Group({ -- 23
	"hero" -- 23
}) -- 23
do -- 24
	local _with_0 = Observer("Add", { -- 24
		"world" -- 24
	}) -- 24
	_with_0:watch(function(self, world) -- 25
		do -- 27
			local _with_1 = world.camera -- 27
			_with_1.followRatio = Vec2(0.03, 0.03) -- 28
			_with_1.boundary = Rect(0, -110, 4096, 1004) -- 29
			_with_1.position = Vec2(1024, 274) -- 30
		end -- 27
		world:setIterations(2, 3) -- 31
		world:gslot("BlockValue", function(group, value) -- 32
			return heroes:each(function(hero) -- 32
				if hero.group == group then -- 33
					hero.blocks = value -- 33
				end -- 33
			end) -- 33
		end) -- 32
		world:gslot("BlockChange", function(group, value) -- 34
			return heroes:each(function(hero) -- 34
				if hero.group == group and hero.blocks then -- 35
					hero.blocks = math.max(hero.blocks + value, 0) -- 36
					if value < 0 then -- 37
						hero.defending = true -- 37
					end -- 37
				end -- 35
			end) -- 37
		end) -- 34
		world:gslot("EPChange", function(group, value) -- 38
			return heroes:each(function(hero) -- 38
				if hero.group == group then -- 39
					hero.ep = hero.ep + value -- 39
				end -- 39
			end) -- 39
		end) -- 38
		world:gslot("PlayerSelect", function(hero) -- 40
			return thread(function() -- 40
				sleep(1) -- 41
				world:clearScene() -- 42
				local _list_0 = { -- 43
					6, -- 43
					1, -- 43
					1 -- 43
				} -- 43
				for _index_0 = 1, #_list_0 do -- 43
					local ep = _list_0[_index_0] -- 43
					emit("EPChange", GroupPlayer, ep) -- 44
					emit("EPChange", GroupEnemy, ep) -- 45
				end -- 45
				Store.winner = nil -- 46
				world.playing = true -- 47
				Audio:playStream("Audio/LOOP14.ogg", true) -- 48
				local names -- 49
				do -- 49
					local _accum_0 = { } -- 49
					local _len_0 = 1 -- 49
					local _list_1 = { -- 49
						"Flandre", -- 49
						"Dorothy", -- 49
						"Villy" -- 49
					} -- 49
					for _index_0 = 1, #_list_1 do -- 49
						local n = _list_1[_index_0] -- 49
						if n ~= hero then -- 49
							_accum_0[_len_0] = n -- 49
							_len_0 = _len_0 + 1 -- 49
						end -- 49
					end -- 49
					names = _accum_0 -- 49
				end -- 49
				local enemyHero = names[(App.rand % 2) + 1] -- 50
				Entity({ -- 52
					hero = hero, -- 52
					group = GroupPlayer, -- 53
					faceRight = true, -- 54
					AI = "PlayerControlAI", -- 55
					layer = LayerPlayerHero, -- 56
					position = Vec2(512, 1004 - 712), -- 57
					ep = MaxEP -- 58
				}) -- 51
				Entity({ -- 60
					hero = enemyHero, -- 60
					group = GroupEnemy, -- 61
					faceRight = false, -- 62
					AI = "HeroAI", -- 63
					layer = LayerEnemyHero, -- 64
					position = Vec2(3584, 1004 - 712), -- 65
					ep = MaxEP -- 66
				}) -- 59
				world:buildCastles() -- 67
				world:addBunnySwither(GroupPlayer) -- 68
				return world:addBunnySwither(GroupEnemy) -- 69
			end) -- 69
		end) -- 40
		Store.world = world -- 26
		world:buildBackground() -- 71
		world:buildSwitches() -- 72
		world:buildGameReadme() -- 73
		Audio:playStream("Audio/LOOP13.ogg", true) -- 74
		return false -- 74
	end) -- 25
end -- 24
local mutables = { -- 77
	"hp", -- 77
	"moveSpeed", -- 78
	"move", -- 79
	"jump", -- 80
	"targetAllow", -- 81
	"attackBase", -- 82
	"attackPower", -- 83
	"attackSpeed", -- 84
	"damageType", -- 85
	"attackBonus", -- 86
	"attackFactor", -- 87
	"attackTarget", -- 88
	"defenceType" -- 89
} -- 76
local _anon_func_0 = function(Visual, _with_1) -- 111
	local _with_0 = Visual("Particle/select.par") -- 109
	_with_0:autoRemove() -- 110
	_with_0:start() -- 111
	return _with_0 -- 109
end -- 109
do -- 91
	local _with_0 = Observer("Add", { -- 91
		"hero", -- 91
		"group", -- 91
		"layer", -- 91
		"position", -- 91
		"faceRight", -- 91
		"AI" -- 91
	}) -- 91
	_with_0:watch(function(self, hero, group, layer, position, faceRight, AI) -- 92
		local world = Store.world -- 93
		local def = Store[hero] -- 94
		for _index_0 = 1, #mutables do -- 95
			local var = mutables[_index_0] -- 95
			self[var] = def[var] -- 96
		end -- 96
		local unit -- 97
		do -- 97
			local _with_1 = Unit(def, world, self, position) -- 97
			_with_1.group = group -- 98
			_with_1.faceRight = faceRight -- 99
			_with_1.order = layer -- 100
			_with_1.decisionTree = AI -- 101
			if "Dorothy" == hero then -- 103
				self.attackSpeed = 1.2 -- 103
			elseif "Villy" == hero then -- 104
				self.attackSpeed = 1.3 -- 104
			elseif "Flandre" == hero then -- 105
				self.attackSpeed = 1.8 -- 105
			end -- 105
			self.moveSpeed = 1.5 -- 106
			_with_1:eachAction(function(self) -- 107
				self.recovery = 0.05 -- 107
			end) -- 107
			_with_1:addTo(world) -- 108
			_with_1:addChild(_anon_func_0(Visual, _with_1)) -- 109
			unit = _with_1 -- 97
		end -- 97
		if group == GroupPlayer then -- 112
			world.camera.followTarget = unit -- 113
		end -- 112
		emit("HPChange", self.group, self.hp) -- 114
		return false -- 114
	end) -- 92
end -- 91
do -- 116
	local _with_0 = Observer("Add", { -- 116
		"bunny", -- 116
		"group", -- 116
		"layer", -- 116
		"position", -- 116
		"faceRight", -- 116
		"AI" -- 116
	}) -- 116
	_with_0:watch(function(self, bunny, group, layer, position, faceRight, AI) -- 117
		local world = Store.world -- 118
		local def = Store[bunny] -- 119
		for _index_0 = 1, #mutables do -- 120
			local var = mutables[_index_0] -- 120
			if var == "hp" and self[var] ~= nil then -- 121
				goto _continue_0 -- 122
			end -- 121
			self[var] = def[var] -- 123
			::_continue_0:: -- 121
		end -- 123
		local unit -- 124
		do -- 124
			local _with_1 = Unit(def, world, self, position) -- 124
			_with_1.group = group -- 125
			_with_1.faceRight = faceRight -- 126
			_with_1.order = layer -- 127
			_with_1.decisionTree = AI -- 128
			_with_1:eachAction(function(self) -- 129
				self.recovery = 0.1 -- 129
			end) -- 129
			_with_1:addTo(world) -- 130
			if self.hp == 0.0 then -- 131
				self.hp = self.hp - 1.0 -- 131
			end -- 131
			unit = _with_1 -- 124
		end -- 124
		return false -- 131
	end) -- 117
end -- 116
do -- 133
	local _with_0 = Observer("Add", { -- 133
		"switch", -- 133
		"group", -- 133
		"layer", -- 133
		"look", -- 133
		"position" -- 133
	}) -- 133
	_with_0:watch(function(self, switchType, group, layer, look, position) -- 134
		local world = Store.world -- 135
		local unit -- 136
		do -- 136
			local _with_1 = Unit(Store[switchType], world, self, position) -- 136
			_with_1.group = group -- 137
			_with_1.order = layer -- 138
			do -- 139
				local _with_2 = _with_1.playable -- 139
				_with_2.look = look -- 140
				_with_2.scaleX = 2 -- 141
				_with_2.scaleY = 2 -- 142
			end -- 139
			_with_1:addTo(world) -- 143
			_with_1.emittingEvent = true -- 144
			_with_1:slot("BodyEnter", function(self, sensorTag) -- 145
				if _with_1.attackSensor.tag == sensorTag and self.entity and Data:isFriend(self, unit) then -- 146
					if self.group == GroupPlayer and self.entity.hero and not self.data.tip then -- 147
						local floating = Action(Sequence(Y(0.5, 140, 150, Ease.OutQuad), Y(0.3, 150, 140, Ease.InQuad))) -- 148
						do -- 152
							local _with_2 = Sprite("Model/items.clip|keyf_down") -- 152
							_with_2.y = 140 -- 153
							local scaleOut = Action(Spawn(Opacity(0.3, 0, 1), Scale(0.3, 0, 1, Ease.OutQuad))) -- 154
							_with_2:runAction(scaleOut) -- 158
							_with_2:slot("ActionEnd", function(self) -- 159
								return _with_2:runAction(floating) -- 159
							end) -- 159
							_with_2:addTo(self) -- 160
							self.data.tip = _with_2 -- 152
						end -- 152
					end -- 147
					self.data.atSwitch = unit -- 161
				end -- 146
			end) -- 145
			_with_1:slot("BodyLeave", function(self, sensorTag) -- 162
				if _with_1.attackSensor.tag == sensorTag and Data:isFriend(self, unit) then -- 163
					self.data.atSwitch = nil -- 164
					if self.data.tip then -- 165
						do -- 166
							local _with_2 = self.data.tip -- 166
							_with_2:perform(Spawn(Scale(0.3, _with_2.scaleX, 0), Opacity(0.3, 1, 0))) -- 167
							_with_2:slot("ActionEnd"):set(function() -- 171
								return _with_2:removeFromParent() -- 171
							end) -- 171
						end -- 166
						self.data.tip = nil -- 172
					end -- 165
				end -- 163
			end) -- 162
			unit = _with_1 -- 136
		end -- 136
		return false -- 172
	end) -- 134
end -- 133
do -- 174
	local _with_0 = Observer("Add", { -- 174
		"block", -- 174
		"group", -- 174
		"layer", -- 174
		"look", -- 174
		"position" -- 174
	}) -- 174
	_with_0:watch(function(self, block, group, layer, look, position) -- 175
		local world = Store.world -- 176
		local def = Store[block] -- 177
		self.hp = def.hp -- 178
		self.defenceType = 0 -- 179
		do -- 180
			local _with_1 = Unit(def, world, self, position) -- 180
			_with_1.group = group -- 181
			_with_1.order = layer -- 182
			_with_1.playable.look = look -- 183
			_with_1:addTo(world) -- 184
		end -- 180
		return false -- 184
	end) -- 175
end -- 174
local _anon_func_1 = function(Data, GroupEnemy, GroupPlayer, _with_1, self) -- 213
	local _exp_0 = self.group -- 211
	if GroupPlayer == _exp_0 or GroupEnemy == _exp_0 then -- 212
		return Data:isEnemy(self.group, _with_1.group) -- 212
	else -- 213
		return false -- 213
	end -- 213
end -- 211
do -- 186
	local _with_0 = Observer("Add", { -- 186
		"poke", -- 186
		"group", -- 186
		"layer", -- 186
		"position" -- 186
	}) -- 186
	_with_0:watch(function(self, poke, group, layer, position) -- 187
		local world = Store.world -- 188
		local pokeDef -- 189
		do -- 189
			local _with_1 = BodyDef() -- 189
			_with_1.linearAcceleration = Vec2(0, -10) -- 190
			_with_1.type = "Dynamic" -- 191
			_with_1:attachDisk(192, 10.0, 0.1, 0.4) -- 192
			_with_1:attachDiskSensor(0, 194) -- 193
			pokeDef = _with_1 -- 189
		end -- 189
		do -- 194
			local _with_1 = Body(pokeDef, world, position) -- 194
			_with_1.group = group -- 195
			if GroupPlayerPoke == group then -- 197
				_with_1.velocityX = 400 -- 197
			elseif GroupEnemyPoke == group then -- 198
				_with_1.velocityX = -400 -- 198
			end -- 198
			local normal -- 199
			do -- 199
				local _with_2 = Sprite("Model/poke.clip|" .. tostring(poke)) -- 199
				_with_2.scaleX = 4 -- 200
				_with_2.scaleY = 4 -- 201
				_with_2.filter = "Point" -- 202
				normal = _with_2 -- 199
			end -- 199
			_with_1:addChild(normal) -- 203
			local glow -- 204
			do -- 204
				local _with_2 = Sprite("Model/poke.clip|" .. tostring(poke) .. "l") -- 204
				_with_2.scaleX = 4 -- 205
				_with_2.scaleY = 4 -- 206
				_with_2.filter = "Point" -- 207
				_with_2.visible = false -- 208
				glow = _with_2 -- 204
			end -- 204
			_with_1:addChild(glow) -- 209
			_with_1:slot("BodyEnter", function(self, sensorTag) -- 210
				if sensorTag == 0 and _anon_func_1(Data, GroupEnemy, GroupPlayer, _with_1, self) then -- 211
					if (_with_1.x < self.x) == (_with_1.velocityX > 0) then -- 214
						self.velocity = Vec2(_with_1.velocityX > 0 and 500 or -500, 400) -- 215
						return self:start("strike") -- 216
					end -- 214
				end -- 211
			end) -- 210
			_with_1:schedule(once(function() -- 217
				while 50 < math.abs(_with_1.velocityX) do -- 218
					sleep(0.1) -- 219
				end -- 219
				for i = 1, 6 do -- 220
					Audio:play("Audio/di.wav") -- 221
					normal.visible = not normal.visible -- 222
					glow.visible = not glow.visible -- 223
					sleep(0.5) -- 224
				end -- 224
				local sensor = _with_1:attachSensor(1, BodyDef:disk(500)) -- 225
				sleep() -- 227
				local _list_0 = sensor.sensedBodies -- 228
				for _index_0 = 1, #_list_0 do -- 228
					local body = _list_0[_index_0] -- 228
					if Data:isEnemy(body.group, _with_1.group) then -- 229
						local entity = body.entity -- 230
						if entity and entity.hp > 0 then -- 231
							local x = _with_1.x -- 232
							do -- 233
								local _with_2 = body.data -- 233
								_with_2.hitPoint = body:convertToWorldSpace(Vec2.zero) -- 234
								_with_2.hitPower = Vec2(2000, 2400) -- 235
								_with_2.hitFromRight = body.x < x -- 236
							end -- 233
							entity.hp = entity.hp - 1 -- 237
						end -- 231
					end -- 229
				end -- 237
				local pos = _with_1:convertToWorldSpace(Vec2.zero) -- 238
				do -- 239
					local _with_2 = Visual("Particle/boom.par") -- 239
					_with_2.position = pos -- 240
					_with_2.scaleX = 4 -- 241
					_with_2.scaleY = 4 -- 242
					_with_2:addTo(world, LayerBlock) -- 243
					_with_2:autoRemove() -- 244
					_with_2:start() -- 245
				end -- 239
				_with_1:removeFromParent() -- 246
				return Audio:play("Audio/explosion.wav") -- 247
			end)) -- 217
			_with_1:addTo(world, layer) -- 248
		end -- 194
		Audio:play("Audio/quake.wav") -- 249
		return false -- 249
	end) -- 187
end -- 186
do -- 251
	local _with_0 = Observer("Change", { -- 251
		"hp", -- 251
		"unit", -- 251
		"block" -- 251
	}) -- 251
	_with_0:watch(function(self, hp, unit) -- 252
		local lastHp = self.oldValues.hp -- 253
		if hp < lastHp then -- 254
			if unit:isDoing("hit") then -- 255
				unit:start("cancel") -- 255
			end -- 255
			if hp > 0 then -- 256
				unit:start("hit") -- 257
				unit.faceRight = true -- 258
				do -- 259
					local _with_1 = unit.playable -- 259
					_with_1.recovery = 0.5 -- 260
					_with_1:play("hp" .. tostring(math.floor(hp))) -- 261
				end -- 259
			else -- 263
				unit:start("hit") -- 263
				unit.faceRight = true -- 264
				unit.group = Data.groupHide -- 265
				unit.playable:perform(Scale(0.3, 1, 0, Ease.OutQuad)) -- 266
				unit:schedule(once(function() -- 267
					sleep(5) -- 268
					return unit:removeFromParent() -- 269
				end)) -- 267
				local group -- 270
				do -- 270
					local _exp_0 = self.group -- 270
					if GroupPlayerBlock == _exp_0 then -- 271
						group = GroupEnemy -- 271
					elseif GroupEnemyBlock == _exp_0 then -- 272
						group = GroupPlayer -- 272
					end -- 272
				end -- 272
				emit("EPChange", group, 1) -- 273
			end -- 256
			local group -- 274
			do -- 274
				local _exp_0 = self.group -- 274
				if GroupPlayerBlock == _exp_0 then -- 275
					group = GroupPlayer -- 275
				elseif GroupEnemyBlock == _exp_0 then -- 276
					group = GroupEnemy -- 276
				end -- 276
			end -- 276
			emit("BlockChange", group, math.max(hp, 0) - lastHp) -- 277
		end -- 254
		return false -- 277
	end) -- 252
end -- 251
do -- 279
	local _with_0 = Observer("Change", { -- 279
		"hp", -- 279
		"bunny" -- 279
	}) -- 279
	_with_0:watch(function(self, hp) -- 280
		local unit = self.unit -- 281
		local lastHp = self.oldValues.hp -- 282
		if hp < lastHp then -- 283
			if unit:isDoing("hit") then -- 284
				unit:start("cancel") -- 284
			end -- 284
			if hp > 0 then -- 285
				unit:start("hit") -- 286
			else -- 288
				unit:start("hit") -- 288
				unit:start("fall") -- 289
				unit.group = Data.groupHide -- 290
				local group -- 291
				do -- 291
					local _exp_0 = self.group -- 291
					if GroupPlayer == _exp_0 then -- 292
						group = GroupEnemy -- 292
					elseif GroupEnemy == _exp_0 then -- 293
						group = GroupPlayer -- 293
					end -- 293
				end -- 293
				emit("EPChange", group, 1) -- 294
				unit:schedule(once(function() -- 295
					sleep(5) -- 296
					return unit:removeFromParent() -- 297
				end)) -- 295
			end -- 285
		end -- 283
		return false -- 297
	end) -- 280
end -- 279
do -- 299
	local _with_0 = Observer("Change", { -- 299
		"hp", -- 299
		"hero" -- 299
	}) -- 299
	_with_0:watch(function(self, hp) -- 300
		local unit = self.unit -- 301
		local lastHp = self.oldValues.hp -- 302
		local world = Store.world -- 303
		if hp < lastHp then -- 304
			if unit:isDoing("hit") then -- 305
				unit:start("cancel") -- 305
			end -- 305
			if hp > 0 then -- 306
				unit:start("hit") -- 307
			else -- 309
				unit:start("hit") -- 309
				unit:start("fall") -- 310
				local lastGroup = unit.group -- 311
				unit.group = Data.groupHide -- 312
				if unit.data.tip then -- 313
					unit.data.tip:removeFromParent() -- 314
					unit.data.tip = nil -- 315
				end -- 313
				emit("EPChange", lastGroup, 6) -- 316
				if GroupPlayer == lastGroup then -- 318
					Audio:play("Audio/hero_fall.wav") -- 319
				elseif GroupEnemy == lastGroup then -- 320
					Audio:play("Audio/hero_kill.wav") -- 321
				end -- 321
				if lastGroup == GroupPlayer then -- 322
					world:addChild((function() -- 323
						local _with_1 = Node() -- 323
						_with_1:schedule(once(function() -- 324
							do -- 325
								local _with_2 = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritesaturation") -- 325
								_with_2:get(1):set("u_adjustment", 0) -- 326
								View.postEffect = _with_2 -- 325
							end -- 325
							sleep(3) -- 327
							cycle(5, function(dt) -- 328
								return View.postEffect:get(1):set("u_adjustment", dt) -- 328
							end) -- 328
							View.postEffect = nil -- 329
						end)) -- 324
						_with_1:slot("Cleanup", function() -- 330
							View.postEffect = nil -- 331
							Director.scheduler.timeScale = 1 -- 332
						end) -- 330
						return _with_1 -- 323
					end)()) -- 323
				end -- 322
				unit:schedule(once(function() -- 333
					Director.scheduler.timeScale = 0.25 -- 334
					sleep(3) -- 335
					Director.scheduler.timeScale = 1 -- 336
					sleep(2) -- 337
					world:addBunnySwither(lastGroup) -- 338
					unit.visible = false -- 339
					local start = unit.position -- 340
					local stop -- 341
					if GroupPlayer == lastGroup then -- 342
						stop = Vec2(512, 1004 - 512) -- 342
					elseif GroupEnemy == lastGroup then -- 343
						stop = Vec2(3584, 1004 - 512) -- 343
					end -- 343
					cycle(5, function(dt) -- 344
						unit.position = start + (stop - start) * Ease:func(Ease.OutQuad, dt) -- 344
					end) -- 344
					unit.playable.look = "happy" -- 345
					unit.visible = true -- 346
					unit.velocityY = 1 -- 347
					unit.group = lastGroup -- 348
					self.hp = MaxHP -- 349
					emit("HPChange", lastGroup, MaxHP) -- 350
					local _with_1 = Visual("Particle/select.par") -- 351
					_with_1:addTo(unit) -- 352
					_with_1:start() -- 353
					_with_1:autoRemove() -- 354
					return _with_1 -- 351
				end)) -- 333
				local group -- 355
				do -- 355
					local _exp_0 = self.group -- 355
					if GroupPlayer == _exp_0 then -- 356
						group = GroupEnemy -- 356
					elseif GroupEnemy == _exp_0 then -- 357
						group = GroupPlayer -- 357
					end -- 357
				end -- 357
				emit("EPChange", group, 1) -- 358
			end -- 306
		end -- 304
		emit("HPChange", self.group, math.max(hp, 0) - lastHp) -- 359
		return false -- 359
	end) -- 300
end -- 299
local _with_0 = Observer("Change", { -- 361
	"blocks", -- 361
	"group" -- 361
}) -- 361
_with_0:watch(function(self, blocks, group) -- 362
	local world = Store.world -- 363
	if not world.playing then -- 364
		return false -- 364
	end -- 364
	if blocks == 0 then -- 365
		world.playing = false -- 366
		Audio:playStream("Audio/LOOP11.ogg", true) -- 367
		local clip, sound -- 368
		if GroupPlayer == group then -- 369
			Store.winner, clip, sound = GroupEnemy, "lose", "hero_lose" -- 369
		elseif GroupEnemy == group then -- 370
			Store.winner, clip, sound = GroupPlayer, "win", "hero_win" -- 370
		end -- 370
		Audio:play("Audio/" .. tostring(sound) .. ".wav") -- 371
		local sp -- 372
		do -- 372
			local _with_1 = Sprite("Model/misc.clip|" .. tostring(clip)) -- 372
			_with_1.scaleX = 2 -- 373
			_with_1.scaleY = 2 -- 374
			_with_1.filter = "Point" -- 375
			sp = _with_1 -- 372
		end -- 372
		local rectDef -- 376
		do -- 376
			local _with_1 = BodyDef() -- 376
			_with_1.linearAcceleration = Vec2(0, -10) -- 377
			_with_1.type = "Dynamic" -- 378
			_with_1:attachPolygon(sp.width * 2, sp.height * 2, 1, 0, 1) -- 379
			rectDef = _with_1 -- 376
		end -- 376
		heroes:each(function(hero) -- 380
			if hero.group == GroupPlayer then -- 381
				local _with_1 = Body(rectDef, world, Vec2(hero.unit.x, 512)) -- 382
				_with_1.order = LayerBunny -- 383
				_with_1.group = GroupDisplay -- 384
				_with_1:addChild(sp) -- 385
				_with_1:addTo(world) -- 386
				return _with_1 -- 382
			end -- 381
		end) -- 380
	end -- 365
	return false -- 386
end) -- 362
return _with_0 -- 361
