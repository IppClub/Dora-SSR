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
local AlignNode = require("UI.Control.Basic.AlignNode") -- 7
local CircleButton = require("UI.Control.Basic.CircleButton") -- 8
local Store = Data.store -- 9
local characters = { -- 14
	{ -- 14
		body = "character_roundGreen", -- 14
		lhand = "character_handGreen", -- 15
		rhand = "character_handGreen" -- 16
	}, -- 14
	{ -- 18
		body = "character_roundRed", -- 18
		lhand = "character_handRed", -- 19
		rhand = "character_handRed" -- 20
	}, -- 18
	{ -- 22
		body = "character_roundYellow", -- 22
		lhand = "character_handYellow", -- 23
		rhand = "character_handYellow" -- 24
	} -- 22
} -- 13
local headItems = { -- 27
	"item_hat", -- 27
	"item_hatTop", -- 28
	"item_helmet", -- 29
	"item_helmetModern" -- 30
} -- 26
local lhandItems = { -- 33
	"item_shield", -- 33
	"item_shieldRound", -- 34
	"tile_heart", -- 35
	"ui_hand" -- 36
} -- 32
local rhandItems = { -- 39
	"item_bow", -- 39
	"item_sword", -- 40
	"item_rod", -- 41
	"item_spear" -- 42
} -- 38
local characterTypes = { -- 45
	"square", -- 45
	"round" -- 46
} -- 44
local characterColors = { -- 49
	"Green", -- 49
	"Red", -- 50
	"Yellow" -- 51
} -- 48
local itemSettings = { -- 54
	item_hat = { -- 55
		name = "普通帽子", -- 55
		desc = "就是很普通的帽子，增加许些防御力", -- 56
		cost = 1, -- 57
		skill = "jump", -- 58
		skillDesc = "跳跃", -- 59
		offset = Vec2(0, 30) -- 60
	}, -- 54
	item_hatTop = { -- 63
		name = "高帽子", -- 63
		desc = "就是很普通的帽子，增加许些防御力", -- 64
		cost = 1, -- 65
		skill = "evade", -- 66
		skillDesc = "闪避", -- 67
		offset = Vec2(0, 30) -- 68
	}, -- 62
	item_helmet = { -- 71
		name = "战盔", -- 71
		desc = "就是很普通的帽子，增加许些防御力", -- 72
		cost = 1, -- 73
		skill = "evade", -- 74
		skillDesc = "闪避", -- 75
		offset = Vec2(0, 0) -- 76
	}, -- 70
	item_helmetModern = { -- 79
		name = "橄榄球盔", -- 79
		desc = "就是很普通的帽子，增加许些防御力", -- 80
		cost = 1, -- 81
		skill = "", -- 82
		skillDesc = "无", -- 83
		offset = Vec2(0, 0) -- 84
	}, -- 78
	item_shield = { -- 87
		name = "方形盾", -- 87
		desc = "无", -- 88
		cost = 1, -- 89
		skill = "evade", -- 90
		skillDesc = "闪避", -- 91
		offset = Vec2(0, 0) -- 92
	}, -- 86
	item_shieldRound = { -- 95
		name = "小圆盾", -- 95
		desc = "无", -- 96
		cost = 1, -- 97
		skill = "jump", -- 98
		skillDesc = "跳跃", -- 99
		offset = Vec2(0, 0) -- 100
	}, -- 94
	tile_heart = { -- 103
		name = "爱心", -- 103
		desc = "无", -- 104
		cost = 1, -- 105
		skill = "jump", -- 106
		skillDesc = "跳跃", -- 107
		offset = Vec2(0, 0) -- 108
	}, -- 102
	ui_hand = { -- 111
		name = "手套", -- 111
		desc = "无", -- 112
		cost = 1, -- 113
		skill = "evade", -- 114
		skillDesc = "闪避", -- 115
		offset = Vec2(0, 0) -- 116
	}, -- 110
	item_bow = { -- 119
		name = "短弓", -- 119
		desc = "无", -- 120
		cost = 1, -- 121
		skill = "range", -- 122
		skillDesc = "远程攻击", -- 123
		offset = Vec2(10, 0), -- 124
		attackRange = Size(630, 150) -- 125
	}, -- 118
	item_sword = { -- 128
		name = "剑", -- 128
		desc = "无", -- 129
		cost = 1, -- 130
		skill = "meleeAttack", -- 131
		skillDesc = "近程攻击", -- 132
		offset = Vec2(15, 50), -- 133
		attackRange = Size(120, 150) -- 134
	}, -- 127
	item_rod = { -- 137
		name = "法杖", -- 137
		desc = "无", -- 138
		cost = 1, -- 139
		skill = "meleeAttack", -- 140
		skillDesc = "近程攻击", -- 141
		offset = Vec2(15, 50), -- 142
		attackRange = Size(200, 150) -- 143
	}, -- 136
	item_spear = { -- 146
		name = "长矛", -- 146
		desc = "无", -- 147
		cost = 1, -- 148
		skill = "meleeAttack", -- 149
		skillDesc = "近程攻击", -- 150
		offset = Vec2(15, 50), -- 151
		attackRange = Size(200, 150) -- 152
	} -- 145
} -- 53
local itemSlots = { -- 155
	"head", -- 155
	"lhand", -- 156
	"rhand" -- 157
} -- 154
characters = { -- 160
	{ -- 160
		head = nil, -- 160
		lhand = nil, -- 161
		rhand = nil, -- 162
		type = 1, -- 163
		color = 1, -- 164
		learnedAI = function() -- 165
			return "unknown" -- 165
		end -- 165
	}, -- 160
	{ -- 167
		head = nil, -- 167
		lhand = nil, -- 168
		rhand = nil, -- 169
		type = 1, -- 170
		color = 2, -- 171
		learnedAI = function() -- 172
			return "unknown" -- 172
		end -- 172
	}, -- 167
	{ -- 174
		head = nil, -- 174
		lhand = nil, -- 175
		rhand = nil, -- 176
		type = 1, -- 177
		color = 3, -- 178
		learnedAI = function() -- 179
			return "unknown" -- 179
		end -- 179
	} -- 174
} -- 159
local bossGroup = Group({ -- 181
	"boss" -- 181
}) -- 181
local lastAction = "idle" -- 183
local lastActionFrame = App.frame -- 184
local data = { } -- 185
local row = nil -- 186
local _anon_func_0 = function(enemy) -- 228
	local _obj_0 = enemy.currentAction -- 228
	if _obj_0 ~= nil then -- 228
		return _obj_0.name -- 228
	end -- 228
	return nil -- 228
end -- 228
local Do -- 187
Do = function(name) -- 187
	return Seq({ -- 188
		Con("Collect data", function(self) -- 188
			if self:isDoing(name) then -- 189
				row = nil -- 190
				return true -- 191
			end -- 189
			if not (AI:getNearestUnit("Enemy") ~= nil) then -- 193
				row = nil -- 194
				return true -- 195
			end -- 193
			local attack_ready -- 197
			do -- 197
				local attackUnits = AI:getUnitsInAttackRange() -- 198
				local ready = false -- 199
				for _index_0 = 1, #attackUnits do -- 200
					local unit = attackUnits[_index_0] -- 200
					if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 201
						ready = true -- 203
						break -- 204
					end -- 201
				end -- 204
				attack_ready = ready -- 205
			end -- 205
			local not_facing_enemy -- 207
			do -- 207
				local enemy = AI:getNearestUnit("Enemy") -- 208
				if enemy then -- 209
					not_facing_enemy = (self.x > enemy.x) == self.faceRight -- 210
				else -- 212
					not_facing_enemy = false -- 212
				end -- 209
			end -- 212
			local enemy_in_attack_range -- 214
			do -- 214
				local enemy = AI:getNearestUnit("Enemy") -- 215
				local attackUnits = AI:getUnitsInAttackRange() -- 216
				enemy_in_attack_range = attackUnits and attackUnits:contains(enemy) or false -- 217
			end -- 217
			local nearest_enemy_distance -- 219
			do -- 219
				local enemy = AI:getNearestUnit("Enemy") -- 220
				if (enemy ~= nil) then -- 221
					nearest_enemy_distance = math.abs(enemy.x - self.x) -- 222
				else -- 224
					nearest_enemy_distance = 999999 -- 224
				end -- 221
			end -- 224
			local enemy_hero_action -- 226
			do -- 226
				local enemy = AI:getNearestUnit("Enemy") -- 227
				enemy_hero_action = _anon_func_0(enemy) or "unknown" -- 228
			end -- 228
			row = { -- 231
				not_facing_enemy = not_facing_enemy, -- 231
				enemy_in_attack_range = enemy_in_attack_range, -- 232
				attack_ready = attack_ready, -- 233
				enemy_hero_action = enemy_hero_action, -- 234
				nearest_enemy_distance = nearest_enemy_distance, -- 235
				action = name -- 236
			} -- 230
			return true -- 238
		end), -- 188
		Sel({ -- 240
			Con("is doing", function(self) -- 240
				return self:isDoing(name) -- 240
			end), -- 240
			Seq({ -- 242
				Act(name), -- 242
				Con("action succeeded", function(self) -- 243
					lastAction = name -- 244
					lastActionFrame = App.frame -- 245
					return true -- 246
				end) -- 243
			}) -- 241
		}), -- 239
		Con("Save data", function(self) -- 249
			if row == nil then -- 250
				return true -- 250
			end -- 250
			data[#data + 1] = row -- 251
			return true -- 252
		end) -- 249
	}) -- 253
end -- 187
local rowNames = { -- 256
	"not_facing_enemy", -- 256
	"enemy_in_attack_range", -- 257
	"attack_ready", -- 259
	"enemy_hero_action", -- 260
	"nearest_enemy_distance", -- 261
	"action" -- 263
} -- 255
local rowTypes = { -- 267
	'C', -- 267
	'C', -- 267
	'C', -- 268
	'C', -- 268
	'N', -- 268
	'C' -- 269
} -- 266
local _anon_func_1 = function(_with_0, name, tostring, op, value) -- 287
	if name ~= "" then -- 287
		return "if " .. tostring(name) .. " " .. tostring(op) .. " " .. tostring(op == '==' and "\"" .. tostring(value) .. "\"" or value) -- 288
	else -- 290
		return tostring(op) .. " \"" .. tostring(value) .. "\"" -- 290
	end -- 287
end -- 287
local _anon_func_2 = function(_with_0, load, luaCodes) -- 298
	local _obj_0 = load(luaCodes) -- 298
	if _obj_0 ~= nil then -- 298
		return _obj_0() -- 298
	end -- 298
	return nil -- 298
end -- 298
do -- 272
	local _with_0 = Node() -- 272
	_with_0:gslot("TrainAI", function(charSet) -- 273
		local csvData -- 274
		do -- 274
			local _accum_0 = { } -- 274
			local _len_0 = 1 -- 274
			for _index_0 = 1, #data do -- 274
				local row = data[_index_0] -- 274
				local rd -- 275
				do -- 275
					local _accum_1 = { } -- 275
					local _len_1 = 1 -- 275
					for _index_1 = 1, #rowNames do -- 275
						local name = rowNames[_index_1] -- 275
						local val -- 276
						if (row[name] ~= nil) then -- 276
							val = row[name] -- 276
						else -- 276
							val = "N" -- 276
						end -- 276
						if "boolean" == type(val) then -- 277
							if val then -- 278
								val = "T" -- 278
							else -- 278
								val = "F" -- 278
							end -- 278
						end -- 277
						_accum_1[_len_1] = tostring(val) -- 279
						_len_1 = _len_1 + 1 -- 279
					end -- 279
					rd = _accum_1 -- 275
				end -- 279
				_accum_0[_len_0] = table.concat(rd, ",") -- 280
				_len_0 = _len_0 + 1 -- 280
			end -- 280
			csvData = _accum_0 -- 274
		end -- 280
		local names = tostring(table.concat(rowNames, ',')) .. "\n" -- 281
		local dataStr = tostring(names) .. tostring(table.concat(rowTypes, ',')) .. "\n" .. tostring(table.concat(csvData, '\n')) -- 282
		data = { } -- 283
		return thread(function() -- 284
			local lines = { -- 285
				"(_ENV) ->" -- 285
			} -- 285
			local accuracy = ML.BuildDecisionTreeAsync(dataStr, 0, function(depth, name, op, value) -- 286
				local line = string.rep("\t", depth + 1) .. _anon_func_1(_with_0, name, tostring, op, value) -- 287
				lines[#lines + 1] = line -- 291
			end) -- 286
			local codes = table.concat(lines, "\n") -- 292
			print("learning accuracy: " .. tostring(accuracy)) -- 293
			print(codes) -- 294
			local yue = require("yue") -- 296
			local luaCodes = yue.to_lua(codes, { -- 297
				reserve_line_number = false -- 297
			}) -- 297
			local learnedAI = _anon_func_2(_with_0, load, luaCodes) or function() -- 298
				return "unknown" -- 298
			end -- 298
			characters[charSet].learnedAI = learnedAI -- 299
			return emit("LearnedAI", learnedAI) -- 300
		end) -- 300
	end) -- 273
end -- 272
local _anon_func_3 = function(enemy) -- 356
	local _obj_0 = enemy.currentAction -- 356
	if _obj_0 ~= nil then -- 356
		return _obj_0.name -- 356
	end -- 356
	return nil -- 356
end -- 356
Store["AI_Learned"] = Sel({ -- 303
	Seq({ -- 304
		Con("is dead", function(self) -- 304
			return self.entity.hp <= 0 -- 304
		end), -- 304
		Accept() -- 305
	}), -- 303
	Seq({ -- 308
		Con("is falling", function(self) -- 308
			return not self.onSurface -- 308
		end), -- 308
		Act("fallOff") -- 309
	}), -- 307
	Seq({ -- 312
		Con("run learned AI", function(self) -- 312
			local _obj_0 = self.data -- 313
			_obj_0.lastActionTime = _obj_0.lastActionTime or 0.0 -- 313
			if not (AI:getNearestUnit("Enemy") ~= nil) then -- 315
				return false -- 315
			end -- 315
			if App.totalTime - self.data.lastActionTime < 0.1 then -- 317
				return false -- 318
			else -- 320
				self.data.lastActionTime = App.totalTime -- 320
			end -- 317
			local attack_ready -- 322
			do -- 322
				local attackUnits = AI:getUnitsInAttackRange() -- 323
				local ready = "F" -- 324
				for _index_0 = 1, #attackUnits do -- 325
					local unit = attackUnits[_index_0] -- 325
					if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 326
						ready = "T" -- 328
						break -- 329
					end -- 326
				end -- 329
				attack_ready = ready -- 330
			end -- 330
			local not_facing_enemy -- 332
			do -- 332
				local enemy = AI:getNearestUnit("Enemy") -- 333
				if enemy then -- 334
					if (self.x > enemy.x) == self.faceRight then -- 335
						not_facing_enemy = "T" -- 336
					else -- 338
						not_facing_enemy = "F" -- 338
					end -- 335
				else -- 340
					not_facing_enemy = "F" -- 340
				end -- 334
			end -- 340
			local enemy_in_attack_range -- 342
			do -- 342
				local enemy = AI:getNearestUnit("Enemy") -- 343
				local attackUnits = AI:getUnitsInAttackRange() -- 344
				enemy_in_attack_range = (attackUnits and attackUnits:contains(enemy)) and "T" or "F" -- 345
			end -- 345
			local nearest_enemy_distance -- 347
			do -- 347
				local enemy = AI:getNearestUnit("Enemy") -- 348
				if (enemy ~= nil) then -- 349
					nearest_enemy_distance = math.abs(enemy.x - self.x) -- 350
				else -- 352
					nearest_enemy_distance = 999999 -- 352
				end -- 349
			end -- 352
			local enemy_hero_action -- 354
			do -- 354
				local enemy = AI:getNearestUnit("Enemy") -- 355
				enemy_hero_action = _anon_func_3(enemy) or "unknown" -- 356
			end -- 356
			self.entity.learnedAction = characters[self.entity.charSet].learnedAI({ -- 359
				not_facing_enemy = not_facing_enemy, -- 359
				enemy_in_attack_range = enemy_in_attack_range, -- 360
				attack_ready = attack_ready, -- 361
				enemy_hero_action = enemy_hero_action, -- 362
				nearest_enemy_distance = nearest_enemy_distance -- 363
			}) or "unknown" -- 358
			return true -- 365
		end), -- 312
		Sel({ -- 367
			Con("is doing", function(self) -- 367
				return self:isDoing(self.entity.learnedAction) -- 367
			end), -- 367
			Seq({ -- 369
				Act(function(self) -- 369
					return self.entity.learnedAction -- 369
				end), -- 369
				Con("Succeeded prediction", function(self) -- 370
					emit("Prediction", true) -- 371
					return true -- 372
				end) -- 370
			}), -- 368
			Con("Failed prediction", function(self) -- 374
				emit("Prediction", false) -- 375
				return false -- 376
			end) -- 374
		}) -- 366
	}), -- 311
	Seq({ -- 380
		Con("not facing enemy", function(self) -- 380
			return bossGroup:each(function(boss) -- 380
				local unit = boss.unit -- 381
				if Data:isEnemy(unit, self) then -- 382
					if (self.x > unit.x) == self.faceRight then -- 383
						return true -- 384
					end -- 383
				end -- 382
			end) -- 384
		end), -- 380
		Act("turn") -- 385
	}), -- 379
	Seq({ -- 388
		Con("need turn", function(self) -- 388
			return (self.x < -1000 and not self.faceRight) or (self.x > 1000 and self.faceRight) -- 389
		end), -- 388
		Act("turn") -- 390
	}), -- 387
	Sel({ -- 393
		Seq({ -- 394
			Con("take a break", function(self) -- 394
				return App.rand % 60 == 0 -- 394
			end), -- 394
			Act("idle") -- 395
		}), -- 393
		Act("walk") -- 397
	}) -- 392
}) -- 302
do -- 401
	local _with_0 = BulletDef() -- 401
	_with_0.tag = "" -- 402
	_with_0.endEffect = "" -- 403
	_with_0.lifeTime = 5 -- 404
	_with_0.damageRadius = 0 -- 405
	_with_0.highSpeedFix = false -- 406
	_with_0.gravity = Vec2(0, -10) -- 407
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2(0, 0)) -- 408
	_with_0:setAsCircle(10) -- 409
	_with_0:setVelocity(25, 800) -- 410
	Store["Bullet_Arrow"] = _with_0 -- 401
end -- 401
Store["AI_Boss"] = Sel({ -- 413
	Seq({ -- 414
		Con("is dead", function(self) -- 414
			return self.entity.hp <= 0 -- 414
		end), -- 414
		Accept() -- 415
	}), -- 413
	Seq({ -- 418
		Con("is falling", function(self) -- 418
			return not self.onSurface -- 418
		end), -- 418
		Act("fallOff") -- 419
	}), -- 417
	Seq({ -- 422
		Con("is not attacking", function(self) -- 422
			return not self:isDoing("meleeAttack") and not self:isDoing("multiArrow") and not self:isDoing("spearAttack") -- 425
		end), -- 422
		Con("need attack", function(self) -- 426
			local attackUnits = AI:getUnitsInAttackRange() -- 427
			for _index_0 = 1, #attackUnits do -- 428
				local unit = attackUnits[_index_0] -- 428
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 429
					return true -- 431
				end -- 429
			end -- 431
			return false -- 432
		end), -- 426
		Sel({ -- 434
			Seq({ -- 435
				Con("melee attack", function(self) -- 435
					return App.rand % 250 == 0 -- 435
				end), -- 435
				Act("meleeAttack") -- 436
			}), -- 434
			Seq({ -- 439
				Con("range attack", function(self) -- 439
					return App.rand % 250 == 0 -- 439
				end), -- 439
				Act("multiArrow") -- 440
			}), -- 438
			Seq({ -- 443
				Con("spear attack", function(self) -- 443
					return App.rand % 250 == 0 -- 443
				end), -- 443
				Act("spearAttack") -- 444
			}), -- 442
			Act("idle") -- 446
		}) -- 433
	}), -- 421
	Seq({ -- 450
		Con("need turn", function(self) -- 450
			return (self.x < -1000 and not self.faceRight) or (self.x > 1000 and self.faceRight) -- 451
		end), -- 450
		Act("turn") -- 452
	}), -- 449
	Act("walk") -- 454
}) -- 412
Store["AI_PlayerControl"] = Sel({ -- 458
	Seq({ -- 459
		Con("is dead", function(self) -- 459
			return self.entity.hp <= 0 -- 459
		end), -- 459
		Accept() -- 460
	}), -- 458
	Seq({ -- 463
		Seq({ -- 464
			Con("move key down", function(self) -- 464
				return not (self.data.keyLeft and self.data.keyRight) and ((self.data.keyLeft and self.faceRight) or (self.data.keyRight and not self.faceRight)) -- 469
			end), -- 464
			Act("turn") -- 470
		}), -- 463
		Reject() -- 472
	}), -- 462
	Seq({ -- 475
		Con("evade key down", function(self) -- 475
			return self.data.keyE -- 475
		end), -- 475
		Do("evade") -- 476
	}), -- 474
	Seq({ -- 479
		Con("attack key down", function(self) -- 479
			return self.data.keyF -- 479
		end), -- 479
		Sel({ -- 481
			Do("meleeAttack"), -- 481
			Do("range") -- 482
		}) -- 480
	}), -- 478
	Sel({ -- 486
		Seq({ -- 487
			Con("is falling", function(self) -- 487
				return not self.onSurface and not self:isDoing("evade") -- 487
			end), -- 487
			Act("fallOff") -- 488
		}), -- 486
		Seq({ -- 491
			Con("jump key down", function(self) -- 491
				return self.data.keyUp -- 491
			end), -- 491
			Do("jump") -- 492
		}) -- 490
	}), -- 485
	Seq({ -- 496
		Con("move key down", function(self) -- 496
			return self.data.keyLeft or self.data.keyRight -- 496
		end), -- 496
		Do("walk") -- 497
	}), -- 495
	Act("idle") -- 499
}) -- 457
local NewFighterDef -- 502
NewFighterDef = function() -- 502
	local _with_0 = Dictionary() -- 502
	_with_0.linearAcceleration = Vec2(0, -10) -- 503
	_with_0.bodyType = "Dynamic" -- 504
	_with_0.scale = 1 -- 505
	_with_0.density = 1.0 -- 506
	_with_0.friction = 1.0 -- 507
	_with_0.restitution = 0.0 -- 508
	_with_0.playable = "model:Model/patreon" -- 509
	_with_0.size = Size(64, 128) -- 510
	_with_0.tag = "Fighter" -- 511
	_with_0.sensity = 0 -- 512
	_with_0.move = 250 -- 513
	_with_0.moveSpeed = 1.0 -- 514
	_with_0.jump = 700 -- 515
	_with_0.detectDistance = 800 -- 516
	_with_0.hp = 50.0 -- 517
	_with_0.attackSpeed = 1.0 -- 518
	_with_0.attackBase = 2.5 -- 519
	_with_0.attackDelay = 20.0 / 60.0 -- 520
	_with_0.attackEffectDelay = 20.0 / 60.0 -- 521
	_with_0.attackBonus = 0.0 -- 522
	_with_0.attackFactor = 1.0 -- 523
	_with_0.attackRange = Size(350, 150) -- 524
	_with_0.attackPower = Vec2(100, 100) -- 525
	_with_0.attackTarget = "Single" -- 526
	do -- 527
		local conf -- 528
		do -- 528
			local _with_1 = TargetAllow() -- 528
			_with_1.terrainAllowed = true -- 529
			_with_1:allow("Enemy", true) -- 530
			conf = _with_1 -- 528
		end -- 528
		_with_0.targetAllow = conf:toValue() -- 531
	end -- 531
	_with_0.damageType = 0 -- 532
	_with_0.defenceType = 0 -- 533
	_with_0.bulletType = "Bullet_Arrow" -- 534
	_with_0.attackEffect = "" -- 535
	_with_0.hitEffect = "Particle/bloodp.par" -- 536
	_with_0.name = "Fighter" -- 537
	_with_0.desc = "" -- 538
	_with_0.sndAttack = "" -- 539
	_with_0.sndFallen = "" -- 540
	_with_0.decisionTree = "AI_PlayerControl" -- 541
	_with_0.usePreciseHit = true -- 542
	_with_0.actions = Array({ -- 544
		"walk", -- 544
		"turn", -- 545
		"idle", -- 546
		"cancel", -- 547
		"hit", -- 548
		"fall", -- 549
		"fallOff" -- 550
	}) -- 543
	return _with_0 -- 502
end -- 502
local NewBossDef -- 553
NewBossDef = function() -- 553
	local _with_0 = Dictionary() -- 553
	_with_0.linearAcceleration = Vec2(0, -10) -- 554
	_with_0.bodyType = "Dynamic" -- 555
	_with_0.scale = 2 -- 556
	_with_0.density = 10.0 -- 557
	_with_0.friction = 1.0 -- 558
	_with_0.restitution = 0.0 -- 559
	_with_0.playable = "model:Model/bossp.model" -- 560
	_with_0.size = Size(150, 410) -- 561
	_with_0.tag = "Boss" -- 562
	_with_0.sensity = 0 -- 563
	_with_0.move = 100 -- 564
	_with_0.moveSpeed = 1.0 -- 565
	_with_0.jump = 600 -- 566
	_with_0.detectDistance = 1500 -- 567
	_with_0.hp = 200.0 -- 568
	_with_0.attackSpeed = 1.0 -- 569
	_with_0.attackBase = 2.5 -- 570
	_with_0.attackDelay = 50.0 / 60.0 -- 571
	_with_0.attackEffectDelay = 50.0 / 60.0 -- 572
	_with_0.attackBonus = 0.0 -- 573
	_with_0.attackFactor = 1.0 -- 574
	_with_0.attackRange = Size(780, 300) -- 575
	_with_0.attackPower = Vec2(200, 200) -- 576
	_with_0.attackTarget = "Multi" -- 577
	do -- 578
		local conf -- 579
		do -- 579
			local _with_1 = TargetAllow() -- 579
			_with_1.terrainAllowed = true -- 580
			_with_1:allow("Enemy", true) -- 581
			conf = _with_1 -- 579
		end -- 579
		_with_0.targetAllow = conf:toValue() -- 582
	end -- 582
	_with_0.damageType = 0 -- 583
	_with_0.defenceType = 0 -- 584
	_with_0.bulletType = "Bullet_Arrow" -- 585
	_with_0.attackEffect = "" -- 586
	_with_0.hitEffect = "Particle/bloodp.par" -- 587
	_with_0.sndAttack = "" -- 588
	_with_0.sndFallen = "" -- 589
	_with_0.decisionTree = "AI_Boss" -- 590
	_with_0.usePreciseHit = true -- 591
	_with_0.actions = Array({ -- 593
		"walk", -- 593
		"turn", -- 594
		"meleeAttack", -- 595
		"multiArrow", -- 596
		"spearAttack", -- 597
		"idle", -- 598
		"cancel", -- 599
		"jump", -- 600
		"fall", -- 601
		"fallOff" -- 602
	}) -- 592
	return _with_0 -- 553
end -- 553
local UnitDefFuncs = { -- 606
	fighter = NewFighterDef, -- 606
	boss = NewBossDef -- 607
} -- 605
local themeColor = App.themeColor -- 610
local itemSize = 64 -- 611
local NewItemPanel -- 612
NewItemPanel = function(displayName, itemName, itemOptions, currentSet) -- 612
	local selectItems = false -- 613
	return function() -- 614
		Columns(1, false) -- 615
		TextColored(themeColor, displayName) -- 616
		NextColumn() -- 617
		if selectItems then -- 618
			Columns(#itemOptions + 1, false) -- 619
			PushID(tostring(itemName) .. "x", function() -- 620
				if Button("x", Vec2(itemSize + 10, itemSize + 10)) then -- 621
					currentSet[itemName] = nil -- 622
					selectItems = false -- 623
				end -- 621
			end) -- 620
			NextColumn() -- 624
			for i = 1, #itemOptions do -- 625
				local item = itemOptions[i] -- 626
				if ImageButton(tostring(itemName) .. tostring(i), "Model/patreon.clip|" .. tostring(item), Vec2(itemSize, itemSize)) then -- 627
					currentSet[itemName] = item -- 628
					selectItems = false -- 629
				end -- 627
				NextColumn() -- 630
			end -- 630
		else -- 632
			if not currentSet[itemName] then -- 632
				Columns(3, false) -- 633
				PushID(tostring(itemName) .. "c1", function() -- 634
					if Button("x", Vec2(itemSize + 10, itemSize + 10)) then -- 635
						selectItems = true -- 635
					end -- 635
				end) -- 634
				NextColumn() -- 636
				return Text("未装备") -- 637
			else -- 639
				Columns(3, false) -- 639
				local item = currentSet[itemName] -- 640
				if ImageButton(tostring(itemName) .. "c2", "Model/patreon.clip|" .. tostring(item), Vec2(itemSize, itemSize)) then -- 641
					selectItems = true -- 641
				end -- 641
				NextColumn() -- 642
				TextColored(Color(0xfffffa0a), itemSettings[item].name) -- 643
				TextWrapped(itemSettings[item].desc) -- 644
				NextColumn() -- 645
				TextColored(Color(0xffff0a90), "消耗: " .. tostring(itemSettings[item].cost)) -- 646
				Text("特技: " .. tostring(itemSettings[item].skillDesc)) -- 647
				return NextColumn() -- 648
			end -- 632
		end -- 618
	end -- 648
end -- 612
local size, grid = 2000, 150 -- 652
local _anon_func_4 = function(_with_0, Line, size, grid, Vec2, Color) -- 673
	local _with_1 = Line() -- 662
	_with_1.depthWrite = true -- 663
	_with_1.z = -10 -- 664
	for i = -size / grid, size / grid do -- 665
		_with_1:add({ -- 667
			Vec2(i * grid, size), -- 667
			Vec2(i * grid, -size) -- 668
		}, Color(0xff000000)) -- 666
		_with_1:add({ -- 671
			Vec2(-size, i * grid), -- 671
			Vec2(size, i * grid) -- 672
		}, Color(0xff000000)) -- 670
	end -- 673
	return _with_1 -- 662
end -- 662
local background -- 654
background = function() -- 654
	local _with_0 = DrawNode() -- 654
	_with_0.depthWrite = true -- 655
	_with_0:drawPolygon({ -- 657
		Vec2(-size, size), -- 657
		Vec2(size, size), -- 658
		Vec2(size, -size), -- 659
		Vec2(-size, -size) -- 660
	}, Color(0xff888888)) -- 656
	_with_0:addChild(_anon_func_4(_with_0, Line, size, grid, Vec2, Color)) -- 662
	return _with_0 -- 654
end -- 654
do -- 675
	local _with_0 = background() -- 675
	_with_0.z = 600 -- 676
end -- 675
do -- 677
	local _with_0 = background() -- 677
	_with_0.angleX = 45 -- 678
end -- 677
local TerrainLayer = 0 -- 682
local EnemyLayer = 1 -- 683
local PlayerLayer = 2 -- 684
local PlayerGroup = 1 -- 686
local EnemyGroup = 2 -- 687
local DesignWidth <const> = 1500 -- 689
Data:setRelation(PlayerGroup, EnemyGroup, "Enemy") -- 691
Data:setShouldContact(PlayerGroup, EnemyGroup, true) -- 692
local world -- 694
do -- 694
	local _with_0 = PlatformWorld() -- 694
	_with_0.camera.boundary = Rect(-1250, -500, 2500, 1000) -- 695
	_with_0.camera.followRatio = Vec2(0.01, 0.01) -- 696
	_with_0.camera.zoom = View.size.width / DesignWidth -- 697
	_with_0:gslot("AppSizeChanged", function() -- 698
		local zoom = View.size.width / DesignWidth -- 699
		_with_0.camera.zoom = zoom -- 700
		local _with_1 = Director.ui -- 701
		_with_1.scaleX = zoom -- 702
		_with_1.scaleY = zoom -- 702
		return _with_1 -- 701
	end) -- 698
	world = _with_0 -- 694
end -- 694
Store["world"] = world -- 703
local terrainDef -- 705
do -- 705
	local _with_0 = BodyDef() -- 705
	_with_0.type = "Static" -- 706
	_with_0:attachPolygon(Vec2(0, 0), 2500, 10, 0, 1, 1, 0) -- 707
	_with_0:attachPolygon(Vec2(0, 1000), 2500, 10, 0, 1, 1, 0) -- 708
	_with_0:attachPolygon(Vec2(1250, 500), 10, 1000, 0, 1, 1, 0) -- 709
	_with_0:attachPolygon(Vec2(-1250, 500), 10, 1000, 0, 1, 1, 0) -- 710
	terrainDef = _with_0 -- 705
end -- 705
do -- 712
	local _with_0 = Body(terrainDef, world, Vec2.zero) -- 712
	_with_0.order = TerrainLayer -- 713
	_with_0.group = Data.groupTerrain -- 714
	_with_0:addTo(world) -- 715
end -- 712
local _anon_func_5 = function(Sprite, item, tostring, offset) -- 736
	local _with_0 = Sprite("Model/patreon.clip|" .. tostring(item)) -- 735
	_with_0.position = offset -- 736
	return _with_0 -- 735
end -- 735
local updateModel -- 717
updateModel = function(model, currentSet) -- 717
	local node = model:getNodeByName("body") -- 718
	node:removeAllChildren() -- 719
	local charType = characterTypes[currentSet.type] -- 720
	local charColor = characterColors[currentSet.color] -- 721
	node:addChild(Sprite("Model/patreon.clip|character_" .. tostring(charType) .. tostring(charColor))) -- 722
	node = model:getNodeByName("lhand") -- 723
	node:removeAllChildren() -- 724
	node:addChild(Sprite("Model/patreon.clip|character_hand" .. tostring(charColor))) -- 725
	node = model:getNodeByName("rhand") -- 726
	node:removeAllChildren() -- 727
	node:addChild(Sprite("Model/patreon.clip|character_hand" .. tostring(charColor))) -- 728
	model:getNodeByName("head"):removeAllChildren() -- 729
	for _index_0 = 1, #itemSlots do -- 730
		local slot = itemSlots[_index_0] -- 730
		node = model:getNodeByName(slot) -- 731
		local item = currentSet[slot] -- 732
		if item then -- 733
			local offset = itemSettings[item].offset -- 734
			node:addChild(_anon_func_5(Sprite, item, tostring, offset)) -- 735
		end -- 733
	end -- 736
end -- 717
local NewFighter -- 738
NewFighter = function(name, currentSet) -- 738
	local assembleFighter = false -- 739
	local fighter -- 740
	do -- 740
		local _with_0 = Model("Model/patreon.model") -- 740
		local modelRect = Rect(-128, -128, 256, 256) -- 741
		_with_0.recovery = 0.2 -- 742
		_with_0.order = PlayerLayer -- 743
		_with_0.touchEnabled = true -- 744
		_with_0.swallowTouches = true -- 745
		_with_0:slot("TapFilter", function(touch) -- 746
			if not modelRect:containsPoint(touch.location) then -- 747
				touch.enabled = false -- 748
			end -- 747
		end) -- 746
		_with_0:slot("Tapped", function() -- 749
			if not fighter:getChildByTag("select") then -- 750
				local selectFrame -- 751
				do -- 751
					local _with_1 = Sprite("Model/patreon.clip|ui_select") -- 751
					_with_1:addTo(fighter, 0, "select") -- 752
					_with_1:runAction(Scale(0.3, 0, 1.8, Ease.OutBack)) -- 753
					assembleFighter = true -- 754
					selectFrame = _with_1 -- 751
				end -- 751
			end -- 750
		end) -- 749
		_with_0:play("idle", true) -- 755
		fighter = _with_0 -- 740
	end -- 740
	updateModel(fighter, currentSet) -- 756
	local HeadItemPanel = NewItemPanel("头部", "head", headItems, currentSet) -- 757
	local LHandItemPanel = NewItemPanel("副手", "lhand", lhandItems, currentSet) -- 758
	local RHandItemPanel = NewItemPanel("主手", "rhand", rhandItems, currentSet) -- 759
	return fighter, function() -- 760
		SetNextWindowSize(Vec2(445, 600), "FirstUseEver") -- 761
		if assembleFighter then -- 762
			assembleFighter = false -- 763
			OpenPopup("战士" .. tostring(name)) -- 764
		end -- 762
		return BeginPopupModal("战士" .. tostring(name), { -- 765
			"NoResize", -- 765
			"NoSavedSettings" -- 765
		}, function() -- 765
			HeadItemPanel() -- 766
			RHandItemPanel() -- 767
			LHandItemPanel() -- 768
			Columns(1, false) -- 769
			TextColored(themeColor, "性别") -- 770
			NextColumn() -- 771
			local _ -- 772
			_, currentSet.type = RadioButton("男", currentSet.type, 1) -- 772
			SameLine() -- 773
			_, currentSet.type = RadioButton("女", currentSet.type, 2) -- 774
			Columns(1, false) -- 775
			local cost = 0 -- 776
			for _index_0 = 1, #itemSlots do -- 777
				local slot = itemSlots[_index_0] -- 777
				local item = currentSet[slot] -- 778
				cost = cost + (item and itemSettings[item].cost or 0) -- 779
			end -- 779
			TextColored(themeColor, "累计消耗资源：" .. tostring(cost)) -- 780
			NextColumn() -- 781
			Columns(2, false) -- 782
			if Button("进行训练！", Vec2(200, 80)) then -- 783
				updateModel(fighter, currentSet) -- 784
				CloseCurrentPopup() -- 785
				do -- 786
					local _with_0 = fighter:getChildByTag("select") -- 786
					_with_0:removeFromParent() -- 787
				end -- 786
				emit("ShowSetting", false) -- 788
				local charSet = 1 -- 789
				for i = 1, #characters do -- 790
					if currentSet == characters[i] then -- 791
						charSet = i -- 792
						break -- 793
					end -- 791
				end -- 793
				Entity({ -- 795
					unitDef = "fighter", -- 795
					charSet = charSet, -- 796
					order = PlayerLayer, -- 797
					position = Vec2(-400, 400), -- 798
					group = PlayerGroup, -- 799
					faceRight = true, -- 800
					player = true, -- 801
					decisionTree = "AI_PlayerControl" -- 802
				}) -- 794
				Entity({ -- 804
					unitDef = "boss", -- 804
					order = EnemyLayer, -- 805
					position = Vec2(400, 400), -- 806
					group = EnemyGroup, -- 807
					faceRight = false, -- 808
					boss = true -- 809
				}) -- 803
				emit("ShowTraining", true) -- 810
			end -- 783
			NextColumn() -- 811
			if Button("装备完成！", Vec2(200, 80)) then -- 812
				updateModel(fighter, currentSet) -- 813
				CloseCurrentPopup() -- 814
				do -- 815
					local _with_0 = fighter:getChildByTag("select") -- 815
					_with_0:runAction(Sequence(Spawn(Scale(0.3, 1.8, 2.5), Opacity(0.3, 1, 0)), Event("End"))) -- 816
					_with_0:slot("End", function() -- 820
						return _with_0:removeFromParent() -- 820
					end) -- 820
				end -- 815
			end -- 812
			return NextColumn() -- 821
		end) -- 821
	end -- 821
end -- 738
local fighterFigures = { } -- 823
local fighterPanels = { } -- 824
for i = 1, #characters do -- 825
	local fighter, fighterPanel = NewFighter(string.rep("I", i), characters[i]) -- 826
	table.insert(fighterFigures, fighter) -- 827
	table.insert(fighterPanels, fighterPanel) -- 828
end -- 828
local playerGroup = Group({ -- 830
	"player", -- 830
	"unit" -- 830
}) -- 830
local updatePlayerControl -- 831
updatePlayerControl = function(key, flag) -- 831
	return playerGroup:each(function(self) -- 831
		self.unit.data[key] = flag -- 831
	end) -- 831
end -- 831
local uiScale = App.devicePixelRatio -- 833
Director.ui:addChild((function() -- 835
	local _with_0 = AlignNode({ -- 835
		isRoot = true -- 835
	}) -- 835
	_with_0:schedule(function() -- 836
		local width, height -- 837
		do -- 837
			local _obj_0 = App.visualSize -- 837
			width, height = _obj_0.width, _obj_0.height -- 837
		end -- 837
		SetNextWindowPos(Vec2(10, 10), "FirstUseEver") -- 838
		SetNextWindowSize(Vec2(350, 160), "FirstUseEver") -- 839
		return Begin("AI军团", { -- 840
			"NoResize", -- 840
			"NoSavedSettings" -- 840
		}, function() -- 840
			local isPC -- 841
			do -- 841
				local _exp_0 = App.platform -- 841
				if "macOS" == _exp_0 or "Windows" == _exp_0 or "Linux" == _exp_0 then -- 842
					isPC = true -- 842
				else -- 843
					isPC = false -- 843
				end -- 843
			end -- 843
			return TextWrapped("点击你的学员部队配备装备，并亲自进行战斗方法的训练，最后带领部队挑战敌人。\n学员战斗AI通过玩家操作自动学习生成。" .. tostring(isPC and '训练操作按键：向左A，向右D，闪避E，攻击J，跳跃K' or '')) -- 844
		end) -- 844
	end) -- 836
	_with_0:addChild((function() -- 845
		local _with_1 = AlignNode() -- 845
		_with_1.size = Size(0, 0) -- 846
		_with_1.hAlign = "Center" -- 847
		_with_1.vAlign = "Center" -- 848
		_with_1.alignOffset = Vec2(0, 32) -- 849
		_with_1.visible = false -- 850
		_with_1:gslot("ShowTraining", function(show) -- 851
			_with_1.visible = show -- 852
			if show then -- 853
				return _with_1:addChild((function() -- 854
					local _with_2 = CircleButton({ -- 855
						text = "训练\n结束！", -- 855
						y = -300, -- 856
						radius = 80, -- 857
						fontName = "sarasa-mono-sc-regular", -- 858
						fontSize = 48 -- 859
					}) -- 854
					_with_2:slot("Tapped", function() -- 861
						emit("ShowTraining", false) -- 862
						Group({ -- 863
							"player" -- 863
						}):each(function(e) -- 863
							if e.charSet then -- 864
								emit("TrainAI", e.charSet) -- 865
								return e.unit:removeFromParent() -- 866
							end -- 864
						end) -- 863
						Group({ -- 867
							"boss" -- 867
						}):each(function(e) -- 867
							return e.unit:removeFromParent() -- 868
						end) -- 867
						return emit("ShowSetting", true) -- 869
					end) -- 861
					return _with_2 -- 854
				end)()) -- 869
			else -- 871
				return _with_1:removeAllChildren() -- 871
			end -- 853
		end) -- 851
		_with_1:gslot("ShowFight", function(show) -- 872
			_with_1.visible = show -- 873
			if show then -- 874
				return _with_1:addChild((function() -- 875
					local _with_2 = CircleButton({ -- 876
						text = "离开\n战斗", -- 876
						y = -300, -- 877
						radius = 80, -- 878
						fontName = "sarasa-mono-sc-regular", -- 879
						fontSize = 48 -- 880
					}) -- 875
					_with_2:slot("Tapped", function() -- 882
						Group({ -- 883
							"unitDef" -- 883
						}):each(function(e) -- 883
							local _obj_0 = e.unit -- 884
							if _obj_0 ~= nil then -- 884
								return _obj_0:removeFromParent() -- 884
							end -- 884
							return nil -- 884
						end) -- 883
						emit("ShowSetting", true) -- 885
						return thread(function() -- 886
							return emit("ShowFight", false) -- 886
						end) -- 886
					end) -- 882
					return _with_2 -- 875
				end)()) -- 886
			else -- 888
				return _with_1:removeAllChildren() -- 888
			end -- 874
		end) -- 872
		return _with_1 -- 845
	end)()) -- 845
	_with_0:addChild((function() -- 889
		local _with_1 = AlignNode() -- 889
		_with_1.size = Size(0, 0) -- 890
		_with_1.hAlign = "Center" -- 891
		_with_1.vAlign = "Center" -- 892
		_with_1.alignOffset = Vec2(0, 32) -- 893
		_with_1:gslot("ShowSetting", function(show) -- 894
			_with_1.visible = show -- 894
		end) -- 894
		_with_1:addChild((function() -- 895
			local _with_2 = Model("Model/bossp.model") -- 895
			_with_2.x = 500 -- 896
			_with_2.y = 100 -- 897
			_with_2.fliped = true -- 898
			_with_2.speed = 0.8 -- 899
			_with_2.scaleX, _with_2.scaleY = 2, 2 -- 900
			_with_2.recovery = 0.2 -- 901
			_with_2:play("idle", true) -- 902
			return _with_2 -- 895
		end)()) -- 895
		for i = 1, #fighterFigures do -- 903
			local fighter = fighterFigures[i] -- 904
			_with_1:addChild((function() -- 905
				fighter.x = -500 + (i - 1) * 200 -- 906
				return fighter -- 905
			end)()) -- 905
		end -- 906
		_with_1:addChild((function() -- 907
			local _with_2 = CircleButton({ -- 908
				text = "开战！", -- 908
				y = -300, -- 909
				radius = 80, -- 910
				fontName = "sarasa-mono-sc-regular", -- 911
				fontSize = 48 -- 912
			}) -- 907
			local showItems -- 914
			showItems = function(show) -- 914
				for _index_0 = 1, #fighterFigures do -- 915
					local fighter = fighterFigures[_index_0] -- 915
					fighter.touchEnabled = not show -- 916
				end -- 916
				_with_2.visible = not show -- 917
			end -- 914
			_with_2:gslot("ShowFight", showItems) -- 918
			_with_2:gslot("ShowTraining", showItems) -- 919
			_with_2:slot("Tapped", function() -- 920
				if not _with_2.visible then -- 921
					return -- 921
				end -- 921
				for i = 1, #characters do -- 922
					local char = characters[i] -- 923
					Entity({ -- 925
						unitDef = "fighter", -- 925
						charSet = i, -- 926
						order = PlayerLayer, -- 927
						position = Vec2(-600 + (i - 1) * 200, 400), -- 928
						group = PlayerGroup, -- 929
						faceRight = true, -- 930
						decisionTree = "AI_Learned", -- 931
						player = true -- 932
					}) -- 924
				end -- 932
				Entity({ -- 934
					unitDef = "boss", -- 934
					order = EnemyLayer, -- 935
					position = Vec2(400, 400), -- 936
					group = EnemyGroup, -- 937
					faceRight = false, -- 938
					boss = true -- 939
				}) -- 933
				emit("ShowSetting", false) -- 940
				return emit("ShowFight", true) -- 941
			end) -- 920
			return _with_2 -- 907
		end)()) -- 907
		return _with_1 -- 889
	end)()) -- 889
	do -- 942
		local _exp_0 = App.platform -- 942
		if "iOS" == _exp_0 or "Android" == _exp_0 then -- 943
			_with_0:addChild((function() -- 944
				local _with_1 = AlignNode() -- 944
				_with_1.hAlign = "Left" -- 945
				_with_1.vAlign = "Bottom" -- 946
				_with_1.visible = false -- 947
				_with_1:gslot("ShowTraining", function(show) -- 948
					_with_1.visible = show -- 948
				end) -- 948
				_with_1:addChild((function() -- 949
					local _with_2 = Menu() -- 949
					_with_2:addChild((function() -- 950
						local _with_3 = CircleButton({ -- 951
							text = "左", -- 951
							x = 20 * uiScale, -- 952
							y = 90 * uiScale, -- 953
							radius = 30 * uiScale, -- 954
							fontSize = math.floor(18 * uiScale) -- 955
						}) -- 950
						_with_3.anchor = Vec2.zero -- 957
						_with_3:slot("TapBegan", function() -- 958
							return updatePlayerControl("keyLeft", true) -- 958
						end) -- 958
						_with_3:slot("TapEnded", function() -- 959
							return updatePlayerControl("keyLeft", false) -- 959
						end) -- 959
						return _with_3 -- 950
					end)()) -- 950
					_with_2:addChild((function() -- 960
						local _with_3 = CircleButton({ -- 961
							text = "右", -- 961
							x = 90 * uiScale, -- 962
							y = 90 * uiScale, -- 963
							radius = 30 * uiScale, -- 964
							fontSize = math.floor(18 * uiScale) -- 965
						}) -- 960
						_with_3.anchor = Vec2.zero -- 967
						_with_3:slot("TapBegan", function() -- 968
							return updatePlayerControl("keyRight", true) -- 968
						end) -- 968
						_with_3:slot("TapEnded", function() -- 969
							return updatePlayerControl("keyRight", false) -- 969
						end) -- 969
						return _with_3 -- 960
					end)()) -- 960
					return _with_2 -- 949
				end)()) -- 949
				return _with_1 -- 944
			end)()) -- 944
			_with_0:addChild((function() -- 970
				local _with_1 = AlignNode() -- 970
				_with_1.hAlign = "Right" -- 971
				_with_1.vAlign = "Bottom" -- 972
				_with_1.visible = false -- 973
				_with_1:gslot("ShowTraining", function(show) -- 974
					_with_1.visible = show -- 974
				end) -- 974
				_with_1:addChild((function() -- 975
					local _with_2 = Menu() -- 975
					_with_2:addChild((function() -- 976
						local _with_3 = CircleButton({ -- 977
							text = "闪", -- 977
							x = -80 * uiScale, -- 978
							y = 160 * uiScale, -- 979
							radius = 30 * uiScale, -- 980
							fontSize = math.floor(18 * uiScale) -- 981
						}) -- 976
						_with_3.anchor = Vec2.zero -- 983
						_with_3:slot("TapBegan", function() -- 984
							return updatePlayerControl("keyE", true) -- 984
						end) -- 984
						_with_3:slot("TapEnded", function() -- 985
							return updatePlayerControl("keyE", false) -- 985
						end) -- 985
						return _with_3 -- 976
					end)()) -- 976
					_with_2:addChild((function() -- 986
						local _with_3 = CircleButton({ -- 987
							text = "跳", -- 987
							x = -80 * uiScale, -- 988
							y = 90 * uiScale, -- 989
							radius = 30 * uiScale, -- 990
							fontSize = math.floor(18 * uiScale) -- 991
						}) -- 986
						_with_3.anchor = Vec2.zero -- 993
						_with_3:slot("TapBegan", function() -- 994
							return updatePlayerControl("keyUp", true) -- 994
						end) -- 994
						_with_3:slot("TapEnded", function() -- 995
							return updatePlayerControl("keyUp", false) -- 995
						end) -- 995
						return _with_3 -- 986
					end)()) -- 986
					_with_2:addChild((function() -- 996
						local _with_3 = CircleButton({ -- 997
							text = "打", -- 997
							x = -150 * uiScale, -- 998
							y = 90 * uiScale, -- 999
							radius = 30 * uiScale, -- 1000
							fontSize = math.floor(18 * uiScale) -- 1001
						}) -- 996
						_with_3.anchor = Vec2.zero -- 1003
						_with_3:slot("TapBegan", function() -- 1004
							return updatePlayerControl("keyF", true) -- 1004
						end) -- 1004
						_with_3:slot("TapEnded", function() -- 1005
							return updatePlayerControl("keyF", false) -- 1005
						end) -- 1005
						return _with_3 -- 996
					end)()) -- 996
					return _with_2 -- 975
				end)()) -- 975
				return _with_1 -- 970
			end)()) -- 970
		elseif "macOS" == _exp_0 or "Windows" == _exp_0 or "Linux" == _exp_0 then -- 1006
			do -- 1007
				local _with_1 = Node() -- 1007
				_with_1:schedule(function() -- 1008
					updatePlayerControl("keyLeft", Keyboard:isKeyPressed("A")) -- 1009
					updatePlayerControl("keyRight", Keyboard:isKeyPressed("D")) -- 1010
					updatePlayerControl("keyUp", Keyboard:isKeyPressed("K")) -- 1011
					updatePlayerControl("keyF", Keyboard:isKeyPressed("J")) -- 1012
					return updatePlayerControl("keyE", Keyboard:isKeyPressed("E")) -- 1013
				end) -- 1008
			end -- 1007
		end -- 1013
	end -- 1013
	return _with_0 -- 835
end)()) -- 835
do -- 1015
	local _with_0 = Node() -- 1015
	_with_0:schedule(function() -- 1016
		local width, height -- 1017
		do -- 1017
			local _obj_0 = App.visualSize -- 1017
			width, height = _obj_0.width, _obj_0.height -- 1017
		end -- 1017
		for _index_0 = 1, #fighterPanels do -- 1018
			local panel = fighterPanels[_index_0] -- 1018
			panel() -- 1018
		end -- 1018
	end) -- 1016
end -- 1015
local rangeAttackEnd -- 1020
rangeAttackEnd = function(name, playable) -- 1020
	if name == "range" then -- 1021
		return playable.parent:stop() -- 1021
	end -- 1021
end -- 1020
UnitAction:add("range", { -- 1024
	priority = 3, -- 1024
	reaction = 10, -- 1025
	recovery = 0.1, -- 1026
	queued = true, -- 1027
	available = function(self) -- 1028
		return true -- 1028
	end, -- 1028
	create = function(self) -- 1029
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 1030
		do -- 1030
			local _obj_0 = self.entity -- 1035
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 1030
		end -- 1035
		do -- 1036
			local _with_0 = self.playable -- 1036
			_with_0.speed = attackSpeed -- 1037
			_with_0:play("range") -- 1038
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 1039
		end -- 1036
		return once(function(self) -- 1040
			local bulletDef = Store[self.unitDef.bulletType] -- 1041
			local onAttack -- 1042
			onAttack = function() -- 1042
				local _with_0 = Bullet(bulletDef, self) -- 1043
				_with_0.targetAllow = targetAllow -- 1044
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 1045
					do -- 1046
						local _with_1 = target.data -- 1046
						_with_1.hitPoint = pos -- 1047
						_with_1.hitPower = attackPower -- 1048
						_with_1.hitFromRight = bullet.velocityX < 0 -- 1049
					end -- 1046
					local entity = target.entity -- 1050
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 1051
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 1052
					entity.hp = entity.hp - damage -- 1053
					bullet.hitStop = true -- 1054
				end) -- 1045
				_with_0:addTo(self.world, self.order) -- 1055
				return _with_0 -- 1043
			end -- 1042
			sleep(0.5 * 28.0 / 30.0 / attackSpeed) -- 1056
			onAttack() -- 1057
			while true do -- 1058
				sleep() -- 1058
			end -- 1058
		end) -- 1058
	end, -- 1029
	stop = function(self) -- 1059
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 1060
	end -- 1059
}) -- 1023
local BigArrow -- 1062
do -- 1062
	local _with_0 = BulletDef() -- 1062
	_with_0.tag = "" -- 1063
	_with_0.endEffect = "" -- 1064
	_with_0.lifeTime = 5 -- 1065
	_with_0.damageRadius = 0 -- 1066
	_with_0.highSpeedFix = false -- 1067
	_with_0.gravity = Vec2(0, -10) -- 1068
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2(-100, 0), 2) -- 1069
	_with_0:setAsCircle(10) -- 1070
	_with_0:setVelocity(25, 800) -- 1071
	BigArrow = _with_0 -- 1062
end -- 1062
UnitAction:add("multiArrow", { -- 1074
	priority = 3, -- 1074
	reaction = 10, -- 1075
	recovery = 0.1, -- 1076
	queued = true, -- 1077
	available = function(self) -- 1078
		return true -- 1078
	end, -- 1078
	create = function(self) -- 1079
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 1080
		do -- 1080
			local _obj_0 = self.entity -- 1085
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 1080
		end -- 1085
		do -- 1086
			local _with_0 = self.playable -- 1086
			_with_0.speed = attackSpeed -- 1087
			_with_0:play("range") -- 1088
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 1089
		end -- 1086
		return once(function(self) -- 1090
			local onAttack -- 1091
			onAttack = function(angle, speed) -- 1091
				BigArrow:setVelocity(angle, speed) -- 1092
				local _with_0 = Bullet(BigArrow, self) -- 1093
				_with_0.targetAllow = targetAllow -- 1094
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 1095
					do -- 1096
						local _with_1 = target.data -- 1096
						_with_1.hitPoint = pos -- 1097
						_with_1.hitPower = attackPower -- 1098
						_with_1.hitFromRight = bullet.velocityX < 0 -- 1099
					end -- 1096
					local entity = target.entity -- 1100
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 1101
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 1102
					entity.hp = entity.hp - damage -- 1103
					bullet.hitStop = true -- 1104
				end) -- 1095
				_with_0:addTo(self.world, self.order) -- 1105
				return _with_0 -- 1093
			end -- 1091
			sleep(30.0 / 60.0 / attackSpeed) -- 1106
			onAttack(30, 1100) -- 1107
			onAttack(10, 1000) -- 1108
			onAttack(-10, 900) -- 1109
			onAttack(-30, 800) -- 1110
			onAttack(-50, 700) -- 1111
			while true do -- 1112
				sleep() -- 1112
			end -- 1112
		end) -- 1112
	end, -- 1079
	stop = function(self) -- 1113
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 1114
	end -- 1113
}) -- 1073
UnitAction:add("fallOff", { -- 1117
	priority = 1, -- 1117
	reaction = 1, -- 1118
	recovery = 0, -- 1119
	available = function(self) -- 1120
		return not self.onSurface -- 1120
	end, -- 1120
	create = function(self) -- 1121
		if self.velocityY <= 0 then -- 1122
			self.data.fallDown = true -- 1123
			do -- 1124
				local _with_0 = self.playable -- 1124
				_with_0.speed = 2.5 -- 1125
				_with_0:play("idle") -- 1126
			end -- 1124
		else -- 1127
			self.data.fallDown = false -- 1127
		end -- 1122
		return function(self, action) -- 1128
			if self.onSurface then -- 1129
				return true -- 1129
			end -- 1129
			if not self.data.fallDown and self.velocityY <= 0 then -- 1130
				self.data.fallDown = true -- 1131
				do -- 1132
					local _with_0 = self.playable -- 1132
					_with_0.speed = 2.5 -- 1133
					_with_0:play("idle") -- 1134
				end -- 1132
			end -- 1130
			return false -- 1135
		end -- 1135
	end -- 1121
}) -- 1116
UnitAction:add("evade", { -- 1138
	priority = 10, -- 1138
	reaction = 10, -- 1139
	recovery = 0, -- 1140
	queued = true, -- 1141
	available = function(self) -- 1142
		return true -- 1142
	end, -- 1142
	create = function(self) -- 1143
		do -- 1144
			local _with_0 = self.playable -- 1144
			_with_0.speed = 1.0 -- 1145
			_with_0.recovery = 0.0 -- 1146
			_with_0:play("bevade") -- 1147
		end -- 1144
		return once(function(self) -- 1148
			local group = self.group -- 1149
			self.group = Data.groupHide -- 1150
			local dir = self.faceRight and -1 or 1 -- 1151
			cycle(0.2, function() -- 1152
				self.velocityX = 800 * dir -- 1152
			end) -- 1152
			self.group = group -- 1153
			do -- 1154
				local _with_0 = self.playable -- 1154
				_with_0.speed = 1.0 -- 1155
				_with_0:play("idle") -- 1156
			end -- 1154
			sleep(1) -- 1157
			return true -- 1158
		end) -- 1158
	end -- 1143
}) -- 1137
local spearAttackEnd -- 1160
spearAttackEnd = function(name, playable) -- 1160
	if name == "spear" then -- 1161
		return playable.parent:stop() -- 1161
	end -- 1161
end -- 1160
UnitAction:add("spearAttack", { -- 1164
	priority = 3, -- 1164
	reaction = 10, -- 1165
	recovery = 0.1, -- 1166
	queued = true, -- 1167
	available = function(self) -- 1168
		return true -- 1168
	end, -- 1168
	create = function(self) -- 1169
		local attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor -- 1170
		do -- 1170
			local _obj_0 = self.entity -- 1174
			attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 1170
		end -- 1174
		do -- 1175
			local _with_0 = self.playable -- 1175
			_with_0.speed = attackSpeed -- 1176
			_with_0.recovery = 0.2 -- 1177
			_with_0:play("spear") -- 1178
			_with_0:slot("AnimationEnd", spearAttackEnd) -- 1179
		end -- 1175
		return once(function(self) -- 1180
			sleep(50.0 / 60.0) -- 1181
			local dir = self.faceRight and 0 or -900 -- 1182
			local origin = self.position - Vec2(0, 205) + Vec2(dir, 0) -- 1183
			size = Size(900, 40) -- 1184
			world:query(Rect(origin, size), function(body) -- 1185
				local entity = body.entity -- 1186
				if entity and Data:isEnemy(body, self) then -- 1187
					do -- 1188
						local _with_0 = body.data -- 1188
						_with_0.hitPoint = body.position -- 1189
						_with_0.hitPower = attackPower -- 1190
						_with_0.hitFromRight = not self.faceRight -- 1191
					end -- 1188
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 1192
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 1193
					entity.hp = entity.hp - damage -- 1194
				end -- 1187
				return false -- 1195
			end) -- 1185
			while true do -- 1196
				sleep() -- 1196
			end -- 1196
		end) -- 1196
	end, -- 1169
	stop = function(self) -- 1197
		return self.playable:slot("AnimationEnd"):remove(spearAttackEnd) -- 1198
	end -- 1197
}) -- 1163
local mutables = { -- 1201
	"hp", -- 1201
	"moveSpeed", -- 1202
	"move", -- 1203
	"jump", -- 1204
	"targetAllow", -- 1205
	"attackBase", -- 1206
	"attackPower", -- 1207
	"attackSpeed", -- 1208
	"damageType", -- 1209
	"attackBonus", -- 1210
	"attackFactor", -- 1211
	"attackTarget", -- 1212
	"defenceType" -- 1213
} -- 1200
do -- 1216
	local _with_0 = Observer("Add", { -- 1216
		"unitDef", -- 1216
		"position", -- 1216
		"order", -- 1216
		"group", -- 1216
		"faceRight" -- 1216
	}) -- 1216
	_with_0:watch(function(self, unitDef, position, order, group) -- 1217
		local player, faceRight, charSet, decisionTree = self.player, self.faceRight, self.charSet, self.decisionTree -- 1218
		world = Store.world -- 1219
		local func = UnitDefFuncs[unitDef] -- 1220
		local def = func() -- 1221
		for _index_0 = 1, #mutables do -- 1222
			local var = mutables[_index_0] -- 1222
			self[var] = def[var] -- 1223
		end -- 1223
		if charSet then -- 1224
			local set = characters[charSet] -- 1225
			local actions = def.actions -- 1226
			local actionSet -- 1227
			do -- 1227
				local _tbl_0 = { } -- 1227
				for _index_0 = 1, #actions do -- 1227
					local a = actions[_index_0] -- 1227
					_tbl_0[a] = true -- 1227
				end -- 1227
				actionSet = _tbl_0 -- 1227
			end -- 1227
			for _index_0 = 1, #itemSlots do -- 1228
				local slot = itemSlots[_index_0] -- 1228
				local item = set[slot] -- 1229
				if not item then -- 1230
					goto _continue_0 -- 1230
				end -- 1230
				local skill = itemSettings[item].skill -- 1231
				if skill and not actionSet[skill] then -- 1232
					actions:add(skill) -- 1233
				end -- 1232
				local attackRange = itemSettings[item].attackRange -- 1234
				if attackRange then -- 1235
					def.attackRange = attackRange -- 1235
				end -- 1235
				::_continue_0:: -- 1229
			end -- 1235
		end -- 1224
		if decisionTree then -- 1236
			def.decisionTree = decisionTree -- 1236
		end -- 1236
		local unit -- 1237
		do -- 1237
			local _with_1 = Unit(def, world, self, position) -- 1237
			_with_1.group = group -- 1238
			_with_1.order = order -- 1239
			_with_1.faceRight = faceRight -- 1240
			_with_1:addTo(world) -- 1241
			unit = _with_1 -- 1237
		end -- 1237
		if charSet then -- 1242
			updateModel(unit.playable, characters[charSet]) -- 1242
		end -- 1242
		if player then -- 1243
			world.camera.followTarget = unit -- 1244
		end -- 1243
		return false -- 1244
	end) -- 1217
end -- 1216
local _with_0 = Observer("Change", { -- 1246
	"hp", -- 1246
	"unit" -- 1246
}) -- 1246
_with_0:watch(function(self, hp, unit) -- 1247
	local boss = self.boss -- 1248
	local lastHp = self.oldValues.hp -- 1249
	if hp < lastHp then -- 1250
		if not boss and unit:isDoing("hit") then -- 1251
			unit:start("cancel") -- 1251
		end -- 1251
		if boss then -- 1252
			do -- 1253
				local _with_1 = Visual("Particle/bloodp.par") -- 1253
				_with_1.position = unit.data.hitPoint -- 1254
				_with_1:addTo(world, unit.order) -- 1255
				_with_1:autoRemove() -- 1256
				_with_1:start() -- 1257
			end -- 1253
		end -- 1252
		if hp > 0 then -- 1258
			unit:start("hit") -- 1259
		else -- 1261
			unit:start("hit") -- 1261
			unit:start("fall") -- 1262
			unit.group = Data.groupHide -- 1263
			if self.player then -- 1264
				playerGroup:each(function(p) -- 1265
					if p and p.unit and p.hp > 0 then -- 1266
						world.camera.followTarget = p.unit -- 1267
						return true -- 1268
					else -- 1269
						return false -- 1269
					end -- 1266
				end) -- 1265
			end -- 1264
		end -- 1258
	end -- 1250
	return false -- 1269
end) -- 1247
return _with_0 -- 1246
