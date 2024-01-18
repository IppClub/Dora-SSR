-- [ts]: RenderTargetTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Color = ____dora.Color -- 3
local Event = ____dora.Event -- 3
local Line = ____dora.Line -- 3
local Node = ____dora.Node -- 3
local RenderTarget = ____dora.RenderTarget -- 3
local Sequence = ____dora.Sequence -- 3
local Spine = ____dora.Spine -- 3
local Sprite = ____dora.Sprite -- 3
local Vec2 = ____dora.Vec2 -- 3
local X = ____dora.X -- 3
local threadLoop = ____dora.threadLoop -- 3
local root = Node() -- 5
local node = Node():addTo(root, 1) -- 7
local ____opt_0 = Spine("Spine/moling") -- 7
local spine = ____opt_0 and ____opt_0:addTo(node) -- 9
if spine then -- 9
    spine.y = -200 -- 11
    spine.scaleX = 1.2 -- 12
    spine.scaleY = 1.2 -- 13
    spine.fliped = false -- 14
    spine:play("fmove", true) -- 15
    spine:runAction(Sequence( -- 16
        X(2, -150, 250), -- 18
        Event("Turn"), -- 19
        X(2, 250, -150), -- 20
        Event("Turn") -- 21
    )) -- 21
    spine:slot( -- 24
        "ActionEnd", -- 24
        function(action) -- 24
            spine:runAction(action) -- 25
        end -- 24
    ) -- 24
    spine:slot( -- 27
        "Turn", -- 27
        function() -- 27
            spine.fliped = not spine.fliped -- 28
        end -- 27
    ) -- 27
end -- 27
local renderTarget = RenderTarget(300, 400) -- 32
renderTarget:renderWithClear(Color(4287269514)) -- 33
local surface = Sprite(renderTarget.texture):addTo(root) -- 35
surface.z = 300 -- 36
surface.angleY = 25 -- 37
surface:addChild(Line( -- 38
    { -- 38
        Vec2.zero, -- 39
        Vec2(300, 0), -- 40
        Vec2(300, 400), -- 41
        Vec2(0, 400), -- 42
        Vec2.zero -- 43
    }, -- 43
    App.themeColor -- 44
)) -- 44
surface:schedule(function() -- 45
    node.y = 200 -- 46
    renderTarget:renderWithClear( -- 47
        node, -- 47
        Color(4287269514) -- 47
    ) -- 47
    node.y = 0 -- 48
    return false -- 49
end) -- 45
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
            ImGui.Text("Render Target") -- 67
            ImGui.Separator() -- 68
            ImGui.TextWrapped("Use render target node as a mirror!") -- 69
        end -- 66
    ) -- 66
    return false -- 71
end) -- 61
return ____exports -- 61