-- [ts]: LabelTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____dora = require("dora") -- 4
local App = ____dora.App -- 4
local Delay = ____dora.Delay -- 4
local Label = ____dora.Label -- 4
local Node = ____dora.Node -- 4
local Opacity = ____dora.Opacity -- 4
local Scale = ____dora.Scale -- 4
local Sequence = ____dora.Sequence -- 4
local Vec2 = ____dora.Vec2 -- 4
local threadLoop = ____dora.threadLoop -- 4
local node = Node() -- 6
local ____opt_0 = Label("sarasa-mono-sc-regular", 40) -- 6
local label = ____opt_0 and ____opt_0:addTo(node) -- 8
if label then -- 8
    label.batched = false -- 10
    label.text = "你好，Dora SSR！" -- 11
    do -- 11
        local i = 1 -- 12
        while i <= label.characterCount do -- 12
            local char = label:getCharacter(i) -- 13
            if char ~= nil then -- 13
                char:runAction(Sequence( -- 15
                    Delay(i / 5), -- 17
                    Scale(0.2, 1, 2), -- 18
                    Scale(0.2, 2, 1) -- 19
                )) -- 19
            end -- 19
            i = i + 1 -- 12
        end -- 12
    end -- 12
end -- 12
local ____opt_2 = Label("sarasa-mono-sc-regular", 30) -- 12
local labelS = ____opt_2 and ____opt_2:addTo(node) -- 26
if labelS then -- 26
    labelS.text = "-- from Jin."
    labelS.color = App.themeColor -- 29
    labelS.opacity = 0 -- 30
    labelS.position = Vec2(120, -70) -- 31
    labelS:runAction(Sequence( -- 32
        Delay(2), -- 34
        Opacity(0.2, 0, 1) -- 35
    )) -- 35
end -- 35
local windowFlags = { -- 40
    "NoDecoration", -- 41
    "AlwaysAutoResize", -- 42
    "NoSavedSettings", -- 43
    "NoFocusOnAppearing", -- 44
    "NoNav", -- 45
    "NoMove" -- 46
} -- 46
threadLoop(function() -- 48
    local size = App.visualSize -- 49
    ImGui.SetNextWindowBgAlpha(0.35) -- 50
    ImGui.SetNextWindowPos( -- 51
        Vec2(size.width - 10, 10), -- 51
        "Always", -- 51
        Vec2(1, 0) -- 51
    ) -- 51
    ImGui.SetNextWindowSize( -- 52
        Vec2(240, 0), -- 52
        "FirstUseEver" -- 52
    ) -- 52
    ImGui.Begin( -- 53
        "Label", -- 53
        windowFlags, -- 53
        function() -- 53
            ImGui.Text("Label (Typescript)") -- 54
            ImGui.Separator() -- 55
            ImGui.TextWrapped("Render labels with unbatched and batched methods!") -- 56
        end -- 53
    ) -- 53
    return false -- 58
end) -- 48
return ____exports -- 48