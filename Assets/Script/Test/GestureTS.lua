-- [ts]: GestureTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____dora = require("dora") -- 4
local App = ____dora.App -- 4
local Node = ____dora.Node -- 4
local Sprite = ____dora.Sprite -- 4
local Vec2 = ____dora.Vec2 -- 4
local View = ____dora.View -- 4
local threadLoop = ____dora.threadLoop -- 4
local nvg = require("nvg") -- 5
local texture = nvg.GetDoraSSR() -- 7
local sprite = Sprite(texture) -- 8
local length = Vec2(View.size).length -- 9
local width = sprite.width -- 9
local height = sprite.height -- 9
local size = Vec2(width, height).length -- 11
local scaledSize = size -- 12
local node = Node() -- 14
node:addChild(sprite) -- 15
node.touchEnabled = true -- 16
node:slot( -- 17
    "Gesture", -- 17
    function(center, _numFingers, deltaDist, deltaAngle) -- 17
        sprite.position = center -- 18
        sprite.angle = sprite.angle + deltaAngle -- 19
        scaledSize = scaledSize + deltaDist * length -- 20
        sprite.scaleX = scaledSize / size -- 21
        sprite.scaleY = scaledSize / size -- 22
    end -- 17
) -- 17
local windowFlags = { -- 25
    "NoDecoration", -- 26
    "AlwaysAutoResize", -- 27
    "NoSavedSettings", -- 28
    "NoFocusOnAppearing", -- 29
    "NoMove", -- 30
    "NoMove" -- 31
} -- 31
threadLoop(function() -- 33
    local ____App_visualSize_0 = App.visualSize -- 34
    local width = ____App_visualSize_0.width -- 34
    ImGui.SetNextWindowBgAlpha(0.35) -- 35
    ImGui.SetNextWindowPos( -- 36
        Vec2(width - 10, 10), -- 36
        "Always", -- 36
        Vec2(1, 0) -- 36
    ) -- 36
    ImGui.SetNextWindowSize( -- 37
        Vec2(240, 0), -- 37
        "FirstUseEver" -- 37
    ) -- 37
    ImGui.Begin( -- 38
        "Gesture", -- 38
        windowFlags, -- 38
        function() -- 38
            ImGui.Text("Gesture (Typescript)") -- 39
            ImGui.Separator() -- 40
            ImGui.TextWrapped("Interact with multi-touches!") -- 41
        end -- 38
    ) -- 38
    return false -- 43
end) -- 33
return ____exports -- 33