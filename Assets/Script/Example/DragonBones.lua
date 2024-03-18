-- [yue]: Script/Example/DragonBones.yue
local DragonBone = dora.DragonBone -- 1
local p = _G.p -- 1
local print = _G.print -- 1
local tostring = _G.tostring -- 1
local Vec2 = dora.Vec2 -- 1
local Label = dora.Label -- 1
local Ease = dora.Ease -- 1
local Spawn = dora.Spawn -- 1
local Opacity = dora.Opacity -- 1
local Delay = dora.Delay -- 1
local App = dora.App -- 1
local Sequence = dora.Sequence -- 1
local Scale = dora.Scale -- 1
local Event = dora.Event -- 1
local threadLoop = dora.threadLoop -- 1
local ImGui = dora.ImGui -- 1
local boneStr = "DragonBones/NewDragon" -- 3
local animations = DragonBone:getAnimations(boneStr) -- 5
local looks = DragonBone:getLooks(boneStr) -- 6
p(animations, looks) -- 8
local _anon_func_0 = function(_with_0, Label, name, App, Sequence, Spawn, Scale, Ease, Delay, Opacity, Event, Vec2, x, y) -- 31
	local _with_1 = Label("sarasa-mono-sc-regular", 30) -- 19
	_with_1.text = name -- 20
	_with_1.color = App.themeColor -- 21
	_with_1:perform(Sequence(Spawn(Scale(1, 0, 2, Ease.OutQuad), Sequence(Delay(0.5), Opacity(0.5, 1, 0))), Event("Stop"))) -- 22
	_with_1.position = Vec2(x, y) -- 29
	_with_1.order = 100 -- 30
	_with_1:slot("Stop", function() -- 31
		return _with_1:removeFromParent() -- 31
	end) -- 31
	return _with_1 -- 19
end -- 19
local bone -- 10
do -- 10
	local _with_0 = DragonBone(boneStr) -- 10
	_with_0.look = looks[1] -- 11
	_with_0:play(animations[1], true) -- 12
	_with_0:slot("AnimationEnd", function(name) -- 13
		return print(tostring(name) .. " end!") -- 13
	end) -- 13
	_with_0.y = -200 -- 14
	_with_0.touchEnabled = true -- 15
	_with_0:slot("TapBegan", function(touch) -- 16
		local x, y -- 17
		do -- 17
			local _obj_0 = touch.location -- 17
			x, y = _obj_0.x, _obj_0.y -- 17
		end -- 17
		do -- 18
			local name = _with_0:containsPoint(x, y) -- 18
			if name then -- 18
				return _with_0:addChild(_anon_func_0(_with_0, Label, name, App, Sequence, Spawn, Scale, Ease, Delay, Opacity, Event, Vec2, x, y)) -- 31
			end -- 18
		end -- 18
	end) -- 16
	bone = _with_0 -- 10
end -- 10
local windowFlags = { -- 36
	"NoDecoration", -- 36
	"AlwaysAutoResize", -- 37
	"NoSavedSettings", -- 38
	"NoFocusOnAppearing", -- 39
	"NoNav", -- 40
	"NoMove" -- 41
} -- 35
local showDebug = bone.showDebug -- 42
return threadLoop(function() -- 43
	local width -- 44
	width = App.visualSize.width -- 44
	ImGui.SetNextWindowBgAlpha(0.35) -- 45
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 46
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 47
	return ImGui.Begin("DragonBones", windowFlags, function() -- 48
		ImGui.Text("DragonBones") -- 49
		ImGui.Separator() -- 50
		ImGui.TextWrapped("Basic usage to create dragonBones! Tap it for a hit test.") -- 51
		do -- 52
			local changed -- 52
			changed, showDebug = ImGui.Checkbox("BoundingBox", showDebug) -- 52
			if changed then -- 52
				bone.showDebug = showDebug -- 53
			end -- 52
		end -- 52
	end) -- 53
end) -- 53
