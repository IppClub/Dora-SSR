local Vec2 = require("Vec2")
local DrawNode = require("DrawNode")
local Model = require("Model")
local Sequence = require("Sequence")
local X = require("X")
local Event = require("Event")
local Node = require("Node")
local ClipNode = require("ClipNode")
local Line = require("Line")
local App = require("App")
local threadLoop = require("threadLoop")
local Action = require("Action")

local function StarVertices(radius, line)
	local a = math.rad(36)
	local c = math.rad(72)
	local f = math.sin(a) * math.tan(c) + math.cos(a)
	local R = radius
	local r = R / f
	local vecs = {}
	local count = 1
	for i = 9, line and -1 or 0, -1 do
		local angle = i * a
		local cr = i % 2 == 1 and r or R
		vecs[count] = Vec2(cr * math.sin(angle), cr * math.cos(angle))
		count = count + 1
	end
	return vecs
end

local maskA = DrawNode()
maskA:drawPolygon(StarVertices(160, false))

local targetA = Model("Model/xiaoli.model")
targetA.look = "happy"
targetA.fliped = true
targetA:play("walk", true)
targetA:runAction(
Sequence(
X(1.5, -200, 200),
Event("Turn"),
X(1.5, 200, -200),
Event("Turn")))


targetA:slot("ActionEnd", function(action)
	targetA:runAction(action)
end)
targetA:slot("Turn", function()
	targetA.fliped = not targetA.fliped
end)

local exampleA = Node()
local clipNodeA = ClipNode(maskA)
clipNodeA:addChild(targetA)
clipNodeA.inverted = true
exampleA:addChild(clipNodeA)

local frame = Line(StarVertices(160, true), App.themeColor)
frame.visible = false
exampleA:addChild(frame)
exampleA.visible = false

local maskB = Model("Model/xiaoli.model")
maskB.look = "happy"
maskB.fliped = true
maskB:play("walk", true)

local targetB = DrawNode()
targetB:drawPolygon(StarVertices(160, false))
targetB:runAction(
Sequence(
X(1.5, -200, 200),
X(1.5, 200, -200)))


targetB:slot("ActionEnd", function(action)
	targetB:runAction(action)
end)

local exampleB = Node()
local clipNodeB = ClipNode(maskB)
clipNodeB:addChild(targetB)
clipNodeB.inverted = true
clipNodeB.alphaThreshold = 0.3
exampleB:addChild(clipNodeB)



local ImGui = require("ImGui")

local inverted = true
local withAlphaThreshold = true
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
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver")
	ImGui.Begin("Clip Node", windowFlags, function()
		ImGui.Text("Clip Node")
		ImGui.Separator()
		ImGui.TextWrapped("Render children nodes with mask!")
		local changed = false
		changed, inverted = ImGui.Checkbox("Inverted", inverted)
		if changed then
			clipNodeA.inverted = inverted
			clipNodeB.inverted = inverted
			frame.visible = not inverted
		end
		changed, withAlphaThreshold = ImGui.Checkbox("With alphaThreshold", withAlphaThreshold)
		if changed then
			exampleB.visible = withAlphaThreshold
			exampleA.visible = not withAlphaThreshold
		end
	end)
end)