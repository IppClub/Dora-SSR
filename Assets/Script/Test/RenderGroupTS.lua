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
    local ____opt_0 = Sprite("Image/logo.png") -- 9
    local sprite = ____opt_0 and ____opt_0:addTo(node) -- 11
    if sprite then -- 11
        sprite.scaleX = 0.1 -- 13
        sprite.scaleY = 0.1 -- 14
        sprite.renderOrder = 1 -- 15
    end -- 15
    local drawNode = DrawNode():addTo(node) -- 18
    drawNode:drawPolygon( -- 19
        { -- 19
            Vec2(-60, -60), -- 20
            Vec2(60, -60), -- 21
            Vec2(60, 60), -- 22
            Vec2(-60, 60) -- 23
        }, -- 23
        Color(822018176) -- 24
    ) -- 24
    drawNode.renderOrder = 2 -- 25
    drawNode.angle = 45 -- 26
    local line = Line( -- 28
        { -- 28
            Vec2(-60, -60), -- 29
            Vec2(60, -60), -- 30
            Vec2(60, 60), -- 31
            Vec2(-60, 60), -- 32
            Vec2(-60, -60) -- 33
        }, -- 33
        Color(4294901888) -- 34
    ):addTo(node) -- 34
    line.renderOrder = 3 -- 35
    line.angle = 45 -- 36
    node:runAction(Angle(5, 0, 360)) -- 38
    node:slot( -- 39
        "ActionEnd", -- 39
        function(action) -- 39
            node:runAction(action) -- 40
        end -- 39
    ) -- 39
    return node -- 42
end -- 5
local currentEntry = Node() -- 45
currentEntry.renderGroup = true -- 46
currentEntry.size = Size(750, 750) -- 47
do -- 47
    local _i = 1 -- 48
    while _i <= 16 do -- 48
        currentEntry:addChild(Item()) -- 49
        _i = _i + 1 -- 48
    end -- 48
end -- 48
currentEntry:alignItems() -- 52
local renderGroup = currentEntry.renderGroup -- 54
local windowFlags = { -- 55
    "NoDecoration", -- 56
    "AlwaysAutoResize", -- 57
    "NoSavedSettings", -- 58
    "NoFocusOnAppearing", -- 59
    "NoNav", -- 60
    "NoMove" -- 61
} -- 61
threadLoop(function() -- 63
    local ____App_visualSize_2 = App.visualSize -- 64
    local width = ____App_visualSize_2.width -- 64
    ImGui.SetNextWindowBgAlpha(0.35) -- 65
    ImGui.SetNextWindowPos( -- 66
        Vec2(width - 10, 10), -- 66
        "Always", -- 66
        Vec2(1, 0) -- 66
    ) -- 66
    ImGui.SetNextWindowSize( -- 67
        Vec2(240, 0), -- 67
        "FirstUseEver" -- 67
    ) -- 67
    ImGui.Begin( -- 68
        "Render Group", -- 68
        windowFlags, -- 68
        function() -- 68
            ImGui.Text("Render Group") -- 69
            ImGui.Separator() -- 70
            ImGui.TextWrapped("When render group is enabled, the nodes in the sub render tree will be grouped by \"renderOrder\" property, and get rendered in ascending order!\nNotice the draw call changes in stats window.") -- 71
            local changed = false -- 72
            changed, renderGroup = ImGui.Checkbox("Grouped", renderGroup) -- 73
            if changed then -- 73
                currentEntry.renderGroup = renderGroup -- 75
            end -- 75
        end -- 68
    ) -- 68
    return false -- 78
end) -- 63
return ____exports -- 63