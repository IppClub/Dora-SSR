-- [yue]: Script/Example/Vector Graphic.yue
local nvg = dora.nvg -- 1
local Color = dora.Color -- 1
local VGNode = dora.VGNode -- 1
local Sequence = dora.Sequence -- 1
local Scale = dora.Scale -- 1
local Ease = dora.Ease -- 1
local coroutine = _G.coroutine -- 1
local cycle = dora.cycle -- 1
local threadLoop = dora.threadLoop -- 1
local App = dora.App -- 1
local ImGui = dora.ImGui -- 1
local Vec2 = dora.Vec2 -- 1
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
	_with_0:runAction(Sequence(Scale(0.2, 1.0, 0.3), Scale(0.5, 0.3, 1.0, Ease.OutBack))) -- 26
	_with_0:slot("ActionEnd", function(self) -- 30
		return _with_0:runAction(self) -- 30
	end) -- 30
end -- 23
local drawAnimated = coroutine.wrap(function() -- 32
	while true do -- 33
		cycle(0.2, function(time) -- 34
			local scale = 1 - 0.7 * time -- 35
			nvg.Scale(scale, scale) -- 36
			return drawHeart() -- 37
		end) -- 34
		cycle(0.5, function(time) -- 38
			local scale = 0.3 + 0.7 * Ease:func(Ease.OutBack, time) -- 39
			nvg.Scale(scale, scale) -- 40
			return drawHeart() -- 41
		end) -- 38
	end -- 41
end) -- 32
threadLoop(function() -- 43
	nvg.Scale(2, 2) -- 44
	drawAnimated() -- 45
	return stopRendering -- 46
end) -- 43
local windowFlags = { -- 51
	"NoDecoration", -- 51
	"AlwaysAutoResize", -- 52
	"NoSavedSettings", -- 53
	"NoFocusOnAppearing", -- 54
	"NoNav", -- 55
	"NoMove" -- 56
} -- 50
return threadLoop(function() -- 57
	local width -- 58
	width = App.visualSize.width -- 58
	ImGui.SetNextWindowBgAlpha(0.35) -- 59
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 60
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 61
	return ImGui.Begin("Vector Graphic Rendering", windowFlags, function() -- 62
		ImGui.Text("Vector Graphic Rendering (Yuescript)") -- 63
		ImGui.Separator() -- 64
		return ImGui.TextWrapped("Use nanoVG lib to do vector graphic rendering, render to a texture or do instant render!") -- 65
	end) -- 65
end) -- 65
