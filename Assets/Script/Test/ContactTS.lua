-- [ts]: ContactTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____Dora = require("Dora") -- 4
local App = ____Dora.App -- 4
local Body = ____Dora.Body -- 4
local BodyDef = ____Dora.BodyDef -- 4
local Label = ____Dora.Label -- 4
local Line = ____Dora.Line -- 4
local PhysicsWorld = ____Dora.PhysicsWorld -- 4
local Vec2 = ____Dora.Vec2 -- 4
local threadLoop = ____Dora.threadLoop -- 4
local gravity = Vec2(0, -10) -- 6
local world = PhysicsWorld() -- 8
world:setShouldContact(0, 0, true) -- 9
world.showDebug = true -- 10
local ____opt_0 = Label("sarasa-mono-sc-regular", 30) -- 10
local label = ____opt_0 and ____opt_0:addTo(world) -- 12
local terrainDef = BodyDef() -- 14
local count = 50 -- 15
local radius = 300 -- 16
local vertices = {} -- 17
for i = 0, count + 1 do -- 17
	local angle = 2 * math.pi * i / count -- 19
	vertices[#vertices + 1] = Vec2( -- 20
		radius * math.cos(angle), -- 20
		radius * math.sin(angle) -- 20
	) -- 20
end -- 20
terrainDef:attachChain(vertices, 0.4, 0) -- 22
terrainDef:attachDisk( -- 23
	Vec2(0, -270), -- 23
	30, -- 23
	1, -- 23
	0, -- 23
	1 -- 23
) -- 23
terrainDef:attachPolygon( -- 24
	Vec2(0, 80), -- 24
	120, -- 24
	30, -- 24
	0, -- 24
	1, -- 24
	0, -- 24
	1 -- 24
) -- 24
local terrain = Body(terrainDef, world) -- 26
terrain:addTo(world) -- 27
local drawNode = Line( -- 29
	{ -- 29
		Vec2(-20, 0), -- 30
		Vec2(20, 0), -- 31
		Vec2.zero, -- 32
		Vec2(0, -20), -- 33
		Vec2(0, 20) -- 34
	}, -- 34
	App.themeColor -- 35
) -- 35
drawNode:addTo(world) -- 36
local diskDef = BodyDef() -- 38
diskDef.type = "Dynamic" -- 39
diskDef.linearAcceleration = gravity -- 40
diskDef:attachDisk(20, 5, 0.8, 1) -- 41
local disk = Body( -- 43
	diskDef, -- 43
	world, -- 43
	Vec2(100, 200) -- 43
) -- 43
disk:addTo(world) -- 44
disk.angularRate = -1800 -- 45
disk:onContactStart(function(_, point) -- 46
	drawNode.position = point -- 47
	if label ~= nil then -- 47
		label.text = string.format("Contact: [%.0f,%.0f]", point.x, point.y) -- 49
	end -- 49
end) -- 46
local windowFlags = { -- 52
	"NoDecoration", -- 53
	"AlwaysAutoResize", -- 54
	"NoSavedSettings", -- 55
	"NoFocusOnAppearing", -- 56
	"NoNav", -- 57
	"NoMove" -- 58
} -- 58
local receivingContact = disk.receivingContact -- 60
threadLoop(function() -- 61
	local ____App_visualSize_2 = App.visualSize -- 62
	local width = ____App_visualSize_2.width -- 62
	ImGui.SetNextWindowBgAlpha(0.35) -- 63
	ImGui.SetNextWindowPos( -- 64
		Vec2(width - 10, 10), -- 64
		"Always", -- 64
		Vec2(1, 0) -- 64
	) -- 64
	ImGui.SetNextWindowSize( -- 65
		Vec2(240, 0), -- 65
		"FirstUseEver" -- 65
	) -- 65
	ImGui.Begin( -- 66
		"Contact", -- 66
		windowFlags, -- 66
		function() -- 66
			ImGui.Text("Contact (Typescript)") -- 67
			ImGui.Separator() -- 68
			ImGui.TextWrapped("Receive events when physics bodies contact.") -- 69
			local changed = false -- 70
			changed, receivingContact = ImGui.Checkbox("Receiving Contact", receivingContact) -- 71
			if changed then -- 71
				disk.receivingContact = receivingContact -- 73
				if label ~= nil then -- 73
					label.text = "" -- 74
				end -- 74
			end -- 74
		end -- 66
	) -- 66
	return false -- 77
end) -- 61
return ____exports -- 61