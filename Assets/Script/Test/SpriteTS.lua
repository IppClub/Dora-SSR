-- [ts]: SpriteTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____dora = require("dora") -- 4
local App = ____dora.App -- 4
local Size = ____dora.Size -- 4
local Sprite = ____dora.Sprite -- 4
local Vec2 = ____dora.Vec2 -- 4
local threadLoop = ____dora.threadLoop -- 4
local sprite = Sprite("Image/logo.png") -- 6
if sprite then -- 6
    sprite.scaleX = 0.5 -- 8
    sprite.scaleY = 0.5 -- 9
    sprite.touchEnabled = true -- 10
    sprite:slot( -- 11
        "TapMoved", -- 11
        function(touch) -- 11
            if not touch.first then -- 11
                return -- 13
            end -- 13
            if not sprite then -- 13
                return -- 15
            end -- 15
            sprite.position = sprite.position:add(touch.delta) -- 16
        end -- 11
    ) -- 11
end -- 11
local windowFlags = {"NoResize", "NoSavedSettings"} -- 20
threadLoop(function() -- 24
    local ____App_visualSize_0 = App.visualSize -- 25
    local width = ____App_visualSize_0.width -- 25
    ImGui.SetNextWindowPos( -- 26
        Vec2(width - 10, 10), -- 26
        "Always", -- 26
        Vec2(1, 0) -- 26
    ) -- 26
    ImGui.SetNextWindowSize( -- 27
        Vec2(240, 520), -- 27
        "FirstUseEver" -- 27
    ) -- 27
    ImGui.Begin( -- 28
        "Sprite", -- 28
        windowFlags, -- 28
        function() -- 28
            ImGui.Text("Sprite (Typescript)") -- 29
            ImGui.BeginChild( -- 30
                "SpriteSetting", -- 30
                Vec2(-1, -40), -- 30
                function() -- 30
                    if not sprite then -- 30
                        return -- 31
                    end -- 31
                    local changed = false -- 32
                    local z = sprite.z -- 33
                    changed, z = ImGui.DragFloat( -- 34
                        "Z", -- 34
                        z, -- 34
                        1, -- 34
                        -1000, -- 34
                        1000, -- 34
                        "%.2f" -- 34
                    ) -- 34
                    if changed then -- 34
                        sprite.z = z -- 36
                    end -- 36
                    local anchor = sprite.anchor -- 38
                    local x, y = anchor.x, anchor.y -- 39
                    changed, x, y = ImGui.DragFloat2( -- 40
                        "Anchor", -- 40
                        x, -- 40
                        y, -- 40
                        0.01, -- 40
                        0, -- 40
                        1, -- 40
                        "%.2f" -- 40
                    ) -- 40
                    if changed then -- 40
                        sprite.anchor = Vec2(x, y) -- 42
                    end -- 42
                    local size = sprite.size -- 44
                    local spriteW, height = size.width, size.height -- 45
                    changed, spriteW, height = ImGui.DragFloat2( -- 46
                        "Size", -- 46
                        spriteW, -- 46
                        height, -- 46
                        0.1, -- 46
                        0, -- 46
                        1000, -- 46
                        "%.f" -- 46
                    ) -- 46
                    if changed then -- 46
                        sprite.size = Size(spriteW, height) -- 48
                    end -- 48
                    local scaleX, scaleY = sprite.scaleX, sprite.scaleY -- 50
                    changed, scaleX, scaleY = ImGui.DragFloat2( -- 51
                        "Scale", -- 51
                        scaleX, -- 51
                        scaleY, -- 51
                        0.01, -- 51
                        -2, -- 51
                        2, -- 51
                        "%.2f" -- 51
                    ) -- 51
                    if changed then -- 51
                        local ____temp_1 = {scaleX, scaleY} -- 53
                        sprite.scaleX = ____temp_1[1] -- 53
                        sprite.scaleY = ____temp_1[2] -- 53
                    end -- 53
                    ImGui.PushItemWidth( -- 55
                        -60, -- 55
                        function() -- 55
                            if not sprite then -- 55
                                return -- 56
                            end -- 56
                            local angle = sprite.angle -- 57
                            changed, angle = ImGui.DragInt( -- 58
                                "Angle", -- 58
                                math.floor(angle), -- 58
                                1, -- 58
                                -360, -- 58
                                360 -- 58
                            ) -- 58
                            if changed then -- 58
                                sprite.angle = angle -- 60
                            end -- 60
                        end -- 55
                    ) -- 55
                    ImGui.PushItemWidth( -- 63
                        -60, -- 63
                        function() -- 63
                            if not sprite then -- 63
                                return -- 64
                            end -- 64
                            local angleX = sprite.angleX -- 65
                            changed, angleX = ImGui.DragInt( -- 66
                                "AngleX", -- 66
                                math.floor(angleX), -- 66
                                1, -- 66
                                -360, -- 66
                                360 -- 66
                            ) -- 66
                            if changed then -- 66
                                sprite.angleX = angleX -- 68
                            end -- 68
                        end -- 63
                    ) -- 63
                    ImGui.PushItemWidth( -- 71
                        -60, -- 71
                        function() -- 71
                            if not sprite then -- 71
                                return -- 72
                            end -- 72
                            local angleY = sprite.angleY -- 73
                            changed, angleY = ImGui.DragInt( -- 74
                                "AngleY", -- 74
                                math.floor(angleY), -- 74
                                1, -- 74
                                -360, -- 74
                                360 -- 74
                            ) -- 74
                            if changed then -- 74
                                sprite.angleY = angleY -- 76
                            end -- 76
                        end -- 71
                    ) -- 71
                    local skewX, skewY = sprite.skewX, sprite.skewY -- 79
                    changed, skewX, skewY = ImGui.DragInt2( -- 80
                        "Skew", -- 80
                        math.floor(skewX), -- 80
                        math.floor(skewY), -- 80
                        1, -- 80
                        -360, -- 80
                        360 -- 80
                    ) -- 80
                    if changed then -- 80
                        local ____temp_2 = {skewX, skewY} -- 82
                        sprite.skewX = ____temp_2[1] -- 82
                        sprite.skewY = ____temp_2[2] -- 82
                    end -- 82
                    ImGui.PushItemWidth( -- 84
                        -70, -- 84
                        function() -- 84
                            if not sprite then -- 84
                                return -- 85
                            end -- 85
                            local opacity = sprite.opacity -- 86
                            changed, opacity = ImGui.DragFloat( -- 87
                                "Opacity", -- 87
                                opacity, -- 87
                                0.01, -- 87
                                0, -- 87
                                1, -- 87
                                "%.2f" -- 87
                            ) -- 87
                            if changed then -- 87
                                sprite.opacity = opacity -- 89
                            end -- 89
                        end -- 84
                    ) -- 84
                    ImGui.PushItemWidth( -- 92
                        -1, -- 92
                        function() -- 92
                            if not sprite then -- 92
                                return -- 93
                            end -- 93
                            local color3 = sprite.color3 -- 94
                            ImGui.SetColorEditOptions({"DisplayRGB"}) -- 95
                            if ImGui.ColorEdit3("", color3) then -- 95
                                sprite.color3 = color3 -- 97
                            end -- 97
                        end -- 92
                    ) -- 92
                end -- 30
            ) -- 30
            if ImGui.Button( -- 30
                "Reset", -- 101
                Vec2(140, 30) -- 101
            ) then -- 101
                if not sprite then -- 101
                    return -- 102
                end -- 102
                local parent = sprite.parent -- 103
                parent:removeChild(sprite) -- 104
                sprite = Sprite("Image/logo.png") -- 105
                if sprite then -- 105
                    parent:addChild(sprite) -- 106
                end -- 106
            end -- 106
        end -- 28
    ) -- 28
    return false -- 109
end) -- 24
return ____exports -- 24