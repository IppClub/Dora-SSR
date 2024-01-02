-- [ts]: CameraTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Director = ____dora.Director -- 3
local Ease = ____dora.Ease -- 3
local Model = ____dora.Model -- 3
local Node = ____dora.Node -- 3
local Sprite = ____dora.Sprite -- 3
local Vec2 = ____dora.Vec2 -- 3
local cycle = ____dora.cycle -- 3
local once = ____dora.once -- 3
local threadLoop = ____dora.threadLoop -- 3
local node = Node() -- 5
local model = Model("Model/xiaoli.model") -- 7
model.look = "happy" -- 8
model:play("idle", true) -- 9
node:addChild(model) -- 10
local sprite = Sprite("Image/logo.png") -- 12
sprite.scaleX = 0.4 -- 13
sprite.scaleY = 0.4 -- 14
sprite.position = Vec2(200, -100) -- 15
sprite.angleY = 45 -- 16
sprite.z = -300 -- 17
node:addChild(sprite) -- 18
node:schedule(once(function() -- 20
    local camera = Director.currentCamera -- 21
    cycle( -- 22
        1.5, -- 22
        function(dt) -- 22
            camera.position = Vec2( -- 23
                200 * Ease:func(Ease.InOutQuad, dt), -- 23
                0 -- 23
            ) -- 23
        end -- 22
    ) -- 22
    cycle( -- 25
        0.1, -- 25
        function(dt) -- 25
            camera.rotation = 25 * Ease:func(Ease.OutSine, dt) -- 26
        end -- 25
    ) -- 25
    cycle( -- 28
        0.2, -- 28
        function(dt) -- 28
            camera.rotation = 25 - 50 * Ease:func(Ease.InOutQuad, dt) -- 29
        end -- 28
    ) -- 28
    cycle( -- 31
        0.1, -- 31
        function(dt) -- 31
            camera.rotation = -25 + 25 * Ease:func(Ease.OutSine, dt) -- 32
        end -- 31
    ) -- 31
    cycle( -- 34
        1.5, -- 34
        function(dt) -- 34
            camera.position = Vec2( -- 35
                200 * Ease:func(Ease.InOutQuad, 1 - dt), -- 35
                0 -- 35
            ) -- 35
        end -- 34
    ) -- 34
    local zoom = camera.zoom -- 34
    cycle( -- 38
        2.5, -- 38
        function(dt) -- 38
            camera.zoom = zoom + Ease:func(Ease.InOutQuad, dt) -- 39
        end -- 38
    ) -- 38
end)) -- 20
local windowFlags = { -- 43
    "NoDecoration", -- 44
    "AlwaysAutoResize", -- 45
    "NoSavedSettings", -- 46
    "NoFocusOnAppearing", -- 47
    "NoNav", -- 48
    "NoMove" -- 49
} -- 49
threadLoop(function() -- 51
    local ____App_visualSize_0 = App.visualSize -- 52
    local width = ____App_visualSize_0.width -- 52
    ImGui.SetNextWindowPos( -- 53
        Vec2(width - 10, 10), -- 53
        "Always", -- 53
        Vec2(1, 0) -- 53
    ) -- 53
    ImGui.SetNextWindowSize( -- 54
        Vec2(240, 0), -- 54
        "FirstUseEver" -- 54
    ) -- 54
    ImGui.Begin( -- 55
        "Camera", -- 55
        windowFlags, -- 55
        function() -- 55
            ImGui.Text("Camera") -- 56
            ImGui.Separator() -- 57
            ImGui.TextWrapped("View camera motions, use 3D camera as default!") -- 58
        end -- 55
    ) -- 55
    return false -- 60
end) -- 51
return ____exports -- 51