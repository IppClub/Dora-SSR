local Group = require("Group")
local Observer = require("Observer")
local Scale = require("Scale")
local Ease = require("Ease")
local Roll = require("Roll")
local Entity = require("Entity")
local Sprite = require("Sprite")
local Vec2 = require("Vec2")
local Node = require("Node")
local Sequence = require("Sequence")
local Event = require("Event")

local tolua = require("tolua")

local sceneGroup = Group({ "scene" })
local positionGroup = Group({ "position" })


local function toNode(item)
	return tolua.cast(item, "Node")
end

Observer("Add", { "scene" }):watch(function(_entity, scene)
	scene.touchEnabled = true
	scene:slot("TapEnded", function(touch)
		local location = touch.location
		positionGroup:each(function(entity)
			entity.target = location
			return false
		end)
	end)
end)

Observer("Add", { "image" }):watch(function(self, image)
	sceneGroup:each(function(e)
		local scene = toNode(e.scene)
		if not (scene == nil) then
			local sprite = Sprite(image)
			if sprite == nil then
				return false
			end
			sprite:addTo(scene)
			sprite:runAction(Scale(0.5, 0, 0.5, Ease.OutBack))
			self.sprite = sprite
			return true
		end
	end)
end)

Observer("Remove", { "sprite" }):watch(function(self)
	local sprite = toNode(self.oldValues.sprite)
	if not (sprite == nil) then
		sprite:removeFromParent()
	end
end)

Observer("Remove", { "target" }):watch(function(self)
	print("remove target from entity " .. tostring(self.index))
end)

Group({ "position", "direction", "speed", "target" }):watch(
function(self, position, _direction, speed, target)
	if target == position then
		return
	end
	local dir = target - position
	dir = dir:normalize()
	local angle = math.deg(math.atan(dir.x, dir.y))
	local newPos = position + dir * speed
	newPos = newPos:clamp(position, target)
	self.position = newPos
	self.direction = angle
	if newPos == target then
		self.target = nil
	end
end)

Observer("AddOrChange", { "position", "direction", "sprite" }):watch(
function(self, position, direction, sprite)
	sprite.position = position
	local lastDirection = self.oldValues.direction or sprite.angle
	if type(lastDirection) == "number" then
		if math.abs(direction - lastDirection) > 1 then
			sprite:runAction(Roll(0.3, lastDirection, direction))
		end
	end
end)








Entity({ scene = Node() })

do
	local def = {
		image = "Image/logo.png",
		position = Vec2.zero,
		direction = 45.0,
		speed = 4.0,
	}
	Entity(def)
end

do
	local def = {
		image = "Image/logo.png",
		position = Vec2(-100, 200),
		direction = 90.0,
		speed = 10.0,
	}
	Entity(def)
end



local App = require("App")
local ImGui = require("ImGui")

local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove",
}
Observer("Add", { "scene" }):watch(function(entity)
	local scene = toNode(entity.scene)
	if not (scene == nil) then
		scene:schedule(function()
			local width = App.visualSize.width
			ImGui.SetNextWindowBgAlpha(0.35)
			ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0))
			ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver")
			ImGui.Begin("ECS System", windowFlags, function()
				ImGui.Text("ECS System")
				ImGui.Separator()
				ImGui.TextWrapped("Tap any place to move entities.")
				if ImGui.Button("Create Random Entity") then
					local def = {
						image = "Image/logo.png",
						position = Vec2(6 * math.random(1, 100), 6 * math.random(1, 100)),
						direction = 1.0 * math.random(0, 360),
						speed = 1.0 * math.random(1, 20),
					}
					Entity(def)
				end
				if ImGui.Button("Destroy An Entity") then
					Group({ "sprite", "position" }):each(function(e)
						e.position = nil
						local sprite = toNode(e.sprite)
						if not (sprite == nil) then
							sprite:runAction(
							Sequence(
							Scale(0.5, 0.5, 0, Ease.InBack),
							Event("Destroy")))


							sprite:slot("Destroy", function()
								e:destroy()
							end)
						end
						return true
					end)
				end
			end)
		end)
	end
end)