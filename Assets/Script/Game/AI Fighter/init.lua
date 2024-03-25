-- [yue]: Script/Game/AI Fighter/init.yue
local _module_1 = dora.Platformer -- 1
local Data = _module_1.Data -- 1
local Vec2 = dora.Vec2 -- 1
local Size = dora.Size -- 1
local Group = dora.Group -- 1
local App = dora.App -- 1
local _module_2 = dora.Platformer.Decision -- 1
local Seq = _module_2.Seq -- 1
local Con = _module_2.Con -- 1
local AI = _module_2.AI -- 1
local math = _G.math -- 1
local Sel = _module_2.Sel -- 1
local Act = _module_2.Act -- 1
local Node = dora.Node -- 1
local type = _G.type -- 1
local tostring = _G.tostring -- 1
local table = _G.table -- 1
local thread = dora.thread -- 1
local ML = dora.ML -- 1
local string = _G.string -- 1
local print = _G.print -- 1
local load = _G.load -- 1
local emit = dora.emit -- 1
local Accept = _module_2.Accept -- 1
local BulletDef = _module_1.BulletDef -- 1
local Face = _module_1.Face -- 1
local Reject = _module_2.Reject -- 1
local Dictionary = dora.Dictionary -- 1
local TargetAllow = _module_1.TargetAllow -- 1
local Array = dora.Array -- 1
local _module_0 = dora.ImGui -- 1
local Columns = _module_0.Columns -- 1
local TextColored = _module_0.TextColored -- 1
local NextColumn = _module_0.NextColumn -- 1
local PushID = _module_0.PushID -- 1
local Button = _module_0.Button -- 1
local ImageButton = _module_0.ImageButton -- 1
local Text = _module_0.Text -- 1
local Color = dora.Color -- 1
local TextWrapped = _module_0.TextWrapped -- 1
local DrawNode = dora.DrawNode -- 1
local Line = dora.Line -- 1
local PlatformWorld = _module_1.PlatformWorld -- 1
local Rect = dora.Rect -- 1
local View = dora.View -- 1
local Director = dora.Director -- 1
local BodyDef = dora.BodyDef -- 1
local Body = dora.Body -- 1
local Sprite = dora.Sprite -- 1
local Model = dora.Model -- 1
local Scale = dora.Scale -- 1
local Ease = dora.Ease -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local OpenPopup = _module_0.OpenPopup -- 1
local BeginPopupModal = _module_0.BeginPopupModal -- 1
local RadioButton = _module_0.RadioButton -- 1
local SameLine = _module_0.SameLine -- 1
local CloseCurrentPopup = _module_0.CloseCurrentPopup -- 1
local Entity = dora.Entity -- 1
local Sequence = dora.Sequence -- 1
local Spawn = dora.Spawn -- 1
local Opacity = dora.Opacity -- 1
local Event = dora.Event -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local Begin = _module_0.Begin -- 1
local Menu = dora.Menu -- 1
local Keyboard = dora.Keyboard -- 1
local UnitAction = _module_1.UnitAction -- 1
local once = dora.once -- 1
local Bullet = _module_1.Bullet -- 1
local sleep = dora.sleep -- 1
local cycle = dora.cycle -- 1
local Observer = dora.Observer -- 1
local Unit = _module_1.Unit -- 1
local Visual = _module_1.Visual -- 1
local AlignNode = require("UI.Control.Basic.AlignNode") -- 16
local CircleButton = require("UI.Control.Basic.CircleButton") -- 17
local Store = Data.store -- 18
local characters = { -- 23
	{ -- 23
		body = "character_roundGreen", -- 23
		lhand = "character_handGreen", -- 24
		rhand = "character_handGreen" -- 25
	}, -- 23
	{ -- 27
		body = "character_roundRed", -- 27
		lhand = "character_handRed", -- 28
		rhand = "character_handRed" -- 29
	}, -- 27
	{ -- 31
		body = "character_roundYellow", -- 31
		lhand = "character_handYellow", -- 32
		rhand = "character_handYellow" -- 33
	} -- 31
} -- 22
local headItems = { -- 36
	"item_hat", -- 36
	"item_hatTop", -- 37
	"item_helmet", -- 38
	"item_helmetModern" -- 39
} -- 35
local lhandItems = { -- 42
	"item_shield", -- 42
	"item_shieldRound", -- 43
	"tile_heart", -- 44
	"ui_hand" -- 45
} -- 41
local rhandItems = { -- 48
	"item_bow", -- 48
	"item_sword", -- 49
	"item_rod", -- 50
	"item_spear" -- 51
} -- 47
local characterTypes = { -- 54
	"square", -- 54
	"round" -- 55
} -- 53
local characterColors = { -- 58
	"Green", -- 58
	"Red", -- 59
	"Yellow" -- 60
} -- 57
local itemSettings = { -- 63
	item_hat = { -- 64
		name = "普通帽子", -- 64
		desc = "就是很普通的帽子，增加许些防御力", -- 65
		cost = 1, -- 66
		skill = "jump", -- 67
		skillDesc = "跳跃", -- 68
		offset = Vec2(0, 30) -- 69
	}, -- 63
	item_hatTop = { -- 72
		name = "高帽子", -- 72
		desc = "就是很普通的帽子，增加许些防御力", -- 73
		cost = 1, -- 74
		skill = "evade", -- 75
		skillDesc = "闪避", -- 76
		offset = Vec2(0, 30) -- 77
	}, -- 71
	item_helmet = { -- 80
		name = "战盔", -- 80
		desc = "就是很普通的帽子，增加许些防御力", -- 81
		cost = 1, -- 82
		skill = "evade", -- 83
		skillDesc = "闪避", -- 84
		offset = Vec2(0, 0) -- 85
	}, -- 79
	item_helmetModern = { -- 88
		name = "橄榄球盔", -- 88
		desc = "就是很普通的帽子，增加许些防御力", -- 89
		cost = 1, -- 90
		skill = "", -- 91
		skillDesc = "无", -- 92
		offset = Vec2(0, 0) -- 93
	}, -- 87
	item_shield = { -- 96
		name = "方形盾", -- 96
		desc = "无", -- 97
		cost = 1, -- 98
		skill = "evade", -- 99
		skillDesc = "闪避", -- 100
		offset = Vec2(0, 0) -- 101
	}, -- 95
	item_shieldRound = { -- 104
		name = "小圆盾", -- 104
		desc = "无", -- 105
		cost = 1, -- 106
		skill = "jump", -- 107
		skillDesc = "跳跃", -- 108
		offset = Vec2(0, 0) -- 109
	}, -- 103
	tile_heart = { -- 112
		name = "爱心", -- 112
		desc = "无", -- 113
		cost = 1, -- 114
		skill = "jump", -- 115
		skillDesc = "跳跃", -- 116
		offset = Vec2(0, 0) -- 117
	}, -- 111
	ui_hand = { -- 120
		name = "手套", -- 120
		desc = "无", -- 121
		cost = 1, -- 122
		skill = "evade", -- 123
		skillDesc = "闪避", -- 124
		offset = Vec2(0, 0) -- 125
	}, -- 119
	item_bow = { -- 128
		name = "短弓", -- 128
		desc = "无", -- 129
		cost = 1, -- 130
		skill = "range", -- 131
		skillDesc = "远程攻击", -- 132
		offset = Vec2(10, 0), -- 133
		attackRange = Size(630, 150) -- 134
	}, -- 127
	item_sword = { -- 137
		name = "剑", -- 137
		desc = "无", -- 138
		cost = 1, -- 139
		skill = "meleeAttack", -- 140
		skillDesc = "近程攻击", -- 141
		offset = Vec2(15, 50), -- 142
		attackRange = Size(120, 150) -- 143
	}, -- 136
	item_rod = { -- 146
		name = "法杖", -- 146
		desc = "无", -- 147
		cost = 1, -- 148
		skill = "meleeAttack", -- 149
		skillDesc = "近程攻击", -- 150
		offset = Vec2(15, 50), -- 151
		attackRange = Size(200, 150) -- 152
	}, -- 145
	item_spear = { -- 155
		name = "长矛", -- 155
		desc = "无", -- 156
		cost = 1, -- 157
		skill = "meleeAttack", -- 158
		skillDesc = "近程攻击", -- 159
		offset = Vec2(15, 50), -- 160
		attackRange = Size(200, 150) -- 161
	} -- 154
} -- 62
local itemSlots = { -- 164
	"head", -- 164
	"lhand", -- 165
	"rhand" -- 166
} -- 163
characters = { -- 169
	{ -- 169
		head = nil, -- 169
		lhand = nil, -- 170
		rhand = nil, -- 171
		type = 1, -- 172
		color = 1, -- 173
		learnedAI = function() -- 174
			return "unknown" -- 174
		end -- 174
	}, -- 169
	{ -- 176
		head = nil, -- 176
		lhand = nil, -- 177
		rhand = nil, -- 178
		type = 1, -- 179
		color = 2, -- 180
		learnedAI = function() -- 181
			return "unknown" -- 181
		end -- 181
	}, -- 176
	{ -- 183
		head = nil, -- 183
		lhand = nil, -- 184
		rhand = nil, -- 185
		type = 1, -- 186
		color = 3, -- 187
		learnedAI = function() -- 188
			return "unknown" -- 188
		end -- 188
	} -- 183
} -- 168
local bossGroup = Group({ -- 190
	"boss" -- 190
}) -- 190
local lastAction = "idle" -- 192
local lastActionFrame = App.frame -- 193
local data = { } -- 194
local row = nil -- 195
local _anon_func_0 = function(enemy) -- 237
	local _obj_0 = enemy.currentAction -- 237
	if _obj_0 ~= nil then -- 237
		return _obj_0.name -- 237
	end -- 237
	return nil -- 237
end -- 237
local Do -- 196
Do = function(name) -- 196
	return Seq({ -- 197
		Con("Collect data", function(self) -- 197
			if self:isDoing(name) then -- 198
				row = nil -- 199
				return true -- 200
			end -- 198
			if not (AI:getNearestUnit("Enemy") ~= nil) then -- 202
				row = nil -- 203
				return true -- 204
			end -- 202
			local attack_ready -- 206
			do -- 206
				local attackUnits = AI:getUnitsInAttackRange() -- 207
				local ready = false -- 208
				for _index_0 = 1, #attackUnits do -- 209
					local unit = attackUnits[_index_0] -- 209
					if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 210
						ready = true -- 212
						break -- 213
					end -- 210
				end -- 213
				attack_ready = ready -- 214
			end -- 214
			local not_facing_enemy -- 216
			do -- 216
				local enemy = AI:getNearestUnit("Enemy") -- 217
				if enemy then -- 218
					not_facing_enemy = (self.x > enemy.x) == self.faceRight -- 219
				else -- 221
					not_facing_enemy = false -- 221
				end -- 218
			end -- 221
			local enemy_in_attack_range -- 223
			do -- 223
				local enemy = AI:getNearestUnit("Enemy") -- 224
				local attackUnits = AI:getUnitsInAttackRange() -- 225
				enemy_in_attack_range = attackUnits and attackUnits:contains(enemy) or false -- 226
			end -- 226
			local nearest_enemy_distance -- 228
			do -- 228
				local enemy = AI:getNearestUnit("Enemy") -- 229
				if (enemy ~= nil) then -- 230
					nearest_enemy_distance = math.abs(enemy.x - self.x) -- 231
				else -- 233
					nearest_enemy_distance = 999999 -- 233
				end -- 230
			end -- 233
			local enemy_hero_action -- 235
			do -- 235
				local enemy = AI:getNearestUnit("Enemy") -- 236
				enemy_hero_action = _anon_func_0(enemy) or "unknown" -- 237
			end -- 237
			row = { -- 240
				not_facing_enemy = not_facing_enemy, -- 240
				enemy_in_attack_range = enemy_in_attack_range, -- 241
				attack_ready = attack_ready, -- 242
				enemy_hero_action = enemy_hero_action, -- 243
				nearest_enemy_distance = nearest_enemy_distance, -- 244
				action = name -- 245
			} -- 239
			return true -- 247
		end), -- 197
		Sel({ -- 249
			Con("is doing", function(self) -- 249
				return self:isDoing(name) -- 249
			end), -- 249
			Seq({ -- 251
				Act(name), -- 251
				Con("action succeeded", function(self) -- 252
					lastAction = name -- 253
					lastActionFrame = App.frame -- 254
					return true -- 255
				end) -- 252
			}) -- 250
		}), -- 248
		Con("Save data", function(self) -- 258
			if row == nil then -- 259
				return true -- 259
			end -- 259
			data[#data + 1] = row -- 260
			return true -- 261
		end) -- 258
	}) -- 262
end -- 196
local rowNames = { -- 265
	"not_facing_enemy", -- 265
	"enemy_in_attack_range", -- 266
	"attack_ready", -- 268
	"enemy_hero_action", -- 269
	"nearest_enemy_distance", -- 270
	"action" -- 272
} -- 264
local rowTypes = { -- 276
	'C', -- 276
	'C', -- 276
	'C', -- 277
	'C', -- 277
	'N', -- 277
	'C' -- 278
} -- 275
local _anon_func_1 = function(_with_0, name, op, tostring, value) -- 296
	if name ~= "" then -- 296
		return "if " .. tostring(name) .. " " .. tostring(op) .. " " .. tostring(op == '==' and "\"" .. tostring(value) .. "\"" or value) -- 297
	else -- 299
		return tostring(op) .. " \"" .. tostring(value) .. "\"" -- 299
	end -- 296
end -- 296
local _anon_func_2 = function(_with_0, load, luaCodes) -- 307
	local _obj_0 = load(luaCodes) -- 307
	if _obj_0 ~= nil then -- 307
		return _obj_0() -- 307
	end -- 307
	return nil -- 307
end -- 307
do -- 281
	local _with_0 = Node() -- 281
	_with_0:gslot("TrainAI", function(charSet) -- 282
		local csvData -- 283
		do -- 283
			local _accum_0 = { } -- 283
			local _len_0 = 1 -- 283
			for _index_0 = 1, #data do -- 283
				local row = data[_index_0] -- 283
				local rd -- 284
				do -- 284
					local _accum_1 = { } -- 284
					local _len_1 = 1 -- 284
					for _index_1 = 1, #rowNames do -- 284
						local name = rowNames[_index_1] -- 284
						local val -- 285
						if (row[name] ~= nil) then -- 285
							val = row[name] -- 285
						else -- 285
							val = "N" -- 285
						end -- 285
						if "boolean" == type(val) then -- 286
							if val then -- 287
								val = "T" -- 287
							else -- 287
								val = "F" -- 287
							end -- 287
						end -- 286
						_accum_1[_len_1] = tostring(val) -- 288
						_len_1 = _len_1 + 1 -- 288
					end -- 288
					rd = _accum_1 -- 284
				end -- 288
				_accum_0[_len_0] = table.concat(rd, ",") -- 289
				_len_0 = _len_0 + 1 -- 289
			end -- 289
			csvData = _accum_0 -- 283
		end -- 289
		local names = tostring(table.concat(rowNames, ',')) .. "\n" -- 290
		local dataStr = tostring(names) .. tostring(table.concat(rowTypes, ',')) .. "\n" .. tostring(table.concat(csvData, '\n')) -- 291
		data = { } -- 292
		return thread(function() -- 293
			local lines = { -- 294
				"(_ENV) ->" -- 294
			} -- 294
			local accuracy = ML.BuildDecisionTreeAsync(dataStr, 0, function(depth, name, op, value) -- 295
				local line = string.rep("\t", depth + 1) .. _anon_func_1(_with_0, name, op, tostring, value) -- 296
				lines[#lines + 1] = line -- 300
			end) -- 295
			local codes = table.concat(lines, "\n") -- 301
			print("learning accuracy: " .. tostring(accuracy)) -- 302
			print(codes) -- 303
			local yue = require("yue") -- 305
			local luaCodes = yue.to_lua(codes, { -- 306
				reserve_line_number = false -- 306
			}) -- 306
			local learnedAI = _anon_func_2(_with_0, load, luaCodes) or function() -- 307
				return "unknown" -- 307
			end -- 307
			characters[charSet].learnedAI = learnedAI -- 308
			return emit("LearnedAI", learnedAI) -- 309
		end) -- 309
	end) -- 282
end -- 281
local _anon_func_3 = function(enemy) -- 365
	local _obj_0 = enemy.currentAction -- 365
	if _obj_0 ~= nil then -- 365
		return _obj_0.name -- 365
	end -- 365
	return nil -- 365
end -- 365
Store["AI_Learned"] = Sel({ -- 312
	Seq({ -- 313
		Con("is dead", function(self) -- 313
			return self.entity.hp <= 0 -- 313
		end), -- 313
		Accept() -- 314
	}), -- 312
	Seq({ -- 317
		Con("is falling", function(self) -- 317
			return not self.onSurface -- 317
		end), -- 317
		Act("fallOff") -- 318
	}), -- 316
	Seq({ -- 321
		Con("run learned AI", function(self) -- 321
			local _obj_0 = self.data -- 322
			_obj_0.lastActionTime = _obj_0.lastActionTime or 0.0 -- 322
			if not (AI:getNearestUnit("Enemy") ~= nil) then -- 324
				return false -- 324
			end -- 324
			if App.totalTime - self.data.lastActionTime < 0.1 then -- 326
				return false -- 327
			else -- 329
				self.data.lastActionTime = App.totalTime -- 329
			end -- 326
			local attack_ready -- 331
			do -- 331
				local attackUnits = AI:getUnitsInAttackRange() -- 332
				local ready = "F" -- 333
				for _index_0 = 1, #attackUnits do -- 334
					local unit = attackUnits[_index_0] -- 334
					if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 335
						ready = "T" -- 337
						break -- 338
					end -- 335
				end -- 338
				attack_ready = ready -- 339
			end -- 339
			local not_facing_enemy -- 341
			do -- 341
				local enemy = AI:getNearestUnit("Enemy") -- 342
				if enemy then -- 343
					if (self.x > enemy.x) == self.faceRight then -- 344
						not_facing_enemy = "T" -- 345
					else -- 347
						not_facing_enemy = "F" -- 347
					end -- 344
				else -- 349
					not_facing_enemy = "F" -- 349
				end -- 343
			end -- 349
			local enemy_in_attack_range -- 351
			do -- 351
				local enemy = AI:getNearestUnit("Enemy") -- 352
				local attackUnits = AI:getUnitsInAttackRange() -- 353
				enemy_in_attack_range = (attackUnits and attackUnits:contains(enemy)) and "T" or "F" -- 354
			end -- 354
			local nearest_enemy_distance -- 356
			do -- 356
				local enemy = AI:getNearestUnit("Enemy") -- 357
				if (enemy ~= nil) then -- 358
					nearest_enemy_distance = math.abs(enemy.x - self.x) -- 359
				else -- 361
					nearest_enemy_distance = 999999 -- 361
				end -- 358
			end -- 361
			local enemy_hero_action -- 363
			do -- 363
				local enemy = AI:getNearestUnit("Enemy") -- 364
				enemy_hero_action = _anon_func_3(enemy) or "unknown" -- 365
			end -- 365
			self.entity.learnedAction = characters[self.entity.charSet].learnedAI({ -- 368
				not_facing_enemy = not_facing_enemy, -- 368
				enemy_in_attack_range = enemy_in_attack_range, -- 369
				attack_ready = attack_ready, -- 370
				enemy_hero_action = enemy_hero_action, -- 371
				nearest_enemy_distance = nearest_enemy_distance -- 372
			}) or "unknown" -- 367
			return true -- 374
		end), -- 321
		Sel({ -- 376
			Con("is doing", function(self) -- 376
				return self:isDoing(self.entity.learnedAction) -- 376
			end), -- 376
			Seq({ -- 378
				Act(function(self) -- 378
					return self.entity.learnedAction -- 378
				end), -- 378
				Con("Succeeded prediction", function(self) -- 379
					emit("Prediction", true) -- 380
					return true -- 381
				end) -- 379
			}), -- 377
			Con("Failed prediction", function(self) -- 383
				emit("Prediction", false) -- 384
				return false -- 385
			end) -- 383
		}) -- 375
	}), -- 320
	Seq({ -- 389
		Con("not facing enemy", function(self) -- 389
			return bossGroup:each(function(boss) -- 389
				local unit = boss.unit -- 390
				if Data:isEnemy(unit, self) then -- 391
					if (self.x > unit.x) == self.faceRight then -- 392
						return true -- 393
					end -- 392
				end -- 391
			end) -- 393
		end), -- 389
		Act("turn") -- 394
	}), -- 388
	Seq({ -- 397
		Con("need turn", function(self) -- 397
			return (self.x < -1000 and not self.faceRight) or (self.x > 1000 and self.faceRight) -- 398
		end), -- 397
		Act("turn") -- 399
	}), -- 396
	Sel({ -- 402
		Seq({ -- 403
			Con("take a break", function(self) -- 403
				return App.rand % 60 == 0 -- 403
			end), -- 403
			Act("idle") -- 404
		}), -- 402
		Act("walk") -- 406
	}) -- 401
}) -- 311
do -- 410
	local _with_0 = BulletDef() -- 410
	_with_0.tag = "" -- 411
	_with_0.endEffect = "" -- 412
	_with_0.lifeTime = 5 -- 413
	_with_0.damageRadius = 0 -- 414
	_with_0.highSpeedFix = false -- 415
	_with_0.gravity = Vec2(0, -10) -- 416
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2(0, 0)) -- 417
	_with_0:setAsCircle(10) -- 418
	_with_0:setVelocity(25, 800) -- 419
	Store["Bullet_Arrow"] = _with_0 -- 410
end -- 410
Store["AI_Boss"] = Sel({ -- 422
	Seq({ -- 423
		Con("is dead", function(self) -- 423
			return self.entity.hp <= 0 -- 423
		end), -- 423
		Accept() -- 424
	}), -- 422
	Seq({ -- 427
		Con("is falling", function(self) -- 427
			return not self.onSurface -- 427
		end), -- 427
		Act("fallOff") -- 428
	}), -- 426
	Seq({ -- 431
		Con("is not attacking", function(self) -- 431
			return not self:isDoing("meleeAttack") and not self:isDoing("multiArrow") and not self:isDoing("spearAttack") -- 434
		end), -- 431
		Con("need attack", function(self) -- 435
			local attackUnits = AI:getUnitsInAttackRange() -- 436
			for _index_0 = 1, #attackUnits do -- 437
				local unit = attackUnits[_index_0] -- 437
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 438
					return true -- 440
				end -- 438
			end -- 440
			return false -- 441
		end), -- 435
		Sel({ -- 443
			Seq({ -- 444
				Con("melee attack", function(self) -- 444
					return App.rand % 250 == 0 -- 444
				end), -- 444
				Act("meleeAttack") -- 445
			}), -- 443
			Seq({ -- 448
				Con("range attack", function(self) -- 448
					return App.rand % 250 == 0 -- 448
				end), -- 448
				Act("multiArrow") -- 449
			}), -- 447
			Seq({ -- 452
				Con("spear attack", function(self) -- 452
					return App.rand % 250 == 0 -- 452
				end), -- 452
				Act("spearAttack") -- 453
			}), -- 451
			Act("idle") -- 455
		}) -- 442
	}), -- 430
	Seq({ -- 459
		Con("need turn", function(self) -- 459
			return (self.x < -1000 and not self.faceRight) or (self.x > 1000 and self.faceRight) -- 460
		end), -- 459
		Act("turn") -- 461
	}), -- 458
	Act("walk") -- 463
}) -- 421
Store["AI_PlayerControl"] = Sel({ -- 467
	Seq({ -- 468
		Con("is dead", function(self) -- 468
			return self.entity.hp <= 0 -- 468
		end), -- 468
		Accept() -- 469
	}), -- 467
	Seq({ -- 472
		Seq({ -- 473
			Con("move key down", function(self) -- 473
				return not (self.data.keyLeft and self.data.keyRight) and ((self.data.keyLeft and self.faceRight) or (self.data.keyRight and not self.faceRight)) -- 478
			end), -- 473
			Act("turn") -- 479
		}), -- 472
		Reject() -- 481
	}), -- 471
	Seq({ -- 484
		Con("evade key down", function(self) -- 484
			return self.data.keyE -- 484
		end), -- 484
		Do("evade") -- 485
	}), -- 483
	Seq({ -- 488
		Con("attack key down", function(self) -- 488
			return self.data.keyF -- 488
		end), -- 488
		Sel({ -- 490
			Do("meleeAttack"), -- 490
			Do("range") -- 491
		}) -- 489
	}), -- 487
	Sel({ -- 495
		Seq({ -- 496
			Con("is falling", function(self) -- 496
				return not self.onSurface and not self:isDoing("evade") -- 496
			end), -- 496
			Act("fallOff") -- 497
		}), -- 495
		Seq({ -- 500
			Con("jump key down", function(self) -- 500
				return self.data.keyUp -- 500
			end), -- 500
			Do("jump") -- 501
		}) -- 499
	}), -- 494
	Seq({ -- 505
		Con("move key down", function(self) -- 505
			return self.data.keyLeft or self.data.keyRight -- 505
		end), -- 505
		Do("walk") -- 506
	}), -- 504
	Act("idle") -- 508
}) -- 466
local NewFighterDef -- 511
NewFighterDef = function() -- 511
	local _with_0 = Dictionary() -- 511
	_with_0.linearAcceleration = Vec2(0, -10) -- 512
	_with_0.bodyType = "Dynamic" -- 513
	_with_0.scale = 1 -- 514
	_with_0.density = 1.0 -- 515
	_with_0.friction = 1.0 -- 516
	_with_0.restitution = 0.0 -- 517
	_with_0.playable = "model:Model/patreon" -- 518
	_with_0.size = Size(64, 128) -- 519
	_with_0.tag = "Fighter" -- 520
	_with_0.sensity = 0 -- 521
	_with_0.move = 250 -- 522
	_with_0.moveSpeed = 1.0 -- 523
	_with_0.jump = 700 -- 524
	_with_0.detectDistance = 800 -- 525
	_with_0.hp = 50.0 -- 526
	_with_0.attackSpeed = 1.0 -- 527
	_with_0.attackBase = 2.5 -- 528
	_with_0.attackDelay = 20.0 / 60.0 -- 529
	_with_0.attackEffectDelay = 20.0 / 60.0 -- 530
	_with_0.attackBonus = 0.0 -- 531
	_with_0.attackFactor = 1.0 -- 532
	_with_0.attackRange = Size(350, 150) -- 533
	_with_0.attackPower = Vec2(100, 100) -- 534
	_with_0.attackTarget = "Single" -- 535
	do -- 536
		local conf -- 537
		do -- 537
			local _with_1 = TargetAllow() -- 537
			_with_1.terrainAllowed = true -- 538
			_with_1:allow("Enemy", true) -- 539
			conf = _with_1 -- 537
		end -- 537
		_with_0.targetAllow = conf:toValue() -- 540
	end -- 540
	_with_0.damageType = 0 -- 541
	_with_0.defenceType = 0 -- 542
	_with_0.bulletType = "Bullet_Arrow" -- 543
	_with_0.attackEffect = "" -- 544
	_with_0.hitEffect = "Particle/bloodp.par" -- 545
	_with_0.name = "Fighter" -- 546
	_with_0.desc = "" -- 547
	_with_0.sndAttack = "" -- 548
	_with_0.sndFallen = "" -- 549
	_with_0.decisionTree = "AI_PlayerControl" -- 550
	_with_0.usePreciseHit = true -- 551
	_with_0.actions = Array({ -- 553
		"walk", -- 553
		"turn", -- 554
		"idle", -- 555
		"cancel", -- 556
		"hit", -- 557
		"fall", -- 558
		"fallOff" -- 559
	}) -- 552
	return _with_0 -- 511
end -- 511
local NewBossDef -- 562
NewBossDef = function() -- 562
	local _with_0 = Dictionary() -- 562
	_with_0.linearAcceleration = Vec2(0, -10) -- 563
	_with_0.bodyType = "Dynamic" -- 564
	_with_0.scale = 2 -- 565
	_with_0.density = 10.0 -- 566
	_with_0.friction = 1.0 -- 567
	_with_0.restitution = 0.0 -- 568
	_with_0.playable = "model:Model/bossp.model" -- 569
	_with_0.size = Size(150, 410) -- 570
	_with_0.tag = "Boss" -- 571
	_with_0.sensity = 0 -- 572
	_with_0.move = 100 -- 573
	_with_0.moveSpeed = 1.0 -- 574
	_with_0.jump = 600 -- 575
	_with_0.detectDistance = 1500 -- 576
	_with_0.hp = 200.0 -- 577
	_with_0.attackSpeed = 1.0 -- 578
	_with_0.attackBase = 2.5 -- 579
	_with_0.attackDelay = 50.0 / 60.0 -- 580
	_with_0.attackEffectDelay = 50.0 / 60.0 -- 581
	_with_0.attackBonus = 0.0 -- 582
	_with_0.attackFactor = 1.0 -- 583
	_with_0.attackRange = Size(780, 300) -- 584
	_with_0.attackPower = Vec2(200, 200) -- 585
	_with_0.attackTarget = "Multi" -- 586
	do -- 587
		local conf -- 588
		do -- 588
			local _with_1 = TargetAllow() -- 588
			_with_1.terrainAllowed = true -- 589
			_with_1:allow("Enemy", true) -- 590
			conf = _with_1 -- 588
		end -- 588
		_with_0.targetAllow = conf:toValue() -- 591
	end -- 591
	_with_0.damageType = 0 -- 592
	_with_0.defenceType = 0 -- 593
	_with_0.bulletType = "Bullet_Arrow" -- 594
	_with_0.attackEffect = "" -- 595
	_with_0.hitEffect = "Particle/bloodp.par" -- 596
	_with_0.sndAttack = "" -- 597
	_with_0.sndFallen = "" -- 598
	_with_0.decisionTree = "AI_Boss" -- 599
	_with_0.usePreciseHit = true -- 600
	_with_0.actions = Array({ -- 602
		"walk", -- 602
		"turn", -- 603
		"meleeAttack", -- 604
		"multiArrow", -- 605
		"spearAttack", -- 606
		"idle", -- 607
		"cancel", -- 608
		"jump", -- 609
		"fall", -- 610
		"fallOff" -- 611
	}) -- 601
	return _with_0 -- 562
end -- 562
local UnitDefFuncs = { -- 615
	fighter = NewFighterDef, -- 615
	boss = NewBossDef -- 616
} -- 614
local themeColor = App.themeColor -- 619
local itemSize = 64 -- 620
local NewItemPanel -- 621
NewItemPanel = function(displayName, itemName, itemOptions, currentSet) -- 621
	local selectItems = false -- 622
	return function() -- 623
		Columns(1, false) -- 624
		TextColored(themeColor, displayName) -- 625
		NextColumn() -- 626
		if selectItems then -- 627
			Columns(#itemOptions + 1, false) -- 628
			PushID(tostring(itemName) .. "x", function() -- 629
				if Button("x", Vec2(itemSize + 10, itemSize + 10)) then -- 630
					currentSet[itemName] = nil -- 631
					selectItems = false -- 632
				end -- 630
			end) -- 629
			NextColumn() -- 633
			for i = 1, #itemOptions do -- 634
				local item = itemOptions[i] -- 635
				if ImageButton(tostring(itemName) .. tostring(i), "Model/patreon.clip|" .. tostring(item), Vec2(itemSize, itemSize)) then -- 636
					currentSet[itemName] = item -- 637
					selectItems = false -- 638
				end -- 636
				NextColumn() -- 639
			end -- 639
		else -- 641
			if not currentSet[itemName] then -- 641
				Columns(3, false) -- 642
				PushID(tostring(itemName) .. "c1", function() -- 643
					if Button("x", Vec2(itemSize + 10, itemSize + 10)) then -- 644
						selectItems = true -- 644
					end -- 644
				end) -- 643
				NextColumn() -- 645
				return Text("未装备") -- 646
			else -- 648
				Columns(3, false) -- 648
				local item = currentSet[itemName] -- 649
				if ImageButton(tostring(itemName) .. "c2", "Model/patreon.clip|" .. tostring(item), Vec2(itemSize, itemSize)) then -- 650
					selectItems = true -- 650
				end -- 650
				NextColumn() -- 651
				TextColored(Color(0xfffffa0a), itemSettings[item].name) -- 652
				TextWrapped(itemSettings[item].desc) -- 653
				NextColumn() -- 654
				TextColored(Color(0xffff0a90), "消耗: " .. tostring(itemSettings[item].cost)) -- 655
				Text("特技: " .. tostring(itemSettings[item].skillDesc)) -- 656
				return NextColumn() -- 657
			end -- 641
		end -- 627
	end -- 657
end -- 621
local size, grid = 2000, 150 -- 661
local _anon_func_4 = function(Color, Line, Vec2, _with_0, grid, size) -- 682
	local _with_1 = Line() -- 671
	_with_1.depthWrite = true -- 672
	_with_1.z = -10 -- 673
	for i = -size / grid, size / grid do -- 674
		_with_1:add({ -- 676
			Vec2(i * grid, size), -- 676
			Vec2(i * grid, -size) -- 677
		}, Color(0xff000000)) -- 675
		_with_1:add({ -- 680
			Vec2(-size, i * grid), -- 680
			Vec2(size, i * grid) -- 681
		}, Color(0xff000000)) -- 679
	end -- 682
	return _with_1 -- 671
end -- 671
local background -- 663
background = function() -- 663
	local _with_0 = DrawNode() -- 663
	_with_0.depthWrite = true -- 664
	_with_0:drawPolygon({ -- 666
		Vec2(-size, size), -- 666
		Vec2(size, size), -- 667
		Vec2(size, -size), -- 668
		Vec2(-size, -size) -- 669
	}, Color(0xff888888)) -- 665
	_with_0:addChild(_anon_func_4(Color, Line, Vec2, _with_0, grid, size)) -- 671
	return _with_0 -- 663
end -- 663
do -- 684
	local _with_0 = background() -- 684
	_with_0.z = 600 -- 685
end -- 684
do -- 686
	local _with_0 = background() -- 686
	_with_0.angleX = 45 -- 687
end -- 686
local TerrainLayer = 0 -- 691
local EnemyLayer = 1 -- 692
local PlayerLayer = 2 -- 693
local PlayerGroup = 1 -- 695
local EnemyGroup = 2 -- 696
local DesignWidth <const> = 1500 -- 698
Data:setRelation(PlayerGroup, EnemyGroup, "Enemy") -- 700
Data:setShouldContact(PlayerGroup, EnemyGroup, true) -- 701
local world -- 703
do -- 703
	local _with_0 = PlatformWorld() -- 703
	_with_0.camera.boundary = Rect(-1250, -500, 2500, 1000) -- 704
	_with_0.camera.followRatio = Vec2(0.01, 0.01) -- 705
	_with_0.camera.zoom = View.size.width / DesignWidth -- 706
	_with_0:gslot("AppSizeChanged", function() -- 707
		local zoom = View.size.width / DesignWidth -- 708
		_with_0.camera.zoom = zoom -- 709
		local _with_1 = Director.ui -- 710
		_with_1.scaleX = zoom -- 711
		_with_1.scaleY = zoom -- 711
		return _with_1 -- 710
	end) -- 707
	world = _with_0 -- 703
end -- 703
Store["world"] = world -- 712
local terrainDef -- 714
do -- 714
	local _with_0 = BodyDef() -- 714
	_with_0.type = "Static" -- 715
	_with_0:attachPolygon(Vec2(0, 0), 2500, 10, 0, 1, 1, 0) -- 716
	_with_0:attachPolygon(Vec2(0, 1000), 2500, 10, 0, 1, 1, 0) -- 717
	_with_0:attachPolygon(Vec2(1250, 500), 10, 1000, 0, 1, 1, 0) -- 718
	_with_0:attachPolygon(Vec2(-1250, 500), 10, 1000, 0, 1, 1, 0) -- 719
	terrainDef = _with_0 -- 714
end -- 714
do -- 721
	local _with_0 = Body(terrainDef, world, Vec2.zero) -- 721
	_with_0.order = TerrainLayer -- 722
	_with_0.group = Data.groupTerrain -- 723
	_with_0:addTo(world) -- 724
end -- 721
local _anon_func_5 = function(Sprite, item, offset, tostring) -- 745
	local _with_0 = Sprite("Model/patreon.clip|" .. tostring(item)) -- 744
	_with_0.position = offset -- 745
	return _with_0 -- 744
end -- 744
local updateModel -- 726
updateModel = function(model, currentSet) -- 726
	local node = model:getNodeByName("body") -- 727
	node:removeAllChildren() -- 728
	local charType = characterTypes[currentSet.type] -- 729
	local charColor = characterColors[currentSet.color] -- 730
	node:addChild(Sprite("Model/patreon.clip|character_" .. tostring(charType) .. tostring(charColor))) -- 731
	node = model:getNodeByName("lhand") -- 732
	node:removeAllChildren() -- 733
	node:addChild(Sprite("Model/patreon.clip|character_hand" .. tostring(charColor))) -- 734
	node = model:getNodeByName("rhand") -- 735
	node:removeAllChildren() -- 736
	node:addChild(Sprite("Model/patreon.clip|character_hand" .. tostring(charColor))) -- 737
	model:getNodeByName("head"):removeAllChildren() -- 738
	for _index_0 = 1, #itemSlots do -- 739
		local slot = itemSlots[_index_0] -- 739
		node = model:getNodeByName(slot) -- 740
		local item = currentSet[slot] -- 741
		if item then -- 742
			local offset = itemSettings[item].offset -- 743
			node:addChild(_anon_func_5(Sprite, item, offset, tostring)) -- 744
		end -- 742
	end -- 745
end -- 726
local NewFighter -- 747
NewFighter = function(name, currentSet) -- 747
	local assembleFighter = false -- 748
	local fighter -- 749
	do -- 749
		local _with_0 = Model("Model/patreon.model") -- 749
		local modelRect = Rect(-128, -128, 256, 256) -- 750
		_with_0.recovery = 0.2 -- 751
		_with_0.order = PlayerLayer -- 752
		_with_0.touchEnabled = true -- 753
		_with_0.swallowTouches = true -- 754
		_with_0:slot("TapFilter", function(touch) -- 755
			if not modelRect:containsPoint(touch.location) then -- 756
				touch.enabled = false -- 757
			end -- 756
		end) -- 755
		_with_0:slot("Tapped", function() -- 758
			if not fighter:getChildByTag("select") then -- 759
				local selectFrame -- 760
				local _with_1 = Sprite("Model/patreon.clip|ui_select") -- 760
				_with_1:addTo(fighter, 0, "select") -- 761
				_with_1:runAction(Scale(0.3, 0, 1.8, Ease.OutBack)) -- 762
				assembleFighter = true -- 763
				selectFrame = _with_1 -- 760
			end -- 759
		end) -- 758
		_with_0:play("idle", true) -- 764
		fighter = _with_0 -- 749
	end -- 749
	updateModel(fighter, currentSet) -- 765
	local HeadItemPanel = NewItemPanel("头部", "head", headItems, currentSet) -- 766
	local LHandItemPanel = NewItemPanel("副手", "lhand", lhandItems, currentSet) -- 767
	local RHandItemPanel = NewItemPanel("主手", "rhand", rhandItems, currentSet) -- 768
	return fighter, function() -- 769
		SetNextWindowSize(Vec2(445, 600), "FirstUseEver") -- 770
		if assembleFighter then -- 771
			assembleFighter = false -- 772
			OpenPopup("战士" .. tostring(name)) -- 773
		end -- 771
		return BeginPopupModal("战士" .. tostring(name), { -- 774
			"NoResize", -- 774
			"NoSavedSettings" -- 774
		}, function() -- 774
			HeadItemPanel() -- 775
			RHandItemPanel() -- 776
			LHandItemPanel() -- 777
			Columns(1, false) -- 778
			TextColored(themeColor, "性别") -- 779
			NextColumn() -- 780
			local _ -- 781
			_, currentSet.type = RadioButton("男", currentSet.type, 1) -- 781
			SameLine() -- 782
			_, currentSet.type = RadioButton("女", currentSet.type, 2) -- 783
			Columns(1, false) -- 784
			local cost = 0 -- 785
			for _index_0 = 1, #itemSlots do -- 786
				local slot = itemSlots[_index_0] -- 786
				local item = currentSet[slot] -- 787
				cost = cost + (item and itemSettings[item].cost or 0) -- 788
			end -- 788
			TextColored(themeColor, "累计消耗资源：" .. tostring(cost)) -- 789
			NextColumn() -- 790
			Columns(2, false) -- 791
			if Button("进行训练！", Vec2(200, 80)) then -- 792
				updateModel(fighter, currentSet) -- 793
				CloseCurrentPopup() -- 794
				do -- 795
					local _with_0 = fighter:getChildByTag("select") -- 795
					_with_0:removeFromParent() -- 796
				end -- 795
				emit("ShowSetting", false) -- 797
				local charSet = 1 -- 798
				for i = 1, #characters do -- 799
					if currentSet == characters[i] then -- 800
						charSet = i -- 801
						break -- 802
					end -- 800
				end -- 802
				Entity({ -- 804
					unitDef = "fighter", -- 804
					charSet = charSet, -- 805
					order = PlayerLayer, -- 806
					position = Vec2(-400, 400), -- 807
					group = PlayerGroup, -- 808
					faceRight = true, -- 809
					player = true, -- 810
					decisionTree = "AI_PlayerControl" -- 811
				}) -- 803
				Entity({ -- 813
					unitDef = "boss", -- 813
					order = EnemyLayer, -- 814
					position = Vec2(400, 400), -- 815
					group = EnemyGroup, -- 816
					faceRight = false, -- 817
					boss = true -- 818
				}) -- 812
				emit("ShowTraining", true) -- 819
			end -- 792
			NextColumn() -- 820
			if Button("装备完成！", Vec2(200, 80)) then -- 821
				updateModel(fighter, currentSet) -- 822
				CloseCurrentPopup() -- 823
				local _with_0 = fighter:getChildByTag("select") -- 824
				_with_0:runAction(Sequence(Spawn(Scale(0.3, 1.8, 2.5), Opacity(0.3, 1, 0)), Event("End"))) -- 825
				_with_0:slot("End", function() -- 829
					return _with_0:removeFromParent() -- 829
				end) -- 829
			end -- 821
			return NextColumn() -- 830
		end) -- 830
	end -- 830
end -- 747
local fighterFigures = { } -- 832
local fighterPanels = { } -- 833
for i = 1, #characters do -- 834
	local fighter, fighterPanel = NewFighter(string.rep("I", i), characters[i]) -- 835
	table.insert(fighterFigures, fighter) -- 836
	table.insert(fighterPanels, fighterPanel) -- 837
end -- 837
local playerGroup = Group({ -- 839
	"player", -- 839
	"unit" -- 839
}) -- 839
local updatePlayerControl -- 840
updatePlayerControl = function(key, flag) -- 840
	return playerGroup:each(function(self) -- 840
		self.unit.data[key] = flag -- 840
	end) -- 840
end -- 840
local uiScale = App.devicePixelRatio -- 842
Director.ui:addChild((function() -- 844
	local _with_0 = AlignNode({ -- 844
		isRoot = true -- 844
	}) -- 844
	_with_0:schedule(function() -- 845
		local width, height -- 846
		do -- 846
			local _obj_0 = App.visualSize -- 846
			width, height = _obj_0.width, _obj_0.height -- 846
		end -- 846
		SetNextWindowPos(Vec2(10, 10), "FirstUseEver") -- 847
		SetNextWindowSize(Vec2(350, 160), "FirstUseEver") -- 848
		return Begin("AI军团", { -- 849
			"NoResize", -- 849
			"NoSavedSettings" -- 849
		}, function() -- 849
			local isPC -- 850
			do -- 850
				local _exp_0 = App.platform -- 850
				if "macOS" == _exp_0 or "Windows" == _exp_0 or "Linux" == _exp_0 then -- 851
					isPC = true -- 851
				else -- 852
					isPC = false -- 852
				end -- 852
			end -- 852
			return TextWrapped("点击你的学员部队配备装备，并亲自进行战斗方法的训练，最后带领部队挑战敌人。\n学员战斗AI通过玩家操作自动学习生成。" .. tostring(isPC and '训练操作按键：向左A，向右D，闪避E，攻击J，跳跃K' or '')) -- 853
		end) -- 853
	end) -- 845
	_with_0:addChild((function() -- 854
		local _with_1 = AlignNode() -- 854
		_with_1.size = Size(0, 0) -- 855
		_with_1.hAlign = "Center" -- 856
		_with_1.vAlign = "Center" -- 857
		_with_1.alignOffset = Vec2(0, 32) -- 858
		_with_1.visible = false -- 859
		_with_1:gslot("ShowTraining", function(show) -- 860
			_with_1.visible = show -- 861
			if show then -- 862
				return _with_1:addChild((function() -- 863
					local _with_2 = CircleButton({ -- 864
						text = "训练\n结束！", -- 864
						y = -300, -- 865
						radius = 80, -- 866
						fontName = "sarasa-mono-sc-regular", -- 867
						fontSize = 48 -- 868
					}) -- 863
					_with_2:slot("Tapped", function() -- 870
						emit("ShowTraining", false) -- 871
						Group({ -- 872
							"player" -- 872
						}):each(function(e) -- 872
							if e.charSet then -- 873
								emit("TrainAI", e.charSet) -- 874
								return e.unit:removeFromParent() -- 875
							end -- 873
						end) -- 872
						Group({ -- 876
							"boss" -- 876
						}):each(function(e) -- 876
							return e.unit:removeFromParent() -- 877
						end) -- 876
						return emit("ShowSetting", true) -- 878
					end) -- 870
					return _with_2 -- 863
				end)()) -- 878
			else -- 880
				return _with_1:removeAllChildren() -- 880
			end -- 862
		end) -- 860
		_with_1:gslot("ShowFight", function(show) -- 881
			_with_1.visible = show -- 882
			if show then -- 883
				return _with_1:addChild((function() -- 884
					local _with_2 = CircleButton({ -- 885
						text = "离开\n战斗", -- 885
						y = -300, -- 886
						radius = 80, -- 887
						fontName = "sarasa-mono-sc-regular", -- 888
						fontSize = 48 -- 889
					}) -- 884
					_with_2:slot("Tapped", function() -- 891
						Group({ -- 892
							"unitDef" -- 892
						}):each(function(e) -- 892
							local _obj_0 = e.unit -- 893
							if _obj_0 ~= nil then -- 893
								return _obj_0:removeFromParent() -- 893
							end -- 893
							return nil -- 893
						end) -- 892
						emit("ShowSetting", true) -- 894
						return thread(function() -- 895
							return emit("ShowFight", false) -- 895
						end) -- 895
					end) -- 891
					return _with_2 -- 884
				end)()) -- 895
			else -- 897
				return _with_1:removeAllChildren() -- 897
			end -- 883
		end) -- 881
		return _with_1 -- 854
	end)()) -- 854
	_with_0:addChild((function() -- 898
		local _with_1 = AlignNode() -- 898
		_with_1.size = Size(0, 0) -- 899
		_with_1.hAlign = "Center" -- 900
		_with_1.vAlign = "Center" -- 901
		_with_1.alignOffset = Vec2(0, 32) -- 902
		_with_1:gslot("ShowSetting", function(show) -- 903
			_with_1.visible = show -- 903
		end) -- 903
		_with_1:addChild((function() -- 904
			local _with_2 = Model("Model/bossp.model") -- 904
			_with_2.x = 500 -- 905
			_with_2.y = 100 -- 906
			_with_2.fliped = true -- 907
			_with_2.speed = 0.8 -- 908
			_with_2.scaleX, _with_2.scaleY = 2, 2 -- 909
			_with_2.recovery = 0.2 -- 910
			_with_2:play("idle", true) -- 911
			return _with_2 -- 904
		end)()) -- 904
		for i = 1, #fighterFigures do -- 912
			local fighter = fighterFigures[i] -- 913
			_with_1:addChild((function() -- 914
				fighter.x = -500 + (i - 1) * 200 -- 915
				return fighter -- 914
			end)()) -- 914
		end -- 915
		_with_1:addChild((function() -- 916
			local _with_2 = CircleButton({ -- 917
				text = "开战！", -- 917
				y = -300, -- 918
				radius = 80, -- 919
				fontName = "sarasa-mono-sc-regular", -- 920
				fontSize = 48 -- 921
			}) -- 916
			local showItems -- 923
			showItems = function(show) -- 923
				for _index_0 = 1, #fighterFigures do -- 924
					local fighter = fighterFigures[_index_0] -- 924
					fighter.touchEnabled = not show -- 925
				end -- 925
				_with_2.visible = not show -- 926
			end -- 923
			_with_2:gslot("ShowFight", showItems) -- 927
			_with_2:gslot("ShowTraining", showItems) -- 928
			_with_2:slot("Tapped", function() -- 929
				if not _with_2.visible then -- 930
					return -- 930
				end -- 930
				for i = 1, #characters do -- 931
					local char = characters[i] -- 932
					Entity({ -- 934
						unitDef = "fighter", -- 934
						charSet = i, -- 935
						order = PlayerLayer, -- 936
						position = Vec2(-600 + (i - 1) * 200, 400), -- 937
						group = PlayerGroup, -- 938
						faceRight = true, -- 939
						decisionTree = "AI_Learned", -- 940
						player = true -- 941
					}) -- 933
				end -- 941
				Entity({ -- 943
					unitDef = "boss", -- 943
					order = EnemyLayer, -- 944
					position = Vec2(400, 400), -- 945
					group = EnemyGroup, -- 946
					faceRight = false, -- 947
					boss = true -- 948
				}) -- 942
				emit("ShowSetting", false) -- 949
				return emit("ShowFight", true) -- 950
			end) -- 929
			return _with_2 -- 916
		end)()) -- 916
		return _with_1 -- 898
	end)()) -- 898
	local _exp_0 = App.platform -- 951
	if "iOS" == _exp_0 or "Android" == _exp_0 then -- 952
		_with_0:addChild((function() -- 953
			local _with_1 = AlignNode() -- 953
			_with_1.hAlign = "Left" -- 954
			_with_1.vAlign = "Bottom" -- 955
			_with_1.visible = false -- 956
			_with_1:gslot("ShowTraining", function(show) -- 957
				_with_1.visible = show -- 957
			end) -- 957
			_with_1:addChild((function() -- 958
				local _with_2 = Menu() -- 958
				_with_2:addChild((function() -- 959
					local _with_3 = CircleButton({ -- 960
						text = "左", -- 960
						x = 20 * uiScale, -- 961
						y = 90 * uiScale, -- 962
						radius = 30 * uiScale, -- 963
						fontSize = math.floor(18 * uiScale) -- 964
					}) -- 959
					_with_3.anchor = Vec2.zero -- 966
					_with_3:slot("TapBegan", function() -- 967
						return updatePlayerControl("keyLeft", true) -- 967
					end) -- 967
					_with_3:slot("TapEnded", function() -- 968
						return updatePlayerControl("keyLeft", false) -- 968
					end) -- 968
					return _with_3 -- 959
				end)()) -- 959
				_with_2:addChild((function() -- 969
					local _with_3 = CircleButton({ -- 970
						text = "右", -- 970
						x = 90 * uiScale, -- 971
						y = 90 * uiScale, -- 972
						radius = 30 * uiScale, -- 973
						fontSize = math.floor(18 * uiScale) -- 974
					}) -- 969
					_with_3.anchor = Vec2.zero -- 976
					_with_3:slot("TapBegan", function() -- 977
						return updatePlayerControl("keyRight", true) -- 977
					end) -- 977
					_with_3:slot("TapEnded", function() -- 978
						return updatePlayerControl("keyRight", false) -- 978
					end) -- 978
					return _with_3 -- 969
				end)()) -- 969
				return _with_2 -- 958
			end)()) -- 958
			return _with_1 -- 953
		end)()) -- 953
		_with_0:addChild((function() -- 979
			local _with_1 = AlignNode() -- 979
			_with_1.hAlign = "Right" -- 980
			_with_1.vAlign = "Bottom" -- 981
			_with_1.visible = false -- 982
			_with_1:gslot("ShowTraining", function(show) -- 983
				_with_1.visible = show -- 983
			end) -- 983
			_with_1:addChild((function() -- 984
				local _with_2 = Menu() -- 984
				_with_2:addChild((function() -- 985
					local _with_3 = CircleButton({ -- 986
						text = "闪", -- 986
						x = -80 * uiScale, -- 987
						y = 160 * uiScale, -- 988
						radius = 30 * uiScale, -- 989
						fontSize = math.floor(18 * uiScale) -- 990
					}) -- 985
					_with_3.anchor = Vec2.zero -- 992
					_with_3:slot("TapBegan", function() -- 993
						return updatePlayerControl("keyE", true) -- 993
					end) -- 993
					_with_3:slot("TapEnded", function() -- 994
						return updatePlayerControl("keyE", false) -- 994
					end) -- 994
					return _with_3 -- 985
				end)()) -- 985
				_with_2:addChild((function() -- 995
					local _with_3 = CircleButton({ -- 996
						text = "跳", -- 996
						x = -80 * uiScale, -- 997
						y = 90 * uiScale, -- 998
						radius = 30 * uiScale, -- 999
						fontSize = math.floor(18 * uiScale) -- 1000
					}) -- 995
					_with_3.anchor = Vec2.zero -- 1002
					_with_3:slot("TapBegan", function() -- 1003
						return updatePlayerControl("keyUp", true) -- 1003
					end) -- 1003
					_with_3:slot("TapEnded", function() -- 1004
						return updatePlayerControl("keyUp", false) -- 1004
					end) -- 1004
					return _with_3 -- 995
				end)()) -- 995
				_with_2:addChild((function() -- 1005
					local _with_3 = CircleButton({ -- 1006
						text = "打", -- 1006
						x = -150 * uiScale, -- 1007
						y = 90 * uiScale, -- 1008
						radius = 30 * uiScale, -- 1009
						fontSize = math.floor(18 * uiScale) -- 1010
					}) -- 1005
					_with_3.anchor = Vec2.zero -- 1012
					_with_3:slot("TapBegan", function() -- 1013
						return updatePlayerControl("keyF", true) -- 1013
					end) -- 1013
					_with_3:slot("TapEnded", function() -- 1014
						return updatePlayerControl("keyF", false) -- 1014
					end) -- 1014
					return _with_3 -- 1005
				end)()) -- 1005
				return _with_2 -- 984
			end)()) -- 984
			return _with_1 -- 979
		end)()) -- 979
	elseif "macOS" == _exp_0 or "Windows" == _exp_0 or "Linux" == _exp_0 then -- 1015
		local _with_1 = Node() -- 1016
		_with_1:schedule(function() -- 1017
			updatePlayerControl("keyLeft", Keyboard:isKeyPressed("A")) -- 1018
			updatePlayerControl("keyRight", Keyboard:isKeyPressed("D")) -- 1019
			updatePlayerControl("keyUp", Keyboard:isKeyPressed("K")) -- 1020
			updatePlayerControl("keyF", Keyboard:isKeyPressed("J")) -- 1021
			return updatePlayerControl("keyE", Keyboard:isKeyPressed("E")) -- 1022
		end) -- 1017
	end -- 1022
	return _with_0 -- 844
end)()) -- 844
do -- 1024
	local _with_0 = Node() -- 1024
	_with_0:schedule(function() -- 1025
		local width, height -- 1026
		do -- 1026
			local _obj_0 = App.visualSize -- 1026
			width, height = _obj_0.width, _obj_0.height -- 1026
		end -- 1026
		for _index_0 = 1, #fighterPanels do -- 1027
			local panel = fighterPanels[_index_0] -- 1027
			panel() -- 1027
		end -- 1027
	end) -- 1025
end -- 1024
local rangeAttackEnd -- 1029
rangeAttackEnd = function(name, playable) -- 1029
	if name == "range" then -- 1030
		return playable.parent:stop() -- 1030
	end -- 1030
end -- 1029
UnitAction:add("range", { -- 1033
	priority = 3, -- 1033
	reaction = 10, -- 1034
	recovery = 0.1, -- 1035
	queued = true, -- 1036
	available = function(self) -- 1037
		return true -- 1037
	end, -- 1037
	create = function(self) -- 1038
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 1039
		do -- 1039
			local _obj_0 = self.entity -- 1044
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 1039
		end -- 1044
		do -- 1045
			local _with_0 = self.playable -- 1045
			_with_0.speed = attackSpeed -- 1046
			_with_0:play("range") -- 1047
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 1048
		end -- 1045
		return once(function(self) -- 1049
			local bulletDef = Store[self.unitDef.bulletType] -- 1050
			local onAttack -- 1051
			onAttack = function() -- 1051
				local _with_0 = Bullet(bulletDef, self) -- 1052
				_with_0.targetAllow = targetAllow -- 1053
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 1054
					do -- 1055
						local _with_1 = target.data -- 1055
						_with_1.hitPoint = pos -- 1056
						_with_1.hitPower = attackPower -- 1057
						_with_1.hitFromRight = bullet.velocityX < 0 -- 1058
					end -- 1055
					local entity = target.entity -- 1059
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 1060
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 1061
					entity.hp = entity.hp - damage -- 1062
					bullet.hitStop = true -- 1063
				end) -- 1054
				_with_0:addTo(self.world, self.order) -- 1064
				return _with_0 -- 1052
			end -- 1051
			sleep(0.5 * 28.0 / 30.0 / attackSpeed) -- 1065
			onAttack() -- 1066
			while true do -- 1067
				sleep() -- 1067
			end -- 1067
		end) -- 1067
	end, -- 1038
	stop = function(self) -- 1068
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 1069
	end -- 1068
}) -- 1032
local BigArrow -- 1071
do -- 1071
	local _with_0 = BulletDef() -- 1071
	_with_0.tag = "" -- 1072
	_with_0.endEffect = "" -- 1073
	_with_0.lifeTime = 5 -- 1074
	_with_0.damageRadius = 0 -- 1075
	_with_0.highSpeedFix = false -- 1076
	_with_0.gravity = Vec2(0, -10) -- 1077
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2(-100, 0), 2) -- 1078
	_with_0:setAsCircle(10) -- 1079
	_with_0:setVelocity(25, 800) -- 1080
	BigArrow = _with_0 -- 1071
end -- 1071
UnitAction:add("multiArrow", { -- 1083
	priority = 3, -- 1083
	reaction = 10, -- 1084
	recovery = 0.1, -- 1085
	queued = true, -- 1086
	available = function(self) -- 1087
		return true -- 1087
	end, -- 1087
	create = function(self) -- 1088
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 1089
		do -- 1089
			local _obj_0 = self.entity -- 1094
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 1089
		end -- 1094
		do -- 1095
			local _with_0 = self.playable -- 1095
			_with_0.speed = attackSpeed -- 1096
			_with_0:play("range") -- 1097
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 1098
		end -- 1095
		return once(function(self) -- 1099
			local onAttack -- 1100
			onAttack = function(angle, speed) -- 1100
				BigArrow:setVelocity(angle, speed) -- 1101
				local _with_0 = Bullet(BigArrow, self) -- 1102
				_with_0.targetAllow = targetAllow -- 1103
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 1104
					do -- 1105
						local _with_1 = target.data -- 1105
						_with_1.hitPoint = pos -- 1106
						_with_1.hitPower = attackPower -- 1107
						_with_1.hitFromRight = bullet.velocityX < 0 -- 1108
					end -- 1105
					local entity = target.entity -- 1109
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 1110
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 1111
					entity.hp = entity.hp - damage -- 1112
					bullet.hitStop = true -- 1113
				end) -- 1104
				_with_0:addTo(self.world, self.order) -- 1114
				return _with_0 -- 1102
			end -- 1100
			sleep(30.0 / 60.0 / attackSpeed) -- 1115
			onAttack(30, 1100) -- 1116
			onAttack(10, 1000) -- 1117
			onAttack(-10, 900) -- 1118
			onAttack(-30, 800) -- 1119
			onAttack(-50, 700) -- 1120
			while true do -- 1121
				sleep() -- 1121
			end -- 1121
		end) -- 1121
	end, -- 1088
	stop = function(self) -- 1122
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 1123
	end -- 1122
}) -- 1082
UnitAction:add("fallOff", { -- 1126
	priority = 1, -- 1126
	reaction = 1, -- 1127
	recovery = 0, -- 1128
	available = function(self) -- 1129
		return not self.onSurface -- 1129
	end, -- 1129
	create = function(self) -- 1130
		if self.velocityY <= 0 then -- 1131
			self.data.fallDown = true -- 1132
			local _with_0 = self.playable -- 1133
			_with_0.speed = 2.5 -- 1134
			_with_0:play("idle") -- 1135
		else -- 1136
			self.data.fallDown = false -- 1136
		end -- 1131
		return function(self, action) -- 1137
			if self.onSurface then -- 1138
				return true -- 1138
			end -- 1138
			if not self.data.fallDown and self.velocityY <= 0 then -- 1139
				self.data.fallDown = true -- 1140
				local _with_0 = self.playable -- 1141
				_with_0.speed = 2.5 -- 1142
				_with_0:play("idle") -- 1143
			end -- 1139
			return false -- 1144
		end -- 1144
	end -- 1130
}) -- 1125
UnitAction:add("evade", { -- 1147
	priority = 10, -- 1147
	reaction = 10, -- 1148
	recovery = 0, -- 1149
	queued = true, -- 1150
	available = function(self) -- 1151
		return true -- 1151
	end, -- 1151
	create = function(self) -- 1152
		do -- 1153
			local _with_0 = self.playable -- 1153
			_with_0.speed = 1.0 -- 1154
			_with_0.recovery = 0.0 -- 1155
			_with_0:play("bevade") -- 1156
		end -- 1153
		return once(function(self) -- 1157
			local group = self.group -- 1158
			self.group = Data.groupHide -- 1159
			local dir = self.faceRight and -1 or 1 -- 1160
			cycle(0.2, function() -- 1161
				self.velocityX = 800 * dir -- 1161
			end) -- 1161
			self.group = group -- 1162
			do -- 1163
				local _with_0 = self.playable -- 1163
				_with_0.speed = 1.0 -- 1164
				_with_0:play("idle") -- 1165
			end -- 1163
			sleep(1) -- 1166
			return true -- 1167
		end) -- 1167
	end -- 1152
}) -- 1146
local spearAttackEnd -- 1169
spearAttackEnd = function(name, playable) -- 1169
	if name == "spear" then -- 1170
		return playable.parent:stop() -- 1170
	end -- 1170
end -- 1169
UnitAction:add("spearAttack", { -- 1173
	priority = 3, -- 1173
	reaction = 10, -- 1174
	recovery = 0.1, -- 1175
	queued = true, -- 1176
	available = function(self) -- 1177
		return true -- 1177
	end, -- 1177
	create = function(self) -- 1178
		local attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor -- 1179
		do -- 1179
			local _obj_0 = self.entity -- 1183
			attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 1179
		end -- 1183
		do -- 1184
			local _with_0 = self.playable -- 1184
			_with_0.speed = attackSpeed -- 1185
			_with_0.recovery = 0.2 -- 1186
			_with_0:play("spear") -- 1187
			_with_0:slot("AnimationEnd", spearAttackEnd) -- 1188
		end -- 1184
		return once(function(self) -- 1189
			sleep(50.0 / 60.0) -- 1190
			local dir = self.faceRight and 0 or -900 -- 1191
			local origin = self.position - Vec2(0, 205) + Vec2(dir, 0) -- 1192
			size = Size(900, 40) -- 1193
			world:query(Rect(origin, size), function(body) -- 1194
				local entity = body.entity -- 1195
				if entity and Data:isEnemy(body, self) then -- 1196
					do -- 1197
						local _with_0 = body.data -- 1197
						_with_0.hitPoint = body.position -- 1198
						_with_0.hitPower = attackPower -- 1199
						_with_0.hitFromRight = not self.faceRight -- 1200
					end -- 1197
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 1201
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 1202
					entity.hp = entity.hp - damage -- 1203
				end -- 1196
				return false -- 1204
			end) -- 1194
			while true do -- 1205
				sleep() -- 1205
			end -- 1205
		end) -- 1205
	end, -- 1178
	stop = function(self) -- 1206
		return self.playable:slot("AnimationEnd"):remove(spearAttackEnd) -- 1207
	end -- 1206
}) -- 1172
local mutables = { -- 1210
	"hp", -- 1210
	"moveSpeed", -- 1211
	"move", -- 1212
	"jump", -- 1213
	"targetAllow", -- 1214
	"attackBase", -- 1215
	"attackPower", -- 1216
	"attackSpeed", -- 1217
	"damageType", -- 1218
	"attackBonus", -- 1219
	"attackFactor", -- 1220
	"attackTarget", -- 1221
	"defenceType" -- 1222
} -- 1209
do -- 1225
	local _with_0 = Observer("Add", { -- 1225
		"unitDef", -- 1225
		"position", -- 1225
		"order", -- 1225
		"group", -- 1225
		"faceRight" -- 1225
	}) -- 1225
	_with_0:watch(function(self, unitDef, position, order, group) -- 1226
		local player, faceRight, charSet, decisionTree = self.player, self.faceRight, self.charSet, self.decisionTree -- 1227
		world = Store.world -- 1228
		local func = UnitDefFuncs[unitDef] -- 1229
		local def = func() -- 1230
		for _index_0 = 1, #mutables do -- 1231
			local var = mutables[_index_0] -- 1231
			self[var] = def[var] -- 1232
		end -- 1232
		if charSet then -- 1233
			local set = characters[charSet] -- 1234
			local actions = def.actions -- 1235
			local actionSet -- 1236
			do -- 1236
				local _tbl_0 = { } -- 1236
				for _index_0 = 1, #actions do -- 1236
					local a = actions[_index_0] -- 1236
					_tbl_0[a] = true -- 1236
				end -- 1236
				actionSet = _tbl_0 -- 1236
			end -- 1236
			for _index_0 = 1, #itemSlots do -- 1237
				local slot = itemSlots[_index_0] -- 1237
				local item = set[slot] -- 1238
				if not item then -- 1239
					goto _continue_0 -- 1239
				end -- 1239
				local skill = itemSettings[item].skill -- 1240
				if skill and not actionSet[skill] then -- 1241
					actions:add(skill) -- 1242
				end -- 1241
				local attackRange = itemSettings[item].attackRange -- 1243
				if attackRange then -- 1244
					def.attackRange = attackRange -- 1244
				end -- 1244
				::_continue_0:: -- 1238
			end -- 1244
		end -- 1233
		if decisionTree then -- 1245
			def.decisionTree = decisionTree -- 1245
		end -- 1245
		local unit -- 1246
		do -- 1246
			local _with_1 = Unit(def, world, self, position) -- 1246
			_with_1.group = group -- 1247
			_with_1.order = order -- 1248
			_with_1.faceRight = faceRight -- 1249
			_with_1:addTo(world) -- 1250
			unit = _with_1 -- 1246
		end -- 1246
		if charSet then -- 1251
			updateModel(unit.playable, characters[charSet]) -- 1251
		end -- 1251
		if player then -- 1252
			world.camera.followTarget = unit -- 1253
		end -- 1252
		return false -- 1253
	end) -- 1226
end -- 1225
local _with_0 = Observer("Change", { -- 1255
	"hp", -- 1255
	"unit" -- 1255
}) -- 1255
_with_0:watch(function(self, hp, unit) -- 1256
	local boss = self.boss -- 1257
	local lastHp = self.oldValues.hp -- 1258
	if hp < lastHp then -- 1259
		if not boss and unit:isDoing("hit") then -- 1260
			unit:start("cancel") -- 1260
		end -- 1260
		if boss then -- 1261
			local _with_1 = Visual("Particle/bloodp.par") -- 1262
			_with_1.position = unit.data.hitPoint -- 1263
			_with_1:addTo(world, unit.order) -- 1264
			_with_1:autoRemove() -- 1265
			_with_1:start() -- 1266
		end -- 1261
		if hp > 0 then -- 1267
			unit:start("hit") -- 1268
		else -- 1270
			unit:start("hit") -- 1270
			unit:start("fall") -- 1271
			unit.group = Data.groupHide -- 1272
			if self.player then -- 1273
				playerGroup:each(function(p) -- 1274
					if p and p.unit and p.hp > 0 then -- 1275
						world.camera.followTarget = p.unit -- 1276
						return true -- 1277
					else -- 1278
						return false -- 1278
					end -- 1275
				end) -- 1274
			end -- 1273
		end -- 1267
	end -- 1259
	return false -- 1278
end) -- 1256
return _with_0 -- 1255
