-- [yue]: Script/Example/Entity Move.yue
local Group = dora.Group -- 1
local Observer = dora.Observer -- 1
local Sprite = dora.Sprite -- 1
local Scale = dora.Scale -- 1
local Ease = dora.Ease -- 1
local print = _G.print -- 1
local tostring = _G.tostring -- 1
local math = _G.math -- 1
local Roll = dora.Roll -- 1
local Entity = dora.Entity -- 1
local Node = dora.Node -- 1
local Vec2 = dora.Vec2 -- 1
local threadLoop = dora.threadLoop -- 1
local App = dora.App -- 1
local ImGui = dora.ImGui -- 1
local Sequence = dora.Sequence -- 1
local Event = dora.Event -- 1
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
		scene.touchEnabled = true -- 8
		scene:slot("TapEnded", function(touch) -- 9
			local location = touch.location -- 10
			return positionGroup:each(function(entity) -- 11
				entity.target = location -- 12
			end) -- 12
		end) -- 9
		return false -- 12
	end) -- 7
end -- 6
do -- 14
	local _with_0 = Observer("Add", { -- 14
		"image" -- 14
	}) -- 14
	_with_0:watch(function(self, image) -- 15
		sceneGroup:each(function(e) -- 15
			do -- 16
				local _with_1 = Sprite(image) -- 16
				self.sprite = _with_1 -- 16
				_with_1:addTo(e.scene) -- 17
				_with_1:runAction(Scale(0.5, 0, 0.5, Ease.OutBack)) -- 18
			end -- 16
			return true -- 19
		end) -- 15
		return false -- 19
	end) -- 15
end -- 14
do -- 21
	local _with_0 = Observer("Remove", { -- 21
		"sprite" -- 21
	}) -- 21
	_with_0:watch(function(self) -- 22
		return self.oldValues.sprite:removeFromParent() -- 22
	end) -- 22
end -- 21
do -- 24
	local _with_0 = Observer("Remove", { -- 24
		"target" -- 24
	}) -- 24
	_with_0:watch(function(self) -- 25
		return print("remove target from entity " .. tostring(self.index)) -- 25
	end) -- 25
end -- 24
do -- 27
	local _with_0 = Group({ -- 27
		"position", -- 27
		"direction", -- 27
		"speed", -- 27
		"target" -- 27
	}) -- 27
	_with_0:watch(function(self, position, direction, speed, target) -- 28
		if target == position then -- 29
			return -- 29
		end -- 29
		local dir = target - position -- 30
		dir = dir:normalize() -- 31
		local angle = math.deg(math.atan(dir.x, dir.y)) -- 32
		local newPos = position + dir * speed -- 33
		newPos = newPos:clamp(position, target) -- 34
		self.position = newPos -- 35
		self.direction = angle -- 36
		if newPos == target then -- 37
			self.target = nil -- 37
		end -- 37
		return false -- 37
	end) -- 28
end -- 27
do -- 39
	local _with_0 = Observer("AddOrChange", { -- 39
		"position", -- 39
		"direction", -- 39
		"sprite" -- 39
	}) -- 39
	_with_0:watch(function(self, position, direction, sprite) -- 40
		sprite.position = position -- 41
		local lastDirection = self.oldValues.direction or sprite.angle -- 42
		if math.abs(direction - lastDirection) > 1 then -- 43
			sprite:runAction(Roll(0.3, lastDirection, direction)) -- 44
		end -- 43
		return false -- 44
	end) -- 40
end -- 39
Entity({ -- 47
	scene = Node() -- 47
}) -- 46
Entity({ -- 50
	image = "Image/logo.png", -- 50
	position = Vec2.zero, -- 51
	direction = 45.0, -- 52
	speed = 4.0 -- 53
}) -- 49
Entity({ -- 56
	image = "Image/logo.png", -- 56
	position = Vec2(-100, 200), -- 57
	direction = 90.0, -- 58
	speed = 10.0 -- 59
}) -- 55
local windowFlags = { -- 64
	"NoDecoration", -- 64
	"AlwaysAutoResize", -- 65
	"NoSavedSettings", -- 66
	"NoFocusOnAppearing", -- 67
	"NoNav", -- 68
	"NoMove" -- 69
} -- 63
return threadLoop(function() -- 70
	local width -- 71
	width = App.visualSize.width -- 71
	ImGui.SetNextWindowBgAlpha(0.35) -- 72
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 73
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 74
	return ImGui.Begin("ECS System", windowFlags, function() -- 75
		ImGui.Text("ECS System (Yuescript)") -- 76
		ImGui.Separator() -- 77
		ImGui.TextWrapped("Tap any place to move entities.") -- 78
		if ImGui.Button("Create Random Entity") then -- 79
			Entity({ -- 81
				image = "Image/logo.png", -- 81
				position = Vec2(6 * math.random(1, 100), 6 * math.random(1, 100)), -- 82
				direction = 1.0 * math.random(0, 360), -- 83
				speed = 1.0 * math.random(1, 20) -- 84
			}) -- 80
		end -- 79
		if ImGui.Button("Destroy An Entity") then -- 85
			return Group({ -- 86
				"sprite", -- 86
				"position" -- 86
			}):each(function(entity) -- 86
				entity.position = nil -- 87
				do -- 88
					local _with_0 = entity.sprite -- 88
					_with_0:runAction(Sequence(Scale(0.5, 0.5, 0, Ease.InBack), Event("Destroy"))) -- 89
					_with_0:slot("Destroy", function() -- 90
						return entity:destroy() -- 90
					end) -- 90
				end -- 88
				return true -- 91
			end) -- 91
		end -- 85
	end) -- 91
end) -- 91
