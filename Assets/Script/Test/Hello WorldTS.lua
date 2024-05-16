-- [ts]: Hello WorldTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____Dora = require("Dora") -- 4
local App = ____Dora.App -- 4
local Node = ____Dora.Node -- 4
local Vec2 = ____Dora.Vec2 -- 4
local once = ____Dora.once -- 4
local sleep = ____Dora.sleep -- 4
local threadLoop = ____Dora.threadLoop -- 4
local node = Node() -- 6
node:slot( -- 7
    "Enter", -- 7
    function() -- 7
        print("on enter event") -- 8
    end -- 7
) -- 7
node:slot( -- 10
    "Exit", -- 10
    function() -- 10
        print("on exit event") -- 11
    end -- 10
) -- 10
node:slot( -- 13
    "Cleanup", -- 13
    function() -- 13
        print("on node destoyed event") -- 14
    end -- 13
) -- 13
node:schedule(once(function() -- 16
    do -- 16
        local i = 5 -- 17
        while i >= 1 do -- 17
            print(i) -- 18
            sleep(1) -- 19
            i = i - 1 -- 17
        end -- 17
    end -- 17
    print("Hello World!") -- 21
end)) -- 16
local windowFlags = { -- 24
    "NoDecoration", -- 25
    "AlwaysAutoResize", -- 26
    "NoSavedSettings", -- 27
    "NoFocusOnAppearing", -- 28
    "NoNav", -- 29
    "NoMove" -- 30
} -- 30
threadLoop(function() -- 32
    local size = App.visualSize -- 33
    ImGui.SetNextWindowBgAlpha(0.35) -- 34
    ImGui.SetNextWindowPos( -- 35
        Vec2(size.width - 10, 10), -- 35
        "Always", -- 35
        Vec2(1, 0) -- 35
    ) -- 35
    ImGui.SetNextWindowSize( -- 36
        Vec2(240, 0), -- 36
        "FirstUseEver" -- 36
    ) -- 36
    ImGui.Begin( -- 37
        "Hello World", -- 37
        windowFlags, -- 37
        function() -- 37
            ImGui.Text("Hello World (Typescript)") -- 38
            ImGui.Separator() -- 39
            ImGui.TextWrapped("Basic Dora schedule and signal function usage. Written in Teal. View outputs in log window!") -- 40
        end -- 37
    ) -- 37
    return false -- 42
end) -- 32
return ____exports -- 32