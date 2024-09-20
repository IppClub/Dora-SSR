-- [ts]: RenderTargetTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____Dora = require("Dora") -- 4
local App = ____Dora.App -- 4
local Color = ____Dora.Color -- 4
local Event = ____Dora.Event -- 4
local Line = ____Dora.Line -- 4
local Node = ____Dora.Node -- 4
local RenderTarget = ____Dora.RenderTarget -- 4
local Sequence = ____Dora.Sequence -- 4
local Spine = ____Dora.Spine -- 4
local Sprite = ____Dora.Sprite -- 4
local Vec2 = ____Dora.Vec2 -- 4
local X = ____Dora.X -- 4
local threadLoop = ____Dora.threadLoop -- 4
local root = Node() -- 6
local node = Node():addTo(root, 1) -- 8
local ____opt_0 = Spine("Spine/moling") -- 8
local spine = ____opt_0 and ____opt_0:addTo(node) -- 10
if spine then -- 10
	spine.y = -200 -- 12
	spine.scaleX = 1.2 -- 13
	spine.scaleY = 1.2 -- 14
	spine.fliped = false -- 15
	spine:play("fmove", true) -- 16
	spine:runAction( -- 17
		Sequence( -- 18
			X(2, -150, 250), -- 19
			Event("Turn"), -- 20
			X(2, 250, -150), -- 21
			Event("Turn") -- 22
		), -- 22
		true -- 23
	) -- 23
	spine:slot( -- 24
		"Turn", -- 24
		function() -- 24
			spine.fliped = not spine.fliped -- 25
		end -- 24
	) -- 24
end -- 24
local renderTarget = RenderTarget(300, 400) -- 29
renderTarget:renderWithClear(Color(4287269514)) -- 30
local surface = Sprite(renderTarget.texture):addTo(root) -- 32
surface.z = 300 -- 33
surface.angleY = 25 -- 34
surface:addChild(Line( -- 35
	{ -- 35
		Vec2.zero, -- 36
		Vec2(300, 0), -- 37
		Vec2(300, 400), -- 38
		Vec2(0, 400), -- 39
		Vec2.zero -- 40
	}, -- 40
	App.themeColor -- 41
)) -- 41
surface:schedule(function() -- 42
	node.y = 200 -- 43
	renderTarget:renderWithClear( -- 44
		node, -- 44
		Color(4287269514) -- 44
	) -- 44
	node.y = 0 -- 45
	return false -- 46
end) -- 42
local windowFlags = { -- 49
	"NoDecoration", -- 50
	"AlwaysAutoResize", -- 51
	"NoSavedSettings", -- 52
	"NoFocusOnAppearing", -- 53
	"NoNav", -- 54
	"NoMove" -- 55
} -- 55
threadLoop(function() -- 57
	local size = App.visualSize -- 58
	ImGui.SetNextWindowBgAlpha(0.35) -- 59
	ImGui.SetNextWindowPos( -- 60
		Vec2(size.width - 10, 10), -- 60
		"Always", -- 60
		Vec2(1, 0) -- 60
	) -- 60
	ImGui.SetNextWindowSize( -- 61
		Vec2(240, 0), -- 61
		"FirstUseEver" -- 61
	) -- 61
	ImGui.Begin( -- 62
		"Render Target", -- 62
		windowFlags, -- 62
		function() -- 62
			ImGui.Text("Render Target (Typescript)") -- 63
			ImGui.Separator() -- 64
			ImGui.TextWrapped("Use render target node as a mirror!") -- 65
		end -- 62
	) -- 62
	return false -- 67
end) -- 57
return ____exports -- 57