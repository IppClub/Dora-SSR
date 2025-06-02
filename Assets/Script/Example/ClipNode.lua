-- [yue]: Script/Example/ClipNode.yue
local math = _G.math -- 1
local Vec2 = Dora.Vec2 -- 1
local DrawNode = Dora.DrawNode -- 1
local Model = Dora.Model -- 1
local Sequence = Dora.Sequence -- 1
local X = Dora.X -- 1
local Event = Dora.Event -- 1
local ClipNode = Dora.ClipNode -- 1
local Line = Dora.Line -- 1
local App = Dora.App -- 1
local Node = Dora.Node -- 1
local threadLoop = Dora.threadLoop -- 1
local ImGui = Dora.ImGui -- 1
local StarVertices -- 3
StarVertices = function(radius, line) -- 3
	if line == nil then -- 3
		line = false -- 3
	end -- 3
	local a = math.rad(36) -- 4
	local c = math.rad(72) -- 5
	local f = math.sin(a) * math.tan(c) + math.cos(a) -- 6
	local R = radius -- 7
	local r = R / f -- 8
	local _accum_0 = { } -- 9
	local _len_0 = 1 -- 9
	for i = 9, line and -1 or 0, -1 do -- 9
		local angle = i * a -- 10
		local cr = i % 2 == 1 and r or R -- 11
		_accum_0[_len_0] = Vec2(cr * math.sin(angle), cr * math.cos(angle)) -- 12
		_len_0 = _len_0 + 1 -- 10
	end -- 12
	return _accum_0 -- 12
end -- 3
local maskA -- 16
do -- 16
	local _with_0 = DrawNode() -- 16
	_with_0:drawPolygon(StarVertices(160)) -- 17
	maskA = _with_0 -- 16
end -- 16
local targetA -- 19
do -- 19
	local _with_0 = Model("Model/xiaoli.model") -- 19
	_with_0.look = "happy" -- 20
	_with_0.fliped = true -- 21
	_with_0:play("walk", true) -- 22
	_with_0:runAction(Sequence(X(1.5, -200, 200), Event("Turn"), X(1.5, 200, -200), Event("Turn")), true) -- 23
	_with_0:slot("Turn", function() -- 29
		_with_0.fliped = not _with_0.fliped -- 29
	end) -- 29
	targetA = _with_0 -- 19
end -- 19
local clipNodeA -- 31
do -- 31
	local _with_0 = ClipNode(maskA) -- 31
	_with_0:addChild(targetA) -- 32
	_with_0.inverted = true -- 33
	clipNodeA = _with_0 -- 31
end -- 31
local frame -- 34
do -- 34
	local _with_0 = Line(StarVertices(160, true), App.themeColor) -- 34
	_with_0.visible = false -- 35
	frame = _with_0 -- 34
end -- 34
local exampleA -- 36
do -- 36
	local _with_0 = Node() -- 36
	_with_0:addChild(clipNodeA) -- 37
	_with_0:addChild(frame) -- 38
	_with_0.visible = false -- 39
	exampleA = _with_0 -- 36
end -- 36
local maskB -- 43
do -- 43
	local _with_0 = Model("Model/xiaoli.model") -- 43
	_with_0.look = "happy" -- 44
	_with_0.fliped = true -- 45
	_with_0:play("walk", true) -- 46
	maskB = _with_0 -- 43
end -- 43
local targetB -- 48
do -- 48
	local _with_0 = DrawNode() -- 48
	_with_0:drawPolygon(StarVertices(160)) -- 49
	_with_0:runAction(Sequence(X(1.5, -200, 200), X(1.5, 200, -200)), true) -- 50
	targetB = _with_0 -- 48
end -- 48
local clipNodeB -- 55
do -- 55
	local _with_0 = ClipNode(maskB) -- 55
	_with_0:addChild(targetB) -- 56
	_with_0.inverted = true -- 57
	_with_0.alphaThreshold = 0.3 -- 58
	clipNodeB = _with_0 -- 55
end -- 55
local exampleB -- 59
do -- 59
	local _with_0 = Node() -- 59
	_with_0:addChild(clipNodeB) -- 60
	exampleB = _with_0 -- 59
end -- 59
local inverted = true -- 64
local withAlphaThreshold = true -- 65
local windowFlags = { -- 67
	"NoDecoration", -- 67
	"AlwaysAutoResize", -- 67
	"NoSavedSettings", -- 67
	"NoFocusOnAppearing", -- 67
	"NoNav", -- 67
	"NoMove" -- 67
} -- 67
return threadLoop(function() -- 75
	local width -- 76
	width = App.visualSize.width -- 76
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 77
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 78
	return ImGui.Begin("Clip Node", windowFlags, function() -- 79
		ImGui.Text("Clip Node (Yuescript)") -- 80
		ImGui.Separator() -- 81
		ImGui.TextWrapped("Render children nodes with mask!") -- 82
		do -- 83
			local changed -- 83
			changed, inverted = ImGui.Checkbox("Inverted", inverted) -- 83
			if changed then -- 83
				clipNodeA.inverted = inverted -- 84
				clipNodeB.inverted = inverted -- 85
				frame.visible = not inverted -- 86
			end -- 83
		end -- 83
		local changed -- 87
		changed, withAlphaThreshold = ImGui.Checkbox("With alphaThreshold", withAlphaThreshold) -- 87
		if changed then -- 87
			exampleB.visible = withAlphaThreshold -- 88
			exampleA.visible = not withAlphaThreshold -- 89
		end -- 87
	end) -- 89
end) -- 89
