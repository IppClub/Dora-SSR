local Node <const> = require("Node")
local Vec2 <const> = require("Vec2")
local Sprite <const> = require("Sprite")
local DrawNode <const> = require("DrawNode")
local Color <const> = require("Color")
local App <const> = require("App")
local Line <const> = require("Line")
local Angle <const> = require("Angle")
local Size <const> = require("Size")
local threadLoop <const> = require("threadLoop")
local Action <const> = require("Action")

local function Item(): Node.Type
	local node = Node()
	node.width = 144
	node.height = 144
	node.anchor = Vec2.zero

	local sprite = Sprite("Image/logo.png")
	if sprite is nil then
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
		Vec2(-60, 60)
	}, Color(App.themeColor:toColor3(), 0x30))
	drawNode.renderOrder = 2
	drawNode.angle = 45
	drawNode:addTo(node)

	local line = Line({
		Vec2(-60, -60),
		Vec2(60, -60),
		Vec2(60, 60),
		Vec2(-60, 60),
		Vec2(-60, -60)
	}, Color(0xffff0080))
	line.renderOrder = 3
	line.angle = 45
	line:addTo(node)

	node:runAction(Angle(5, 0, 360))
	node:slot("ActionEnd", function(action: Action.Type)
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

-- example codes ends here, some test ui below --

local ImGui <const> = require("ImGui")

local renderGroup = currentEntry.renderGroup
local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove"
}
threadLoop(function(): boolean
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
