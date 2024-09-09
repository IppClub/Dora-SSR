-- [yue]: Script/Example/Model.yue
local Model = Dora.Model -- 1
local print = _G.print -- 1
local threadLoop = Dora.threadLoop -- 1
local App = Dora.App -- 1
local ImGui = Dora.ImGui -- 1
local Vec2 = Dora.Vec2 -- 1
local modelFile = "Model/xiaoli.model" -- 3
local model -- 5
do -- 5
	local _with_0 = Model(modelFile) -- 5
	_with_0.recovery = 0.2 -- 6
	_with_0.look = "happy" -- 7
	_with_0:play("walk", true) -- 8
	_with_0:onAnimationEnd(function(name) -- 9
		return print(name, "end") -- 9
	end) -- 9
	model = _with_0 -- 5
end -- 5
local looks = Model:getLooks(modelFile) -- 13
if #looks == 0 then -- 14
	looks[#looks + 1] = "" -- 14
end -- 14
local animations = Model:getAnimations(modelFile) -- 15
if #animations == 0 then -- 16
	animations[#animations + 1] = "" -- 16
end -- 16
local currentLook = #looks -- 17
local currentAnim = #animations -- 18
local loop = true -- 19
local windowFlags = { -- 21
	"NoResize", -- 21
	"NoSavedSettings" -- 21
} -- 21
return threadLoop(function() -- 22
	local width -- 23
	width = App.visualSize.width -- 23
	ImGui.SetNextWindowPos(Vec2(width - 250, 10), "FirstUseEver") -- 24
	ImGui.SetNextWindowSize(Vec2(240, 325), "FirstUseEver") -- 25
	return ImGui.Begin("Model", windowFlags, function() -- 26
		ImGui.Text("Model (Yuescript)") -- 27
		do -- 28
			local changed -- 28
			changed, currentLook = ImGui.Combo("Look", currentLook, looks) -- 28
			if changed then -- 28
				model.look = looks[currentLook] -- 29
			end -- 28
		end -- 28
		do -- 30
			local changed -- 30
			changed, currentAnim = ImGui.Combo("Anim", currentAnim, animations) -- 30
			if changed then -- 30
				model:play(animations[currentAnim], loop) -- 31
			end -- 30
		end -- 30
		do -- 32
			local changed -- 32
			changed, loop = ImGui.Checkbox("Loop", loop) -- 32
			if changed then -- 32
				model:play(animations[currentAnim], loop) -- 33
			end -- 32
		end -- 32
		ImGui.SameLine() -- 34
		do -- 35
			local changed -- 35
			changed, model.reversed = ImGui.Checkbox("Reversed", model.reversed) -- 35
			if changed then -- 35
				model:play(animations[currentAnim], loop) -- 36
			end -- 35
		end -- 35
		ImGui.PushItemWidth(-70, function() -- 37
			local _ -- 38
			_, model.speed = ImGui.DragFloat("Speed", model.speed, 0.01, 0, 10, "%.2f") -- 38
			_, model.recovery = ImGui.DragFloat("Recovery", model.recovery, 0.01, 0, 10, "%.2f") -- 39
		end) -- 37
		local scale = model.scaleX -- 40
		local _ -- 41
		_, scale = ImGui.DragFloat("Scale", scale, 0.01, 0.5, 2, "%.2f") -- 41
		model.scaleX, model.scaleY = scale, scale -- 42
		if ImGui.Button("Play", Vec2(140, 30)) then -- 43
			return model:play(animations[currentAnim], loop) -- 44
		end -- 43
	end) -- 44
end) -- 44
