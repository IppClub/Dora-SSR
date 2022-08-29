local Group <const> = require("Group")
local Observer <const> = require("Observer")
local Director <const> = require("Director")
local Scale <const> = require("Scale")
local Ease <const> = require("Ease")
local Roll <const> = require("Roll")
local Entity <const> = require("Entity")
local Sprite <const> = require("Sprite")
local Vec2 <const> = require("Vec2")
local Node <const> = require("Node")
local Sequence <const> = require("Sequence")
local Event <const> = require("Event")
local Touch <const> = require("Touch")
local tolua <const> = require("tolua")

local sceneGroup = Group { "scene" }
local positionGroup = Group { "position" }

local function toNode(item: Entity.Item): Node.Type | nil
	if item is Entity.ContainerItem then
		return tolua.cast(item, "Node")
	end
end

Observer("Add", { "scene" }):watch(function(_self: Entity.Type, scene: Node.Type)
	scene.touchEnabled = true
	scene:slot("TapEnded", function(touch: Touch.Type)
		local location = touch.location
		positionGroup:each(function(entity: Entity.Type): boolean
			entity.target = location
			return false
		end)
	end)
	scene:addTo(Director.entry)
end)

Observer("Add", { "sprite" }):watch(function(_self: Entity.Type, sprite: Sprite.Type)
	sceneGroup:each(function(e: Entity.Type): boolean
		local scene = toNode(e.scene)
		if not scene is nil then
			sprite:runAction(Scale(0.5, 0, 0.5, Ease.OutBack))
			scene:addChild(sprite)
			return true
		end
		return false
	end)
end)

Observer("Remove", { "sprite" }):watch(function(self: Entity.Type)
	sceneGroup:each(function(e: Entity.Type): boolean
		local scene = toNode(e.scene)
		if not scene is nil then
			local sprite = toNode(self.oldValues.sprite)
			if not sprite is nil then
				scene:addChild(sprite)
				return true
			end
		end
		return false
	end)
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

Entity {
	sprite = Sprite("Image/logo.png"),
	position = Vec2.zero,
	direction = 45.0,
	speed = 4.0
}

Entity {
	sprite = Sprite("Image/logo.png"),
	position = Vec2(-100, 200),
	direction = 90.0,
	speed = 10.0
}

Entity { scene = Node() }

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
					Entity {
						sprite = Sprite("Image/logo.png"),
						position = Vec2(6 * math.random(1, 100), 6 * math.random(1, 100)),
						direction = 1.0 * math.random(0, 360),
						speed = 1.0 * math.random(1, 20)
					}
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
