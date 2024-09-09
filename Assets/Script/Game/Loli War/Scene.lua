-- [yue]: Scene.yue
local _module_0 = Dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Class = Dora.Class -- 1
local PlatformWorld = _module_0.PlatformWorld -- 1
local Entity = Dora.Entity -- 1
local View = Dora.View -- 1
local BodyDef = Dora.BodyDef -- 1
local Vec2 = Dora.Vec2 -- 1
local Body = Dora.Body -- 1
local Sprite = Dora.Sprite -- 1
local Node = Dora.Node -- 1
local Visual = _module_0.Visual -- 1
local tostring = _G.tostring -- 1
local Group = Dora.Group -- 1
local emit = Dora.emit -- 1
local _module_0 = nil -- 1
local Store = Data.store -- 11
local GroupPlayer, GroupEnemy, GroupPlayerBlock, GroupEnemyBlock, GroupTerrain, GroupDisplay, LayerBlock, LayerBunny, LayerSwitch, LayerPlayerHero, LayerEnemyHero, LayerBackground = Store.GroupPlayer, Store.GroupEnemy, Store.GroupPlayerBlock, Store.GroupEnemyBlock, Store.GroupTerrain, Store.GroupDisplay, Store.LayerBlock, Store.LayerBunny, Store.LayerSwitch, Store.LayerPlayerHero, Store.LayerEnemyHero, Store.LayerBackground -- 12
local _anon_func_0 = function(Body, GroupTerrain, LayerBackground, Vec2, self, terrainDef) -- 45
	local _with_0 = Body(terrainDef, self, Vec2.zero) -- 43
	_with_0.order = LayerBackground -- 44
	_with_0.group = GroupTerrain -- 45
	return _with_0 -- 43
end -- 43
local _anon_func_1 = function(LayerBackground, Sprite, Vec2) -- 52
	local _with_0 = Sprite("Model/items.clip|background") -- 47
	_with_0.order = LayerBackground -- 48
	_with_0.anchor = Vec2.zero -- 49
	_with_0.scaleX = 4146 / _with_0.width -- 50
	_with_0.scaleY = 1600 / _with_0.height -- 51
	_with_0.y = -50 -- 52
	return _with_0 -- 47
end -- 47
local _anon_func_3 = function(Sprite, _with_0, i) -- 62
	local _with_1 = Sprite("Model/misc.clip|floor") -- 58
	_with_1.scaleX = 8 -- 59
	_with_1.scaleY = 8 -- 60
	_with_1.x = i * 128 -- 61
	_with_1.filter = "Point" -- 62
	return _with_1 -- 58
end -- 58
local _anon_func_2 = function(LayerBackground, Node, Sprite) -- 62
	local _with_0 = Node() -- 54
	_with_0.order = LayerBackground -- 55
	_with_0.y = -44 -- 56
	for i = 0, 32 do -- 57
		_with_0:addChild(_anon_func_3(Sprite, _with_0, i)) -- 58
	end -- 62
	return _with_0 -- 54
end -- 54
local _anon_func_4 = function(GroupEnemy, GroupPlayer, LayerBunny, Vec2, group) -- 218
	local _with_0 = { } -- 211
	_with_0.group = group -- 212
	if GroupPlayer == group then -- 214
		_with_0.bunny, _with_0.faceRight, _with_0.position = "BunnyG", false, Vec2(216, 500) -- 214
	elseif GroupEnemy == group then -- 215
		_with_0.bunny, _with_0.faceRight, _with_0.position = "BunnyP", true, Vec2(3877, 500) -- 215
	end -- 215
	_with_0.AI = "BunnySwitcherAI" -- 216
	_with_0.layer = LayerBunny -- 217
	_with_0.targetSwitch = "SwitchG" -- 218
	return _with_0 -- 211
end -- 211
local _anon_func_5 = function(GroupEnemy, GroupPlayer, LayerBunny, Vec2, group) -- 227
	local _with_0 = { } -- 220
	_with_0.group = group -- 221
	if GroupPlayer == group then -- 223
		_with_0.bunny, _with_0.faceRight, _with_0.position = "BunnyG", true, Vec2(677, 500) -- 223
	elseif GroupEnemy == group then -- 224
		_with_0.bunny, _with_0.faceRight, _with_0.position = "BunnyP", false, Vec2(3431, 500) -- 224
	end -- 224
	_with_0.AI = "BunnySwitcherAI" -- 225
	_with_0.layer = LayerBunny -- 226
	_with_0.targetSwitch = "Switch" -- 227
	return _with_0 -- 220
end -- 220
local GameWorld = Class(PlatformWorld, { -- 28
	__init = function(self) -- 28
		Entity({ -- 29
			world = self -- 29
		}) -- 29
		local DesignWidth <const> = 1024 -- 30
		self.camera.zoom = View.size.width / DesignWidth -- 31
		return self:onAppChange(function(settingName) -- 32
			if settingName == "Size" then -- 32
				self.camera.zoom = View.size.width / DesignWidth -- 33
			end -- 32
		end) -- 33
	end, -- 28
	buildBackground = function(self) -- 35
		local terrainDef -- 36
		do -- 36
			local _with_0 = BodyDef() -- 36
			_with_0.type = "Static" -- 37
			_with_0:attachPolygon(Vec2(2048, 1004 - 994), 4096, 10) -- 38
			_with_0:attachPolygon(Vec2(2048, 1004), 4096, 10) -- 39
			_with_0:attachPolygon(Vec2(-5, 1004 - 512), 10, 1024) -- 40
			_with_0:attachPolygon(Vec2(4101, 1004 - 512), 10, 1024) -- 41
			terrainDef = _with_0 -- 36
		end -- 36
		self:addChild(_anon_func_0(Body, GroupTerrain, LayerBackground, Vec2, self, terrainDef)) -- 43
		self:addChild(_anon_func_1(LayerBackground, Sprite, Vec2)) -- 47
		return self:addChild(_anon_func_2(LayerBackground, Node, Sprite)) -- 62
	end, -- 35
	buildGameReadme = function(self) -- 64
		local pos = self.camera.position -- 65
		local readmeDef -- 66
		do -- 66
			local _with_0 = BodyDef() -- 66
			_with_0.type = "Static" -- 67
			_with_0:attachPolygon(Vec2(pos.x, 1004 - 994), 1024, 10) -- 68
			_with_0:attachPolygon(Vec2(pos.x, 1004), 1024, 10) -- 69
			_with_0:attachPolygon(Vec2(pos.x - 512, 1004 - 512), 10, 1024) -- 70
			_with_0:attachPolygon(Vec2(pos.x + 512, 1004 - 512), 10, 1024) -- 71
			readmeDef = _with_0 -- 66
		end -- 66
		local readme -- 73
		do -- 73
			local _with_0 = Body(readmeDef, self, Vec2.zero) -- 73
			_with_0.order = LayerBackground -- 74
			_with_0.group = GroupDisplay -- 75
			_with_0:addTo(self) -- 76
			_with_0:gslot("PlayerSelect", function() -- 77
				_with_0.children:each(function(child) -- 78
					local _with_1 = Visual("Particle/heart.par") -- 79
					_with_1.position = child:convertToWorldSpace(Vec2.zero) -- 80
					_with_1:autoRemove() -- 81
					_with_1:start() -- 82
					return _with_1 -- 79
				end) -- 78
				return _with_0:removeFromParent() -- 83
			end) -- 77
			readme = _with_0 -- 73
		end -- 73
		local _list_0 = { -- 86
			{ -- 86
				"war", -- 86
				Vec2(pos.x - 512 + 369, 1004 - 413 - 200) -- 86
			}, -- 86
			{ -- 87
				"use", -- 87
				Vec2(pos.x - 512 + 459, 1004 - 575 - 200) -- 87
			}, -- 87
			{ -- 88
				"key", -- 88
				Vec2(pos.x - 512 + 521, 1004 - 499 - 200) -- 88
			}, -- 88
			{ -- 89
				"loli", -- 89
				Vec2(pos.x - 512 + 655, 1004 - 423 - 200) -- 89
			}, -- 89
			{ -- 90
				"select", -- 90
				Vec2(pos.x - 512 + 709, 1004 - 509 - 200) -- 90
			}, -- 90
			{ -- 91
				"mosic", -- 91
				Vec2(pos.x - 512 + 599, 1004 - 339 - 200) -- 91
			}, -- 91
			{ -- 92
				"breakblocks", -- 92
				Vec2(pos.x - 512 + 578, 1004 - 626 - 200) -- 92
			}, -- 92
			{ -- 93
				"search", -- 93
				Vec2(pos.x - 512 + 746, 1004 - 604 - 200) -- 93
			}, -- 93
			{ -- 94
				"quit", -- 94
				Vec2(pos.x - 512 + 363, 1004 - 566 - 200) -- 94
			}, -- 94
			{ -- 95
				"pushSwitch", -- 95
				Vec2(pos.x - 512 + 494, 1004 - 631 - 200) -- 95
			}, -- 95
			{ -- 96
				"attack", -- 96
				Vec2(pos.x - 512 + 630, 1004 - 631 - 200) -- 96
			} -- 96
		} -- 85
		for _index_0 = 1, #_list_0 do -- 97
			local item = _list_0[_index_0] -- 85
			local sp -- 98
			do -- 98
				local _with_0 = Sprite("Model/misc.clip|" .. tostring(item[1])) -- 98
				_with_0.scaleX = 2 -- 99
				_with_0.scaleY = 2 -- 100
				_with_0.filter = "Point" -- 101
				sp = _with_0 -- 98
			end -- 98
			local rectDef -- 102
			do -- 102
				local _with_0 = BodyDef() -- 102
				_with_0.linearAcceleration = Vec2(0, -10) -- 103
				_with_0.type = "Dynamic" -- 104
				_with_0:attachPolygon(sp.width * 2, sp.height * 2, 1, 0, 1) -- 105
				rectDef = _with_0 -- 102
			end -- 102
			local _with_0 = Body(rectDef, self, item[2]) -- 106
			_with_0.order = LayerBackground -- 107
			_with_0.group = GroupDisplay -- 108
			_with_0:addChild(sp) -- 109
			_with_0:addTo(readme) -- 110
		end -- 110
	end, -- 64
	buildCastles = function(_self) -- 112
		local Block -- 113
		Block = function(block, group, look, x, y) -- 113
			return Entity({ -- 115
				block = "Block" .. tostring(block), -- 115
				group = group, -- 116
				layer = LayerBlock, -- 117
				look = look, -- 118
				position = Vec2(x, y) -- 119
			}) -- 119
		end -- 113
		Block("C", GroupPlayerBlock, "gray", 419, 1004 - 280) -- 122
		Block("A", GroupPlayerBlock, "green", 239, 1004 - 190) -- 123
		Block("A", GroupPlayerBlock, "green", 419, 1004 - 190) -- 124
		Block("A", GroupPlayerBlock, "green", 599, 1004 - 190) -- 125
		Block("C", GroupPlayerBlock, "gray", 419, 1004 - 580) -- 126
		Block("B", GroupPlayerBlock, "", 291, 1004 - 430) -- 127
		Block("B", GroupPlayerBlock, "", 416, 1004 - 430) -- 128
		Block("B", GroupPlayerBlock, "", 540, 1004 - 430) -- 129
		Block("A", GroupPlayerBlock, "gray", 239, 1004 - 670) -- 130
		Block("A", GroupPlayerBlock, "gray", 599, 1004 - 670) -- 131
		Block("A", GroupPlayerBlock, "blue", 239, 1004 - 760) -- 132
		Block("A", GroupPlayerBlock, "blue", 599, 1004 - 760) -- 133
		Block("A", GroupPlayerBlock, "red", 239, 1004 - 850) -- 134
		Block("A", GroupPlayerBlock, "red", 599, 1004 - 850) -- 135
		Block("C", GroupPlayerBlock, "jade", 419, 1004 - 940) -- 136
		Block("C", GroupPlayerBlock, "jade", 1074, 1004 - 552) -- 139
		Block("C", GroupPlayerBlock, "jade", 1074, 1004 - 731) -- 140
		Block("A", GroupPlayerBlock, "blue", 894, 1004 - 463) -- 141
		Block("A", GroupPlayerBlock, "blue", 1075, 1004 - 463) -- 142
		Block("A", GroupPlayerBlock, "blue", 1254, 1004 - 463) -- 143
		Block("A", GroupPlayerBlock, "green", 956, 1004 - 642) -- 144
		Block("A", GroupPlayerBlock, "green", 1194, 1004 - 642) -- 145
		Block("B", GroupPlayerBlock, "", 893, 1004 - 881) -- 146
		Block("B", GroupPlayerBlock, "", 1254, 1004 - 881) -- 147
		Block("C", GroupEnemyBlock, "gray", 3674, 1004 - 281) -- 150
		Block("A", GroupEnemyBlock, "green", 3494, 1004 - 191) -- 151
		Block("A", GroupEnemyBlock, "green", 3674, 1004 - 191) -- 152
		Block("A", GroupEnemyBlock, "green", 3854, 1004 - 191) -- 153
		Block("C", GroupEnemyBlock, "gray", 3674, 1004 - 581) -- 154
		Block("B", GroupEnemyBlock, "", 3546, 1004 - 431) -- 155
		Block("B", GroupEnemyBlock, "", 3671, 1004 - 431) -- 156
		Block("B", GroupEnemyBlock, "", 3795, 1004 - 431) -- 157
		Block("A", GroupEnemyBlock, "gray", 3494, 1004 - 671) -- 158
		Block("A", GroupEnemyBlock, "gray", 3854, 1004 - 671) -- 159
		Block("A", GroupEnemyBlock, "blue", 3494, 1004 - 761) -- 160
		Block("A", GroupEnemyBlock, "blue", 3854, 1004 - 761) -- 161
		Block("A", GroupEnemyBlock, "red", 3494, 1004 - 851) -- 162
		Block("A", GroupEnemyBlock, "red", 3854, 1004 - 851) -- 163
		Block("C", GroupEnemyBlock, "jade", 3674, 1004 - 941) -- 164
		Block("C", GroupEnemyBlock, "jade", 3024, 1004 - 552) -- 167
		Block("C", GroupEnemyBlock, "jade", 3024, 1004 - 731) -- 168
		Block("A", GroupEnemyBlock, "blue", 2844, 1004 - 463) -- 169
		Block("A", GroupEnemyBlock, "blue", 3025, 1004 - 463) -- 170
		Block("A", GroupEnemyBlock, "blue", 3204, 1004 - 463) -- 171
		Block("A", GroupEnemyBlock, "green", 2906, 1004 - 642) -- 172
		Block("A", GroupEnemyBlock, "green", 3144, 1004 - 642) -- 173
		Block("B", GroupEnemyBlock, "", 2843, 1004 - 881) -- 174
		Block("B", GroupEnemyBlock, "", 3204, 1004 - 881) -- 175
		local playerBlockHP = 0 -- 177
		local enemyBlockHP = 0 -- 178
		do -- 179
			local _with_0 = Group({ -- 179
				"block" -- 179
			}) -- 179
			_with_0:each(function(self) -- 180
				local _exp_0 = self.group -- 180
				if GroupPlayerBlock == _exp_0 then -- 181
					playerBlockHP = playerBlockHP + Store[self.block].hp -- 182
				elseif GroupEnemyBlock == _exp_0 then -- 183
					enemyBlockHP = enemyBlockHP + Store[self.block].hp -- 184
				end -- 184
			end) -- 180
		end -- 179
		emit("BlockValue", GroupPlayer, playerBlockHP) -- 185
		return emit("BlockValue", GroupEnemy, enemyBlockHP) -- 186
	end, -- 112
	buildSwitches = function(_self) -- 188
		local Switch -- 189
		Switch = function(switchType, group, look, x, y) -- 189
			return Entity({ -- 191
				switch = switchType, -- 191
				group = group, -- 192
				look = look, -- 193
				layer = LayerSwitch, -- 194
				position = Vec2(x, y) -- 195
			}) -- 195
		end -- 189
		Switch("Switch", GroupPlayer, "normal", 777, 1004 - 923) -- 196
		Switch("SwitchG", GroupPlayer, "gold", 116, 1004 - 923) -- 197
		Switch("Switch", GroupEnemy, "normal", 3331, 1004 - 923) -- 198
		return Switch("SwitchG", GroupEnemy, "gold", 3977, 1004 - 923) -- 199
	end, -- 188
	addBunnySwither = function(_self, group) -- 201
		local switchGExist = false -- 202
		local switchNExist = false -- 203
		local bunnySwitchers = Group({ -- 204
			"bunny", -- 204
			"targetSwitch" -- 204
		}) -- 204
		bunnySwitchers:each(function(switcher) -- 205
			if switcher.group == group then -- 206
				local _exp_0 = switcher.targetSwitch -- 207
				if "SwitchG" == _exp_0 then -- 208
					switchGExist = true -- 208
				elseif "Switch" == _exp_0 then -- 209
					switchNExist = true -- 209
				end -- 209
			end -- 206
		end) -- 205
		if not switchGExist then -- 210
			Entity(_anon_func_4(GroupEnemy, GroupPlayer, LayerBunny, Vec2, group)) -- 211
		end -- 210
		if not switchNExist then -- 219
			return Entity(_anon_func_5(GroupEnemy, GroupPlayer, LayerBunny, Vec2, group)) -- 227
		end -- 219
	end, -- 201
	clearScene = function(self) -- 229
		self:removeLayer(LayerBlock) -- 230
		self:removeLayer(LayerBunny) -- 231
		self:removeLayer(LayerPlayerHero) -- 232
		return self:removeLayer(LayerEnemyHero) -- 233
	end -- 229
}) -- 27
_module_0 = GameWorld() -- 235
return _module_0 -- 235
