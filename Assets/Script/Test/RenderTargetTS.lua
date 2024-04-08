-- [ts]: RenderTargetTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____dora = require("dora") -- 4
local App = ____dora.App -- 4
local Color = ____dora.Color -- 4
local Event = ____dora.Event -- 4
local Line = ____dora.Line -- 4
local Node = ____dora.Node -- 4
local RenderTarget = ____dora.RenderTarget -- 4
local Sequence = ____dora.Sequence -- 4
local Spine = ____dora.Spine -- 4
local Sprite = ____dora.Sprite -- 4
local Vec2 = ____dora.Vec2 -- 4
local X = ____dora.X -- 4
local threadLoop = ____dora.threadLoop -- 4
local root = Node() -- 6
local node = Node():addTo(root, 1) -- 8
local ____opt_0 = Spine("Spine/moling") -- 8
local spine = ____opt_0 and ____opt_0:addTo(node) -- 10
if spine then -- 10
    spine.y = -200 -- 12
    spine.scaleX = 1.2 -- 13
    spine.scaleY = 1.2 -- 14
    spine.fliped = false -- 15
    spine:play("fmove", true) -- 16
    spine:runAction(Sequence( -- 17
        X(2, -150, 250), -- 19
        Event("Turn"), -- 20
        X(2, 250, -150), -- 21
        Event("Turn") -- 22
    )) -- 22
    spine:slot( -- 25
        "ActionEnd", -- 25
        function(action) -- 25
            spine:runAction(action) -- 26
        end -- 25
    ) -- 25
    spine:slot( -- 28
        "Turn", -- 28
        function() -- 28
            spine.fliped = not spine.fliped -- 29
        end -- 28
    ) -- 28
end -- 28
local renderTarget = RenderTarget(300, 400) -- 33
renderTarget:renderWithClear(Color(4287269514)) -- 34
local surface = Sprite(renderTarget.texture):addTo(root) -- 36
surface.z = 300 -- 37
surface.angleY = 25 -- 38
surface:addChild(Line( -- 39
    { -- 39
        Vec2.zero, -- 40
        Vec2(300, 0), -- 41
        Vec2(300, 400), -- 42
        Vec2(0, 400), -- 43
        Vec2.zero -- 44
    }, -- 44
    App.themeColor -- 45
)) -- 45
surface:schedule(function() -- 46
    node.y = 200 -- 47
    renderTarget:renderWithClear( -- 48
        node, -- 48
        Color(4287269514) -- 48
    ) -- 48
    node.y = 0 -- 49
    return false -- 50
end) -- 46
local windowFlags = { -- 53
    "NoDecoration", -- 54
    "AlwaysAutoResize", -- 55
    "NoSavedSettings", -- 56
    "NoFocusOnAppearing", -- 57
    "NoNav", -- 58
    "NoMove" -- 59
} -- 59
threadLoop(function() -- 61
    local size = App.visualSize -- 62
    ImGui.SetNextWindowBgAlpha(0.35) -- 63
    ImGui.SetNextWindowPos( -- 64
        Vec2(size.width - 10, 10), -- 64
        "Always", -- 64
        Vec2(1, 0) -- 64
    ) -- 64
    ImGui.SetNextWindowSize( -- 65
        Vec2(240, 0), -- 65
        "FirstUseEver" -- 65
    ) -- 65
    ImGui.Begin( -- 66
        "Render Target", -- 66
        windowFlags, -- 66
        function() -- 66
            ImGui.Text("Render Target (Typescript)") -- 67
            ImGui.Separator() -- 68
            ImGui.TextWrapped("Use render target node as a mirror!") -- 69
        end -- 66
    ) -- 66
    return false -- 71
end) -- 61
return ____exports -- 61