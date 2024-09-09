-- [yue]: Script/Example/DragonBones.yue
local DragonBone = Dora.DragonBone -- 1
local p = _G.p -- 1
local print = _G.print -- 1
local tostring = _G.tostring -- 1
local App = Dora.App -- 1
local Spawn = Dora.Spawn -- 1
local Scale = Dora.Scale -- 1
local Label = Dora.Label -- 1
local Ease = Dora.Ease -- 1
local Opacity = Dora.Opacity -- 1
local Event = Dora.Event -- 1
local Sequence = Dora.Sequence -- 1
local Delay = Dora.Delay -- 1
local Vec2 = Dora.Vec2 -- 1
local threadLoop = Dora.threadLoop -- 1
local ImGui = Dora.ImGui -- 1
local boneStr = "DragonBones/NewDragon" -- 3
local animations = DragonBone:getAnimations(boneStr) -- 5
local looks = DragonBone:getLooks(boneStr) -- 6
p(animations, looks) -- 8
local _anon_func_0 = function(App, Delay, Ease, Event, Label, Opacity, Scale, Sequence, Spawn, Vec2, _with_0, name, x, y) -- 30
	local _with_1 = Label("sarasa-mono-sc-regular", 30) -- 18
	_with_1.text = name -- 19
	_with_1.color = App.themeColor -- 20
	_with_1:perform(Sequence(Spawn(Scale(1, 0, 2, Ease.OutQuad), Sequence(Delay(0.5), Opacity(0.5, 1, 0))), Event("Stop"))) -- 21
	_with_1.position = Vec2(x, y) -- 28
	_with_1.order = 100 -- 29
	_with_1:slot("Stop", function() -- 30
		return _with_1:removeFromParent() -- 30
	end) -- 30
	return _with_1 -- 18
end -- 18
local bone -- 10
do -- 10
	local _with_0 = DragonBone(boneStr) -- 10
	_with_0.look = looks[1] -- 11
	_with_0:play(animations[1], true) -- 12
	_with_0:onAnimationEnd(function(name) -- 13
		return print(tostring(name) .. " end!") -- 13
	end) -- 13
	_with_0.y = -200 -- 14
	_with_0:onTapBegan(function(touch) -- 15
		local x, y -- 16
		do -- 16
			local _obj_0 = touch.location -- 16
			x, y = _obj_0.x, _obj_0.y -- 16
		end -- 16
		local name = _with_0:containsPoint(x, y) -- 17
		if name then -- 17
			return _with_0:addChild(_anon_func_0(App, Delay, Ease, Event, Label, Opacity, Scale, Sequence, Spawn, Vec2, _with_0, name, x, y)) -- 30
		end -- 17
	end) -- 15
	bone = _with_0 -- 10
end -- 10
local windowFlags = { -- 35
	"NoDecoration", -- 35
	"AlwaysAutoResize", -- 35
	"NoSavedSettings", -- 35
	"NoFocusOnAppearing", -- 35
	"NoNav", -- 35
	"NoMove" -- 35
} -- 35
local showDebug = bone.showDebug -- 43
return threadLoop(function() -- 44
	local width -- 45
	width = App.visualSize.width -- 45
	ImGui.SetNextWindowBgAlpha(0.35) -- 46
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 47
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 48
	return ImGui.Begin("DragonBones", windowFlags, function() -- 49
		ImGui.Text("DragonBones (Yuescript)") -- 50
		ImGui.Separator() -- 51
		ImGui.TextWrapped("Basic usage to create dragonBones! Tap it for a hit test.") -- 52
		local changed -- 53
		changed, showDebug = ImGui.Checkbox("BoundingBox", showDebug) -- 53
		if changed then -- 53
			bone.showDebug = showDebug -- 54
		end -- 53
	end) -- 54
end) -- 54
