-- [tsx]: LabelOutline.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local Color = ____Dora.Color -- 3
local Vec2 = ____Dora.Vec2 -- 3
local threadLoop = ____Dora.threadLoop -- 3
local tolua = ____Dora.tolua -- 3
local ImGui = require("ImGui") -- 5
toNode(React.createElement( -- 7
	"draw-node", -- 7
	nil, -- 7
	React.createElement("rect-shape", {width = 5000, height = 5000, fillColor = 4278190080}) -- 7
)) -- 7
local outlineColor = Color(4294901896) -- 13
local outlineWidth = 0.16 -- 14
local scale = 3 -- 15
local start = App.elapsedTime -- 17
local node = toNode(React.createElement( -- 19
	"label", -- 19
	{ -- 19
		fontName = "sarasa-mono-sc-regular", -- 19
		sdf = true, -- 19
		fontSize = 50, -- 19
		textWidth = 800, -- 19
		color3 = 16499712, -- 19
		outlineColor = outlineColor:toARGB(), -- 19
		outlineWidth = outlineWidth, -- 19
		scaleX = scale, -- 19
		scaleY = scale, -- 19
		showDebug = true -- 19
	}, -- 19
	"Dora SSR is a game engine for rapid development of games on various devices. It has a built-in easy-to-use Web IDE development tool chain that supports direct game development on mobile phones, open source handhelds and other devices. Dora SSR 是一个用于多种设备上快速开发游戏的游戏引擎。它内置易用的 Web IDE 开发工具链，支持在手机、开源掌机等设备上直接进行游戏开发。" -- 19
)) -- 19
print(("label bake time: " .. tostring(App.elapsedTime - start)) .. " s") -- 29
local label = tolua.cast(node, "Label") -- 31
if not label then -- 31
	error("failed") -- 32
end -- 32
local ____label_smooth_0 = label.smooth -- 33
local edgeA = ____label_smooth_0.x -- 33
local edgeB = ____label_smooth_0.y -- 33
local windowFlags = {"NoResize", "NoSavedSettings"} -- 35
threadLoop(function() -- 39
	local ____App_visualSize_1 = App.visualSize -- 40
	local width = ____App_visualSize_1.width -- 40
	ImGui.SetNextWindowPos( -- 41
		Vec2(width - 10, 10), -- 41
		"FirstUseEver", -- 41
		Vec2(1, 0) -- 41
	) -- 41
	ImGui.SetNextWindowSize( -- 42
		Vec2(240, 520), -- 42
		"FirstUseEver" -- 42
	) -- 42
	ImGui.Begin( -- 43
		"SDF", -- 43
		windowFlags, -- 43
		function() -- 43
			ImGui.Text("SDF Label") -- 44
			local changed = false -- 45
			changed, edgeA, edgeB = ImGui.DragFloat2( -- 46
				"Edge", -- 46
				edgeA, -- 46
				edgeB, -- 46
				0.01, -- 46
				0, -- 46
				1, -- 46
				"%.2f" -- 46
			) -- 46
			if changed then -- 46
				label.smooth = Vec2(edgeA, edgeB) -- 48
			end -- 48
			changed, scale = ImGui.DragFloat( -- 50
				"Scale", -- 50
				scale, -- 50
				0.1, -- 50
				0.5, -- 50
				20 -- 50
			) -- 50
			if changed then -- 50
				local ____scale_2 = scale -- 52
				label.scaleY = ____scale_2 -- 52
				label.scaleX = ____scale_2 -- 52
			end -- 52
			if ImGui.ColorEdit4("LColor", outlineColor) then -- 52
				label.outlineColor = outlineColor -- 55
			end -- 55
			changed, outlineWidth = ImGui.DragFloat( -- 57
				"LWidth", -- 57
				outlineWidth, -- 57
				0.01, -- 57
				0, -- 57
				0.3 -- 57
			) -- 57
			if changed then -- 57
				label.outlineWidth = outlineWidth -- 59
			end -- 59
		end -- 43
	) -- 43
	return false -- 62
end) -- 39
return ____exports -- 39