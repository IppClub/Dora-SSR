-- [yue]: Script/Game/Zombie Escape/Logic.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Observer = dora.Observer -- 1
local Color3 = dora.Color3 -- 1
local Body = dora.Body -- 1
local type = _G.type -- 1
local Color = dora.Color -- 1
local Unit = _module_0.Unit -- 1
local once = dora.once -- 1
local sleep = dora.sleep -- 1
local Opacity = dora.Opacity -- 1
local Ease = dora.Ease -- 1
local Group = dora.Group -- 1
local threadLoop = dora.threadLoop -- 1
local Vec2 = dora.Vec2 -- 1
local App = dora.App -- 1
local Rect = dora.Rect -- 1
local Size = dora.Size -- 1
local Entity = dora.Entity -- 1
local math = _G.math -- 1
local tostring = _G.tostring -- 1
local Rectangle = require("UI.View.Shape.Rectangle") -- 2
local Circle = require("UI.View.Shape.Circle") -- 3
local Star = require("UI.View.Shape.Star") -- 4
local Store = Data.store -- 6
do -- 8
	local _with_0 = Observer("Add", { -- 8
		"obstacleDef", -- 8
		"size", -- 8
		"position", -- 8
		"color" -- 8
	}) -- 8
	_with_0:watch(function(self, obstacleDef, size, position, color) -- 9
		local world, TerrainLayer = Store.world, Store.TerrainLayer -- 10
		color = Color3(color) -- 11
		do -- 12
			local _with_1 = Body(Store[obstacleDef], world, position) -- 12
			_with_1.tag = "Obstacle" -- 13
			_with_1.order = TerrainLayer -- 14
			_with_1.group = Data.groupTerrain -- 15
			if "number" == type(size) then -- 16
				_with_1:addChild(Circle({ -- 18
					radius = size, -- 18
					fillColor = Color(color, 0x66):toARGB(), -- 19
					borderColor = Color(color, 0xff):toARGB(), -- 20
					fillOrder = 1, -- 21
					lineOrder = 2 -- 22
				})) -- 17
				_with_1:addChild(Star({ -- 25
					size = 20, -- 25
					borderColor = 0xffffffff, -- 26
					fillColor = 0x66ffffff, -- 27
					fillOrder = 1, -- 28
					lineOrder = 2 -- 29
				})) -- 24
			else -- 32
				_with_1:addChild(Rectangle({ -- 33
					width = size.width, -- 33
					height = size.height, -- 34
					fillColor = Color(color, 0x66):toARGB(), -- 35
					borderColor = Color(color, 0xff):toARGB(), -- 36
					fillOrder = 1, -- 37
					lineOrder = 2 -- 38
				})) -- 32
			end -- 16
			_with_1:addTo(world) -- 40
		end -- 12
		self:destroy() -- 41
		return false -- 41
	end) -- 9
end -- 8
local mutables = { -- 44
	"hp", -- 44
	"moveSpeed", -- 45
	"move", -- 46
	"jump", -- 47
	"targetAllow", -- 48
	"attackPower", -- 49
	"attackSpeed" -- 50
} -- 43
do -- 52
	local _with_0 = Observer("Add", { -- 52
		"unitDef", -- 52
		"position", -- 52
		"order", -- 52
		"group", -- 52
		"faceRight" -- 52
	}) -- 52
	_with_0:watch(function(self, unitDef, position, order, group, faceRight) -- 53
		local world = Store.world -- 54
		local def = Store[unitDef] -- 55
		for _index_0 = 1, #mutables do -- 56
			local var = mutables[_index_0] -- 56
			self[var] = def[var] -- 57
		end -- 57
		local unit -- 58
		do -- 58
			local _with_1 = Unit(def, world, self, position) -- 58
			_with_1.group = group -- 59
			_with_1.order = order -- 60
			_with_1.faceRight = faceRight -- 61
			_with_1:addTo(world) -- 62
			_with_1:eachAction(function(self) -- 63
				self.recovery = 0 -- 63
			end) -- 63
			do -- 64
				local _with_2 = _with_1.playable -- 64
				_with_2:eachNode(function(sp) -- 65
					sp.filter = "Point" -- 65
				end) -- 65
				if self.zombie then -- 66
					_with_2:play("groundEntrance") -- 66
				end -- 66
			end -- 64
			unit = _with_1 -- 58
		end -- 58
		if self.player and unit.decisionTree == "AI_KidSearch" then -- 67
			world.camera.followTarget = unit -- 67
		end -- 67
		return false -- 67
	end) -- 53
end -- 52
do -- 69
	local _with_0 = Observer("Change", { -- 69
		"hp", -- 69
		"unit" -- 69
	}) -- 69
	_with_0:watch(function(self, hp, unit) -- 70
		local lastHp = self.oldValues.hp -- 71
		if hp < lastHp then -- 72
			if hp > 0 then -- 73
				unit:start("hit") -- 74
			else -- 76
				unit:start("hit") -- 76
				unit:start("fall") -- 77
				unit.group = Data.groupHide -- 78
				unit:schedule(once(function() -- 79
					sleep(5) -- 80
					unit:runAction(Opacity(0.5, 1, 0, Ease.OutQuad)) -- 81
					sleep(0.5) -- 82
					if Store.world.camera.followTarget == unit then -- 83
						do -- 84
							local player = Group({ -- 84
								"player", -- 84
								"unit" -- 84
							}):find(function(self) -- 84
								return self.player -- 84
							end) -- 84
							if player then -- 84
								Store.world.camera.followTarget = player.unit -- 85
							end -- 84
						end -- 84
					end -- 83
					return unit:removeFromParent() -- 86
				end)) -- 79
			end -- 73
		end -- 72
		return false -- 86
	end) -- 70
end -- 69
Store.zombieKilled = 0 -- 88
do -- 89
	local _with_0 = Observer("Change", { -- 89
		"hp", -- 89
		"zombie" -- 89
	}) -- 89
	_with_0:watch(function(self, hp) -- 90
		if hp <= 0 then -- 91
			Store.zombieKilled = Store.zombieKilled + 1 -- 91
		end -- 91
		return false -- 91
	end) -- 90
end -- 89
local zombieGroup = Group({ -- 93
	"zombie" -- 93
}) -- 93
return threadLoop(function() -- 94
	local ZombieLayer, ZombieGroup, MaxZombies, ZombieWaveDelay, world = Store.ZombieLayer, Store.ZombieGroup, Store.MaxZombies, Store.ZombieWaveDelay, Store.world -- 95
	if zombieGroup.count < MaxZombies then -- 102
		for i = zombieGroup.count + 1, MaxZombies do -- 103
			local available = false -- 104
			local pos = Vec2.zero -- 105
			while not available do -- 106
				pos = Vec2(App.rand % 2400 - 1200, -430) -- 107
				available = not world:query(Rect(pos, Size(5, 5)), function(self) -- 108
					return self.group == Data.groupTerrain -- 108
				end) -- 108
			end -- 108
			Entity({ -- 110
				unitDef = "Unit_Zombie" .. tostring(math.floor(App.rand % 2 + 1)), -- 110
				order = ZombieLayer, -- 111
				position = pos, -- 112
				group = ZombieGroup, -- 113
				faceRight = App.rand % 2 == 0, -- 114
				zombie = true -- 115
			}) -- 109
			sleep(0.1 * App.rand % 5) -- 116
		end -- 116
	end -- 102
	return sleep(ZombieWaveDelay) -- 117
end) -- 117
