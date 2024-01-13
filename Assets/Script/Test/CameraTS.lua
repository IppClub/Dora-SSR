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
local tolua = ____dora.tolua -- 3
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
    local camera = tolua.cast(Director.currentCamera, "Camera2D") -- 21
    if camera == nil then -- 21
        return -- 22
    end -- 22
    cycle( -- 23
        1.5, -- 23
        function(dt) -- 23
            camera.position = Vec2( -- 24
                200 * Ease:func(Ease.InOutQuad, dt), -- 24
                0 -- 24
            ) -- 24
        end -- 23
    ) -- 23
    cycle( -- 26
        0.1, -- 26
        function(dt) -- 26
            camera.rotation = 25 * Ease:func(Ease.OutSine, dt) -- 27
        end -- 26
    ) -- 26
    cycle( -- 29
        0.2, -- 29
        function(dt) -- 29
            camera.rotation = 25 - 50 * Ease:func(Ease.InOutQuad, dt) -- 30
        end -- 29
    ) -- 29
    cycle( -- 32
        0.1, -- 32
        function(dt) -- 32
            camera.rotation = -25 + 25 * Ease:func(Ease.OutSine, dt) -- 33
        end -- 32
    ) -- 32
    cycle( -- 35
        1.5, -- 35
        function(dt) -- 35
            camera.position = Vec2( -- 36
                200 * Ease:func(Ease.InOutQuad, 1 - dt), -- 36
                0 -- 36
            ) -- 36
        end -- 35
    ) -- 35
    local zoom = camera.zoom -- 35
    cycle( -- 39
        2.5, -- 39
        function(dt) -- 39
            camera.zoom = zoom + Ease:func(Ease.InOutQuad, dt) -- 40
        end -- 39
    ) -- 39
end)) -- 20
local windowFlags = { -- 44
    "NoDecoration", -- 45
    "AlwaysAutoResize", -- 46
    "NoSavedSettings", -- 47
    "NoFocusOnAppearing", -- 48
    "NoNav", -- 49
    "NoMove" -- 50
} -- 50
threadLoop(function() -- 52
    local ____App_visualSize_0 = App.visualSize -- 53
    local width = ____App_visualSize_0.width -- 53
    ImGui.SetNextWindowPos( -- 54
        Vec2(width - 10, 10), -- 54
        "Always", -- 54
        Vec2(1, 0) -- 54
    ) -- 54
    ImGui.SetNextWindowSize( -- 55
        Vec2(240, 0), -- 55
        "FirstUseEver" -- 55
    ) -- 55
    ImGui.Begin( -- 56
        "Camera", -- 56
        windowFlags, -- 56
        function() -- 56
            ImGui.Text("Camera") -- 57
            ImGui.Separator() -- 58
            ImGui.TextWrapped("View camera motions, use 3D camera as default!") -- 59
        end -- 56
    ) -- 56
    return false -- 61
end) -- 52
return ____exports -- 52