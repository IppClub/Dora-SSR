-- [ts]: SpriteTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Size = ____dora.Size -- 3
local Sprite = ____dora.Sprite -- 3
local Vec2 = ____dora.Vec2 -- 3
local threadLoop = ____dora.threadLoop -- 3
local sprite = Sprite("Image/logo.png") -- 5
if sprite then -- 5
    sprite.scaleX = 0.5 -- 7
    sprite.scaleY = 0.5 -- 8
    sprite.touchEnabled = true -- 9
    sprite:slot( -- 10
        "TapMoved", -- 10
        function(touch) -- 10
            if not touch.first then -- 10
                return -- 12
            end -- 12
            if not sprite then -- 12
                return -- 14
            end -- 14
            sprite.position = sprite.position:add(touch.delta) -- 15
        end -- 10
    ) -- 10
end -- 10
local windowFlags = {"NoResize", "NoSavedSettings"} -- 19
threadLoop(function() -- 23
    local ____App_visualSize_0 = App.visualSize -- 24
    local width = ____App_visualSize_0.width -- 24
    ImGui.SetNextWindowPos( -- 25
        Vec2(width - 10, 10), -- 25
        "Always", -- 25
        Vec2(1, 0) -- 25
    ) -- 25
    ImGui.SetNextWindowSize( -- 26
        Vec2(240, 520), -- 26
        "FirstUseEver" -- 26
    ) -- 26
    ImGui.Begin( -- 27
        "Sprite", -- 27
        windowFlags, -- 27
        function() -- 27
            ImGui.BeginChild( -- 28
                "SpriteSetting", -- 28
                Vec2(-1, -40), -- 28
                function() -- 28
                    if not sprite then -- 28
                        return -- 29
                    end -- 29
                    local changed = false -- 30
                    local z = sprite.z -- 31
                    changed, z = ImGui.DragFloat( -- 32
                        "Z", -- 32
                        z, -- 32
                        1, -- 32
                        -1000, -- 32
                        1000, -- 32
                        "%.2f" -- 32
                    ) -- 32
                    if changed then -- 32
                        sprite.z = z -- 34
                    end -- 34
                    local anchor = sprite.anchor -- 36
                    local x, y = anchor.x, anchor.y -- 37
                    changed, x, y = ImGui.DragFloat2( -- 38
                        "Anchor", -- 38
                        x, -- 38
                        y, -- 38
                        0.01, -- 38
                        0, -- 38
                        1, -- 38
                        "%.2f" -- 38
                    ) -- 38
                    if changed then -- 38
                        sprite.anchor = Vec2(x, y) -- 40
                    end -- 40
                    local size = sprite.size -- 42
                    local spriteW, height = size.width, size.height -- 43
                    changed, spriteW, height = ImGui.DragFloat2( -- 44
                        "Size", -- 44
                        spriteW, -- 44
                        height, -- 44
                        0.1, -- 44
                        0, -- 44
                        1000, -- 44
                        "%.f" -- 44
                    ) -- 44
                    if changed then -- 44
                        sprite.size = Size(spriteW, height) -- 46
                    end -- 46
                    local scaleX, scaleY = sprite.scaleX, sprite.scaleY -- 48
                    changed, scaleX, scaleY = ImGui.DragFloat2( -- 49
                        "Scale", -- 49
                        scaleX, -- 49
                        scaleY, -- 49
                        0.01, -- 49
                        -2, -- 49
                        2, -- 49
                        "%.2f" -- 49
                    ) -- 49
                    if changed then -- 49
                        local ____temp_1 = {scaleX, scaleY} -- 51
                        sprite.scaleX = ____temp_1[1] -- 51
                        sprite.scaleY = ____temp_1[2] -- 51
                    end -- 51
                    ImGui.PushItemWidth( -- 53
                        -60, -- 53
                        function() -- 53
                            if not sprite then -- 53
                                return -- 54
                            end -- 54
                            local angle = sprite.angle -- 55
                            changed, angle = ImGui.DragInt( -- 56
                                "Angle", -- 56
                                math.floor(angle), -- 56
                                1, -- 56
                                -360, -- 56
                                360 -- 56
                            ) -- 56
                            if changed then -- 56
                                sprite.angle = angle -- 58
                            end -- 58
                        end -- 53
                    ) -- 53
                    ImGui.PushItemWidth( -- 61
                        -60, -- 61
                        function() -- 61
                            if not sprite then -- 61
                                return -- 62
                            end -- 62
                            local angleX = sprite.angleX -- 63
                            changed, angleX = ImGui.DragInt( -- 64
                                "AngleX", -- 64
                                math.floor(angleX), -- 64
                                1, -- 64
                                -360, -- 64
                                360 -- 64
                            ) -- 64
                            if changed then -- 64
                                sprite.angleX = angleX -- 66
                            end -- 66
                        end -- 61
                    ) -- 61
                    ImGui.PushItemWidth( -- 69
                        -60, -- 69
                        function() -- 69
                            if not sprite then -- 69
                                return -- 70
                            end -- 70
                            local angleY = sprite.angleY -- 71
                            changed, angleY = ImGui.DragInt( -- 72
                                "AngleY", -- 72
                                math.floor(angleY), -- 72
                                1, -- 72
                                -360, -- 72
                                360 -- 72
                            ) -- 72
                            if changed then -- 72
                                sprite.angleY = angleY -- 74
                            end -- 74
                        end -- 69
                    ) -- 69
                    local skewX, skewY = sprite.skewX, sprite.skewY -- 77
                    changed, skewX, skewY = ImGui.DragInt2( -- 78
                        "Skew", -- 78
                        math.floor(skewX), -- 78
                        math.floor(skewY), -- 78
                        1, -- 78
                        -360, -- 78
                        360 -- 78
                    ) -- 78
                    if changed then -- 78
                        local ____temp_2 = {skewX, skewY} -- 80
                        sprite.skewX = ____temp_2[1] -- 80
                        sprite.skewY = ____temp_2[2] -- 80
                    end -- 80
                    ImGui.PushItemWidth( -- 82
                        -70, -- 82
                        function() -- 82
                            if not sprite then -- 82
                                return -- 83
                            end -- 83
                            local opacity = sprite.opacity -- 84
                            changed, opacity = ImGui.DragFloat( -- 85
                                "Opacity", -- 85
                                opacity, -- 85
                                0.01, -- 85
                                0, -- 85
                                1, -- 85
                                "%.2f" -- 85
                            ) -- 85
                            if changed then -- 85
                                sprite.opacity = opacity -- 87
                            end -- 87
                        end -- 82
                    ) -- 82
                    ImGui.PushItemWidth( -- 90
                        -1, -- 90
                        function() -- 90
                            if not sprite then -- 90
                                return -- 91
                            end -- 91
                            local color3 = sprite.color3 -- 92
                            ImGui.SetColorEditOptions("RGB") -- 93
                            if ImGui.ColorEdit3("", color3) then -- 93
                                sprite.color3 = color3 -- 95
                            end -- 95
                        end -- 90
                    ) -- 90
                end -- 28
            ) -- 28
            if ImGui.Button( -- 28
                "Reset", -- 99
                Vec2(140, 30) -- 99
            ) then -- 99
                if not sprite then -- 99
                    return -- 100
                end -- 100
                local parent = sprite.parent -- 101
                parent:removeChild(sprite) -- 102
                sprite = Sprite("Image/logo.png") -- 103
                if sprite then -- 103
                    parent:addChild(sprite) -- 104
                end -- 104
            end -- 104
        end -- 27
    ) -- 27
    return false -- 107
end) -- 23
return ____exports -- 23