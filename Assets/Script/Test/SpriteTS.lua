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
sprite.scaleX = 0.5 -- 6
sprite.scaleY = 0.5 -- 7
sprite.touchEnabled = true -- 8
sprite:slot( -- 9
    "TapMoved", -- 9
    function(touch) -- 9
        if not touch.first then -- 9
            return -- 11
        end -- 11
        sprite.position = sprite.position:add(touch.delta) -- 13
    end -- 9
) -- 9
local windowFlags = {"NoResize", "NoSavedSettings"} -- 16
threadLoop(function() -- 20
    local ____App_visualSize_0 = App.visualSize -- 21
    local width = ____App_visualSize_0.width -- 21
    ImGui.SetNextWindowPos( -- 22
        Vec2(width - 10, 10), -- 22
        "Always", -- 22
        Vec2(1, 0) -- 22
    ) -- 22
    ImGui.SetNextWindowSize( -- 23
        Vec2(240, 520), -- 23
        "FirstUseEver" -- 23
    ) -- 23
    ImGui.Begin( -- 24
        "Sprite", -- 24
        windowFlags, -- 24
        function() -- 24
            ImGui.BeginChild( -- 25
                "SpriteSetting", -- 25
                Vec2(-1, -40), -- 25
                function() -- 25
                    local changed = false -- 26
                    local z = sprite.z -- 27
                    changed, z = ImGui.DragFloat( -- 28
                        "Z", -- 28
                        z, -- 28
                        1, -- 28
                        -1000, -- 28
                        1000, -- 28
                        "%.2f" -- 28
                    ) -- 28
                    if changed then -- 28
                        sprite.z = z -- 30
                    end -- 30
                    local anchor = sprite.anchor -- 32
                    local x, y = anchor.x, anchor.y -- 33
                    changed, x, y = ImGui.DragFloat2( -- 34
                        "Anchor", -- 34
                        x, -- 34
                        y, -- 34
                        0.01, -- 34
                        0, -- 34
                        1, -- 34
                        "%.2f" -- 34
                    ) -- 34
                    if changed then -- 34
                        sprite.anchor = Vec2(x, y) -- 36
                    end -- 36
                    local size = sprite.size -- 38
                    local spriteW, height = size.width, size.height -- 39
                    changed, spriteW, height = ImGui.DragFloat2( -- 40
                        "Size", -- 40
                        spriteW, -- 40
                        height, -- 40
                        0.1, -- 40
                        0, -- 40
                        1000, -- 40
                        "%.f" -- 40
                    ) -- 40
                    if changed then -- 40
                        sprite.size = Size(spriteW, height) -- 42
                    end -- 42
                    local scaleX, scaleY = sprite.scaleX, sprite.scaleY -- 44
                    changed, scaleX, scaleY = ImGui.DragFloat2( -- 45
                        "Scale", -- 45
                        scaleX, -- 45
                        scaleY, -- 45
                        0.01, -- 45
                        -2, -- 45
                        2, -- 45
                        "%.2f" -- 45
                    ) -- 45
                    if changed then -- 45
                        local ____temp_1 = {scaleX, scaleY} -- 47
                        sprite.scaleX = ____temp_1[1] -- 47
                        sprite.scaleY = ____temp_1[2] -- 47
                    end -- 47
                    ImGui.PushItemWidth( -- 49
                        -60, -- 49
                        function() -- 49
                            local angle = sprite.angle -- 50
                            changed, angle = ImGui.DragInt( -- 51
                                "Angle", -- 51
                                math.floor(angle), -- 51
                                1, -- 51
                                -360, -- 51
                                360 -- 51
                            ) -- 51
                            if changed then -- 51
                                sprite.angle = angle -- 53
                            end -- 53
                        end -- 49
                    ) -- 49
                    ImGui.PushItemWidth( -- 56
                        -60, -- 56
                        function() -- 56
                            local angleX = sprite.angleX -- 57
                            changed, angleX = ImGui.DragInt( -- 58
                                "AngleX", -- 58
                                math.floor(angleX), -- 58
                                1, -- 58
                                -360, -- 58
                                360 -- 58
                            ) -- 58
                            if changed then -- 58
                                sprite.angleX = angleX -- 60
                            end -- 60
                        end -- 56
                    ) -- 56
                    ImGui.PushItemWidth( -- 63
                        -60, -- 63
                        function() -- 63
                            local angleY = sprite.angleY -- 64
                            changed, angleY = ImGui.DragInt( -- 65
                                "AngleY", -- 65
                                math.floor(angleY), -- 65
                                1, -- 65
                                -360, -- 65
                                360 -- 65
                            ) -- 65
                            if changed then -- 65
                                sprite.angleY = angleY -- 67
                            end -- 67
                        end -- 63
                    ) -- 63
                    local skewX, skewY = sprite.skewX, sprite.skewY -- 70
                    changed, skewX, skewY = ImGui.DragInt2( -- 71
                        "Skew", -- 71
                        math.floor(skewX), -- 71
                        math.floor(skewY), -- 71
                        1, -- 71
                        -360, -- 71
                        360 -- 71
                    ) -- 71
                    if changed then -- 71
                        local ____temp_2 = {skewX, skewY} -- 73
                        sprite.skewX = ____temp_2[1] -- 73
                        sprite.skewY = ____temp_2[2] -- 73
                    end -- 73
                    ImGui.PushItemWidth( -- 75
                        -70, -- 75
                        function() -- 75
                            local opacity = sprite.opacity -- 76
                            changed, opacity = ImGui.DragFloat( -- 77
                                "Opacity", -- 77
                                opacity, -- 77
                                0.01, -- 77
                                0, -- 77
                                1, -- 77
                                "%.2f" -- 77
                            ) -- 77
                            if changed then -- 77
                                sprite.opacity = opacity -- 79
                            end -- 79
                        end -- 75
                    ) -- 75
                    ImGui.PushItemWidth( -- 82
                        -1, -- 82
                        function() -- 82
                            local color3 = sprite.color3 -- 83
                            ImGui.SetColorEditOptions("RGB") -- 84
                            if ImGui.ColorEdit3("", color3) then -- 84
                                sprite.color3 = color3 -- 86
                            end -- 86
                        end -- 82
                    ) -- 82
                end -- 25
            ) -- 25
            if ImGui.Button( -- 25
                "Reset", -- 90
                Vec2(140, 30) -- 90
            ) then -- 90
                local parent = sprite.parent -- 91
                parent:removeChild(sprite) -- 92
                sprite = Sprite("Image/logo.png") -- 93
                parent:addChild(sprite) -- 94
            end -- 94
        end -- 24
    ) -- 24
    return false -- 97
end) -- 20
return ____exports -- 20