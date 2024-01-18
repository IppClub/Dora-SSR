-- [ts]: LabelTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Delay = ____dora.Delay -- 3
local Label = ____dora.Label -- 3
local Node = ____dora.Node -- 3
local Opacity = ____dora.Opacity -- 3
local Scale = ____dora.Scale -- 3
local Sequence = ____dora.Sequence -- 3
local Vec2 = ____dora.Vec2 -- 3
local threadLoop = ____dora.threadLoop -- 3
local node = Node() -- 5
local ____opt_0 = Label("sarasa-mono-sc-regular", 40) -- 5
local label = ____opt_0 and ____opt_0:addTo(node) -- 7
if label then -- 7
    label.batched = false -- 9
    label.text = "你好，Dora SSR！" -- 10
    do -- 10
        local i = 1 -- 11
        while i <= label.characterCount do -- 11
            local char = label:getCharacter(i) -- 12
            if char ~= nil then -- 12
                char:runAction(Sequence( -- 14
                    Delay(i / 5), -- 16
                    Scale(0.2, 1, 2), -- 17
                    Scale(0.2, 2, 1) -- 18
                )) -- 18
            end -- 18
            i = i + 1 -- 11
        end -- 11
    end -- 11
end -- 11
local ____opt_2 = Label("sarasa-mono-sc-regular", 30) -- 11
local labelS = ____opt_2 and ____opt_2:addTo(node) -- 25
if labelS then -- 25
    labelS.text = "-- from Jin."
    labelS.color = App.themeColor -- 28
    labelS.opacity = 0 -- 29
    labelS.position = Vec2(120, -70) -- 30
    labelS:runAction(Sequence( -- 31
        Delay(2), -- 33
        Opacity(0.2, 0, 1) -- 34
    )) -- 34
end -- 34
local windowFlags = { -- 39
    "NoDecoration", -- 40
    "AlwaysAutoResize", -- 41
    "NoSavedSettings", -- 42
    "NoFocusOnAppearing", -- 43
    "NoNav", -- 44
    "NoMove" -- 45
} -- 45
threadLoop(function() -- 47
    local size = App.visualSize -- 48
    ImGui.SetNextWindowBgAlpha(0.35) -- 49
    ImGui.SetNextWindowPos( -- 50
        Vec2(size.width - 10, 10), -- 50
        "Always", -- 50
        Vec2(1, 0) -- 50
    ) -- 50
    ImGui.SetNextWindowSize( -- 51
        Vec2(240, 0), -- 51
        "FirstUseEver" -- 51
    ) -- 51
    ImGui.Begin( -- 52
        "Label", -- 52
        windowFlags, -- 52
        function() -- 52
            ImGui.Text("Label") -- 53
            ImGui.Separator() -- 54
            ImGui.TextWrapped("Render labels with unbatched and batched methods!") -- 55
        end -- 52
    ) -- 52
    return false -- 57
end) -- 47
return ____exports -- 47