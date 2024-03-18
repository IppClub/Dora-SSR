-- [yue]: Script/Game/Loli War/Action.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local UnitAction = _module_0.UnitAction -- 1
local once = dora.once -- 1
local sleep = dora.sleep -- 1
local Audio = dora.Audio -- 1
local Group = dora.Group -- 1
local Entity = dora.Entity -- 1
local Vec2 = dora.Vec2 -- 1
local emit = dora.emit -- 1
local Bullet = _module_0.Bullet -- 1
local Store = Data.store -- 3
local LayerBunny, LayerBlock, GroupPlayerPoke, GroupEnemyPoke, GroupPlayer, GroupEnemy, MaxBunnies = Store.LayerBunny, Store.LayerBlock, Store.GroupPlayerPoke, Store.GroupEnemyPoke, Store.GroupPlayer, Store.GroupEnemy, Store.MaxBunnies -- 4
UnitAction:add("fallOff", { -- 15
	priority = 1, -- 15
	reaction = 0.1, -- 16
	recovery = 0, -- 17
	available = function(self) -- 18
		return not self.onSurface -- 18
	end, -- 18
	create = function(self) -- 19
		do -- 20
			local _with_0 = self.playable -- 20
			_with_0.speed = 1.5 -- 21
			_with_0:play("jump", true) -- 22
		end -- 20
		return function(self) -- 23
			return self.onSurface -- 23
		end -- 23
	end -- 19
}) -- 14
local pushSwitchEnd -- 25
pushSwitchEnd = function(name, playable) -- 25
	if "switch" == name or "attack" == name then -- 26
		return playable.parent:stop() -- 27
	end -- 27
end -- 25
UnitAction:add("pushSwitch", { -- 30
	priority = 4, -- 30
	reaction = 3, -- 31
	recovery = 0.2, -- 32
	queued = true, -- 33
	available = function(self) -- 34
		return self.onSurface -- 34
	end, -- 34
	create = function(self) -- 35
		do -- 36
			local _with_0 = self.playable -- 36
			_with_0.speed = 1.5 -- 37
			_with_0.look = "noweapon" -- 38
			_with_0:play("switch") -- 39
			if not _with_0.playing then -- 40
				_with_0:play("attack") -- 41
			end -- 40
			_with_0:slot("AnimationEnd", pushSwitchEnd) -- 42
		end -- 36
		do -- 43
			local _with_0 = self.data.atSwitch -- 43
			_with_0.data.pushed = true -- 44
			_with_0.data.fromRight = self.x > _with_0.x -- 45
		end -- 43
		return function() -- 46
			return false -- 46
		end -- 46
	end, -- 35
	stop = function(self) -- 47
		return self.playable:slot("AnimationEnd"):remove(pushSwitchEnd) -- 48
	end -- 47
}) -- 29
UnitAction:add("waitUser", { -- 51
	priority = 1, -- 51
	reaction = 0.1, -- 52
	recovery = 0.2, -- 53
	available = function() -- 54
		return true -- 54
	end, -- 54
	create = function(self) -- 55
		do -- 56
			local _with_0 = self.playable -- 56
			_with_0.speed = 1 -- 57
			_with_0:play("idle", true) -- 58
		end -- 56
		return function() -- 59
			return false -- 59
		end -- 59
	end -- 55
}) -- 50
local switchPushed -- 61
switchPushed = function(name, playable) -- 61
	if "pushRight" == name or "pushLeft" == name then -- 62
		return playable.parent:stop() -- 63
	end -- 63
end -- 61
local _anon_func_0 = function(LayerBlock, self, GroupPlayer, GroupPlayerPoke, Vec2, GroupEnemy, GroupEnemyPoke) -- 108
	local _with_0 = { } -- 102
	_with_0.layer = LayerBlock -- 103
	do -- 104
		local _exp_0 = self.group -- 104
		if GroupPlayer == _exp_0 then -- 105
			_with_0.poke, _with_0.group, _with_0.position = "pokeb", GroupPlayerPoke, Vec2(192, 1004 - 512) -- 106
		elseif GroupEnemy == _exp_0 then -- 107
			_with_0.poke, _with_0.group, _with_0.position = "pokep", GroupEnemyPoke, Vec2(3904, 1004 - 512) -- 108
		end -- 108
	end -- 108
	return _with_0 -- 102
end -- 102
UnitAction:add("pushed", { -- 66
	priority = 2, -- 66
	reaction = 0.1, -- 67
	recovery = 0.2, -- 68
	queued = true, -- 69
	available = function() -- 70
		return true -- 70
	end, -- 70
	create = function(self) -- 71
		do -- 72
			local _with_0 = self.playable -- 72
			_with_0.recovery = 0.2 -- 73
			_with_0.speed = 1.5 -- 74
			_with_0:play(self.data.fromRight and "pushLeft" or "pushRight") -- 75
			_with_0:slot("AnimationEnd", switchPushed) -- 76
		end -- 72
		return once(function(self) -- 77
			sleep(0.5) -- 78
			Audio:play("Audio/switch.wav") -- 79
			local heroes = Group({ -- 80
				"hero" -- 80
			}) -- 80
			do -- 81
				local _exp_0 = self.entity.switch -- 81
				if "Switch" == _exp_0 then -- 82
					heroes:each(function(hero) -- 83
						if self.group == hero.group and hero.ep >= 1 then -- 84
							Entity((function() -- 85
								local _with_0 = { } -- 85
								do -- 86
									local _exp_1 = self.group -- 86
									if GroupPlayer == _exp_1 then -- 87
										_with_0.bunny, _with_0.group, _with_0.faceRight, _with_0.position = "BunnyG", GroupPlayer, true, Vec2(1000, 1004 - 500) -- 88
									elseif GroupEnemy == _exp_1 then -- 89
										_with_0.bunny, _with_0.group, _with_0.faceRight, _with_0.position = "BunnyP", GroupEnemy, false, Vec2(3130, 1004 - 500) -- 90
									end -- 90
								end -- 90
								_with_0.AI = "BunnyForwardReturnAI" -- 91
								_with_0.layer = LayerBunny -- 92
								local bunnyCount = 0 -- 93
								Group({ -- 94
									"bunny" -- 94
								}):each(function(bunny) -- 94
									if bunny.group == self.group then -- 95
										bunnyCount = bunnyCount + 1 -- 95
									end -- 95
								end) -- 94
								if bunnyCount > MaxBunnies then -- 96
									_with_0.hp = 0.0 -- 96
								end -- 96
								return _with_0 -- 85
							end)()) -- 85
							emit("EPChange", self.group, -1) -- 97
							return true -- 98
						end -- 84
					end) -- 83
				elseif "SwitchG" == _exp_0 then -- 99
					heroes:each(function(hero) -- 100
						if self.group == hero.group and hero.ep >= 2 then -- 101
							Entity(_anon_func_0(LayerBlock, self, GroupPlayer, GroupPlayerPoke, Vec2, GroupEnemy, GroupEnemyPoke)) -- 102
							emit("EPChange", self.group, -2) -- 109
							return true -- 110
						end -- 101
					end) -- 100
				end -- 110
			end -- 110
			while true do -- 111
				sleep() -- 112
			end -- 112
		end) -- 112
	end, -- 71
	stop = function(self) -- 113
		self.data.pushed = false -- 114
		return self.playable:slot("AnimationEnd"):remove(pushSwitchEnd) -- 115
	end -- 113
}) -- 65
local strikeEnd -- 117
strikeEnd = function(name, playable) -- 117
	if name == "hit" then -- 118
		return playable.parent:stop() -- 118
	end -- 118
end -- 117
UnitAction:add("strike", { -- 121
	priority = 4, -- 121
	reaction = 3, -- 122
	recovery = 0, -- 123
	queued = true, -- 124
	available = function(self) -- 125
		return true -- 125
	end, -- 125
	create = function(self) -- 126
		do -- 127
			local _with_0 = self.playable -- 127
			_with_0.speed = 1 -- 128
			_with_0.look = "fail" -- 129
			_with_0:play("hit") -- 130
			_with_0:slot("AnimationEnd", strikeEnd) -- 131
		end -- 127
		Audio:play("Audio/hit.wav") -- 132
		return function() -- 133
			return false -- 133
		end -- 133
	end, -- 126
	stop = function(self) -- 134
		return self.playable:slot("AnimationEnd"):remove(strikeEnd) -- 135
	end -- 134
}) -- 120
local villyAttackEnd -- 137
villyAttackEnd = function(name, playable) -- 137
	if name == "attack" then -- 138
		return playable.parent:stop() -- 138
	end -- 138
end -- 137
UnitAction:add("villyAttack", { -- 141
	priority = 3, -- 141
	reaction = 10, -- 142
	recovery = 0.1, -- 143
	queued = true, -- 144
	available = function(self) -- 145
		return true -- 145
	end, -- 145
	create = function(self) -- 146
		local attackSpeed, targetAllow, damageType, attackBase, attackBonus, attackFactor, attackPower -- 147
		do -- 147
			local _obj_0 = self.entity -- 155
			attackSpeed, targetAllow, damageType, attackBase, attackBonus, attackFactor, attackPower = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor, _obj_0.attackPower -- 147
		end -- 155
		do -- 156
			local _with_0 = self.playable -- 156
			_with_0.speed = attackSpeed -- 157
			_with_0.look = "fight" -- 158
			_with_0:play("attack") -- 159
			_with_0:slot("AnimationEnd", villyAttackEnd) -- 160
		end -- 156
		return once(function(self) -- 161
			local bulletDef = Store[self.unitDef.bulletType] -- 162
			local onAttack -- 163
			onAttack = function() -- 163
				Audio:play("Audio/v_att.wav") -- 164
				local _with_0 = Bullet(bulletDef, self) -- 165
				_with_0.targetAllow = targetAllow -- 166
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 167
					do -- 168
						local _with_1 = target.data -- 168
						_with_1.hitPoint = pos -- 169
						_with_1.hitPower = attackPower -- 170
						_with_1.hitFromRight = bullet.velocityX < 0 -- 171
					end -- 168
					local entity = target.entity -- 172
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 173
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 174
					entity.hp = entity.hp - damage -- 175
					bullet.hitStop = true -- 176
				end) -- 167
				_with_0:addTo(self.world, self.order) -- 177
				return _with_0 -- 165
			end -- 163
			sleep(0.17 / attackSpeed) -- 178
			onAttack() -- 179
			sleep(0.63 / attackSpeed) -- 180
			onAttack() -- 181
			sleep(1.0) -- 182
			return true -- 183
		end) -- 183
	end, -- 146
	stop = function(self) -- 184
		return self.playable:slot("AnimationEnd"):remove(villyAttackEnd) -- 185
	end -- 184
}) -- 140
return UnitAction:add("wait", { -- 188
	priority = 1, -- 188
	reaction = 0.1, -- 189
	recovery = 0, -- 190
	available = function(self) -- 191
		return self.onSurface -- 191
	end, -- 191
	create = function(self) -- 192
		do -- 193
			local _with_0 = self.playable -- 193
			_with_0.speed = 1 -- 194
			_with_0.look = Store.winner == self.group and "happy" or "fail" -- 195
			_with_0:play("idle", true) -- 196
		end -- 193
		return function(self) -- 197
			if not self.onSurface then -- 198
				return true -- 199
			end -- 198
			return false -- 200
		end -- 200
	end -- 192
}) -- 200
