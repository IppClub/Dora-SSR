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
local Store = Data.store -- 11
local GroupPlayer, GroupEnemy, GroupPlayerBlock, GroupEnemyBlock, GroupTerrain, GroupDisplay, LayerReadMe, LayerBlock, LayerBunny, LayerSwitch, LayerPlayerHero, LayerEnemyHero, LayerBackground = Store.GroupPlayer, Store.GroupEnemy, Store.GroupPlayerBlock, Store.GroupEnemyBlock, Store.GroupTerrain, Store.GroupDisplay, Store.LayerReadMe, Store.LayerBlock, Store.LayerBunny, Store.LayerSwitch, Store.LayerPlayerHero, Store.LayerEnemyHero, Store.LayerBackground -- 12
local _anon_func_0 = function(Body, GroupTerrain, LayerBackground, Vec2, self, terrainDef) -- 46
	local _with_0 = Body(terrainDef, self, Vec2.zero) -- 44
	_with_0.order = LayerBackground -- 45
	_with_0.group = GroupTerrain -- 46
	return _with_0 -- 44
end -- 44
local _anon_func_1 = function(LayerBackground, Sprite, Vec2) -- 53
	local _with_0 = Sprite("Model/items.clip|background") -- 48
	_with_0.order = LayerBackground -- 49
	_with_0.anchor = Vec2.zero -- 50
	_with_0.scaleX = 4146 / _with_0.width -- 51
	_with_0.scaleY = 1600 / _with_0.height -- 52
	_with_0.y = -50 -- 53
	return _with_0 -- 48
end -- 48
local _anon_func_3 = function(Sprite, _with_0, i) -- 63
	local _with_1 = Sprite("Model/misc.clip|floor") -- 59
	_with_1.scaleX = 8 -- 60
	_with_1.scaleY = 8 -- 61
	_with_1.x = i * 128 -- 62
	_with_1.filter = "Point" -- 63
	return _with_1 -- 59
end -- 59
local _anon_func_2 = function(LayerBackground, Node, Sprite) -- 63
	local _with_0 = Node() -- 55
	_with_0.order = LayerBackground -- 56
	_with_0.y = -44 -- 57
	for i = 0, 32 do -- 58
		_with_0:addChild(_anon_func_3(Sprite, _with_0, i)) -- 59
	end -- 63
	return _with_0 -- 55
end -- 55
local _anon_func_4 = function(GroupEnemy, GroupPlayer, LayerBunny, Vec2, group) -- 219
	local _with_0 = { } -- 212
	_with_0.group = group -- 213
	if GroupPlayer == group then -- 215
		_with_0.bunny, _with_0.faceRight, _with_0.position = "BunnyG", false, Vec2(216, 500) -- 215
	elseif GroupEnemy == group then -- 216
		_with_0.bunny, _with_0.faceRight, _with_0.position = "BunnyP", true, Vec2(3877, 500) -- 216
	end -- 216
	_with_0.AI = "BunnySwitcherAI" -- 217
	_with_0.layer = LayerBunny -- 218
	_with_0.targetSwitch = "SwitchG" -- 219
	return _with_0 -- 212
end -- 212
local _anon_func_5 = function(GroupEnemy, GroupPlayer, LayerBunny, Vec2, group) -- 228
	local _with_0 = { } -- 221
	_with_0.group = group -- 222
	if GroupPlayer == group then -- 224
		_with_0.bunny, _with_0.faceRight, _with_0.position = "BunnyG", true, Vec2(677, 500) -- 224
	elseif GroupEnemy == group then -- 225
		_with_0.bunny, _with_0.faceRight, _with_0.position = "BunnyP", false, Vec2(3431, 500) -- 225
	end -- 225
	_with_0.AI = "BunnySwitcherAI" -- 226
	_with_0.layer = LayerBunny -- 227
	_with_0.targetSwitch = "Switch" -- 228
	return _with_0 -- 221
end -- 221
local GameWorld = Class(PlatformWorld, { -- 29
	__init = function(self) -- 29
		Entity({ -- 30
			world = self -- 30
		}) -- 30
		local DesignWidth <const> = 1024 -- 31
		self.camera.zoom = View.size.width / DesignWidth -- 32
		return self:gslot("AppSizeChanged", function() -- 33
			self.camera.zoom = View.size.width / DesignWidth -- 34
		end) -- 34
	end, -- 29
	buildBackground = function(self) -- 36
		local terrainDef -- 37
		do -- 37
			local _with_0 = BodyDef() -- 37
			_with_0.type = "Static" -- 38
			_with_0:attachPolygon(Vec2(2048, 1004 - 994), 4096, 10) -- 39
			_with_0:attachPolygon(Vec2(2048, 1004), 4096, 10) -- 40
			_with_0:attachPolygon(Vec2(-5, 1004 - 512), 10, 1024) -- 41
			_with_0:attachPolygon(Vec2(4101, 1004 - 512), 10, 1024) -- 42
			terrainDef = _with_0 -- 37
		end -- 37
		self:addChild(_anon_func_0(Body, GroupTerrain, LayerBackground, Vec2, self, terrainDef)) -- 44
		self:addChild(_anon_func_1(LayerBackground, Sprite, Vec2)) -- 48
		return self:addChild(_anon_func_2(LayerBackground, Node, Sprite)) -- 63
	end, -- 36
	buildGameReadme = function(self) -- 65
		local pos = self.camera.position -- 66
		local readmeDef -- 67
		do -- 67
			local _with_0 = BodyDef() -- 67
			_with_0.type = "Static" -- 68
			_with_0:attachPolygon(Vec2(pos.x, 1004 - 994), 1024, 10) -- 69
			_with_0:attachPolygon(Vec2(pos.x, 1004), 1024, 10) -- 70
			_with_0:attachPolygon(Vec2(pos.x - 512, 1004 - 512), 10, 1024) -- 71
			_with_0:attachPolygon(Vec2(pos.x + 512, 1004 - 512), 10, 1024) -- 72
			readmeDef = _with_0 -- 67
		end -- 67
		local readme -- 74
		do -- 74
			local _with_0 = Body(readmeDef, self, Vec2.zero) -- 74
			_with_0.order = LayerBackground -- 75
			_with_0.group = GroupDisplay -- 76
			_with_0:addTo(self) -- 77
			_with_0:gslot("PlayerSelect", function() -- 78
				_with_0.children:each(function(child) -- 79
					local _with_1 = Visual("Particle/heart.par") -- 80
					_with_1.position = child:convertToWorldSpace(Vec2.zero) -- 81
					_with_1:autoRemove() -- 82
					_with_1:start() -- 83
					return _with_1 -- 80
				end) -- 79
				return _with_0:removeFromParent() -- 84
			end) -- 78
			readme = _with_0 -- 74
		end -- 74
		local _list_0 = { -- 87
			{ -- 87
				"war", -- 87
				Vec2(pos.x - 512 + 369, 1004 - 413 - 200) -- 87
			}, -- 87
			{ -- 88
				"use", -- 88
				Vec2(pos.x - 512 + 459, 1004 - 575 - 200) -- 88
			}, -- 88
			{ -- 89
				"key", -- 89
				Vec2(pos.x - 512 + 521, 1004 - 499 - 200) -- 89
			}, -- 89
			{ -- 90
				"loli", -- 90
				Vec2(pos.x - 512 + 655, 1004 - 423 - 200) -- 90
			}, -- 90
			{ -- 91
				"select", -- 91
				Vec2(pos.x - 512 + 709, 1004 - 509 - 200) -- 91
			}, -- 91
			{ -- 92
				"mosic", -- 92
				Vec2(pos.x - 512 + 599, 1004 - 339 - 200) -- 92
			}, -- 92
			{ -- 93
				"breakblocks", -- 93
				Vec2(pos.x - 512 + 578, 1004 - 626 - 200) -- 93
			}, -- 93
			{ -- 94
				"search", -- 94
				Vec2(pos.x - 512 + 746, 1004 - 604 - 200) -- 94
			}, -- 94
			{ -- 95
				"quit", -- 95
				Vec2(pos.x - 512 + 363, 1004 - 566 - 200) -- 95
			}, -- 95
			{ -- 96
				"pushSwitch", -- 96
				Vec2(pos.x - 512 + 494, 1004 - 631 - 200) -- 96
			}, -- 96
			{ -- 97
				"attack", -- 97
				Vec2(pos.x - 512 + 630, 1004 - 631 - 200) -- 97
			} -- 97
		} -- 86
		for _index_0 = 1, #_list_0 do -- 98
			local item = _list_0[_index_0] -- 86
			local sp -- 99
			do -- 99
				local _with_0 = Sprite("Model/misc.clip|" .. tostring(item[1])) -- 99
				_with_0.scaleX = 2 -- 100
				_with_0.scaleY = 2 -- 101
				_with_0.filter = "Point" -- 102
				sp = _with_0 -- 99
			end -- 99
			local rectDef -- 103
			do -- 103
				local _with_0 = BodyDef() -- 103
				_with_0.linearAcceleration = Vec2(0, -10) -- 104
				_with_0.type = "Dynamic" -- 105
				_with_0:attachPolygon(sp.width * 2, sp.height * 2, 1, 0, 1) -- 106
				rectDef = _with_0 -- 103
			end -- 103
			local _with_0 = Body(rectDef, self, item[2]) -- 107
			_with_0.order = LayerBackground -- 108
			_with_0.group = GroupDisplay -- 109
			_with_0:addChild(sp) -- 110
			_with_0:addTo(readme) -- 111
		end -- 111
	end, -- 65
	buildCastles = function(self) -- 113
		local Block -- 114
		Block = function(block, group, look, x, y) -- 114
			return Entity({ -- 116
				block = "Block" .. tostring(block), -- 116
				group = group, -- 117
				layer = LayerBlock, -- 118
				look = look, -- 119
				position = Vec2(x, y) -- 120
			}) -- 120
		end -- 114
		Block("C", GroupPlayerBlock, "gray", 419, 1004 - 280) -- 123
		Block("A", GroupPlayerBlock, "green", 239, 1004 - 190) -- 124
		Block("A", GroupPlayerBlock, "green", 419, 1004 - 190) -- 125
		Block("A", GroupPlayerBlock, "green", 599, 1004 - 190) -- 126
		Block("C", GroupPlayerBlock, "gray", 419, 1004 - 580) -- 127
		Block("B", GroupPlayerBlock, "", 291, 1004 - 430) -- 128
		Block("B", GroupPlayerBlock, "", 416, 1004 - 430) -- 129
		Block("B", GroupPlayerBlock, "", 540, 1004 - 430) -- 130
		Block("A", GroupPlayerBlock, "gray", 239, 1004 - 670) -- 131
		Block("A", GroupPlayerBlock, "gray", 599, 1004 - 670) -- 132
		Block("A", GroupPlayerBlock, "blue", 239, 1004 - 760) -- 133
		Block("A", GroupPlayerBlock, "blue", 599, 1004 - 760) -- 134
		Block("A", GroupPlayerBlock, "red", 239, 1004 - 850) -- 135
		Block("A", GroupPlayerBlock, "red", 599, 1004 - 850) -- 136
		Block("C", GroupPlayerBlock, "jade", 419, 1004 - 940) -- 137
		Block("C", GroupPlayerBlock, "jade", 1074, 1004 - 552) -- 140
		Block("C", GroupPlayerBlock, "jade", 1074, 1004 - 731) -- 141
		Block("A", GroupPlayerBlock, "blue", 894, 1004 - 463) -- 142
		Block("A", GroupPlayerBlock, "blue", 1075, 1004 - 463) -- 143
		Block("A", GroupPlayerBlock, "blue", 1254, 1004 - 463) -- 144
		Block("A", GroupPlayerBlock, "green", 956, 1004 - 642) -- 145
		Block("A", GroupPlayerBlock, "green", 1194, 1004 - 642) -- 146
		Block("B", GroupPlayerBlock, "", 893, 1004 - 881) -- 147
		Block("B", GroupPlayerBlock, "", 1254, 1004 - 881) -- 148
		Block("C", GroupEnemyBlock, "gray", 3674, 1004 - 281) -- 151
		Block("A", GroupEnemyBlock, "green", 3494, 1004 - 191) -- 152
		Block("A", GroupEnemyBlock, "green", 3674, 1004 - 191) -- 153
		Block("A", GroupEnemyBlock, "green", 3854, 1004 - 191) -- 154
		Block("C", GroupEnemyBlock, "gray", 3674, 1004 - 581) -- 155
		Block("B", GroupEnemyBlock, "", 3546, 1004 - 431) -- 156
		Block("B", GroupEnemyBlock, "", 3671, 1004 - 431) -- 157
		Block("B", GroupEnemyBlock, "", 3795, 1004 - 431) -- 158
		Block("A", GroupEnemyBlock, "gray", 3494, 1004 - 671) -- 159
		Block("A", GroupEnemyBlock, "gray", 3854, 1004 - 671) -- 160
		Block("A", GroupEnemyBlock, "blue", 3494, 1004 - 761) -- 161
		Block("A", GroupEnemyBlock, "blue", 3854, 1004 - 761) -- 162
		Block("A", GroupEnemyBlock, "red", 3494, 1004 - 851) -- 163
		Block("A", GroupEnemyBlock, "red", 3854, 1004 - 851) -- 164
		Block("C", GroupEnemyBlock, "jade", 3674, 1004 - 941) -- 165
		Block("C", GroupEnemyBlock, "jade", 3024, 1004 - 552) -- 168
		Block("C", GroupEnemyBlock, "jade", 3024, 1004 - 731) -- 169
		Block("A", GroupEnemyBlock, "blue", 2844, 1004 - 463) -- 170
		Block("A", GroupEnemyBlock, "blue", 3025, 1004 - 463) -- 171
		Block("A", GroupEnemyBlock, "blue", 3204, 1004 - 463) -- 172
		Block("A", GroupEnemyBlock, "green", 2906, 1004 - 642) -- 173
		Block("A", GroupEnemyBlock, "green", 3144, 1004 - 642) -- 174
		Block("B", GroupEnemyBlock, "", 2843, 1004 - 881) -- 175
		Block("B", GroupEnemyBlock, "", 3204, 1004 - 881) -- 176
		local playerBlockHP = 0 -- 178
		local enemyBlockHP = 0 -- 179
		do -- 180
			local _with_0 = Group({ -- 180
				"block" -- 180
			}) -- 180
			_with_0:each(function(self) -- 181
				local _exp_0 = self.group -- 181
				if GroupPlayerBlock == _exp_0 then -- 182
					playerBlockHP = playerBlockHP + Store[self.block].hp -- 183
				elseif GroupEnemyBlock == _exp_0 then -- 184
					enemyBlockHP = enemyBlockHP + Store[self.block].hp -- 185
				end -- 185
			end) -- 181
		end -- 180
		emit("BlockValue", GroupPlayer, playerBlockHP) -- 186
		return emit("BlockValue", GroupEnemy, enemyBlockHP) -- 187
	end, -- 113
	buildSwitches = function(self) -- 189
		local Switch -- 190
		Switch = function(switchType, group, look, x, y) -- 190
			return Entity({ -- 192
				switch = switchType, -- 192
				group = group, -- 193
				look = look, -- 194
				layer = LayerSwitch, -- 195
				position = Vec2(x, y) -- 196
			}) -- 196
		end -- 190
		Switch("Switch", GroupPlayer, "normal", 777, 1004 - 923) -- 197
		Switch("SwitchG", GroupPlayer, "gold", 116, 1004 - 923) -- 198
		Switch("Switch", GroupEnemy, "normal", 3331, 1004 - 923) -- 199
		return Switch("SwitchG", GroupEnemy, "gold", 3977, 1004 - 923) -- 200
	end, -- 189
	addBunnySwither = function(self, group) -- 202
		local switchGExist = false -- 203
		local switchNExist = false -- 204
		local bunnySwitchers = Group({ -- 205
			"bunny", -- 205
			"targetSwitch" -- 205
		}) -- 205
		bunnySwitchers:each(function(switcher) -- 206
			if switcher.group == group then -- 207
				local _exp_0 = switcher.targetSwitch -- 208
				if "SwitchG" == _exp_0 then -- 209
					switchGExist = true -- 209
				elseif "Switch" == _exp_0 then -- 210
					switchNExist = true -- 210
				end -- 210
			end -- 207
		end) -- 206
		if not switchGExist then -- 211
			Entity(_anon_func_4(GroupEnemy, GroupPlayer, LayerBunny, Vec2, group)) -- 212
		end -- 211
		if not switchNExist then -- 220
			return Entity(_anon_func_5(GroupEnemy, GroupPlayer, LayerBunny, Vec2, group)) -- 228
		end -- 220
	end, -- 202
	clearScene = function(self) -- 230
		self:removeLayer(LayerBlock) -- 231
		self:removeLayer(LayerBunny) -- 232
		self:removeLayer(LayerPlayerHero) -- 233
		return self:removeLayer(LayerEnemyHero) -- 234
	end -- 230
}) -- 28
_module_0 = GameWorld() -- 236
return _module_0 -- 236
