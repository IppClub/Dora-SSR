-- [yue]: Script/Example/Label.yue
local Label = dora.Label -- 1
local Sequence = dora.Sequence -- 1
local Delay = dora.Delay -- 1
local Scale = dora.Scale -- 1
local App = dora.App -- 1
local Vec2 = dora.Vec2 -- 1
local Opacity = dora.Opacity -- 1
local threadLoop = dora.threadLoop -- 1
local ImGui = dora.ImGui -- 1
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
	"AlwaysAutoResize", -- 28
	"NoSavedSettings", -- 29
	"NoFocusOnAppearing", -- 30
	"NoNav", -- 31
	"NoMove" -- 32
} -- 26
return threadLoop(function() -- 33
	local width -- 34
	width = App.visualSize.width -- 34
	ImGui.SetNextWindowBgAlpha(0.35) -- 35
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 36
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 37
	return ImGui.Begin("Label", windowFlags, function() -- 38
		ImGui.Text("Label (Yuescript)") -- 39
		ImGui.Separator() -- 40
		return ImGui.TextWrapped("Render labels with unbatched and batched methods!") -- 41
	end) -- 41
end) -- 41
