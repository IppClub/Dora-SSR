-- [ts]: RenderTargetTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 76
local ____dora = require("dora") -- 77
local App = ____dora.App -- 77
local Color = ____dora.Color -- 77
local Event = ____dora.Event -- 77
local Line = ____dora.Line -- 77
local Node = ____dora.Node -- 77
local RenderTarget = ____dora.RenderTarget -- 77
local Sequence = ____dora.Sequence -- 77
local Spine = ____dora.Spine -- 77
local Sprite = ____dora.Sprite -- 77
local Vec2 = ____dora.Vec2 -- 77
local X = ____dora.X -- 77
local threadLoop = ____dora.threadLoop -- 77
local root = Node() -- 79
local node = Node():addTo(root, 1) -- 81
local spine = Spine("Spine/moling"):addTo(node) -- 83
spine.y = -200 -- 84
spine.scaleX = 1.2 -- 85
spine.scaleY = 1.2 -- 86
spine.fliped = false -- 87
spine:play("fmove", true) -- 88
spine:runAction(Sequence( -- 89
    X(2, -150, 250), -- 91
    Event("Turn"), -- 92
    X(2, 250, -150), -- 93
    Event("Turn") -- 94
)) -- 94
spine:slot( -- 97
    "ActionEnd", -- 97
    function(action) -- 97
        spine:runAction(action) -- 98
    end -- 97
) -- 97
spine:slot( -- 100
    "Turn", -- 100
    function() -- 100
        spine.fliped = not spine.fliped -- 101
    end -- 100
) -- 100
local renderTarget = RenderTarget(300, 400) -- 104
renderTarget:renderWithClear(Color(4287269514)) -- 105
local surface = Sprite(renderTarget.texture):addTo(root) -- 107
surface.z = 300 -- 108
surface.angleY = 25 -- 109
surface:addChild(Line( -- 110
    { -- 110
        Vec2.zero, -- 111
        Vec2(300, 0), -- 112
        Vec2(300, 400), -- 113
        Vec2(0, 400), -- 114
        Vec2.zero -- 115
    }, -- 115
    App.themeColor -- 116
)) -- 116
surface:schedule(function() -- 117
    node.y = 200 -- 118
    renderTarget:renderWithClear( -- 119
        node, -- 119
        Color(4287269514) -- 119
    ) -- 119
    node.y = 0 -- 120
    return false -- 121
end) -- 117
local windowFlags = { -- 125
    "NoDecoration", -- 126
    "AlwaysAutoResize", -- 127
    "NoSavedSettings", -- 128
    "NoFocusOnAppearing", -- 129
    "NoNav", -- 130
    "NoMove" -- 131
} -- 131
threadLoop(function() -- 133
    local size = App.visualSize -- 134
    ImGui.SetNextWindowBgAlpha(0.35) -- 135
    ImGui.SetNextWindowPos( -- 136
        Vec2(size.width - 10, 10), -- 136
        "Always", -- 136
        Vec2(1, 0) -- 136
    ) -- 136
    ImGui.SetNextWindowSize( -- 137
        Vec2(240, 0), -- 137
        "FirstUseEver" -- 137
    ) -- 137
    ImGui.Begin( -- 138
        "Render Target", -- 138
        windowFlags, -- 138
        function() -- 138
            ImGui.Text("Render Target") -- 139
            ImGui.Separator() -- 140
            ImGui.TextWrapped("Use render target node as a mirror!") -- 141
        end -- 138
    ) -- 138
    return false -- 143
end) -- 133
return ____exports -- 133