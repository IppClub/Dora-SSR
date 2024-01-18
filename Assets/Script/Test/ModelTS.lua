-- [ts]: ModelTS.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Model = ____dora.Model -- 3
local Vec2 = ____dora.Vec2 -- 3
local threadLoop = ____dora.threadLoop -- 3
local modelFile = "Model/xiaoli.model" -- 5
local looks = Model:getLooks(modelFile) -- 7
if #looks == 0 then -- 7
    looks[#looks + 1] = "" -- 9
end -- 9
local animations = Model:getAnimations(modelFile) -- 12
if #animations == 0 then -- 12
    animations[#animations + 1] = "" -- 14
end -- 14
local currentLook = __TS__ArrayIndexOf(looks, "happy") -- 17
currentLook = math.max(currentLook, 0) -- 18
local currentAnim = __TS__ArrayIndexOf(animations, "idle") -- 19
currentAnim = math.max(currentAnim, 0) -- 20
local model = Model(modelFile) -- 22
if model then -- 22
    model.recovery = 0.2 -- 24
    model.look = looks[currentLook + 1] -- 25
    model:play(animations[currentAnim + 1], true) -- 26
    model:slot( -- 27
        "AnimationEnd", -- 27
        function(name) -- 27
            print(name, "end") -- 28
        end -- 27
    ) -- 27
end -- 27
currentLook = currentLook + 1 -- 32
currentAnim = currentAnim + 1 -- 33
local loop = true -- 35
local windowFlags = {"NoResize", "NoSavedSettings"} -- 36
threadLoop(function() -- 40
    local ____App_visualSize_0 = App.visualSize -- 41
    local width = ____App_visualSize_0.width -- 41
    ImGui.SetNextWindowPos( -- 42
        Vec2(width - 250, 10), -- 42
        "FirstUseEver" -- 42
    ) -- 42
    ImGui.SetNextWindowSize( -- 43
        Vec2(240, 325), -- 43
        "FirstUseEver" -- 43
    ) -- 43
    ImGui.Begin( -- 44
        "Model", -- 44
        windowFlags, -- 44
        function() -- 44
            if not model then -- 44
                return -- 45
            end -- 45
            local changed = false -- 46
            changed, currentLook = ImGui.Combo("Look", currentLook, looks) -- 47
            if changed then -- 47
                model.look = looks[currentLook] -- 49
            end -- 49
            changed, currentAnim = ImGui.Combo("Anim", currentAnim, animations) -- 52
            if changed then -- 52
                model:play(animations[currentAnim], loop) -- 54
            end -- 54
            changed, loop = ImGui.Checkbox("Loop", loop) -- 57
            if changed then -- 57
                model:play(animations[currentAnim], loop) -- 59
            end -- 59
            ImGui.SameLine() -- 62
            local ____temp_1 = {ImGui.Checkbox("Reversed", model.reversed)} -- 63
            changed = ____temp_1[1] -- 63
            model.reversed = ____temp_1[2] -- 63
            if changed then -- 63
                model:play(animations[currentAnim], loop) -- 65
            end -- 65
            ImGui.PushItemWidth( -- 68
                -70, -- 68
                function() -- 68
                    local ____temp_2 = {ImGui.DragFloat( -- 69
                        "Speed", -- 69
                        model.speed, -- 69
                        0.01, -- 69
                        0, -- 69
                        10, -- 69
                        "%.2f" -- 69
                    )} -- 69
                    changed = ____temp_2[1] -- 69
                    model.speed = ____temp_2[2] -- 69
                    local ____temp_3 = {ImGui.DragFloat( -- 70
                        "Recovery", -- 70
                        model.recovery, -- 70
                        0.01, -- 70
                        0, -- 70
                        10, -- 70
                        "%.2f" -- 70
                    )} -- 70
                    changed = ____temp_3[1] -- 70
                    model.recovery = ____temp_3[2] -- 70
                end -- 68
            ) -- 68
            local scale = model.scaleX -- 73
            changed, scale = ImGui.DragFloat( -- 74
                "Scale", -- 74
                scale, -- 74
                0.01, -- 74
                0.5, -- 74
                2, -- 74
                "%.2f" -- 74
            ) -- 74
            model.scaleX = scale -- 75
            model.scaleY = scale -- 76
            if ImGui.Button( -- 76
                "Play", -- 78
                Vec2(140, 30) -- 78
            ) then -- 78
                model:play(animations[currentAnim], loop) -- 79
            end -- 79
        end -- 44
    ) -- 44
    return false -- 83
end) -- 40
return ____exports -- 40