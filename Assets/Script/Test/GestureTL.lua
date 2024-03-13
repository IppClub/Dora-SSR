local nvg = require("nvg")
local Sprite = require("Sprite")
local Vec2 = require("Vec2")
local View = require("View")
local threadLoop = require("threadLoop")
local Node = require("Node")

local texture = nvg.GetDoraSSR()
local sprite = Sprite(texture)
local length = Vec2(View.size).length
local width, height = sprite.width, sprite.height
local size = Vec2(width, height).length
local scaledSize = size

local node = Node()
node:addChild(sprite)
node.touchEnabled = true
node:slot("Gesture", function(center, _numFingers, deltaDist, deltaAngle)
	sprite.position = center
	sprite.angle = sprite.angle + deltaAngle
	scaledSize = scaledSize + (deltaDist * length)
	sprite.scaleX = scaledSize / size
	sprite.scaleY = scaledSize / size
end)



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
threadLoop(function()
	local w = App.visualSize.width
	ImGui.SetNextWindowBgAlpha(0.35)
	ImGui.SetNextWindowPos(Vec2(w - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver")
	ImGui.Begin("Gesture", windowFlags, function()
		ImGui.Text("Gesture")
		ImGui.Separator()
		ImGui.TextWrapped("Interact with multi-touches!")
	end)
end)