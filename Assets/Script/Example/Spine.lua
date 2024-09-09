-- [yue]: Script/Example/Spine.yue
local Spine = Dora.Spine -- 1
local p = _G.p -- 1
local print = _G.print -- 1
local tostring = _G.tostring -- 1
local Spawn = Dora.Spawn -- 1
local Sequence = Dora.Sequence -- 1
local Vec2 = Dora.Vec2 -- 1
local Opacity = Dora.Opacity -- 1
local Label = Dora.Label -- 1
local App = Dora.App -- 1
local Ease = Dora.Ease -- 1
local Delay = Dora.Delay -- 1
local Event = Dora.Event -- 1
local Scale = Dora.Scale -- 1
local threadLoop = Dora.threadLoop -- 1
local ImGui = Dora.ImGui -- 1
local spineStr = "Spine/dragon-ess" -- 3
local animations = Spine:getAnimations(spineStr) -- 5
local looks = Spine:getLooks(spineStr) -- 6
p(animations, looks) -- 8
local _anon_func_0 = function(App, Delay, Ease, Event, Label, Opacity, Scale, Sequence, Spawn, Vec2, _with_0, name, x, y) -- 28
	local _with_1 = Label("sarasa-mono-sc-regular", 30) -- 17
	_with_1.text = name -- 18
	_with_1.color = App.themeColor -- 19
	_with_1.position = Vec2(x, y) -- 20
	_with_1:perform(Sequence(Spawn(Scale(1, 0, 2, Ease.OutQuad), Sequence(Delay(0.5), Opacity(0.5, 1, 0))), Event("Stop"))) -- 21
	_with_1:slot("Stop", function() -- 28
		return _with_1:removeFromParent() -- 28
	end) -- 28
	return _with_1 -- 17
end -- 17
local spine -- 10
do -- 10
	local _with_0 = Spine(spineStr) -- 10
	_with_0.look = looks[1] -- 11
	_with_0:play(animations[1], true) -- 12
	_with_0:onAnimationEnd(function(name) -- 13
		return print(tostring(name) .. " end!") -- 13
	end) -- 13
	_with_0:onTapBegan(function(touch) -- 14
		local x, y -- 15
		do -- 15
			local _obj_0 = touch.location -- 15
			x, y = _obj_0.x, _obj_0.y -- 15
		end -- 15
		local name = _with_0:containsPoint(x, y) -- 16
		if name then -- 16
			return _with_0:addChild(_anon_func_0(App, Delay, Ease, Event, Label, Opacity, Scale, Sequence, Spawn, Vec2, _with_0, name, x, y)) -- 28
		end -- 16
	end) -- 14
	spine = _with_0 -- 10
end -- 10
local windowFlags = { -- 33
	"NoDecoration", -- 33
	"AlwaysAutoResize", -- 33
	"NoSavedSettings", -- 33
	"NoFocusOnAppearing", -- 33
	"NoNav", -- 33
	"NoMove" -- 33
} -- 33
local showDebug = spine.showDebug -- 41
return threadLoop(function() -- 42
	local width -- 43
	width = App.visualSize.width -- 43
	ImGui.SetNextWindowBgAlpha(0.35) -- 44
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 45
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 46
	return ImGui.Begin("Spine", windowFlags, function() -- 47
		ImGui.Text("Spine (Yuescript)") -- 48
		ImGui.Separator() -- 49
		ImGui.TextWrapped("Basic usage to create spine! Tap it for a hit test.") -- 50
		local changed -- 51
		changed, showDebug = ImGui.Checkbox("BoundingBox", showDebug) -- 51
		if changed then -- 51
			spine.showDebug = showDebug -- 52
		end -- 51
	end) -- 52
end) -- 52
