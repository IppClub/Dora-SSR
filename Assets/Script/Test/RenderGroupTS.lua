-- [ts]: RenderGroupTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____dora = require("dora") -- 4
local Angle = ____dora.Angle -- 4
local App = ____dora.App -- 4
local Color = ____dora.Color -- 4
local DrawNode = ____dora.DrawNode -- 4
local Line = ____dora.Line -- 4
local Node = ____dora.Node -- 4
local Size = ____dora.Size -- 4
local Sprite = ____dora.Sprite -- 4
local Vec2 = ____dora.Vec2 -- 4
local threadLoop = ____dora.threadLoop -- 4
local function Item() -- 6
    local node = Node() -- 7
    node.width = 144 -- 8
    node.height = 144 -- 9
    node.anchor = Vec2.zero -- 10
    local ____opt_0 = Sprite("Image/logo.png") -- 10
    local sprite = ____opt_0 and ____opt_0:addTo(node) -- 12
    if sprite then -- 12
        sprite.scaleX = 0.1 -- 14
        sprite.scaleY = 0.1 -- 15
        sprite.renderOrder = 1 -- 16
    end -- 16
    local drawNode = DrawNode():addTo(node) -- 19
    drawNode:drawPolygon( -- 20
        { -- 20
            Vec2(-60, -60), -- 21
            Vec2(60, -60), -- 22
            Vec2(60, 60), -- 23
            Vec2(-60, 60) -- 24
        }, -- 24
        Color(822018176) -- 25
    ) -- 25
    drawNode.renderOrder = 2 -- 26
    drawNode.angle = 45 -- 27
    local line = Line( -- 29
        { -- 29
            Vec2(-60, -60), -- 30
            Vec2(60, -60), -- 31
            Vec2(60, 60), -- 32
            Vec2(-60, 60), -- 33
            Vec2(-60, -60) -- 34
        }, -- 34
        Color(4294901888) -- 35
    ):addTo(node) -- 35
    line.renderOrder = 3 -- 36
    line.angle = 45 -- 37
    node:runAction( -- 39
        Angle(5, 0, 360), -- 39
        true -- 39
    ) -- 39
    return node -- 40
end -- 6
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
    local ____App_visualSize_2 = App.visualSize -- 62
    local width = ____App_visualSize_2.width -- 62
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
            ImGui.Text("Render Group (Typescript)") -- 67
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