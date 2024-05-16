-- [ts]: DragonBonesTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____Dora = require("Dora") -- 4
local App = ____Dora.App -- 4
local Delay = ____Dora.Delay -- 4
local DragonBone = ____Dora.DragonBone -- 4
local Ease = ____Dora.Ease -- 4
local Event = ____Dora.Event -- 4
local Label = ____Dora.Label -- 4
local Opacity = ____Dora.Opacity -- 4
local Scale = ____Dora.Scale -- 4
local Sequence = ____Dora.Sequence -- 4
local Spawn = ____Dora.Spawn -- 4
local Vec2 = ____Dora.Vec2 -- 4
local threadLoop = ____Dora.threadLoop -- 4
local boneStr = "DragonBones/NewDragon" -- 6
local animations = DragonBone:getAnimations(boneStr) -- 7
local looks = DragonBone:getLooks(boneStr) -- 8
p(animations, looks) -- 10
local bone = DragonBone(boneStr) -- 12
if bone ~= nil then -- 12
    bone.look = looks[1] -- 14
    bone:play(animations[1], true) -- 15
    bone:slot( -- 16
        "AnimationEnd", -- 16
        function(name) -- 16
            print(name .. " end!") -- 17
        end -- 16
    ) -- 16
    bone.y = -200 -- 20
    bone.touchEnabled = true -- 21
    bone:slot( -- 22
        "TapBegan", -- 22
        function(touch) -- 22
            local ____touch_location_0 = touch.location -- 23
            local x = ____touch_location_0.x -- 23
            local y = ____touch_location_0.y -- 23
            local name = bone:containsPoint(x, y) -- 24
            if name ~= nil then -- 24
                local label = Label("sarasa-mono-sc-regular", 30) -- 26
                if label ~= nil then -- 26
                    label.text = name -- 28
                    label.color = App.themeColor -- 29
                    label.position = Vec2(x, y) -- 30
                    label.order = 100 -- 31
                    label:perform(Sequence( -- 32
                        Spawn( -- 34
                            Scale(1, 0, 2, Ease.OutQuad), -- 35
                            Sequence( -- 36
                                Delay(0.5), -- 37
                                Opacity(0.5, 1, 0) -- 38
                            ) -- 38
                        ), -- 38
                        Event("Stop") -- 41
                    )) -- 41
                    label:slot( -- 44
                        "Stop", -- 44
                        function() -- 44
                            label:removeFromParent() -- 45
                        end -- 44
                    ) -- 44
                    bone:addChild(label) -- 47
                end -- 47
            end -- 47
        end -- 22
    ) -- 22
end -- 22
local windowFlags = { -- 53
    "NoDecoration", -- 54
    "AlwaysAutoResize", -- 55
    "NoSavedSettings", -- 56
    "NoFocusOnAppearing", -- 57
    "NoNav", -- 58
    "NoMove" -- 59
} -- 59
local ____temp_3 = bone and bone.showDebug -- 61
if ____temp_3 == nil then -- 61
    ____temp_3 = false -- 61
end -- 61
local showDebug = ____temp_3 -- 61
threadLoop(function() -- 62
    local ____App_visualSize_4 = App.visualSize -- 63
    local width = ____App_visualSize_4.width -- 63
    ImGui.SetNextWindowBgAlpha(0.35) -- 64
    ImGui.SetNextWindowPos( -- 65
        Vec2(width - 10, 10), -- 65
        "Always", -- 65
        Vec2(1, 0) -- 65
    ) -- 65
    ImGui.SetNextWindowSize( -- 66
        Vec2(240, 0), -- 66
        "FirstUseEver" -- 66
    ) -- 66
    ImGui.Begin( -- 67
        "DragonBones", -- 67
        windowFlags, -- 67
        function() -- 67
            ImGui.Text("DragonBones (Typescript)") -- 68
            ImGui.Separator() -- 69
            ImGui.TextWrapped("Basic usage to create dragonBones! Tap it for a hit test.") -- 70
            local changed = false -- 71
            changed, showDebug = ImGui.Checkbox("BoundingBox", showDebug) -- 72
            if changed and bone then -- 72
                bone.showDebug = showDebug -- 74
            end -- 74
        end -- 67
    ) -- 67
    return false -- 77
end) -- 62
return ____exports -- 62