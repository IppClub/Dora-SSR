-- [ts]: GestureTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____Dora = require("Dora") -- 4
local App = ____Dora.App -- 4
local Node = ____Dora.Node -- 4
local Sprite = ____Dora.Sprite -- 4
local Vec2 = ____Dora.Vec2 -- 4
local View = ____Dora.View -- 4
local threadLoop = ____Dora.threadLoop -- 4
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
node:onGesture(function(center, _numFingers, deltaDist, deltaAngle) -- 16
    sprite.position = center -- 17
    sprite.angle = sprite.angle + deltaAngle -- 18
    scaledSize = scaledSize + deltaDist * length -- 19
    sprite.scaleX = scaledSize / size -- 20
    sprite.scaleY = scaledSize / size -- 21
end) -- 16
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
            ImGui.Text("Gesture (Typescript)") -- 38
            ImGui.Separator() -- 39
            ImGui.TextWrapped("Interact with multi-touches!") -- 40
        end -- 37
    ) -- 37
    return false -- 42
end) -- 32
return ____exports -- 32