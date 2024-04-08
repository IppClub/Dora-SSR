-- [tsx]: BodyTSX.tsx
local ____exports = {} -- 1
local ____dora_2Dx = require("dora-x") -- 2
local React = ____dora_2Dx.React -- 2
local toNode = ____dora_2Dx.toNode -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Vec2 = ____dora.Vec2 -- 3
local threadLoop = ____dora.threadLoop -- 3
local ImGui = require("ImGui") -- 4
local gravity = Vec2(0, -10) -- 7
local groupA = 0 -- 8
local groupB = 1 -- 9
local groupTerrain = 2 -- 10
toNode(React:createElement( -- 12
    "physics-world", -- 12
    {y = -200, showDebug = true}, -- 12
    React:createElement("contact", {groupA = groupA, groupB = groupB, enabled = false}), -- 12
    React:createElement("contact", {groupA = groupA, groupB = groupTerrain, enabled = true}), -- 12
    React:createElement("contact", {groupA = groupB, groupB = groupTerrain, enabled = true}), -- 12
    React:createElement( -- 12
        "body", -- 12
        { -- 12
            type = "Dynamic", -- 12
            group = groupA, -- 12
            linearAcceleration = gravity, -- 12
            y = 500, -- 12
            angle = 15 -- 12
        }, -- 12
        React:createElement( -- 12
            "polygon-fixture", -- 12
            { -- 12
                verts = { -- 12
                    Vec2(60, 0), -- 27
                    Vec2(30, -30), -- 28
                    Vec2(-30, -30), -- 29
                    Vec2(-60, 0), -- 30
                    Vec2(-30, 30), -- 31
                    Vec2(30, 30) -- 32
                }, -- 32
                density = 1, -- 32
                friction = 0.4, -- 32
                restitution = 0.4 -- 32
            } -- 32
        ) -- 32
    ), -- 32
    React:createElement( -- 32
        "body", -- 32
        { -- 32
            type = "Dynamic", -- 32
            group = groupB, -- 32
            linearAcceleration = gravity, -- 32
            x = 50, -- 32
            y = 800, -- 32
            angularRate = 90 -- 32
        }, -- 32
        React:createElement("disk-fixture", {radius = 60, density = 1, friction = 0.4, restitution = 0.4}) -- 32
    ), -- 32
    React:createElement( -- 32
        "body", -- 32
        {type = "Static", group = groupTerrain}, -- 32
        React:createElement("rect-fixture", {width = 800, height = 10, friction = 0.8, restitution = 0.2}) -- 32
    ) -- 32
)) -- 32
local windowFlags = { -- 62
    "NoDecoration", -- 63
    "AlwaysAutoResize", -- 64
    "NoSavedSettings", -- 65
    "NoFocusOnAppearing", -- 66
    "NoNav", -- 67
    "NoMove" -- 68
} -- 68
threadLoop(function() -- 70
    local ____App_visualSize_0 = App.visualSize -- 71
    local width = ____App_visualSize_0.width -- 71
    ImGui.SetNextWindowBgAlpha(0.35) -- 72
    ImGui.SetNextWindowPos( -- 73
        Vec2(width - 10, 10), -- 73
        "Always", -- 73
        Vec2(1, 0) -- 73
    ) -- 73
    ImGui.SetNextWindowSize( -- 74
        Vec2(240, 0), -- 74
        "FirstUseEver" -- 74
    ) -- 74
    ImGui.Begin( -- 75
        "Body", -- 75
        windowFlags, -- 75
        function() -- 75
            ImGui.Text("Body (TSX)") -- 76
            ImGui.Separator() -- 77
            ImGui.TextWrapped("Basic usage to create physics bodies!") -- 78
        end -- 75
    ) -- 75
    return false -- 80
end) -- 70
return ____exports -- 70