-- [ts]: SpriteTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____Dora = require("Dora") -- 4
local App = ____Dora.App -- 4
local Size = ____Dora.Size -- 4
local Sprite = ____Dora.Sprite -- 4
local Vec2 = ____Dora.Vec2 -- 4
local threadLoop = ____Dora.threadLoop -- 4
local sprite = Sprite("Image/logo.png") -- 6
if sprite then -- 6
    sprite.scaleX = 0.5 -- 8
    sprite.scaleY = 0.5 -- 9
    sprite.touchEnabled = true -- 10
    sprite.showDebug = true -- 11
    sprite:slot( -- 12
        "TapMoved", -- 12
        function(touch) -- 12
            if not touch.first then -- 12
                return -- 14
            end -- 14
            if not sprite then -- 14
                return -- 16
            end -- 16
            sprite.position = sprite.position:add(touch.delta) -- 17
        end -- 12
    ) -- 12
end -- 12
local windowFlags = {"NoResize", "NoSavedSettings"} -- 21
threadLoop(function() -- 25
    local ____App_visualSize_0 = App.visualSize -- 26
    local width = ____App_visualSize_0.width -- 26
    ImGui.SetNextWindowPos( -- 27
        Vec2(width - 10, 10), -- 27
        "FirstUseEver", -- 27
        Vec2(1, 0) -- 27
    ) -- 27
    ImGui.SetNextWindowSize( -- 28
        Vec2(240, 520), -- 28
        "FirstUseEver" -- 28
    ) -- 28
    ImGui.Begin( -- 29
        "Sprite", -- 29
        windowFlags, -- 29
        function() -- 29
            ImGui.Text("Sprite (Typescript)") -- 30
            ImGui.BeginChild( -- 31
                "SpriteSetting", -- 31
                Vec2(-1, -40), -- 31
                function() -- 31
                    if not sprite then -- 31
                        return -- 32
                    end -- 32
                    local changed = false -- 33
                    local z = sprite.z -- 34
                    changed, z = ImGui.DragFloat( -- 35
                        "Z", -- 35
                        z, -- 35
                        1, -- 35
                        -1000, -- 35
                        1000, -- 35
                        "%.2f" -- 35
                    ) -- 35
                    if changed then -- 35
                        sprite.z = z -- 37
                    end -- 37
                    local anchor = sprite.anchor -- 39
                    local x, y = anchor.x, anchor.y -- 40
                    changed, x, y = ImGui.DragFloat2( -- 41
                        "Anchor", -- 41
                        x, -- 41
                        y, -- 41
                        0.01, -- 41
                        0, -- 41
                        1, -- 41
                        "%.2f" -- 41
                    ) -- 41
                    if changed then -- 41
                        sprite.anchor = Vec2(x, y) -- 43
                    end -- 43
                    local size = sprite.size -- 45
                    local spriteW, height = size.width, size.height -- 46
                    changed, spriteW, height = ImGui.DragFloat2( -- 47
                        "Size", -- 47
                        spriteW, -- 47
                        height, -- 47
                        1, -- 47
                        0, -- 47
                        1500, -- 47
                        "%.f" -- 47
                    ) -- 47
                    if changed then -- 47
                        sprite.size = Size(spriteW, height) -- 49
                    end -- 49
                    local scaleX, scaleY = sprite.scaleX, sprite.scaleY -- 51
                    changed, scaleX, scaleY = ImGui.DragFloat2( -- 52
                        "Scale", -- 52
                        scaleX, -- 52
                        scaleY, -- 52
                        0.01, -- 52
                        -2, -- 52
                        2, -- 52
                        "%.2f" -- 52
                    ) -- 52
                    if changed then -- 52
                        local ____temp_1 = {scaleX, scaleY} -- 54
                        sprite.scaleX = ____temp_1[1] -- 54
                        sprite.scaleY = ____temp_1[2] -- 54
                    end -- 54
                    ImGui.PushItemWidth( -- 56
                        -60, -- 56
                        function() -- 56
                            if not sprite then -- 56
                                return -- 57
                            end -- 57
                            local angle = sprite.angle -- 58
                            changed, angle = ImGui.DragInt( -- 59
                                "Angle", -- 59
                                math.floor(angle), -- 59
                                1, -- 59
                                -360, -- 59
                                360 -- 59
                            ) -- 59
                            if changed then -- 59
                                sprite.angle = angle -- 61
                            end -- 61
                        end -- 56
                    ) -- 56
                    ImGui.PushItemWidth( -- 64
                        -60, -- 64
                        function() -- 64
                            if not sprite then -- 64
                                return -- 65
                            end -- 65
                            local angleX = sprite.angleX -- 66
                            changed, angleX = ImGui.DragInt( -- 67
                                "AngleX", -- 67
                                math.floor(angleX), -- 67
                                1, -- 67
                                -360, -- 67
                                360 -- 67
                            ) -- 67
                            if changed then -- 67
                                sprite.angleX = angleX -- 69
                            end -- 69
                        end -- 64
                    ) -- 64
                    ImGui.PushItemWidth( -- 72
                        -60, -- 72
                        function() -- 72
                            if not sprite then -- 72
                                return -- 73
                            end -- 73
                            local angleY = sprite.angleY -- 74
                            changed, angleY = ImGui.DragInt( -- 75
                                "AngleY", -- 75
                                math.floor(angleY), -- 75
                                1, -- 75
                                -360, -- 75
                                360 -- 75
                            ) -- 75
                            if changed then -- 75
                                sprite.angleY = angleY -- 77
                            end -- 77
                        end -- 72
                    ) -- 72
                    local skewX, skewY = sprite.skewX, sprite.skewY -- 80
                    changed, skewX, skewY = ImGui.DragInt2( -- 81
                        "Skew", -- 81
                        math.floor(skewX), -- 81
                        math.floor(skewY), -- 81
                        1, -- 81
                        -360, -- 81
                        360 -- 81
                    ) -- 81
                    if changed then -- 81
                        local ____temp_2 = {skewX, skewY} -- 83
                        sprite.skewX = ____temp_2[1] -- 83
                        sprite.skewY = ____temp_2[2] -- 83
                    end -- 83
                    ImGui.PushItemWidth( -- 85
                        -70, -- 85
                        function() -- 85
                            if not sprite then -- 85
                                return -- 86
                            end -- 86
                            local opacity = sprite.opacity -- 87
                            changed, opacity = ImGui.DragFloat( -- 88
                                "Opacity", -- 88
                                opacity, -- 88
                                0.01, -- 88
                                0, -- 88
                                1, -- 88
                                "%.2f" -- 88
                            ) -- 88
                            if changed then -- 88
                                sprite.opacity = opacity -- 90
                            end -- 90
                        end -- 85
                    ) -- 85
                    ImGui.PushItemWidth( -- 93
                        -1, -- 93
                        function() -- 93
                            if not sprite then -- 93
                                return -- 94
                            end -- 94
                            local color3 = sprite.color3 -- 95
                            ImGui.SetColorEditOptions({"DisplayRGB"}) -- 96
                            if ImGui.ColorEdit3("", color3) then -- 96
                                sprite.color3 = color3 -- 98
                            end -- 98
                        end -- 93
                    ) -- 93
                end -- 31
            ) -- 31
            if ImGui.Button( -- 31
                "Reset", -- 102
                Vec2(140, 30) -- 102
            ) then -- 102
                if not sprite then -- 102
                    return -- 103
                end -- 103
                local parent = sprite.parent -- 104
                sprite:removeFromParent() -- 105
                sprite = Sprite("Image/logo.png") -- 106
                if sprite and parent then -- 106
                    sprite.scaleX = 0.5 -- 108
                    sprite.scaleY = 0.5 -- 109
                    sprite.touchEnabled = true -- 110
                    sprite.showDebug = true -- 111
                    sprite:slot( -- 112
                        "TapMoved", -- 112
                        function(touch) -- 112
                            if not touch.first then -- 112
                                return -- 114
                            end -- 114
                            if not sprite then -- 114
                                return -- 116
                            end -- 116
                            sprite.position = sprite.position:add(touch.delta) -- 117
                        end -- 112
                    ) -- 112
                    parent:addChild(sprite) -- 119
                end -- 119
            end -- 119
        end -- 29
    ) -- 29
    return false -- 123
end) -- 25
return ____exports -- 25