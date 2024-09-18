-- [tsx]: Hello WorldTSX.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ImGui = require("ImGui") -- 4
local ____Dora = require("Dora") -- 5
local App = ____Dora.App -- 5
local Vec2 = ____Dora.Vec2 -- 5
local once = ____Dora.once -- 5
local sleep = ____Dora.sleep -- 5
local threadLoop = ____Dora.threadLoop -- 5
toNode(React.createElement( -- 7
    "node", -- 7
    { -- 7
        onEnter = function() -- 7
            print("on enter event") -- 10
        end, -- 9
        onExit = function() -- 9
            print("on exit event") -- 13
        end, -- 12
        onCleanup = function() -- 12
            print("on node destoyed event") -- 16
        end, -- 15
        onUpdate = once(function() -- 15
            do -- 15
                local i = 5 -- 19
                while i >= 1 do -- 19
                    print(i) -- 20
                    sleep(1) -- 21
                    i = i - 1 -- 19
                end -- 19
            end -- 19
            print("Hello World!") -- 23
        end) -- 18
    } -- 18
)) -- 18
local windowFlags = { -- 28
    "NoDecoration", -- 29
    "AlwaysAutoResize", -- 30
    "NoSavedSettings", -- 31
    "NoFocusOnAppearing", -- 32
    "NoNav", -- 33
    "NoMove" -- 34
} -- 34
threadLoop(function() -- 36
    local size = App.visualSize -- 37
    ImGui.SetNextWindowBgAlpha(0.35) -- 38
    ImGui.SetNextWindowPos( -- 39
        Vec2(size.width - 10, 10), -- 39
        "Always", -- 39
        Vec2(1, 0) -- 39
    ) -- 39
    ImGui.SetNextWindowSize( -- 40
        Vec2(240, 0), -- 40
        "FirstUseEver" -- 40
    ) -- 40
    ImGui.Begin( -- 41
        "Hello World", -- 41
        windowFlags, -- 41
        function() -- 41
            ImGui.Text("Hello World (TSX)") -- 42
            ImGui.Separator() -- 43
            ImGui.TextWrapped("Basic Dora schedule and signal function usage. Written in Teal. View outputs in log window!") -- 44
        end -- 41
    ) -- 41
    return false -- 46
end) -- 36
return ____exports -- 36