-- [yue]: Script/Game/Loli War/AI.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Group = dora.Group -- 1
local _module_1 = dora.Platformer.Decision -- 1
local Seq = _module_1.Seq -- 1
local Con = _module_1.Con -- 1
local Sel = _module_1.Sel -- 1
local Act = _module_1.Act -- 1
local Accept = _module_1.Accept -- 1
local Reject = _module_1.Reject -- 1
local AI = _module_1.AI -- 1
local App = dora.App -- 1
local math = _G.math -- 1
local Store = Data.store -- 14
local MaxBunnies, GroupPlayer, GroupEnemyPoke = Store.MaxBunnies, Store.GroupPlayer, Store.GroupEnemyPoke -- 15
local heroes = Group({ -- 21
	"hero" -- 21
}) -- 21
local gameEndWait = Seq({ -- 24
	Con("game end", function(self) -- 24
		return (Store.winner ~= nil) -- 24
	end), -- 24
	Sel({ -- 26
		Seq({ -- 27
			Con("need wait", function(self) -- 27
				return self.onSurface and not self:isDoing("wait") -- 27
			end), -- 27
			Act("cancel"), -- 28
			Act("wait") -- 29
		}), -- 26
		Accept() -- 31
	}) -- 25
}) -- 23
Store["PlayerControlAI"] = Sel({ -- 36
	Seq({ -- 37
		Con("is dead", function(self) -- 37
			return self.entity.hp <= 0 -- 37
		end), -- 37
		Accept() -- 38
	}), -- 36
	Seq({ -- 41
		Con("pushing switch", function(self) -- 41
			return self:isDoing("pushSwitch") -- 41
		end), -- 41
		Accept() -- 42
	}), -- 40
	Seq({ -- 45
		Seq({ -- 46
			Con("move key down", function(self) -- 46
				return not (self.data.keyLeft and self.data.keyRight) and ((self.data.keyLeft and self.faceRight) or (self.data.keyRight and not self.faceRight)) -- 51
			end), -- 46
			Act("turn") -- 52
		}), -- 45
		Reject() -- 54
	}), -- 44
	Seq({ -- 57
		Con("attack key down", function(self) -- 57
			return Store.winner == nil and self.data.keyF -- 57
		end), -- 57
		Sel({ -- 59
			Seq({ -- 60
				Con("at switch", function(self) -- 60
					local theSwitch = self.data.atSwitch -- 61
					return (theSwitch ~= nil) and not theSwitch.data.pushed and ((self.x < theSwitch.x) == self.faceRight) -- 63
				end), -- 60
				Act("pushSwitch") -- 64
			}), -- 59
			Act("villyAttack"), -- 66
			Act("meleeAttack"), -- 67
			Act("rangeAttack") -- 68
		}) -- 58
	}), -- 56
	Sel({ -- 72
		Seq({ -- 73
			Con("is falling", function(self) -- 73
				return not self.onSurface -- 73
			end), -- 73
			Act("fallOff") -- 74
		}), -- 72
		Seq({ -- 77
			Con("jump key down", function(self) -- 77
				return self.data.keyUp -- 77
			end), -- 77
			Act("jump") -- 78
		}) -- 76
	}), -- 71
	Seq({ -- 82
		Con("move key down", function(self) -- 82
			return self.data.keyLeft or self.data.keyRight -- 82
		end), -- 82
		Act("walk") -- 83
	}), -- 81
	Act("idle") -- 85
}) -- 35
Store["HeroAI"] = Sel({ -- 89
	Seq({ -- 90
		Con("is dead", function(self) -- 90
			return self.entity.hp <= 0 -- 90
		end), -- 90
		Accept() -- 91
	}), -- 89
	Seq({ -- 94
		Con("is falling", function(self) -- 94
			return not self.onSurface -- 94
		end), -- 94
		Act("fallOff") -- 95
	}), -- 93
	gameEndWait, -- 97
	Seq({ -- 99
		Con("need attack", function(self) -- 99
			local attackUnits = AI:getUnitsInAttackRange() -- 100
			for _index_0 = 1, #attackUnits do -- 101
				local unit = attackUnits[_index_0] -- 101
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 102
					return true -- 104
				end -- 102
			end -- 104
			return false -- 105
		end), -- 99
		Sel({ -- 107
			Act("villyAttack"), -- 107
			Act("rangeAttack"), -- 108
			Act("meleeAttack") -- 109
		}) -- 106
	}), -- 98
	Seq({ -- 113
		Con("not facing enemy", function(self) -- 113
			return heroes:each(function(hero) -- 113
				local unit = hero.unit -- 114
				if Data:isEnemy(unit, self) then -- 115
					if (self.x > unit.x) == self.faceRight then -- 116
						return true -- 117
					end -- 116
				end -- 115
			end) -- 117
		end), -- 113
		Act("turn") -- 118
	}), -- 112
	Seq({ -- 121
		Con("need turn", function(self) -- 121
			return (self.x < 100 and not self.faceRight) or (self.x > 3990 and self.faceRight) -- 122
		end), -- 121
		Act("turn") -- 123
	}), -- 120
	Seq({ -- 126
		Con("wanna jump", function(self) -- 126
			return App.rand % 20 == 0 -- 126
		end), -- 126
		Act("jump") -- 127
	}), -- 125
	Seq({ -- 130
		Con("is at enemy side", function(self) -- 130
			return heroes:each(function(hero) -- 130
				local unit = hero.unit -- 131
				if Data:isEnemy(unit, self) then -- 132
					if math.abs(self.x - unit.x) < 50 then -- 133
						return true -- 134
					end -- 133
				end -- 132
			end) -- 134
		end), -- 130
		Act("idle") -- 135
	}), -- 129
	Act("walk") -- 137
}) -- 88
Store["BunnyForwardReturnAI"] = Sel({ -- 141
	Seq({ -- 142
		Con("is dead", function(self) -- 142
			return self.entity.hp <= 0 -- 142
		end), -- 142
		Accept() -- 143
	}), -- 141
	Seq({ -- 146
		Con("is falling", function(self) -- 146
			return not self.onSurface -- 146
		end), -- 146
		Act("fallOff") -- 147
	}), -- 145
	gameEndWait, -- 149
	Seq({ -- 151
		Con("need attack", function(self) -- 151
			local attackUnits = AI:getUnitsInAttackRange() -- 152
			for _index_0 = 1, #attackUnits do -- 153
				local unit = attackUnits[_index_0] -- 153
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 154
					return App.rand % 5 ~= 0 -- 156
				end -- 154
			end -- 156
			return false -- 157
		end), -- 151
		Act("meleeAttack") -- 158
	}), -- 150
	Seq({ -- 161
		Con("need turn", function(self) -- 161
			return (self.x < 100 and not self.faceRight) or (self.x > 3990 and self.faceRight) -- 162
		end), -- 161
		Act("turn") -- 163
	}), -- 160
	Act("walk") -- 165
}) -- 140
Store["SwitchAI"] = Sel({ -- 169
	Seq({ -- 170
		Con("is pushed", function(self) -- 170
			return self.data.pushed -- 170
		end), -- 170
		Act("pushed") -- 171
	}), -- 169
	Act("waitUser") -- 173
}) -- 168
local switches = Group({ -- 176
	"switch" -- 176
}) -- 176
local turnToSwitch = Seq({ -- 178
	Con("go to switch", function(self) -- 178
		return switches:each(function(item) -- 178
			if item.group == self.group and self.entity and self.entity.targetSwitch == item.switch then -- 179
				return (self.x > item.unit.x) == self.faceRight -- 180
			end -- 179
		end) -- 180
	end), -- 178
	Act("turn"), -- 181
	Reject() -- 182
}) -- 177
Store["BunnySwitcherAI"] = Sel({ -- 185
	Seq({ -- 186
		Con("is dead", function(self) -- 186
			return self.entity.hp <= 0 -- 186
		end), -- 186
		Accept() -- 187
	}), -- 185
	Seq({ -- 190
		Con("is falling", function(self) -- 190
			return not self.onSurface -- 190
		end), -- 190
		Act("fallOff") -- 191
	}), -- 189
	gameEndWait, -- 193
	Seq({ -- 195
		Con("need attack", function(self) -- 195
			local attackUnits = AI:getUnitsInAttackRange() -- 196
			for _index_0 = 1, #attackUnits do -- 197
				local unit = attackUnits[_index_0] -- 197
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 198
					return App.rand % 5 ~= 0 -- 200
				end -- 198
			end -- 200
			return false -- 201
		end), -- 195
		Act("meleeAttack") -- 202
	}), -- 194
	Seq({ -- 205
		Con("at switch", function(self) -- 205
			local _with_0 = self.data -- 205
			return (_with_0.atSwitch ~= nil) and _with_0.atSwitch.entity.switch == self.entity.targetSwitch -- 206
		end), -- 205
		Sel({ -- 208
			Seq({ -- 209
				Con("switch available", function(self) -- 209
					return heroes:each(function(hero) -- 209
						if self.group ~= hero.group then -- 210
							return false -- 210
						end -- 210
						local needEP, available -- 211
						do -- 211
							local _exp_0 = self.entity.targetSwitch -- 211
							if "Switch" == _exp_0 then -- 212
								local bunnyCount = 0 -- 213
								Group({ -- 214
									"bunny" -- 214
								}):each(function(bunny) -- 214
									if bunny.group == self.group then -- 215
										bunnyCount = bunnyCount + 1 -- 215
									end -- 215
								end) -- 214
								needEP, available = 1, bunnyCount < MaxBunnies -- 216
							elseif "SwitchG" == _exp_0 then -- 217
								needEP, available = 2, hero.defending -- 218
							end -- 218
						end -- 218
						if hero.ep >= needEP and available then -- 219
							if not self.data.atSwitch:isDoing("pushed") then -- 220
								if self.entity.targetSwitch == "SwitchG" then -- 221
									hero.defending = false -- 221
								end -- 221
								return true -- 222
							end -- 220
						end -- 219
						return false -- 223
					end) -- 223
				end), -- 209
				Act("pushSwitch") -- 224
			}), -- 208
			turnToSwitch, -- 226
			Act("idle") -- 227
		}) -- 207
	}), -- 204
	Seq({ -- 231
		Con("need turn", function(self) -- 231
			return (self.x < 100 and not self.faceRight) or (self.x > 3990 and self.faceRight) -- 232
		end), -- 231
		Act("turn") -- 233
	}), -- 230
	turnToSwitch, -- 235
	Act("walk") -- 236
}) -- 184
