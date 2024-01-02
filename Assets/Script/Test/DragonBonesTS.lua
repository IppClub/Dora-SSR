-- [ts]: DragonBonesTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Delay = ____dora.Delay -- 3
local DragonBone = ____dora.DragonBone -- 3
local Ease = ____dora.Ease -- 3
local Event = ____dora.Event -- 3
local Label = ____dora.Label -- 3
local Opacity = ____dora.Opacity -- 3
local Scale = ____dora.Scale -- 3
local Sequence = ____dora.Sequence -- 3
local Spawn = ____dora.Spawn -- 3
local Vec2 = ____dora.Vec2 -- 3
local threadLoop = ____dora.threadLoop -- 3
local boneStr = "DragonBones/NewDragon" -- 5
local animations = DragonBone:getAnimations(boneStr) -- 6
local looks = DragonBone:getLooks(boneStr) -- 7
p(animations, looks) -- 9
local bone = DragonBone(boneStr) -- 11
bone.look = looks[1] -- 12
bone:play(animations[1], true) -- 13
bone:slot( -- 14
    "AnimationEnd", -- 14
    function(name) -- 14
        print(name .. " end!") -- 15
    end -- 14
) -- 14
bone.y = -200 -- 18
bone.touchEnabled = true -- 19
bone:slot( -- 20
    "TapBegan", -- 20
    function(touch) -- 20
        local ____touch_location_0 = touch.location -- 21
        local x = ____touch_location_0.x -- 21
        local y = ____touch_location_0.y -- 21
        local name = bone:containsPoint(x, y) -- 22
        if name ~= nil then -- 22
            local label = Label("sarasa-mono-sc-regular", 30) -- 24
            label.text = name -- 25
            label.color = App.themeColor -- 26
            label.position = Vec2(x, y) -- 27
            label.order = 100 -- 28
            label:perform(Sequence( -- 29
                Spawn( -- 31
                    Scale(1, 0, 2, Ease.OutQuad), -- 32
                    Sequence( -- 33
                        Delay(0.5), -- 34
                        Opacity(0.5, 1, 0) -- 35
                    ) -- 35
                ), -- 35
                Event("Stop") -- 38
            )) -- 38
            label:slot( -- 41
                "Stop", -- 41
                function() -- 41
                    label:removeFromParent() -- 42
                end -- 41
            ) -- 41
            bone:addChild(label) -- 44
        end -- 44
    end -- 20
) -- 20
local windowFlags = { -- 48
    "NoDecoration", -- 49
    "AlwaysAutoResize", -- 50
    "NoSavedSettings", -- 51
    "NoFocusOnAppearing", -- 52
    "NoNav", -- 53
    "NoMove" -- 54
} -- 54
local showDebug = bone.showDebug -- 56
threadLoop(function() -- 57
    local ____App_visualSize_1 = App.visualSize -- 58
    local width = ____App_visualSize_1.width -- 58
    ImGui.SetNextWindowBgAlpha(0.35) -- 59
    ImGui.SetNextWindowPos( -- 60
        Vec2(width - 10, 10), -- 60
        "Always", -- 60
        Vec2(1, 0) -- 60
    ) -- 60
    ImGui.SetNextWindowSize( -- 61
        Vec2(240, 0), -- 61
        "FirstUseEver" -- 61
    ) -- 61
    ImGui.Begin( -- 62
        "DragonBones", -- 62
        windowFlags, -- 62
        function() -- 62
            ImGui.Text("DragonBones") -- 63
            ImGui.Separator() -- 64
            ImGui.TextWrapped("Basic usage to create dragonBones! Tap it for a hit test.") -- 65
            local changed = false -- 66
            changed, showDebug = ImGui.Checkbox("BoundingBox", showDebug) -- 67
            if changed then -- 67
                bone.showDebug = showDebug -- 69
            end -- 69
        end -- 62
    ) -- 62
    return false -- 72
end) -- 57
return ____exports -- 57