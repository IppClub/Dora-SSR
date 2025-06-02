-- [yue]: init.yue
local _module_1 = Dora.Platformer -- 1
local Data = _module_1.Data -- 1
local Vec2 = Dora.Vec2 -- 1
local Size = Dora.Size -- 1
local Group = Dora.Group -- 1
local App = Dora.App -- 1
local _module_2 = Dora.Platformer.Decision -- 1
local Seq = _module_2.Seq -- 1
local Con = _module_2.Con -- 1
local AI = _module_2.AI -- 1
local math = _G.math -- 1
local Sel = _module_2.Sel -- 1
local Act = _module_2.Act -- 1
local Node = Dora.Node -- 1
local type = _G.type -- 1
local tostring = _G.tostring -- 1
local table = _G.table -- 1
local thread = Dora.thread -- 1
local ML = Dora.ML -- 1
local string = _G.string -- 1
local print = _G.print -- 1
local load = _G.load -- 1
local emit = Dora.emit -- 1
local Accept = _module_2.Accept -- 1
local BulletDef = _module_1.BulletDef -- 1
local Face = _module_1.Face -- 1
local Reject = _module_2.Reject -- 1
local Dictionary = Dora.Dictionary -- 1
local TargetAllow = _module_1.TargetAllow -- 1
local Array = Dora.Array -- 1
local _module_0 = Dora.ImGui -- 1
local Columns = _module_0.Columns -- 1
local TextColored = _module_0.TextColored -- 1
local NextColumn = _module_0.NextColumn -- 1
local PushID = _module_0.PushID -- 1
local Button = _module_0.Button -- 1
local ImageButton = _module_0.ImageButton -- 1
local Text = _module_0.Text -- 1
local Color = Dora.Color -- 1
local TextWrapped = _module_0.TextWrapped -- 1
local DrawNode = Dora.DrawNode -- 1
local Line = Dora.Line -- 1
local PlatformWorld = _module_1.PlatformWorld -- 1
local Rect = Dora.Rect -- 1
local View = Dora.View -- 1
local BodyDef = Dora.BodyDef -- 1
local Body = Dora.Body -- 1
local Sprite = Dora.Sprite -- 1
local Model = Dora.Model -- 1
local Scale = Dora.Scale -- 1
local Ease = Dora.Ease -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local OpenPopup = _module_0.OpenPopup -- 1
local BeginPopupModal = _module_0.BeginPopupModal -- 1
local RadioButton = _module_0.RadioButton -- 1
local SameLine = _module_0.SameLine -- 1
local CloseCurrentPopup = _module_0.CloseCurrentPopup -- 1
local Entity = Dora.Entity -- 1
local Sequence = Dora.Sequence -- 1
local Spawn = Dora.Spawn -- 1
local Opacity = Dora.Opacity -- 1
local Event = Dora.Event -- 1
local Director = Dora.Director -- 1
local AlignNode = Dora.AlignNode -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local Begin = _module_0.Begin -- 1
local Menu = Dora.Menu -- 1
local Keyboard = Dora.Keyboard -- 1
local UnitAction = _module_1.UnitAction -- 1
local once = Dora.once -- 1
local Bullet = _module_1.Bullet -- 1
local sleep = Dora.sleep -- 1
local cycle = Dora.cycle -- 1
local Observer = Dora.Observer -- 1
local Unit = _module_1.Unit -- 1
local Visual = _module_1.Visual -- 1
local CircleButton = require("UI.Control.Basic.CircleButton") -- 16
local Store = Data.store -- 17
local characters = { -- 22
	{ -- 22
		body = "character_roundGreen", -- 22
		lhand = "character_handGreen", -- 23
		rhand = "character_handGreen" -- 24
	}, -- 22
	{ -- 26
		body = "character_roundRed", -- 26
		lhand = "character_handRed", -- 27
		rhand = "character_handRed" -- 28
	}, -- 26
	{ -- 30
		body = "character_roundYellow", -- 30
		lhand = "character_handYellow", -- 31
		rhand = "character_handYellow" -- 32
	} -- 30
} -- 21
local headItems = { -- 35
	"item_hat", -- 35
	"item_hatTop", -- 36
	"item_helmet", -- 37
	"item_helmetModern" -- 38
} -- 34
local lhandItems = { -- 41
	"item_shield", -- 41
	"item_shieldRound", -- 42
	"tile_heart", -- 43
	"ui_hand" -- 44
} -- 40
local rhandItems = { -- 47
	"item_bow", -- 47
	"item_sword", -- 48
	"item_rod", -- 49
	"item_spear" -- 50
} -- 46
local characterTypes = { -- 53
	"square", -- 53
	"round" -- 54
} -- 52
local characterColors = { -- 57
	"Green", -- 57
	"Red", -- 58
	"Yellow" -- 59
} -- 56
local itemSettings = { -- 62
	item_hat = { -- 63
		name = "普通帽子", -- 63
		desc = "就是很普通的帽子，增加许些防御力", -- 64
		cost = 1, -- 65
		skill = "jump", -- 66
		skillDesc = "跳跃", -- 67
		offset = Vec2(0, 30) -- 68
	}, -- 62
	item_hatTop = { -- 71
		name = "高帽子", -- 71
		desc = "就是很普通的帽子，增加许些防御力", -- 72
		cost = 1, -- 73
		skill = "evade", -- 74
		skillDesc = "闪避", -- 75
		offset = Vec2(0, 30) -- 76
	}, -- 70
	item_helmet = { -- 79
		name = "战盔", -- 79
		desc = "就是很普通的帽子，增加许些防御力", -- 80
		cost = 1, -- 81
		skill = "evade", -- 82
		skillDesc = "闪避", -- 83
		offset = Vec2(0, 0) -- 84
	}, -- 78
	item_helmetModern = { -- 87
		name = "橄榄球盔", -- 87
		desc = "就是很普通的帽子，增加许些防御力", -- 88
		cost = 1, -- 89
		skill = "", -- 90
		skillDesc = "无", -- 91
		offset = Vec2(0, 0) -- 92
	}, -- 86
	item_shield = { -- 95
		name = "方形盾", -- 95
		desc = "无", -- 96
		cost = 1, -- 97
		skill = "evade", -- 98
		skillDesc = "闪避", -- 99
		offset = Vec2(0, 0) -- 100
	}, -- 94
	item_shieldRound = { -- 103
		name = "小圆盾", -- 103
		desc = "无", -- 104
		cost = 1, -- 105
		skill = "jump", -- 106
		skillDesc = "跳跃", -- 107
		offset = Vec2(0, 0) -- 108
	}, -- 102
	tile_heart = { -- 111
		name = "爱心", -- 111
		desc = "无", -- 112
		cost = 1, -- 113
		skill = "jump", -- 114
		skillDesc = "跳跃", -- 115
		offset = Vec2(0, 0) -- 116
	}, -- 110
	ui_hand = { -- 119
		name = "手套", -- 119
		desc = "无", -- 120
		cost = 1, -- 121
		skill = "evade", -- 122
		skillDesc = "闪避", -- 123
		offset = Vec2(0, 0) -- 124
	}, -- 118
	item_bow = { -- 127
		name = "短弓", -- 127
		desc = "无", -- 128
		cost = 1, -- 129
		skill = "range", -- 130
		skillDesc = "远程攻击", -- 131
		offset = Vec2(10, 0), -- 132
		attackRange = Size(630, 150) -- 133
	}, -- 126
	item_sword = { -- 136
		name = "剑", -- 136
		desc = "无", -- 137
		cost = 1, -- 138
		skill = "meleeAttack", -- 139
		skillDesc = "近程攻击", -- 140
		offset = Vec2(15, 50), -- 141
		attackRange = Size(120, 150) -- 142
	}, -- 135
	item_rod = { -- 145
		name = "法杖", -- 145
		desc = "无", -- 146
		cost = 1, -- 147
		skill = "meleeAttack", -- 148
		skillDesc = "近程攻击", -- 149
		offset = Vec2(15, 50), -- 150
		attackRange = Size(200, 150) -- 151
	}, -- 144
	item_spear = { -- 154
		name = "长矛", -- 154
		desc = "无", -- 155
		cost = 1, -- 156
		skill = "meleeAttack", -- 157
		skillDesc = "近程攻击", -- 158
		offset = Vec2(15, 50), -- 159
		attackRange = Size(200, 150) -- 160
	} -- 153
} -- 61
local itemSlots = { -- 163
	"head", -- 163
	"lhand", -- 164
	"rhand" -- 165
} -- 162
characters = { -- 168
	{ -- 168
		head = nil, -- 168
		lhand = nil, -- 169
		rhand = nil, -- 170
		type = 1, -- 171
		color = 1, -- 172
		learnedAI = function() -- 173
			return "unknown" -- 173
		end -- 173
	}, -- 168
	{ -- 175
		head = nil, -- 175
		lhand = nil, -- 176
		rhand = nil, -- 177
		type = 1, -- 178
		color = 2, -- 179
		learnedAI = function() -- 180
			return "unknown" -- 180
		end -- 180
	}, -- 175
	{ -- 182
		head = nil, -- 182
		lhand = nil, -- 183
		rhand = nil, -- 184
		type = 1, -- 185
		color = 3, -- 186
		learnedAI = function() -- 187
			return "unknown" -- 187
		end -- 187
	} -- 182
} -- 167
local bossGroup = Group({ -- 189
	"boss" -- 189
}) -- 189
local lastAction = "idle" -- 191
local lastActionFrame = App.frame -- 192
local data = { } -- 193
local row = nil -- 194
local _anon_func_0 = function(enemy) -- 236
	local _obj_0 = enemy.currentAction -- 236
	if _obj_0 ~= nil then -- 236
		return _obj_0.name -- 236
	end -- 236
	return nil -- 236
end -- 236
local Do -- 195
Do = function(name) -- 195
	return Seq({ -- 196
		Con("Collect data", function(self) -- 196
			if self:isDoing(name) then -- 197
				row = nil -- 198
				return true -- 199
			end -- 197
			if not (AI:getNearestUnit("Enemy") ~= nil) then -- 201
				row = nil -- 202
				return true -- 203
			end -- 201
			local attack_ready -- 205
			do -- 205
				local attackUnits = AI:getUnitsInAttackRange() -- 206
				local ready = false -- 207
				for _index_0 = 1, #attackUnits do -- 208
					local unit = attackUnits[_index_0] -- 208
					if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 209
						ready = true -- 211
						break -- 212
					end -- 209
				end -- 212
				attack_ready = ready -- 213
			end -- 213
			local not_facing_enemy -- 215
			do -- 215
				local enemy = AI:getNearestUnit("Enemy") -- 216
				if enemy then -- 217
					not_facing_enemy = (self.x > enemy.x) == self.faceRight -- 218
				else -- 220
					not_facing_enemy = false -- 220
				end -- 217
			end -- 220
			local enemy_in_attack_range -- 222
			do -- 222
				local enemy = AI:getNearestUnit("Enemy") -- 223
				local attackUnits = AI:getUnitsInAttackRange() -- 224
				enemy_in_attack_range = attackUnits and attackUnits:contains(enemy) or false -- 225
			end -- 225
			local nearest_enemy_distance -- 227
			do -- 227
				local enemy = AI:getNearestUnit("Enemy") -- 228
				if (enemy ~= nil) then -- 229
					nearest_enemy_distance = math.abs(enemy.x - self.x) -- 230
				else -- 232
					nearest_enemy_distance = 999999 -- 232
				end -- 229
			end -- 232
			local enemy_hero_action -- 234
			do -- 234
				local enemy = AI:getNearestUnit("Enemy") -- 235
				enemy_hero_action = _anon_func_0(enemy) or "unknown" -- 236
			end -- 236
			row = { -- 239
				not_facing_enemy = not_facing_enemy, -- 239
				enemy_in_attack_range = enemy_in_attack_range, -- 240
				attack_ready = attack_ready, -- 241
				enemy_hero_action = enemy_hero_action, -- 242
				nearest_enemy_distance = nearest_enemy_distance, -- 243
				action = name -- 244
			} -- 238
			return true -- 246
		end), -- 196
		Sel({ -- 248
			Con("is doing", function(self) -- 248
				return self:isDoing(name) -- 248
			end), -- 248
			Seq({ -- 250
				Act(name), -- 250
				Con("action succeeded", function() -- 251
					lastAction = name -- 252
					lastActionFrame = App.frame -- 253
					return true -- 254
				end) -- 251
			}) -- 249
		}), -- 247
		Con("Save data", function() -- 257
			if row == nil then -- 258
				return true -- 258
			end -- 258
			data[#data + 1] = row -- 259
			return true -- 260
		end) -- 257
	}) -- 261
end -- 195
local rowNames = { -- 264
	"not_facing_enemy", -- 264
	"enemy_in_attack_range", -- 265
	"attack_ready", -- 267
	"enemy_hero_action", -- 268
	"nearest_enemy_distance", -- 269
	"action" -- 271
} -- 263
local rowTypes = { -- 275
	'C', -- 275
	'C', -- 275
	'C', -- 276
	'C', -- 276
	'N', -- 276
	'C' -- 277
} -- 274
local _anon_func_1 = function(_with_0, name, op, tostring, value) -- 295
	if name ~= "" then -- 295
		return "if " .. tostring(name) .. " " .. tostring(op) .. " " .. tostring(op == '==' and "\"" .. tostring(value) .. "\"" or value) -- 296
	else -- 298
		return tostring(op) .. " \"" .. tostring(value) .. "\"" -- 298
	end -- 295
end -- 295
local _anon_func_2 = function(_with_0, load, luaCodes) -- 306
	local _obj_0 = load(luaCodes) -- 306
	if _obj_0 ~= nil then -- 306
		return _obj_0() -- 306
	end -- 306
	return nil -- 306
end -- 306
do -- 280
	local _with_0 = Node() -- 280
	_with_0:gslot("TrainAI", function(charSet) -- 281
		local csvData -- 282
		do -- 282
			local _accum_0 = { } -- 282
			local _len_0 = 1 -- 282
			for _index_0 = 1, #data do -- 282
				local row = data[_index_0] -- 282
				local rd -- 283
				do -- 283
					local _accum_1 = { } -- 283
					local _len_1 = 1 -- 283
					for _index_1 = 1, #rowNames do -- 283
						local name = rowNames[_index_1] -- 283
						local val -- 284
						if (row[name] ~= nil) then -- 284
							val = row[name] -- 284
						else -- 284
							val = "N" -- 284
						end -- 284
						if "boolean" == type(val) then -- 285
							if val then -- 286
								val = "T" -- 286
							else -- 286
								val = "F" -- 286
							end -- 286
						end -- 285
						_accum_1[_len_1] = tostring(val) -- 287
						_len_1 = _len_1 + 1 -- 284
					end -- 287
					rd = _accum_1 -- 283
				end -- 287
				_accum_0[_len_0] = table.concat(rd, ",") -- 288
				_len_0 = _len_0 + 1 -- 283
			end -- 288
			csvData = _accum_0 -- 282
		end -- 288
		local names = tostring(table.concat(rowNames, ',')) .. "\n" -- 289
		local dataStr = tostring(names) .. tostring(table.concat(rowTypes, ',')) .. "\n" .. tostring(table.concat(csvData, '\n')) -- 290
		data = { } -- 291
		return thread(function() -- 292
			local lines = { -- 293
				"(_ENV) ->" -- 293
			} -- 293
			local accuracy = ML.BuildDecisionTreeAsync(dataStr, 0, function(depth, name, op, value) -- 294
				local line = string.rep("\t", depth + 1) .. _anon_func_1(_with_0, name, op, tostring, value) -- 295
				lines[#lines + 1] = line -- 299
			end) -- 294
			local codes = table.concat(lines, "\n") -- 300
			print("learning accuracy: " .. tostring(accuracy)) -- 301
			print(codes) -- 302
			local yue = require("yue") -- 304
			local luaCodes = yue.to_lua(codes, { -- 305
				reserve_line_number = false -- 305
			}) -- 305
			local learnedAI = _anon_func_2(_with_0, load, luaCodes) or function() -- 306
				return "unknown" -- 306
			end -- 306
			characters[charSet].learnedAI = learnedAI -- 307
			return emit("LearnedAI", learnedAI) -- 308
		end) -- 308
	end) -- 281
end -- 280
local _anon_func_3 = function(enemy) -- 364
	local _obj_0 = enemy.currentAction -- 364
	if _obj_0 ~= nil then -- 364
		return _obj_0.name -- 364
	end -- 364
	return nil -- 364
end -- 364
Store["AI_Learned"] = Sel({ -- 311
	Seq({ -- 312
		Con("is dead", function(self) -- 312
			return self.entity.hp <= 0 -- 312
		end), -- 312
		Accept() -- 313
	}), -- 311
	Seq({ -- 316
		Con("is falling", function(self) -- 316
			return not self.onSurface -- 316
		end), -- 316
		Act("fallOff") -- 317
	}), -- 315
	Seq({ -- 320
		Con("run learned AI", function(self) -- 320
			local _obj_0 = self.data -- 321
			_obj_0.lastActionTime = _obj_0.lastActionTime or 0.0 -- 321
			if not (AI:getNearestUnit("Enemy") ~= nil) then -- 323
				return false -- 323
			end -- 323
			if App.totalTime - self.data.lastActionTime < 0.1 then -- 325
				return false -- 326
			else -- 328
				self.data.lastActionTime = App.totalTime -- 328
			end -- 325
			local attack_ready -- 330
			do -- 330
				local attackUnits = AI:getUnitsInAttackRange() -- 331
				local ready = "F" -- 332
				for _index_0 = 1, #attackUnits do -- 333
					local unit = attackUnits[_index_0] -- 333
					if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 334
						ready = "T" -- 336
						break -- 337
					end -- 334
				end -- 337
				attack_ready = ready -- 338
			end -- 338
			local not_facing_enemy -- 340
			do -- 340
				local enemy = AI:getNearestUnit("Enemy") -- 341
				if enemy then -- 342
					if (self.x > enemy.x) == self.faceRight then -- 343
						not_facing_enemy = "T" -- 344
					else -- 346
						not_facing_enemy = "F" -- 346
					end -- 343
				else -- 348
					not_facing_enemy = "F" -- 348
				end -- 342
			end -- 348
			local enemy_in_attack_range -- 350
			do -- 350
				local enemy = AI:getNearestUnit("Enemy") -- 351
				local attackUnits = AI:getUnitsInAttackRange() -- 352
				enemy_in_attack_range = (attackUnits and attackUnits:contains(enemy)) and "T" or "F" -- 353
			end -- 353
			local nearest_enemy_distance -- 355
			do -- 355
				local enemy = AI:getNearestUnit("Enemy") -- 356
				if (enemy ~= nil) then -- 357
					nearest_enemy_distance = math.abs(enemy.x - self.x) -- 358
				else -- 360
					nearest_enemy_distance = 999999 -- 360
				end -- 357
			end -- 360
			local enemy_hero_action -- 362
			do -- 362
				local enemy = AI:getNearestUnit("Enemy") -- 363
				enemy_hero_action = _anon_func_3(enemy) or "unknown" -- 364
			end -- 364
			self.entity.learnedAction = characters[self.entity.charSet].learnedAI({ -- 367
				not_facing_enemy = not_facing_enemy, -- 367
				enemy_in_attack_range = enemy_in_attack_range, -- 368
				attack_ready = attack_ready, -- 369
				enemy_hero_action = enemy_hero_action, -- 370
				nearest_enemy_distance = nearest_enemy_distance -- 371
			}) or "unknown" -- 366
			return true -- 373
		end), -- 320
		Sel({ -- 375
			Con("is doing", function(self) -- 375
				return self:isDoing(self.entity.learnedAction) -- 375
			end), -- 375
			Seq({ -- 377
				Act(function(self) -- 377
					return self.entity.learnedAction -- 377
				end), -- 377
				Con("Succeeded prediction", function() -- 378
					emit("Prediction", true) -- 379
					return true -- 380
				end) -- 378
			}), -- 376
			Con("Failed prediction", function() -- 382
				emit("Prediction", false) -- 383
				return false -- 384
			end) -- 382
		}) -- 374
	}), -- 319
	Seq({ -- 388
		Con("not facing enemy", function(self) -- 388
			return bossGroup:each(function(boss) -- 388
				local unit = boss.unit -- 389
				if Data:isEnemy(unit, self) then -- 390
					if (self.x > unit.x) == self.faceRight then -- 391
						return true -- 392
					end -- 391
				end -- 390
			end) -- 392
		end), -- 388
		Act("turn") -- 393
	}), -- 387
	Seq({ -- 396
		Con("need turn", function(self) -- 396
			return (self.x < -1000 and not self.faceRight) or (self.x > 1000 and self.faceRight) -- 397
		end), -- 396
		Act("turn") -- 398
	}), -- 395
	Sel({ -- 401
		Seq({ -- 402
			Con("take a break", function() -- 402
				return App.rand % 60 == 0 -- 402
			end), -- 402
			Act("idle") -- 403
		}), -- 401
		Act("walk") -- 405
	}) -- 400
}) -- 310
do -- 409
	local _with_0 = BulletDef() -- 409
	_with_0.tag = "" -- 410
	_with_0.endEffect = "" -- 411
	_with_0.lifeTime = 5 -- 412
	_with_0.damageRadius = 0 -- 413
	_with_0.highSpeedFix = false -- 414
	_with_0.gravity = Vec2(0, -10) -- 415
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2(0, 0)) -- 416
	_with_0:setAsCircle(10) -- 417
	_with_0:setVelocity(25, 800) -- 418
	Store["Bullet_Arrow"] = _with_0 -- 409
end -- 409
Store["AI_Boss"] = Sel({ -- 421
	Seq({ -- 422
		Con("is dead", function(self) -- 422
			return self.entity.hp <= 0 -- 422
		end), -- 422
		Accept() -- 423
	}), -- 421
	Seq({ -- 426
		Con("is falling", function(self) -- 426
			return not self.onSurface -- 426
		end), -- 426
		Act("fallOff") -- 427
	}), -- 425
	Seq({ -- 430
		Con("is not attacking", function(self) -- 430
			return not self:isDoing("meleeAttack") and not self:isDoing("multiArrow") and not self:isDoing("spearAttack") -- 433
		end), -- 430
		Con("need attack", function(self) -- 434
			local attackUnits = AI:getUnitsInAttackRange() -- 435
			for _index_0 = 1, #attackUnits do -- 436
				local unit = attackUnits[_index_0] -- 436
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 437
					return true -- 439
				end -- 437
			end -- 439
			return false -- 440
		end), -- 434
		Sel({ -- 442
			Seq({ -- 443
				Con("melee attack", function() -- 443
					return App.rand % 250 == 0 -- 443
				end), -- 443
				Act("meleeAttack") -- 444
			}), -- 442
			Seq({ -- 447
				Con("range attack", function() -- 447
					return App.rand % 250 == 0 -- 447
				end), -- 447
				Act("multiArrow") -- 448
			}), -- 446
			Seq({ -- 451
				Con("spear attack", function() -- 451
					return App.rand % 250 == 0 -- 451
				end), -- 451
				Act("spearAttack") -- 452
			}), -- 450
			Act("idle") -- 454
		}) -- 441
	}), -- 429
	Seq({ -- 458
		Con("need turn", function(self) -- 458
			return (self.x < -1000 and not self.faceRight) or (self.x > 1000 and self.faceRight) -- 459
		end), -- 458
		Act("turn") -- 460
	}), -- 457
	Act("walk") -- 462
}) -- 420
Store["AI_PlayerControl"] = Sel({ -- 466
	Seq({ -- 467
		Con("is dead", function(self) -- 467
			return self.entity.hp <= 0 -- 467
		end), -- 467
		Accept() -- 468
	}), -- 466
	Seq({ -- 471
		Seq({ -- 472
			Con("move key down", function(self) -- 472
				return not (self.data.keyLeft and self.data.keyRight) and ((self.data.keyLeft and self.faceRight) or (self.data.keyRight and not self.faceRight)) -- 477
			end), -- 472
			Act("turn") -- 478
		}), -- 471
		Reject() -- 480
	}), -- 470
	Seq({ -- 483
		Con("evade key down", function(self) -- 483
			return self.data.keyE -- 483
		end), -- 483
		Do("evade") -- 484
	}), -- 482
	Seq({ -- 487
		Con("attack key down", function(self) -- 487
			return self.data.keyF -- 487
		end), -- 487
		Sel({ -- 489
			Do("meleeAttack"), -- 489
			Do("range") -- 490
		}) -- 488
	}), -- 486
	Sel({ -- 494
		Seq({ -- 495
			Con("is falling", function(self) -- 495
				return not self.onSurface and not self:isDoing("evade") -- 495
			end), -- 495
			Act("fallOff") -- 496
		}), -- 494
		Seq({ -- 499
			Con("jump key down", function(self) -- 499
				return self.data.keyUp -- 499
			end), -- 499
			Do("jump") -- 500
		}) -- 498
	}), -- 493
	Seq({ -- 504
		Con("move key down", function(self) -- 504
			return self.data.keyLeft or self.data.keyRight -- 504
		end), -- 504
		Do("walk") -- 505
	}), -- 503
	Act("idle") -- 507
}) -- 465
local NewFighterDef -- 510
NewFighterDef = function() -- 510
	local _with_0 = Dictionary() -- 510
	_with_0.linearAcceleration = Vec2(0, -10) -- 511
	_with_0.bodyType = "Dynamic" -- 512
	_with_0.scale = 1 -- 513
	_with_0.density = 1.0 -- 514
	_with_0.friction = 1.0 -- 515
	_with_0.restitution = 0.0 -- 516
	_with_0.playable = "model:Model/patreon" -- 517
	_with_0.size = Size(64, 128) -- 518
	_with_0.tag = "Fighter" -- 519
	_with_0.sensity = 0 -- 520
	_with_0.move = 250 -- 521
	_with_0.moveSpeed = 1.0 -- 522
	_with_0.jump = 700 -- 523
	_with_0.detectDistance = 800 -- 524
	_with_0.hp = 50.0 -- 525
	_with_0.attackSpeed = 1.0 -- 526
	_with_0.attackBase = 2.5 -- 527
	_with_0.attackDelay = 20.0 / 60.0 -- 528
	_with_0.attackEffectDelay = 20.0 / 60.0 -- 529
	_with_0.attackBonus = 0.0 -- 530
	_with_0.attackFactor = 1.0 -- 531
	_with_0.attackRange = Size(350, 150) -- 532
	_with_0.attackPower = Vec2(100, 100) -- 533
	_with_0.attackTarget = "Single" -- 534
	do -- 535
		local conf -- 536
		do -- 536
			local _with_1 = TargetAllow() -- 536
			_with_1.terrainAllowed = true -- 537
			_with_1:allow("Enemy", true) -- 538
			conf = _with_1 -- 536
		end -- 536
		_with_0.targetAllow = conf:toValue() -- 539
	end -- 539
	_with_0.damageType = 0 -- 540
	_with_0.defenceType = 0 -- 541
	_with_0.bulletType = "Bullet_Arrow" -- 542
	_with_0.attackEffect = "" -- 543
	_with_0.hitEffect = "Particle/bloodp.par" -- 544
	_with_0.name = "Fighter" -- 545
	_with_0.desc = "" -- 546
	_with_0.sndAttack = "" -- 547
	_with_0.sndFallen = "" -- 548
	_with_0.decisionTree = "AI_PlayerControl" -- 549
	_with_0.usePreciseHit = true -- 550
	_with_0.actions = Array({ -- 552
		"walk", -- 552
		"turn", -- 553
		"idle", -- 554
		"cancel", -- 555
		"hit", -- 556
		"fall", -- 557
		"fallOff" -- 558
	}) -- 551
	return _with_0 -- 510
end -- 510
local NewBossDef -- 561
NewBossDef = function() -- 561
	local _with_0 = Dictionary() -- 561
	_with_0.linearAcceleration = Vec2(0, -10) -- 562
	_with_0.bodyType = "Dynamic" -- 563
	_with_0.scale = 2 -- 564
	_with_0.density = 10.0 -- 565
	_with_0.friction = 1.0 -- 566
	_with_0.restitution = 0.0 -- 567
	_with_0.playable = "model:Model/bossp.model" -- 568
	_with_0.size = Size(150, 410) -- 569
	_with_0.tag = "Boss" -- 570
	_with_0.sensity = 0 -- 571
	_with_0.move = 100 -- 572
	_with_0.moveSpeed = 1.0 -- 573
	_with_0.jump = 600 -- 574
	_with_0.detectDistance = 1500 -- 575
	_with_0.hp = 200.0 -- 576
	_with_0.attackSpeed = 1.0 -- 577
	_with_0.attackBase = 2.5 -- 578
	_with_0.attackDelay = 50.0 / 60.0 -- 579
	_with_0.attackEffectDelay = 50.0 / 60.0 -- 580
	_with_0.attackBonus = 0.0 -- 581
	_with_0.attackFactor = 1.0 -- 582
	_with_0.attackRange = Size(780, 300) -- 583
	_with_0.attackPower = Vec2(200, 200) -- 584
	_with_0.attackTarget = "Multi" -- 585
	do -- 586
		local conf -- 587
		do -- 587
			local _with_1 = TargetAllow() -- 587
			_with_1.terrainAllowed = true -- 588
			_with_1:allow("Enemy", true) -- 589
			conf = _with_1 -- 587
		end -- 587
		_with_0.targetAllow = conf:toValue() -- 590
	end -- 590
	_with_0.damageType = 0 -- 591
	_with_0.defenceType = 0 -- 592
	_with_0.bulletType = "Bullet_Arrow" -- 593
	_with_0.attackEffect = "" -- 594
	_with_0.hitEffect = "Particle/bloodp.par" -- 595
	_with_0.sndAttack = "" -- 596
	_with_0.sndFallen = "" -- 597
	_with_0.decisionTree = "AI_Boss" -- 598
	_with_0.usePreciseHit = true -- 599
	_with_0.actions = Array({ -- 601
		"walk", -- 601
		"turn", -- 602
		"meleeAttack", -- 603
		"multiArrow", -- 604
		"spearAttack", -- 605
		"idle", -- 606
		"cancel", -- 607
		"jump", -- 608
		"fall", -- 609
		"fallOff" -- 610
	}) -- 600
	return _with_0 -- 561
end -- 561
local UnitDefFuncs = { -- 614
	fighter = NewFighterDef, -- 614
	boss = NewBossDef -- 615
} -- 613
local themeColor = App.themeColor -- 618
local itemSize = 64 -- 619
local NewItemPanel -- 620
NewItemPanel = function(displayName, itemName, itemOptions, currentSet) -- 620
	local selectItems = false -- 621
	return function() -- 622
		Columns(1, false) -- 623
		TextColored(themeColor, displayName) -- 624
		NextColumn() -- 625
		if selectItems then -- 626
			Columns(#itemOptions + 1, false) -- 627
			PushID(tostring(itemName) .. "x", function() -- 628
				if Button("x", Vec2(itemSize + 10, itemSize + 10)) then -- 629
					currentSet[itemName] = nil -- 630
					selectItems = false -- 631
				end -- 629
			end) -- 628
			NextColumn() -- 632
			for i = 1, #itemOptions do -- 633
				local item = itemOptions[i] -- 634
				if ImageButton(tostring(itemName) .. tostring(i), "Model/patreon.clip|" .. tostring(item), Vec2(itemSize, itemSize)) then -- 635
					currentSet[itemName] = item -- 636
					selectItems = false -- 637
				end -- 635
				NextColumn() -- 638
			end -- 638
		else -- 640
			if not currentSet[itemName] then -- 640
				Columns(3, false) -- 641
				PushID(tostring(itemName) .. "c1", function() -- 642
					if Button("x", Vec2(itemSize + 10, itemSize + 10)) then -- 643
						selectItems = true -- 643
					end -- 643
				end) -- 642
				NextColumn() -- 644
				return Text("未装备") -- 645
			else -- 647
				Columns(3, false) -- 647
				local item = currentSet[itemName] -- 648
				if ImageButton(tostring(itemName) .. "c2", "Model/patreon.clip|" .. tostring(item), Vec2(itemSize, itemSize)) then -- 649
					selectItems = true -- 649
				end -- 649
				NextColumn() -- 650
				TextColored(Color(0xfffffa0a), itemSettings[item].name) -- 651
				TextWrapped(itemSettings[item].desc) -- 652
				NextColumn() -- 653
				TextColored(Color(0xffff0a90), "消耗: " .. tostring(itemSettings[item].cost)) -- 654
				Text("特技: " .. tostring(itemSettings[item].skillDesc)) -- 655
				return NextColumn() -- 656
			end -- 640
		end -- 626
	end -- 656
end -- 620
local size, grid = 2000, 150 -- 660
local _anon_func_4 = function(Color, Line, Vec2, _with_0, grid, size) -- 681
	local _with_1 = Line() -- 670
	_with_1.depthWrite = true -- 671
	_with_1.z = -10 -- 672
	for i = -size / grid, size / grid do -- 673
		_with_1:add({ -- 675
			Vec2(i * grid, size), -- 675
			Vec2(i * grid, -size) -- 676
		}, Color(0xff000000)) -- 674
		_with_1:add({ -- 679
			Vec2(-size, i * grid), -- 679
			Vec2(size, i * grid) -- 680
		}, Color(0xff000000)) -- 678
	end -- 681
	return _with_1 -- 670
end -- 670
local background -- 662
background = function() -- 662
	local _with_0 = DrawNode() -- 662
	_with_0.depthWrite = true -- 663
	_with_0:drawPolygon({ -- 665
		Vec2(-size, size), -- 665
		Vec2(size, size), -- 666
		Vec2(size, -size), -- 667
		Vec2(-size, -size) -- 668
	}, Color(0xff888888)) -- 664
	_with_0:addChild(_anon_func_4(Color, Line, Vec2, _with_0, grid, size)) -- 670
	return _with_0 -- 662
end -- 662
do -- 683
	local _with_0 = background() -- 683
	_with_0.z = 600 -- 684
end -- 683
do -- 685
	local _with_0 = background() -- 685
	_with_0.angleX = 45 -- 686
end -- 685
local TerrainLayer = 0 -- 690
local EnemyLayer = 1 -- 691
local PlayerLayer = 2 -- 692
local PlayerGroup = 1 -- 694
local EnemyGroup = 2 -- 695
local DesignWidth <const> = 1500 -- 697
Data:setRelation(PlayerGroup, EnemyGroup, "Enemy") -- 699
Data:setShouldContact(PlayerGroup, EnemyGroup, true) -- 700
local world -- 702
do -- 702
	local _with_0 = PlatformWorld() -- 702
	_with_0.camera.boundary = Rect(-1250, -500, 2500, 1000) -- 703
	_with_0.camera.followRatio = Vec2(0.01, 0.01) -- 704
	_with_0.camera.zoom = View.size.width / DesignWidth -- 705
	_with_0:onAppChange(function(settingName) -- 706
		if settingName == "Size" then -- 706
			local zoom = View.size.width / DesignWidth -- 707
			_with_0.camera.zoom = zoom -- 708
		end -- 706
	end) -- 706
	world = _with_0 -- 702
end -- 702
Store["world"] = world -- 709
local terrainDef -- 711
do -- 711
	local _with_0 = BodyDef() -- 711
	_with_0.type = "Static" -- 712
	_with_0:attachPolygon(Vec2(0, 0), 2500, 10, 0, 1, 1, 0) -- 713
	_with_0:attachPolygon(Vec2(0, 1000), 2500, 10, 0, 1, 1, 0) -- 714
	_with_0:attachPolygon(Vec2(1250, 500), 10, 1000, 0, 1, 1, 0) -- 715
	_with_0:attachPolygon(Vec2(-1250, 500), 10, 1000, 0, 1, 1, 0) -- 716
	terrainDef = _with_0 -- 711
end -- 711
do -- 718
	local _with_0 = Body(terrainDef, world, Vec2.zero) -- 718
	_with_0.order = TerrainLayer -- 719
	_with_0.group = Data.groupTerrain -- 720
	_with_0:addTo(world) -- 721
end -- 718
local _anon_func_5 = function(Sprite, item, offset, tostring) -- 742
	local _with_0 = Sprite("Model/patreon.clip|" .. tostring(item)) -- 741
	_with_0.position = offset -- 742
	return _with_0 -- 741
end -- 741
local updateModel -- 723
updateModel = function(model, currentSet) -- 723
	local node = model:getNodeByName("body") -- 724
	node:removeAllChildren() -- 725
	local charType = characterTypes[currentSet.type] -- 726
	local charColor = characterColors[currentSet.color] -- 727
	node:addChild(Sprite("Model/patreon.clip|character_" .. tostring(charType) .. tostring(charColor))) -- 728
	node = model:getNodeByName("lhand") -- 729
	node:removeAllChildren() -- 730
	node:addChild(Sprite("Model/patreon.clip|character_hand" .. tostring(charColor))) -- 731
	node = model:getNodeByName("rhand") -- 732
	node:removeAllChildren() -- 733
	node:addChild(Sprite("Model/patreon.clip|character_hand" .. tostring(charColor))) -- 734
	model:getNodeByName("head"):removeAllChildren() -- 735
	for _index_0 = 1, #itemSlots do -- 736
		local slot = itemSlots[_index_0] -- 736
		node = model:getNodeByName(slot) -- 737
		local item = currentSet[slot] -- 738
		if item then -- 739
			local offset = itemSettings[item].offset -- 740
			node:addChild(_anon_func_5(Sprite, item, offset, tostring)) -- 741
		end -- 739
	end -- 742
end -- 723
local NewFighter -- 744
NewFighter = function(name, currentSet) -- 744
	local assembleFighter = false -- 745
	local fighter -- 746
	do -- 746
		local _with_0 = Model("Model/patreon.model") -- 746
		local modelRect = Rect(-128, -128, 256, 256) -- 747
		_with_0.recovery = 0.2 -- 748
		_with_0.order = PlayerLayer -- 749
		_with_0.touchEnabled = true -- 750
		_with_0.swallowTouches = true -- 751
		_with_0:slot("TapFilter", function(touch) -- 752
			if not modelRect:containsPoint(touch.location) then -- 753
				touch.enabled = false -- 754
			end -- 753
		end) -- 752
		_with_0:slot("Tapped", function() -- 755
			if not fighter:getChildByTag("select") then -- 756
				local selectFrame -- 757
				local _with_1 = Sprite("Model/patreon.clip|ui_select") -- 757
				_with_1:addTo(fighter, 0, "select") -- 758
				_with_1:runAction(Scale(0.3, 0, 1.8, Ease.OutBack)) -- 759
				assembleFighter = true -- 760
				selectFrame = _with_1 -- 757
			end -- 756
		end) -- 755
		_with_0:play("idle", true) -- 761
		fighter = _with_0 -- 746
	end -- 746
	updateModel(fighter, currentSet) -- 762
	local HeadItemPanel = NewItemPanel("头部", "head", headItems, currentSet) -- 763
	local LHandItemPanel = NewItemPanel("副手", "lhand", lhandItems, currentSet) -- 764
	local RHandItemPanel = NewItemPanel("主手", "rhand", rhandItems, currentSet) -- 765
	return fighter, function() -- 766
		SetNextWindowSize(Vec2(445, 600), "FirstUseEver") -- 767
		if assembleFighter then -- 768
			assembleFighter = false -- 769
			OpenPopup("战士" .. tostring(name)) -- 770
		end -- 768
		return BeginPopupModal("战士" .. tostring(name), { -- 771
			"NoResize", -- 771
			"NoSavedSettings" -- 771
		}, function() -- 771
			HeadItemPanel() -- 772
			RHandItemPanel() -- 773
			LHandItemPanel() -- 774
			Columns(1, false) -- 775
			TextColored(themeColor, "性别") -- 776
			NextColumn() -- 777
			local _ -- 778
			_, currentSet.type = RadioButton("男", currentSet.type, 1) -- 778
			SameLine() -- 779
			_, currentSet.type = RadioButton("女", currentSet.type, 2) -- 780
			Columns(1, false) -- 781
			local cost = 0 -- 782
			for _index_0 = 1, #itemSlots do -- 783
				local slot = itemSlots[_index_0] -- 783
				local item = currentSet[slot] -- 784
				cost = cost + (item and itemSettings[item].cost or 0) -- 785
			end -- 785
			TextColored(themeColor, "累计消耗资源：" .. tostring(cost)) -- 786
			NextColumn() -- 787
			Columns(2, false) -- 788
			if Button("进行训练！", Vec2(200, 80)) then -- 789
				updateModel(fighter, currentSet) -- 790
				CloseCurrentPopup() -- 791
				do -- 792
					local _with_0 = fighter:getChildByTag("select") -- 792
					_with_0:removeFromParent() -- 793
				end -- 792
				emit("ShowSetting", false) -- 794
				local charSet = 1 -- 795
				for i = 1, #characters do -- 796
					if currentSet == characters[i] then -- 797
						charSet = i -- 798
						break -- 799
					end -- 797
				end -- 799
				Entity({ -- 801
					unitDef = "fighter", -- 801
					charSet = charSet, -- 802
					order = PlayerLayer, -- 803
					position = Vec2(-400, 400), -- 804
					group = PlayerGroup, -- 805
					faceRight = true, -- 806
					player = true, -- 807
					decisionTree = "AI_PlayerControl" -- 808
				}) -- 800
				Entity({ -- 810
					unitDef = "boss", -- 810
					order = EnemyLayer, -- 811
					position = Vec2(400, 400), -- 812
					group = EnemyGroup, -- 813
					faceRight = false, -- 814
					boss = true -- 815
				}) -- 809
				emit("ShowTraining", true) -- 816
			end -- 789
			NextColumn() -- 817
			if Button("装备完成！", Vec2(200, 80)) then -- 818
				updateModel(fighter, currentSet) -- 819
				CloseCurrentPopup() -- 820
				local _with_0 = fighter:getChildByTag("select") -- 821
				_with_0:runAction(Sequence(Spawn(Scale(0.3, 1.8, 2.5), Opacity(0.3, 1, 0)), Event("End"))) -- 822
				_with_0:slot("End", function() -- 826
					return _with_0:removeFromParent() -- 826
				end) -- 826
			end -- 818
			return NextColumn() -- 827
		end) -- 827
	end -- 827
end -- 744
local fighterFigures = { } -- 829
local fighterPanels = { } -- 830
for i = 1, #characters do -- 831
	local fighter, fighterPanel = NewFighter(string.rep("I", i), characters[i]) -- 832
	table.insert(fighterFigures, fighter) -- 833
	table.insert(fighterPanels, fighterPanel) -- 834
end -- 834
local playerGroup = Group({ -- 836
	"player", -- 836
	"unit" -- 836
}) -- 836
local updatePlayerControl -- 837
updatePlayerControl = function(key, flag) -- 837
	return playerGroup:each(function(self) -- 837
		self.unit.data[key] = flag -- 837
	end) -- 837
end -- 837
Director.ui:addChild((function() -- 839
	local _with_0 = AlignNode(true) -- 839
	_with_0:css('flex-direction: column') -- 840
	_with_0:schedule(function() -- 841
		local width, height -- 842
		do -- 842
			local _obj_0 = App.visualSize -- 842
			width, height = _obj_0.width, _obj_0.height -- 842
		end -- 842
		SetNextWindowPos(Vec2(10, 10), "FirstUseEver") -- 843
		SetNextWindowSize(Vec2(350, 160), "FirstUseEver") -- 844
		return Begin("AI军团", { -- 845
			"NoResize", -- 845
			"NoSavedSettings" -- 845
		}, function() -- 845
			local isPC -- 846
			do -- 846
				local _exp_0 = App.platform -- 846
				if "macOS" == _exp_0 or "Windows" == _exp_0 or "Linux" == _exp_0 then -- 847
					isPC = true -- 847
				else -- 848
					isPC = false -- 848
				end -- 848
			end -- 848
			return TextWrapped("点击你的学员部队配备装备，并亲自进行战斗方法的训练，最后带领部队挑战敌人。\n学员战斗AI通过玩家操作自动学习生成。" .. tostring(isPC and '训练操作按键：向左A，向右D，闪避E，攻击J，跳跃K' or '')) -- 849
		end) -- 849
	end) -- 841
	_with_0:addChild((function() -- 850
		local _with_1 = AlignNode() -- 850
		_with_1:css("height: 30%") -- 851
		return _with_1 -- 850
	end)()) -- 850
	_with_0:addChild((function() -- 852
		local _with_1 = AlignNode() -- 852
		_with_1:css("height: 40%; align-items: center; justify-content: center") -- 853
		_with_1:addChild((function() -- 854
			local _with_2 = AlignNode() -- 854
			_with_2:css('height: 1; width: 0') -- 855
			_with_2:addChild((function() -- 856
				local _with_3 = Node() -- 856
				_with_3.visible = false -- 857
				_with_3.scaleX = 0.5 -- 858
				_with_3.scaleY = 0.5 -- 858
				_with_3:gslot("ShowTraining", function(show) -- 859
					_with_3.visible = show -- 860
					if show then -- 861
						return _with_3:addChild((function() -- 862
							local _with_4 = CircleButton({ -- 863
								text = "训练\n结束！", -- 863
								y = -150, -- 864
								radius = 80, -- 865
								fontName = "sarasa-mono-sc-regular", -- 866
								fontSize = 48 -- 867
							}) -- 862
							_with_4:slot("Tapped", function() -- 869
								emit("ShowTraining", false) -- 870
								Group({ -- 871
									"player" -- 871
								}):each(function(e) -- 871
									if e.charSet then -- 872
										emit("TrainAI", e.charSet) -- 873
										return e.unit:removeFromParent() -- 874
									end -- 872
								end) -- 871
								Group({ -- 875
									"boss" -- 875
								}):each(function(e) -- 875
									return e.unit:removeFromParent() -- 876
								end) -- 875
								return emit("ShowSetting", true) -- 877
							end) -- 869
							return _with_4 -- 862
						end)()) -- 877
					else -- 879
						return _with_3:removeAllChildren() -- 879
					end -- 861
				end) -- 859
				_with_3:gslot("ShowFight", function(show) -- 880
					_with_3.visible = show -- 881
					if show then -- 882
						return _with_3:addChild((function() -- 883
							local _with_4 = CircleButton({ -- 884
								text = "离开\n战斗", -- 884
								y = -150, -- 885
								radius = 80, -- 886
								fontName = "sarasa-mono-sc-regular", -- 887
								fontSize = 48 -- 888
							}) -- 883
							_with_4:slot("Tapped", function() -- 890
								Group({ -- 891
									"unitDef" -- 891
								}):each(function(e) -- 891
									local _obj_0 = e.unit -- 892
									if _obj_0 ~= nil then -- 892
										return _obj_0:removeFromParent() -- 892
									end -- 892
									return nil -- 892
								end) -- 891
								emit("ShowSetting", true) -- 893
								return thread(function() -- 894
									return emit("ShowFight", false) -- 894
								end) -- 894
							end) -- 890
							return _with_4 -- 883
						end)()) -- 894
					else -- 896
						return _with_3:removeAllChildren() -- 896
					end -- 882
				end) -- 880
				return _with_3 -- 856
			end)()) -- 856
			_with_2:addChild((function() -- 897
				local _with_3 = Node() -- 897
				_with_3:gslot("ShowSetting", function(show) -- 898
					_with_3.visible = show -- 898
				end) -- 898
				_with_3.scaleX = 0.5 -- 899
				_with_3.scaleY = 0.5 -- 899
				_with_3:addChild((function() -- 900
					local _with_4 = Model("Model/bossp.model") -- 900
					_with_4.x = 500 -- 901
					_with_4.y = 100 -- 902
					_with_4.fliped = true -- 903
					_with_4.speed = 0.8 -- 904
					_with_4.recovery = 0.2 -- 905
					_with_4.scaleX = 2 -- 906
					_with_4.scaleY = 2 -- 906
					_with_4:play("idle", true) -- 907
					return _with_4 -- 900
				end)()) -- 900
				for i = 1, #fighterFigures do -- 908
					local fighter = fighterFigures[i] -- 909
					_with_3:addChild((function() -- 910
						fighter.x = -500 + (i - 1) * 200 -- 911
						return fighter -- 910
					end)()) -- 910
				end -- 911
				_with_3:addChild((function() -- 912
					local _with_4 = CircleButton({ -- 913
						text = "开战！", -- 913
						y = -150, -- 914
						radius = 80, -- 915
						fontName = "sarasa-mono-sc-regular", -- 916
						fontSize = 48 -- 917
					}) -- 912
					local showItems -- 919
					showItems = function(show) -- 919
						for _index_0 = 1, #fighterFigures do -- 920
							local fighter = fighterFigures[_index_0] -- 920
							fighter.touchEnabled = not show -- 921
						end -- 921
						_with_4.visible = not show -- 922
					end -- 919
					_with_4:gslot("ShowFight", showItems) -- 923
					_with_4:gslot("ShowTraining", showItems) -- 924
					_with_4:slot("Tapped", function() -- 925
						if not _with_4.visible then -- 926
							return -- 926
						end -- 926
						for i = 1, #characters do -- 927
							Entity({ -- 929
								unitDef = "fighter", -- 929
								charSet = i, -- 930
								order = PlayerLayer, -- 931
								position = Vec2(-600 + (i - 1) * 200, 400), -- 932
								group = PlayerGroup, -- 933
								faceRight = true, -- 934
								decisionTree = "AI_Learned", -- 935
								player = true -- 936
							}) -- 928
						end -- 936
						Entity({ -- 938
							unitDef = "boss", -- 938
							order = EnemyLayer, -- 939
							position = Vec2(400, 400), -- 940
							group = EnemyGroup, -- 941
							faceRight = false, -- 942
							boss = true -- 943
						}) -- 937
						emit("ShowSetting", false) -- 944
						return emit("ShowFight", true) -- 945
					end) -- 925
					return _with_4 -- 912
				end)()) -- 912
				return _with_3 -- 897
			end)()) -- 897
			return _with_2 -- 854
		end)()) -- 854
		return _with_1 -- 852
	end)()) -- 852
	local _exp_0 = App.platform -- 946
	if "iOS" == _exp_0 or "Android" == _exp_0 then -- 947
		_with_0:addChild((function() -- 948
			local _with_1 = AlignNode() -- 948
			_with_1:css("\n					width: auto;\n					height: 30%;\n					padding-bottom: 40;\n					margin: 0, 10, 0;\n					flex-direction: row;\n					justify-content: space-between\n				") -- 949
			_with_1:gslot("ShowTraining", function(show) -- 957
				_with_1.visible = show -- 957
			end) -- 957
			_with_1:addChild((function() -- 958
				local _with_2 = AlignNode() -- 958
				_with_2:css('height: 100%; width: 0') -- 959
				_with_2:addChild((function() -- 960
					local _with_3 = Menu() -- 960
					_with_3.anchor = Vec2.zero -- 961
					_with_3.size = Size(130, 60) -- 962
					_with_3:addChild((function() -- 963
						local _with_4 = CircleButton({ -- 964
							text = "左", -- 964
							radius = 60, -- 965
							fontSize = math.floor(36) -- 966
						}) -- 963
						_with_4.scaleX = 0.5 -- 968
						_with_4.scaleY = 0.5 -- 968
						_with_4.anchor = Vec2.zero -- 969
						_with_4:slot("TapBegan", function() -- 970
							return updatePlayerControl("keyLeft", true) -- 970
						end) -- 970
						_with_4:slot("TapEnded", function() -- 971
							return updatePlayerControl("keyLeft", false) -- 971
						end) -- 971
						return _with_4 -- 963
					end)()) -- 963
					_with_3:addChild((function() -- 972
						local _with_4 = CircleButton({ -- 973
							text = "右", -- 973
							x = 70, -- 974
							radius = 60, -- 975
							fontSize = math.floor(36) -- 976
						}) -- 972
						_with_4.scaleX = 0.5 -- 978
						_with_4.scaleY = 0.5 -- 978
						_with_4.anchor = Vec2.zero -- 979
						_with_4:slot("TapBegan", function() -- 980
							return updatePlayerControl("keyRight", true) -- 980
						end) -- 980
						_with_4:slot("TapEnded", function() -- 981
							return updatePlayerControl("keyRight", false) -- 981
						end) -- 981
						return _with_4 -- 972
					end)()) -- 972
					return _with_3 -- 960
				end)()) -- 960
				return _with_2 -- 958
			end)()) -- 958
			_with_1:addChild((function() -- 982
				local _with_2 = AlignNode() -- 982
				_with_2:css('height: 100%; width: 0') -- 983
				_with_2:addChild((function() -- 984
					local _with_3 = Menu() -- 984
					_with_3.anchor = Vec2(1, 0) -- 985
					_with_3.size = Size(200, 60) -- 986
					_with_3:addChild((function() -- 987
						local _with_4 = CircleButton({ -- 988
							text = "闪", -- 988
							radius = 60, -- 989
							fontSize = math.floor(36) -- 990
						}) -- 987
						_with_4.scaleX = 0.5 -- 992
						_with_4.scaleY = 0.5 -- 992
						_with_4.anchor = Vec2.zero -- 993
						_with_4:slot("TapBegan", function() -- 994
							return updatePlayerControl("keyE", true) -- 994
						end) -- 994
						_with_4:slot("TapEnded", function() -- 995
							return updatePlayerControl("keyE", false) -- 995
						end) -- 995
						return _with_4 -- 987
					end)()) -- 987
					_with_3:addChild((function() -- 996
						local _with_4 = CircleButton({ -- 997
							text = "跳", -- 997
							x = 70, -- 998
							radius = 60, -- 999
							fontSize = math.floor(36) -- 1000
						}) -- 996
						_with_4.scaleX = 0.5 -- 1002
						_with_4.scaleY = 0.5 -- 1002
						_with_4.anchor = Vec2.zero -- 1003
						_with_4:slot("TapBegan", function() -- 1004
							return updatePlayerControl("keyUp", true) -- 1004
						end) -- 1004
						_with_4:slot("TapEnded", function() -- 1005
							return updatePlayerControl("keyUp", false) -- 1005
						end) -- 1005
						return _with_4 -- 996
					end)()) -- 996
					_with_3:addChild((function() -- 1006
						local _with_4 = CircleButton({ -- 1007
							text = "打", -- 1007
							x = 140, -- 1008
							radius = 60, -- 1009
							fontSize = math.floor(36) -- 1010
						}) -- 1006
						_with_4.scaleX = 0.5 -- 1012
						_with_4.scaleY = 0.5 -- 1012
						_with_4.anchor = Vec2.zero -- 1013
						_with_4:slot("TapBegan", function() -- 1014
							return updatePlayerControl("keyF", true) -- 1014
						end) -- 1014
						_with_4:slot("TapEnded", function() -- 1015
							return updatePlayerControl("keyF", false) -- 1015
						end) -- 1015
						return _with_4 -- 1006
					end)()) -- 1006
					return _with_3 -- 984
				end)()) -- 984
				return _with_2 -- 982
			end)()) -- 982
			return _with_1 -- 948
		end)()) -- 948
	elseif "macOS" == _exp_0 or "Windows" == _exp_0 or "Linux" == _exp_0 then -- 1016
		local _with_1 = Node() -- 1017
		_with_1:schedule(function() -- 1018
			updatePlayerControl("keyLeft", Keyboard:isKeyPressed("A")) -- 1019
			updatePlayerControl("keyRight", Keyboard:isKeyPressed("D")) -- 1020
			updatePlayerControl("keyUp", Keyboard:isKeyPressed("K")) -- 1021
			updatePlayerControl("keyF", Keyboard:isKeyPressed("J")) -- 1022
			return updatePlayerControl("keyE", Keyboard:isKeyPressed("E")) -- 1023
		end) -- 1018
	end -- 1023
	return _with_0 -- 839
end)()) -- 839
do -- 1025
	local _with_0 = Node() -- 1025
	_with_0:schedule(function() -- 1026
		local width, height -- 1027
		do -- 1027
			local _obj_0 = App.visualSize -- 1027
			width, height = _obj_0.width, _obj_0.height -- 1027
		end -- 1027
		for _index_0 = 1, #fighterPanels do -- 1028
			local panel = fighterPanels[_index_0] -- 1028
			panel() -- 1028
		end -- 1028
	end) -- 1026
end -- 1025
local rangeAttackEnd -- 1030
rangeAttackEnd = function(name, playable) -- 1030
	if name == "range" then -- 1031
		return playable.parent:stop() -- 1031
	end -- 1031
end -- 1030
UnitAction:add("range", { -- 1034
	priority = 3, -- 1034
	reaction = 10, -- 1035
	recovery = 0.1, -- 1036
	queued = true, -- 1037
	available = function() -- 1038
		return true -- 1038
	end, -- 1038
	create = function(self) -- 1039
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 1040
		do -- 1040
			local _obj_0 = self.entity -- 1045
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 1040
		end -- 1045
		do -- 1046
			local _with_0 = self.playable -- 1046
			_with_0.speed = attackSpeed -- 1047
			_with_0:play("range") -- 1048
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 1049
		end -- 1046
		return once(function(self) -- 1050
			local bulletDef = Store[self.unitDef.bulletType] -- 1051
			local onAttack -- 1052
			onAttack = function() -- 1052
				local _with_0 = Bullet(bulletDef, self) -- 1053
				_with_0.targetAllow = targetAllow -- 1054
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 1055
					do -- 1056
						local _with_1 = target.data -- 1056
						_with_1.hitPoint = pos -- 1057
						_with_1.hitPower = attackPower -- 1058
						_with_1.hitFromRight = bullet.velocityX < 0 -- 1059
					end -- 1056
					local entity = target.entity -- 1060
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 1061
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 1062
					entity.hp = entity.hp - damage -- 1063
					bullet.hitStop = true -- 1064
				end) -- 1055
				_with_0:addTo(self.world, self.order) -- 1065
				return _with_0 -- 1053
			end -- 1052
			sleep(0.5 * 28.0 / 30.0 / attackSpeed) -- 1066
			onAttack() -- 1067
			while true do -- 1068
				sleep() -- 1068
			end -- 1068
		end) -- 1068
	end, -- 1039
	stop = function(self) -- 1069
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 1070
	end -- 1069
}) -- 1033
local BigArrow -- 1072
do -- 1072
	local _with_0 = BulletDef() -- 1072
	_with_0.tag = "" -- 1073
	_with_0.endEffect = "" -- 1074
	_with_0.lifeTime = 5 -- 1075
	_with_0.damageRadius = 0 -- 1076
	_with_0.highSpeedFix = false -- 1077
	_with_0.gravity = Vec2(0, -10) -- 1078
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2(-100, 0), 2) -- 1079
	_with_0:setAsCircle(10) -- 1080
	_with_0:setVelocity(25, 800) -- 1081
	BigArrow = _with_0 -- 1072
end -- 1072
UnitAction:add("multiArrow", { -- 1084
	priority = 3, -- 1084
	reaction = 10, -- 1085
	recovery = 0.1, -- 1086
	queued = true, -- 1087
	available = function() -- 1088
		return true -- 1088
	end, -- 1088
	create = function(self) -- 1089
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 1090
		do -- 1090
			local _obj_0 = self.entity -- 1095
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 1090
		end -- 1095
		do -- 1096
			local _with_0 = self.playable -- 1096
			_with_0.speed = attackSpeed -- 1097
			_with_0:play("range") -- 1098
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 1099
		end -- 1096
		return once(function(self) -- 1100
			local onAttack -- 1101
			onAttack = function(angle, speed) -- 1101
				BigArrow:setVelocity(angle, speed) -- 1102
				local _with_0 = Bullet(BigArrow, self) -- 1103
				_with_0.targetAllow = targetAllow -- 1104
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 1105
					do -- 1106
						local _with_1 = target.data -- 1106
						_with_1.hitPoint = pos -- 1107
						_with_1.hitPower = attackPower -- 1108
						_with_1.hitFromRight = bullet.velocityX < 0 -- 1109
					end -- 1106
					local entity = target.entity -- 1110
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 1111
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 1112
					entity.hp = entity.hp - damage -- 1113
					bullet.hitStop = true -- 1114
				end) -- 1105
				_with_0:addTo(self.world, self.order) -- 1115
				return _with_0 -- 1103
			end -- 1101
			sleep(30.0 / 60.0 / attackSpeed) -- 1116
			onAttack(30, 1100) -- 1117
			onAttack(10, 1000) -- 1118
			onAttack(-10, 900) -- 1119
			onAttack(-30, 800) -- 1120
			onAttack(-50, 700) -- 1121
			while true do -- 1122
				sleep() -- 1122
			end -- 1122
		end) -- 1122
	end, -- 1089
	stop = function(self) -- 1123
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 1124
	end -- 1123
}) -- 1083
UnitAction:add("fallOff", { -- 1127
	priority = 1, -- 1127
	reaction = 1, -- 1128
	recovery = 0, -- 1129
	available = function(self) -- 1130
		return not self.onSurface -- 1130
	end, -- 1130
	create = function(self) -- 1131
		if self.velocityY <= 0 then -- 1132
			self.data.fallDown = true -- 1133
			local _with_0 = self.playable -- 1134
			_with_0.speed = 2.5 -- 1135
			_with_0:play("idle") -- 1136
		else -- 1137
			self.data.fallDown = false -- 1137
		end -- 1132
		return function(self) -- 1138
			if self.onSurface then -- 1139
				return true -- 1139
			end -- 1139
			if not self.data.fallDown and self.velocityY <= 0 then -- 1140
				self.data.fallDown = true -- 1141
				local _with_0 = self.playable -- 1142
				_with_0.speed = 2.5 -- 1143
				_with_0:play("idle") -- 1144
			end -- 1140
			return false -- 1145
		end -- 1145
	end -- 1131
}) -- 1126
UnitAction:add("evade", { -- 1148
	priority = 10, -- 1148
	reaction = 10, -- 1149
	recovery = 0, -- 1150
	queued = true, -- 1151
	available = function() -- 1152
		return true -- 1152
	end, -- 1152
	create = function(self) -- 1153
		do -- 1154
			local _with_0 = self.playable -- 1154
			_with_0.speed = 1.0 -- 1155
			_with_0.recovery = 0.0 -- 1156
			_with_0:play("bevade") -- 1157
		end -- 1154
		return once(function(self) -- 1158
			local group = self.group -- 1159
			self.group = Data.groupHide -- 1160
			local dir = self.faceRight and -1 or 1 -- 1161
			cycle(0.2, function() -- 1162
				self.velocityX = 800 * dir -- 1162
			end) -- 1162
			self.group = group -- 1163
			do -- 1164
				local _with_0 = self.playable -- 1164
				_with_0.speed = 1.0 -- 1165
				_with_0:play("idle") -- 1166
			end -- 1164
			sleep(1) -- 1167
			return true -- 1168
		end) -- 1168
	end -- 1153
}) -- 1147
local spearAttackEnd -- 1170
spearAttackEnd = function(name, playable) -- 1170
	if name == "spear" then -- 1171
		return playable.parent:stop() -- 1171
	end -- 1171
end -- 1170
UnitAction:add("spearAttack", { -- 1174
	priority = 3, -- 1174
	reaction = 10, -- 1175
	recovery = 0.1, -- 1176
	queued = true, -- 1177
	available = function() -- 1178
		return true -- 1178
	end, -- 1178
	create = function(self) -- 1179
		local attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor -- 1180
		do -- 1180
			local _obj_0 = self.entity -- 1184
			attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 1180
		end -- 1184
		do -- 1185
			local _with_0 = self.playable -- 1185
			_with_0.speed = attackSpeed -- 1186
			_with_0.recovery = 0.2 -- 1187
			_with_0:play("spear") -- 1188
			_with_0:slot("AnimationEnd", spearAttackEnd) -- 1189
		end -- 1185
		return once(function(self) -- 1190
			sleep(50.0 / 60.0) -- 1191
			local dir = self.faceRight and 0 or -900 -- 1192
			local origin = self.position - Vec2(0, 205) + Vec2(dir, 0) -- 1193
			local size = Size(900, 40) -- 1194
			world:query(Rect(origin, size), function(body) -- 1195
				local entity = body.entity -- 1196
				if entity and Data:isEnemy(body, self) then -- 1197
					do -- 1198
						local _with_0 = body.data -- 1198
						_with_0.hitPoint = body.position -- 1199
						_with_0.hitPower = attackPower -- 1200
						_with_0.hitFromRight = not self.faceRight -- 1201
					end -- 1198
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 1202
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 1203
					entity.hp = entity.hp - damage -- 1204
				end -- 1197
				return false -- 1205
			end) -- 1195
			while true do -- 1206
				sleep() -- 1206
			end -- 1206
		end) -- 1206
	end, -- 1179
	stop = function(self) -- 1207
		return self.playable:slot("AnimationEnd"):remove(spearAttackEnd) -- 1208
	end -- 1207
}) -- 1173
local mutables = { -- 1211
	"hp", -- 1211
	"moveSpeed", -- 1212
	"move", -- 1213
	"jump", -- 1214
	"targetAllow", -- 1215
	"attackBase", -- 1216
	"attackPower", -- 1217
	"attackSpeed", -- 1218
	"damageType", -- 1219
	"attackBonus", -- 1220
	"attackFactor", -- 1221
	"attackTarget", -- 1222
	"defenceType" -- 1223
} -- 1210
do -- 1226
	local _with_0 = Observer("Add", { -- 1226
		"unitDef", -- 1226
		"position", -- 1226
		"order", -- 1226
		"group", -- 1226
		"faceRight" -- 1226
	}) -- 1226
	_with_0:watch(function(self, unitDef, position, order, group) -- 1227
		local player, faceRight, charSet, decisionTree = self.player, self.faceRight, self.charSet, self.decisionTree -- 1228
		world = Store.world -- 1229
		local func = UnitDefFuncs[unitDef] -- 1230
		local def = func() -- 1231
		for _index_0 = 1, #mutables do -- 1232
			local var = mutables[_index_0] -- 1232
			self[var] = def[var] -- 1233
		end -- 1233
		if charSet then -- 1234
			local set = characters[charSet] -- 1235
			local actions = def.actions -- 1236
			local actionSet -- 1237
			do -- 1237
				local _tbl_0 = { } -- 1237
				for _index_0 = 1, #actions do -- 1237
					local a = actions[_index_0] -- 1237
					_tbl_0[a] = true -- 1237
				end -- 1237
				actionSet = _tbl_0 -- 1237
			end -- 1237
			for _index_0 = 1, #itemSlots do -- 1238
				local slot = itemSlots[_index_0] -- 1238
				local item = set[slot] -- 1239
				if not item then -- 1240
					goto _continue_0 -- 1240
				end -- 1240
				local skill = itemSettings[item].skill -- 1241
				if skill and not actionSet[skill] then -- 1242
					actions:add(skill) -- 1243
				end -- 1242
				local attackRange = itemSettings[item].attackRange -- 1244
				if attackRange then -- 1245
					def.attackRange = attackRange -- 1245
				end -- 1245
				::_continue_0:: -- 1239
			end -- 1245
		end -- 1234
		if decisionTree then -- 1246
			def.decisionTree = decisionTree -- 1246
		end -- 1246
		local unit -- 1247
		do -- 1247
			local _with_1 = Unit(def, world, self, position) -- 1247
			_with_1.group = group -- 1248
			_with_1.order = order -- 1249
			_with_1.faceRight = faceRight -- 1250
			_with_1:addTo(world) -- 1251
			unit = _with_1 -- 1247
		end -- 1247
		if charSet then -- 1252
			updateModel(unit.playable, characters[charSet]) -- 1252
		end -- 1252
		if player then -- 1253
			world.camera.followTarget = unit -- 1254
		end -- 1253
		return false -- 1254
	end) -- 1227
end -- 1226
local _with_0 = Observer("Change", { -- 1256
	"hp", -- 1256
	"unit" -- 1256
}) -- 1256
_with_0:watch(function(self, hp, unit) -- 1257
	local boss = self.boss -- 1258
	local lastHp = self.oldValues.hp -- 1259
	if hp < lastHp then -- 1260
		if not boss and unit:isDoing("hit") then -- 1261
			unit:start("cancel") -- 1261
		end -- 1261
		if boss then -- 1262
			local _with_1 = Visual("Particle/bloodp.par") -- 1263
			_with_1.position = unit.data.hitPoint -- 1264
			_with_1:addTo(world, unit.order) -- 1265
			_with_1:autoRemove() -- 1266
			_with_1:start() -- 1267
		end -- 1262
		if hp > 0 then -- 1268
			unit:start("hit") -- 1269
		else -- 1271
			unit:start("hit") -- 1271
			unit:start("fall") -- 1272
			unit.group = Data.groupHide -- 1273
			if self.player then -- 1274
				playerGroup:each(function(p) -- 1275
					if p and p.unit and p.hp > 0 then -- 1276
						world.camera.followTarget = p.unit -- 1277
						return true -- 1278
					else -- 1279
						return false -- 1279
					end -- 1276
				end) -- 1275
			end -- 1274
		end -- 1268
	end -- 1260
	return false -- 1279
end) -- 1257
return _with_0 -- 1256
