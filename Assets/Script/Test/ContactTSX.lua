-- [tsx]: ContactTSX.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local useRef = ____DoraX.useRef -- 2
local ImGui = require("ImGui") -- 4
local ____Dora = require("Dora") -- 5
local App = ____Dora.App -- 5
local Vec2 = ____Dora.Vec2 -- 5
local threadLoop = ____Dora.threadLoop -- 5
local gravity = Vec2(0, -10) -- 7
local anchor = useRef() -- 8
local label = useRef() -- 9
local disk = useRef() -- 10
toNode(React.createElement( -- 12
	"physics-world", -- 12
	{showDebug = true}, -- 12
	React.createElement("contact", {groupA = 0, groupB = 0, enabled = true}), -- 12
	React.createElement("label", {ref = label, fontName = "sarasa-mono-sc-regular", fontSize = 30}), -- 12
	React.createElement( -- 12
		"body", -- 12
		{type = "Static"}, -- 12
		React.createElement( -- 12
			"chain-fixture", -- 12
			{ -- 12
				verts = (function() -- 12
					local count = 50 -- 21
					local radius = 300 -- 22
					local vertices = {} -- 23
					for i = 0, count + 1 do -- 23
						local angle = 2 * math.pi * i / count -- 25
						vertices[#vertices + 1] = Vec2( -- 26
							radius * math.cos(angle), -- 26
							radius * math.sin(angle) -- 26
						) -- 26
					end -- 26
					return vertices -- 28
				end)(), -- 20
				friction = 0.4, -- 20
				restitution = 0 -- 20
			} -- 20
		), -- 20
		React.createElement("disk-fixture", {radius = 30, centerY = -270, friction = 0, restitution = 1}) -- 20
	), -- 20
	React.createElement( -- 20
		"body", -- 20
		{ -- 20
			type = "Static", -- 20
			onContactFilter = function(other) -- 20
				return other.velocityY < 0 -- 37
			end -- 36
		}, -- 36
		React.createElement("rect-fixture", { -- 36
			width = 120, -- 36
			height = 30, -- 36
			centerY = -60, -- 36
			friction = 0, -- 36
			restitution = 1 -- 36
		}) -- 36
	), -- 36
	React.createElement( -- 36
		"line", -- 36
		{ -- 36
			ref = anchor, -- 36
			verts = { -- 36
				Vec2(-20, 0), -- 43
				Vec2(20, 0), -- 44
				Vec2.zero, -- 45
				Vec2(0, -20), -- 46
				Vec2(0, 20) -- 47
			}, -- 47
			lineColor = App.themeColor:toARGB() -- 47
		} -- 47
	), -- 47
	React.createElement( -- 47
		"body", -- 47
		{ -- 47
			ref = disk, -- 47
			type = "Dynamic", -- 47
			linearAcceleration = gravity, -- 47
			angularRate = -2200, -- 47
			x = 100, -- 47
			y = 200, -- 47
			onContactStart = function(_other, point, _normal, enabled) -- 47
				if not enabled then -- 47
					return -- 57
				end -- 57
				if anchor.current then -- 57
					anchor.current.position = point -- 59
				end -- 59
				if label.current then -- 59
					label.current.text = string.format("Contact: [%.0f,%.0f]", point.x, point.y) -- 62
				end -- 62
			end -- 56
		}, -- 56
		React.createElement("disk-fixture", {radius = 20, density = 5, friction = 0.8, restitution = 1}) -- 56
	) -- 56
)) -- 56
local windowFlags = { -- 71
	"NoDecoration", -- 72
	"AlwaysAutoResize", -- 73
	"NoSavedSettings", -- 74
	"NoFocusOnAppearing", -- 75
	"NoNav", -- 76
	"NoMove" -- 77
} -- 77
local ____opt_0 = disk.current -- 77
local ____temp_2 = ____opt_0 and ____opt_0.receivingContact -- 79
if ____temp_2 == nil then -- 79
	____temp_2 = true -- 79
end -- 79
local receivingContact = ____temp_2 -- 79
threadLoop(function() -- 80
	local ____App_visualSize_3 = App.visualSize -- 81
	local width = ____App_visualSize_3.width -- 81
	ImGui.SetNextWindowBgAlpha(0.35) -- 82
	ImGui.SetNextWindowPos( -- 83
		Vec2(width - 10, 10), -- 83
		"Always", -- 83
		Vec2(1, 0) -- 83
	) -- 83
	ImGui.SetNextWindowSize( -- 84
		Vec2(240, 0), -- 84
		"FirstUseEver" -- 84
	) -- 84
	ImGui.Begin( -- 85
		"Contact", -- 85
		windowFlags, -- 85
		function() -- 85
			ImGui.Text("Contact (TSX)") -- 86
			ImGui.Separator() -- 87
			ImGui.TextWrapped("Receive events when physics bodies contact.") -- 88
			local changed = false -- 89
			changed, receivingContact = ImGui.Checkbox("Receiving Contact", receivingContact) -- 90
			if changed then -- 90
				if disk.current then -- 90
					disk.current.receivingContact = receivingContact -- 93
				end -- 93
				if label.current then -- 93
					label.current.text = "" -- 96
				end -- 96
			end -- 96
		end -- 85
	) -- 85
	return false -- 100
end) -- 80
return ____exports -- 80