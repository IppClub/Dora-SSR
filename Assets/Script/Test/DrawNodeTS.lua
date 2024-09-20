-- [ts]: DrawNodeTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____Dora = require("Dora") -- 4
local App = ____Dora.App -- 4
local Color = ____Dora.Color -- 4
local DrawNode = ____Dora.DrawNode -- 4
local Line = ____Dora.Line -- 4
local Node = ____Dora.Node -- 4
local Vec2 = ____Dora.Vec2 -- 4
local threadLoop = ____Dora.threadLoop -- 4
local function CircleVertices(radius, verts) -- 6
	local v = verts or 20 -- 7
	local function newV(index, r) -- 8
		local angle = 2 * math.pi * index / v -- 9
		return Vec2( -- 10
			r * math.cos(angle), -- 10
			radius * math.sin(angle) -- 10
		):add(Vec2(r, radius)) -- 10
	end -- 8
	local vs = {} -- 12
	do -- 12
		local index = 0 -- 13
		while index <= v do -- 13
			vs[#vs + 1] = newV(index, radius) -- 14
			index = index + 1 -- 13
		end -- 13
	end -- 13
	return vs -- 16
end -- 6
local function StarVertices(radius) -- 19
	local a = math.rad(36) -- 20
	local c = math.rad(72) -- 21
	local f = math.sin(a) * math.tan(c) + math.cos(a) -- 22
	local R = radius -- 23
	local r = R / f -- 24
	local vs = {} -- 25
	do -- 25
		local i = 9 -- 26
		while i >= 0 do -- 26
			local angle = i * a -- 27
			local cr = i % 2 == 1 and r or R -- 28
			vs[#vs + 1] = Vec2( -- 29
				cr * math.sin(angle), -- 29
				cr * math.cos(angle) -- 29
			) -- 29
			i = i - 1 -- 26
		end -- 26
	end -- 26
	return vs -- 31
end -- 19
local node = Node() -- 34
local star = DrawNode() -- 36
star.position = Vec2(200, 200) -- 37
star:drawPolygon( -- 38
	StarVertices(60), -- 38
	Color(2164195456), -- 38
	1, -- 38
	Color(4294901888) -- 38
) -- 38
star:addTo(node) -- 39
local ____App_0 = App -- 41
local themeColor = ____App_0.themeColor -- 41
local circle = Line( -- 43
	CircleVertices(60), -- 43
	themeColor -- 43
) -- 43
circle.position = Vec2(-200, 200) -- 44
circle:addTo(node) -- 45
local camera = Node() -- 47
camera.color = themeColor -- 48
camera.scaleX = 2 -- 49
camera.scaleY = 2 -- 50
camera:addTo(node) -- 51
local cameraFill = DrawNode() -- 53
cameraFill.opacity = 0.5 -- 54
cameraFill:drawPolygon({ -- 55
	Vec2(-20, -10), -- 56
	Vec2(20, -10), -- 57
	Vec2(20, 10), -- 58
	Vec2(-20, 10) -- 59
}) -- 59
cameraFill:drawPolygon({ -- 61
	Vec2(20, 3), -- 62
	Vec2(32, 10), -- 63
	Vec2(32, -10), -- 64
	Vec2(20, -3) -- 65
}) -- 65
cameraFill:drawDot( -- 67
	Vec2(-11, 20), -- 67
	10 -- 67
) -- 67
cameraFill:drawDot( -- 68
	Vec2(11, 20), -- 68
	10 -- 68
) -- 68
cameraFill:addTo(camera) -- 69
local cameraLine = Line(CircleVertices(10)) -- 71
cameraLine.position = Vec2(-21, 10) -- 72
cameraLine:addTo(camera) -- 73
cameraLine = Line(CircleVertices(10)) -- 75
cameraLine.position = Vec2(1, 10) -- 76
cameraLine:addTo(camera) -- 77
cameraLine = Line({ -- 79
	Vec2(20, 3), -- 80
	Vec2(32, 10), -- 81
	Vec2(32, -10), -- 82
	Vec2(20, -3) -- 83
}) -- 83
cameraLine:addTo(camera) -- 85
local windowFlags = { -- 87
	"NoDecoration", -- 88
	"AlwaysAutoResize", -- 89
	"NoSavedSettings", -- 90
	"NoFocusOnAppearing", -- 91
	"NoNav", -- 92
	"NoMove" -- 93
} -- 93
threadLoop(function() -- 95
	local ____App_visualSize_1 = App.visualSize -- 96
	local width = ____App_visualSize_1.width -- 96
	ImGui.SetNextWindowBgAlpha(0.35) -- 97
	ImGui.SetNextWindowPos( -- 98
		Vec2(width - 10, 10), -- 98
		"Always", -- 98
		Vec2(1, 0) -- 98
	) -- 98
	ImGui.SetNextWindowSize( -- 99
		Vec2(240, 0), -- 99
		"FirstUseEver" -- 99
	) -- 99
	ImGui.Begin( -- 100
		"Draw Node", -- 100
		windowFlags, -- 100
		function() -- 100
			ImGui.Text("Draw Node (Typescript)") -- 101
			ImGui.Separator() -- 102
			ImGui.TextWrapped("Draw shapes and lines!") -- 103
		end -- 100
	) -- 100
	return false -- 105
end) -- 95
return ____exports -- 95