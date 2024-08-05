-- [yue]: Script/Example/Label.yue
local Label = Dora.Label -- 1
local Sequence = Dora.Sequence -- 1
local Delay = Dora.Delay -- 1
local Scale = Dora.Scale -- 1
local App = Dora.App -- 1
local Vec2 = Dora.Vec2 -- 1
local Opacity = Dora.Opacity -- 1
local threadLoop = Dora.threadLoop -- 1
local ImGui = Dora.ImGui -- 1
do -- 3
	local _with_0 = Label("sarasa-mono-sc-regular", 40) -- 3
	_with_0.batched = false -- 4
	_with_0.text = "你好，Dora SSR！" -- 5
	for i = 1, _with_0.characterCount do -- 6
		local char = _with_0:getCharacter(i) -- 7
		if char ~= nil then -- 8
			char:runAction(Sequence(Delay(i / 5), Scale(0.2, 1, 2), Scale(0.2, 2, 1))) -- 8
		end -- 8
	end -- 12
end -- 3
do -- 14
	local _with_0 = Label("sarasa-mono-sc-regular", 30) -- 14
	_with_0.text = "-- from Jin." -- 15
	_with_0.color = App.themeColor -- 16
	_with_0.opacity = 0 -- 17
	_with_0.position = Vec2(120, -70) -- 18
	_with_0:runAction(Sequence(Delay(2), Opacity(0.2, 0, 1))) -- 19
end -- 14
local windowFlags = { -- 27
	"NoDecoration", -- 27
	"AlwaysAutoResize", -- 27
	"NoSavedSettings", -- 27
	"NoFocusOnAppearing", -- 27
	"NoNav", -- 27
	"NoMove" -- 27
} -- 27
return threadLoop(function() -- 35
	local width -- 36
	width = App.visualSize.width -- 36
	ImGui.SetNextWindowBgAlpha(0.35) -- 37
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 38
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 39
	return ImGui.Begin("Label", windowFlags, function() -- 40
		ImGui.Text("Label (Yuescript)") -- 41
		ImGui.Separator() -- 42
		return ImGui.TextWrapped("Render labels with unbatched and batched methods!") -- 43
	end) -- 43
end) -- 43
