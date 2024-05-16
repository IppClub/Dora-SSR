-- [yue]: Script/Game/Zombie Escape/AI.yue
local _module_0 = Dora.Platformer -- 1
local Data = _module_0.Data -- 1
local _module_1 = Dora.Platformer.Decision -- 1
local Sel = _module_1.Sel -- 1
local Seq = _module_1.Seq -- 1
local Con = _module_1.Con -- 1
local Unit = _module_0.Unit -- 1
local Vec2 = Dora.Vec2 -- 1
local Act = _module_1.Act -- 1
local Reject = _module_1.Reject -- 1
local math = _G.math -- 1
local Behave = _module_1.Behave -- 1
local AI = _module_1.AI -- 1
local App = Dora.App -- 1
local Accept = _module_1.Accept -- 1
local Group = Dora.Group -- 1
local BT = require("Platformer").Behavior -- 13
local Store = Data.store -- 15
local rangeAttack = Sel({ -- 18
	Seq({ -- 19
		Con("attack path blocked", function(self) -- 19
			local sensor = self:getSensorByTag(Unit.AttackSensorTag) -- 20
			if sensor.sensedBodies:each(function(body) -- 21
				return body.group == Data.groupTerrain and (self.x > body.x) ~= self.faceRight and body.tag == "Obstacle" -- 24
			end) then -- 21
				local faceObstacle = true -- 25
				local start = self.position -- 26
				local stop = Vec2(start.x + (self.faceRight and 1 or -1) * self.unitDef.attackRange.width, start.y) -- 27
				Store.world:raycast(start, stop, true, function(b) -- 28
					if b.group == Data.groupDetection then -- 29
						return false -- 29
					end -- 29
					if Data:isEnemy(self, b) then -- 30
						faceObstacle = false -- 30
					end -- 30
					return true -- 31
				end) -- 28
				return faceObstacle -- 32
			else -- 33
				return false -- 33
			end -- 21
		end), -- 19
		Act("jump"), -- 34
		Reject() -- 35
	}), -- 18
	Act("rangeAttack") -- 37
}) -- 17
local walk = Sel({ -- 41
	Seq({ -- 42
		Con("obstacles ahead", function(self) -- 42
			local start = self.position -- 43
			local stop = Vec2(start.x + (self.faceRight and 140 or -140), start.y) -- 44
			return Store.world:raycast(start, stop, false, function(b, p) -- 45
				if b.group == Data.groupTerrain and b.tag == "Obstacle" then -- 46
					self.data.obstacleDistance = math.abs(p.x - start.x) -- 47
					return true -- 48
				else -- 49
					return false -- 49
				end -- 46
			end) -- 49
		end), -- 42
		Sel({ -- 51
			Seq({ -- 52
				Con("obstacle distance <= 80", function(self) -- 52
					return self.data.obstacleDistance <= 80 -- 52
				end), -- 52
				Behave("backJump", BT.Seq({ -- 54
					BT.Act("turn"), -- 54
					BT.Countdown(0.3, BT.Act("walk")), -- 55
					BT.Act("turn"), -- 56
					BT.Countdown(0.1, BT.Act("walk")), -- 57
					BT.Act("jump") -- 58
				})) -- 53
			}), -- 51
			Seq({ -- 62
				Con("has forward speed", function(self) -- 62
					return math.abs(self.velocityX) > 0 -- 62
				end), -- 62
				Act("jump") -- 63
			}) -- 61
		}) -- 50
	}), -- 41
	Act("walk") -- 67
}) -- 40
local fightDecision = Seq({ -- 71
	Con("see enemy", function(self) -- 71
		return (AI:getNearestUnit("Enemy") ~= nil) -- 71
	end), -- 71
	Sel({ -- 73
		Seq({ -- 74
			Con("need evade", function(self) -- 74
				if not self:getAction("rangeAttack" or not self.onSurface) then -- 75
					return false -- 75
				end -- 75
				local evadeLeftEnemy = false -- 76
				local evadeRightEnemy = false -- 77
				local sensor = self:getSensorByTag(Unit.AttackSensorTag) -- 78
				sensor.sensedBodies:each(function(body) -- 79
					if Data:isEnemy(self, body) then -- 80
						local distance = math.abs(self.x - body.x) -- 81
						if distance < 80 then -- 82
							evadeRightEnemy = false -- 83
							evadeLeftEnemy = false -- 84
							return true -- 85
						elseif distance < 200 then -- 86
							if body.x > self.x then -- 87
								evadeRightEnemy = true -- 87
							end -- 87
							if body.x <= self.x then -- 88
								evadeLeftEnemy = true -- 88
							end -- 88
						end -- 82
					end -- 80
				end) -- 79
				local needEvade = not (evadeLeftEnemy == evadeRightEnemy) and math.abs(self.x) < 1000 -- 89
				if needEvade then -- 90
					self.data.evadeRight = evadeRightEnemy -- 90
				end -- 90
				return needEvade -- 91
			end), -- 74
			Sel({ -- 93
				Seq({ -- 94
					Con("face enemy", function(self) -- 94
						return self.data.evadeRight == self.faceRight -- 94
					end), -- 94
					Act("turn"), -- 95
					walk -- 96
				}), -- 93
				walk -- 98
			}) -- 92
		}), -- 73
		Seq({ -- 102
			Con("not facing nearest enemy", function(self) -- 102
				local enemy = AI:getNearestUnit("Enemy") -- 103
				return (self.x > enemy.x) == self.faceRight -- 104
			end), -- 102
			Act("turn") -- 105
		}), -- 101
		Seq({ -- 108
			Con("enemy in attack range", function(self) -- 108
				local enemy = AI:getNearestUnit("Enemy") -- 109
				local attackUnits = AI:getUnitsInAttackRange() -- 110
				return attackUnits and attackUnits:contains(enemy) or false -- 111
			end), -- 108
			Sel({ -- 113
				rangeAttack, -- 113
				Act("meleeAttack") -- 114
			}) -- 112
		}), -- 107
		Seq({ -- 118
			Con("wanna jump", function(self) -- 118
				return App.rand % 5 == 0 -- 118
			end), -- 118
			Act("jump") -- 119
		}), -- 117
		walk -- 121
	}) -- 72
}) -- 70
Store["AI_Zombie"] = Sel({ -- 126
	Seq({ -- 127
		Con("is dead", function(self) -- 127
			return self.entity.hp <= 0 -- 127
		end), -- 127
		Accept() -- 128
	}), -- 126
	Seq({ -- 131
		Con("not entered", function(self) -- 131
			return not self.data.entered -- 131
		end), -- 131
		Act("groundEntrance") -- 132
	}), -- 130
	fightDecision, -- 134
	Seq({ -- 136
		Con("need stop", function(self) -- 136
			return not self:isDoing("idle") -- 136
		end), -- 136
		Act("cancel"), -- 137
		Act("idle") -- 138
	}) -- 135
}) -- 125
local playerGroup = Group({ -- 142
	"player" -- 142
}) -- 142
Store["AI_KidFollow"] = Sel({ -- 145
	Seq({ -- 146
		Con("is dead", function(self) -- 146
			return self.entity.hp <= 0 -- 146
		end), -- 146
		Accept() -- 147
	}), -- 145
	fightDecision, -- 149
	Seq({ -- 151
		Con("is falling", function(self) -- 151
			return not self.onSurface -- 151
		end), -- 151
		Act("fallOff") -- 152
	}), -- 150
	Seq({ -- 155
		Con("follow target is away", function(self) -- 155
			local target = playerGroup:find(function(e) -- 156
				return e.unit ~= self -- 156
			end) -- 156
			if target then -- 156
				self.data.followTarget = target.unit -- 157
				return math.abs(self.x - target.unit.x) > 50 -- 158
			else -- 159
				return false -- 159
			end -- 156
		end), -- 155
		Sel({ -- 161
			Seq({ -- 162
				Con("not facing target", function(self) -- 162
					return (self.x > self.data.followTarget.x) == self.faceRight -- 162
				end), -- 162
				Act("turn") -- 163
			}), -- 161
			Accept() -- 165
		}), -- 160
		walk -- 167
	}), -- 154
	Seq({ -- 170
		Con("need stop", function(self) -- 170
			return not self:isDoing("idle") -- 170
		end), -- 170
		Act("cancel"), -- 171
		Act("idle") -- 172
	}) -- 169
}) -- 144
Store["AI_KidSearch"] = Sel({ -- 177
	Seq({ -- 178
		Con("is dead", function(self) -- 178
			return self.entity.hp <= 0 -- 178
		end), -- 178
		Accept() -- 179
	}), -- 177
	fightDecision, -- 181
	Seq({ -- 183
		Con("is falling", function(self) -- 183
			return not self.onSurface -- 183
		end), -- 183
		Act("fallOff") -- 184
	}), -- 182
	Seq({ -- 187
		Con("reach search limit", function(self) -- 187
			return math.abs(self.x) > 1150 and ((self.x > 0) == self.faceRight) -- 187
		end), -- 187
		Act("turn") -- 188
	}), -- 186
	Seq({ -- 191
		Con("continue search", function() -- 191
			return true -- 191
		end), -- 191
		walk -- 192
	}) -- 190
}) -- 176
Store["AI_PlayerControl"] = Sel({ -- 197
	Seq({ -- 198
		Con("is dead", function(self) -- 198
			return self.entity.hp <= 0 -- 198
		end), -- 198
		Accept() -- 199
	}), -- 197
	Seq({ -- 202
		Seq({ -- 203
			Con("move key down", function(self) -- 203
				return not (self.data.keyLeft and self.data.keyRight) and ((self.data.keyLeft and self.faceRight) or (self.data.keyRight and not self.faceRight)) -- 208
			end), -- 203
			Act("turn") -- 209
		}), -- 202
		Reject() -- 211
	}), -- 201
	Seq({ -- 214
		Con("attack key down", function(self) -- 214
			return self.data.keyShoot -- 214
		end), -- 214
		Sel({ -- 216
			Act("meleeAttack"), -- 216
			Act("rangeAttack") -- 217
		}) -- 215
	}), -- 213
	Sel({ -- 221
		Seq({ -- 222
			Con("is falling", function(self) -- 222
				return not self.onSurface -- 222
			end), -- 222
			Act("fallOff") -- 223
		}), -- 221
		Seq({ -- 226
			Con("jump key down", function(self) -- 226
				return self.data.keyUp -- 226
			end), -- 226
			Act("jump") -- 227
		}) -- 225
	}), -- 220
	Seq({ -- 231
		Con("move key down", function(self) -- 231
			return self.data.keyLeft or self.data.keyRight -- 231
		end), -- 231
		Act("walk") -- 232
	}), -- 230
	Seq({ -- 235
		Con("need stop", function(self) -- 235
			return not self:isDoing("idle") -- 235
		end), -- 235
		Act("cancel"), -- 236
		Act("idle") -- 237
	}) -- 234
}) -- 196
