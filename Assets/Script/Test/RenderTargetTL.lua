local Node = require("Node")
local Spine = require("Spine")
local Sequence = require("Sequence")
local X = require("X")
local Event = require("Event")
local RenderTarget = require("RenderTarget")
local Color = require("Color")
local App = require("App")
local Sprite = require("Sprite")
local Line = require("Line")
local Vec2 = require("Vec2")
local threadLoop = require("threadLoop")
local Action = require("Action")

local root = Node()

local node = Node()
node:addTo(root, 1)

local spine = Spine("Spine/moling")
if spine == nil then
	return
end
spine.y = -200
spine.scaleX = 1.2
spine.scaleY = 1.2
spine.fliped = false
spine:play("fmove", true)
spine:runAction(
Sequence(
X(2, -150, 250),
Event("Turn"),
X(2, 250, -150),
Event("Turn")))


spine:slot("ActionEnd", function(action)
	spine:runAction(action)
end)
spine:slot("Turn", function()
	spine.fliped = not spine.fliped
end)
spine:addTo(node)

local renderTarget = RenderTarget(300, 400)
renderTarget:renderWithClear(Color(0xff8a8a8a))

local surface = Sprite(renderTarget.texture)
surface.z = 300
surface.angleY = 25
surface:addChild(Line({
	Vec2.zero,
	Vec2(300, 0),
	Vec2(300, 400),
	Vec2(0, 400),
	Vec2.zero,
}, App.themeColor))
surface:schedule(function()
	node.y = 200
	renderTarget:renderWithClear(node, Color(0xff8a8a8a))
	node.y = 0
	return false
end)
surface:addTo(root)



local ImGui = require("ImGui")

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
	ImGui.Begin("Render Target", windowFlags, function()
		ImGui.Text("Render Target")
		ImGui.Separator()
		ImGui.TextWrapped("Use render target node as a mirror!")
	end)
end)