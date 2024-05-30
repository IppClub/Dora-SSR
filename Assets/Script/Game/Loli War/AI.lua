-- [yue]: AI.yue
local _module_0 = Dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Group = Dora.Group -- 1
local _module_1 = Dora.Platformer.Decision -- 1
local Seq = _module_1.Seq -- 1
local Con = _module_1.Con -- 1
local Sel = _module_1.Sel -- 1
local Act = _module_1.Act -- 1
local Accept = _module_1.Accept -- 1
local Reject = _module_1.Reject -- 1
local AI = _module_1.AI -- 1
local App = Dora.App -- 1
local math = _G.math -- 1
local Store = Data.store -- 14
local MaxBunnies = Store.MaxBunnies -- 15
local heroes = Group({ -- 19
	"hero" -- 19
}) -- 19
local gameEndWait = Seq({ -- 22
	Con("game end", function() -- 22
		return (Store.winner ~= nil) -- 22
	end), -- 22
	Sel({ -- 24
		Seq({ -- 25
			Con("need wait", function(self) -- 25
				return self.onSurface and not self:isDoing("wait") -- 25
			end), -- 25
			Act("cancel"), -- 26
			Act("wait") -- 27
		}), -- 24
		Accept() -- 29
	}) -- 23
}) -- 21
Store["PlayerControlAI"] = Sel({ -- 34
	Seq({ -- 35
		Con("is dead", function(self) -- 35
			return self.entity.hp <= 0 -- 35
		end), -- 35
		Accept() -- 36
	}), -- 34
	Seq({ -- 39
		Con("pushing switch", function(self) -- 39
			return self:isDoing("pushSwitch") -- 39
		end), -- 39
		Accept() -- 40
	}), -- 38
	Seq({ -- 43
		Seq({ -- 44
			Con("move key down", function(self) -- 44
				return not (self.data.keyLeft and self.data.keyRight) and ((self.data.keyLeft and self.faceRight) or (self.data.keyRight and not self.faceRight)) -- 49
			end), -- 44
			Act("turn") -- 50
		}), -- 43
		Reject() -- 52
	}), -- 42
	Seq({ -- 55
		Con("attack key down", function(self) -- 55
			return Store.winner == nil and self.data.keyF -- 55
		end), -- 55
		Sel({ -- 57
			Seq({ -- 58
				Con("at switch", function(self) -- 58
					local theSwitch = self.data.atSwitch -- 59
					return (theSwitch ~= nil) and not theSwitch.data.pushed and ((self.x < theSwitch.x) == self.faceRight) -- 61
				end), -- 58
				Act("pushSwitch") -- 62
			}), -- 57
			Act("villyAttack"), -- 64
			Act("meleeAttack"), -- 65
			Act("rangeAttack") -- 66
		}) -- 56
	}), -- 54
	Sel({ -- 70
		Seq({ -- 71
			Con("is falling", function(self) -- 71
				return not self.onSurface -- 71
			end), -- 71
			Act("fallOff") -- 72
		}), -- 70
		Seq({ -- 75
			Con("jump key down", function(self) -- 75
				return self.data.keyUp -- 75
			end), -- 75
			Act("jump") -- 76
		}) -- 74
	}), -- 69
	Seq({ -- 80
		Con("move key down", function(self) -- 80
			return self.data.keyLeft or self.data.keyRight -- 80
		end), -- 80
		Act("walk") -- 81
	}), -- 79
	Act("idle") -- 83
}) -- 33
Store["HeroAI"] = Sel({ -- 87
	Seq({ -- 88
		Con("is dead", function(self) -- 88
			return self.entity.hp <= 0 -- 88
		end), -- 88
		Accept() -- 89
	}), -- 87
	Seq({ -- 92
		Con("is falling", function(self) -- 92
			return not self.onSurface -- 92
		end), -- 92
		Act("fallOff") -- 93
	}), -- 91
	gameEndWait, -- 95
	Seq({ -- 97
		Con("need attack", function(self) -- 97
			local attackUnits = AI:getUnitsInAttackRange() -- 98
			for _index_0 = 1, #attackUnits do -- 99
				local unit = attackUnits[_index_0] -- 99
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 100
					return true -- 102
				end -- 100
			end -- 102
			return false -- 103
		end), -- 97
		Sel({ -- 105
			Act("villyAttack"), -- 105
			Act("rangeAttack"), -- 106
			Act("meleeAttack") -- 107
		}) -- 104
	}), -- 96
	Seq({ -- 111
		Con("not facing enemy", function(self) -- 111
			return heroes:each(function(hero) -- 111
				local unit = hero.unit -- 112
				if Data:isEnemy(unit, self) then -- 113
					if (self.x > unit.x) == self.faceRight then -- 114
						return true -- 115
					end -- 114
				end -- 113
			end) -- 115
		end), -- 111
		Act("turn") -- 116
	}), -- 110
	Seq({ -- 119
		Con("need turn", function(self) -- 119
			return (self.x < 100 and not self.faceRight) or (self.x > 3990 and self.faceRight) -- 120
		end), -- 119
		Act("turn") -- 121
	}), -- 118
	Seq({ -- 124
		Con("wanna jump", function() -- 124
			return App.rand % 20 == 0 -- 124
		end), -- 124
		Act("jump") -- 125
	}), -- 123
	Seq({ -- 128
		Con("is at enemy side", function(self) -- 128
			return heroes:each(function(hero) -- 128
				local unit = hero.unit -- 129
				if Data:isEnemy(unit, self) then -- 130
					if math.abs(self.x - unit.x) < 50 then -- 131
						return true -- 132
					end -- 131
				end -- 130
			end) -- 132
		end), -- 128
		Act("idle") -- 133
	}), -- 127
	Act("walk") -- 135
}) -- 86
Store["BunnyForwardReturnAI"] = Sel({ -- 139
	Seq({ -- 140
		Con("is dead", function(self) -- 140
			return self.entity.hp <= 0 -- 140
		end), -- 140
		Accept() -- 141
	}), -- 139
	Seq({ -- 144
		Con("is falling", function(self) -- 144
			return not self.onSurface -- 144
		end), -- 144
		Act("fallOff") -- 145
	}), -- 143
	gameEndWait, -- 147
	Seq({ -- 149
		Con("need attack", function(self) -- 149
			local attackUnits = AI:getUnitsInAttackRange() -- 150
			for _index_0 = 1, #attackUnits do -- 151
				local unit = attackUnits[_index_0] -- 151
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 152
					return App.rand % 5 ~= 0 -- 154
				end -- 152
			end -- 154
			return false -- 155
		end), -- 149
		Act("meleeAttack") -- 156
	}), -- 148
	Seq({ -- 159
		Con("need turn", function(self) -- 159
			return (self.x < 100 and not self.faceRight) or (self.x > 3990 and self.faceRight) -- 160
		end), -- 159
		Act("turn") -- 161
	}), -- 158
	Act("walk") -- 163
}) -- 138
Store["SwitchAI"] = Sel({ -- 167
	Seq({ -- 168
		Con("is pushed", function(self) -- 168
			return self.data.pushed -- 168
		end), -- 168
		Act("pushed") -- 169
	}), -- 167
	Act("waitUser") -- 171
}) -- 166
local switches = Group({ -- 174
	"switch" -- 174
}) -- 174
local turnToSwitch = Seq({ -- 176
	Con("go to switch", function(self) -- 176
		return switches:each(function(item) -- 176
			if item.group == self.group and self.entity and self.entity.targetSwitch == item.switch then -- 177
				return (self.x > item.unit.x) == self.faceRight -- 178
			end -- 177
		end) -- 178
	end), -- 176
	Act("turn"), -- 179
	Reject() -- 180
}) -- 175
Store["BunnySwitcherAI"] = Sel({ -- 183
	Seq({ -- 184
		Con("is dead", function(self) -- 184
			return self.entity.hp <= 0 -- 184
		end), -- 184
		Accept() -- 185
	}), -- 183
	Seq({ -- 188
		Con("is falling", function(self) -- 188
			return not self.onSurface -- 188
		end), -- 188
		Act("fallOff") -- 189
	}), -- 187
	gameEndWait, -- 191
	Seq({ -- 193
		Con("need attack", function(self) -- 193
			local attackUnits = AI:getUnitsInAttackRange() -- 194
			for _index_0 = 1, #attackUnits do -- 195
				local unit = attackUnits[_index_0] -- 195
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 196
					return App.rand % 5 ~= 0 -- 198
				end -- 196
			end -- 198
			return false -- 199
		end), -- 193
		Act("meleeAttack") -- 200
	}), -- 192
	Seq({ -- 203
		Con("at switch", function(self) -- 203
			local _with_0 = self.data -- 203
			return (_with_0.atSwitch ~= nil) and _with_0.atSwitch.entity.switch == self.entity.targetSwitch -- 204
		end), -- 203
		Sel({ -- 206
			Seq({ -- 207
				Con("switch available", function(self) -- 207
					return heroes:each(function(hero) -- 207
						if self.group ~= hero.group then -- 208
							return false -- 208
						end -- 208
						local needEP, available -- 209
						do -- 209
							local _exp_0 = self.entity.targetSwitch -- 209
							if "Switch" == _exp_0 then -- 210
								local bunnyCount = 0 -- 211
								Group({ -- 212
									"bunny" -- 212
								}):each(function(bunny) -- 212
									if bunny.group == self.group then -- 213
										bunnyCount = bunnyCount + 1 -- 213
									end -- 213
								end) -- 212
								needEP, available = 1, bunnyCount < MaxBunnies -- 214
							elseif "SwitchG" == _exp_0 then -- 215
								needEP, available = 2, hero.defending -- 216
							end -- 216
						end -- 216
						if hero.ep >= needEP and available then -- 217
							if not self.data.atSwitch:isDoing("pushed") then -- 218
								if self.entity.targetSwitch == "SwitchG" then -- 219
									hero.defending = false -- 219
								end -- 219
								return true -- 220
							end -- 218
						end -- 217
						return false -- 221
					end) -- 221
				end), -- 207
				Act("pushSwitch") -- 222
			}), -- 206
			turnToSwitch, -- 224
			Act("idle") -- 225
		}) -- 205
	}), -- 202
	Seq({ -- 229
		Con("need turn", function(self) -- 229
			return (self.x < 100 and not self.faceRight) or (self.x > 3990 and self.faceRight) -- 230
		end), -- 229
		Act("turn") -- 231
	}), -- 228
	turnToSwitch, -- 233
	Act("walk") -- 234
}) -- 182
