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
local windowFlags = { -- 61
    "NoDecoration", -- 62
    "AlwaysAutoResize", -- 63
    "NoSavedSettings", -- 64
    "NoFocusOnAppearing", -- 65
    "NoNav", -- 66
    "NoMove" -- 67
} -- 67
threadLoop(function() -- 69
    local ____App_visualSize_0 = App.visualSize -- 70
    local width = ____App_visualSize_0.width -- 70
    ImGui.SetNextWindowBgAlpha(0.35) -- 71
    ImGui.SetNextWindowPos( -- 72
        Vec2(width - 10, 10), -- 72
        "Always", -- 72
        Vec2(1, 0) -- 72
    ) -- 72
    ImGui.SetNextWindowSize( -- 73
        Vec2(240, 0), -- 73
        "FirstUseEver" -- 73
    ) -- 73
    ImGui.Begin( -- 74
        "Body", -- 74
        windowFlags, -- 74
        function() -- 74
            ImGui.Text("Body") -- 75
            ImGui.Separator() -- 76
            ImGui.TextWrapped("Basic usage to create physics bodies!") -- 77
        end -- 74
    ) -- 74
    return false -- 79
end) -- 69
return ____exports -- 69