local Vec2 <const> = require("Vec2")
local DrawNode <const> = require("DrawNode")
local Model <const> = require("Model")
local Sequence <const> = require("Sequence")
local X <const> = require("X")
local Event <const> = require("Event")
local Node <const> = require("Node")
local ClipNode <const> = require("ClipNode")
local Line <const> = require("Line")
local App <const> = require("App")
local Director <const> = require("Director")
local Action <const> = require("Action")

local function StarVertices(radius: number, line: boolean): {Vec2.Type}
	local a = math.rad(36)
	local c = math.rad(72)
	local f = math.sin(a) * math.tan(c) + math.cos(a)
	local R = radius
	local r = R / f
	local vecs = { }
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
		Event("Turn")
	)
)
targetA:slot("ActionEnd", function(action: Action.Type)
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
exampleA:addTo(Director.entry)
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
		X(1.5, 200, -200)
	)
)
targetB:slot("ActionEnd", function(action: Action.Type)
	targetB:runAction(action)
end)

local exampleB = Node()
local clipNodeB = ClipNode(maskB)
clipNodeB:addChild(targetB)
clipNodeB.inverted = true
clipNodeB.alphaThreshold = 0.3
exampleB:addChild(clipNodeB)
exampleB:addTo(Director.entry)

-- example codes ends here, some test ui below --

local ImGui <const> = require("ImGui")

local inverted = true
local withAlphaThreshold = true
local ui = Node()
local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove"
}
ui:schedule(function(): boolean
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
Director.entry:addChild(ui)
