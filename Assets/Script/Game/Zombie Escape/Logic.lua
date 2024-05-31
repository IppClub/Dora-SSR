-- [yue]: Logic.yue
local _module_0 = Dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Observer = Dora.Observer -- 1
local Color3 = Dora.Color3 -- 1
local Body = Dora.Body -- 1
local type = _G.type -- 1
local Color = Dora.Color -- 1
local Unit = _module_0.Unit -- 1
local once = Dora.once -- 1
local sleep = Dora.sleep -- 1
local Opacity = Dora.Opacity -- 1
local Ease = Dora.Ease -- 1
local Group = Dora.Group -- 1
local threadLoop = Dora.threadLoop -- 1
local Vec2 = Dora.Vec2 -- 1
local App = Dora.App -- 1
local Rect = Dora.Rect -- 1
local Size = Dora.Size -- 1
local Entity = Dora.Entity -- 1
local math = _G.math -- 1
local tostring = _G.tostring -- 1
local Rectangle = require("UI.View.Shape.Rectangle") -- 10
local Circle = require("UI.View.Shape.Circle") -- 11
local Star = require("UI.View.Shape.Star") -- 12
local Store = Data.store -- 14
do -- 16
	local _with_0 = Observer("Add", { -- 16
		"obstacleDef", -- 16
		"size", -- 16
		"position", -- 16
		"color" -- 16
	}) -- 16
	_with_0:watch(function(self, obstacleDef, size, position, color) -- 17
		local world, TerrainLayer = Store.world, Store.TerrainLayer -- 18
		color = Color3(color) -- 19
		do -- 20
			local _with_1 = Body(Store[obstacleDef], world, position) -- 20
			_with_1.tag = "Obstacle" -- 21
			_with_1.order = TerrainLayer -- 22
			_with_1.group = Data.groupTerrain -- 23
			if "number" == type(size) then -- 24
				_with_1:addChild(Circle({ -- 26
					radius = size, -- 26
					fillColor = Color(color, 0x66):toARGB(), -- 27
					borderColor = Color(color, 0xff):toARGB(), -- 28
					fillOrder = 1, -- 29
					lineOrder = 2 -- 30
				})) -- 25
				_with_1:addChild(Star({ -- 33
					size = 20, -- 33
					borderColor = 0xffffffff, -- 34
					fillColor = 0x66ffffff, -- 35
					fillOrder = 1, -- 36
					lineOrder = 2 -- 37
				})) -- 32
			else -- 40
				_with_1:addChild(Rectangle({ -- 41
					width = size.width, -- 41
					height = size.height, -- 42
					fillColor = Color(color, 0x66):toARGB(), -- 43
					borderColor = Color(color, 0xff):toARGB(), -- 44
					fillOrder = 1, -- 45
					lineOrder = 2 -- 46
				})) -- 40
			end -- 24
			_with_1:addTo(world) -- 48
		end -- 20
		self:destroy() -- 49
		return false -- 49
	end) -- 17
end -- 16
local mutables = { -- 52
	"hp", -- 52
	"moveSpeed", -- 53
	"move", -- 54
	"jump", -- 55
	"targetAllow", -- 56
	"attackPower", -- 57
	"attackSpeed" -- 58
} -- 51
do -- 60
	local _with_0 = Observer("Add", { -- 60
		"unitDef", -- 60
		"position", -- 60
		"order", -- 60
		"group", -- 60
		"faceRight" -- 60
	}) -- 60
	_with_0:watch(function(self, unitDef, position, order, group, faceRight) -- 61
		local world = Store.world -- 62
		local def = Store[unitDef] -- 63
		for _index_0 = 1, #mutables do -- 64
			local var = mutables[_index_0] -- 64
			self[var] = def[var] -- 65
		end -- 65
		local unit -- 66
		do -- 66
			local _with_1 = Unit(def, world, self, position) -- 66
			_with_1.group = group -- 67
			_with_1.order = order -- 68
			_with_1.faceRight = faceRight -- 69
			_with_1:addTo(world) -- 70
			_with_1:eachAction(function(self) -- 71
				self.recovery = 0 -- 71
			end) -- 71
			local _with_2 = _with_1.playable -- 72
			_with_2:eachNode(function(sp) -- 73
				sp.filter = "Point" -- 73
			end) -- 73
			if self.zombie then -- 74
				_with_2:play("groundEntrance") -- 74
			end -- 74
			unit = _with_1 -- 66
		end -- 66
		if self.player and unit.decisionTree == "AI_KidSearch" then -- 75
			world.camera.followTarget = unit -- 75
		end -- 75
		return false -- 75
	end) -- 61
end -- 60
do -- 77
	local _with_0 = Observer("Change", { -- 77
		"hp", -- 77
		"unit" -- 77
	}) -- 77
	_with_0:watch(function(self, hp, unit) -- 78
		local lastHp = self.oldValues.hp -- 79
		if hp < lastHp then -- 80
			if hp > 0 then -- 81
				unit:start("hit") -- 82
			else -- 84
				unit:start("hit") -- 84
				unit:start("fall") -- 85
				unit.group = Data.groupHide -- 86
				unit:schedule(once(function() -- 87
					sleep(5) -- 88
					unit:runAction(Opacity(0.5, 1, 0, Ease.OutQuad)) -- 89
					sleep(0.5) -- 90
					if Store.world.camera.followTarget == unit then -- 91
						local player = Group({ -- 92
							"player", -- 92
							"unit" -- 92
						}):find(function(self) -- 92
							return self.player -- 92
						end) -- 92
						if player then -- 92
							Store.world.camera.followTarget = player.unit -- 93
						end -- 92
					end -- 91
					return unit:removeFromParent() -- 94
				end)) -- 87
			end -- 81
		end -- 80
		return false -- 94
	end) -- 78
end -- 77
Store.zombieKilled = 0 -- 96
do -- 97
	local _with_0 = Observer("Change", { -- 97
		"hp", -- 97
		"zombie" -- 97
	}) -- 97
	_with_0:watch(function(_entity, hp) -- 98
		if hp <= 0 then -- 99
			Store.zombieKilled = Store.zombieKilled + 1 -- 99
		end -- 99
		return false -- 99
	end) -- 98
end -- 97
local zombieGroup = Group({ -- 101
	"zombie" -- 101
}) -- 101
return threadLoop(function() -- 102
	local ZombieLayer, ZombieGroup, MaxZombies, ZombieWaveDelay, world = Store.ZombieLayer, Store.ZombieGroup, Store.MaxZombies, Store.ZombieWaveDelay, Store.world -- 103
	if zombieGroup.count < MaxZombies then -- 110
		for _ = zombieGroup.count + 1, MaxZombies do -- 111
			local available = false -- 112
			local pos = Vec2.zero -- 113
			while not available do -- 114
				pos = Vec2(App.rand % 2400 - 1200, -430) -- 115
				available = not world:query(Rect(pos, Size(5, 5)), function(self) -- 116
					return self.group == Data.groupTerrain -- 116
				end) -- 116
			end -- 116
			Entity({ -- 118
				unitDef = "Unit_Zombie" .. tostring(math.floor(App.rand % 2 + 1)), -- 118
				order = ZombieLayer, -- 119
				position = pos, -- 120
				group = ZombieGroup, -- 121
				faceRight = App.rand % 2 == 0, -- 122
				zombie = true -- 123
			}) -- 117
			sleep(0.1 * App.rand % 5) -- 124
		end -- 124
	end -- 110
	return sleep(ZombieWaveDelay) -- 125
end) -- 125
