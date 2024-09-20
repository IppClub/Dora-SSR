-- [ts]: Entity MoveTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____Dora = require("Dora") -- 4
local App = ____Dora.App -- 4
local Ease = ____Dora.Ease -- 4
local Entity = ____Dora.Entity -- 4
local Event = ____Dora.Event -- 4
local Group = ____Dora.Group -- 4
local Node = ____Dora.Node -- 4
local Observer = ____Dora.Observer -- 4
local Roll = ____Dora.Roll -- 4
local Scale = ____Dora.Scale -- 4
local Sequence = ____Dora.Sequence -- 4
local Sprite = ____Dora.Sprite -- 4
local Vec2 = ____Dora.Vec2 -- 4
local tolua = ____Dora.tolua -- 4
local sceneGroup = Group({"scene"}) -- 6
local positionGroup = Group({"position"}) -- 7
local function toNode(item) -- 9
	return tolua.cast(item, "Node") -- 10
end -- 9
Observer("Add", {"scene"}):watch(function(_, scene) -- 13
	scene:onTapEnded(function(touch) -- 14
		local ____touch_0 = touch -- 15
		local location = ____touch_0.location -- 15
		positionGroup:each(function(entity) -- 16
			entity.target = location -- 17
			return false -- 18
		end) -- 16
	end) -- 14
	return false -- 21
end) -- 13
Observer("Add", {"image"}):watch(function(entity, image) -- 24
	sceneGroup:each(function(e) -- 25
		local scene = toNode(e.scene) -- 26
		if scene ~= nil then -- 26
			local sprite = Sprite(image) -- 28
			if sprite then -- 28
				sprite:addTo(scene) -- 30
				sprite:runAction(Scale(0.5, 0, 0.5, Ease.OutBack)) -- 31
				entity.sprite = sprite -- 32
			end -- 32
			return true -- 34
		end -- 34
		return false -- 36
	end) -- 25
	return false -- 38
end) -- 24
Observer("Remove", {"sprite"}):watch(function(entity) -- 41
	local sprite = toNode(entity.oldValues.sprite) -- 42
	if sprite ~= nil then -- 42
		sprite:removeFromParent() -- 43
	end -- 43
	return false -- 44
end) -- 41
Observer("Remove", {"target"}):watch(function(entity) -- 47
	print("remove target from entity " .. tostring(entity.index)) -- 48
	return false -- 49
end) -- 47
Group({"position", "direction", "speed", "target"}):watch(function(entity, position, _direction, speed, target) -- 52
	if target:equals(position) then -- 52
		return false -- 54
	end -- 54
	local dir = target:sub(position):normalize() -- 55
	local angle = math.deg(math.atan(dir.x, dir.y)) -- 56
	local newPos = position:add(dir:mul(speed)) -- 57
	newPos = newPos:clamp(position, target) -- 58
	entity.position = newPos -- 59
	entity.direction = angle -- 60
	if newPos:equals(target) then -- 60
		entity.target = nil -- 62
	end -- 62
	return false -- 64
end) -- 53
Observer("AddOrChange", {"position", "direction", "sprite"}):watch(function(entity, position, direction, sprite) -- 67
	sprite.position = position -- 69
	local ____entity_oldValues_direction_3 = entity.oldValues.direction -- 70
	if ____entity_oldValues_direction_3 == nil then -- 70
		____entity_oldValues_direction_3 = sprite.angle -- 70
	end -- 70
	local lastDirection = ____entity_oldValues_direction_3 -- 70
	if type(lastDirection) == "number" then -- 70
		if math.abs(direction - lastDirection) > 1 then -- 70
			sprite:runAction(Roll(0.3, lastDirection, direction)) -- 73
		end -- 73
	end -- 73
	return false -- 76
end) -- 68
Entity({scene = Node()}) -- 86
local def = {image = "Image/logo.png", position = Vec2.zero, direction = 45, speed = 4} -- 88
Entity(def) -- 94
def = { -- 96
	image = "Image/logo.png", -- 97
	position = Vec2(-100, 200), -- 98
	direction = 90, -- 99
	speed = 10 -- 100
} -- 100
Entity(def) -- 102
local windowFlags = { -- 104
	"NoDecoration", -- 105
	"AlwaysAutoResize", -- 106
	"NoSavedSettings", -- 107
	"NoFocusOnAppearing", -- 108
	"NoNav", -- 109
	"NoMove" -- 110
} -- 110
Observer("Add", {"scene"}):watch(function(entity) -- 112
	local scene = toNode(entity.scene) -- 113
	if scene ~= nil then -- 113
		scene:schedule(function() -- 115
			local ____App_visualSize_4 = App.visualSize -- 116
			local width = ____App_visualSize_4.width -- 116
			ImGui.SetNextWindowBgAlpha(0.35) -- 117
			ImGui.SetNextWindowPos( -- 118
				Vec2(width - 10, 10), -- 118
				"Always", -- 118
				Vec2(1, 0) -- 118
			) -- 118
			ImGui.SetNextWindowSize( -- 119
				Vec2(240, 0), -- 119
				"FirstUseEver" -- 119
			) -- 119
			ImGui.Begin( -- 120
				"ECS System", -- 120
				windowFlags, -- 120
				function() -- 120
					ImGui.Text("ECS System (Typescript)") -- 121
					ImGui.Separator() -- 122
					ImGui.TextWrapped("Tap any place to move entities.") -- 123
					if ImGui.Button("Create Random Entity") then -- 123
						local def = { -- 125
							image = "Image/logo.png", -- 126
							position = Vec2( -- 127
								6 * math.random(1, 100), -- 127
								6 * math.random(1, 100) -- 127
							), -- 127
							direction = 1 * math.random(0, 360), -- 128
							speed = 1 * math.random(1, 20) -- 129
						} -- 129
						Entity(def) -- 131
					end -- 131
					if ImGui.Button("Destroy An Entity") then -- 131
						Group({"sprite", "position"}):each(function(e) -- 134
							e.position = nil -- 135
							local sprite = toNode(e.sprite) -- 136
							if sprite ~= nil then -- 136
								sprite:runAction(Sequence( -- 138
									Scale(0.5, 0.5, 0, Ease.InBack), -- 140
									Event("Destroy") -- 141
								)) -- 141
								sprite:slot( -- 144
									"Destroy", -- 144
									function() -- 144
										e:destroy() -- 145
									end -- 144
								) -- 144
							end -- 144
							return true -- 148
						end) -- 134
					end -- 134
				end -- 120
			) -- 120
			return false -- 152
		end) -- 115
	end -- 115
	return false -- 155
end) -- 112
return ____exports -- 112