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
		_len_0 = _len_0 + 1 -- 12
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
	_with_0:runAction(Sequence(X(1.5, -200, 200), X(1.5, 200, -200))) -- 50
	_with_0:slot("ActionEnd", function(action) -- 54
		return _with_0:runAction(action) -- 54
	end) -- 54
	targetB = _with_0 -- 48
end -- 48
local clipNodeB -- 56
do -- 56
	local _with_0 = ClipNode(maskB) -- 56
	_with_0:addChild(targetB) -- 57
	_with_0.inverted = true -- 58
	_with_0.alphaThreshold = 0.3 -- 59
	clipNodeB = _with_0 -- 56
end -- 56
local exampleB -- 60
do -- 60
	local _with_0 = Node() -- 60
	_with_0:addChild(clipNodeB) -- 61
	exampleB = _with_0 -- 60
end -- 60
local inverted = true -- 65
local withAlphaThreshold = true -- 66
local windowFlags = { -- 68
	"NoDecoration", -- 68
	"AlwaysAutoResize", -- 69
	"NoSavedSettings", -- 70
	"NoFocusOnAppearing", -- 71
	"NoNav", -- 72
	"NoMove" -- 73
} -- 67
return threadLoop(function() -- 74
	local width -- 75
	width = App.visualSize.width -- 75
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 76
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 77
	return ImGui.Begin("Clip Node", windowFlags, function() -- 78
		ImGui.Text("Clip Node (Yuescript)") -- 79
		ImGui.Separator() -- 80
		ImGui.TextWrapped("Render children nodes with mask!") -- 81
		do -- 82
			local changed -- 82
			changed, inverted = ImGui.Checkbox("Inverted", inverted) -- 82
			if changed then -- 82
				clipNodeA.inverted = inverted -- 83
				clipNodeB.inverted = inverted -- 84
				frame.visible = not inverted -- 85
			end -- 82
		end -- 82
		local changed -- 86
		changed, withAlphaThreshold = ImGui.Checkbox("With alphaThreshold", withAlphaThreshold) -- 86
		if changed then -- 86
			exampleB.visible = withAlphaThreshold -- 87
			exampleA.visible = not withAlphaThreshold -- 88
		end -- 86
	end) -- 88
end) -- 88
