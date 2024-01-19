local Group <const> = require("Group")
local Observer <const> = require("Observer")
local Scale <const> = require("Scale")
local Ease <const> = require("Ease")
local Roll <const> = require("Roll")
local Entity <const> = require("Entity")
local Sprite <const> = require("Sprite")
local Vec2 <const> = require("Vec2")
local Node <const> = require("Node")
local Sequence <const> = require("Sequence")
local Event <const> = require("Event")
local type Touch = require("TouchType")
local tolua <const> = require("tolua")

local sceneGroup = Group { "scene" }
local positionGroup = Group { "position" }

-- doing safe type conversions instead of using 'as' keyword
local function toNode(item: any): Node.Type | nil
	return tolua.cast(item, "Node")
end

Observer("Add", { "scene" }):watch(function(_entity: Entity.Type, scene: Node.Type)
	scene.touchEnabled = true
	scene:slot("TapEnded", function(touch: Touch)
		local location = touch.location
		positionGroup:each(function(entity: Entity.Type): boolean
			entity.target = location
			return false
		end)
	end)
end)

Observer("Add", { "image" }):watch(function(self: Entity.Type, image: string)
	sceneGroup:each(function(e: Entity.Type): boolean
		local scene = toNode(e.scene)
		if not scene is nil then
			local sprite = Sprite(image)
			if sprite is nil then
				return false
			end
			sprite:addTo(scene)
			sprite:runAction(Scale(0.5, 0, 0.5, Ease.OutBack))
			self.sprite = sprite
			return true
		end
	end)
end)

Observer("Remove", { "sprite" }):watch(function(self: Entity.Type)
	local sprite = toNode(self.oldValues.sprite)
	if not sprite is nil then
		sprite:removeFromParent()
	end
end)

Observer("Remove", { "target" }):watch(function(self: Entity.Type)
	print("remove target from entity " .. tostring(self.index))
end)

Group({ "position", "direction", "speed", "target" }):watch(
	function(self: Entity.Type, position: Vec2.Type, _direction: number, speed: number, target: Vec2.Type)
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
	function(self: Entity.Type, position: Vec2.Type, direction: number, sprite: Sprite.Type)
	sprite.position = position
	local lastDirection = self.oldValues.direction or sprite.angle
	if lastDirection is number then
		if math.abs(direction - lastDirection) > 1 then
			sprite:runAction(Roll(0.3, lastDirection, direction))
		end
	end
end)

local record EntityDef
	image: string
	position: Vec2.Type
	direction: number
	speed: number
end

Entity { scene = Node() }

do
	local def <total>: EntityDef = {
		image = "Image/logo.png",
		position = Vec2.zero,
		direction = 45.0,
		speed = 4.0
	}
	Entity(def)
end

do
	local def <total>: EntityDef = {
		image = "Image/logo.png",
		position = Vec2(-100, 200),
		direction = 90.0,
		speed = 10.0
	}
	Entity(def)
end

-- example codes ends here, some test ui below --

local App <const> = require("App")
local ImGui <const> = require("ImGui")

local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove"
}
Observer("Add", { "scene" }):watch(function(entity: Entity.Type)
	local scene = toNode(entity.scene)
	if not scene is nil then
		scene:schedule(function(): boolean
			local width = App.visualSize.width
			ImGui.SetNextWindowBgAlpha(0.35)
			ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0))
			ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver")
			ImGui.Begin("ECS System", windowFlags, function()
				ImGui.Text("ECS System")
				ImGui.Separator()
				ImGui.TextWrapped("Tap any place to move entities.")
				if ImGui.Button("Create Random Entity") then
					local def <total>: EntityDef = {
						image = "Image/logo.png",
						position = Vec2(6 * math.random(1, 100), 6 * math.random(1, 100)),
						direction = 1.0 * math.random(0, 360),
						speed = 1.0 * math.random(1, 20)
					}
					Entity(def)
				end
				if ImGui.Button("Destroy An Entity") then
					Group({ "sprite", "position" }):each(function(e: Entity.Type): boolean
						e.position = nil
						local sprite = toNode(e.sprite)
						if not sprite is nil then
							sprite:runAction(
								Sequence(
									Scale(0.5, 0.5, 0, Ease.InBack),
									Event("Destroy")
								)
							)
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
