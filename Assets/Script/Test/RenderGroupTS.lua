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
    node:runAction(Angle(5, 0, 360)) -- 39
    node:slot( -- 40
        "ActionEnd", -- 40
        function(action) -- 40
            node:runAction(action) -- 41
        end -- 40
    ) -- 40
    return node -- 43
end -- 6
local currentEntry = Node() -- 46
currentEntry.renderGroup = true -- 47
currentEntry.size = Size(750, 750) -- 48
do -- 48
    local _i = 1 -- 49
    while _i <= 16 do -- 49
        currentEntry:addChild(Item()) -- 50
        _i = _i + 1 -- 49
    end -- 49
end -- 49
currentEntry:alignItems() -- 53
local renderGroup = currentEntry.renderGroup -- 55
local windowFlags = { -- 56
    "NoDecoration", -- 57
    "AlwaysAutoResize", -- 58
    "NoSavedSettings", -- 59
    "NoFocusOnAppearing", -- 60
    "NoNav", -- 61
    "NoMove" -- 62
} -- 62
threadLoop(function() -- 64
    local ____App_visualSize_2 = App.visualSize -- 65
    local width = ____App_visualSize_2.width -- 65
    ImGui.SetNextWindowBgAlpha(0.35) -- 66
    ImGui.SetNextWindowPos( -- 67
        Vec2(width - 10, 10), -- 67
        "Always", -- 67
        Vec2(1, 0) -- 67
    ) -- 67
    ImGui.SetNextWindowSize( -- 68
        Vec2(240, 0), -- 68
        "FirstUseEver" -- 68
    ) -- 68
    ImGui.Begin( -- 69
        "Render Group", -- 69
        windowFlags, -- 69
        function() -- 69
            ImGui.Text("Render Group (Typescript)") -- 70
            ImGui.Separator() -- 71
            ImGui.TextWrapped("When render group is enabled, the nodes in the sub render tree will be grouped by \"renderOrder\" property, and get rendered in ascending order!\nNotice the draw call changes in stats window.") -- 72
            local changed = false -- 73
            changed, renderGroup = ImGui.Checkbox("Grouped", renderGroup) -- 74
            if changed then -- 74
                currentEntry.renderGroup = renderGroup -- 76
            end -- 76
        end -- 69
    ) -- 69
    return false -- 79
end) -- 64
return ____exports -- 64