
local Vec2 <const> = require("Vec2")
local PhysicsWorld <const> = require("PhysicsWorld")
local Label <const> = require("Label")
local BodyDef <const> = require("BodyDef")
local Body <const> = require("Body")
local Line <const> = require("Line")
local App <const> = require("App")
local threadLoop <const> = require("threadLoop")

local gravity <const> = Vec2(0, -10)

local world = PhysicsWorld()
world:setShouldContact(0, 0, true)
world.showDebug = true

local label = Label("sarasa-mono-sc-regular", 30)
label:addTo(world)

local terrainDef = BodyDef()
local count <const> = 50
local radius <const> = 300
local vertices = {}
local index = 1
for i = 1, count + 1 do
	local angle = 2 * math.pi * i / count
	vertices[index] = Vec2(radius * math.cos(angle), radius * math.sin(angle))
	index = index + 1
end
terrainDef:attachChain(vertices, 0.4, 0)
terrainDef:attachDisk(Vec2(0, -270), 30, 1, 0, 1.0)
terrainDef:attachPolygon(Vec2(0, 80), 120, 30, 0, 1, 0, 1.0)

local terrain = Body(terrainDef, world)
terrain:addTo(world)

local drawNode = Line({
	Vec2(-20, 0),
	Vec2(20, 0),
	Vec2.zero,
	Vec2(0, -20),
	Vec2(0, 20),
}, App.themeColor)
drawNode:addTo(world)

local diskDef = BodyDef()
diskDef.type = "Dynamic"
diskDef.linearAcceleration = gravity
diskDef:attachDisk(20, 5, 0.8, 1)

local disk = Body(diskDef, world, Vec2(100, 200))
disk:addTo(world)
disk.angularRate = -1800
disk.receivingContact = true
disk:slot("ContactStart", function(_, point)
	drawNode.position = point
	label.text = string.format("Contact: [%.0f,%.0f]", point.x, point.y)
end)



local ImGui <const> = require("ImGui")

local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove",
}
local receivingContact = disk.receivingContact
threadLoop(function()
	local width = App.visualSize.width
	ImGui.SetNextWindowBgAlpha(0.35)
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver")
	ImGui.Begin("Contact", windowFlags, function()
		ImGui.Text("Contact (Teal)")
		ImGui.Separator()
		ImGui.TextWrapped("Receive events when physics bodies contact.")
		local changed = false
		changed, receivingContact = ImGui.Checkbox("Receiving Contact", receivingContact)
		if changed then
			disk.receivingContact = receivingContact
			label.text = ""
		end
	end)
end)