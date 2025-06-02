-- [yue]: Script/Example/DrawNode.yue
local math = _G.math -- 1
local Vec2 = Dora.Vec2 -- 1
local Node = Dora.Node -- 1
local DrawNode = Dora.DrawNode -- 1
local Color = Dora.Color -- 1
local App = Dora.App -- 1
local Line = Dora.Line -- 1
local threadLoop = Dora.threadLoop -- 1
local ImGui = Dora.ImGui -- 1
local CircleVertices -- 3
CircleVertices = function(radius, verts) -- 3
	if verts == nil then -- 3
		verts = 20 -- 3
	end -- 3
	local newV -- 4
	newV = function(index, radius) -- 4
		local angle = 2 * math.pi * index / verts -- 5
		return Vec2(radius * math.cos(angle), radius * math.sin(angle)) + Vec2(radius, radius) -- 6
	end -- 4
	local _accum_0 = { } -- 7
	local _len_0 = 1 -- 7
	for index = 0, verts do -- 7
		_accum_0[_len_0] = newV(index, radius) -- 7
		_len_0 = _len_0 + 1 -- 7
	end -- 7
	return _accum_0 -- 7
end -- 3
local StarVertices -- 9
StarVertices = function(radius) -- 9
	local a = math.rad(36) -- 10
	local c = math.rad(72) -- 11
	local f = math.sin(a) * math.tan(c) + math.cos(a) -- 12
	local R = radius -- 13
	local r = R / f -- 14
	local _accum_0 = { } -- 15
	local _len_0 = 1 -- 15
	for i = 9, 0, -1 do -- 15
		local angle = i * a -- 16
		local cr = i % 2 == 1 and r or R -- 17
		_accum_0[_len_0] = Vec2(cr * math.sin(angle), cr * math.cos(angle)) -- 18
		_len_0 = _len_0 + 1 -- 16
	end -- 18
	return _accum_0 -- 18
end -- 9
do -- 20
	local _with_0 = Node() -- 20
	_with_0:addChild((function() -- 21
		local _with_1 = DrawNode() -- 21
		_with_1.position = Vec2(200, 200) -- 22
		_with_1:drawPolygon(StarVertices(60), Color(0x80ff0080), 1, Color(0xffff0080)) -- 23
		return _with_1 -- 21
	end)()) -- 21
	local themeColor = App.themeColor -- 25
	_with_0:addChild((function() -- 27
		local _with_1 = Line(CircleVertices(60), themeColor) -- 27
		_with_1.position = Vec2(-200, 200) -- 28
		return _with_1 -- 27
	end)()) -- 27
	_with_0:addChild((function() -- 30
		local _with_1 = Node() -- 30
		_with_1.color = themeColor -- 31
		_with_1.scaleX = 2 -- 32
		_with_1.scaleY = 2 -- 33
		_with_1:addChild((function() -- 34
			local _with_2 = DrawNode() -- 34
			_with_2.opacity = 0.5 -- 35
			_with_2:drawPolygon({ -- 37
				Vec2(-20, -10), -- 37
				Vec2(20, -10), -- 38
				Vec2(20, 10), -- 39
				Vec2(-20, 10) -- 40
			}) -- 36
			_with_2:drawPolygon({ -- 43
				Vec2(20, 3), -- 43
				Vec2(32, 10), -- 44
				Vec2(32, -10), -- 45
				Vec2(20, -3) -- 46
			}) -- 42
			_with_2:drawDot(Vec2(-11, 20), 10) -- 48
			_with_2:drawDot(Vec2(11, 20), 10) -- 49
			return _with_2 -- 34
		end)()) -- 34
		_with_1:addChild((function() -- 50
			local _with_2 = Line({ -- 51
				Vec2(0, 0), -- 51
				Vec2(40, 0), -- 52
				Vec2(40, 20), -- 53
				Vec2(0, 20), -- 54
				Vec2(0, 0) -- 55
			}) -- 50
			_with_2.position = Vec2(-20, -10) -- 57
			return _with_2 -- 50
		end)()) -- 50
		_with_1:addChild((function() -- 58
			local _with_2 = Line(CircleVertices(10)) -- 58
			_with_2.position = Vec2(-21, 10) -- 59
			return _with_2 -- 58
		end)()) -- 58
		_with_1:addChild((function() -- 60
			local _with_2 = Line(CircleVertices(10)) -- 60
			_with_2.position = Vec2(1, 10) -- 61
			return _with_2 -- 60
		end)()) -- 60
		_with_1:addChild(Line({ -- 63
			Vec2(20, 3), -- 63
			Vec2(32, 10), -- 64
			Vec2(32, -10), -- 65
			Vec2(20, -3) -- 66
		})) -- 62
		return _with_1 -- 30
	end)()) -- 30
end -- 20
local windowFlags = { -- 72
	"NoDecoration", -- 72
	"AlwaysAutoResize", -- 72
	"NoSavedSettings", -- 72
	"NoFocusOnAppearing", -- 72
	"NoNav", -- 72
	"NoMove" -- 72
} -- 72
return threadLoop(function() -- 80
	local width -- 81
	width = App.visualSize.width -- 81
	ImGui.SetNextWindowBgAlpha(0.35) -- 82
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 83
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 84
	return ImGui.Begin("Draw Node", windowFlags, function() -- 85
		ImGui.Text("Draw Node (Yuescript)") -- 86
		ImGui.Separator() -- 87
		return ImGui.TextWrapped("Draw shapes and lines!") -- 88
	end) -- 88
end) -- 88
