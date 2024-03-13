local Node = require("Node")
local Vec2 = require("Vec2")
local Sprite = require("Sprite")
local DrawNode = require("DrawNode")
local Color = require("Color")
local App = require("App")
local Line = require("Line")
local Angle = require("Angle")
local Size = require("Size")
local threadLoop = require("threadLoop")
local Action = require("Action")

local function Item()
	local node = Node()
	node.width = 144
	node.height = 144
	node.anchor = Vec2.zero

	local sprite = Sprite("Image/logo.png")
	if sprite == nil then
		return node
	end
	sprite.scaleX = 0.1
	sprite.scaleY = 0.1
	sprite.renderOrder = 1
	sprite:addTo(node)

	local drawNode = DrawNode()
	drawNode:drawPolygon({
		Vec2(-60, -60),
		Vec2(60, -60),
		Vec2(60, 60),
		Vec2(-60, 60),
	}, Color(App.themeColor:toColor3(), 0x30))
	drawNode.renderOrder = 2
	drawNode.angle = 45
	drawNode:addTo(node)

	local line = Line({
		Vec2(-60, -60),
		Vec2(60, -60),
		Vec2(60, 60),
		Vec2(-60, 60),
		Vec2(-60, -60),
	}, Color(0xffff0080))
	line.renderOrder = 3
	line.angle = 45
	line:addTo(node)

	node:runAction(Angle(5, 0, 360))
	node:slot("ActionEnd", function(action)
		node:runAction(action)
	end)
	return node
end

local currentEntry = Node()
currentEntry.renderGroup = true
currentEntry.size = Size(750, 750)
for _i = 1, 16 do
	currentEntry:addChild(Item())
end
currentEntry:alignItems()



local ImGui = require("ImGui")

local renderGroup = currentEntry.renderGroup
local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove",
}
threadLoop(function()
	local width = App.visualSize.width
	ImGui.SetNextWindowBgAlpha(0.35)
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver")
	ImGui.Begin("Render Group", windowFlags, function()
		ImGui.Text("Render Group")
		ImGui.Separator()
		ImGui.TextWrapped("When render group is enabled, the nodes in the sub render tree will be grouped by \"renderOrder\" property, and get rendered in ascending order!\nNotice the draw call changes in stats window.")
		local changed = true
		changed, renderGroup = ImGui.Checkbox("Grouped", renderGroup)
		if changed then
			currentEntry.renderGroup = renderGroup
		end
	end)
end)