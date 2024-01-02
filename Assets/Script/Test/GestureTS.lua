-- [ts]: GestureTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Node = ____dora.Node -- 3
local Sprite = ____dora.Sprite -- 3
local Vec2 = ____dora.Vec2 -- 3
local View = ____dora.View -- 3
local threadLoop = ____dora.threadLoop -- 3
local nvg = require("nvg") -- 4
local texture = nvg.GetDoraSSR() -- 6
local sprite = Sprite(texture) -- 7
local length = Vec2(View.size).length -- 8
local width = sprite.width -- 8
local height = sprite.height -- 8
local size = Vec2(width, height).length -- 10
local scaledSize = size -- 11
local node = Node() -- 13
node:addChild(sprite) -- 14
node.touchEnabled = true -- 15
node:slot( -- 16
    "Gesture", -- 16
    function(center, _numFingers, deltaDist, deltaAngle) -- 16
        sprite.position = center -- 17
        sprite.angle = sprite.angle + deltaAngle -- 18
        scaledSize = scaledSize + deltaDist * length -- 19
        sprite.scaleX = scaledSize / size -- 20
        sprite.scaleY = scaledSize / size -- 21
    end -- 16
) -- 16
local windowFlags = { -- 24
    "NoDecoration", -- 25
    "AlwaysAutoResize", -- 26
    "NoSavedSettings", -- 27
    "NoFocusOnAppearing", -- 28
    "NoMove", -- 29
    "NoMove" -- 30
} -- 30
threadLoop(function() -- 32
    local ____App_visualSize_0 = App.visualSize -- 33
    local width = ____App_visualSize_0.width -- 33
    ImGui.SetNextWindowBgAlpha(0.35) -- 34
    ImGui.SetNextWindowPos( -- 35
        Vec2(width - 10, 10), -- 35
        "Always", -- 35
        Vec2(1, 0) -- 35
    ) -- 35
    ImGui.SetNextWindowSize( -- 36
        Vec2(240, 0), -- 36
        "FirstUseEver" -- 36
    ) -- 36
    ImGui.Begin( -- 37
        "Gesture", -- 37
        windowFlags, -- 37
        function() -- 37
            ImGui.Text("Gesture") -- 38
            ImGui.Separator() -- 39
            ImGui.TextWrapped("Interact with multi-touches!") -- 40
        end -- 37
    ) -- 37
    return false -- 42
end) -- 32
return ____exports -- 32