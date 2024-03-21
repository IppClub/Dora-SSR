-- [yue]: Script/Game/Zombie Escape/AI.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local _module_1 = dora.Platformer.Decision -- 1
local Sel = _module_1.Sel -- 1
local Seq = _module_1.Seq -- 1
local Con = _module_1.Con -- 1
local Unit = _module_0.Unit -- 1
local Vec2 = dora.Vec2 -- 1
local Act = _module_1.Act -- 1
local Reject = _module_1.Reject -- 1
local math = _G.math -- 1
local Behave = _module_1.Behave -- 1
local AI = _module_1.AI -- 1
local App = dora.App -- 1
local Accept = _module_1.Accept -- 1
local Group = dora.Group -- 1
local BT = require("Platformer").Behavior -- 5
local Store = Data.store -- 7
local rangeAttack = Sel({ -- 10
	Seq({ -- 11
		Con("attack path blocked", function(self) -- 11
			local sensor = self:getSensorByTag(Unit.AttackSensorTag) -- 12
			if sensor.sensedBodies:each(function(body) -- 13
				return body.group == Data.groupTerrain and (self.x > body.x) ~= self.faceRight and body.tag == "Obstacle" -- 16
			end) then -- 13
				local faceObstacle = true -- 17
				local start = self.position -- 18
				local stop = Vec2(start.x + (self.faceRight and 1 or -1) * self.unitDef.attackRange.width, start.y) -- 19
				Store.world:raycast(start, stop, true, function(b) -- 20
					if b.group == Data.groupDetection then -- 21
						return false -- 21
					end -- 21
					if Data:isEnemy(self, b) then -- 22
						faceObstacle = false -- 22
					end -- 22
					return true -- 23
				end) -- 20
				return faceObstacle -- 24
			else -- 25
				return false -- 25
			end -- 13
		end), -- 11
		Act("jump"), -- 26
		Reject() -- 27
	}), -- 10
	Act("rangeAttack") -- 29
}) -- 9
local walk = Sel({ -- 33
	Seq({ -- 34
		Con("obstacles ahead", function(self) -- 34
			local start = self.position -- 35
			local stop = Vec2(start.x + (self.faceRight and 140 or -140), start.y) -- 36
			return Store.world:raycast(start, stop, false, function(b, p) -- 37
				if b.group == Data.groupTerrain and b.tag == "Obstacle" then -- 38
					self.data.obstacleDistance = math.abs(p.x - start.x) -- 39
					return true -- 40
				else -- 41
					return false -- 41
				end -- 38
			end) -- 41
		end), -- 34
		Sel({ -- 43
			Seq({ -- 44
				Con("obstacle distance <= 80", function(self) -- 44
					return self.data.obstacleDistance <= 80 -- 44
				end), -- 44
				Behave("backJump", BT.Seq({ -- 46
					BT.Act("turn"), -- 46
					BT.Countdown(0.3, BT.Act("walk")), -- 47
					BT.Act("turn"), -- 48
					BT.Countdown(0.1, BT.Act("walk")), -- 49
					BT.Act("jump") -- 50
				})) -- 45
			}), -- 43
			Seq({ -- 54
				Con("has forward speed", function(self) -- 54
					return math.abs(self.velocityX) > 0 -- 54
				end), -- 54
				Act("jump") -- 55
			}) -- 53
		}) -- 42
	}), -- 33
	Act("walk") -- 59
}) -- 32
local fightDecision = Seq({ -- 63
	Con("see enemy", function(self) -- 63
		return (AI:getNearestUnit("Enemy") ~= nil) -- 63
	end), -- 63
	Sel({ -- 65
		Seq({ -- 66
			Con("need evade", function(self) -- 66
				if not self:getAction("rangeAttack" or not self.onSurface) then -- 67
					return false -- 67
				end -- 67
				local evadeLeftEnemy = false -- 68
				local evadeRightEnemy = false -- 69
				local sensor = self:getSensorByTag(Unit.AttackSensorTag) -- 70
				sensor.sensedBodies:each(function(body) -- 71
					if Data:isEnemy(self, body) then -- 72
						local distance = math.abs(self.x - body.x) -- 73
						if distance < 80 then -- 74
							evadeRightEnemy = false -- 75
							evadeLeftEnemy = false -- 76
							return true -- 77
						elseif distance < 200 then -- 78
							if body.x > self.x then -- 79
								evadeRightEnemy = true -- 79
							end -- 79
							if body.x <= self.x then -- 80
								evadeLeftEnemy = true -- 80
							end -- 80
						end -- 74
					end -- 72
				end) -- 71
				local needEvade = not (evadeLeftEnemy == evadeRightEnemy) and math.abs(self.x) < 1000 -- 81
				if needEvade then -- 82
					self.data.evadeRight = evadeRightEnemy -- 82
				end -- 82
				return needEvade -- 83
			end), -- 66
			Sel({ -- 85
				Seq({ -- 86
					Con("face enemy", function(self) -- 86
						return self.data.evadeRight == self.faceRight -- 86
					end), -- 86
					Act("turn"), -- 87
					walk -- 88
				}), -- 85
				walk -- 90
			}) -- 84
		}), -- 65
		Seq({ -- 94
			Con("not facing nearest enemy", function(self) -- 94
				local enemy = AI:getNearestUnit("Enemy") -- 95
				return (self.x > enemy.x) == self.faceRight -- 96
			end), -- 94
			Act("turn") -- 97
		}), -- 93
		Seq({ -- 100
			Con("enemy in attack range", function(self) -- 100
				local enemy = AI:getNearestUnit("Enemy") -- 101
				local attackUnits = AI:getUnitsInAttackRange() -- 102
				return attackUnits and attackUnits:contains(enemy) or false -- 103
			end), -- 100
			Sel({ -- 105
				rangeAttack, -- 105
				Act("meleeAttack") -- 106
			}) -- 104
		}), -- 99
		Seq({ -- 110
			Con("wanna jump", function(self) -- 110
				return App.rand % 5 == 0 -- 110
			end), -- 110
			Act("jump") -- 111
		}), -- 109
		walk -- 113
	}) -- 64
}) -- 62
Store["AI_Zombie"] = Sel({ -- 118
	Seq({ -- 119
		Con("is dead", function(self) -- 119
			return self.entity.hp <= 0 -- 119
		end), -- 119
		Accept() -- 120
	}), -- 118
	Seq({ -- 123
		Con("not entered", function(self) -- 123
			return not self.data.entered -- 123
		end), -- 123
		Act("groundEntrance") -- 124
	}), -- 122
	fightDecision, -- 126
	Seq({ -- 128
		Con("need stop", function(self) -- 128
			return not self:isDoing("idle") -- 128
		end), -- 128
		Act("cancel"), -- 129
		Act("idle") -- 130
	}) -- 127
}) -- 117
local playerGroup = Group({ -- 134
	"player" -- 134
}) -- 134
Store["AI_KidFollow"] = Sel({ -- 137
	Seq({ -- 138
		Con("is dead", function(self) -- 138
			return self.entity.hp <= 0 -- 138
		end), -- 138
		Accept() -- 139
	}), -- 137
	fightDecision, -- 141
	Seq({ -- 143
		Con("is falling", function(self) -- 143
			return not self.onSurface -- 143
		end), -- 143
		Act("fallOff") -- 144
	}), -- 142
	Seq({ -- 147
		Con("follow target is away", function(self) -- 147
			local target = playerGroup:find(function(e) -- 148
				return e.unit ~= self -- 148
			end) -- 148
			if target then -- 148
				self.data.followTarget = target.unit -- 149
				return math.abs(self.x - target.unit.x) > 50 -- 150
			else -- 151
				return false -- 151
			end -- 148
		end), -- 147
		Sel({ -- 153
			Seq({ -- 154
				Con("not facing target", function(self) -- 154
					return (self.x > self.data.followTarget.x) == self.faceRight -- 154
				end), -- 154
				Act("turn") -- 155
			}), -- 153
			Accept() -- 157
		}), -- 152
		walk -- 159
	}), -- 146
	Seq({ -- 162
		Con("need stop", function(self) -- 162
			return not self:isDoing("idle") -- 162
		end), -- 162
		Act("cancel"), -- 163
		Act("idle") -- 164
	}) -- 161
}) -- 136
Store["AI_KidSearch"] = Sel({ -- 169
	Seq({ -- 170
		Con("is dead", function(self) -- 170
			return self.entity.hp <= 0 -- 170
		end), -- 170
		Accept() -- 171
	}), -- 169
	fightDecision, -- 173
	Seq({ -- 175
		Con("is falling", function(self) -- 175
			return not self.onSurface -- 175
		end), -- 175
		Act("fallOff") -- 176
	}), -- 174
	Seq({ -- 179
		Con("reach search limit", function(self) -- 179
			return math.abs(self.x) > 1150 and ((self.x > 0) == self.faceRight) -- 179
		end), -- 179
		Act("turn") -- 180
	}), -- 178
	Seq({ -- 183
		Con("continue search", function() -- 183
			return true -- 183
		end), -- 183
		walk -- 184
	}) -- 182
}) -- 168
Store["AI_PlayerControl"] = Sel({ -- 189
	Seq({ -- 190
		Con("is dead", function(self) -- 190
			return self.entity.hp <= 0 -- 190
		end), -- 190
		Accept() -- 191
	}), -- 189
	Seq({ -- 194
		Seq({ -- 195
			Con("move key down", function(self) -- 195
				return not (self.data.keyLeft and self.data.keyRight) and ((self.data.keyLeft and self.faceRight) or (self.data.keyRight and not self.faceRight)) -- 200
			end), -- 195
			Act("turn") -- 201
		}), -- 194
		Reject() -- 203
	}), -- 193
	Seq({ -- 206
		Con("attack key down", function(self) -- 206
			return self.data.keyShoot -- 206
		end), -- 206
		Sel({ -- 208
			Act("meleeAttack"), -- 208
			Act("rangeAttack") -- 209
		}) -- 207
	}), -- 205
	Sel({ -- 213
		Seq({ -- 214
			Con("is falling", function(self) -- 214
				return not self.onSurface -- 214
			end), -- 214
			Act("fallOff") -- 215
		}), -- 213
		Seq({ -- 218
			Con("jump key down", function(self) -- 218
				return self.data.keyUp -- 218
			end), -- 218
			Act("jump") -- 219
		}) -- 217
	}), -- 212
	Seq({ -- 223
		Con("move key down", function(self) -- 223
			return self.data.keyLeft or self.data.keyRight -- 223
		end), -- 223
		Act("walk") -- 224
	}), -- 222
	Seq({ -- 227
		Con("need stop", function(self) -- 227
			return not self:isDoing("idle") -- 227
		end), -- 227
		Act("cancel"), -- 228
		Act("idle") -- 229
	}) -- 226
}) -- 188
