local DragonBone = require("DragonBone")
local Label = require("Label")
local App = require("App")
local Sequence = require("Sequence")
local Spawn = require("Spawn")
local Scale = require("Scale")
local Ease = require("Ease")
local Delay = require("Delay")
local Opacity = require("Opacity")
local Event = require("Event")
local Vec2 = require("Vec2")
local threadLoop = require("threadLoop")


local boneStr = "DragonBones/NewDragon"
local animations = DragonBone:getAnimations(boneStr)
local looks = DragonBone:getLooks(boneStr)

p(animations, looks)

local bone = DragonBone(boneStr)
if bone == nil then
	return
end
bone.look = looks[1]
bone:play(animations[1], true)
bone:slot("AnimationEnd", function(name)
	print(name .. " end!")
end)

bone.y = -200
bone.touchEnabled = true
bone:slot("TapBegan", function(touch)
	local loc = touch.location
	local x, y = loc.x, loc.y
	local name = bone:containsPoint(x, y)
	if not (name == nil) then
		local label = Label("sarasa-mono-sc-regular", 30)
		label.text = name
		label.color = App.themeColor
		label.position = Vec2(x, y)
		label.order = 100
		label:perform(
		Sequence(
		Spawn(
		Scale(1, 0, 2, Ease.OutQuad),
		Sequence(
		Delay(0.5),
		Opacity(0.5, 1, 0))),


		Event("Stop")))


		label:slot("Stop", function()
			label:removeFromParent()
		end)
		bone:addChild(label)
	end
end)



local ImGui = require("ImGui")

local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove",
}
local showDebug = bone.showDebug
threadLoop(function()
	local width = App.visualSize.width
	ImGui.SetNextWindowBgAlpha(0.35)
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver")
	ImGui.Begin("DragonBones", windowFlags, function()
		ImGui.Text("DragonBones")
		ImGui.Separator()
		ImGui.TextWrapped("Basic usage to create dragonBones! Tap it for a hit test.")
		local changed = false
		changed, showDebug = ImGui.Checkbox("BoundingBox", showDebug)
		if changed then
			bone.showDebug = showDebug
		end
	end)
end)