-- [ts]: RenderGroupTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 83
local ____dora = require("dora") -- 84
local Angle = ____dora.Angle -- 84
local App = ____dora.App -- 84
local Color = ____dora.Color -- 84
local DrawNode = ____dora.DrawNode -- 84
local Line = ____dora.Line -- 84
local Node = ____dora.Node -- 84
local Size = ____dora.Size -- 84
local Sprite = ____dora.Sprite -- 84
local Vec2 = ____dora.Vec2 -- 84
local threadLoop = ____dora.threadLoop -- 84
local function Item() -- 86
    local node = Node() -- 87
    node.width = 144 -- 88
    node.height = 144 -- 89
    node.anchor = Vec2.zero -- 90
    local sprite = Sprite("Image/logo.png"):addTo(node) -- 92
    sprite.scaleX = 0.1 -- 93
    sprite.scaleY = 0.1 -- 94
    sprite.renderOrder = 1 -- 95
    local drawNode = DrawNode():addTo(node) -- 97
    drawNode:drawPolygon( -- 98
        { -- 98
            Vec2(-60, -60), -- 99
            Vec2(60, -60), -- 100
            Vec2(60, 60), -- 101
            Vec2(-60, 60) -- 102
        }, -- 102
        Color(822018176) -- 103
    ) -- 103
    drawNode.renderOrder = 2 -- 104
    drawNode.angle = 45 -- 105
    local line = Line( -- 107
        { -- 107
            Vec2(-60, -60), -- 108
            Vec2(60, -60), -- 109
            Vec2(60, 60), -- 110
            Vec2(-60, 60), -- 111
            Vec2(-60, -60) -- 112
        }, -- 112
        Color(4294901888) -- 113
    ):addTo(node) -- 113
    line.renderOrder = 3 -- 114
    line.angle = 45 -- 115
    node:runAction(Angle(5, 0, 360)) -- 117
    node:slot( -- 118
        "ActionEnd", -- 118
        function(action) -- 118
            node:runAction(action) -- 119
        end -- 118
    ) -- 118
    return node -- 121
end -- 86
local currentEntry = Node() -- 124
currentEntry.renderGroup = true -- 125
currentEntry.size = Size(750, 750) -- 126
do -- 126
    local _i = 1 -- 127
    while _i <= 16 do -- 127
        currentEntry:addChild(Item()) -- 128
        _i = _i + 1 -- 127
    end -- 127
end -- 127
currentEntry:alignItems() -- 131
local renderGroup = currentEntry.renderGroup -- 133
local windowFlags = { -- 134
    "NoDecoration", -- 135
    "AlwaysAutoResize", -- 136
    "NoSavedSettings", -- 137
    "NoFocusOnAppearing", -- 138
    "NoNav", -- 139
    "NoMove" -- 140
} -- 140
threadLoop(function() -- 142
    local ____App_visualSize_0 = App.visualSize -- 143
    local width = ____App_visualSize_0.width -- 143
    ImGui.SetNextWindowBgAlpha(0.35) -- 144
    ImGui.SetNextWindowPos( -- 145
        Vec2(width - 10, 10), -- 145
        "Always", -- 145
        Vec2(1, 0) -- 145
    ) -- 145
    ImGui.SetNextWindowSize( -- 146
        Vec2(240, 0), -- 146
        "FirstUseEver" -- 146
    ) -- 146
    ImGui.Begin( -- 147
        "Render Group", -- 147
        windowFlags, -- 147
        function() -- 147
            ImGui.Text("Render Group") -- 148
            ImGui.Separator() -- 149
            ImGui.TextWrapped("When render group is enabled, the nodes in the sub render tree will be grouped by \"renderOrder\" property, and get rendered in ascending order!\nNotice the draw call changes in stats window.") -- 150
            local changed = false -- 151
            changed, renderGroup = ImGui.Checkbox("Grouped", renderGroup) -- 152
            if changed then -- 152
                currentEntry.renderGroup = renderGroup -- 154
            end -- 154
        end -- 147
    ) -- 147
    return false -- 157
end) -- 142
return ____exports -- 142