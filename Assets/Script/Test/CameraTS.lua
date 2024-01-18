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
if model ~= nil then -- 7
    model.look = "happy" -- 9
    model:play("idle", true) -- 10
    node:addChild(model) -- 11
end -- 11
local sprite = Sprite("Image/logo.png") -- 14
if sprite ~= nil then -- 14
    sprite.scaleX = 0.4 -- 16
    sprite.scaleY = 0.4 -- 17
    sprite.position = Vec2(200, -100) -- 18
    sprite.angleY = 45 -- 19
    sprite.z = -300 -- 20
    node:addChild(sprite) -- 21
end -- 21
node:schedule(once(function() -- 24
    local camera = tolua.cast(Director.currentCamera, "Camera2D") -- 25
    if camera == nil then -- 25
        return -- 26
    end -- 26
    cycle( -- 27
        1.5, -- 27
        function(dt) -- 27
            camera.position = Vec2( -- 28
                200 * Ease:func(Ease.InOutQuad, dt), -- 28
                0 -- 28
            ) -- 28
        end -- 27
    ) -- 27
    cycle( -- 30
        0.1, -- 30
        function(dt) -- 30
            camera.rotation = 25 * Ease:func(Ease.OutSine, dt) -- 31
        end -- 30
    ) -- 30
    cycle( -- 33
        0.2, -- 33
        function(dt) -- 33
            camera.rotation = 25 - 50 * Ease:func(Ease.InOutQuad, dt) -- 34
        end -- 33
    ) -- 33
    cycle( -- 36
        0.1, -- 36
        function(dt) -- 36
            camera.rotation = -25 + 25 * Ease:func(Ease.OutSine, dt) -- 37
        end -- 36
    ) -- 36
    cycle( -- 39
        1.5, -- 39
        function(dt) -- 39
            camera.position = Vec2( -- 40
                200 * Ease:func(Ease.InOutQuad, 1 - dt), -- 40
                0 -- 40
            ) -- 40
        end -- 39
    ) -- 39
    local zoom = camera.zoom -- 39
    cycle( -- 43
        2.5, -- 43
        function(dt) -- 43
            camera.zoom = zoom + Ease:func(Ease.InOutQuad, dt) -- 44
        end -- 43
    ) -- 43
end)) -- 24
local windowFlags = { -- 48
    "NoDecoration", -- 49
    "AlwaysAutoResize", -- 50
    "NoSavedSettings", -- 51
    "NoFocusOnAppearing", -- 52
    "NoNav", -- 53
    "NoMove" -- 54
} -- 54
threadLoop(function() -- 56
    local ____App_visualSize_0 = App.visualSize -- 57
    local width = ____App_visualSize_0.width -- 57
    ImGui.SetNextWindowPos( -- 58
        Vec2(width - 10, 10), -- 58
        "Always", -- 58
        Vec2(1, 0) -- 58
    ) -- 58
    ImGui.SetNextWindowSize( -- 59
        Vec2(240, 0), -- 59
        "FirstUseEver" -- 59
    ) -- 59
    ImGui.Begin( -- 60
        "Camera", -- 60
        windowFlags, -- 60
        function() -- 60
            ImGui.Text("Camera") -- 61
            ImGui.Separator() -- 62
            ImGui.TextWrapped("View camera motions, use 3D camera as default!") -- 63
        end -- 60
    ) -- 60
    return false -- 65
end) -- 56
return ____exports -- 56