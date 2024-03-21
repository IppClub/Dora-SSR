-- [yue]: Script/Example/ClipNode.yue
local math = _G.math -- 1
local Vec2 = dora.Vec2 -- 1
local DrawNode = dora.DrawNode -- 1
local Model = dora.Model -- 1
local Sequence = dora.Sequence -- 1
local X = dora.X -- 1
local Event = dora.Event -- 1
local ClipNode = dora.ClipNode -- 1
local Line = dora.Line -- 1
local App = dora.App -- 1
local Node = dora.Node -- 1
local threadLoop = dora.threadLoop -- 1
local ImGui = dora.ImGui -- 1
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
	_with_0:runAction(Sequence(X(1.5, -200, 200), Event("Turn"), X(1.5, 200, -200), Event("Turn"))) -- 23
	_with_0:slot("ActionEnd", function(action) -- 29
		return _with_0:runAction(action) -- 29
	end) -- 29
	_with_0:slot("Turn", function() -- 30
		_with_0.fliped = not _with_0.fliped -- 30
	end) -- 30
	targetA = _with_0 -- 19
end -- 19
local clipNodeA -- 32
do -- 32
	local _with_0 = ClipNode(maskA) -- 32
	_with_0:addChild(targetA) -- 33
	_with_0.inverted = true -- 34
	clipNodeA = _with_0 -- 32
end -- 32
local frame -- 35
do -- 35
	local _with_0 = Line(StarVertices(160, true), App.themeColor) -- 35
	_with_0.visible = false -- 36
	frame = _with_0 -- 35
end -- 35
local exampleA -- 37
do -- 37
	local _with_0 = Node() -- 37
	_with_0:addChild(clipNodeA) -- 38
	_with_0:addChild(frame) -- 39
	_with_0.visible = false -- 40
	exampleA = _with_0 -- 37
end -- 37
local maskB -- 44
do -- 44
	local _with_0 = Model("Model/xiaoli.model") -- 44
	_with_0.look = "happy" -- 45
	_with_0.fliped = true -- 46
	_with_0:play("walk", true) -- 47
	maskB = _with_0 -- 44
end -- 44
local targetB -- 49
do -- 49
	local _with_0 = DrawNode() -- 49
	_with_0:drawPolygon(StarVertices(160)) -- 50
	_with_0:runAction(Sequence(X(1.5, -200, 200), X(1.5, 200, -200))) -- 51
	_with_0:slot("ActionEnd", function(action) -- 55
		return _with_0:runAction(action) -- 55
	end) -- 55
	targetB = _with_0 -- 49
end -- 49
local clipNodeB -- 57
do -- 57
	local _with_0 = ClipNode(maskB) -- 57
	_with_0:addChild(targetB) -- 58
	_with_0.inverted = true -- 59
	_with_0.alphaThreshold = 0.3 -- 60
	clipNodeB = _with_0 -- 57
end -- 57
local exampleB -- 61
do -- 61
	local _with_0 = Node() -- 61
	_with_0:addChild(clipNodeB) -- 62
	exampleB = _with_0 -- 61
end -- 61
local inverted = true -- 66
local withAlphaThreshold = true -- 67
local windowFlags = { -- 69
	"NoDecoration", -- 69
	"AlwaysAutoResize", -- 70
	"NoSavedSettings", -- 71
	"NoFocusOnAppearing", -- 72
	"NoNav", -- 73
	"NoMove" -- 74
} -- 68
return threadLoop(function() -- 75
	local width -- 76
	width = App.visualSize.width -- 76
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 77
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 78
	return ImGui.Begin("Clip Node", windowFlags, function() -- 79
		ImGui.Text("Clip Node") -- 80
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
