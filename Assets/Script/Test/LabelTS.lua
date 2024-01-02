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
local label = Label("sarasa-mono-sc-regular", 40):addTo(node) -- 7
label.batched = false -- 8
label.text = "你好，Dora SSR！" -- 9
do -- 9
    local i = 1 -- 10
    while i <= label.characterCount do -- 10
        local char = label:getCharacter(i) -- 11
        if char ~= nil then -- 11
            char:runAction(Sequence( -- 13
                Delay(i / 5), -- 15
                Scale(0.2, 1, 2), -- 16
                Scale(0.2, 2, 1) -- 17
            )) -- 17
        end -- 17
        i = i + 1 -- 10
    end -- 10
end -- 10
local labelS = Label("sarasa-mono-sc-regular", 30):addTo(node) -- 23
labelS.text = "-- from Jin."
labelS.color = App.themeColor -- 25
labelS.opacity = 0 -- 26
labelS.position = Vec2(120, -70) -- 27
labelS:runAction(Sequence( -- 28
    Delay(2), -- 30
    Opacity(0.2, 0, 1) -- 31
)) -- 31
local windowFlags = { -- 35
    "NoDecoration", -- 36
    "AlwaysAutoResize", -- 37
    "NoSavedSettings", -- 38
    "NoFocusOnAppearing", -- 39
    "NoNav", -- 40
    "NoMove" -- 41
} -- 41
threadLoop(function() -- 43
    local size = App.visualSize -- 44
    ImGui.SetNextWindowBgAlpha(0.35) -- 45
    ImGui.SetNextWindowPos( -- 46
        Vec2(size.width - 10, 10), -- 46
        "Always", -- 46
        Vec2(1, 0) -- 46
    ) -- 46
    ImGui.SetNextWindowSize( -- 47
        Vec2(240, 0), -- 47
        "FirstUseEver" -- 47
    ) -- 47
    ImGui.Begin( -- 48
        "Label", -- 48
        windowFlags, -- 48
        function() -- 48
            ImGui.Text("Label") -- 49
            ImGui.Separator() -- 50
            ImGui.TextWrapped("Render labels with unbatched and batched methods!") -- 51
        end -- 48
    ) -- 48
    return false -- 53
end) -- 43
return ____exports -- 43