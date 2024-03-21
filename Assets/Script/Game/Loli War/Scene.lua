-- [yue]: Script/Game/Loli War/Scene.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Class = dora.Class -- 1
local PlatformWorld = _module_0.PlatformWorld -- 1
local Entity = dora.Entity -- 1
local View = dora.View -- 1
local BodyDef = dora.BodyDef -- 1
local Vec2 = dora.Vec2 -- 1
local Body = dora.Body -- 1
local Sprite = dora.Sprite -- 1
local Node = dora.Node -- 1
local Visual = _module_0.Visual -- 1
local tostring = _G.tostring -- 1
local Group = dora.Group -- 1
local emit = dora.emit -- 1
local _module_0 = nil -- 1
local Store = Data.store -- 3
local GroupPlayer, GroupEnemy, GroupPlayerBlock, GroupEnemyBlock, GroupTerrain, GroupDisplay, LayerReadMe, LayerBlock, LayerBunny, LayerSwitch, LayerPlayerHero, LayerEnemyHero, LayerBackground = Store.GroupPlayer, Store.GroupEnemy, Store.GroupPlayerBlock, Store.GroupEnemyBlock, Store.GroupTerrain, Store.GroupDisplay, Store.LayerReadMe, Store.LayerBlock, Store.LayerBunny, Store.LayerSwitch, Store.LayerPlayerHero, Store.LayerEnemyHero, Store.LayerBackground -- 4
local _anon_func_0 = function(Body, GroupTerrain, LayerBackground, Vec2, self, terrainDef) -- 38
	local _with_0 = Body(terrainDef, self, Vec2.zero) -- 36
	_with_0.order = LayerBackground -- 37
	_with_0.group = GroupTerrain -- 38
	return _with_0 -- 36
end -- 36
local _anon_func_1 = function(LayerBackground, Sprite, Vec2) -- 45
	local _with_0 = Sprite("Model/items.clip|background") -- 40
	_with_0.order = LayerBackground -- 41
	_with_0.anchor = Vec2.zero -- 42
	_with_0.scaleX = 4146 / _with_0.width -- 43
	_with_0.scaleY = 1600 / _with_0.height -- 44
	_with_0.y = -50 -- 45
	return _with_0 -- 40
end -- 40
local _anon_func_3 = function(Sprite, _with_0, i) -- 55
	local _with_1 = Sprite("Model/misc.clip|floor") -- 51
	_with_1.scaleX = 8 -- 52
	_with_1.scaleY = 8 -- 53
	_with_1.x = i * 128 -- 54
	_with_1.filter = "Point" -- 55
	return _with_1 -- 51
end -- 51
local _anon_func_2 = function(LayerBackground, Node, Sprite) -- 55
	local _with_0 = Node() -- 47
	_with_0.order = LayerBackground -- 48
	_with_0.y = -44 -- 49
	for i = 0, 32 do -- 50
		_with_0:addChild(_anon_func_3(Sprite, _with_0, i)) -- 51
	end -- 55
	return _with_0 -- 47
end -- 47
local _anon_func_4 = function(GroupEnemy, GroupPlayer, LayerBunny, Vec2, group) -- 211
	local _with_0 = { } -- 204
	_with_0.group = group -- 205
	if GroupPlayer == group then -- 207
		_with_0.bunny, _with_0.faceRight, _with_0.position = "BunnyG", false, Vec2(216, 500) -- 207
	elseif GroupEnemy == group then -- 208
		_with_0.bunny, _with_0.faceRight, _with_0.position = "BunnyP", true, Vec2(3877, 500) -- 208
	end -- 208
	_with_0.AI = "BunnySwitcherAI" -- 209
	_with_0.layer = LayerBunny -- 210
	_with_0.targetSwitch = "SwitchG" -- 211
	return _with_0 -- 204
end -- 204
local _anon_func_5 = function(GroupEnemy, GroupPlayer, LayerBunny, Vec2, group) -- 220
	local _with_0 = { } -- 213
	_with_0.group = group -- 214
	if GroupPlayer == group then -- 216
		_with_0.bunny, _with_0.faceRight, _with_0.position = "BunnyG", true, Vec2(677, 500) -- 216
	elseif GroupEnemy == group then -- 217
		_with_0.bunny, _with_0.faceRight, _with_0.position = "BunnyP", false, Vec2(3431, 500) -- 217
	end -- 217
	_with_0.AI = "BunnySwitcherAI" -- 218
	_with_0.layer = LayerBunny -- 219
	_with_0.targetSwitch = "Switch" -- 220
	return _with_0 -- 213
end -- 213
local GameWorld = Class(PlatformWorld, { -- 21
	__init = function(self) -- 21
		Entity({ -- 22
			world = self -- 22
		}) -- 22
		local DesignWidth <const> = 1024 -- 23
		self.camera.zoom = View.size.width / DesignWidth -- 24
		return self:gslot("AppSizeChanged", function() -- 25
			self.camera.zoom = View.size.width / DesignWidth -- 26
		end) -- 26
	end, -- 21
	buildBackground = function(self) -- 28
		local terrainDef -- 29
		do -- 29
			local _with_0 = BodyDef() -- 29
			_with_0.type = "Static" -- 30
			_with_0:attachPolygon(Vec2(2048, 1004 - 994), 4096, 10) -- 31
			_with_0:attachPolygon(Vec2(2048, 1004), 4096, 10) -- 32
			_with_0:attachPolygon(Vec2(-5, 1004 - 512), 10, 1024) -- 33
			_with_0:attachPolygon(Vec2(4101, 1004 - 512), 10, 1024) -- 34
			terrainDef = _with_0 -- 29
		end -- 29
		self:addChild(_anon_func_0(Body, GroupTerrain, LayerBackground, Vec2, self, terrainDef)) -- 36
		self:addChild(_anon_func_1(LayerBackground, Sprite, Vec2)) -- 40
		return self:addChild(_anon_func_2(LayerBackground, Node, Sprite)) -- 55
	end, -- 28
	buildGameReadme = function(self) -- 57
		local pos = self.camera.position -- 58
		local readmeDef -- 59
		do -- 59
			local _with_0 = BodyDef() -- 59
			_with_0.type = "Static" -- 60
			_with_0:attachPolygon(Vec2(pos.x, 1004 - 994), 1024, 10) -- 61
			_with_0:attachPolygon(Vec2(pos.x, 1004), 1024, 10) -- 62
			_with_0:attachPolygon(Vec2(pos.x - 512, 1004 - 512), 10, 1024) -- 63
			_with_0:attachPolygon(Vec2(pos.x + 512, 1004 - 512), 10, 1024) -- 64
			readmeDef = _with_0 -- 59
		end -- 59
		local readme -- 66
		do -- 66
			local _with_0 = Body(readmeDef, self, Vec2.zero) -- 66
			_with_0.order = LayerBackground -- 67
			_with_0.group = GroupDisplay -- 68
			_with_0:addTo(self) -- 69
			_with_0:gslot("PlayerSelect", function() -- 70
				_with_0.children:each(function(child) -- 71
					local _with_1 = Visual("Particle/heart.par") -- 72
					_with_1.position = child:convertToWorldSpace(Vec2.zero) -- 73
					_with_1:autoRemove() -- 74
					_with_1:start() -- 75
					return _with_1 -- 72
				end) -- 71
				return _with_0:removeFromParent() -- 76
			end) -- 70
			readme = _with_0 -- 66
		end -- 66
		local _list_0 = { -- 79
			{ -- 79
				"war", -- 79
				Vec2(pos.x - 512 + 369, 1004 - 413 - 200) -- 79
			}, -- 79
			{ -- 80
				"use", -- 80
				Vec2(pos.x - 512 + 459, 1004 - 575 - 200) -- 80
			}, -- 80
			{ -- 81
				"key", -- 81
				Vec2(pos.x - 512 + 521, 1004 - 499 - 200) -- 81
			}, -- 81
			{ -- 82
				"loli", -- 82
				Vec2(pos.x - 512 + 655, 1004 - 423 - 200) -- 82
			}, -- 82
			{ -- 83
				"select", -- 83
				Vec2(pos.x - 512 + 709, 1004 - 509 - 200) -- 83
			}, -- 83
			{ -- 84
				"mosic", -- 84
				Vec2(pos.x - 512 + 599, 1004 - 339 - 200) -- 84
			}, -- 84
			{ -- 85
				"breakblocks", -- 85
				Vec2(pos.x - 512 + 578, 1004 - 626 - 200) -- 85
			}, -- 85
			{ -- 86
				"search", -- 86
				Vec2(pos.x - 512 + 746, 1004 - 604 - 200) -- 86
			}, -- 86
			{ -- 87
				"quit", -- 87
				Vec2(pos.x - 512 + 363, 1004 - 566 - 200) -- 87
			}, -- 87
			{ -- 88
				"pushSwitch", -- 88
				Vec2(pos.x - 512 + 494, 1004 - 631 - 200) -- 88
			}, -- 88
			{ -- 89
				"attack", -- 89
				Vec2(pos.x - 512 + 630, 1004 - 631 - 200) -- 89
			} -- 89
		} -- 78
		for _index_0 = 1, #_list_0 do -- 90
			local item = _list_0[_index_0] -- 78
			local sp -- 91
			do -- 91
				local _with_0 = Sprite("Model/misc.clip|" .. tostring(item[1])) -- 91
				_with_0.scaleX = 2 -- 92
				_with_0.scaleY = 2 -- 93
				_with_0.filter = "Point" -- 94
				sp = _with_0 -- 91
			end -- 91
			local rectDef -- 95
			do -- 95
				local _with_0 = BodyDef() -- 95
				_with_0.linearAcceleration = Vec2(0, -10) -- 96
				_with_0.type = "Dynamic" -- 97
				_with_0:attachPolygon(sp.width * 2, sp.height * 2, 1, 0, 1) -- 98
				rectDef = _with_0 -- 95
			end -- 95
			local _with_0 = Body(rectDef, self, item[2]) -- 99
			_with_0.order = LayerBackground -- 100
			_with_0.group = GroupDisplay -- 101
			_with_0:addChild(sp) -- 102
			_with_0:addTo(readme) -- 103
		end -- 103
	end, -- 57
	buildCastles = function(self) -- 105
		local Block -- 106
		Block = function(block, group, look, x, y) -- 106
			return Entity({ -- 108
				block = "Block" .. tostring(block), -- 108
				group = group, -- 109
				layer = LayerBlock, -- 110
				look = look, -- 111
				position = Vec2(x, y) -- 112
			}) -- 112
		end -- 106
		Block("C", GroupPlayerBlock, "gray", 419, 1004 - 280) -- 115
		Block("A", GroupPlayerBlock, "green", 239, 1004 - 190) -- 116
		Block("A", GroupPlayerBlock, "green", 419, 1004 - 190) -- 117
		Block("A", GroupPlayerBlock, "green", 599, 1004 - 190) -- 118
		Block("C", GroupPlayerBlock, "gray", 419, 1004 - 580) -- 119
		Block("B", GroupPlayerBlock, "", 291, 1004 - 430) -- 120
		Block("B", GroupPlayerBlock, "", 416, 1004 - 430) -- 121
		Block("B", GroupPlayerBlock, "", 540, 1004 - 430) -- 122
		Block("A", GroupPlayerBlock, "gray", 239, 1004 - 670) -- 123
		Block("A", GroupPlayerBlock, "gray", 599, 1004 - 670) -- 124
		Block("A", GroupPlayerBlock, "blue", 239, 1004 - 760) -- 125
		Block("A", GroupPlayerBlock, "blue", 599, 1004 - 760) -- 126
		Block("A", GroupPlayerBlock, "red", 239, 1004 - 850) -- 127
		Block("A", GroupPlayerBlock, "red", 599, 1004 - 850) -- 128
		Block("C", GroupPlayerBlock, "jade", 419, 1004 - 940) -- 129
		Block("C", GroupPlayerBlock, "jade", 1074, 1004 - 552) -- 132
		Block("C", GroupPlayerBlock, "jade", 1074, 1004 - 731) -- 133
		Block("A", GroupPlayerBlock, "blue", 894, 1004 - 463) -- 134
		Block("A", GroupPlayerBlock, "blue", 1075, 1004 - 463) -- 135
		Block("A", GroupPlayerBlock, "blue", 1254, 1004 - 463) -- 136
		Block("A", GroupPlayerBlock, "green", 956, 1004 - 642) -- 137
		Block("A", GroupPlayerBlock, "green", 1194, 1004 - 642) -- 138
		Block("B", GroupPlayerBlock, "", 893, 1004 - 881) -- 139
		Block("B", GroupPlayerBlock, "", 1254, 1004 - 881) -- 140
		Block("C", GroupEnemyBlock, "gray", 3674, 1004 - 281) -- 143
		Block("A", GroupEnemyBlock, "green", 3494, 1004 - 191) -- 144
		Block("A", GroupEnemyBlock, "green", 3674, 1004 - 191) -- 145
		Block("A", GroupEnemyBlock, "green", 3854, 1004 - 191) -- 146
		Block("C", GroupEnemyBlock, "gray", 3674, 1004 - 581) -- 147
		Block("B", GroupEnemyBlock, "", 3546, 1004 - 431) -- 148
		Block("B", GroupEnemyBlock, "", 3671, 1004 - 431) -- 149
		Block("B", GroupEnemyBlock, "", 3795, 1004 - 431) -- 150
		Block("A", GroupEnemyBlock, "gray", 3494, 1004 - 671) -- 151
		Block("A", GroupEnemyBlock, "gray", 3854, 1004 - 671) -- 152
		Block("A", GroupEnemyBlock, "blue", 3494, 1004 - 761) -- 153
		Block("A", GroupEnemyBlock, "blue", 3854, 1004 - 761) -- 154
		Block("A", GroupEnemyBlock, "red", 3494, 1004 - 851) -- 155
		Block("A", GroupEnemyBlock, "red", 3854, 1004 - 851) -- 156
		Block("C", GroupEnemyBlock, "jade", 3674, 1004 - 941) -- 157
		Block("C", GroupEnemyBlock, "jade", 3024, 1004 - 552) -- 160
		Block("C", GroupEnemyBlock, "jade", 3024, 1004 - 731) -- 161
		Block("A", GroupEnemyBlock, "blue", 2844, 1004 - 463) -- 162
		Block("A", GroupEnemyBlock, "blue", 3025, 1004 - 463) -- 163
		Block("A", GroupEnemyBlock, "blue", 3204, 1004 - 463) -- 164
		Block("A", GroupEnemyBlock, "green", 2906, 1004 - 642) -- 165
		Block("A", GroupEnemyBlock, "green", 3144, 1004 - 642) -- 166
		Block("B", GroupEnemyBlock, "", 2843, 1004 - 881) -- 167
		Block("B", GroupEnemyBlock, "", 3204, 1004 - 881) -- 168
		local playerBlockHP = 0 -- 170
		local enemyBlockHP = 0 -- 171
		do -- 172
			local _with_0 = Group({ -- 172
				"block" -- 172
			}) -- 172
			_with_0:each(function(self) -- 173
				local _exp_0 = self.group -- 173
				if GroupPlayerBlock == _exp_0 then -- 174
					playerBlockHP = playerBlockHP + Store[self.block].hp -- 175
				elseif GroupEnemyBlock == _exp_0 then -- 176
					enemyBlockHP = enemyBlockHP + Store[self.block].hp -- 177
				end -- 177
			end) -- 173
		end -- 172
		emit("BlockValue", GroupPlayer, playerBlockHP) -- 178
		return emit("BlockValue", GroupEnemy, enemyBlockHP) -- 179
	end, -- 105
	buildSwitches = function(self) -- 181
		local Switch -- 182
		Switch = function(switchType, group, look, x, y) -- 182
			return Entity({ -- 184
				switch = switchType, -- 184
				group = group, -- 185
				look = look, -- 186
				layer = LayerSwitch, -- 187
				position = Vec2(x, y) -- 188
			}) -- 188
		end -- 182
		Switch("Switch", GroupPlayer, "normal", 777, 1004 - 923) -- 189
		Switch("SwitchG", GroupPlayer, "gold", 116, 1004 - 923) -- 190
		Switch("Switch", GroupEnemy, "normal", 3331, 1004 - 923) -- 191
		return Switch("SwitchG", GroupEnemy, "gold", 3977, 1004 - 923) -- 192
	end, -- 181
	addBunnySwither = function(self, group) -- 194
		local switchGExist = false -- 195
		local switchNExist = false -- 196
		local bunnySwitchers = Group({ -- 197
			"bunny", -- 197
			"targetSwitch" -- 197
		}) -- 197
		bunnySwitchers:each(function(switcher) -- 198
			if switcher.group == group then -- 199
				local _exp_0 = switcher.targetSwitch -- 200
				if "SwitchG" == _exp_0 then -- 201
					switchGExist = true -- 201
				elseif "Switch" == _exp_0 then -- 202
					switchNExist = true -- 202
				end -- 202
			end -- 199
		end) -- 198
		if not switchGExist then -- 203
			Entity(_anon_func_4(GroupEnemy, GroupPlayer, LayerBunny, Vec2, group)) -- 204
		end -- 203
		if not switchNExist then -- 212
			return Entity(_anon_func_5(GroupEnemy, GroupPlayer, LayerBunny, Vec2, group)) -- 220
		end -- 212
	end, -- 194
	clearScene = function(self) -- 222
		self:removeLayer(LayerBlock) -- 223
		self:removeLayer(LayerBunny) -- 224
		self:removeLayer(LayerPlayerHero) -- 225
		return self:removeLayer(LayerEnemyHero) -- 226
	end -- 222
}) -- 20
_module_0 = GameWorld() -- 228
return _module_0 -- 228
