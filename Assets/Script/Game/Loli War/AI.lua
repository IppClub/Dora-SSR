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
local Store = Data.store -- 6
local MaxBunnies, GroupPlayer, GroupEnemyPoke = Store.MaxBunnies, Store.GroupPlayer, Store.GroupEnemyPoke -- 7
local heroes = Group({ -- 13
	"hero" -- 13
}) -- 13
local gameEndWait = Seq({ -- 16
	Con("game end", function(self) -- 16
		return (Store.winner ~= nil) -- 16
	end), -- 16
	Sel({ -- 18
		Seq({ -- 19
			Con("need wait", function(self) -- 19
				return self.onSurface and not self:isDoing("wait") -- 19
			end), -- 19
			Act("cancel"), -- 20
			Act("wait") -- 21
		}), -- 18
		Accept() -- 23
	}) -- 17
}) -- 15
Store["PlayerControlAI"] = Sel({ -- 28
	Seq({ -- 29
		Con("is dead", function(self) -- 29
			return self.entity.hp <= 0 -- 29
		end), -- 29
		Accept() -- 30
	}), -- 28
	Seq({ -- 33
		Con("pushing switch", function(self) -- 33
			return self:isDoing("pushSwitch") -- 33
		end), -- 33
		Accept() -- 34
	}), -- 32
	Seq({ -- 37
		Seq({ -- 38
			Con("move key down", function(self) -- 38
				return not (self.data.keyLeft and self.data.keyRight) and ((self.data.keyLeft and self.faceRight) or (self.data.keyRight and not self.faceRight)) -- 43
			end), -- 38
			Act("turn") -- 44
		}), -- 37
		Reject() -- 46
	}), -- 36
	Seq({ -- 49
		Con("attack key down", function(self) -- 49
			return Store.winner == nil and self.data.keyF -- 49
		end), -- 49
		Sel({ -- 51
			Seq({ -- 52
				Con("at switch", function(self) -- 52
					local theSwitch = self.data.atSwitch -- 53
					return (theSwitch ~= nil) and not theSwitch.data.pushed and ((self.x < theSwitch.x) == self.faceRight) -- 55
				end), -- 52
				Act("pushSwitch") -- 56
			}), -- 51
			Act("villyAttack"), -- 58
			Act("meleeAttack"), -- 59
			Act("rangeAttack") -- 60
		}) -- 50
	}), -- 48
	Sel({ -- 64
		Seq({ -- 65
			Con("is falling", function(self) -- 65
				return not self.onSurface -- 65
			end), -- 65
			Act("fallOff") -- 66
		}), -- 64
		Seq({ -- 69
			Con("jump key down", function(self) -- 69
				return self.data.keyUp -- 69
			end), -- 69
			Act("jump") -- 70
		}) -- 68
	}), -- 63
	Seq({ -- 74
		Con("move key down", function(self) -- 74
			return self.data.keyLeft or self.data.keyRight -- 74
		end), -- 74
		Act("walk") -- 75
	}), -- 73
	Act("idle") -- 77
}) -- 27
Store["HeroAI"] = Sel({ -- 81
	Seq({ -- 82
		Con("is dead", function(self) -- 82
			return self.entity.hp <= 0 -- 82
		end), -- 82
		Accept() -- 83
	}), -- 81
	Seq({ -- 86
		Con("is falling", function(self) -- 86
			return not self.onSurface -- 86
		end), -- 86
		Act("fallOff") -- 87
	}), -- 85
	gameEndWait, -- 89
	Seq({ -- 91
		Con("need attack", function(self) -- 91
			local attackUnits = AI:getUnitsInAttackRange() -- 92
			for _index_0 = 1, #attackUnits do -- 93
				local unit = attackUnits[_index_0] -- 93
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 94
					return true -- 96
				end -- 94
			end -- 96
			return false -- 97
		end), -- 91
		Sel({ -- 99
			Act("villyAttack"), -- 99
			Act("rangeAttack"), -- 100
			Act("meleeAttack") -- 101
		}) -- 98
	}), -- 90
	Seq({ -- 105
		Con("not facing enemy", function(self) -- 105
			return heroes:each(function(hero) -- 105
				local unit = hero.unit -- 106
				if Data:isEnemy(unit, self) then -- 107
					if (self.x > unit.x) == self.faceRight then -- 108
						return true -- 109
					end -- 108
				end -- 107
			end) -- 109
		end), -- 105
		Act("turn") -- 110
	}), -- 104
	Seq({ -- 113
		Con("need turn", function(self) -- 113
			return (self.x < 100 and not self.faceRight) or (self.x > 3990 and self.faceRight) -- 114
		end), -- 113
		Act("turn") -- 115
	}), -- 112
	Seq({ -- 118
		Con("wanna jump", function(self) -- 118
			return App.rand % 20 == 0 -- 118
		end), -- 118
		Act("jump") -- 119
	}), -- 117
	Seq({ -- 122
		Con("is at enemy side", function(self) -- 122
			return heroes:each(function(hero) -- 122
				local unit = hero.unit -- 123
				if Data:isEnemy(unit, self) then -- 124
					if math.abs(self.x - unit.x) < 50 then -- 125
						return true -- 126
					end -- 125
				end -- 124
			end) -- 126
		end), -- 122
		Act("idle") -- 127
	}), -- 121
	Act("walk") -- 129
}) -- 80
Store["BunnyForwardReturnAI"] = Sel({ -- 133
	Seq({ -- 134
		Con("is dead", function(self) -- 134
			return self.entity.hp <= 0 -- 134
		end), -- 134
		Accept() -- 135
	}), -- 133
	Seq({ -- 138
		Con("is falling", function(self) -- 138
			return not self.onSurface -- 138
		end), -- 138
		Act("fallOff") -- 139
	}), -- 137
	gameEndWait, -- 141
	Seq({ -- 143
		Con("need attack", function(self) -- 143
			local attackUnits = AI:getUnitsInAttackRange() -- 144
			for _index_0 = 1, #attackUnits do -- 145
				local unit = attackUnits[_index_0] -- 145
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 146
					return App.rand % 5 ~= 0 -- 148
				end -- 146
			end -- 148
			return false -- 149
		end), -- 143
		Act("meleeAttack") -- 150
	}), -- 142
	Seq({ -- 153
		Con("need turn", function(self) -- 153
			return (self.x < 100 and not self.faceRight) or (self.x > 3990 and self.faceRight) -- 154
		end), -- 153
		Act("turn") -- 155
	}), -- 152
	Act("walk") -- 157
}) -- 132
Store["SwitchAI"] = Sel({ -- 161
	Seq({ -- 162
		Con("is pushed", function(self) -- 162
			return self.data.pushed -- 162
		end), -- 162
		Act("pushed") -- 163
	}), -- 161
	Act("waitUser") -- 165
}) -- 160
local switches = Group({ -- 168
	"switch" -- 168
}) -- 168
local turnToSwitch = Seq({ -- 170
	Con("go to switch", function(self) -- 170
		return switches:each(function(item) -- 170
			if item.group == self.group and self.entity and self.entity.targetSwitch == item.switch then -- 171
				return (self.x > item.unit.x) == self.faceRight -- 172
			end -- 171
		end) -- 172
	end), -- 170
	Act("turn"), -- 173
	Reject() -- 174
}) -- 169
Store["BunnySwitcherAI"] = Sel({ -- 177
	Seq({ -- 178
		Con("is dead", function(self) -- 178
			return self.entity.hp <= 0 -- 178
		end), -- 178
		Accept() -- 179
	}), -- 177
	Seq({ -- 182
		Con("is falling", function(self) -- 182
			return not self.onSurface -- 182
		end), -- 182
		Act("fallOff") -- 183
	}), -- 181
	gameEndWait, -- 185
	Seq({ -- 187
		Con("need attack", function(self) -- 187
			local attackUnits = AI:getUnitsInAttackRange() -- 188
			for _index_0 = 1, #attackUnits do -- 189
				local unit = attackUnits[_index_0] -- 189
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 190
					return App.rand % 5 ~= 0 -- 192
				end -- 190
			end -- 192
			return false -- 193
		end), -- 187
		Act("meleeAttack") -- 194
	}), -- 186
	Seq({ -- 197
		Con("at switch", function(self) -- 197
			local _with_0 = self.data -- 197
			return (_with_0.atSwitch ~= nil) and _with_0.atSwitch.entity.switch == self.entity.targetSwitch -- 198
		end), -- 197
		Sel({ -- 200
			Seq({ -- 201
				Con("switch available", function(self) -- 201
					return heroes:each(function(hero) -- 201
						if self.group ~= hero.group then -- 202
							return false -- 202
						end -- 202
						local needEP, available -- 203
						do -- 203
							local _exp_0 = self.entity.targetSwitch -- 203
							if "Switch" == _exp_0 then -- 204
								local bunnyCount = 0 -- 205
								Group({ -- 206
									"bunny" -- 206
								}):each(function(bunny) -- 206
									if bunny.group == self.group then -- 207
										bunnyCount = bunnyCount + 1 -- 207
									end -- 207
								end) -- 206
								needEP, available = 1, bunnyCount < MaxBunnies -- 208
							elseif "SwitchG" == _exp_0 then -- 209
								needEP, available = 2, hero.defending -- 210
							end -- 210
						end -- 210
						if hero.ep >= needEP and available then -- 211
							if not self.data.atSwitch:isDoing("pushed") then -- 212
								if self.entity.targetSwitch == "SwitchG" then -- 213
									hero.defending = false -- 213
								end -- 213
								return true -- 214
							end -- 212
						end -- 211
						return false -- 215
					end) -- 215
				end), -- 201
				Act("pushSwitch") -- 216
			}), -- 200
			turnToSwitch, -- 218
			Act("idle") -- 219
		}) -- 199
	}), -- 196
	Seq({ -- 223
		Con("need turn", function(self) -- 223
			return (self.x < 100 and not self.faceRight) or (self.x > 3990 and self.faceRight) -- 224
		end), -- 223
		Act("turn") -- 225
	}), -- 222
	turnToSwitch, -- 227
	Act("walk") -- 228
}) -- 176
