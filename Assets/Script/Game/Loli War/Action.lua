-- [yue]: Action.yue
local _module_0 = Dora.Platformer -- 1
local Data = _module_0.Data -- 1
local UnitAction = _module_0.UnitAction -- 1
local once = Dora.once -- 1
local sleep = Dora.sleep -- 1
local Audio = Dora.Audio -- 1
local Group = Dora.Group -- 1
local Entity = Dora.Entity -- 1
local Vec2 = Dora.Vec2 -- 1
local emit = Dora.emit -- 1
local Bullet = _module_0.Bullet -- 1
local Store = Data.store -- 11
local LayerBunny, LayerBlock, GroupPlayerPoke, GroupEnemyPoke, GroupPlayer, GroupEnemy, MaxBunnies = Store.LayerBunny, Store.LayerBlock, Store.GroupPlayerPoke, Store.GroupEnemyPoke, Store.GroupPlayer, Store.GroupEnemy, Store.MaxBunnies -- 12
UnitAction:add("fallOff", { -- 23
	priority = 1, -- 23
	reaction = 0.1, -- 24
	recovery = 0, -- 25
	available = function(self) -- 26
		return not self.onSurface -- 26
	end, -- 26
	create = function(self) -- 27
		do -- 28
			local _with_0 = self.playable -- 28
			_with_0.speed = 1.5 -- 29
			_with_0:play("jump", true) -- 30
		end -- 28
		return function(self) -- 31
			return self.onSurface -- 31
		end -- 31
	end -- 27
}) -- 22
local pushSwitchEnd -- 33
pushSwitchEnd = function(name, playable) -- 33
	if "switch" == name or "attack" == name then -- 34
		return playable.parent:stop() -- 35
	end -- 35
end -- 33
UnitAction:add("pushSwitch", { -- 38
	priority = 4, -- 38
	reaction = 3, -- 39
	recovery = 0.2, -- 40
	queued = true, -- 41
	available = function(self) -- 42
		return self.onSurface -- 42
	end, -- 42
	create = function(self) -- 43
		do -- 44
			local _with_0 = self.playable -- 44
			_with_0.speed = 1.5 -- 45
			_with_0.look = "noweapon" -- 46
			_with_0:play("switch") -- 47
			if not _with_0.playing then -- 48
				_with_0:play("attack") -- 49
			end -- 48
			_with_0:slot("AnimationEnd", pushSwitchEnd) -- 50
		end -- 44
		do -- 51
			local _with_0 = self.data.atSwitch -- 51
			_with_0.data.pushed = true -- 52
			_with_0.data.fromRight = self.x > _with_0.x -- 53
		end -- 51
		return function() -- 54
			return false -- 54
		end -- 54
	end, -- 43
	stop = function(self) -- 55
		return self.playable:slot("AnimationEnd"):remove(pushSwitchEnd) -- 56
	end -- 55
}) -- 37
UnitAction:add("waitUser", { -- 59
	priority = 1, -- 59
	reaction = 0.1, -- 60
	recovery = 0.2, -- 61
	available = function() -- 62
		return true -- 62
	end, -- 62
	create = function(self) -- 63
		do -- 64
			local _with_0 = self.playable -- 64
			_with_0.speed = 1 -- 65
			_with_0:play("idle", true) -- 66
		end -- 64
		return function() -- 67
			return false -- 67
		end -- 67
	end -- 63
}) -- 58
local switchPushed -- 69
switchPushed = function(name, playable) -- 69
	if "pushRight" == name or "pushLeft" == name then -- 70
		return playable.parent:stop() -- 71
	end -- 71
end -- 69
local _anon_func_0 = function(GroupEnemy, GroupEnemyPoke, GroupPlayer, GroupPlayerPoke, LayerBlock, Vec2, self) -- 116
	local _with_0 = { } -- 110
	_with_0.layer = LayerBlock -- 111
	local _exp_0 = self.group -- 112
	if GroupPlayer == _exp_0 then -- 113
		_with_0.poke, _with_0.group, _with_0.position = "pokeb", GroupPlayerPoke, Vec2(192, 1004 - 512) -- 114
	elseif GroupEnemy == _exp_0 then -- 115
		_with_0.poke, _with_0.group, _with_0.position = "pokep", GroupEnemyPoke, Vec2(3904, 1004 - 512) -- 116
	end -- 116
	return _with_0 -- 110
end -- 110
UnitAction:add("pushed", { -- 74
	priority = 2, -- 74
	reaction = 0.1, -- 75
	recovery = 0.2, -- 76
	queued = true, -- 77
	available = function() -- 78
		return true -- 78
	end, -- 78
	create = function(self) -- 79
		do -- 80
			local _with_0 = self.playable -- 80
			_with_0.recovery = 0.2 -- 81
			_with_0.speed = 1.5 -- 82
			_with_0:play(self.data.fromRight and "pushLeft" or "pushRight") -- 83
			_with_0:slot("AnimationEnd", switchPushed) -- 84
		end -- 80
		return once(function(self) -- 85
			sleep(0.5) -- 86
			Audio:play("Audio/switch.wav") -- 87
			local heroes = Group({ -- 88
				"hero" -- 88
			}) -- 88
			do -- 89
				local _exp_0 = self.entity.switch -- 89
				if "Switch" == _exp_0 then -- 90
					heroes:each(function(hero) -- 91
						if self.group == hero.group and hero.ep >= 1 then -- 92
							Entity((function() -- 93
								local _with_0 = { } -- 93
								do -- 94
									local _exp_1 = self.group -- 94
									if GroupPlayer == _exp_1 then -- 95
										_with_0.bunny, _with_0.group, _with_0.faceRight, _with_0.position = "BunnyG", GroupPlayer, true, Vec2(1000, 1004 - 500) -- 96
									elseif GroupEnemy == _exp_1 then -- 97
										_with_0.bunny, _with_0.group, _with_0.faceRight, _with_0.position = "BunnyP", GroupEnemy, false, Vec2(3130, 1004 - 500) -- 98
									end -- 98
								end -- 98
								_with_0.AI = "BunnyForwardReturnAI" -- 99
								_with_0.layer = LayerBunny -- 100
								local bunnyCount = 0 -- 101
								Group({ -- 102
									"bunny" -- 102
								}):each(function(bunny) -- 102
									if bunny.group == self.group then -- 103
										bunnyCount = bunnyCount + 1 -- 103
									end -- 103
								end) -- 102
								if bunnyCount > MaxBunnies then -- 104
									_with_0.hp = 0.0 -- 104
								end -- 104
								return _with_0 -- 93
							end)()) -- 93
							emit("EPChange", self.group, -1) -- 105
							return true -- 106
						end -- 92
					end) -- 91
				elseif "SwitchG" == _exp_0 then -- 107
					heroes:each(function(hero) -- 108
						if self.group == hero.group and hero.ep >= 2 then -- 109
							Entity(_anon_func_0(GroupEnemy, GroupEnemyPoke, GroupPlayer, GroupPlayerPoke, LayerBlock, Vec2, self)) -- 110
							emit("EPChange", self.group, -2) -- 117
							return true -- 118
						end -- 109
					end) -- 108
				end -- 118
			end -- 118
			while true do -- 119
				sleep() -- 120
			end -- 120
		end) -- 120
	end, -- 79
	stop = function(self) -- 121
		self.data.pushed = false -- 122
		return self.playable:slot("AnimationEnd"):remove(pushSwitchEnd) -- 123
	end -- 121
}) -- 73
local strikeEnd -- 125
strikeEnd = function(name, playable) -- 125
	if name == "hit" then -- 126
		return playable.parent:stop() -- 126
	end -- 126
end -- 125
UnitAction:add("strike", { -- 129
	priority = 4, -- 129
	reaction = 3, -- 130
	recovery = 0, -- 131
	queued = true, -- 132
	available = function() -- 133
		return true -- 133
	end, -- 133
	create = function(self) -- 134
		do -- 135
			local _with_0 = self.playable -- 135
			_with_0.speed = 1 -- 136
			_with_0.look = "fail" -- 137
			_with_0:play("hit") -- 138
			_with_0:slot("AnimationEnd", strikeEnd) -- 139
		end -- 135
		Audio:play("Audio/hit.wav") -- 140
		return function() -- 141
			return false -- 141
		end -- 141
	end, -- 134
	stop = function(self) -- 142
		return self.playable:slot("AnimationEnd"):remove(strikeEnd) -- 143
	end -- 142
}) -- 128
local villyAttackEnd -- 145
villyAttackEnd = function(name, playable) -- 145
	if name == "attack" then -- 146
		return playable.parent:stop() -- 146
	end -- 146
end -- 145
UnitAction:add("villyAttack", { -- 149
	priority = 3, -- 149
	reaction = 10, -- 150
	recovery = 0.1, -- 151
	queued = true, -- 152
	available = function() -- 153
		return true -- 153
	end, -- 153
	create = function(self) -- 154
		local attackSpeed, targetAllow, damageType, attackBase, attackBonus, attackFactor, attackPower -- 155
		do -- 155
			local _obj_0 = self.entity -- 163
			attackSpeed, targetAllow, damageType, attackBase, attackBonus, attackFactor, attackPower = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor, _obj_0.attackPower -- 155
		end -- 163
		do -- 164
			local _with_0 = self.playable -- 164
			_with_0.speed = attackSpeed -- 165
			_with_0.look = "fight" -- 166
			_with_0:play("attack") -- 167
			_with_0:slot("AnimationEnd", villyAttackEnd) -- 168
		end -- 164
		return once(function(self) -- 169
			local bulletDef = Store[self.unitDef.bulletType] -- 170
			local onAttack -- 171
			onAttack = function() -- 171
				Audio:play("Audio/v_att.wav") -- 172
				local _with_0 = Bullet(bulletDef, self) -- 173
				_with_0.targetAllow = targetAllow -- 174
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 175
					do -- 176
						local _with_1 = target.data -- 176
						_with_1.hitPoint = pos -- 177
						_with_1.hitPower = attackPower -- 178
						_with_1.hitFromRight = bullet.velocityX < 0 -- 179
					end -- 176
					local entity = target.entity -- 180
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 181
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 182
					entity.hp = entity.hp - damage -- 183
					bullet.hitStop = true -- 184
				end) -- 175
				_with_0:addTo(self.world, self.order) -- 185
				return _with_0 -- 173
			end -- 171
			sleep(0.17 / attackSpeed) -- 186
			onAttack() -- 187
			sleep(0.63 / attackSpeed) -- 188
			onAttack() -- 189
			sleep(1.0) -- 190
			return true -- 191
		end) -- 191
	end, -- 154
	stop = function(self) -- 192
		return self.playable:slot("AnimationEnd"):remove(villyAttackEnd) -- 193
	end -- 192
}) -- 148
return UnitAction:add("wait", { -- 196
	priority = 1, -- 196
	reaction = 0.1, -- 197
	recovery = 0, -- 198
	available = function(self) -- 199
		return self.onSurface -- 199
	end, -- 199
	create = function(self) -- 200
		do -- 201
			local _with_0 = self.playable -- 201
			_with_0.speed = 1 -- 202
			_with_0.look = Store.winner == self.group and "happy" or "fail" -- 203
			_with_0:play("idle", true) -- 204
		end -- 201
		return function(self) -- 205
			if not self.onSurface then -- 206
				return true -- 207
			end -- 206
			return false -- 208
		end -- 208
	end -- 200
}) -- 208
