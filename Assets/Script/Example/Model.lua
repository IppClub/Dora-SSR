-- [yue]: Script/Example/Model.yue
local Model = dora.Model -- 1
local print = _G.print -- 1
local threadLoop = dora.threadLoop -- 1
local App = dora.App -- 1
local ImGui = dora.ImGui -- 1
local Vec2 = dora.Vec2 -- 1
local modelFile = "Model/xiaoli.model" -- 3
local model -- 5
do -- 5
	local _with_0 = Model(modelFile) -- 5
	_with_0.recovery = 0.2 -- 6
	_with_0.look = "happy" -- 7
	_with_0:play("walk", true) -- 8
	_with_0:slot("AnimationEnd", function(name) -- 9
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
local windowFlags = { -- 20
	"NoResize", -- 20
	"NoSavedSettings" -- 20
} -- 20
return threadLoop(function() -- 21
	local width -- 22
	width = App.visualSize.width -- 22
	ImGui.SetNextWindowPos(Vec2(width - 250, 10), "FirstUseEver") -- 23
	ImGui.SetNextWindowSize(Vec2(240, 325), "FirstUseEver") -- 24
	return ImGui.Begin("Model", windowFlags, function() -- 25
		do -- 26
			local changed -- 26
			changed, currentLook = ImGui.Combo("Look", currentLook, looks) -- 26
			if changed then -- 26
				model.look = looks[currentLook] -- 27
			end -- 26
		end -- 26
		do -- 28
			local changed -- 28
			changed, currentAnim = ImGui.Combo("Anim", currentAnim, animations) -- 28
			if changed then -- 28
				model:play(animations[currentAnim], loop) -- 29
			end -- 28
		end -- 28
		do -- 30
			local changed -- 30
			changed, loop = ImGui.Checkbox("Loop", loop) -- 30
			if changed then -- 30
				model:play(animations[currentAnim], loop) -- 31
			end -- 30
		end -- 30
		ImGui.SameLine() -- 32
		do -- 33
			local changed -- 33
			changed, model.reversed = ImGui.Checkbox("Reversed", model.reversed) -- 33
			if changed then -- 33
				model:play(animations[currentAnim], loop) -- 34
			end -- 33
		end -- 33
		ImGui.PushItemWidth(-70, function() -- 35
			local _ -- 36
			_, model.speed = ImGui.DragFloat("Speed", model.speed, 0.01, 0, 10, "%.2f") -- 36
			_, model.recovery = ImGui.DragFloat("Recovery", model.recovery, 0.01, 0, 10, "%.2f") -- 37
		end) -- 35
		local scale = model.scaleX -- 38
		local _ -- 39
		_, scale = ImGui.DragFloat("Scale", scale, 0.01, 0.5, 2, "%.2f") -- 39
		model.scaleX, model.scaleY = scale, scale -- 40
		if ImGui.Button("Play", Vec2(140, 30)) then -- 41
			return model:play(animations[currentAnim], loop) -- 42
		end -- 41
	end) -- 42
end) -- 42
