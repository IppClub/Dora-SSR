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
local spine = Spine("Spine/moling"):addTo(node) -- 9
spine.y = -200 -- 10
spine.scaleX = 1.2 -- 11
spine.scaleY = 1.2 -- 12
spine.fliped = false -- 13
spine:play("fmove", true) -- 14
spine:runAction(Sequence( -- 15
    X(2, -150, 250), -- 17
    Event("Turn"), -- 18
    X(2, 250, -150), -- 19
    Event("Turn") -- 20
)) -- 20
spine:slot( -- 23
    "ActionEnd", -- 23
    function(action) -- 23
        spine:runAction(action) -- 24
    end -- 23
) -- 23
spine:slot( -- 26
    "Turn", -- 26
    function() -- 26
        spine.fliped = not spine.fliped -- 27
    end -- 26
) -- 26
local renderTarget = RenderTarget(300, 400) -- 30
renderTarget:renderWithClear(Color(4287269514)) -- 31
local surface = Sprite(renderTarget.texture):addTo(root) -- 33
surface.z = 300 -- 34
surface.angleY = 25 -- 35
surface:addChild(Line( -- 36
    { -- 36
        Vec2.zero, -- 37
        Vec2(300, 0), -- 38
        Vec2(300, 400), -- 39
        Vec2(0, 400), -- 40
        Vec2.zero -- 41
    }, -- 41
    App.themeColor -- 42
)) -- 42
surface:schedule(function() -- 43
    node.y = 200 -- 44
    renderTarget:renderWithClear( -- 45
        node, -- 45
        Color(4287269514) -- 45
    ) -- 45
    node.y = 0 -- 46
    return false -- 47
end) -- 43
local windowFlags = { -- 51
    "NoDecoration", -- 52
    "AlwaysAutoResize", -- 53
    "NoSavedSettings", -- 54
    "NoFocusOnAppearing", -- 55
    "NoNav", -- 56
    "NoMove" -- 57
} -- 57
threadLoop(function() -- 59
    local size = App.visualSize -- 60
    ImGui.SetNextWindowBgAlpha(0.35) -- 61
    ImGui.SetNextWindowPos( -- 62
        Vec2(size.width - 10, 10), -- 62
        "Always", -- 62
        Vec2(1, 0) -- 62
    ) -- 62
    ImGui.SetNextWindowSize( -- 63
        Vec2(240, 0), -- 63
        "FirstUseEver" -- 63
    ) -- 63
    ImGui.Begin( -- 64
        "Render Target", -- 64
        windowFlags, -- 64
        function() -- 64
            ImGui.Text("Render Target") -- 65
            ImGui.Separator() -- 66
            ImGui.TextWrapped("Use render target node as a mirror!") -- 67
        end -- 64
    ) -- 64
    return false -- 69
end) -- 59
return ____exports -- 59