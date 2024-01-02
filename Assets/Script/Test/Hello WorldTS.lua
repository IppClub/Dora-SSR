-- [ts]: Hello WorldTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Node = ____dora.Node -- 3
local Vec2 = ____dora.Vec2 -- 3
local once = ____dora.once -- 3
local sleep = ____dora.sleep -- 3
local threadLoop = ____dora.threadLoop -- 3
local node = Node() -- 5
node:slot( -- 6
    "Enter", -- 6
    function() -- 6
        print("on enter event") -- 7
    end -- 6
) -- 6
node:slot( -- 9
    "Exit", -- 9
    function() -- 9
        print("on exit event") -- 10
    end -- 9
) -- 9
node:slot( -- 12
    "Cleanup", -- 12
    function() -- 12
        print("on node destoyed event") -- 13
    end -- 12
) -- 12
node:schedule(once(function() -- 15
    do -- 15
        local i = 5 -- 16
        while i >= 1 do -- 16
            print(i) -- 17
            sleep(1) -- 18
            i = i - 1 -- 16
        end -- 16
    end -- 16
    print("Hello World!") -- 20
end)) -- 15
local windowFlags = { -- 23
    "NoDecoration", -- 24
    "AlwaysAutoResize", -- 25
    "NoSavedSettings", -- 26
    "NoFocusOnAppearing", -- 27
    "NoNav", -- 28
    "NoMove" -- 29
} -- 29
threadLoop(function() -- 31
    local size = App.visualSize -- 32
    ImGui.SetNextWindowBgAlpha(0.35) -- 33
    ImGui.SetNextWindowPos( -- 34
        Vec2(size.width - 10, 10), -- 34
        "Always", -- 34
        Vec2(1, 0) -- 34
    ) -- 34
    ImGui.SetNextWindowSize( -- 35
        Vec2(240, 0), -- 35
        "FirstUseEver" -- 35
    ) -- 35
    ImGui.Begin( -- 36
        "Hello World", -- 36
        windowFlags, -- 36
        function() -- 36
            ImGui.Text("Hello World") -- 37
            ImGui.Separator() -- 38
            ImGui.TextWrapped("Basic Dora schedule and signal function usage. Written in Teal. View outputs in log window!") -- 39
        end -- 36
    ) -- 36
    return false -- 41
end) -- 31
return ____exports -- 31