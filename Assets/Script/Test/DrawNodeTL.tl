local Vec2 <const> = require("Vec2")
local threadLoop <const> = require("threadLoop")
local Node <const> = require("Node")
local DrawNode <const> = require("DrawNode")
local Color <const> = require("Color")
local App <const> = require("App")
local Line <const> = require("Line")

local function CircleVertices(radius: number, verts?: integer): {Vec2.Type}
	if verts == nil then
		verts = 20
	end
	local function newV(index: integer, r: number): Vec2.Type
		local angle = 2 * math.pi * index / verts
		return Vec2(r * math.cos(angle), radius * math.sin(angle)) + Vec2(r, radius)
	end
	local vs = { }
	local count = 1
	for index = 0, verts do
		vs[count] = newV(index, radius)
		count = count + 1
	end
	return vs
end

local function StarVertices(radius: number): {Vec2.Type}
	local a = math.rad(36)
	local c = math.rad(72)
	local f = math.sin(a) * math.tan(c) + math.cos(a)
	local R = radius
	local r = R / f
	local vs = { }
	local count = 1
	for i = 9, 0, -1 do
		local angle = i * a
		local cr = i % 2 == 1 and r or R
		vs[count] = Vec2(cr * math.sin(angle), cr * math.cos(angle))
		count = count + 1
	end
	return vs
end

local node = Node()

local star = DrawNode()
star.position = Vec2(200, 200)
star:drawPolygon(StarVertices(60), Color(0x80ff0080), 1, Color(0xffff0080))
star:addTo(node)

local themeColor = App.themeColor

local circle = Line(CircleVertices(60), themeColor)
circle.position = Vec2(-200, 200)
circle:addTo(node)

local camera = Node()
camera.color = themeColor
camera.scaleX = 2
camera.scaleY = 2
camera:addTo(node)

local cameraFill = DrawNode()
cameraFill.opacity = 0.5
cameraFill:drawPolygon{
	Vec2(-20, -10),
	Vec2(20, -10),
	Vec2(20, 10),
	Vec2(-20, 10)
}
cameraFill:drawPolygon{
	Vec2(20, 3),
	Vec2(32, 10),
	Vec2(32, -10),
	Vec2(20, -3)
}
cameraFill:drawDot(Vec2(-11, 20), 10)
cameraFill:drawDot(Vec2(11, 20), 10)
cameraFill:addTo(camera)

local cameraLine = Line{
	Vec2(0, 0),
	Vec2(40, 0),
	Vec2(40, 20),
	Vec2(0, 20),
	Vec2(0, 0)
}
cameraLine.position = Vec2(-20, -10)
cameraLine = Line(CircleVertices(10))
cameraLine.position = Vec2(-21, 10)
cameraLine:addTo(camera)

cameraLine = Line(CircleVertices(10))
cameraLine.position = Vec2(1, 10)
cameraLine:addTo(camera)

cameraLine = Line{
	Vec2(20, 3),
	Vec2(32, 10),
	Vec2(32, -10),
	Vec2(20, -3)
}
cameraLine:addTo(camera)

-- example codes ends here, some test ui below --

local ImGui <const> = require("ImGui")

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
	ImGui.Begin("Draw Node", windowFlags, function()
		ImGui.Text("Draw Node")
		ImGui.Separator()
		ImGui.TextWrapped("Draw shapes and lines!")
	end)
end)
