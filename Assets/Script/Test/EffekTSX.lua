-- [tsx]: EffekTSX.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____dora_2Dx = require("dora-x") -- 2
local React = ____dora_2Dx.React -- 2
local toNode = ____dora_2Dx.toNode -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Vec2 = ____dora.Vec2 -- 3
local threadLoop = ____dora.threadLoop -- 3
local ImGui = require("ImGui") -- 5
local current = nil -- 7
local function Test(name, jsx) -- 9
    return { -- 10
        name = name, -- 10
        test = function() -- 10
            current = toNode(jsx) -- 11
        end -- 10
    } -- 10
end -- 9
local tests = { -- 15
    Test( -- 17
        "Laser", -- 17
        React:createElement( -- 17
            "effek-node", -- 17
            {scaleX = 50, scaleY = 50, x = -300, angleY = -90}, -- 17
            React:createElement("effek", {file = "Particle/effek/Laser01.efk"}) -- 17
        ) -- 17
    ), -- 17
    Test( -- 23
        "Simple Model UV", -- 23
        React:createElement( -- 23
            "effek-node", -- 23
            {scaleX = 50, scaleY = 50, y = -200}, -- 23
            React:createElement("effek", {file = "Particle/effek/Simple_Model_UV.efkefc"}) -- 23
        ) -- 23
    ), -- 23
    Test( -- 29
        "Sword Lightning", -- 29
        React:createElement( -- 29
            "effek-node", -- 29
            {scaleX = 50, scaleY = 50, y = -300}, -- 29
            React:createElement("effek", {file = "Particle/effek/sword_lightning.efkefc"}) -- 29
        ) -- 29
    ) -- 29
} -- 29
tests[1]:test() -- 36
local testNames = __TS__ArrayMap( -- 38
    tests, -- 38
    function(____, t) return t.name end -- 38
) -- 38
local currentTest = 1 -- 40
local windowFlags = { -- 41
    "NoDecoration", -- 42
    "NoSavedSettings", -- 43
    "NoFocusOnAppearing", -- 44
    "NoNav", -- 45
    "NoMove" -- 46
} -- 46
threadLoop(function() -- 48
    local ____App_visualSize_0 = App.visualSize -- 49
    local width = ____App_visualSize_0.width -- 49
    ImGui.SetNextWindowPos( -- 50
        Vec2(width - 10, 10), -- 50
        "Always", -- 50
        Vec2(1, 0) -- 50
    ) -- 50
    ImGui.SetNextWindowSize( -- 51
        Vec2(200, 0), -- 51
        "Always" -- 51
    ) -- 51
    ImGui.Begin( -- 52
        "Effekseer", -- 52
        windowFlags, -- 52
        function() -- 52
            ImGui.Text("Effekseer (TSX)") -- 53
            ImGui.Separator() -- 54
            local changed = false -- 55
            changed, currentTest = ImGui.Combo("Test", currentTest, testNames) -- 56
            if changed then -- 56
                if current then -- 56
                    current:removeFromParent() -- 59
                end -- 59
                tests[currentTest]:test() -- 61
            end -- 61
        end -- 52
    ) -- 52
    return false -- 64
end) -- 48
return ____exports -- 48