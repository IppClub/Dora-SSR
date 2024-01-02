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
model.recovery = 0.2 -- 23
model.look = looks[currentLook + 1] -- 24
model:play(animations[currentAnim + 1], true) -- 25
model:slot( -- 26
    "AnimationEnd", -- 26
    function(name) -- 26
        print(name, "end") -- 27
    end -- 26
) -- 26
currentLook = currentLook + 1 -- 30
currentAnim = currentAnim + 1 -- 31
local loop = true -- 33
local windowFlags = {"NoResize", "NoSavedSettings"} -- 34
threadLoop(function() -- 38
    local ____App_visualSize_0 = App.visualSize -- 39
    local width = ____App_visualSize_0.width -- 39
    ImGui.SetNextWindowPos( -- 40
        Vec2(width - 250, 10), -- 40
        "FirstUseEver" -- 40
    ) -- 40
    ImGui.SetNextWindowSize( -- 41
        Vec2(240, 325), -- 41
        "FirstUseEver" -- 41
    ) -- 41
    ImGui.Begin( -- 42
        "Model", -- 42
        windowFlags, -- 42
        function() -- 42
            local changed = false -- 43
            changed, currentLook = ImGui.Combo("Look", currentLook, looks) -- 44
            if changed then -- 44
                model.look = looks[currentLook] -- 46
            end -- 46
            changed, currentAnim = ImGui.Combo("Anim", currentAnim, animations) -- 49
            if changed then -- 49
                model:play(animations[currentAnim], loop) -- 51
            end -- 51
            changed, loop = ImGui.Checkbox("Loop", loop) -- 54
            if changed then -- 54
                model:play(animations[currentAnim], loop) -- 56
            end -- 56
            ImGui.SameLine() -- 59
            local ____temp_1 = {ImGui.Checkbox("Reversed", model.reversed)} -- 60
            changed = ____temp_1[1] -- 60
            model.reversed = ____temp_1[2] -- 60
            if changed then -- 60
                model:play(animations[currentAnim], loop) -- 62
            end -- 62
            ImGui.PushItemWidth( -- 65
                -70, -- 65
                function() -- 65
                    local ____temp_2 = {ImGui.DragFloat( -- 66
                        "Speed", -- 66
                        model.speed, -- 66
                        0.01, -- 66
                        0, -- 66
                        10, -- 66
                        "%.2f" -- 66
                    )} -- 66
                    changed = ____temp_2[1] -- 66
                    model.speed = ____temp_2[2] -- 66
                    local ____temp_3 = {ImGui.DragFloat( -- 67
                        "Recovery", -- 67
                        model.recovery, -- 67
                        0.01, -- 67
                        0, -- 67
                        10, -- 67
                        "%.2f" -- 67
                    )} -- 67
                    changed = ____temp_3[1] -- 67
                    model.recovery = ____temp_3[2] -- 67
                end -- 65
            ) -- 65
            local scale = model.scaleX -- 70
            changed, scale = ImGui.DragFloat( -- 71
                "Scale", -- 71
                scale, -- 71
                0.01, -- 71
                0.5, -- 71
                2, -- 71
                "%.2f" -- 71
            ) -- 71
            model.scaleX = scale -- 72
            model.scaleY = scale -- 73
            if ImGui.Button( -- 73
                "Play", -- 75
                Vec2(140, 30) -- 75
            ) then -- 75
                model:play(animations[currentAnim], loop) -- 76
            end -- 76
        end -- 42
    ) -- 42
    return false -- 80
end) -- 38
return ____exports -- 38