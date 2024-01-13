-- [ts]: RenderGroupTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 2
local ____dora = require("dora") -- 3
local Angle = ____dora.Angle -- 3
local App = ____dora.App -- 3
local Color = ____dora.Color -- 3
local DrawNode = ____dora.DrawNode -- 3
local Line = ____dora.Line -- 3
local Node = ____dora.Node -- 3
local Size = ____dora.Size -- 3
local Sprite = ____dora.Sprite -- 3
local Vec2 = ____dora.Vec2 -- 3
local threadLoop = ____dora.threadLoop -- 3
local function Item() -- 5
    local node = Node() -- 6
    node.width = 144 -- 7
    node.height = 144 -- 8
    node.anchor = Vec2.zero -- 9
    local sprite = Sprite("Image/logo.png"):addTo(node) -- 11
    sprite.scaleX = 0.1 -- 12
    sprite.scaleY = 0.1 -- 13
    sprite.renderOrder = 1 -- 14
    local drawNode = DrawNode():addTo(node) -- 16
    drawNode:drawPolygon( -- 17
        { -- 17
            Vec2(-60, -60), -- 18
            Vec2(60, -60), -- 19
            Vec2(60, 60), -- 20
            Vec2(-60, 60) -- 21
        }, -- 21
        Color(822018176) -- 22
    ) -- 22
    drawNode.renderOrder = 2 -- 23
    drawNode.angle = 45 -- 24
    local line = Line( -- 26
        { -- 26
            Vec2(-60, -60), -- 27
            Vec2(60, -60), -- 28
            Vec2(60, 60), -- 29
            Vec2(-60, 60), -- 30
            Vec2(-60, -60) -- 31
        }, -- 31
        Color(4294901888) -- 32
    ):addTo(node) -- 32
    line.renderOrder = 3 -- 33
    line.angle = 45 -- 34
    node:runAction(Angle(5, 0, 360)) -- 36
    node:slot( -- 37
        "ActionEnd", -- 37
        function(action) -- 37
            node:runAction(action) -- 38
        end -- 37
    ) -- 37
    return node -- 40
end -- 5
local currentEntry = Node() -- 43
currentEntry.renderGroup = true -- 44
currentEntry.size = Size(750, 750) -- 45
do -- 45
    local _i = 1 -- 46
    while _i <= 16 do -- 46
        currentEntry:addChild(Item()) -- 47
        _i = _i + 1 -- 46
    end -- 46
end -- 46
currentEntry:alignItems() -- 50
local renderGroup = currentEntry.renderGroup -- 52
local windowFlags = { -- 53
    "NoDecoration", -- 54
    "AlwaysAutoResize", -- 55
    "NoSavedSettings", -- 56
    "NoFocusOnAppearing", -- 57
    "NoNav", -- 58
    "NoMove" -- 59
} -- 59
threadLoop(function() -- 61
    local ____App_visualSize_0 = App.visualSize -- 62
    local width = ____App_visualSize_0.width -- 62
    ImGui.SetNextWindowBgAlpha(0.35) -- 63
    ImGui.SetNextWindowPos( -- 64
        Vec2(width - 10, 10), -- 64
        "Always", -- 64
        Vec2(1, 0) -- 64
    ) -- 64
    ImGui.SetNextWindowSize( -- 65
        Vec2(240, 0), -- 65
        "FirstUseEver" -- 65
    ) -- 65
    ImGui.Begin( -- 66
        "Render Group", -- 66
        windowFlags, -- 66
        function() -- 66
            ImGui.Text("Render Group") -- 67
            ImGui.Separator() -- 68
            ImGui.TextWrapped("When render group is enabled, the nodes in the sub render tree will be grouped by \"renderOrder\" property, and get rendered in ascending order!\nNotice the draw call changes in stats window.") -- 69
            local changed = false -- 70
            changed, renderGroup = ImGui.Checkbox("Grouped", renderGroup) -- 71
            if changed then -- 71
                currentEntry.renderGroup = renderGroup -- 73
            end -- 73
        end -- 66
    ) -- 66
    return false -- 76
end) -- 61
return ____exports -- 61