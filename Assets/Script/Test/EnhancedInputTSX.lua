-- [tsx]: EnhancedInputTSX.tsx
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
        name = "Default", -- 9
        actions = { -- 9
            { -- 10
                name = "Confirm", -- 10
                trigger = Trigger.Selector({ -- 10
                    Trigger.ButtonHold("a", 1), -- 12
                    Trigger.KeyHold("Return", 1) -- 13
                }) -- 13
            }, -- 13
            { -- 16
                name = "MoveDown", -- 16
                trigger = Trigger.Selector({ -- 16
                    Trigger.ButtonPressed("dpdown"), -- 18
                    Trigger:KeyDoubleDown("S") -- 19
                }) -- 19
            } -- 19
        } -- 19
    }, -- 19
    { -- 23
        name = "Test", -- 23
        actions = {{ -- 23
            name = "Confirm", -- 24
            trigger = Trigger.Selector({ -- 24
                Trigger.ButtonHold("x", 0.3), -- 26
                Trigger.KeyHold("LCtrl", 0.3) -- 27
            }) -- 27
        }} -- 27
    } -- 27
}) -- 27
inputManager:pushContext("Default") -- 33
toNode(React:createElement(GamePad, {inputManager = inputManager})) -- 35
local holdTime = 0 -- 39
local node = Node() -- 40
node:gslot( -- 41
    "Input.Confirm", -- 41
    function(state, progress) -- 41
        if state == "Completed" then -- 41
            holdTime = 1 -- 43
        elseif state == "Ongoing" then -- 43
            holdTime = progress -- 45
        end -- 45
    end -- 41
) -- 41
node:gslot( -- 49
    "Input.MoveDown", -- 49
    function(state, progress, value) -- 49
        if state == "Completed" then -- 49
            print(state, progress, value) -- 51
        end -- 51
    end -- 49
) -- 49
local countDownFlags = {"NoResize", "NoSavedSettings", "NoTitleBar", "NoMove"} -- 55
node:schedule(loop(function() -- 61
    local ____App_visualSize_0 = App.visualSize -- 62
    local width = ____App_visualSize_0.width -- 62
    local height = ____App_visualSize_0.height -- 62
    ImGui.SetNextWindowPos(Vec2(width / 2 - 160, height / 2 - 50)) -- 63
    ImGui.SetNextWindowSize( -- 64
        Vec2(300, 50), -- 64
        "FirstUseEver" -- 64
    ) -- 64
    ImGui.Begin( -- 65
        "CountDown", -- 65
        countDownFlags, -- 65
        function() -- 65
            ImGui.ProgressBar( -- 66
                holdTime, -- 66
                Vec2(-1, 30) -- 66
            ) -- 66
        end -- 65
    ) -- 65
    return false -- 68
end)) -- 61
local checked = false -- 71
local windowFlags = { -- 73
    "NoDecoration", -- 74
    "AlwaysAutoResize", -- 75
    "NoSavedSettings", -- 76
    "NoFocusOnAppearing", -- 77
    "NoNav", -- 78
    "NoMove" -- 79
} -- 79
threadLoop(function() -- 81
    local ____App_visualSize_1 = App.visualSize -- 82
    local width = ____App_visualSize_1.width -- 82
    ImGui.SetNextWindowBgAlpha(0.35) -- 83
    ImGui.SetNextWindowPos( -- 84
        Vec2(width - 10, 10), -- 84
        "Always", -- 84
        Vec2(1, 0) -- 84
    ) -- 84
    ImGui.SetNextWindowSize( -- 85
        Vec2(240, 0), -- 85
        "FirstUseEver" -- 85
    ) -- 85
    ImGui.Begin( -- 86
        "EnhancedInput", -- 86
        windowFlags, -- 86
        function() -- 86
            ImGui.Text("Enhanced Input (TSX)") -- 87
            ImGui.Separator() -- 88
            ImGui.TextWrapped("Change input context to alter input mapping") -- 89
            local changed, result = ImGui.Checkbox("X to Confirm (not A)", checked) -- 90
            if changed then -- 90
                if checked then -- 90
                    inputManager:popContext() -- 93
                else -- 93
                    inputManager:pushContext("Test") -- 95
                end -- 95
                checked = result -- 97
            end -- 97
        end -- 86
    ) -- 86
    return false -- 100
end) -- 81
return ____exports -- 81