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
if bone ~= nil then -- 11
    bone.look = looks[1] -- 13
    bone:play(animations[1], true) -- 14
    bone:slot( -- 15
        "AnimationEnd", -- 15
        function(name) -- 15
            print(name .. " end!") -- 16
        end -- 15
    ) -- 15
    bone.y = -200 -- 19
    bone.touchEnabled = true -- 20
    bone:slot( -- 21
        "TapBegan", -- 21
        function(touch) -- 21
            local ____touch_location_0 = touch.location -- 22
            local x = ____touch_location_0.x -- 22
            local y = ____touch_location_0.y -- 22
            local name = bone:containsPoint(x, y) -- 23
            if name ~= nil then -- 23
                local label = Label("sarasa-mono-sc-regular", 30) -- 25
                if label ~= nil then -- 25
                    label.text = name -- 27
                    label.color = App.themeColor -- 28
                    label.position = Vec2(x, y) -- 29
                    label.order = 100 -- 30
                    label:perform(Sequence( -- 31
                        Spawn( -- 33
                            Scale(1, 0, 2, Ease.OutQuad), -- 34
                            Sequence( -- 35
                                Delay(0.5), -- 36
                                Opacity(0.5, 1, 0) -- 37
                            ) -- 37
                        ), -- 37
                        Event("Stop") -- 40
                    )) -- 40
                    label:slot( -- 43
                        "Stop", -- 43
                        function() -- 43
                            label:removeFromParent() -- 44
                        end -- 43
                    ) -- 43
                    bone:addChild(label) -- 46
                end -- 46
            end -- 46
        end -- 21
    ) -- 21
end -- 21
local windowFlags = { -- 52
    "NoDecoration", -- 53
    "AlwaysAutoResize", -- 54
    "NoSavedSettings", -- 55
    "NoFocusOnAppearing", -- 56
    "NoNav", -- 57
    "NoMove" -- 58
} -- 58
local ____temp_3 = bone and bone.showDebug -- 60
if ____temp_3 == nil then -- 60
    ____temp_3 = false -- 60
end -- 60
local showDebug = ____temp_3 -- 60
threadLoop(function() -- 61
    local ____App_visualSize_4 = App.visualSize -- 62
    local width = ____App_visualSize_4.width -- 62
    ImGui.SetNextWindowBgAlpha(0.35) -- 63
    ImGui.SetNextWindowPos( -- 64
        Vec2(width - 10, 10), -- 64
        "Always", -- 64
        Vec2(1, 0) -- 64
    ) -- 64
    ImGui.SetNextWindowSize( -- 65
        Vec2(240, 0), -- 65
        "FirstUseEver" -- 65
    ) -- 65
    ImGui.Begin( -- 66
        "DragonBones", -- 66
        windowFlags, -- 66
        function() -- 66
            ImGui.Text("DragonBones") -- 67
            ImGui.Separator() -- 68
            ImGui.TextWrapped("Basic usage to create dragonBones! Tap it for a hit test.") -- 69
            local changed = false -- 70
            changed, showDebug = ImGui.Checkbox("BoundingBox", showDebug) -- 71
            if changed and bone then -- 71
                bone.showDebug = showDebug -- 73
            end -- 73
        end -- 66
    ) -- 66
    return false -- 76
end) -- 61
return ____exports -- 61