-- [yue]: Script/Example/Entity Move.yue
local Group = Dora.Group -- 1
local Observer = Dora.Observer -- 1
local Sprite = Dora.Sprite -- 1
local Scale = Dora.Scale -- 1
local Ease = Dora.Ease -- 1
local print = _G.print -- 1
local tostring = _G.tostring -- 1
local math = _G.math -- 1
local Roll = Dora.Roll -- 1
local Entity = Dora.Entity -- 1
local Node = Dora.Node -- 1
local Vec2 = Dora.Vec2 -- 1
local threadLoop = Dora.threadLoop -- 1
local App = Dora.App -- 1
local ImGui = Dora.ImGui -- 1
local Sequence = Dora.Sequence -- 1
local Event = Dora.Event -- 1
local sceneGroup = Group({ -- 3
	"scene" -- 3
}) -- 3
local positionGroup = Group({ -- 4
	"position" -- 4
}) -- 4
do -- 6
	local _with_0 = Observer("Add", { -- 6
		"scene" -- 6
	}) -- 6
	_with_0:watch(function(self, scene) -- 7
		scene:onTapEnded(function(touch) -- 8
			local location = touch.location -- 9
			return positionGroup:each(function(entity) -- 10
				entity.target = location -- 11
			end) -- 11
		end) -- 8
		return false -- 11
	end) -- 7
end -- 6
do -- 13
	local _with_0 = Observer("Add", { -- 13
		"image" -- 13
	}) -- 13
	_with_0:watch(function(self, image) -- 14
		sceneGroup:each(function(e) -- 14
			do -- 15
				local _with_1 = Sprite(image) -- 15
				self.sprite = _with_1 -- 15
				_with_1:addTo(e.scene) -- 16
				_with_1:runAction(Scale(0.5, 0, 0.5, Ease.OutBack)) -- 17
			end -- 15
			return true -- 18
		end) -- 14
		return false -- 18
	end) -- 14
end -- 13
do -- 20
	local _with_0 = Observer("Remove", { -- 20
		"sprite" -- 20
	}) -- 20
	_with_0:watch(function(self) -- 21
		return self.oldValues.sprite:removeFromParent() -- 21
	end) -- 21
end -- 20
do -- 23
	local _with_0 = Observer("Remove", { -- 23
		"target" -- 23
	}) -- 23
	_with_0:watch(function(self) -- 24
		return print("remove target from entity " .. tostring(self.index)) -- 24
	end) -- 24
end -- 23
do -- 26
	local _with_0 = Group({ -- 26
		"position", -- 26
		"direction", -- 26
		"speed", -- 26
		"target" -- 26
	}) -- 26
	_with_0:watch(function(self, position, direction, speed, target) -- 27
		if target == position then -- 28
			return -- 28
		end -- 28
		local dir = target - position -- 29
		dir = dir:normalize() -- 30
		local angle = math.deg(math.atan(dir.x, dir.y)) -- 31
		local newPos = position + dir * speed -- 32
		newPos = newPos:clamp(position, target) -- 33
		self.position = newPos -- 34
		self.direction = angle -- 35
		if newPos == target then -- 36
			self.target = nil -- 36
		end -- 36
		return false -- 36
	end) -- 27
end -- 26
do -- 38
	local _with_0 = Observer("AddOrChange", { -- 38
		"position", -- 38
		"direction", -- 38
		"sprite" -- 38
	}) -- 38
	_with_0:watch(function(self, position, direction, sprite) -- 39
		sprite.position = position -- 40
		local lastDirection = self.oldValues.direction or sprite.angle -- 41
		if math.abs(direction - lastDirection) > 1 then -- 42
			sprite:runAction(Roll(0.3, lastDirection, direction)) -- 43
		end -- 42
		return false -- 43
	end) -- 39
end -- 38
Entity({ -- 46
	scene = Node() -- 46
}) -- 45
Entity({ -- 49
	image = "Image/logo.png", -- 49
	position = Vec2.zero, -- 50
	direction = 45.0, -- 51
	speed = 4.0 -- 52
}) -- 48
Entity({ -- 55
	image = "Image/logo.png", -- 55
	position = Vec2(-100, 200), -- 56
	direction = 90.0, -- 57
	speed = 10.0 -- 58
}) -- 54
local windowFlags = { -- 63
	"NoDecoration", -- 63
	"AlwaysAutoResize", -- 63
	"NoSavedSettings", -- 63
	"NoFocusOnAppearing", -- 63
	"NoNav", -- 63
	"NoMove" -- 63
} -- 63
return threadLoop(function() -- 71
	local width -- 72
	width = App.visualSize.width -- 72
	ImGui.SetNextWindowBgAlpha(0.35) -- 73
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 74
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 75
	return ImGui.Begin("ECS System", windowFlags, function() -- 76
		ImGui.Text("ECS System (Yuescript)") -- 77
		ImGui.Separator() -- 78
		ImGui.TextWrapped("Tap any place to move entities.") -- 79
		if ImGui.Button("Create Random Entity") then -- 80
			Entity({ -- 82
				image = "Image/logo.png", -- 82
				position = Vec2(6 * math.random(1, 100), 6 * math.random(1, 100)), -- 83
				direction = 1.0 * math.random(0, 360), -- 84
				speed = 1.0 * math.random(1, 20) -- 85
			}) -- 81
		end -- 80
		if ImGui.Button("Destroy An Entity") then -- 86
			return Group({ -- 87
				"sprite", -- 87
				"position" -- 87
			}):each(function(entity) -- 87
				entity.position = nil -- 88
				do -- 89
					local _with_0 = entity.sprite -- 89
					_with_0:runAction(Sequence(Scale(0.5, 0.5, 0, Ease.InBack), Event("Destroy"))) -- 90
					_with_0:slot("Destroy", function() -- 91
						return entity:destroy() -- 91
					end) -- 91
				end -- 89
				return true -- 92
			end) -- 92
		end -- 86
	end) -- 92
end) -- 92
