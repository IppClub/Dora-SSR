-- [yue]: Script/Example/Vector Graphic.yue
local nvg = Dora.nvg -- 1
local Color = Dora.Color -- 1
local VGNode = Dora.VGNode -- 1
local Sequence = Dora.Sequence -- 1
local Scale = Dora.Scale -- 1
local Ease = Dora.Ease -- 1
local coroutine = _G.coroutine -- 1
local cycle = Dora.cycle -- 1
local threadLoop = Dora.threadLoop -- 1
local App = Dora.App -- 1
local ImGui = Dora.ImGui -- 1
local Vec2 = Dora.Vec2 -- 1
local drawHeart -- 3
drawHeart = function() -- 3
	local _with_0 = nvg -- 3
	_with_0.BeginPath() -- 4
	_with_0.MoveTo(36.29, 0) -- 5
	_with_0.BezierTo(32.5244, 0.0, 28.9316, 1.3173, 26.0742, 3.7275) -- 6
	_with_0.BezierTo(23.2168, 1.3173, 19.624, 0, 15.8593, 0) -- 7
	_with_0.BezierTo(5.4843, 0, 0, 5.4838, 0, 15.8588) -- 8
	_with_0.BezierTo(0.0, 23.5278, 9.248, 33.1123, 14.7607, 38.143) -- 9
	_with_0.BezierTo(17.2099, 40.3779, 23.8379, 46.0322, 25.9765, 46.2172) -- 10
	_with_0.BezierTo(26.0097, 46.2207, 26.0478, 46.2226, 26.08, 46.2216) -- 11
	_with_0.BezierTo(26.1093, 46.2216, 26.1377, 46.2207, 26.165, 46.2177) -- 12
	_with_0.LineTo(26.165, 46.2163) -- 13
	_with_0.BezierTo(28.2246, 46.0263, 34.748, 40.4858, 37.165, 38.2939) -- 14
	_with_0.BezierTo(42.7607, 33.2197, 52.1484, 23.5581, 52.1484, 15.8588) -- 15
	_with_0.BezierTo(52.1484, 5.4838, 46.665, 0, 36.29, 0) -- 16
	_with_0.ClosePath() -- 17
	_with_0.FillColor(Color(253, 90, 90, 255)) -- 18
	_with_0.Fill() -- 19
	return _with_0 -- 3
end -- 3
local stopRendering = false -- 21
do -- 23
	local _with_0 = VGNode(60, 50, 5) -- 23
	_with_0:render(drawHeart) -- 24
	_with_0:slot("Cleanup", function() -- 25
		stopRendering = true -- 25
	end) -- 25
	_with_0:runAction(Sequence(Scale(0.2, 1.0, 0.3), Scale(0.5, 0.3, 1.0, Ease.OutBack)), true) -- 26
end -- 23
local drawAnimated = coroutine.wrap(function() -- 31
	while true do -- 32
		cycle(0.2, function(time) -- 33
			nvg.Translate(60, 50) -- 34
			local scale = 1 - 0.7 * time -- 35
			nvg.Scale(scale, scale) -- 36
			nvg.Translate(-30, -25) -- 37
			return drawHeart() -- 38
		end) -- 33
		cycle(0.5, function(time) -- 39
			nvg.Translate(60, 50) -- 40
			local scale = 0.3 + 0.7 * Ease:func(Ease.OutBack, time) -- 41
			nvg.Scale(scale, scale) -- 42
			nvg.Translate(-30, -25) -- 43
			return drawHeart() -- 44
		end) -- 39
	end -- 44
end) -- 31
threadLoop(function() -- 46
	nvg.Scale(2, 2) -- 47
	drawAnimated() -- 48
	return stopRendering -- 49
end) -- 46
local windowFlags = { -- 54
	"NoDecoration", -- 54
	"AlwaysAutoResize", -- 54
	"NoSavedSettings", -- 54
	"NoFocusOnAppearing", -- 54
	"NoNav", -- 54
	"NoMove" -- 54
} -- 54
return threadLoop(function() -- 62
	local width -- 63
	width = App.visualSize.width -- 63
	ImGui.SetNextWindowBgAlpha(0.35) -- 64
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 65
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 66
	return ImGui.Begin("Vector Graphic Rendering", windowFlags, function() -- 67
		ImGui.Text("Vector Graphic Rendering (Yuescript)") -- 68
		ImGui.Separator() -- 69
		return ImGui.TextWrapped("Use nanoVG lib to do vector graphic rendering, render to a texture or do instant render!") -- 70
	end) -- 70
end) -- 70
