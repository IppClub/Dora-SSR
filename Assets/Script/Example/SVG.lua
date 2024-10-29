-- [yue]: Script/Example/SVG.yue
local SVG = Dora.SVG -- 1
local Node = Dora.Node -- 1
local threadLoop = Dora.threadLoop -- 1
local nvg = Dora.nvg -- 1
local View = Dora.View -- 1
local App = Dora.App -- 1
local ImGui = Dora.ImGui -- 1
local Vec2 = Dora.Vec2 -- 1
local svg = SVG("Image/dora.svg") -- 3
local size <const> = 1133 -- 4
local node = Node() -- 6
threadLoop(function() -- 8
	nvg.ApplyTransform(node) -- 9
	local scale = 0.6 * View.size.height / size -- 10
	nvg.Scale(scale, -scale) -- 11
	nvg.Translate(-size / 2, -size / 2) -- 12
	return svg:render() -- 13
end) -- 8
local windowFlags = { -- 18
	"NoDecoration", -- 18
	"AlwaysAutoResize", -- 18
	"NoSavedSettings", -- 18
	"NoFocusOnAppearing", -- 18
	"NoNav", -- 18
	"NoMove" -- 18
} -- 18
return threadLoop(function() -- 26
	local width -- 27
	width = App.visualSize.width -- 27
	ImGui.SetNextWindowBgAlpha(0.35) -- 28
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 29
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 30
	return ImGui.Begin("SVG Render", windowFlags, function() -- 31
		ImGui.Text("SVG Render (Yuescript)") -- 32
		ImGui.Separator() -- 33
		return ImGui.TextWrapped("Load and render an SVG file. Only support the SVG file preprocessed by the picosvg tool.") -- 34
	end) -- 34
end) -- 34
