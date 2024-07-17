-- [tsx]: InputTestTSX.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local Node = ____Dora.Node -- 3
local Vec2 = ____Dora.Vec2 -- 3
local loop = ____Dora.loop -- 3
local threadLoop = ____Dora.threadLoop -- 3
local ImGui = require("ImGui") -- 4
local ____InputManager = require("InputManager") -- 6
local GamePad = ____InputManager.GamePad -- 6
local CreateInputManager = ____InputManager.CreateInputManager -- 6
local Trigger = ____InputManager.Trigger -- 6
local inputManager = CreateInputManager({ -- 8
    { -- 9
        name = "Default", -- 10
        actions = { -- 11
            { -- 12
                name = "Confirm", -- 12
                trigger = Trigger.Selector({ -- 12
                    Trigger.ButtonHold("a", 1), -- 14
                    Trigger.KeyHold("Return", 1) -- 15
                }) -- 15
            }, -- 15
            { -- 18
                name = "MoveDown", -- 18
                trigger = Trigger.Selector({ -- 18
                    Trigger.ButtonPressed("dpdown"), -- 20
                    Trigger.KeyPressed("S") -- 21
                }) -- 21
            } -- 21
        } -- 21
    }, -- 21
    { -- 26
        name = "Test", -- 27
        actions = {{ -- 28
            name = "Confirm", -- 29
            trigger = Trigger.Selector({ -- 29
                Trigger.ButtonHold("x", 0.5), -- 31
                Trigger.KeyHold("LCtrl", 0.5) -- 32
            }) -- 32
        }} -- 32
    } -- 32
}) -- 32
toNode(React:createElement(GamePad, {inputManager = inputManager})) -- 39
local holdTime = 0 -- 43
local node = Node() -- 44
node:gslot( -- 45
    "Input.Confirm", -- 45
    function(state, progress, value) -- 45
        if state == "Completed" then -- 45
            holdTime = 1 -- 47
        elseif state == "Ongoing" then -- 47
            holdTime = progress -- 49
        end -- 49
    end -- 45
) -- 45
node:gslot( -- 53
    "Input.MoveDown", -- 53
    function(state, progress, value) -- 53
        if state == "Completed" then -- 53
            print(state, progress, value) -- 55
        end -- 55
    end -- 53
) -- 53
node:schedule(loop(function() -- 58
    local ____App_visualSize_0 = App.visualSize -- 59
    local width = ____App_visualSize_0.width -- 59
    local height = ____App_visualSize_0.height -- 59
    ImGui.SetNextWindowPos(Vec2(width / 2 - 150, height / 2 - 50)) -- 60
    ImGui.SetNextWindowSize( -- 61
        Vec2(300, 50), -- 61
        "FirstUseEver" -- 61
    ) -- 61
    ImGui.Begin( -- 62
        "CountDown", -- 62
        {"NoResize", "NoSavedSettings", "NoTitleBar", "NoMove"}, -- 62
        function() -- 62
            ImGui.ProgressBar( -- 63
                holdTime, -- 63
                Vec2(-1, 30) -- 63
            ) -- 63
        end -- 62
    ) -- 62
    return false -- 65
end)) -- 58
local checked = false -- 68
local windowFlags = { -- 70
    "NoDecoration", -- 71
    "AlwaysAutoResize", -- 72
    "NoSavedSettings", -- 73
    "NoFocusOnAppearing", -- 74
    "NoNav", -- 75
    "NoMove" -- 76
} -- 76
threadLoop(function() -- 78
    local ____App_visualSize_1 = App.visualSize -- 79
    local width = ____App_visualSize_1.width -- 79
    ImGui.SetNextWindowBgAlpha(0.35) -- 80
    ImGui.SetNextWindowPos( -- 81
        Vec2(width - 10, 10), -- 81
        "Always", -- 81
        Vec2(1, 0) -- 81
    ) -- 81
    ImGui.SetNextWindowSize( -- 82
        Vec2(240, 0), -- 82
        "FirstUseEver" -- 82
    ) -- 82
    ImGui.Begin( -- 83
        "EnhancedInput", -- 83
        windowFlags, -- 83
        function() -- 83
            ImGui.Text("Enhanced Input (TSX)") -- 84
            ImGui.Separator() -- 85
            ImGui.TextWrapped("Change input context to alter input mapping") -- 86
            local changed, result = ImGui.Checkbox("X to Confirm (not A)", checked) -- 87
            if changed then -- 87
                if checked then -- 87
                    inputManager:popContext() -- 90
                else -- 90
                    inputManager:pushContext({"Test"}) -- 92
                end -- 92
                checked = result -- 94
            end -- 94
        end -- 83
    ) -- 83
    return false -- 97
end) -- 78
return ____exports -- 78