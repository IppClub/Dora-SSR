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
local CreateManager = ____InputManager.CreateManager -- 6
local Trigger = ____InputManager.Trigger -- 6
local function QTEContext(contextName, keyName, buttonName, timeWindow) -- 15
    return { -- 16
        name = contextName, -- 16
        actions = {{ -- 17
            name = "QTE", -- 18
            trigger = Trigger.Sequence({ -- 18
                Trigger.Selector({ -- 20
                    Trigger.Selector({ -- 21
                        Trigger.KeyPressed(keyName), -- 22
                        Trigger.Block(Trigger.AnyKeyPressed()) -- 23
                    }), -- 23
                    Trigger.Selector({ -- 25
                        Trigger.ButtonPressed(buttonName), -- 26
                        Trigger.Block(Trigger.AnyButtonPressed()) -- 27
                    }) -- 27
                }), -- 27
                Trigger.Selector({ -- 30
                    Trigger.KeyTimed(keyName, timeWindow), -- 31
                    Trigger.ButtonTimed(buttonName, timeWindow) -- 32
                }) -- 32
            }) -- 32
        }} -- 32
    } -- 32
end -- 15
local inputManager = CreateManager({ -- 39
    { -- 40
        name = "Default", -- 40
        actions = { -- 40
            { -- 41
                name = "Confirm", -- 41
                trigger = Trigger.Selector({ -- 41
                    Trigger.ButtonHold("y", 1), -- 43
                    Trigger.KeyHold("Return", 1) -- 44
                }) -- 44
            }, -- 44
            { -- 47
                name = "MoveDown", -- 47
                trigger = Trigger.Selector({ -- 47
                    Trigger.ButtonPressed("dpdown"), -- 49
                    Trigger.KeyPressed("S") -- 50
                }) -- 50
            } -- 50
        } -- 50
    }, -- 50
    { -- 54
        name = "Test", -- 54
        actions = {{ -- 54
            name = "Confirm", -- 55
            trigger = Trigger.Selector({ -- 55
                Trigger.ButtonHold("x", 0.3), -- 57
                Trigger.KeyHold("LCtrl", 0.3) -- 58
            }) -- 58
        }} -- 58
    }, -- 58
    QTEContext("Phase1", "J", "a", 3), -- 62
    QTEContext("Phase2", "K", "b", 2), -- 63
    QTEContext("Phase3", "L", "x", 1) -- 64
}) -- 64
inputManager:pushContext("Default") -- 67
toNode(React:createElement(GamePad, {inputManager = inputManager})) -- 69
local phase = "None" -- 73
local text = "" -- 74
local holdTime = 0 -- 76
local node = Node() -- 77
node:gslot( -- 78
    "Input.Confirm", -- 78
    function(state, progress) -- 78
        if state == "Completed" then -- 78
            holdTime = 1 -- 80
        elseif state == "Ongoing" then -- 80
            holdTime = progress -- 82
        end -- 82
    end -- 78
) -- 78
node:gslot( -- 86
    "Input.MoveDown", -- 86
    function(state, progress, value) -- 86
        if state == "Completed" then -- 86
            print(state, progress, value) -- 88
        end -- 88
    end -- 86
) -- 86
node:gslot( -- 92
    "Input.QTE", -- 92
    function(state, progress, value) -- 92
        repeat -- 92
            local ____switch9 = phase -- 92
            local ____cond9 = ____switch9 == "Phase1" -- 92
            if ____cond9 then -- 92
                repeat -- 92
                    local ____switch10 = state -- 92
                    local ____cond10 = ____switch10 == "Canceled" -- 92
                    if ____cond10 then -- 92
                        phase = "None" -- 97
                        inputManager:popContext() -- 98
                        text = "Failed!" -- 99
                        holdTime = progress -- 100
                        break -- 101
                    end -- 101
                    ____cond10 = ____cond10 or ____switch10 == "Completed" -- 101
                    if ____cond10 then -- 101
                        phase = "Phase2" -- 103
                        inputManager:pushContext("Phase2") -- 104
                        text = "Button B or Key K" -- 105
                        break -- 106
                    end -- 106
                    ____cond10 = ____cond10 or ____switch10 == "Ongoing" -- 106
                    if ____cond10 then -- 106
                        holdTime = progress -- 108
                        break -- 109
                    end -- 109
                until true -- 109
                break -- 111
            end -- 111
            ____cond9 = ____cond9 or ____switch9 == "Phase2" -- 111
            if ____cond9 then -- 111
                repeat -- 111
                    local ____switch11 = state -- 111
                    local ____cond11 = ____switch11 == "Canceled" -- 111
                    if ____cond11 then -- 111
                        phase = "None" -- 115
                        inputManager:popContext(2) -- 116
                        text = "Failed!" -- 117
                        holdTime = progress -- 118
                        break -- 119
                    end -- 119
                    ____cond11 = ____cond11 or ____switch11 == "Completed" -- 119
                    if ____cond11 then -- 119
                        phase = "Phase3" -- 121
                        inputManager:pushContext("Phase3") -- 122
                        text = "Button X or Key L" -- 123
                        break -- 124
                    end -- 124
                    ____cond11 = ____cond11 or ____switch11 == "Ongoing" -- 124
                    if ____cond11 then -- 124
                        holdTime = progress -- 126
                        break -- 127
                    end -- 127
                until true -- 127
                break -- 129
            end -- 129
            ____cond9 = ____cond9 or ____switch9 == "Phase3" -- 129
            if ____cond9 then -- 129
                repeat -- 129
                    local ____switch12 = state -- 129
                    local ____cond12 = ____switch12 == "Canceled" or ____switch12 == "Completed" -- 129
                    if ____cond12 then -- 129
                        phase = "None" -- 134
                        inputManager:popContext(3) -- 135
                        text = state == "Completed" and "Success!" or "Failed!" -- 136
                        holdTime = progress -- 137
                        break -- 138
                    end -- 138
                    ____cond12 = ____cond12 or ____switch12 == "Ongoing" -- 138
                    if ____cond12 then -- 138
                        holdTime = progress -- 140
                        break -- 141
                    end -- 141
                until true -- 141
                break -- 143
            end -- 143
        until true -- 143
    end -- 92
) -- 92
local function QTEButton() -- 147
    if ImGui.Button("Start QTE") then -- 147
        phase = "Phase1" -- 149
        text = "Button A or Key J" -- 150
        inputManager:pushContext("Phase1") -- 151
    end -- 151
end -- 147
local countDownFlags = { -- 154
    "NoResize", -- 155
    "NoSavedSettings", -- 156
    "NoTitleBar", -- 157
    "NoMove", -- 158
    "AlwaysAutoResize" -- 159
} -- 159
node:schedule(loop(function() -- 161
    local ____App_visualSize_0 = App.visualSize -- 162
    local width = ____App_visualSize_0.width -- 162
    local height = ____App_visualSize_0.height -- 162
    ImGui.SetNextWindowPos(Vec2(width / 2 - 160, height / 2 - 100)) -- 163
    ImGui.SetNextWindowSize( -- 164
        Vec2(300, 100), -- 164
        "Always" -- 164
    ) -- 164
    ImGui.Begin( -- 165
        "CountDown", -- 165
        countDownFlags, -- 165
        function() -- 165
            if phase == "None" then -- 165
                QTEButton() -- 167
            else -- 167
                ImGui.BeginDisabled(QTEButton) -- 169
            end -- 169
            ImGui.SameLine() -- 171
            ImGui.Text(text) -- 172
            ImGui.ProgressBar( -- 173
                holdTime, -- 173
                Vec2(-1, 30) -- 173
            ) -- 173
        end -- 165
    ) -- 165
    return false -- 175
end)) -- 161
local checked = false -- 178
local windowFlags = { -- 180
    "NoDecoration", -- 181
    "AlwaysAutoResize", -- 182
    "NoSavedSettings", -- 183
    "NoFocusOnAppearing", -- 184
    "NoNav", -- 185
    "NoMove" -- 186
} -- 186
threadLoop(function() -- 188
    local ____App_visualSize_1 = App.visualSize -- 189
    local width = ____App_visualSize_1.width -- 189
    ImGui.SetNextWindowBgAlpha(0.35) -- 190
    ImGui.SetNextWindowPos( -- 191
        Vec2(width - 10, 10), -- 191
        "Always", -- 191
        Vec2(1, 0) -- 191
    ) -- 191
    ImGui.SetNextWindowSize( -- 192
        Vec2(240, 0), -- 192
        "FirstUseEver" -- 192
    ) -- 192
    ImGui.Begin( -- 193
        "EnhancedInput", -- 193
        windowFlags, -- 193
        function() -- 193
            ImGui.Text("Enhanced Input (TSX)") -- 194
            ImGui.Separator() -- 195
            ImGui.TextWrapped("Change input context to alter input mapping") -- 196
            if phase == "None" then -- 196
                local changed, result = ImGui.Checkbox("hold X to Confirm (instead Y)", checked) -- 198
                if changed then -- 198
                    if checked then -- 198
                        inputManager:popContext() -- 201
                    else -- 201
                        inputManager:pushContext("Test") -- 203
                    end -- 203
                    checked = result -- 205
                end -- 205
            end -- 205
        end -- 193
    ) -- 193
    return false -- 209
end) -- 188
return ____exports -- 188