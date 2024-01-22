-- [tsx]: DrawNodeTSX.tsx
local ____exports = {} -- 1
local ____dora_2Dx = require("dora-x") -- 2
local React = ____dora_2Dx.React -- 2
local toNode = ____dora_2Dx.toNode -- 2
local ImGui = require("ImGui") -- 4
local ____dora = require("dora") -- 5
local App = ____dora.App -- 5
local Vec2 = ____dora.Vec2 -- 5
local threadLoop = ____dora.threadLoop -- 5
local function CircleVertices(radius, verts) -- 7
    local v = verts or 20 -- 8
    local function newV(index, r) -- 9
        local angle = 2 * math.pi * index / v -- 10
        return Vec2( -- 11
            r * math.cos(angle), -- 11
            radius * math.sin(angle) -- 11
        ):add(Vec2(r, radius)) -- 11
    end -- 9
    local vs = {} -- 13
    do -- 13
        local index = 0 -- 14
        while index <= v do -- 14
            vs[#vs + 1] = newV(index, radius) -- 15
            index = index + 1 -- 14
        end -- 14
    end -- 14
    return vs -- 17
end -- 7
local function StarVertices(radius) -- 20
    local a = math.rad(36) -- 21
    local c = math.rad(72) -- 22
    local f = math.sin(a) * math.tan(c) + math.cos(a) -- 23
    local R = radius -- 24
    local r = R / f -- 25
    local vs = {} -- 26
    do -- 26
        local i = 9 -- 27
        while i >= 0 do -- 27
            local angle = i * a -- 28
            local cr = i % 2 == 1 and r or R -- 29
            vs[#vs + 1] = Vec2( -- 30
                cr * math.sin(angle), -- 30
                cr * math.cos(angle) -- 30
            ) -- 30
            i = i - 1 -- 27
        end -- 27
    end -- 27
    return vs -- 32
end -- 20
local themeColor = App.themeColor:toARGB() -- 35
toNode(React:createElement( -- 37
    React.Fragment, -- 37
    nil, -- 37
    React:createElement( -- 37
        "draw-node", -- 37
        {x = 200, y = 200}, -- 37
        React:createElement( -- 37
            "polygon-shape", -- 37
            { -- 37
                verts = StarVertices(60), -- 37
                fillColor = 2164195456, -- 37
                borderWidth = 1, -- 37
                borderColor = 4294901888 -- 37
            } -- 37
        ) -- 37
    ), -- 37
    React:createElement( -- 37
        "line", -- 37
        { -- 37
            verts = CircleVertices(60), -- 37
            lineColor = themeColor, -- 37
            x = -200, -- 37
            y = 200 -- 37
        } -- 37
    ), -- 37
    React:createElement( -- 37
        "node", -- 37
        {color3 = themeColor, scaleX = 2, scaleY = 2}, -- 37
        React:createElement( -- 37
            "draw-node", -- 37
            {opacity = 0.5}, -- 37
            React:createElement( -- 37
                "polygon-shape", -- 37
                {verts = { -- 37
                    Vec2(-20, -10), -- 48
                    Vec2(20, -10), -- 49
                    Vec2(20, 10), -- 50
                    Vec2(-20, 10) -- 51
                }} -- 51
            ), -- 51
            React:createElement( -- 51
                "polygon-shape", -- 51
                {verts = { -- 51
                    Vec2(20, 3), -- 54
                    Vec2(32, 10), -- 55
                    Vec2(32, -10), -- 56
                    Vec2(20, -3) -- 57
                }} -- 57
            ), -- 57
            React:createElement("dot-shape", {x = -11, y = 20, radius = 10}), -- 57
            React:createElement("dot-shape", {x = 11, y = 20, radius = 10}) -- 57
        ), -- 57
        React:createElement( -- 57
            "line", -- 57
            { -- 57
                verts = CircleVertices(10), -- 57
                x = -21, -- 57
                y = 10 -- 57
            } -- 57
        ), -- 57
        React:createElement( -- 57
            "line", -- 57
            { -- 57
                verts = CircleVertices(10), -- 57
                x = 1, -- 57
                y = 10 -- 57
            } -- 57
        ), -- 57
        React:createElement( -- 57
            "line", -- 57
            {verts = { -- 57
                Vec2(20, 3), -- 66
                Vec2(32, 10), -- 67
                Vec2(32, -10), -- 68
                Vec2(20, -3) -- 69
            }} -- 69
        ) -- 69
    ) -- 69
)) -- 69
local windowFlags = { -- 75
    "NoDecoration", -- 76
    "AlwaysAutoResize", -- 77
    "NoSavedSettings", -- 78
    "NoFocusOnAppearing", -- 79
    "NoNav", -- 80
    "NoMove" -- 81
} -- 81
threadLoop(function() -- 83
    local ____App_visualSize_0 = App.visualSize -- 84
    local width = ____App_visualSize_0.width -- 84
    ImGui.SetNextWindowBgAlpha(0.35) -- 85
    ImGui.SetNextWindowPos( -- 86
        Vec2(width - 10, 10), -- 86
        "Always", -- 86
        Vec2(1, 0) -- 86
    ) -- 86
    ImGui.SetNextWindowSize( -- 87
        Vec2(240, 0), -- 87
        "FirstUseEver" -- 87
    ) -- 87
    ImGui.Begin( -- 88
        "Draw Node", -- 88
        windowFlags, -- 88
        function() -- 88
            ImGui.Text("Draw Node") -- 89
            ImGui.Separator() -- 90
            ImGui.TextWrapped("Draw shapes and lines!") -- 91
        end -- 88
    ) -- 88
    return false -- 93
end) -- 83
return ____exports -- 83