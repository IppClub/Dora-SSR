-- [yue]: Script/Example/SVG.yue
local SVG = Dora.SVG -- 1
local threadLoop = Dora.threadLoop -- 1
local App = Dora.App -- 1
local nvg = Dora.nvg -- 1
local ImGui = Dora.ImGui -- 1
local Vec2 = Dora.Vec2 -- 1
local svg = SVG("Image/Dora.svg") -- 3
local size <const> = 1133 -- 4
threadLoop(function() -- 6
	local width, height -- 7
	do -- 7
		local _obj_0 = App.visualSize -- 7
		width, height = _obj_0.width, _obj_0.height -- 7
	end -- 7
	nvg.Translate(width / 2, height / 2) -- 8
	nvg.Scale(1, -1) -- 9
	local scale = height * 0.8 / size -- 11
	nvg.Scale(scale, -scale) -- 12
	nvg.Translate(-size / 2, -size / 2) -- 13
	return svg:render() -- 14
end) -- 6
local windowFlags = { -- 19
	"NoDecoration", -- 19
	"AlwaysAutoResize", -- 19
	"NoSavedSettings", -- 19
	"NoFocusOnAppearing", -- 19
	"NoNav", -- 19
	"NoMove" -- 19
} -- 19
return threadLoop(function() -- 27
	local width -- 28
	width = App.visualSize.width -- 28
	ImGui.SetNextWindowBgAlpha(0.35) -- 29
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 30
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 31
	return ImGui.Begin("SVG Render", windowFlags, function() -- 32
		ImGui.Text("SVG Render (Yuescript)") -- 33
		ImGui.Separator() -- 34
		return ImGui.TextWrapped("Load and render an SVG file. Only support the SVG file preprocessed by the picosvg tool.") -- 35
	end) -- 35
end) -- 35
