-- [ts]: DrawNodeTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Color = ____dora.Color -- 3
local DrawNode = ____dora.DrawNode -- 3
local Line = ____dora.Line -- 3
local Node = ____dora.Node -- 3
local Vec2 = ____dora.Vec2 -- 3
local threadLoop = ____dora.threadLoop -- 3
local function CircleVertices(radius, verts) -- 5
    local v = verts or 20 -- 6
    local function newV(index, r) -- 7
        local angle = 2 * math.pi * index / v -- 8
        return Vec2( -- 9
            r * math.cos(angle), -- 9
            radius * math.sin(angle) -- 9
        ):add(Vec2(r, radius)) -- 9
    end -- 7
    local vs = {} -- 11
    do -- 11
        local index = 0 -- 12
        while index <= v do -- 12
            vs[#vs + 1] = newV(index, radius) -- 13
            index = index + 1 -- 12
        end -- 12
    end -- 12
    return vs -- 15
end -- 5
local function StarVertices(radius) -- 18
    local a = math.rad(36) -- 19
    local c = math.rad(72) -- 20
    local f = math.sin(a) * math.tan(c) + math.cos(a) -- 21
    local R = radius -- 22
    local r = R / f -- 23
    local vs = {} -- 24
    do -- 24
        local i = 9 -- 25
        while i >= 0 do -- 25
            local angle = i * a -- 26
            local cr = i % 2 == 1 and r or R -- 27
            vs[#vs + 1] = Vec2( -- 28
                cr * math.sin(angle), -- 28
                cr * math.cos(angle) -- 28
            ) -- 28
            i = i - 1 -- 25
        end -- 25
    end -- 25
    return vs -- 30
end -- 18
local node = Node() -- 33
local star = DrawNode() -- 35
star.position = Vec2(200, 200) -- 36
star:drawPolygon( -- 37
    StarVertices(60), -- 37
    Color(2164195456), -- 37
    1, -- 37
    Color(4294901888) -- 37
) -- 37
star:addTo(node) -- 38
local ____App_0 = App -- 40
local themeColor = ____App_0.themeColor -- 40
local circle = Line( -- 42
    CircleVertices(60), -- 42
    themeColor -- 42
) -- 42
circle.position = Vec2(-200, 200) -- 43
circle:addTo(node) -- 44
local camera = Node() -- 46
camera.color = themeColor -- 47
camera.scaleX = 2 -- 48
camera.scaleY = 2 -- 49
camera:addTo(node) -- 50
local cameraFill = DrawNode() -- 52
cameraFill.opacity = 0.5 -- 53
cameraFill:drawPolygon({ -- 54
    Vec2(-20, -10), -- 55
    Vec2(20, -10), -- 56
    Vec2(20, 10), -- 57
    Vec2(-20, 10) -- 58
}) -- 58
cameraFill:drawPolygon({ -- 60
    Vec2(20, 3), -- 61
    Vec2(32, 10), -- 62
    Vec2(32, -10), -- 63
    Vec2(20, -3) -- 64
}) -- 64
cameraFill:drawDot( -- 66
    Vec2(-11, 20), -- 66
    10 -- 66
) -- 66
cameraFill:drawDot( -- 67
    Vec2(11, 20), -- 67
    10 -- 67
) -- 67
cameraFill:addTo(camera) -- 68
local cameraLine = Line(CircleVertices(10)) -- 70
cameraLine.position = Vec2(-21, 10) -- 71
cameraLine:addTo(camera) -- 72
cameraLine = Line(CircleVertices(10)) -- 74
cameraLine.position = Vec2(1, 10) -- 75
cameraLine:addTo(camera) -- 76
cameraLine = Line({ -- 78
    Vec2(20, 3), -- 79
    Vec2(32, 10), -- 80
    Vec2(32, -10), -- 81
    Vec2(20, -3) -- 82
}) -- 82
cameraLine:addTo(camera) -- 84
local windowFlags = { -- 86
    "NoDecoration", -- 87
    "AlwaysAutoResize", -- 88
    "NoSavedSettings", -- 89
    "NoFocusOnAppearing", -- 90
    "NoNav", -- 91
    "NoMove" -- 92
} -- 92
threadLoop(function() -- 94
    local ____App_visualSize_1 = App.visualSize -- 95
    local width = ____App_visualSize_1.width -- 95
    ImGui.SetNextWindowBgAlpha(0.35) -- 96
    ImGui.SetNextWindowPos( -- 97
        Vec2(width - 10, 10), -- 97
        "Always", -- 97
        Vec2(1, 0) -- 97
    ) -- 97
    ImGui.SetNextWindowSize( -- 98
        Vec2(240, 0), -- 98
        "FirstUseEver" -- 98
    ) -- 98
    ImGui.Begin( -- 99
        "Draw Node", -- 99
        windowFlags, -- 99
        function() -- 99
            ImGui.Text("Draw Node") -- 100
            ImGui.Separator() -- 101
            ImGui.TextWrapped("Draw shapes and lines!") -- 102
        end -- 99
    ) -- 99
    return false -- 104
end) -- 94
return ____exports -- 94