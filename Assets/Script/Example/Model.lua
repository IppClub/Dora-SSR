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
		ImGui.Text("Model (Yuescript)") -- 26
		do -- 27
			local changed -- 27
			changed, currentLook = ImGui.Combo("Look", currentLook, looks) -- 27
			if changed then -- 27
				model.look = looks[currentLook] -- 28
			end -- 27
		end -- 27
		do -- 29
			local changed -- 29
			changed, currentAnim = ImGui.Combo("Anim", currentAnim, animations) -- 29
			if changed then -- 29
				model:play(animations[currentAnim], loop) -- 30
			end -- 29
		end -- 29
		do -- 31
			local changed -- 31
			changed, loop = ImGui.Checkbox("Loop", loop) -- 31
			if changed then -- 31
				model:play(animations[currentAnim], loop) -- 32
			end -- 31
		end -- 31
		ImGui.SameLine() -- 33
		do -- 34
			local changed -- 34
			changed, model.reversed = ImGui.Checkbox("Reversed", model.reversed) -- 34
			if changed then -- 34
				model:play(animations[currentAnim], loop) -- 35
			end -- 34
		end -- 34
		ImGui.PushItemWidth(-70, function() -- 36
			local _ -- 37
			_, model.speed = ImGui.DragFloat("Speed", model.speed, 0.01, 0, 10, "%.2f") -- 37
			_, model.recovery = ImGui.DragFloat("Recovery", model.recovery, 0.01, 0, 10, "%.2f") -- 38
		end) -- 36
		local scale = model.scaleX -- 39
		local _ -- 40
		_, scale = ImGui.DragFloat("Scale", scale, 0.01, 0.5, 2, "%.2f") -- 40
		model.scaleX, model.scaleY = scale, scale -- 41
		if ImGui.Button("Play", Vec2(140, 30)) then -- 42
			return model:play(animations[currentAnim], loop) -- 43
		end -- 42
	end) -- 43
end) -- 43
