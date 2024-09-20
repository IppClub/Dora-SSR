-- [ts]: ModelTS.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____Dora = require("Dora") -- 4
local App = ____Dora.App -- 4
local Model = ____Dora.Model -- 4
local Vec2 = ____Dora.Vec2 -- 4
local threadLoop = ____Dora.threadLoop -- 4
local modelFile = "Model/xiaoli.model" -- 6
local looks = Model:getLooks(modelFile) -- 8
if #looks == 0 then -- 8
	looks[#looks + 1] = "" -- 10
end -- 10
local animations = Model:getAnimations(modelFile) -- 13
if #animations == 0 then -- 13
	animations[#animations + 1] = "" -- 15
end -- 15
local currentLook = __TS__ArrayIndexOf(looks, "happy") -- 18
currentLook = math.max(currentLook, 0) -- 19
local currentAnim = __TS__ArrayIndexOf(animations, "idle") -- 20
currentAnim = math.max(currentAnim, 0) -- 21
local model = Model(modelFile) -- 23
if model then -- 23
	model.recovery = 0.2 -- 25
	model.look = looks[currentLook + 1] -- 26
	model:play(animations[currentAnim + 1], true) -- 27
	model:onAnimationEnd(function(name) -- 28
		print(name, "end") -- 29
	end) -- 28
end -- 28
currentLook = currentLook + 1 -- 33
currentAnim = currentAnim + 1 -- 34
local loop = true -- 36
local windowFlags = {"NoResize", "NoSavedSettings"} -- 37
threadLoop(function() -- 41
	local ____App_visualSize_0 = App.visualSize -- 42
	local width = ____App_visualSize_0.width -- 42
	ImGui.SetNextWindowPos( -- 43
		Vec2(width - 250, 10), -- 43
		"FirstUseEver" -- 43
	) -- 43
	ImGui.SetNextWindowSize( -- 44
		Vec2(240, 325), -- 44
		"FirstUseEver" -- 44
	) -- 44
	ImGui.Begin( -- 45
		"Model", -- 45
		windowFlags, -- 45
		function() -- 45
			ImGui.Text("Model (Typescript)") -- 46
			if not model then -- 46
				return -- 47
			end -- 47
			local changed = false -- 48
			changed, currentLook = ImGui.Combo("Look", currentLook, looks) -- 49
			if changed then -- 49
				model.look = looks[currentLook] -- 51
			end -- 51
			changed, currentAnim = ImGui.Combo("Anim", currentAnim, animations) -- 54
			if changed then -- 54
				model:play(animations[currentAnim], loop) -- 56
			end -- 56
			changed, loop = ImGui.Checkbox("Loop", loop) -- 59
			if changed then -- 59
				model:play(animations[currentAnim], loop) -- 61
			end -- 61
			ImGui.SameLine() -- 64
			local ____temp_1 = {ImGui.Checkbox("Reversed", model.reversed)} -- 65
			changed = ____temp_1[1] -- 65
			model.reversed = ____temp_1[2] -- 65
			if changed then -- 65
				model:play(animations[currentAnim], loop) -- 67
			end -- 67
			ImGui.PushItemWidth( -- 70
				-70, -- 70
				function() -- 70
					local ____temp_2 = {ImGui.DragFloat( -- 71
						"Speed", -- 71
						model.speed, -- 71
						0.01, -- 71
						0, -- 71
						10, -- 71
						"%.2f" -- 71
					)} -- 71
					changed = ____temp_2[1] -- 71
					model.speed = ____temp_2[2] -- 71
					local ____temp_3 = {ImGui.DragFloat( -- 72
						"Recovery", -- 72
						model.recovery, -- 72
						0.01, -- 72
						0, -- 72
						10, -- 72
						"%.2f" -- 72
					)} -- 72
					changed = ____temp_3[1] -- 72
					model.recovery = ____temp_3[2] -- 72
				end -- 70
			) -- 70
			local scale = model.scaleX -- 75
			changed, scale = ImGui.DragFloat( -- 76
				"Scale", -- 76
				scale, -- 76
				0.01, -- 76
				0.5, -- 76
				2, -- 76
				"%.2f" -- 76
			) -- 76
			model.scaleX = scale -- 77
			model.scaleY = scale -- 78
			if ImGui.Button( -- 78
				"Play", -- 80
				Vec2(140, 30) -- 80
			) then -- 80
				model:play(animations[currentAnim], loop) -- 81
			end -- 81
		end -- 45
	) -- 45
	return false -- 85
end) -- 41
return ____exports -- 41